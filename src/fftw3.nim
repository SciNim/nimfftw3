### Introduction

## Nim binding for the FFTW3 library
##
## FFTW is one the best library to compute Fourier transforms of various kinds with high performance.
##
## Make sure FFTW's documentation : http://www.fftw.org/fftw3_doc/
##
## The C-bindings can be used identically to the C-API
##
## In order to simplify usage an Arraymancer high level API is added on top of the low-level API.
##

### Examples

####  C-Binding low-level example

##  .. code-block:: nim
##    const N = 3
##    var input: array[1..N, cdouble] = [0.0, 2.0, 6.0]
##    var output: array[1..N, cdouble]
##    let plan = fftw_plan_r2r_1d(N, addr(input[low(input)]),
##                                addr(output[low(output)]), FFTW_REDFT00, FFTW_ESTIMATE)
##    input = [0.0, 2.0, 6.0]
##    fftw_execute(plan)
##    let expectedResult: array[1..N, cdouble] = [10.0, -6.0, 2.0]
##    for i in low(output)..high(output):
##      assert abs(output[i] - expectedResult[i]) < 1.0e-14

####  Arraymancer API example

## .. code-block:: nim
##   var input  : Tensor[Complex64] = # Insert data in your input Tensor...
##   # Allocate output Tensor
##   var output = newTensor[Complex64](input.shape.toSeq)
##   # Create a plan
##   var plan : fftw_plan = fftw_plan_dft(input, output, FFTW_FORWARD, FFTW_ESTIMATE)
##   # Execute plan in-place
##   fftw_execute(plan)

### Planner flags

## Planner are const integer that specify how the DFT plan should be computed.
## More information about `planner flags <http://www.fftw.org/doc/Planner-Flags.html>`_

import arraymancer
import sequtils
import complex
import arraymancer/tensor/private/p_accessors
import fftw3/libutils
# Import mostly for documentation links
{.push warning[UnusedImport]: off.}
import fftw3/guru, fftw3/wisdom
{.pop.}
# export used types
export fftw_plan
export fftw_r2r_kind

const
    FFTW_MEASURE* = 0  ## ``fftw_plan`` planner flag.
    ##
    ## Find an optimized plan by computing several FFTs and measuring their execution time. Default planning option.
    FFTW_ESTIMATE* = 1 shl 6 ## ``fftw_plan`` planner flag.
    ##
    ## Instead of time measurements, a simple heuristic is used to pick a plan quickly. The input/output arrays are not overwritten during planning.
    FFTW_PATIENT* = 1 shl 5 ## ``fftw_plan`` planner flag.
    ##
    ## Like FFTW_MEASURE, but considers a wider range of algorithms.
    FFTW_EXHAUSTIVE* = 1 shl 3 ## ``fftw_plan`` planner flag.
    ##
    ## Like FFTW_PATIENT, but considers an even wider range of algorithms.
    FFTW_WISDOM_ONLY* = 1 shl 21 ## ``fftw_plan`` planner flag.
    ##
    ## Special planning mode in which the plan is created only if wisdow is available.

    FFTW_DESTROY_INPUT* = 1 ## ``fftw_plan`` planner flag.
    ##
    ## An out-of-place transform is allowed to overwrite its input array with arbitrary data. Default value for complex-to-real transform.
    FFTW_PRESERVE_INPUT* = 1 shl 4 ## ``fftw_plan`` planner flag.
    ##
    ## An out-of-place transform must not change its input array. Default value except for complex-to-real (c2r and hc2r).
    FFTW_UNALIGNED* = 1 shl 1  ## ``fftw_plan`` planner flag.
    ##
    ## The algorithm may not impose any unusual alignment requirements on the input/output arrays.(i.e. no SIMD may be used).
    FFTW_CONSERVE_MEMORY* = 1 shl 2

const
    FFTW_FORWARD* = -1 ## ``fftw_plan`` sign flag.
    ##
    ## Compute a DFT transform.
    FFTW_BACKWARD* = 1 ## ``fftw_plan`` sign flag.
    ##
    ## Compute an inverse DFT transform.


# FFT Shift
proc circshift_impl[T](t: Tensor[T], xshift: int, yshift: int, zshift: int): Tensor[T] =
  assert(t.rank == 3)
  var X = t.shape[0]
  var Y = t.shape[1]
  var Z = t.shape[2]

  result = newTensor[T](t.shape.toSeq)
  for i in 0||(X-1):
    var ii = (i + xshift) mod X
    for j in 0||(Y-1):
      var jj = (j + yshift) mod Y
      for k in 0||(Z-1):
        var kk = (k + zshift) mod Z
        result[ii, jj, kk] = t[i, j, k]

proc circshift_impl[T](t: Tensor[T], xshift: int, yshift: int): Tensor[T] =
  assert(t.rank == 2)
  var X = t.shape[0]
  var Y = t.shape[1]

  result = newTensor[T](t.shape.toSeq)
  for i in 0||(X-1):
    var ii = (i + xshift) mod X
    for j in 0||(Y-1):
      var jj = (j + yshift) mod Y
      result[ii, jj] = t[i, j]

proc circshift_impl[T](t: Tensor[T], xshift: int): Tensor[T] =
  assert(t.rank == 1)
  var X = t.shape[0]

  result = newTensor[T](t.shape.toSeq)
  for i in 0||(X-1):
    var ii = (i + xshift) mod X
    result[ii] = t[i]

# TODO : Generic implementation in parallel
proc circshift_impl[T](t: Tensor[T], shift: seq[int]): Tensor[T] =
  let shape = t.shape.toSeq
  result = newTensor[T](t.shape.toSeq)
  for coord, values in t:
    var newcoord: seq[int] = newSeq[int](t.rank)
    for i in 0..<t.rank:
      newcoord[i] = (coord[i]+shift[i]) mod shape[i]
    result.atIndexMut(newcoord, values)

proc circshift*[T](t: Tensor[T], shift: seq[int]): Tensor[T] =
  ## Generic Circshift
  assert(t.rank == shift.len)
  case t.rank
  of 1:
    result = circshift_impl(t, shift[0])
  of 2:
    result = circshift_impl(t, shift[0], shift[1])
  of 3:
    result = circshift_impl(t, shift[0], shift[1], shift[2])
  else:
    result = circshift_impl(t, shift)

proc fftshift*[T](t: Tensor[T]): Tensor[T] =
  ## Common fftshift function
  runnableExamples:
    import arraymancer
    let input_tensor = randomTensor[float64](10, 10, 10, 10.0)
    # output_tensor is the fftshift of input_tensor
    var output_tensor = fftshift(input_tensor)

  ## Calculate fftshift using circshift
  let xshift = t.shape[0] div 2
  let yshift = t.shape[1] div 2
  let zshift = t.shape[2] div 2
  result = circshift(t, @[xshift.int, yshift.int, zshift.int])

proc ifftshift*[T](t: Tensor[T]): Tensor[T] =
  ## Common ifftshift function
  runnableExamples:
    import arraymancer
    let input_tensor = randomTensor[float64](10, 10, 10, 10.0)
    # output_tensor is the fftshift of input_tensor
    var output_tensor = ifftshift(input_tensor)

  # Calculate inverse fftshift using circshift
  let xshift = (t.shape[0]+1) div 2
  let yshift = (t.shape[1]+1) div 2
  let zshift = (t.shape[2]+1) div 2
  result = circshift(t, @[xshift.int, yshift.int, zshift.int])

# FFTW Execute API
proc fftw_execute*(p: fftw_plan) {.cdecl, importc: "fftw_execute", dynlib: Fftw3Lib.}
  ## Execute a plan

proc fftw_execute_dft*(p: fftw_plan, inptr: ptr Complex64, outptr: ptr Complex64) {.cdecl,
        importc: "fftw_execute_dft", dynlib: Fftw3Lib.}
  ## Execute a plan with different input / output memory address

proc fftw_execute_dft*(p: fftw_plan, input: Tensor[Complex64], output: Tensor[Complex64]) =
  ## Execute an fft using a pre-calculated ``fftw_plan``
  runnableExamples:
    import arraymancer
    import fftw3
    let shape = @[100, 100]
    # Create dummy tensors
    var
      dummy_input = newTensor[Complex64](shape)
      dummy_output = newTensor[Complex64](shape)
    # Use dummy tensor to create plan
    var plan: fftw_plan = fftw_plan_dft(dummy_input, dummy_output, FFTW_FORWARD, FFTW_ESTIMATE)
    # Allocate output Tensor
    # It is crucial to NOT modify the dimensions of the tensor
    var inputRe: Tensor[float64] = randomTensor[float64](shape, 10.0)
    var inputIm: Tensor[float64] = randomTensor[float64](shape, 20.0)
    var input = map2_inline(inputRe, inputIm):
      complex64(x, y)
    let in_shape = @(input.shape)
    var output = newTensor[Complex64](in_shape)
    # Execute plan with output_tensor and input_tensor
    fftw_execute_dft(plan, input, output) ## Execute a plan on new Tensor

  fftw_execute_dft(p, input.get_data_ptr, output.get_data_ptr)

proc fftw_execute_r2r*(p: fftw_plan, inptr: ptr cdouble, outptr: ptr cdouble) {.cdecl, importc: "fftw_execute_r2r",
        dynlib: Fftw3Lib.}
  ## Execute a plan real-to-real

proc fftw_execute_dft_r2c*(p: fftw_plan, inptr: ptr cdouble, outptr: ptr Complex64) {.cdecl,
        importc: "fftw_execute_dft_r2c", dynlib: Fftw3Lib.}
  ## Execute a plan real-to-complex

proc fftw_execute_dft_r2c*(p: fftw_plan, input: Tensor[float64], output: Tensor[Complex64]) =
  ## Execute a real-to-complex plan on new Tensor
  fftw_execute_dft_r2c(p, cast[ptr cdouble](input.get_data_ptr), output.get_data_ptr)

proc fftw_execute_dft_c2r*(p: fftw_plan, inptr: ptr Complex64, outptr: ptr cdouble) {.cdecl,
        importc: "fftw_execute_dft_c2r", dynlib: Fftw3Lib.}
  ## Execute a plan complex-to-real

proc fftw_execute_dft_c2r*(p: fftw_plan, input: Tensor[Complex64], output: Tensor[float64]) =
  ## Execute a complex-to-real plan on new Tensor
  fftw_execute_dft_c2r(p, input.get_data_ptr, cast[ptr cdouble](output.get_data_ptr))

# FFTW Plan API
proc fftw_plan_dft*(rank: cint, n: ptr cint, inptr: ptr Complex64,
                    outptr: ptr Complex64, sign: cint, flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_dft", dynlib: Fftw3Lib.}

proc fftw_plan_dft*(input: Tensor[Complex64], output: Tensor[Complex64], sign: cint,
        flags: cuint = FFTW_MEASURE): fftw_plan =
  ## Generic Tensor plan calculation using FFTW_MEASURE as a default fftw flag.
  ## Read carefully FFTW documentation about the input / output dimension it will change depending on the transformation.
  let shape: seq[cint] = map(input.shape.toSeq, proc(x: int): cint = x.cint)
  result = fftw_plan_dft(input.rank.cint, (shape[0].unsafeaddr), input.get_data_ptr, output.get_data_ptr, sign, flags)

proc fftw_plan_dft_1d*(n: cint, inptr: ptr Complex64, outptr: ptr Complex64,
                       sign: cint, flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_dft_1d", dynlib: Fftw3Lib.}

proc fftw_plan_dft_1d*(input: Tensor[Complex64], output: Tensor[Complex64], sign: cint,
        flags: cuint = FFTW_MEASURE): fftw_plan =
  ## 1D Tensor plan calculation using FFTW_MEASURE as a default fftw flag.
  assert(input.rank == 1)
  let shape: seq[cint] = map(input.shape.toSeq, proc(x: int): cint = x.cint)
  result = fftw_plan_dft_1d(shape[0], input.get_data_ptr, output.get_data_ptr, sign, flags)

proc fftw_plan_dft_2d*(n0: cint, n1: cint, inptr: ptr Complex64,
                       outptr: ptr Complex64, sign: cint, flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_dft_2d", dynlib: Fftw3Lib.}

proc fftw_plan_dft_2d*(input: Tensor[Complex64], output: Tensor[Complex64], sign: cint,
        flags: cuint = FFTW_MEASURE): fftw_plan =
  ## 2D Tensor plan calculation using FFTW_MEASURE as a default fftw flag.
  assert(input.rank == 2)
  let shape: seq[cint] = map(input.shape.toSeq, proc(x: int): cint = x.cint)
  result = fftw_plan_dft_2d(shape[0], shape[1], input.get_data_ptr, output.get_data_ptr, sign, flags)

proc fftw_plan_dft_3d*(n0: cint, n1: cint, n2: cint, inptr: ptr Complex64,
                       outptr: ptr Complex64, sign: cint, flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_dft_3d", dynlib: Fftw3Lib.}

proc fftw_plan_dft_3d*(input: Tensor[Complex64], output: Tensor[Complex64], sign: cint,
        flags: cuint = FFTW_MEASURE): fftw_plan =
  ## 3D Tensor plan calculation using FFTW_MEASURE as a default fftw flag.
  assert(input.rank == 3)
  let shape: seq[cint] = map(input.shape.toSeq, proc(x: int): cint = x.cint)
  result = fftw_plan_dft_3d(shape[0], shape[1], shape[2], input.get_data_ptr, output.get_data_ptr, sign, flags)

proc fftw_plan_dft_r2c*(rank: cint, n: ptr cint, inptr: ptr cdouble,
                        outptr: ptr Complex64, flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_dft_r2c", dynlib: Fftw3Lib.}

proc fftw_plan_dft_r2c*(input: Tensor[float64], output: Tensor[Complex64], flags: cuint = FFTW_MEASURE): fftw_plan =
  ## Generic Real-to-Complex Tensor plan calculation using FFTW_MEASURE as a default fftw flag.
  ## Read carefully FFTW documentation about the input / output dimension as FFTW does not calculate redundant conjugate value.
  let shape: seq[cint] = map(input.shape.toSeq, proc(x: int): cint = x.cint)
  result = fftw_plan_dft_r2c(input.rank.cint, (shape[0].unsafeaddr), cast[ptr cdouble](input.get_data_ptr),
          output.get_data_ptr, flags)

proc fftw_plan_dft_r2c_1d*(n: cint, inptr: ptr cdouble, outptr: ptr Complex64,
                           flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_dft_r2c_1d", dynlib: Fftw3Lib.}

proc fftw_plan_dft_r2c_1d*(input: Tensor[float64], output: Tensor[Complex64],
        flags: cuint = FFTW_MEASURE): fftw_plan =
  ## 1D Real-to-Complex Tensor plan calculation using FFTW_MEASURE as a default fftw flag.
  assert(input.rank == 1)
  let shape: seq[cint] = map(input.shape.toSeq, proc(x: int): cint = x.cint)
  result = fftw_plan_dft_r2c_1d(shape[0], cast[ptr cdouble](input.get_data_ptr), output.get_data_ptr, flags)

proc fftw_plan_dft_r2c_2d*(n0: cint, n1: cint, inptr: ptr cdouble,
                           outptr: ptr Complex64, flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_dft_r2c_2d", dynlib: Fftw3Lib.}

proc fftw_plan_dft_r2c_2d*(input: Tensor[float64], output: Tensor[Complex64],
        flags: cuint = FFTW_MEASURE): fftw_plan =
  ## 2D Real-to-Complex Tensor plan calculation using FFTW_MEASURE as a default fftw flag.
  assert(input.rank == 2)
  let shape: seq[cint] = map(input.shape.toSeq, proc(x: int): cint = x.cint)
  result = fftw_plan_dft_r2c_2d(shape[0], shape[1], cast[ptr cdouble](input.get_data_ptr), output.get_data_ptr, flags)

proc fftw_plan_dft_r2c_3d*(n0: cint, n1: cint, n2: cint, inptr: ptr cdouble,
                           outptr: ptr Complex64, flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_dft_r2c_3d", dynlib: Fftw3Lib.}

proc fftw_plan_dft_r2c_3d*(input: Tensor[float64], output: Tensor[Complex64],
        flags: cuint = FFTW_MEASURE): fftw_plan =
  ## 3D Real-to-Complex Tensor plan calculation using FFTW_MEASURE as a default fftw flag.
  assert(input.rank == 3)
  let shape: seq[cint] = map(input.shape.toSeq, proc(x: int): cint = x.cint)
  result = fftw_plan_dft_r2c_3d(shape[0], shape[1], shape[2], cast[ptr cdouble](input.get_data_ptr),
          output.get_data_ptr, flags)

proc fftw_plan_dft_c2r*(rank: cint, n: ptr cint, inptr: ptr Complex64,
                        outptr: ptr cdouble, flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_dft_c2r", dynlib: Fftw3Lib.}

proc fftw_plan_dft_c2r*(input: Tensor[Complex64], output: Tensor[float64], flags: cuint = FFTW_MEASURE): fftw_plan =
  ## Generic Complex-to-real Tensor plan calculation using FFTW_MEASURE as a default fftw flag.
  let shape: seq[cint] = map(input.shape.toSeq, proc(x: int): cint = x.cint)
  result = fftw_plan_dft_c2r(input.rank.cint, (shape[0].unsafeaddr), input.get_data_ptr, cast[ptr cdouble](
          output.get_data_ptr), flags)

proc fftw_plan_dft_c2r_1d*(n: cint, inptr: ptr Complex64, outptr: ptr cdouble,
                           flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_dft_c2r_1d", dynlib: Fftw3Lib.}

proc fftw_plan_dft_c2r_1d*(input: Tensor[Complex64], output: Tensor[float64],
        flags: cuint = FFTW_MEASURE): fftw_plan =
  ## 1D Complex-to-real Tensor plan calculation using FFTW_MEASURE as a default fftw flag.
  assert(input.rank == 1)
  let shape: seq[cint] = map(input.shape.toSeq, proc(x: int): cint = x.cint)
  result = fftw_plan_dft_c2r_1d(shape[0], input.get_data_ptr, cast[ptr cdouble](output.get_data_ptr), flags)

proc fftw_plan_dft_c2r_2d*(n0: cint, n1: cint, inptr: ptr Complex64,
                           outptr: ptr cdouble, flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_dft_c2r_2d", dynlib: Fftw3Lib.}

proc fftw_plan_dft_c2r_2d*(input: Tensor[Complex64], output: Tensor[float64],
        flags: cuint = FFTW_MEASURE): fftw_plan =
  ## 2D Complex-to-real Tensor plan calculation using FFTW_MEASURE as a default fftw flag.
  assert(input.rank == 2)
  let shape: seq[cint] = map(input.shape.toSeq, proc(x: int): cint = x.cint)
  result = fftw_plan_dft_c2r_2d(shape[0], shape[1], input.get_data_ptr, cast[ptr cdouble](output.get_data_ptr), flags)

proc fftw_plan_dft_c2r_3d*(n0: cint, n1: cint, n2: cint, inptr: ptr Complex64,
                           outptr: ptr cdouble, flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_dft_c2r_3d", dynlib: Fftw3Lib.}

proc fftw_plan_dft_c2r_3d*(input: Tensor[Complex64], output: Tensor[float64],
        flags: cuint = FFTW_MEASURE): fftw_plan =
  ## 3D Complex-to-real Tensor plan calculation using FFTW_MEASURE as a default fftw flag.
  assert(input.rank == 3)
  let shape: seq[cint] = map(input.shape.toSeq, proc(x: int): cint = x.cint)
  result = fftw_plan_dft_c2r_3d(shape[0], shape[1], shape[2], input.get_data_ptr, cast[ptr cdouble](
          output.get_data_ptr), flags)

proc fftw_plan_r2r*(rank: cint, n: ptr cint, inptr: ptr cdouble,
                    outptr: ptr cdouble, kind: ptr fftw_r2r_kind, flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_r2r", dynlib: Fftw3Lib.}

proc fftw_plan_r2r*(input: Tensor[float64], output: Tensor[float64], kinds: seq[fftw_r2r_kind],
        flags: cuint = FFTW_MEASURE): fftw_plan =
  ## Generic real-to-real Tensor plan calculation using FFTW_MEASURE as a default fftw flag.
  let shape: seq[cint] = map(input.shape.toSeq, proc(x: int): cint = x.cint)
  result = fftw_plan_r2r(input.rank.cint, shape[0].unsafeaddr, cast[ptr cdouble](input.get_data_ptr), cast[
          ptr cdouble](output.get_data_ptr), kinds[0].unsafeaddr, flags)

proc fftw_plan_r2r_1d*(n: cint, inptr: ptr cdouble, outptr: ptr cdouble,
                       kind: fftw_r2r_kind, flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_r2r_1d", dynlib: Fftw3Lib.}

proc fftw_plan_r2r_1d*(input: Tensor[float64], output: Tensor[float64], kind: fftw_r2r_kind,
        flags: cuint = FFTW_MEASURE): fftw_plan =
  ## 1D real-to-real Tensor plan calculation using FFTW_MEASURE as a default fftw flag.
  assert(input.rank == 1)
  let shape: seq[cint] = map(input.shape.toSeq, proc(x: int): cint = x.cint)
  result = fftw_plan_r2r_1d(shape[0], cast[ptr cdouble](input.get_data_ptr), cast[ptr cdouble](output.get_data_ptr),
          kind, flags)

proc fftw_plan_r2r_2d*(n0: cint, n1: cint, inptr: ptr cdouble,
                       outptr: ptr cdouble, kind0: fftw_r2r_kind,
                       kind1: fftw_r2r_kind, flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_r2r_2d", dynlib: Fftw3Lib.}

proc fftw_plan_r2r_2d*(input: Tensor[float64], output: Tensor[float64], kinds: seq[fftw_r2r_kind],
        flags: cuint = FFTW_MEASURE): fftw_plan =
  ## 2D real-to-real Tensor plan calculation using FFTW_MEASURE as a default fftw flag.
  assert(input.rank == 2)
  let shape: seq[cint] = map(input.shape.toSeq, proc(x: int): cint = x.cint)
  result = fftw_plan_r2r_2d(shape[0], shape[1], cast[ptr cdouble](input.get_data_ptr), cast[ptr cdouble](
          output.get_data_ptr), kinds[0], kinds[1], flags)


proc fftw_plan_r2r_3d*(n0: cint, n1: cint, n2: cint, inptr: ptr cdouble,
                       outptr: ptr cdouble, kind0: fftw_r2r_kind,
                       kind1: fftw_r2r_kind, kind2: fftw_r2r_kind, flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_r2r_3d", dynlib: Fftw3Lib.}

proc fftw_plan_r2r_3d*(input: Tensor[float64], output: Tensor[float64], kinds: seq[fftw_r2r_kind],
        flags: cuint = FFTW_MEASURE): fftw_plan =
  ## 3D real-to-real Tensor plan calculation using FFTW_MEASURE as a default fftw flag.
  assert(input.rank == 3)
  let shape: seq[cint] = map(input.shape.toSeq, proc(x: int): cint = x.cint)
  result = fftw_plan_r2r_3d(shape[0], shape[1], shape[2], cast[ptr cdouble](input.get_data_ptr), cast[ptr cdouble](
          output.get_data_ptr), kinds[0], kinds[1], kinds[2], flags)

# FFTW Plan Many API
proc fftw_plan_many_dft*(rank: cint, n: ptr cint, howmany: cint,
                         inptr: ptr Complex64, inembed: ptr cint,
                         istride: cint, idist: cint, outptr: ptr Complex64,
                         onembed: ptr cint, ostride: cint, odist: cint,
                         sign: cint, flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_many_dft", dynlib: Fftw3Lib.}
    ## Plan mutliple multidimensionnal complex DFTs and extend ``fftw_plan_dft`` to compute howmany transforms, each having rank rank and size n.
    ## ``howmany`` is the (nonnegative) number of transforms to compute. The resulting plan computes howmany transforms, where the input of the k-th transform is at location in+k*idist (in C pointer arithmetic), and its output is at location out+k*odist.
    ## Plans obtained in this way can often be faster than calling FFTW multiple times for the individual transforms. The basic fftw_plan_dft interface corresponds to howmany=1 (in which case the dist parameters are ignored).

proc fftw_plan_many_dft_c2r*(rank: cint, n: ptr cint, howmany: cint,
                             inptr: ptr Complex64, inembed: ptr cint,
                             istride: cint, idist: cint, outptr: ptr cdouble,
                             onembed: ptr cint, ostride: cint, odist: cint,
                             flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_many_dft_c2r", dynlib: Fftw3Lib.}

proc fftw_plan_many_dft_r2c*(rank: cint, n: ptr cint, howmany: cint,
                             inptr: ptr cdouble, inembed: ptr cint,
                             istride: cint, idist: cint,
                             outptr: ptr Complex64, onembed: ptr cint,
                             ostride: cint, odist: cint, flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_many_dft_r2c", dynlib: Fftw3Lib.}

proc fftw_plan_many_r2r*(rank: cint, n: ptr cint, howmany: cint,
                         inptr: ptr cdouble, inembed: ptr cint, istride: cint,
                         idist: cint, outptr: ptr cdouble, onembed: ptr cint,
                         ostride: cint, odist: cint, kind: ptr fftw_r2r_kind,
                         flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_many_r2r", dynlib: Fftw3Lib.}

# FFTW Utility & Cleanup API
proc fftw_destroy_plan*(p: fftw_plan) {.cdecl, importc: "fftw_destroy_plan", dynlib: Fftw3Lib.}
  ## Destroy a plan

proc fftw_cleanup*() {.cdecl, importc: "fftw_cleanup", dynlib: Fftw3Lib.}
  ## All existing plans become undefined, and you should not attempt to execute them nor to destroy them. You can however create and execute/destroy new plans, in which case FFTW starts accumulating wisdom information again.

proc fftw_set_timelimit*(t: cdouble) {.cdecl, importc: "fftw_set_timelimit", dynlib: Fftw3Lib.}


