### Introduction

## Nim binding for the FFTW3 library
##
## FFTW is one the best library to compute Fourier transforms of various kinds with high performance.
##
## Make sure FFTW's documentation : http://www.ffwf.org/ffwf3_doc/
##
## The C-bindings can be used identically to the C-API
##
## In order to simplify usage an Arraymancer high level API is added on top of the low-level API.
##

### Examples

####  C-Binding low-level example
runnableExamples:
  import ffwf3
  const N = 3
  var input: array[N, cfloat] = [0.0, 2.0, 6.0]
  var output: array[N, cfloat]
  let bufIn = cast[ptr UncheckedArray[cfloat]](addr(input[0]))
  let bufOut = cast[ptr UncheckedArray[cfloat]](addr(output[0]))
  let plan = fftwf_plan_r2r_1d(N, bufIn, bufOut, fftwf_r2r_kind.FFTW_REDFT00, FFTW_ESTIMATE)
  fftwf_execute(plan)
  let expectedResult: array[N, cfloat] = [10.0, -6.0, 2.0]
  for i in low(output)..high(output):
    assert abs(output[i] - expectedResult[i]) < 1.0e-14

####  Arraymancer API example
runnableExamples:
  import arraymancer
  import ffwf3
  import sequtils

  var
    input  : Tensor[Complex32] = newTensor[Complex32](@[10, 10, 10])
    reInput = randomTensor[float32](10, 10, 100.0)
    imInput = randomTensor[float32](10, 10, 100.0)

  for i, x in input.menumerate:
    x.re = reInput.atContiguousIndex(i)
    x.im = imInput.atContiguousIndex(i)

  # Allocate output Tensor
  var output = newTensor[Complex32](input.shape.toSeq)
  # Create a plan
  var plan : fftwf_plan = fftwf_plan_dft(input, output, FFTW_FORWARD, FFTW_ESTIMATE)
  # Execute plan in-place
  fftwf_execute(plan)

### Planner flags

## Planner are const integer that specify how the DFT plan should be computed.
## More information about `planner flags <http://www.ffwf.org/doc/Planner-Flags.html>`_

import arraymancer
import sequtils
import complex
import fftw3f/libutils
# Import mostly for documentation links
{.push warning[UnusedImport]: off.}
import fftw3f/guru, fftw3f/wisdom
{.pop.}
import fftw3f/fftshift
# export used types
export fftwf_plan
export fftwf_r2r_kind
export fftshift

const
    FFTW_MEASURE* = 0              ## ``fftwf_plan`` planner flag.
                                   ##
                      ## Find an optimized plan by computing several FFTs and measuring their execution time. Default planning option.
    FFTW_ESTIMATE* = 1 shl 6       ## ``fftwf_plan`` planner flag.
                                   ##
                             ## Instead of time measurements, a simple heuristic is used to pick a plan quickly. The input/output arrays are not overwritten during planning.
    FFTW_PATIENT* = 1 shl 5        ## ``fftwf_plan`` planner flag.
                                   ##
                                   ## Like FFTW_MEASURE, but considers a wider range of algorithms.
    FFTW_EXHAUSTIVE* = 1 shl 3     ## ``fftwf_plan`` planner flag.
                                   ##
                                   ## Like FFTW_PATIENT, but considers an even wider range of algorithms.
    FFTW_WISDOM_ONLY* = 1 shl 21   ## ``fftwf_plan`` planner flag.
                                   ##
                                   ## Special planning mode in which the plan is created only if wisdow is available.

    FFTW_DESTROY_INPUT* = 1        ## ``fftwf_plan`` planner flag.
                                   ##
                            ## An out-of-place transform is allowed to overwrite its input array with arbitrary data. Default value for complex-to-real transform.
    FFTW_PRESERVE_INPUT* = 1 shl 4 ## ``fftwf_plan`` planner flag.
                                   ##
                                   ## An out-of-place transform must not change its input array. Default value except for complex-to-real (c2r and hc2r).
    FFTW_UNALIGNED* = 1 shl 1      ## ``fftwf_plan`` planner flag.
                                   ##
                              ## The algorithm may not impose any unusual alignment requirements on the input/output arrays.(i.e. no SIMD may be used).
    FFTW_CONSERVE_MEMORY* = 1 shl 2

const
    FFTW_FORWARD* = -1 ## ``fftwf_plan`` sign flag.
                       ##
                       ## Compute a DFT transform.
    FFTW_BACKWARD* = 1 ## ``fftwf_plan`` sign flag.
                       ##
                       ## Compute an inverse DFT transform.

# FFTW Execute API
proc fftwf_execute*(p: fftwf_plan) {.cdecl, importc: "fftwf_execute", dynlib: Fftw3Lib.}
  ## Execute a plan

proc fftwf_execute_dft*(p: fftwf_plan, inptr: ptr UncheckedArray[Complex32], outptr: ptr UncheckedArray[Complex32]) {.
        cdecl, importc: "fftwf_execute_dft", dynlib: Fftw3Lib.}
  ## Execute a plan with different input / output memory address

proc fftwf_execute_dft*(p: fftwf_plan, input: Tensor[Complex32], output: Tensor[Complex32]) =
    ## Execute an fft using a pre-calculated ``fftwf_plan``
    runnableExamples:
        import arraymancer
        import ffwf3
        let shape = @[100, 100]
        # Create dummy tensors
        var
            dummy_input = newTensor[Complex32](shape)
            dummy_output = newTensor[Complex32](shape)
        # Use dummy tensor to create plan
        var plan: fftwf_plan = fftwf_plan_dft(dummy_input, dummy_output, FFTW_FORWARD, FFTW_ESTIMATE)
        # Allocate output Tensor
        # It is crucial to NOT modify the dimensions of the tensor
        var inputRe: Tensor[float32] = randomTensor[float32](shape, 10.0)
        var inputIm: Tensor[float32] = randomTensor[float32](shape, 20.0)
        var input = map2_inline(inputRe, inputIm):
            complex64(x, y)
        let in_shape = @(input.shape)
        var output = newTensor[Complex32](in_shape)
        # Execute plan with output_tensor and input_tensor
        fftwf_execute_dft(plan, input, output) ## Execute a plan on new Tensor

    fftwf_execute_dft(p, input.toUnsafeView(), output.toUnsafeView())

proc fftwf_execute_r2r*(p: fftwf_plan, inptr: ptr UncheckedArray[cfloat], outptr: ptr UncheckedArray[cfloat]) {.cdecl,
        importc: "fftwf_execute_r2r", dynlib: Fftw3Lib.}
  ## Execute a plan real-to-real

proc fftwf_execute_dft_r2c*(p: fftwf_plan, inptr: ptr UncheckedArray[cfloat], outptr: ptr UncheckedArray[Complex32]) {.
        cdecl, importc: "fftwf_execute_dft_r2c", dynlib: Fftw3Lib.}
  ## Execute a plan real-to-complex

proc fftwf_execute_dft_r2c*(p: fftwf_plan, input: Tensor[float32], output: Tensor[Complex32]) =
    ## Execute a real-to-complex plan on new Tensor
    fftwf_execute_dft_r2c(p, input.asType(cfloat).toUnsafeView(), output.toUnsafeView())

proc fftwf_execute_dft_c2r*(p: fftwf_plan, inptr: ptr UncheckedArray[Complex32], outptr: ptr UncheckedArray[cfloat]) {.
        cdecl, importc: "fftwf_execute_dft_c2r", dynlib: Fftw3Lib.}
  ## Execute a plan complex-to-real

proc fftwf_execute_dft_c2r*(p: fftwf_plan, input: Tensor[Complex32], output: Tensor[float32]) =
    ## Execute a complex-to-real plan on new Tensor
    fftwf_execute_dft_c2r(p, input.toUnsafeView(), cast[ptr UncheckedArray[cfloat]](output.toUnsafeView()))

# FFTW Plan API
proc fftwf_plan_dft*(rank: cint, n: ptr cint, inptr: ptr UncheckedArray[Complex32],
                    outptr: ptr UncheckedArray[Complex32], sign: cint, flags: cuint): fftwf_plan {.
    cdecl, importc: "fftwf_plan_dft", dynlib: Fftw3Lib.}

proc fftwf_plan_dft_1d*(n: cint, inptr: ptr UncheckedArray[Complex32], outptr: ptr UncheckedArray[Complex32], sign: cint,
        flags: cuint): fftwf_plan {.cdecl, importc: "fftwf_plan_dft_1d", dynlib: Fftw3Lib.}

proc fftwf_plan_dft_2d*(n0: cint, n1: cint, inptr: ptr UncheckedArray[Complex32], outptr: ptr UncheckedArray[Complex32],
        sign: cint, flags: cuint): fftwf_plan {.cdecl, importc: "fftwf_plan_dft_2d", dynlib: Fftw3Lib.}

proc fftwf_plan_dft_3d*(n0: cint, n1: cint, n2: cint, inptr: ptr UncheckedArray[Complex32], outptr: ptr UncheckedArray[
        Complex32], sign: cint, flags: cuint): fftwf_plan {.cdecl, importc: "fftwf_plan_dft_3d", dynlib: Fftw3Lib.}

proc fftwf_plan_dft*(input: Tensor[Complex32], output: Tensor[Complex32], sign: cint,
        flags: cuint = FFTW_MEASURE): fftwf_plan =
    ## Generic Tensor plan calculation using FFTW_MEASURE as a default ffwf flag.
    ##
    ## Read carefully FFTW documentation about the input / output dimension it will change depending on the transformation.
    case input.rank:
    of 1:
      fftwf_plan_dft_1d(input.shape[0].cint, input.toUnsafeView(), output.toUnsafeView(), sign, flags)
    of 2:
      fftwf_plan_dft_2d(input.shape[0].cint, input.shape[1].cint, input.toUnsafeView(), output.toUnsafeView(), sign, flags)
    of 3:
      fftwf_plan_dft_3d(input.shape[0].cint, input.shape[1].cint, input.shape[2].cint, input.toUnsafeView(), output.toUnsafeView(), sign, flags)
    else:
      var shape: seq[cint] = map(input.shape.toSeq, proc(x: int): cint = x.cint)
      fftwf_plan_dft(input.rank.cint, (shape[0].unsafeaddr), input.toUnsafeView(), output.toUnsafeView(), sign, flags)


proc fftwf_plan_dft_r2c*(rank: cint, n: ptr cint, inptr: ptr UncheckedArray[cfloat], outptr: ptr UncheckedArray[
        Complex32], flags: cuint): fftwf_plan {.cdecl, importc: "fftwf_plan_dft_r2c", dynlib: Fftw3Lib.}

proc fftwf_plan_dft_r2c_1d*(n: cint, inptr: ptr UncheckedArray[cfloat], outptr: ptr UncheckedArray[Complex32],
        flags: cuint): fftwf_plan {.cdecl, importc: "fftwf_plan_dft_r2c_1d", dynlib: Fftw3Lib.}

proc fftwf_plan_dft_r2c_2d*(n0: cint, n1: cint, inptr: ptr UncheckedArray[cfloat], outptr: ptr UncheckedArray[
        Complex32], flags: cuint): fftwf_plan {.
    cdecl, importc: "fftwf_plan_dft_r2c_2d", dynlib: Fftw3Lib.}

proc fftwf_plan_dft_r2c_3d*(n0: cint, n1: cint, n2: cint, inptr: ptr UncheckedArray[cfloat], outptr: ptr UncheckedArray[
        Complex32], flags: cuint): fftwf_plan {.cdecl, importc: "fftwf_plan_dft_r2c_3d", dynlib: Fftw3Lib.}

proc fftwf_plan_dft_r2c*(input: Tensor[float32], output: Tensor[Complex32], flags: cuint = FFTW_MEASURE): fftwf_plan =
    ## Generic Real-to-Complex Tensor plan calculation using FFTW_MEASURE as a default ffwf flag.
    ##
    ## Read carefully FFTW documentation about the input / output dimension as FFTW does not calculate redundant conjugate value.
    case input.rank:
    of 1:
      fftwf_plan_dft_r2c_1d(input.shape[0].cint, input.toUnsafeView(), output.toUnsafeView(), flags)
    of 2:
      fftwf_plan_dft_r2c_2d(input.shape[0].cint, input.shape[1].cint, input.toUnsafeView(), output.toUnsafeView(), flags)
    of 3:
      fftwf_plan_dft_r2c_3d(input.shape[0].cint, input.shape[1].cint, input.shape[2].cint, input.toUnsafeView(), output.toUnsafeView(), flags)
    else:
      let shape: seq[cint] = map(input.shape.toSeq(), proc(x: int): cint = x.cint)
      fftwf_plan_dft_r2c(input.rank.cint, (shape[0].unsafeaddr), input.toUnsafeView(), output.toUnsafeView(), flags)


proc fftwf_plan_dft_c2r*(rank: cint, n: ptr cint, inptr: ptr UncheckedArray[Complex32], outptr: ptr UncheckedArray[
        cfloat], flags: cuint): fftwf_plan {.cdecl, importc: "fftwf_plan_dft_c2r", dynlib: Fftw3Lib.}

proc fftwf_plan_dft_c2r_1d*(n: cint, inptr: ptr UncheckedArray[Complex32], outptr: ptr UncheckedArray[cfloat],
        flags: cuint): fftwf_plan {.cdecl, importc: "fftwf_plan_dft_c2r_1d", dynlib: Fftw3Lib.}

proc fftwf_plan_dft_c2r_2d*(n0: cint, n1: cint, inptr: ptr UncheckedArray[Complex32], outptr: ptr UncheckedArray[
        cfloat], flags: cuint): fftwf_plan {.cdecl, importc: "fftwf_plan_dft_c2r_2d", dynlib: Fftw3Lib.}

proc fftwf_plan_dft_c2r_3d*(n0: cint, n1: cint, n2: cint, inptr: ptr UncheckedArray[Complex32],
        outptr: ptr UncheckedArray[cfloat], flags: cuint): fftwf_plan {.cdecl, importc: "fftwf_plan_dft_c2r_3d",
        dynlib: Fftw3Lib.}

proc fftwf_plan_dft_c2r*(input: Tensor[Complex32], output: Tensor[float32], flags: cuint = FFTW_MEASURE): fftwf_plan =
    ## Generic Complex-to-real Tensor plan calculation using FFTW_MEASURE as a default ffwf flag.
    case input.rank:
    of 1:
      fftwf_plan_dft_c2r_1d(input.shape[0].cint, input.toUnsafeView(), output.toUnsafeView(), flags)
    of 2:
      fftwf_plan_dft_c2r_2d(input.shape[0].cint, input.shape[1].cint, input.toUnsafeView(), output.toUnsafeView(), flags)
    of 3:
      fftwf_plan_dft_c2r_3d(input.shape[0].cint, input.shape[1].cint, input.shape[2].cint, input.toUnsafeView(), output.toUnsafeView(), flags)
    else:
      let shape: seq[cint] = map(input.shape.toSeq(), proc(x: int): cint = x.cint)
      fftwf_plan_dft_c2r(input.rank.cint, (shape[0].unsafeaddr), input.toUnsafeView(), output.toUnsafeView(), flags)

proc fftwf_plan_r2r*(rank: cint, n: ptr cint, inptr: ptr UncheckedArray[cfloat], outptr: ptr UncheckedArray[cfloat],
        kind: ptr fftwf_r2r_kind, flags: cuint): fftwf_plan {.cdecl, importc: "fftwf_plan_r2r", dynlib: Fftw3Lib.}

proc fftwf_plan_r2r_1d*(n: cint, inptr: ptr UncheckedArray[cfloat], outptr: ptr UncheckedArray[cfloat],
        kind: fftwf_r2r_kind, flags: cuint): fftwf_plan {.cdecl, importc: "fftwf_plan_r2r_1d", dynlib: Fftw3Lib.}

proc fftwf_plan_r2r_2d*(n0: cint, n1: cint, inptr: ptr UncheckedArray[cfloat], outptr: ptr UncheckedArray[cfloat],
        kind0: fftwf_r2r_kind, kind1: fftwf_r2r_kind, flags: cuint): fftwf_plan {.cdecl, importc: "fftwf_plan_r2r_2d",
        dynlib: Fftw3Lib.}

proc fftwf_plan_r2r_3d*(n0: cint, n1: cint, n2: cint, inptr: ptr UncheckedArray[cfloat], outptr: ptr UncheckedArray[
        cfloat], kind0: fftwf_r2r_kind, kind1: fftwf_r2r_kind, kind2: fftwf_r2r_kind, flags: cuint): fftwf_plan {.cdecl,
        importc: "fftwf_plan_r2r_3d", dynlib: Fftw3Lib.}

proc fftwf_plan_r2r*(input: Tensor[float32], output: Tensor[float32], kinds: seq[fftwf_r2r_kind],
        flags: cuint = FFTW_MEASURE): fftwf_plan =
    ## Generic real-to-real Tensor plan calculation using FFTW_MEASURE as a default ffwf flag.
    case input.rank:
    of 1:
      fftwf_plan_r2r_1d(input.shape[0].cint, input.toUnsafeView(), output.toUnsafeView(), kinds[0], flags)
    of 2:
      fftwf_plan_r2r_2d(input.shape[0].cint, input.shape[1].cint, input.toUnsafeView(), output.toUnsafeView(), kinds[0], kinds[1], flags)
    of 3:
      fftwf_plan_r2r_3d(input.shape[0].cint, input.shape[1].cint, input.shape[2].cint, input.toUnsafeView(), output.toUnsafeView(), kinds[0], kinds[1], kinds[2], flags)
    else:
      let shape: seq[cint] = map(input.shape.toSeq, proc(x: int): cint = x.cint)
      fftwf_plan_r2r(input.rank.cint, shape[0].unsafeaddr, input.toUnsafeView(), output.toUnsafeView(), kinds[0].unsafeaddr, flags)

# FFTW Plan Many API
proc fftwf_plan_many_dft*(rank: cint, n: ptr cint, howmany: cint, inptr: ptr UncheckedArray[Complex32],
        inembed: ptr cint, istride: cint, idist: cint, outptr: ptr UncheckedArray[Complex32], onembed: ptr cint,
        ostride: cint, odist: cint, sign: cint, flags: cuint): fftwf_plan {.cdecl, importc: "fftwf_plan_many_dft",
        dynlib: Fftw3Lib.}
    ## Plan mutliple multidimensionnal complex DFTs and extend ``fftwf_plan_dft`` to compute howmany transforms, each having rank rank and size n.
    ##
    ## ``howmany`` is the (nonnegative) number of transforms to compute. The resulting plan computes howmany transforms, where the input of the k-th transform is at location in+k*idist (in C pointer arithmetic), and its output is at location out+k*odist.
    ##
    ## Plans obtained in this way can often be faster than calling FFTW multiple times for the individual transforms. The basic fftwf_plan_dft interface corresponds to howmany=1 (in which case the dist parameters are ignored).

proc fftwf_plan_many_dft_c2r*(rank: cint, n: ptr cint, howmany: cint,
                             inptr: ptr UncheckedArray[Complex32], inembed: ptr cint,
                             istride: cint, idist: cint, outptr: ptr UncheckedArray[cfloat],
                             onembed: ptr cint, ostride: cint, odist: cint,
                             flags: cuint): fftwf_plan {.cdecl,
    importc: "fftwf_plan_many_dft_c2r", dynlib: Fftw3Lib.}

proc fftwf_plan_many_dft_r2c*(rank: cint, n: ptr cint, howmany: cint,
                             inptr: ptr UncheckedArray[cfloat], inembed: ptr cint,
                             istride: cint, idist: cint,
                             outptr: ptr UncheckedArray[Complex32], onembed: ptr cint,
                             ostride: cint, odist: cint, flags: cuint): fftwf_plan {.
    cdecl, importc: "fftwf_plan_many_dft_r2c", dynlib: Fftw3Lib.}

proc fftwf_plan_many_r2r*(rank: cint, n: ptr cint, howmany: cint,
                         inptr: ptr UncheckedArray[cfloat], inembed: ptr cint, istride: cint,
                         idist: cint, outptr: ptr UncheckedArray[cfloat], onembed: ptr cint,
                         ostride: cint, odist: cint, kind: ptr fftwf_r2r_kind,
                         flags: cuint): fftwf_plan {.cdecl,
    importc: "fftwf_plan_many_r2r", dynlib: Fftw3Lib.}

proc fftwf_set_timelimit*(t: cfloat) {.cdecl, importc: "fftwf_set_timelimit", dynlib: Fftw3Lib.}
  ## Set timelimit to FFT

# FFTW Utility & Cleanup API
proc fftwf_destroy_plan*(p: fftwf_plan) {.cdecl, importc: "fftwf_destroy_plan", dynlib: Fftw3Lib.}
  ## Destroy a plan

proc fftwf_cleanup*() {.cdecl, importc: "fftwf_cleanup", dynlib: Fftw3Lib.}
  ## All existing plans become undefined, and you should not attempt to execute them nor to destroy them. You can however create and execute/destroy new plans, in which case FFTW starts accumulating wisdom information again.

when compileOption("threads"):
  proc fftwf_init_threads*() {.cdecl, importc: "fftwf_init_threads", dynlib: Fftw3Lib.}
    ## Initialize once before using thread-ed plan
    ## Needs ``--threads:on`` to be enabled
  proc fftwf_plan_with_nthreads*(nthreads: cint) {.cdecl, importc: "fftwf_plan_with_nthreads", dynlib: Fftw3Lib.}
    ## Set the number of threads to use
    ## Needs ``--threads:on`` to be enabled
  proc fftwf_cleanup_threads*() {.cdecl, importc: "fftwf_cleanup_threads", dynlib: Fftw3Lib.}
    ## Additional clean-up when threads are used
    ## Needs ``--threads:on`` to be enabled

