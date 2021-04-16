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
##    let bufIn = cast[ptr UncheckedArray[cdouble]](add(input[0]))
##    let bufOut = cast[ptr UncheckedArray[cdouble]](add(output[0]))
##    let plan = fftw_plan_r2r_1d(N, bufIn, FFTW_REDFT00, FFTW_ESTIMATE)
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
import fftw3/libutils
# Import mostly for documentation links
{.push warning[UnusedImport]: off.}
import fftw3/guru, fftw3/wisdom
{.pop.}
import fftw3/fftshift
# export used types
export fftw_plan
export fftw_r2r_kind
export fftshift

const
    FFTW_MEASURE* = 0              ## ``fftw_plan`` planner flag.
                                   ##
                      ## Find an optimized plan by computing several FFTs and measuring their execution time. Default planning option.
    FFTW_ESTIMATE* = 1 shl 6       ## ``fftw_plan`` planner flag.
                                   ##
                             ## Instead of time measurements, a simple heuristic is used to pick a plan quickly. The input/output arrays are not overwritten during planning.
    FFTW_PATIENT* = 1 shl 5        ## ``fftw_plan`` planner flag.
                                   ##
                                   ## Like FFTW_MEASURE, but considers a wider range of algorithms.
    FFTW_EXHAUSTIVE* = 1 shl 3     ## ``fftw_plan`` planner flag.
                                   ##
                                   ## Like FFTW_PATIENT, but considers an even wider range of algorithms.
    FFTW_WISDOM_ONLY* = 1 shl 21   ## ``fftw_plan`` planner flag.
                                   ##
                                   ## Special planning mode in which the plan is created only if wisdow is available.

    FFTW_DESTROY_INPUT* = 1        ## ``fftw_plan`` planner flag.
                                   ##
                            ## An out-of-place transform is allowed to overwrite its input array with arbitrary data. Default value for complex-to-real transform.
    FFTW_PRESERVE_INPUT* = 1 shl 4 ## ``fftw_plan`` planner flag.
                                   ##
                                   ## An out-of-place transform must not change its input array. Default value except for complex-to-real (c2r and hc2r).
    FFTW_UNALIGNED* = 1 shl 1      ## ``fftw_plan`` planner flag.
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

# FFTW Execute API
proc fftw_execute*(p: fftw_plan) {.cdecl, importc: "fftw_execute", dynlib: Fftw3Lib.}
  ## Execute a plan

proc fftw_execute_dft*(p: fftw_plan, inptr: ptr UncheckedArray[Complex64], outptr: ptr UncheckedArray[Complex64]) {.
        cdecl, importc: "fftw_execute_dft", dynlib: Fftw3Lib.}
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

    fftw_execute_dft(p, input.toUnsafeView(), output.toUnsafeView())

proc fftw_execute_r2r*(p: fftw_plan, inptr: ptr UncheckedArray[cdouble], outptr: ptr UncheckedArray[cdouble]) {.cdecl,
        importc: "fftw_execute_r2r", dynlib: Fftw3Lib.}
  ## Execute a plan real-to-real

proc fftw_execute_dft_r2c*(p: fftw_plan, inptr: ptr UncheckedArray[cdouble], outptr: ptr UncheckedArray[Complex64]) {.
        cdecl, importc: "fftw_execute_dft_r2c", dynlib: Fftw3Lib.}
  ## Execute a plan real-to-complex

proc fftw_execute_dft_r2c*(p: fftw_plan, input: Tensor[float64], output: Tensor[Complex64]) =
    ## Execute a real-to-complex plan on new Tensor
    fftw_execute_dft_r2c(p, input.asType(cdouble).toUnsafeView(), output.toUnsafeView())

proc fftw_execute_dft_c2r*(p: fftw_plan, inptr: ptr UncheckedArray[Complex64], outptr: ptr UncheckedArray[cdouble]) {.
        cdecl, importc: "fftw_execute_dft_c2r", dynlib: Fftw3Lib.}
  ## Execute a plan complex-to-real

proc fftw_execute_dft_c2r*(p: fftw_plan, input: Tensor[Complex64], output: Tensor[float64]) =
    ## Execute a complex-to-real plan on new Tensor
    fftw_execute_dft_c2r(p, input.toUnsafeView(), cast[ptr UncheckedArray[cdouble]](output.toUnsafeView()))

# FFTW Plan API
proc fftw_plan_dft*(rank: cint, n: ptr cint, inptr: ptr UncheckedArray[Complex64],
                    outptr: ptr UncheckedArray[Complex64], sign: cint, flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_dft", dynlib: Fftw3Lib.}

proc fftw_plan_dft_1d*(n: cint, inptr: ptr UncheckedArray[Complex64], outptr: ptr UncheckedArray[Complex64], sign: cint,
        flags: cuint): fftw_plan {.cdecl, importc: "fftw_plan_dft_1d", dynlib: Fftw3Lib.}

proc fftw_plan_dft_2d*(n0: cint, n1: cint, inptr: ptr UncheckedArray[Complex64], outptr: ptr UncheckedArray[Complex64],
        sign: cint, flags: cuint): fftw_plan {.cdecl, importc: "fftw_plan_dft_2d", dynlib: Fftw3Lib.}

proc fftw_plan_dft_3d*(n0: cint, n1: cint, n2: cint, inptr: ptr UncheckedArray[Complex64], outptr: ptr UncheckedArray[
        Complex64], sign: cint, flags: cuint): fftw_plan {.cdecl, importc: "fftw_plan_dft_3d", dynlib: Fftw3Lib.}

proc fftw_plan_dft*(input: Tensor[Complex64], output: Tensor[Complex64], sign: cint,
        flags: cuint = FFTW_MEASURE): fftw_plan =
    ## Generic Tensor plan calculation using FFTW_MEASURE as a default fftw flag.
    ##
    ## Read carefully FFTW documentation about the input / output dimension it will change depending on the transformation.
    case input.rank:
    of 1:
      fftw_plan_dft_1d(input.shape[0].cint, input.toUnsafeView(), output.toUnsafeView(), sign, flags)
    of 2:
      fftw_plan_dft_2d(input.shape[0].cint, input.shape[1].cint, input.toUnsafeView(), output.toUnsafeView(), sign, flags)
    of 3:
      fftw_plan_dft_3d(input.shape[0].cint, input.shape[1].cint, input.shape[2].cint, input.toUnsafeView(), output.toUnsafeView(), sign, flags)
    else:
      var shape: seq[cint] = map(input.shape.toSeq, proc(x: int): cint = x.cint)
      fftw_plan_dft(input.rank.cint, (shape[0].unsafeaddr), input.toUnsafeView(), output.toUnsafeView(), sign, flags)


proc fftw_plan_dft_r2c*(rank: cint, n: ptr cint, inptr: ptr UncheckedArray[cdouble], outptr: ptr UncheckedArray[
        Complex64], flags: cuint): fftw_plan {.cdecl, importc: "fftw_plan_dft_r2c", dynlib: Fftw3Lib.}

proc fftw_plan_dft_r2c_1d*(n: cint, inptr: ptr UncheckedArray[cdouble], outptr: ptr UncheckedArray[Complex64],
        flags: cuint): fftw_plan {.cdecl, importc: "fftw_plan_dft_r2c_1d", dynlib: Fftw3Lib.}

proc fftw_plan_dft_r2c_2d*(n0: cint, n1: cint, inptr: ptr UncheckedArray[cdouble], outptr: ptr UncheckedArray[
        Complex64], flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_dft_r2c_2d", dynlib: Fftw3Lib.}

proc fftw_plan_dft_r2c_3d*(n0: cint, n1: cint, n2: cint, inptr: ptr UncheckedArray[cdouble], outptr: ptr UncheckedArray[
        Complex64], flags: cuint): fftw_plan {.cdecl, importc: "fftw_plan_dft_r2c_3d", dynlib: Fftw3Lib.}

proc fftw_plan_dft_r2c*(input: Tensor[float64], output: Tensor[Complex64], flags: cuint = FFTW_MEASURE): fftw_plan =
    ## Generic Real-to-Complex Tensor plan calculation using FFTW_MEASURE as a default fftw flag.
    ##
    ## Read carefully FFTW documentation about the input / output dimension as FFTW does not calculate redundant conjugate value.
    case input.rank:
    of 1:
      fftw_plan_dft_r2c_1d(input.shape[0].cint, input.toUnsafeView(), output.toUnsafeView(), flags)
    of 2:
      fftw_plan_dft_r2c_2d(input.shape[0].cint, input.shape[1].cint, input.toUnsafeView(), output.toUnsafeView(), flags)
    of 3:
      fftw_plan_dft_r2c_3d(input.shape[0].cint, input.shape[1].cint, input.shape[2].cint, input.toUnsafeView(), output.toUnsafeView(), flags)
    else:
      let shape: seq[cint] = map(input.shape.toSeq(), proc(x: int): cint = x.cint)
      fftw_plan_dft_r2c(input.rank.cint, (shape[0].unsafeaddr), input.toUnsafeView(), output.toUnsafeView(), flags)


proc fftw_plan_dft_c2r*(rank: cint, n: ptr cint, inptr: ptr UncheckedArray[Complex64], outptr: ptr UncheckedArray[
        cdouble], flags: cuint): fftw_plan {.cdecl, importc: "fftw_plan_dft_c2r", dynlib: Fftw3Lib.}

proc fftw_plan_dft_c2r_1d*(n: cint, inptr: ptr UncheckedArray[Complex64], outptr: ptr UncheckedArray[cdouble],
        flags: cuint): fftw_plan {.cdecl, importc: "fftw_plan_dft_c2r_1d", dynlib: Fftw3Lib.}

proc fftw_plan_dft_c2r_2d*(n0: cint, n1: cint, inptr: ptr UncheckedArray[Complex64], outptr: ptr UncheckedArray[
        cdouble], flags: cuint): fftw_plan {.cdecl, importc: "fftw_plan_dft_c2r_2d", dynlib: Fftw3Lib.}

proc fftw_plan_dft_c2r_3d*(n0: cint, n1: cint, n2: cint, inptr: ptr UncheckedArray[Complex64],
        outptr: ptr UncheckedArray[cdouble], flags: cuint): fftw_plan {.cdecl, importc: "fftw_plan_dft_c2r_3d",
        dynlib: Fftw3Lib.}

proc fftw_plan_dft_c2r*(input: Tensor[Complex64], output: Tensor[float64], flags: cuint = FFTW_MEASURE): fftw_plan =
    ## Generic Complex-to-real Tensor plan calculation using FFTW_MEASURE as a default fftw flag.
    case input.rank:
    of 1:
      fftw_plan_dft_c2r_1d(input.shape[0].cint, input.toUnsafeView(), output.toUnsafeView(), flags)
    of 2:
      fftw_plan_dft_c2r_2d(input.shape[0].cint, input.shape[1].cint, input.toUnsafeView(), output.toUnsafeView(), flags)
    of 3:
      fftw_plan_dft_c2r_3d(input.shape[0].cint, input.shape[1].cint, input.shape[2].cint, input.toUnsafeView(), output.toUnsafeView(), flags)
    else:
      let shape: seq[cint] = map(input.shape.toSeq(), proc(x: int): cint = x.cint)
      fftw_plan_dft_c2r(input.rank.cint, (shape[0].unsafeaddr), input.toUnsafeView(), output.toUnsafeView(), flags)

proc fftw_plan_r2r*(rank: cint, n: ptr cint, inptr: ptr UncheckedArray[cdouble], outptr: ptr UncheckedArray[cdouble],
        kind: ptr fftw_r2r_kind, flags: cuint): fftw_plan {.cdecl, importc: "fftw_plan_r2r", dynlib: Fftw3Lib.}

proc fftw_plan_r2r_1d*(n: cint, inptr: ptr UncheckedArray[cdouble], outptr: ptr UncheckedArray[cdouble],
        kind: fftw_r2r_kind, flags: cuint): fftw_plan {.cdecl, importc: "fftw_plan_r2r_1d", dynlib: Fftw3Lib.}

proc fftw_plan_r2r_2d*(n0: cint, n1: cint, inptr: ptr UncheckedArray[cdouble], outptr: ptr UncheckedArray[cdouble],
        kind0: fftw_r2r_kind, kind1: fftw_r2r_kind, flags: cuint): fftw_plan {.cdecl, importc: "fftw_plan_r2r_2d",
        dynlib: Fftw3Lib.}

proc fftw_plan_r2r_3d*(n0: cint, n1: cint, n2: cint, inptr: ptr UncheckedArray[cdouble], outptr: ptr UncheckedArray[
        cdouble], kind0: fftw_r2r_kind, kind1: fftw_r2r_kind, kind2: fftw_r2r_kind, flags: cuint): fftw_plan {.cdecl,
        importc: "fftw_plan_r2r_3d", dynlib: Fftw3Lib.}

proc fftw_plan_r2r*(input: Tensor[float64], output: Tensor[float64], kinds: seq[fftw_r2r_kind],
        flags: cuint = FFTW_MEASURE): fftw_plan =
    ## Generic real-to-real Tensor plan calculation using FFTW_MEASURE as a default fftw flag.
    case input.rank:
    of 1:
      fftw_plan_r2r_1d(input.shape[0].cint, input.toUnsafeView(), output.toUnsafeView(), kinds[0], flags)
    of 2:
      fftw_plan_r2r_2d(input.shape[0].cint, input.shape[1].cint, input.toUnsafeView(), output.toUnsafeView(), kinds[0], kinds[1], flags)
    of 3:
      fftw_plan_r2r_3d(input.shape[0].cint, input.shape[1].cint, input.shape[2].cint, input.toUnsafeView(), output.toUnsafeView(), kinds[0], kinds[1], kinds[2], flags)
    else:
      let shape: seq[cint] = map(input.shape.toSeq, proc(x: int): cint = x.cint)
      fftw_plan_r2r(input.rank.cint, shape[0].unsafeaddr, input.toUnsafeView(), output.toUnsafeView(), kinds[0].unsafeaddr, flags)

# FFTW Plan Many API
proc fftw_plan_many_dft*(rank: cint, n: ptr cint, howmany: cint, inptr: ptr UncheckedArray[Complex64],
        inembed: ptr cint, istride: cint, idist: cint, outptr: ptr UncheckedArray[Complex64], onembed: ptr cint,
        ostride: cint, odist: cint, sign: cint, flags: cuint): fftw_plan {.cdecl, importc: "fftw_plan_many_dft",
        dynlib: Fftw3Lib.}
    ## Plan mutliple multidimensionnal complex DFTs and extend ``fftw_plan_dft`` to compute howmany transforms, each having rank rank and size n.
    ##
    ## ``howmany`` is the (nonnegative) number of transforms to compute. The resulting plan computes howmany transforms, where the input of the k-th transform is at location in+k*idist (in C pointer arithmetic), and its output is at location out+k*odist.
    ##
    ## Plans obtained in this way can often be faster than calling FFTW multiple times for the individual transforms. The basic fftw_plan_dft interface corresponds to howmany=1 (in which case the dist parameters are ignored).

proc fftw_plan_many_dft_c2r*(rank: cint, n: ptr cint, howmany: cint,
                             inptr: ptr UncheckedArray[Complex64], inembed: ptr cint,
                             istride: cint, idist: cint, outptr: ptr UncheckedArray[cdouble],
                             onembed: ptr cint, ostride: cint, odist: cint,
                             flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_many_dft_c2r", dynlib: Fftw3Lib.}

proc fftw_plan_many_dft_r2c*(rank: cint, n: ptr cint, howmany: cint,
                             inptr: ptr UncheckedArray[cdouble], inembed: ptr cint,
                             istride: cint, idist: cint,
                             outptr: ptr UncheckedArray[Complex64], onembed: ptr cint,
                             ostride: cint, odist: cint, flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_many_dft_r2c", dynlib: Fftw3Lib.}

proc fftw_plan_many_r2r*(rank: cint, n: ptr cint, howmany: cint,
                         inptr: ptr UncheckedArray[cdouble], inembed: ptr cint, istride: cint,
                         idist: cint, outptr: ptr UncheckedArray[cdouble], onembed: ptr cint,
                         ostride: cint, odist: cint, kind: ptr fftw_r2r_kind,
                         flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_many_r2r", dynlib: Fftw3Lib.}

# FFTW Utility & Cleanup API
proc fftw_destroy_plan*(p: fftw_plan) {.cdecl, importc: "fftw_destroy_plan", dynlib: Fftw3Lib.}
  ## Destroy a plan

proc fftw_cleanup*() {.cdecl, importc: "fftw_cleanup", dynlib: Fftw3Lib.}
  ## All existing plans become undefined, and you should not attempt to execute them nor to destroy them. You can however create and execute/destroy new plans, in which case FFTW starts accumulating wisdom information again.

proc fftw_set_timelimit*(t: cdouble) {.cdecl, importc: "fftw_set_timelimit", dynlib: Fftw3Lib.}

when compileOption("threads"):
  proc fftw_init_threads*() {.cdecl, importc: "fftw_init_threads", dynlib: Fftw3ThreadLib.}
  proc fftw_plan_with_nthreads*(nthreads: cint) {.cdecl, importc: "fftw_plan_with_nthreads", dynlib: Fftw3ThreadLib.}
  proc fftw_cleanup_threads*() {.cdecl, importc: "fftw_cleanup_threads", dynlib: Fftw3ThreadLib.}
#   {.passL: "-lfftw3_threads"}
# {.passL: "-lfftw3"}

