import complex
import os

## Some utility types and functions not directly used to calculate FFT
when defined(windows):
  const Fftw3LibName = "libfftw3f-3.dll"
elif defined(macosx):
  const Fftw3LibName* = "libfftw3f(|.0).dylib"
else:
  const Fftw3LibName* = "libfftw3f.so.(|3|3.6.9)"

when defined(localFftw3):
  const Fftw3LibPath = currentSourcePath().parentDir().parentDir() / "third_party" / "lib"
  const Fftw3Lib* = Fftw3LibPath / Fftw3LibName
else:
  const Fftw3Lib* = Fftw3LibName
# static:
#   debugEcho "nim-ffwf3> Using dynamic library: ", Fftw3Lib

proc getFftw3Lib*() : string {.compiletime.}=
  return Fftw3Lib

type
  fftwf_r2r_kind* = enum
    FFTW_R2HC = 0, FFTW_HC2R = 1, FFTW_DHT = 2, FFTW_REDFT00 = 3, FFTW_REDFT01 = 4, FFTW_REDFT10 = 5, FFTW_REDFT11 = 6, FFTW_RODFT00 = 7, FFTW_RODFT01 = 8, FFTW_RODFT10 = 9, FFTW_RODFT11 = 10

  fftwf_iodim* {.pure.} = object
    n*: cint
    `is`*: cint
    os*: cint

  ptrdiff_t* = clong
  wchar_t* = cint
  fftwf_iodim64* {.pure.} = object
    n*: ptrdiff_t
    `is`*: ptrdiff_t
    os*: ptrdiff_t

  fftwf_write_char_func* = proc (c: char, a3: pointer) {.cdecl.}
  fftwf_read_char_func* = proc (a2: pointer): cint {.cdecl.}
  # Deprecated -> Use complex
  fftwf_complex = Complex32
  fftwf_plan* = pointer


proc fftwf_fprint_plan*(p: fftwf_plan, output_file: ptr FILE) {.cdecl, importc: "fftwf_fprint_plan", dynlib: Fftw3Lib.}

proc fftwf_print_plan*(p: fftwf_plan) {.cdecl, importc: "fftwf_print_plan", dynlib: Fftw3Lib.}

proc fftwf_sprint_plan*(p: fftwf_plan): cstring {.cdecl, importc: "fftwf_sprint_plan", dynlib: Fftw3Lib.}

proc fftwf_malloc*(n: csize_t): pointer {.cdecl, importc: "fftwf_malloc", dynlib: Fftw3Lib.}

proc fftwf_alloc_real*(n: csize_t): ptr cdouble {.cdecl, importc: "fftwf_alloc_real", dynlib: Fftw3Lib.}

proc fftwf_alloc_complex*(n: csize_t): ptr fftwf_complex {.cdecl, importc: "fftwf_alloc_complex", dynlib: Fftw3Lib.}

proc fftwf_free*(p: pointer) {.cdecl, importc: "fftwf_free", dynlib: Fftw3Lib.}

proc fftwf_flops*(p: fftwf_plan, add: ptr cdouble, mul: ptr cdouble, fmas: ptr cdouble) {.cdecl, importc: "fftwf_flops",
        dynlib: Fftw3Lib.}

proc fftwf_estimate_cost*(p: fftwf_plan): cdouble {.cdecl, importc: "fftwf_estimate_cost", dynlib: Fftw3Lib.}

proc fftwf_cost*(p: fftwf_plan): cdouble {.cdecl, importc: "fftwf_cost", dynlib: Fftw3Lib.}

proc fftwf_alignment_of*(p: ptr cdouble): cint {.cdecl, importc: "fftwf_alignment_of", dynlib: Fftw3Lib.}

let fftwf_version* {.importc: "fftwf_version", dynlib: Fftw3Lib.}: cstring

var fftwf_cc* {.importc: "fftwf_cc", dynlib: Fftw3Lib.}: cstring

var fftwf_codelet_optim* {.importc: "fftwf_codelet_optim", dynlib: Fftw3Lib.}: cstring

