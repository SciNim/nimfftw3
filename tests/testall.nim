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

proc tensorTest() =
  test "Tensor":
    # Only FFTW_ESTIMATE is deterministic so for comparaison in a test suite it is the most appropriate
    # See readme
    let FFT_METHOD = FFTW_ESTIMATE.cuint
    # Show how to use a Complex64 -> Complex64 FFTW with 3D Tensor
    let dims = @[8, 10, 14]
    var
      inputData: Tensor[Complex64] = randomTensor[float64](dims, 10.0).asType(Complex64)
      output_dummy: Tensor[Complex64] = newTensor[Complex64](dims)
      input_dummy: Tensor[Complex64] = newTensor[Complex64](dims)

    # Create FFT plan
    let fft = fftw_plan_dft(input_dummy, output_dummy, FFTW_FORWARD, FFT_METHOD)
    # Allocate FFT output buffer
    var fftOutputData: Tensor[Complex64] = newTensor[Complex64](dims)
    # Execute FFT
    fftw_execute_dft(fft, inputData, fftOutputData)

    # Allocate IFFT output buffer
    var ifftOutputData = newTensor[Complex64](dims)
    # Create IFFT plan
    let ifft = fftw_plan_dft(fftOutputData, ifftOutputData, FFTW_BACKWARD, FFT_METHOD)
    # Execute IFFT
    fftw_execute_dft(ifft, fftOutputData, ifftOutputData)
    # Normalize IFFT: => FFTW does not normalize inverse fft
    let size = complex(ifftOutputData.size.float64)
    ifftOutputData.apply(x => x/size)

    # Check  X = FFT(IFFT(x))
    let diff = mean_relative_error(inputData.map(x => x.re), ifftOutputData.map(x => x.re))
    if diff > 1e-12:
      echo diff
      doAssert(false)
    else:
      doAssert(true)

    # Clean-up
    fftw_destroy_plan(fft)
    fftw_destroy_plan(ifft)

proc seq1DTest() =
  test "seq1d":
    let FFT_METHOD = FFTW_ESTIMATE.cuint
    # Show how to use a r2c FFTW with seq
    let size = 120
    var
      input_dummy = newSeq[float64](size)
      inbuf_dummy = cast[ptr UncheckedArray[float64]](addr(input_dummy[0]))
      output_dummy = newSeq[Complex64](size)
      outbuf_dummy = cast[ptr UncheckedArray[Complex64]](addr(output_dummy[0]))

    # Create FFT plan with dummy input / output buffer
    let fft = fftw_plan_dft_r2c_1d(size.cint, inbuf_dummy, outbuf_dummy, FFT_METHOD)
    # Allocate FFT output buffer
    var
      inputData = newSeq[float64](size)
      fftOutputData = newseq[Complex64](size)
    # Input is random float
    inputData.apply(x => rand(10.0))
    # Execute FFT buffer other than the ones used for plan creation (it makes reusing plan easier)
    fftw_execute_dft_r2c(fft, inputData.toUnsafeView(), fftOutputData.toUnsafeView())

    # Allocate IFFT output buffer
    var ifftOutputData = newSeq[float64](size)
    # Create IFFT plan
    let ifft = fftw_plan_dft_c2r_1d(size.cint, fftOutputData.toUnsafeView(), ifftOutputData.toUnsafeView(), FFT_METHOD)
    # Execute IFFT
    fftw_execute(ifft)
    # Normalize IFFT: => FFTW does not normalize inverse fft
    ifftOutputData = ifftOutputData.map(x => x / float64(size))

    # Check  X = FFT(IFFT(x))
    for i in 0..<inputData.len():
      let diff = abs(inputData[i] - ifftOutputData[i])
      if diff > 1e-12:
        echo diff
        doAssert(false)
      else:
        doAssert(true)

    # Clean-up
    fftw_destroy_plan(fft)
    fftw_destroy_plan(ifft)

proc seq2DTest() =
  test "seq2d":
    let FFT_METHOD = FFTW_ESTIMATE.cuint
    # Show how to use a r2c FFTW with seq
    let size = 120
    var
      input_dummy = newSeq[float64](size*size)
      inbuf_dummy = cast[ptr UncheckedArray[float64]](addr(input_dummy[0]))
      output_dummy = newSeq[Complex64](size*size)
      outbuf_dummy = cast[ptr UncheckedArray[Complex64]](addr(output_dummy[0]))

    # Create FFT plan with dummy input / output buffer
    let fft = fftw_plan_dft_r2c_2d(size.cint, size.cint, inbuf_dummy, outbuf_dummy, FFT_METHOD)

    # Allocate FFT output buffer
    var
      inputData = newSeq[float64](size*size)
      fftOutputData = newSeq[Complex64](size*size)
    # Assign random datas
    for i in 0..<size:
      for j in 0..<size:
        inputData[i*size+j] = rand(10.0)

    # Execute FFT buffer other than the ones used for plan creation (it makes reusing plan easier)
    fftw_execute_dft_r2c(fft, inputData.toUnsafeView(), fftOutputData.toUnsafeView())

    # Allocate IFFT output buffer
    var ifftOutputData = newSeq[float64](size*size)
    # Create IFFT plan
    let ifft = fftw_plan_dft_c2r_2d(size.cint, size.cint, fftOutputData.toUnsafeView(), ifftOutputData.toUnsafeView(), FFT_METHOD)
    # Execute IFFT plan
    fftw_execute(ifft)
    # Normalize IFFT: => FFTW does not normalize inverse fft
    ifftOutputData.apply(x => x/float(size*size))

    # Check  X = FFT(IFFT(x))
    for i in 0..<size:
      for j in 0..<size:
        let diff = abs(inputData[i*size+j]  - ifftOutputData[i*size+j])
        doAssert diff <= 1e-12

    # Clean-up
    fftw_destroy_plan(fft)
    fftw_destroy_plan(ifft)

when isMainModule:
  suite "FFTW DFT":
    seq1DTest()
    tensorTest()
    seq2DTest()
