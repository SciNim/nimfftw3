import libutils
import complex

## FFTW Guru API for experts who knows what they're doing.

# Split Array API
proc fftwf_execute_split_dft*(p: fftwf_plan, ri: ptr cdouble, ii: ptr cdouble, ro: ptr cdouble, io: ptr cdouble) {.cdecl,
        importc: "fftwf_execute_split_dft", dynlib: Fftw3Lib.}

proc fftwf_execute_split_dft_r2c*(p: fftwf_plan, inptr: ptr cdouble, ro: ptr cdouble, io: ptr cdouble) {.cdecl,
        importc: "fftwf_execute_split_dft_r2c", dynlib: Fftw3Lib.}

proc fftwf_execute_split_dft_c2r*(p: fftwf_plan, ri: ptr cdouble, ii: ptr cdouble, outptr: ptr cdouble) {.cdecl,
        importc: "fftwf_execute_split_dft_c2r", dynlib: Fftw3Lib.}


# FFTW "Guru" API
proc fftwf_plan_guru_dft*(rank: cint, dims: ptr fftwf_iodim, howmany_rank: cint,
                         howmany_dims: ptr fftwf_iodim, inptr: ptr Complex64,
                         outptr: ptr Complex64, sign: cint, flags: cuint): fftwf_plan {.
    cdecl, importc: "fftwf_plan_guru_dft", dynlib: Fftw3Lib.}
proc fftwf_plan_guru_split_dft*(rank: cint, dims: ptr fftwf_iodim,
                               howmany_rank: cint, howmany_dims: ptr fftwf_iodim,
                               ri: ptr cdouble, ii: ptr cdouble,
                               ro: ptr cdouble, io: ptr cdouble, flags: cuint): fftwf_plan {.
    cdecl, importc: "fftwf_plan_guru_split_dft", dynlib: Fftw3Lib.}
proc fftwf_plan_guru64_dft*(rank: cint, dims: ptr fftwf_iodim64,
                           howmany_rank: cint, howmany_dims: ptr fftwf_iodim64,
                           inptr: ptr Complex64, outptr: ptr Complex64,
                           sign: cint, flags: cuint): fftwf_plan {.cdecl,
    importc: "fftwf_plan_guru64_dft", dynlib: Fftw3Lib.}
proc fftwf_plan_guru64_split_dft*(rank: cint, dims: ptr fftwf_iodim64,
                                 howmany_rank: cint,
                                 howmany_dims: ptr fftwf_iodim64,
                                 ri: ptr cdouble, ii: ptr cdouble,
                                 ro: ptr cdouble, io: ptr cdouble, flags: cuint): fftwf_plan {.
    cdecl, importc: "fftwf_plan_guru64_split_dft", dynlib: Fftw3Lib.}
proc fftwf_plan_guru_dft_r2c*(rank: cint, dims: ptr fftwf_iodim,
                             howmany_rank: cint, howmany_dims: ptr fftwf_iodim,
                             inptr: ptr cdouble, outptr: ptr Complex64,
                             flags: cuint): fftwf_plan {.cdecl,
    importc: "fftwf_plan_guru_dft_r2c", dynlib: Fftw3Lib.}
proc fftwf_plan_guru_dft_c2r*(rank: cint, dims: ptr fftwf_iodim,
                             howmany_rank: cint, howmany_dims: ptr fftwf_iodim,
                             inptr: ptr Complex64, outptr: ptr cdouble,
                             flags: cuint): fftwf_plan {.cdecl,
    importc: "fftwf_plan_guru_dft_c2r", dynlib: Fftw3Lib.}
proc fftwf_plan_guru_split_dft_r2c*(rank: cint, dims: ptr fftwf_iodim,
                                   howmany_rank: cint,
                                   howmany_dims: ptr fftwf_iodim,
                                   inptr: ptr cdouble, ro: ptr cdouble,
                                   io: ptr cdouble, flags: cuint): fftwf_plan {.
    cdecl, importc: "fftwf_plan_guru_split_dft_r2c", dynlib: Fftw3Lib.}
proc fftwf_plan_guru_split_dft_c2r*(rank: cint, dims: ptr fftwf_iodim,
                                   howmany_rank: cint,
                                   howmany_dims: ptr fftwf_iodim,
                                   ri: ptr cdouble, ii: ptr cdouble,
                                   outptr: ptr cdouble, flags: cuint): fftwf_plan {.
    cdecl, importc: "fftwf_plan_guru_split_dft_c2r", dynlib: Fftw3Lib.}
proc fftwf_plan_guru64_dft_r2c*(rank: cint, dims: ptr fftwf_iodim64,
                               howmany_rank: cint,
                               howmany_dims: ptr fftwf_iodim64,
                               inptr: ptr cdouble, outptr: ptr Complex64,
                               flags: cuint): fftwf_plan {.cdecl,
    importc: "fftwf_plan_guru64_dft_r2c", dynlib: Fftw3Lib.}
proc fftwf_plan_guru64_dft_c2r*(rank: cint, dims: ptr fftwf_iodim64,
                               howmany_rank: cint,
                               howmany_dims: ptr fftwf_iodim64,
                               inptr: ptr Complex64, outptr: ptr cdouble,
                               flags: cuint): fftwf_plan {.cdecl,
    importc: "fftwf_plan_guru64_dft_c2r", dynlib: Fftw3Lib.}
proc fftwf_plan_guru64_split_dft_r2c*(rank: cint, dims: ptr fftwf_iodim64,
                                     howmany_rank: cint,
                                     howmany_dims: ptr fftwf_iodim64,
                                     inptr: ptr cdouble, ro: ptr cdouble,
                                     io: ptr cdouble, flags: cuint): fftwf_plan {.
    cdecl, importc: "fftwf_plan_guru64_split_dft_r2c", dynlib: Fftw3Lib.}
proc fftwf_plan_guru64_split_dft_c2r*(rank: cint, dims: ptr fftwf_iodim64,
                                     howmany_rank: cint,
                                     howmany_dims: ptr fftwf_iodim64,
                                     ri: ptr cdouble, ii: ptr cdouble,
                                     outptr: ptr cdouble, flags: cuint): fftwf_plan {.
    cdecl, importc: "fftwf_plan_guru64_split_dft_c2r", dynlib: Fftw3Lib.}

proc fftwf_plan_guru_r2r*(rank: cint, dims: ptr fftwf_iodim, howmany_rank: cint,
                         howmany_dims: ptr fftwf_iodim, inptr: ptr cdouble,
                         outptr: ptr cdouble, kind: ptr fftwf_r2r_kind,
                         flags: cuint): fftwf_plan {.cdecl,
    importc: "fftwf_plan_guru_r2r", dynlib: Fftw3Lib.}
proc fftwf_plan_guru64_r2r*(rank: cint, dims: ptr fftwf_iodim64,
                           howmany_rank: cint, howmany_dims: ptr fftwf_iodim64,
                           inptr: ptr cdouble, outptr: ptr cdouble,
                           kind: ptr fftwf_r2r_kind, flags: cuint): fftwf_plan {.
    cdecl, importc: "fftwf_plan_guru64_r2r", dynlib: Fftw3Lib.}

