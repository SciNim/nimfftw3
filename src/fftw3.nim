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

##  C-Binding low-level example

##  .. code-block:: nim
##      const N = 3
##      var input : array[1..N, cdouble] = [0.0, 2.0, 6.0]
##      var output : array[1..N, cdouble]
##
##      let plan = fftw_plan_r2r_1d(N, addr(input[low(input)]), addr(output[low(output)]),
##                                  FFTW_REDFT00, FFTW_ESTIMATE)
##
##      input = [0.0, 2.0, 6.0]
##      fftw_execute(plan)
##
##      let expectedResult : array[1..N, cdouble] = [10.0, -6.0, 2.0]
##      for i in low(output)..high(output):
##          assert abs(output[i] - expectedResult[i]) < 1.0e-14


##  Arraymancer API example

## .. code-block:: nim
##   var input  : Tensor[Complex64] = # Insert data in your input Tensor...
##   # Allocate output Tensor
##   var output = newTensor[Complex64](input.shape.toSeq)
##   # Create a plan
##   var plan : fftw_plan = fftw_plan_dft(input, output, FFTW_FORWARD, FFTW_ESTIMATE)
##   # Execute plan in-place
##   fftw_execute(plan)

## Arraymancer non-official API for ease of use

import arraymancer
import sequtils
import complex
import arraymancer/../tensor/private/p_accessors


when defined(windows):
    const LibraryName = "fftw3.dll"
elif defined(macosx):
    const LibraryName = "libfftw3(|.0).dylib"
else:
    const LibraryName = "libfftw3.so"

type
  fftw_r2r_kind* = enum
    FFTW_R2HC = 0, FFTW_HC2R = 1, FFTW_DHT = 2, FFTW_REDFT00 = 3,
    FFTW_REDFT01 = 4, FFTW_REDFT10 = 5, FFTW_REDFT11 = 6, FFTW_RODFT00 = 7,
    FFTW_RODFT01 = 8, FFTW_RODFT10 = 9, FFTW_RODFT11 = 10

const
    FFTW_MEASURE* = 0
    FFTW_DESTROY_INPUT* = 1
    FFTW_UNALIGNED* = 1 shl 1
    FFTW_CONSERVE_MEMORY* = 1 shl 2
    FFTW_EXHAUSTIVE* = 1 shl 3
    FFTW_PRESERVE_INPUT* = 1 shl 4
    FFTW_PATIENT* = 1 shl 5
    FFTW_ESTIMATE* = 1 shl 6
    FFTW_WISDOM_ONLY* = 1 shl 21

const
  FFTW_FORWARD*  = -1
  FFTW_BACKWARD* = 1


type
  fftw_iodim* {. pure .} = object
    n*: cint
    `is`*: cint
    os*: cint

  ptrdiff_t* = clong
  wchar_t* = cint
  fftw_iodim64* {. pure .} = object
    n*: ptrdiff_t
    `is`*: ptrdiff_t
    os*: ptrdiff_t

  fftw_write_char_func* = proc (c: char; a3: pointer) {.cdecl.}
  fftw_read_char_func* = proc (a2: pointer): cint {.cdecl.}
  fftw_complex* = Complex64
  fftw_plan* = pointer

## FFT Shift
## Because FFT-Shift is used in many FFT based Algorithm
proc circshift_impl[T](t: Tensor[T], xshift: int, yshift: int, zshift: int): Tensor[T]=
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

proc circshift_impl[T](t: Tensor[T], xshift: int, yshift: int): Tensor[T]=
  assert(t.rank == 2)
  var X = t.shape[0]
  var Y = t.shape[1]

  result = newTensor[T](t.shape.toSeq)
  for i in 0||(X-1):
    var ii = (i + xshift) mod X
    for j in 0||(Y-1):
      var jj = (j + yshift) mod Y
      result[ii, jj] = t[i, j]

proc circshift_impl[T](t: Tensor[T], xshift: int): Tensor[T]=
  assert(t.rank == 1)
  var X = t.shape[0]

  result = newTensor[T](t.shape.toSeq)
  for i in 0||(X-1):
    var ii = (i + xshift) mod X
    result[ii] = t[i]

# TODO : Generic implementation in parallel
proc circshift_impl[T](t: Tensor[T], shift: seq[int]): Tensor[T]=
  let shape = t.shape.toSeq
  result = newTensor[T](t.shape.toSeq)
  for coord, values in t:
    var newcoord : seq[int] = newSeq[int](t.rank)
    for i in 0..<t.rank:
      newcoord[i] = (coord[i]+shift[i]) mod shape[i]
    result.atIndexMut(newcoord, values)

proc circshift*[T](t: Tensor[T], shift: seq[int]): Tensor[T]=
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

proc fftshift*[T](t: Tensor[T]): Tensor[T]=
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

proc ifftshift*[T](t: Tensor[T]): Tensor[T]=
  runnableExamples:
    import arraymancer
    let input_tensor = randomTensor[float64](10, 10, 10, 10.0)
    # output_tensor is the fftshift of input_tensor
    var output_tensor = ifftshift(input_tensor)

  ## Calculate inverse fftshift using circshift
  let xshift = (t.shape[0]+1) div 2
  let yshift = (t.shape[1]+1) div 2
  let zshift = (t.shape[2]+1) div 2
  result = circshift(t, @[xshift.int, yshift.int, zshift.int])

## FFTW Execute API

proc fftw_execute*(p: fftw_plan) {.cdecl, importc: "fftw_execute",
                                   dynlib: LibraryName.}

proc fftw_execute_dft*(p: fftw_plan; `in`: ptr fftw_complex;
                       `out`: ptr fftw_complex) {.cdecl,
    importc: "fftw_execute_dft", dynlib: LibraryName.}

proc fftw_execute_dft*(p: fftw_plan, input: Tensor[fftw_complex], output: Tensor[fftw_complex])=
  runnableExamples:
    import arraymancer
    import fftw3

    let shape = @[100, 100]
    # Create dummy tensors
    var
      dummy_input = newTensor[Complex64](shape)
      dummy_output = newTensor[Complex64](shape)
    # Use dummy tensor to create plan
    var plan : fftw_plan = fftw_plan_dft(dummy_input, dummy_output, FFTW_FORWARD, FFTW_ESTIMATE)

    # Allocate output Tensor
    # It is crucial to NOT modify the dimensions of the tensor
    var inputRe: Tensor[float64] = randomTensor[float64](shape, 10.0)
    var inputIm: Tensor[float64] = randomTensor[float64](shape, 20.0)

    var input = map2_inline(inputRe, inputIm):
      complex64(x, y)

    let in_shape = @(input.shape)
    var output = newTensor[Complex64](in_shape)

    # Execute plan with output_tensor and input_tensor
    fftw_execute_dft(plan, input, output)  ## Execute a plan on new Tensor

  fftw_execute_dft(p, input.get_data_ptr, output.get_data_ptr)

proc fftw_execute_r2r*(p: fftw_plan; `in`: ptr cdouble; `out`: ptr cdouble) {.
    cdecl, importc: "fftw_execute_r2r", dynlib: LibraryName.}


proc fftw_execute_dft_r2c*(p: fftw_plan; `in`: ptr cdouble;
                           `out`: ptr fftw_complex) {.cdecl,
    importc: "fftw_execute_dft_r2c", dynlib: LibraryName.}

proc fftw_execute_dft_r2c*(p: fftw_plan, input: Tensor[float64], output: Tensor[fftw_complex])=
  ## Execute a real-to-complex plan on new Tensor
  fftw_execute_dft_r2c(p, cast[ptr cdouble](input.get_data_ptr), output.get_data_ptr)


proc fftw_execute_dft_c2r*(p: fftw_plan; `in`: ptr fftw_complex;
                           `out`: ptr cdouble) {.cdecl,
    importc: "fftw_execute_dft_c2r", dynlib: LibraryName.}

proc fftw_execute_dft_c2r*(p: fftw_plan, input: Tensor[fftw_complex],   output: Tensor[float64])=
  ## Execute a complex-to-real plan on new Tensor
  fftw_execute_dft_c2r(p, input.get_data_ptr, cast[ptr cdouble](output.get_data_ptr))


proc fftw_execute_split_dft*(p: fftw_plan; ri: ptr cdouble; ii: ptr cdouble;
                             ro: ptr cdouble; io: ptr cdouble) {.cdecl,
    importc: "fftw_execute_split_dft", dynlib: LibraryName.}

proc fftw_execute_split_dft_r2c*(p: fftw_plan; `in`: ptr cdouble;
                                 ro: ptr cdouble; io: ptr cdouble) {.cdecl,
    importc: "fftw_execute_split_dft_r2c", dynlib: LibraryName.}

proc fftw_execute_split_dft_c2r*(p: fftw_plan; ri: ptr cdouble; ii: ptr cdouble;
                                 `out`: ptr cdouble) {.cdecl,
    importc: "fftw_execute_split_dft_c2r", dynlib: LibraryName.}


## FFTW Plan API

proc fftw_plan_dft*(rank: cint; n: ptr cint; `in`: ptr fftw_complex;
                    `out`: ptr fftw_complex; sign: cint; flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_dft", dynlib: LibraryName.}

proc fftw_plan_dft*(input: Tensor[fftw_complex], output: Tensor[fftw_complex], sign: cint, flags: cuint = FFTW_MEASURE): fftw_plan=
  ## Generic Tensor plan calculation using FFTW_MEASURE as a default fftw flag.
  ## Read carefully FFTW documentation about the input / output dimension it will change depending on the transformation.
  let shape : seq[cint] = map(input.shape.toSeq, proc(x: int): cint= x.cint)
  result = fftw_plan_dft(input.rank.cint, (shape[0].unsafeaddr), input.get_data_ptr, output.get_data_ptr,sign, flags)


proc fftw_plan_dft_1d*(n: cint; `in`: ptr fftw_complex; `out`: ptr fftw_complex;
                       sign: cint; flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_dft_1d", dynlib: LibraryName.}

proc fftw_plan_dft_1d*(input: Tensor[fftw_complex], output: Tensor[fftw_complex], sign: cint, flags: cuint = FFTW_MEASURE): fftw_plan=
  ## 1D Tensor plan calculation using FFTW_MEASURE as a default fftw flag.
  assert(input.rank == 1)
  let shape : seq[cint] = map(input.shape.toSeq, proc(x: int): cint= x.cint)
  result = fftw_plan_dft_1d(shape[0], input.get_data_ptr, output.get_data_ptr,sign, flags)


proc fftw_plan_dft_2d*(n0: cint; n1: cint; `in`: ptr fftw_complex;
                       `out`: ptr fftw_complex; sign: cint; flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_dft_2d", dynlib: LibraryName.}

proc fftw_plan_dft_2d*(input: Tensor[fftw_complex], output: Tensor[fftw_complex], sign: cint, flags: cuint = FFTW_MEASURE): fftw_plan=
  ## 2D Tensor plan calculation using FFTW_MEASURE as a default fftw flag.
  assert(input.rank == 2)
  let shape : seq[cint] = map(input.shape.toSeq, proc(x: int): cint= x.cint)
  result = fftw_plan_dft_2d(shape[0], shape[1], input.get_data_ptr, output.get_data_ptr,sign, flags)

proc fftw_plan_dft_3d*(n0: cint; n1: cint; n2: cint; `in`: ptr fftw_complex;
                       `out`: ptr fftw_complex; sign: cint; flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_dft_3d", dynlib: LibraryName.}

proc fftw_plan_dft_3d*(input: Tensor[fftw_complex], output: Tensor[fftw_complex], sign: cint, flags: cuint = FFTW_MEASURE): fftw_plan=
  ## 3D Tensor plan calculation using FFTW_MEASURE as a default fftw flag.
  assert(input.rank == 3)
  let shape : seq[cint] = map(input.shape.toSeq, proc(x: int): cint= x.cint)
  result = fftw_plan_dft_3d(shape[0], shape[1], shape[2], input.get_data_ptr, output.get_data_ptr,sign, flags)


proc fftw_plan_dft_r2c*(rank: cint; n: ptr cint; `in`: ptr cdouble;
                        `out`: ptr fftw_complex; flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_dft_r2c", dynlib: LibraryName.}

proc fftw_plan_dft_r2c*(input: Tensor[float64], output: Tensor[fftw_complex], flags: cuint = FFTW_MEASURE): fftw_plan=
  ## Generic Real-to-Complex Tensor plan calculation using FFTW_MEASURE as a default fftw flag.
  ## Read carefully FFTW documentation about the input / output dimension as FFTW does not calculate redundant conjugate value.
  let shape : seq[cint] = map(input.shape.toSeq, proc(x: int): cint= x.cint)
  result = fftw_plan_dft_r2c(input.rank.cint, (shape[0].unsafeaddr), cast[ptr cdouble](input.get_data_ptr), output.get_data_ptr, flags)

proc fftw_plan_dft_r2c_1d*(n: cint; `in`: ptr cdouble; `out`: ptr fftw_complex;
                           flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_dft_r2c_1d", dynlib: LibraryName.}

proc fftw_plan_dft_r2c_1d*(input: Tensor[float64], output: Tensor[fftw_complex], flags: cuint = FFTW_MEASURE): fftw_plan=
  ## 1D Real-to-Complex Tensor plan calculation using FFTW_MEASURE as a default fftw flag.
  assert(input.rank == 1)
  let shape : seq[cint] = map(input.shape.toSeq, proc(x: int): cint= x.cint)
  result = fftw_plan_dft_r2c_1d(shape[0], cast[ptr cdouble](input.get_data_ptr), output.get_data_ptr, flags)


proc fftw_plan_dft_r2c_2d*(n0: cint; n1: cint; `in`: ptr cdouble;
                           `out`: ptr fftw_complex; flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_dft_r2c_2d", dynlib: LibraryName.}

proc fftw_plan_dft_r2c_2d*(input: Tensor[float64], output: Tensor[fftw_complex], flags: cuint = FFTW_MEASURE): fftw_plan=
  ## 2D Real-to-Complex Tensor plan calculation using FFTW_MEASURE as a default fftw flag.
  assert(input.rank == 2)
  let shape : seq[cint] = map(input.shape.toSeq, proc(x: int): cint= x.cint)
  result = fftw_plan_dft_r2c_2d(shape[0], shape[1], cast[ptr cdouble](input.get_data_ptr), output.get_data_ptr, flags)


proc fftw_plan_dft_r2c_3d*(n0: cint; n1: cint; n2: cint; `in`: ptr cdouble;
                           `out`: ptr fftw_complex; flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_dft_r2c_3d", dynlib: LibraryName.}

proc fftw_plan_dft_r2c_3d*(input: Tensor[float64], output: Tensor[fftw_complex], flags: cuint = FFTW_MEASURE): fftw_plan=
  ## 3D Real-to-Complex Tensor plan calculation using FFTW_MEASURE as a default fftw flag.
  assert(input.rank == 3)
  let shape : seq[cint] = map(input.shape.toSeq, proc(x: int): cint= x.cint)
  result = fftw_plan_dft_r2c_3d(shape[0], shape[1], shape[2], cast[ptr cdouble](input.get_data_ptr), output.get_data_ptr, flags)


proc fftw_plan_dft_c2r*(rank: cint; n: ptr cint; `in`: ptr fftw_complex;
                        `out`: ptr cdouble; flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_dft_c2r", dynlib: LibraryName.}

proc fftw_plan_dft_c2r*(input: Tensor[fftw_complex], output: Tensor[float64], flags: cuint = FFTW_MEASURE): fftw_plan=
  ## Generic Complex-to-real Tensor plan calculation using FFTW_MEASURE as a default fftw flag.
  let shape : seq[cint] = map(input.shape.toSeq, proc(x: int): cint= x.cint)
  result = fftw_plan_dft_c2r(input.rank.cint, (shape[0].unsafeaddr), input.get_data_ptr, cast[ptr cdouble](output.get_data_ptr), flags)


proc fftw_plan_dft_c2r_1d*(n: cint; `in`: ptr fftw_complex; `out`: ptr cdouble;
                           flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_dft_c2r_1d", dynlib: LibraryName.}

proc fftw_plan_dft_c2r_1d*(input: Tensor[fftw_complex], output: Tensor[float64], flags: cuint = FFTW_MEASURE): fftw_plan=
  ## 1D Complex-to-real Tensor plan calculation using FFTW_MEASURE as a default fftw flag.
  assert(input.rank == 1)
  let shape : seq[cint] = map(input.shape.toSeq, proc(x: int): cint= x.cint)
  result = fftw_plan_dft_c2r_1d(shape[0], input.get_data_ptr, cast[ptr cdouble](output.get_data_ptr), flags)


proc fftw_plan_dft_c2r_2d*(n0: cint; n1: cint; `in`: ptr fftw_complex;
                           `out`: ptr cdouble; flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_dft_c2r_2d", dynlib: LibraryName.}

proc fftw_plan_dft_c2r_2d*(input: Tensor[fftw_complex], output: Tensor[float64], flags: cuint = FFTW_MEASURE): fftw_plan=
  ## 2D Complex-to-real Tensor plan calculation using FFTW_MEASURE as a default fftw flag.
  assert(input.rank == 2)
  let shape : seq[cint] = map(input.shape.toSeq, proc(x: int): cint= x.cint)
  result = fftw_plan_dft_c2r_2d(shape[0], shape[1], input.get_data_ptr, cast[ptr cdouble](output.get_data_ptr), flags)

proc fftw_plan_dft_c2r_3d*(n0: cint; n1: cint; n2: cint; `in`: ptr fftw_complex;
                           `out`: ptr cdouble; flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_dft_c2r_3d", dynlib: LibraryName.}

proc fftw_plan_dft_c2r_3d*(input: Tensor[fftw_complex], output: Tensor[float64], flags: cuint = FFTW_MEASURE): fftw_plan=
  ## 3D Complex-to-real Tensor plan calculation using FFTW_MEASURE as a default fftw flag.
  assert(input.rank == 3)
  let shape : seq[cint] = map(input.shape.toSeq, proc(x: int): cint= x.cint)
  result = fftw_plan_dft_c2r_3d(shape[0], shape[1], shape[2], input.get_data_ptr, cast[ptr cdouble](output.get_data_ptr), flags)



proc fftw_plan_r2r*(rank: cint; n: ptr cint; `in`: ptr cdouble;
                    `out`: ptr cdouble; kind: ptr fftw_r2r_kind; flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_r2r", dynlib: LibraryName.}

proc fftw_plan_r2r*(input: Tensor[float64], output: Tensor[float64], kinds: seq[fftw_r2r_kind], flags: cuint = FFTW_MEASURE): fftw_plan=
  ## Generic real-to-real Tensor plan calculation using FFTW_MEASURE as a default fftw flag.
  let shape : seq[cint] = map(input.shape.toSeq, proc(x: int): cint= x.cint)
  result = fftw_plan_r2r(input.rank.cint, shape[0].unsafeaddr, cast[ptr cdouble](input.get_data_ptr), cast[ptr cdouble](output.get_data_ptr), kinds[0].unsafeaddr, flags)


proc fftw_plan_r2r_1d*(n: cint; `in`: ptr cdouble; `out`: ptr cdouble;
                       kind: fftw_r2r_kind; flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_r2r_1d", dynlib: LibraryName.}

proc fftw_plan_r2r_1d*(input: Tensor[float64], output: Tensor[float64], kind: fftw_r2r_kind, flags: cuint = FFTW_MEASURE): fftw_plan=
  ## 1D real-to-real Tensor plan calculation using FFTW_MEASURE as a default fftw flag.
  assert(input.rank == 1)
  let shape : seq[cint] = map(input.shape.toSeq, proc(x: int): cint= x.cint)
  result = fftw_plan_r2r_1d(shape[0], cast[ptr cdouble](input.get_data_ptr), cast[ptr cdouble](output.get_data_ptr), kind, flags)


proc fftw_plan_r2r_2d*(n0: cint; n1: cint; `in`: ptr cdouble;
                       `out`: ptr cdouble; kind0: fftw_r2r_kind;
                       kind1: fftw_r2r_kind; flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_r2r_2d", dynlib: LibraryName.}

proc fftw_plan_r2r_2d*(input: Tensor[float64], output: Tensor[float64], kinds: seq[fftw_r2r_kind], flags: cuint = FFTW_MEASURE): fftw_plan=
  ## 2D real-to-real Tensor plan calculation using FFTW_MEASURE as a default fftw flag.
  assert(input.rank == 2)
  let shape : seq[cint] = map(input.shape.toSeq, proc(x: int): cint= x.cint)
  result = fftw_plan_r2r_2d(shape[0], shape[1], cast[ptr cdouble](input.get_data_ptr), cast[ptr cdouble](output.get_data_ptr), kinds[0], kinds[1], flags)


proc fftw_plan_r2r_3d*(n0: cint; n1: cint; n2: cint; `in`: ptr cdouble;
                       `out`: ptr cdouble; kind0: fftw_r2r_kind;
                       kind1: fftw_r2r_kind; kind2: fftw_r2r_kind; flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_r2r_3d", dynlib: LibraryName.}

proc fftw_plan_r2r_3d*(input: Tensor[float64], output: Tensor[float64], kinds: seq[fftw_r2r_kind], flags: cuint = FFTW_MEASURE): fftw_plan=
  ## 3D real-to-real Tensor plan calculation using FFTW_MEASURE as a default fftw flag.
  assert(input.rank == 3)
  let shape : seq[cint] = map(input.shape.toSeq, proc(x: int): cint= x.cint)
  result = fftw_plan_r2r_3d(shape[0], shape[1], shape[2], cast[ptr cdouble](input.get_data_ptr), cast[ptr cdouble](output.get_data_ptr), kinds[0], kinds[1], kinds[2], flags)

## FFTW Plan Many API

proc fftw_plan_many_dft*(rank: cint; n: ptr cint; howmany: cint;
                         `in`: ptr fftw_complex; inembed: ptr cint;
                         istride: cint; idist: cint; `out`: ptr fftw_complex;
                         onembed: ptr cint; ostride: cint; odist: cint;
                         sign: cint; flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_many_dft", dynlib: LibraryName.}



proc fftw_plan_many_dft_c2r*(rank: cint; n: ptr cint; howmany: cint;
                             `in`: ptr fftw_complex; inembed: ptr cint;
                             istride: cint; idist: cint; `out`: ptr cdouble;
                             onembed: ptr cint; ostride: cint; odist: cint;
                             flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_many_dft_c2r", dynlib: LibraryName.}

proc fftw_plan_many_dft_r2c*(rank: cint; n: ptr cint; howmany: cint;
                             `in`: ptr cdouble; inembed: ptr cint;
                             istride: cint; idist: cint;
                             `out`: ptr fftw_complex; onembed: ptr cint;
                             ostride: cint; odist: cint; flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_many_dft_r2c", dynlib: LibraryName.}

proc fftw_plan_many_r2r*(rank: cint; n: ptr cint; howmany: cint;
                         `in`: ptr cdouble; inembed: ptr cint; istride: cint;
                         idist: cint; `out`: ptr cdouble; onembed: ptr cint;
                         ostride: cint; odist: cint; kind: ptr fftw_r2r_kind;
                         flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_many_r2r", dynlib: LibraryName.}



## FFTW "Guru" API
## This is the "I know what I'm doing and want to optimize every last bits of performance" API of FFTW

proc fftw_plan_guru_dft*(rank: cint; dims: ptr fftw_iodim; howmany_rank: cint;
                         howmany_dims: ptr fftw_iodim; `in`: ptr fftw_complex;
                         `out`: ptr fftw_complex; sign: cint; flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_guru_dft", dynlib: LibraryName.}
proc fftw_plan_guru_split_dft*(rank: cint; dims: ptr fftw_iodim;
                               howmany_rank: cint; howmany_dims: ptr fftw_iodim;
                               ri: ptr cdouble; ii: ptr cdouble;
                               ro: ptr cdouble; io: ptr cdouble; flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_guru_split_dft", dynlib: LibraryName.}
proc fftw_plan_guru64_dft*(rank: cint; dims: ptr fftw_iodim64;
                           howmany_rank: cint; howmany_dims: ptr fftw_iodim64;
                           `in`: ptr fftw_complex; `out`: ptr fftw_complex;
                           sign: cint; flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_guru64_dft", dynlib: LibraryName.}
proc fftw_plan_guru64_split_dft*(rank: cint; dims: ptr fftw_iodim64;
                                 howmany_rank: cint;
                                 howmany_dims: ptr fftw_iodim64;
                                 ri: ptr cdouble; ii: ptr cdouble;
                                 ro: ptr cdouble; io: ptr cdouble; flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_guru64_split_dft", dynlib: LibraryName.}

proc fftw_plan_guru_dft_r2c*(rank: cint; dims: ptr fftw_iodim;
                             howmany_rank: cint; howmany_dims: ptr fftw_iodim;
                             `in`: ptr cdouble; `out`: ptr fftw_complex;
                             flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_guru_dft_r2c", dynlib: LibraryName.}
proc fftw_plan_guru_dft_c2r*(rank: cint; dims: ptr fftw_iodim;
                             howmany_rank: cint; howmany_dims: ptr fftw_iodim;
                             `in`: ptr fftw_complex; `out`: ptr cdouble;
                             flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_guru_dft_c2r", dynlib: LibraryName.}
proc fftw_plan_guru_split_dft_r2c*(rank: cint; dims: ptr fftw_iodim;
                                   howmany_rank: cint;
                                   howmany_dims: ptr fftw_iodim;
                                   `in`: ptr cdouble; ro: ptr cdouble;
                                   io: ptr cdouble; flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_guru_split_dft_r2c", dynlib: LibraryName.}
proc fftw_plan_guru_split_dft_c2r*(rank: cint; dims: ptr fftw_iodim;
                                   howmany_rank: cint;
                                   howmany_dims: ptr fftw_iodim;
                                   ri: ptr cdouble; ii: ptr cdouble;
                                   `out`: ptr cdouble; flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_guru_split_dft_c2r", dynlib: LibraryName.}
proc fftw_plan_guru64_dft_r2c*(rank: cint; dims: ptr fftw_iodim64;
                               howmany_rank: cint;
                               howmany_dims: ptr fftw_iodim64;
                               `in`: ptr cdouble; `out`: ptr fftw_complex;
                               flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_guru64_dft_r2c", dynlib: LibraryName.}
proc fftw_plan_guru64_dft_c2r*(rank: cint; dims: ptr fftw_iodim64;
                               howmany_rank: cint;
                               howmany_dims: ptr fftw_iodim64;
                               `in`: ptr fftw_complex; `out`: ptr cdouble;
                               flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_guru64_dft_c2r", dynlib: LibraryName.}
proc fftw_plan_guru64_split_dft_r2c*(rank: cint; dims: ptr fftw_iodim64;
                                     howmany_rank: cint;
                                     howmany_dims: ptr fftw_iodim64;
                                     `in`: ptr cdouble; ro: ptr cdouble;
                                     io: ptr cdouble; flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_guru64_split_dft_r2c", dynlib: LibraryName.}
proc fftw_plan_guru64_split_dft_c2r*(rank: cint; dims: ptr fftw_iodim64;
                                     howmany_rank: cint;
                                     howmany_dims: ptr fftw_iodim64;
                                     ri: ptr cdouble; ii: ptr cdouble;
                                     `out`: ptr cdouble; flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_guru64_split_dft_c2r", dynlib: LibraryName.}

proc fftw_plan_guru_r2r*(rank: cint; dims: ptr fftw_iodim; howmany_rank: cint;
                         howmany_dims: ptr fftw_iodim; `in`: ptr cdouble;
                         `out`: ptr cdouble; kind: ptr fftw_r2r_kind;
                         flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_guru_r2r", dynlib: LibraryName.}
proc fftw_plan_guru64_r2r*(rank: cint; dims: ptr fftw_iodim64;
                           howmany_rank: cint; howmany_dims: ptr fftw_iodim64;
                           `in`: ptr cdouble; `out`: ptr cdouble;
                           kind: ptr fftw_r2r_kind; flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_guru64_r2r", dynlib: LibraryName.}

## FFTW Utility & Cleanup API

proc fftw_destroy_plan*(p: fftw_plan) {.cdecl, importc: "fftw_destroy_plan",
                                        dynlib: LibraryName.}
proc fftw_forget_wisdom*() {.cdecl, importc: "fftw_forget_wisdom",
                             dynlib: LibraryName.}
proc fftw_cleanup*() {.cdecl, importc: "fftw_cleanup", dynlib: LibraryName.}
proc fftw_set_timelimit*(t: cdouble) {.cdecl, importc: "fftw_set_timelimit",
                                       dynlib: LibraryName.}
proc fftw_export_wisdom_to_filename*(filename: cstring): cint {.cdecl,
    importc: "fftw_export_wisdom_to_filename", dynlib: LibraryName.}
proc fftw_export_wisdom_to_file*(output_file: ptr FILE) {.cdecl,
    importc: "fftw_export_wisdom_to_file", dynlib: LibraryName.}
proc fftw_export_wisdom_to_string*(): cstring {.cdecl,
    importc: "fftw_export_wisdom_to_string", dynlib: LibraryName.}
proc fftw_export_wisdom*(write_char: fftw_write_char_func; data: pointer) {.
    cdecl, importc: "fftw_export_wisdom", dynlib: LibraryName.}
proc fftw_import_system_wisdom*(): cint {.cdecl,
    importc: "fftw_import_system_wisdom", dynlib: LibraryName.}
proc fftw_import_wisdom_from_filename*(filename: cstring): cint {.cdecl,
    importc: "fftw_import_wisdom_from_filename", dynlib: LibraryName.}
proc fftw_import_wisdom_from_file*(input_file: ptr FILE): cint {.cdecl,
    importc: "fftw_import_wisdom_from_file", dynlib: LibraryName.}
proc fftw_import_wisdom_from_string*(input_string: cstring): cint {.cdecl,
    importc: "fftw_import_wisdom_from_string", dynlib: LibraryName.}
proc fftw_import_wisdom*(read_char: fftw_read_char_func; data: pointer): cint {.
    cdecl, importc: "fftw_import_wisdom", dynlib: LibraryName.}
proc fftw_fprint_plan*(p: fftw_plan; output_file: ptr FILE) {.cdecl,
    importc: "fftw_fprint_plan", dynlib: LibraryName.}
proc fftw_print_plan*(p: fftw_plan) {.cdecl, importc: "fftw_print_plan",
                                      dynlib: LibraryName.}
proc fftw_sprint_plan*(p: fftw_plan): cstring {.cdecl,
    importc: "fftw_sprint_plan", dynlib: LibraryName.}
proc fftw_malloc*(n: csize): pointer {.cdecl, importc: "fftw_malloc",
                                       dynlib: LibraryName.}
proc fftw_alloc_real*(n: csize): ptr cdouble {.cdecl,
    importc: "fftw_alloc_real", dynlib: LibraryName.}
proc fftw_alloc_complex*(n: csize): ptr fftw_complex {.cdecl,
    importc: "fftw_alloc_complex", dynlib: LibraryName.}
proc fftw_free*(p: pointer) {.cdecl, importc: "fftw_free", dynlib: LibraryName.}
proc fftw_flops*(p: fftw_plan; add: ptr cdouble; mul: ptr cdouble;
                 fmas: ptr cdouble) {.cdecl, importc: "fftw_flops",
                                      dynlib: LibraryName.}
proc fftw_estimate_cost*(p: fftw_plan): cdouble {.cdecl,
    importc: "fftw_estimate_cost", dynlib: LibraryName.}
proc fftw_cost*(p: fftw_plan): cdouble {.cdecl, importc: "fftw_cost",
    dynlib: LibraryName.}
proc fftw_alignment_of*(p: ptr cdouble): cint {.cdecl,
    importc: "fftw_alignment_of", dynlib: LibraryName.}
var fftw_version* {.importc: "fftw_version", dynlib: LibraryName.}: ptr char

var fftw_cc* {.importc: "fftw_cc", dynlib: LibraryName.}: ptr char

var fftw_codelet_optim* {.importc: "fftw_codelet_optim", dynlib: LibraryName.}: ptr char
