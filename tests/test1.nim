import unittest
import macros
import sequtils
import os
import sugar

import fftw3
import utils

import arraymancer

import random
import times
import system

proc fixConjugate*(output: Tensor[Complex64]): Tensor[Complex64] =
  let
    X = output.shape[0]
    Y = output.shape[1]
    Z = output.shape[2]
    MZ = 2*Z - 1

  result = newTensor[Complex64]([X, Y, MZ])
  result[_, _, 0] = output[_, _, 0]

  for x in 0||(X-1):
    for y in 0||(Y-1):
      for z in 1||((Z+1 div 2) - 1):
        var mx = X - x
        var my = Y - y
        var mz = MZ - z

        if x == 0:
          mx = x

        if y == 0:
          my = y

        result[mx, my, mz] = conjugate(output[x, y, z])
        result[x, y, z] = output[x, y, z]

proc mirrorTime[T](data: Tensor[T]): Tensor[T]=
  result = concat(data[_.._, _.._, ^1..1|-1], data, axis=2)

proc main()=
  let odims = @[4, 3, 7]
  var dims: seq[int] = @[odims[0], odims[1], 2*odims[2]-1]

  var randData: Tensor[float64] = randomTensor(odims, 10).astype(float64)

  var r = initRand(epochTime().int64)
  apply_inline(randData):
    x + r.rand(100.0)/100.0

  ## Mirror data to avoid dealing with symetry in FFTW
  randData = mirrorTime(randData)

  var output_dummy: Tensor[Complex64] = newTensor[Complex64](dims)
  var input_dummy: Tensor[Complex64] = newTensor[Complex64](dims)
  let fft = fftw_plan_dft(input_dummy, output_dummy, FFTW_FORWARD, FFTW_ESTIMATE)
  var output : Tensor[Complex64] = newTensor[Complex64](dims)
  fftw_execute_dft(fft, randData.map(x => complex(x)), output)

  var orig = newTensor[Complex64](dims)
  let ifft = fftw_plan_dft(output, orig, FFTW_BACKWARD, FFTW_ESTIMATE)
  fftw_execute_dft(ifft, output, orig)
  let size = complex(orig.size.float64)
  orig = orig /. size

  test "fftw_plan_dft ifft(fft(x)) compared to original data":
    check compare(randData, orig.map(x => x.re))

  fftw_destroy_plan(fft)

main()
