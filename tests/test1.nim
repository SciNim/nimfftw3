# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.
#
import arraymancer
import unittest
import fftw3


test "fftw_plan_dft_r2c":
  var dims: seq[int] = @[3, 2, 2]
  var input: Tensor[float64] = randomTensor(dims, 100).astype(float64)
  apply_inline(input):
    x / 100
  var output: Tensor[Complex64] = newTensor[Complex64](dims)
  let fft = fftw_plan_dft_r2c(input, output)
  fftw_execute(fft)
