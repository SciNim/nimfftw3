import libutils

## FFTW Guru API for experts who knows what they're doing.

# Split Array API
proc fftw_execute_split_dft*(p: fftw_plan, ri: ptr cdouble, ii: ptr cdouble, ro: ptr cdouble, io: ptr cdouble) {.cdecl,
        importc: "fftw_execute_split_dft", dynlib: Fftw3Lib.}

proc fftw_execute_split_dft_r2c*(p: fftw_plan, inptr: ptr cdouble, ro: ptr cdouble, io: ptr cdouble) {.cdecl,
        importc: "fftw_execute_split_dft_r2c", dynlib: Fftw3Lib.}

proc fftw_execute_split_dft_c2r*(p: fftw_plan, ri: ptr cdouble, ii: ptr cdouble, outptr: ptr cdouble) {.cdecl,
        importc: "fftw_execute_split_dft_c2r", dynlib: Fftw3Lib.}


# FFTW "Guru" API
proc fftw_plan_guru_dft*(rank: cint, dims: ptr fftw_iodim, howmany_rank: cint,
                         howmany_dims: ptr fftw_iodim, inptr: ptr fftw_complex,
                         outptr: ptr fftw_complex, sign: cint, flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_guru_dft", dynlib: Fftw3Lib.}
proc fftw_plan_guru_split_dft*(rank: cint, dims: ptr fftw_iodim,
                               howmany_rank: cint, howmany_dims: ptr fftw_iodim,
                               ri: ptr cdouble, ii: ptr cdouble,
                               ro: ptr cdouble, io: ptr cdouble, flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_guru_split_dft", dynlib: Fftw3Lib.}
proc fftw_plan_guru64_dft*(rank: cint, dims: ptr fftw_iodim64,
                           howmany_rank: cint, howmany_dims: ptr fftw_iodim64,
                           inptr: ptr fftw_complex, outptr: ptr fftw_complex,
                           sign: cint, flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_guru64_dft", dynlib: Fftw3Lib.}
proc fftw_plan_guru64_split_dft*(rank: cint, dims: ptr fftw_iodim64,
                                 howmany_rank: cint,
                                 howmany_dims: ptr fftw_iodim64,
                                 ri: ptr cdouble, ii: ptr cdouble,
                                 ro: ptr cdouble, io: ptr cdouble, flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_guru64_split_dft", dynlib: Fftw3Lib.}
proc fftw_plan_guru_dft_r2c*(rank: cint, dims: ptr fftw_iodim,
                             howmany_rank: cint, howmany_dims: ptr fftw_iodim,
                             inptr: ptr cdouble, outptr: ptr fftw_complex,
                             flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_guru_dft_r2c", dynlib: Fftw3Lib.}
proc fftw_plan_guru_dft_c2r*(rank: cint, dims: ptr fftw_iodim,
                             howmany_rank: cint, howmany_dims: ptr fftw_iodim,
                             inptr: ptr fftw_complex, outptr: ptr cdouble,
                             flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_guru_dft_c2r", dynlib: Fftw3Lib.}
proc fftw_plan_guru_split_dft_r2c*(rank: cint, dims: ptr fftw_iodim,
                                   howmany_rank: cint,
                                   howmany_dims: ptr fftw_iodim,
                                   inptr: ptr cdouble, ro: ptr cdouble,
                                   io: ptr cdouble, flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_guru_split_dft_r2c", dynlib: Fftw3Lib.}
proc fftw_plan_guru_split_dft_c2r*(rank: cint, dims: ptr fftw_iodim,
                                   howmany_rank: cint,
                                   howmany_dims: ptr fftw_iodim,
                                   ri: ptr cdouble, ii: ptr cdouble,
                                   outptr: ptr cdouble, flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_guru_split_dft_c2r", dynlib: Fftw3Lib.}
proc fftw_plan_guru64_dft_r2c*(rank: cint, dims: ptr fftw_iodim64,
                               howmany_rank: cint,
                               howmany_dims: ptr fftw_iodim64,
                               inptr: ptr cdouble, outptr: ptr fftw_complex,
                               flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_guru64_dft_r2c", dynlib: Fftw3Lib.}
proc fftw_plan_guru64_dft_c2r*(rank: cint, dims: ptr fftw_iodim64,
                               howmany_rank: cint,
                               howmany_dims: ptr fftw_iodim64,
                               inptr: ptr fftw_complex, outptr: ptr cdouble,
                               flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_guru64_dft_c2r", dynlib: Fftw3Lib.}
proc fftw_plan_guru64_split_dft_r2c*(rank: cint, dims: ptr fftw_iodim64,
                                     howmany_rank: cint,
                                     howmany_dims: ptr fftw_iodim64,
                                     inptr: ptr cdouble, ro: ptr cdouble,
                                     io: ptr cdouble, flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_guru64_split_dft_r2c", dynlib: Fftw3Lib.}
proc fftw_plan_guru64_split_dft_c2r*(rank: cint, dims: ptr fftw_iodim64,
                                     howmany_rank: cint,
                                     howmany_dims: ptr fftw_iodim64,
                                     ri: ptr cdouble, ii: ptr cdouble,
                                     outptr: ptr cdouble, flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_guru64_split_dft_c2r", dynlib: Fftw3Lib.}

proc fftw_plan_guru_r2r*(rank: cint, dims: ptr fftw_iodim, howmany_rank: cint,
                         howmany_dims: ptr fftw_iodim, inptr: ptr cdouble,
                         outptr: ptr cdouble, kind: ptr fftw_r2r_kind,
                         flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_guru_r2r", dynlib: Fftw3Lib.}
proc fftw_plan_guru64_r2r*(rank: cint, dims: ptr fftw_iodim64,
                           howmany_rank: cint, howmany_dims: ptr fftw_iodim64,
                           inptr: ptr cdouble, outptr: ptr cdouble,
                           kind: ptr fftw_r2r_kind, flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_guru64_r2r", dynlib: Fftw3Lib.}

