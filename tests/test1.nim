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

proc mirrorTime[T](data: Tensor[T]): Tensor[T]=
  result = concat(data[_.._, _.._, ^1..1|-1], data, axis=2)

proc main()=
  let dims = @[4, 3, 2*7-1]

  var randData: Tensor[float64] = randomTensor(dims, 10).astype(float64)

  var r = initRand(epochTime().int64)
  apply_inline(randData):
    x + r.rand(100.0)/100.0

  ## Mirror data to avoid dealing with symetry in FFTW

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
