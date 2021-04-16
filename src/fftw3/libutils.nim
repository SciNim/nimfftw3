import complex

## Some utility types and functions not directly used to calculate FFT

when defined(windows):
    const Fftw3Lib* = "fftw3.dll"
    when compileOption("threads"):
      const Fftw3ThreadLib* = "fftw3_threads.dll"
elif defined(macosx):
    const Fftw3Lib* = "libfftw3(|.0).dylib"
    when compileOption("threads"):
      const Fftw3ThreadLib* = "libfftw3_threads(|.0).dylib"
else:
    const Fftw3Lib* = "libfftw3.so(|.3)"
    when compileOption("threads"):
      const Fftw3ThreadLib* = "libfftw3_threads(|.3).so"

type
    fftw_r2r_kind* = enum
        FFTW_R2HC = 0, FFTW_HC2R = 1, FFTW_DHT = 2, FFTW_REDFT00 = 3, FFTW_REDFT01 = 4, FFTW_REDFT10 = 5,
                FFTW_REDFT11 = 6, FFTW_RODFT00 = 7, FFTW_RODFT01 = 8, FFTW_RODFT10 = 9, FFTW_RODFT11 = 10

    fftw_iodim* {.pure.} = object
        n*: cint
        `is`*: cint
        os*: cint

    ptrdiff_t* = clong
    wchar_t* = cint
    fftw_iodim64* {.pure.} = object
        n*: ptrdiff_t
        `is`*: ptrdiff_t
        os*: ptrdiff_t

    fftw_write_char_func* = proc (c: char, a3: pointer) {.cdecl.}
    fftw_read_char_func* = proc (a2: pointer): cint {.cdecl.}
    # Deprecated -> Use complex
    fftw_complex = Complex64
    fftw_plan* = pointer


proc fftw_fprint_plan*(p: fftw_plan, output_file: ptr FILE) {.cdecl, importc: "fftw_fprint_plan", dynlib: Fftw3Lib.}

proc fftw_print_plan*(p: fftw_plan) {.cdecl, importc: "fftw_print_plan", dynlib: Fftw3Lib.}

proc fftw_sprint_plan*(p: fftw_plan): cstring {.cdecl, importc: "fftw_sprint_plan", dynlib: Fftw3Lib.}

proc fftw_malloc*(n: csize_t): pointer {.cdecl, importc: "fftw_malloc", dynlib: Fftw3Lib.}

proc fftw_alloc_real*(n: csize_t): ptr cdouble {.cdecl, importc: "fftw_alloc_real", dynlib: Fftw3Lib.}

proc fftw_alloc_complex*(n: csize_t): ptr fftw_complex {.cdecl, importc: "fftw_alloc_complex", dynlib: Fftw3Lib.}

proc fftw_free*(p: pointer) {.cdecl, importc: "fftw_free", dynlib: Fftw3Lib.}

proc fftw_flops*(p: fftw_plan, add: ptr cdouble, mul: ptr cdouble, fmas: ptr cdouble) {.cdecl, importc: "fftw_flops",
        dynlib: Fftw3Lib.}

proc fftw_estimate_cost*(p: fftw_plan): cdouble {.cdecl, importc: "fftw_estimate_cost", dynlib: Fftw3Lib.}

proc fftw_cost*(p: fftw_plan): cdouble {.cdecl, importc: "fftw_cost", dynlib: Fftw3Lib.}

proc fftw_alignment_of*(p: ptr cdouble): cint {.cdecl, importc: "fftw_alignment_of", dynlib: Fftw3Lib.}

let fftw_version* {.importc: "fftw_version", dynlib: Fftw3Lib.}: cstring

var fftw_cc* {.importc: "fftw_cc", dynlib: Fftw3Lib.}: cstring

var fftw_codelet_optim* {.importc: "fftw_codelet_optim", dynlib: Fftw3Lib.}: cstring

