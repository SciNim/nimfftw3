import sugar
import random
import times
import system
import arraymancer

import fftw3
import fftw3/libutils

import utils

block: # fftw_plan_dft, fftw_execute_dft
  let dims = @[4, 3, 2*7-1]

  var randData: Tensor[float64] = newTensor[float64](dims)

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

  # FFTW does not normalize inverse fft
  let size = complex(orig.size.float64)
  orig = orig /. size

  doAssert compare(randData, orig.map(x => x.re))

  fftw_destroy_plan(fft)
  fftw_destroy_plan(ifft)
