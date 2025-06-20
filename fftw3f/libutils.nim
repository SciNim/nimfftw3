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
  fftwfr2r_kind* = enum
    FFTW_R2HC = 0, FFTW_HC2R = 1, FFTW_DHT = 2, FFTW_REDFT00 = 3, FFTW_REDFT01 = 4, FFTW_REDFT10 = 5, FFTW_REDFT11 = 6, FFTW_RODFT00 = 7, FFTW_RODFT01 = 8, FFTW_RODFT10 = 9, FFTW_RODFT11 = 10

  fftwfiodim* {.pure.} = object
    n*: cint
    `is`*: cint
    os*: cint

  ptrdiff_t* = clong
  wchar_t* = cint
  fftwfiodim64* {.pure.} = object
    n*: ptrdiff_t
    `is`*: ptrdiff_t
    os*: ptrdiff_t

  fftwfwrite_char_func* = proc (c: char, a3: pointer) {.cdecl.}
  fftwfread_char_func* = proc (a2: pointer): cint {.cdecl.}
  # Deprecated -> Use complex
  fftwfcomplex = Complex64
  fftwfplan* = pointer


proc fftwffprint_plan*(p: fftwfplan, output_file: ptr FILE) {.cdecl, importc: "fftwffprint_plan", dynlib: Fftw3Lib.}

proc fftwfprint_plan*(p: fftwfplan) {.cdecl, importc: "fftwfprint_plan", dynlib: Fftw3Lib.}

proc fftwfsprint_plan*(p: fftwfplan): cstring {.cdecl, importc: "fftwfsprint_plan", dynlib: Fftw3Lib.}

proc fftwfmalloc*(n: csize_t): pointer {.cdecl, importc: "fftwfmalloc", dynlib: Fftw3Lib.}

proc fftwfalloc_real*(n: csize_t): ptr cdouble {.cdecl, importc: "fftwfalloc_real", dynlib: Fftw3Lib.}

proc fftwfalloc_complex*(n: csize_t): ptr fftwfcomplex {.cdecl, importc: "fftwfalloc_complex", dynlib: Fftw3Lib.}

proc fftwffree*(p: pointer) {.cdecl, importc: "fftwffree", dynlib: Fftw3Lib.}

proc fftwfflops*(p: fftwfplan, add: ptr cdouble, mul: ptr cdouble, fmas: ptr cdouble) {.cdecl, importc: "fftwfflops",
        dynlib: Fftw3Lib.}

proc fftwfestimate_cost*(p: fftwfplan): cdouble {.cdecl, importc: "fftwfestimate_cost", dynlib: Fftw3Lib.}

proc fftwfcost*(p: fftwfplan): cdouble {.cdecl, importc: "fftwfcost", dynlib: Fftw3Lib.}

proc fftwfalignment_of*(p: ptr cdouble): cint {.cdecl, importc: "fftwfalignment_of", dynlib: Fftw3Lib.}

let fftwf_version* {.importc: "fftwf_version", dynlib: Fftw3Lib.}: cstring

var fftwf_cc* {.importc: "fftwf_cc", dynlib: Fftw3Lib.}: cstring

var fftwf_codelet_optim* {.importc: "fftwf_codelet_optim", dynlib: Fftw3Lib.}: cstring

