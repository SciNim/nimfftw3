import sugar
import random
import unittest
import sequtils

import arraymancer

import fftw3
import fftw3/libutils

randomize()

proc toUnsafeView*[T: Complex64|float64](buf: var openArray[T]): ptr UncheckedArray[T] {.inline.} =
  cast[ptr UncheckedArray[T]](addr(buf[0]))

proc toUnsafeView*[T: Complex64|float64](buf: var openArray[seq[T]]): ptr UncheckedArray[T] {.inline.} =
  cast[ptr UncheckedArray[T]](addr(buf[0]))

proc seq1DTest() =
  test "seq1d":
    # Show how to use a r2c FFTW with seq
    let size = 120
    var
      input_dummy = newSeq[float64](size)
      inbuf_dummy = cast[ptr UncheckedArray[float64]](addr(input_dummy[0]))
      output_dummy = newSeq[Complex64](size)
      outbuf_dummy = cast[ptr UncheckedArray[Complex64]](addr(output_dummy[0]))

    # Create FFT plan with dummy input / output buffer
    let fft = fftw_plan_dft_r2c_1d(size.cint, inbuf_dummy, outbuf_dummy, FFTW_ESTIMATE)

    # Allocate FFT output buffer
    var
      inputData = newSeq[float64](size)
      fftOutputData = newseq[Complex64](size)

    # Input is float
    inputData.apply(x => rand(10.0))

    # Execute FFT
    fftw_execute_dft_r2c(fft, inputData.toUnsafeView(), fftOutputData.toUnsafeView())

    # Allocate IFFT output buffer
    var ifftOutputData = newSeq[float64](size)

    # Create IFFT plan
    let ifft = fftw_plan_dft_c2r_1d(size.cint, fftOutputData.toUnsafeView(), ifftOutputData.toUnsafeView(), FFTW_ESTIMATE)

    # Execute IFFT
    fftw_execute(ifft)
    # Normalize IFFT: => FFTW does not normalize inverse fft
    ifftOutputData = ifftOutputData.map(x => x / float64(size))

    # Check  X = FFT(IFFT(x))
    for i in 0..<inputData.len():
      doAssert abs(inputData[i] - ifftOutputData[i]) <= 1e-12

    # Clean-up
    fftw_destroy_plan(fft)
    fftw_destroy_plan(ifft)

proc seq2DTest() =
  test "seq2d":
    # Show how to use a r2c FFTW with seq
    let size = 120
    var
      input_dummy = newSeqWith(size, newSeq[float64](size))
      inbuf_dummy = cast[ptr UncheckedArray[float64]](addr(input_dummy[0]))
      output_dummy = newSeqWith(size, newSeq[Complex64](size))
      outbuf_dummy = cast[ptr UncheckedArray[Complex64]](addr(output_dummy[0]))

    # Create FFT plan with dummy input / output buffer
    let fft = fftw_plan_dft_r2c_2d(size.cint, size.cint, inbuf_dummy, outbuf_dummy, FFTW_ESTIMATE)

    # Allocate FFT output buffer
    var
      inputData = newSeqWith(size, newSeq[float64](size))
      fftOutputData = newSeqWith(size, newSeq[Complex64](size))

    for i in 0..<size:
      for j in 0..<size:
        inputData[i][j] = rand(10.0)

    # Execute FFT
    fftw_execute_dft_r2c(fft, inputData.toUnsafeView(), fftOutputData.toUnsafeView())

    # Allocate IFFT output buffer
    var ifftOutputData = newSeqWith(size, newSeq[float64](size))

    # Create IFFT plan
    let ifft = fftw_plan_dft_c2r_2d(size.cint, size.cint, fftOutputData.toUnsafeView(), ifftOutputData.toUnsafeView(), FFTW_ESTIMATE)

    # Execute IFFT
    fftw_execute(ifft)

    # Normalize IFFT: => FFTW does not normalize inverse fft
    for i in 0..<size:
      for j in 0..<size:
        ifftOutputData[i][j] = ifftOutputData[i][j] / float(size*size)

    # Check  X = FFT(IFFT(x))
    for i in 0..<inputData.len():
      for (e1, e2) in zip(inputData[i], ifftOutputData[i]):
        doAssert abs(e1 - e2) <= 1e-12

    # Clean-up
    fftw_destroy_plan(fft)
    fftw_destroy_plan(ifft)


proc tensorTest() = # fftw_plan_dft, fftw_execute_dft
  test "Tensor":
    # Show how to use a Complex64 -> Complex64 FFTW with Tensor
    let dims = @[4, 3, 2*7-1]
    var
      inputData: Tensor[float64] = randomTensor[float64](dims, 100.0)
      output_dummy: Tensor[Complex64] = newTensor[Complex64](dims)
      input_dummy: Tensor[Complex64] = newTensor[Complex64](dims)

    # Create FFT plan
    let fft = fftw_plan_dft(input_dummy, output_dummy, FFTW_FORWARD, FFTW_ESTIMATE)

    # Allocate FFT output buffer
    var fftOutputData: Tensor[Complex64] = newTensor[Complex64](dims)

    # Execute FFT
    fftw_execute_dft(fft, inputData.map(x => complex(x)), fftOutputData)

    # Allocate IFFT output buffer
    var ifftOutputData = newTensor[Complex64](dims)

    # Create IFFT plan
    let ifft = fftw_plan_dft(fftOutputData, ifftOutputData, FFTW_BACKWARD, FFTW_ESTIMATE)

    # Execute IFFT
    fftw_execute_dft(ifft, fftOutputData, ifftOutputData)

    # Normalize IFFT: => FFTW does not normalize inverse fft
    let size = complex(ifftOutputData.size.float64)
    ifftOutputData = ifftOutputData /. size

    # Check  X = FFT(IFFT(x))
    doAssert mean_relative_error(inputData, ifftOutputData.map(x => x.re)) <= 1e-12

    # Clean-up
    fftw_destroy_plan(fft)
    fftw_destroy_plan(ifft)

when isMainModule:
  suite "FFTW DFT":
    seq1DTest()
    seq2DTest()
    tensorTest()
