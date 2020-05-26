# Bindings to the FFTW3 library generated automatically by Maurizio
# Tomasi using c2nim

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

import complex

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
  # No need to define fftw_complex as an array
  #fftw_complex* = array[2, cdouble]
  fftw_complex* = Complex64
  fftw_plan* = pointer

proc fftw_execute*(p: fftw_plan) {.cdecl, importc: "fftw_execute",
                                   dynlib: LibraryName.}
proc fftw_plan_dft*(rank: cint; n: ptr cint; `in`: ptr fftw_complex;
                    `out`: ptr fftw_complex; sign: cint; flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_dft", dynlib: LibraryName.}
proc fftw_plan_dft_1d*(n: cint; `in`: ptr fftw_complex; `out`: ptr fftw_complex;
                       sign: cint; flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_dft_1d", dynlib: LibraryName.}
proc fftw_plan_dft_2d*(n0: cint; n1: cint; `in`: ptr fftw_complex;
                       `out`: ptr fftw_complex; sign: cint; flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_dft_2d", dynlib: LibraryName.}
proc fftw_plan_dft_3d*(n0: cint; n1: cint; n2: cint; `in`: ptr fftw_complex;
                       `out`: ptr fftw_complex; sign: cint; flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_dft_3d", dynlib: LibraryName.}

proc fftw_plan_many_dft*(rank: cint; n: ptr cint; howmany: cint;
                         `in`: ptr fftw_complex; inembed: ptr cint;
                         istride: cint; idist: cint; `out`: ptr fftw_complex;
                         onembed: ptr cint; ostride: cint; odist: cint;
                         sign: cint; flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_many_dft", dynlib: LibraryName.}

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

proc fftw_execute_dft*(p: fftw_plan; `in`: ptr fftw_complex;
                       `out`: ptr fftw_complex) {.cdecl,
    importc: "fftw_execute_dft", dynlib: LibraryName.}
proc fftw_execute_split_dft*(p: fftw_plan; ri: ptr cdouble; ii: ptr cdouble;
                             ro: ptr cdouble; io: ptr cdouble) {.cdecl,
    importc: "fftw_execute_split_dft", dynlib: LibraryName.}

proc fftw_plan_many_dft_r2c*(rank: cint; n: ptr cint; howmany: cint;
                             `in`: ptr cdouble; inembed: ptr cint;
                             istride: cint; idist: cint;
                             `out`: ptr fftw_complex; onembed: ptr cint;
                             ostride: cint; odist: cint; flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_many_dft_r2c", dynlib: LibraryName.}

proc fftw_plan_dft_r2c*(rank: cint; n: ptr cint; `in`: ptr cdouble;
                        `out`: ptr fftw_complex; flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_dft_r2c", dynlib: LibraryName.}
proc fftw_plan_dft_r2c_1d*(n: cint; `in`: ptr cdouble; `out`: ptr fftw_complex;
                           flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_dft_r2c_1d", dynlib: LibraryName.}
proc fftw_plan_dft_r2c_2d*(n0: cint; n1: cint; `in`: ptr cdouble;
                           `out`: ptr fftw_complex; flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_dft_r2c_2d", dynlib: LibraryName.}
proc fftw_plan_dft_r2c_3d*(n0: cint; n1: cint; n2: cint; `in`: ptr cdouble;
                           `out`: ptr fftw_complex; flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_dft_r2c_3d", dynlib: LibraryName.}

proc fftw_plan_many_dft_c2r*(rank: cint; n: ptr cint; howmany: cint;
                             `in`: ptr fftw_complex; inembed: ptr cint;
                             istride: cint; idist: cint; `out`: ptr cdouble;
                             onembed: ptr cint; ostride: cint; odist: cint;
                             flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_many_dft_c2r", dynlib: LibraryName.}

proc fftw_plan_dft_c2r*(rank: cint; n: ptr cint; `in`: ptr fftw_complex;
                        `out`: ptr cdouble; flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_dft_c2r", dynlib: LibraryName.}
proc fftw_plan_dft_c2r_1d*(n: cint; `in`: ptr fftw_complex; `out`: ptr cdouble;
                           flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_dft_c2r_1d", dynlib: LibraryName.}
proc fftw_plan_dft_c2r_2d*(n0: cint; n1: cint; `in`: ptr fftw_complex;
                           `out`: ptr cdouble; flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_dft_c2r_2d", dynlib: LibraryName.}
proc fftw_plan_dft_c2r_3d*(n0: cint; n1: cint; n2: cint; `in`: ptr fftw_complex;
                           `out`: ptr cdouble; flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_dft_c2r_3d", dynlib: LibraryName.}

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

proc fftw_execute_dft_r2c*(p: fftw_plan; `in`: ptr cdouble;
                           `out`: ptr fftw_complex) {.cdecl,
    importc: "fftw_execute_dft_r2c", dynlib: LibraryName.}
proc fftw_execute_dft_c2r*(p: fftw_plan; `in`: ptr fftw_complex;
                           `out`: ptr cdouble) {.cdecl,
    importc: "fftw_execute_dft_c2r", dynlib: LibraryName.}

proc fftw_execute_split_dft_r2c*(p: fftw_plan; `in`: ptr cdouble;
                                 ro: ptr cdouble; io: ptr cdouble) {.cdecl,
    importc: "fftw_execute_split_dft_r2c", dynlib: LibraryName.}
proc fftw_execute_split_dft_c2r*(p: fftw_plan; ri: ptr cdouble; ii: ptr cdouble;
                                 `out`: ptr cdouble) {.cdecl,
    importc: "fftw_execute_split_dft_c2r", dynlib: LibraryName.}
proc fftw_plan_many_r2r*(rank: cint; n: ptr cint; howmany: cint;
                         `in`: ptr cdouble; inembed: ptr cint; istride: cint;
                         idist: cint; `out`: ptr cdouble; onembed: ptr cint;
                         ostride: cint; odist: cint; kind: ptr fftw_r2r_kind;
                         flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_many_r2r", dynlib: LibraryName.}

proc fftw_plan_r2r*(rank: cint; n: ptr cint; `in`: ptr cdouble;
                    `out`: ptr cdouble; kind: ptr fftw_r2r_kind; flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_r2r", dynlib: LibraryName.}
proc fftw_plan_r2r_1d*(n: cint; `in`: ptr cdouble; `out`: ptr cdouble;
                       kind: fftw_r2r_kind; flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_r2r_1d", dynlib: LibraryName.}
proc fftw_plan_r2r_2d*(n0: cint; n1: cint; `in`: ptr cdouble;
                       `out`: ptr cdouble; kind0: fftw_r2r_kind;
                       kind1: fftw_r2r_kind; flags: cuint): fftw_plan {.cdecl,
    importc: "fftw_plan_r2r_2d", dynlib: LibraryName.}
proc fftw_plan_r2r_3d*(n0: cint; n1: cint; n2: cint; `in`: ptr cdouble;
                       `out`: ptr cdouble; kind0: fftw_r2r_kind;
                       kind1: fftw_r2r_kind; kind2: fftw_r2r_kind; flags: cuint): fftw_plan {.
    cdecl, importc: "fftw_plan_r2r_3d", dynlib: LibraryName.}

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
proc fftw_execute_r2r*(p: fftw_plan; `in`: ptr cdouble; `out`: ptr cdouble) {.
    cdecl, importc: "fftw_execute_r2r", dynlib: LibraryName.}
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

################################################################################

import arraymancer
import sequtils

proc fftw_plan_dft*(input: Tensor[fftw_complex], output: Tensor[fftw_complex], sign: cint, flags: cuint = FFTW_MEASURE): fftw_plan=
  let shape : seq[cint] = map(input.shape.toSeq, proc(x: int): cint= x.cint)
  result = fftw_plan_dft(input.rank.cint, (shape[0].unsafeaddr), input.get_data_ptr, output.get_data_ptr,sign, flags)

proc fftw_plan_dft_1d*(input: Tensor[fftw_complex], output: Tensor[fftw_complex], sign: cint, flags: cuint = FFTW_MEASURE): fftw_plan=
  assert(input.rank == 1)
  let shape : seq[cint] = map(input.shape.toSeq, proc(x: int): cint= x.cint)
  result = fftw_plan_dft_1d(shape[0], input.get_data_ptr, output.get_data_ptr,sign, flags)


proc fftw_plan_dft_2d*(input: Tensor[fftw_complex], output: Tensor[fftw_complex], sign: cint, flags: cuint = FFTW_MEASURE): fftw_plan=
  assert(input.rank == 2)
  let shape : seq[cint] = map(input.shape.toSeq, proc(x: int): cint= x.cint)
  result = fftw_plan_dft_2d(shape[0], shape[1], input.get_data_ptr, output.get_data_ptr,sign, flags)

proc fftw_plan_dft_3d*(input: Tensor[fftw_complex], output: Tensor[fftw_complex], sign: cint, flags: cuint = FFTW_MEASURE): fftw_plan=
  assert(input.rank == 3)
  let shape : seq[cint] = map(input.shape.toSeq, proc(x: int): cint= x.cint)
  result = fftw_plan_dft_3d(shape[0], shape[1], shape[2], input.get_data_ptr, output.get_data_ptr,sign, flags)

proc fftw_plan_dft_r2c*(input: Tensor[float64], output: Tensor[fftw_complex], flags: cuint = FFTW_MEASURE): fftw_plan=
  let shape : seq[cint] = map(input.shape.toSeq, proc(x: int): cint= x.cint)
  result = fftw_plan_dft_r2c(input.rank.cint, (shape[0].unsafeaddr), cast[ptr cdouble](input.get_data_ptr), output.get_data_ptr, flags)

proc fftw_plan_dft_r2c_1d*(input: Tensor[float64], output: Tensor[fftw_complex], flags: cuint = FFTW_MEASURE): fftw_plan=
  assert(input.rank == 1)
  let shape : seq[cint] = map(input.shape.toSeq, proc(x: int): cint= x.cint)
  result = fftw_plan_dft_r2c_1d(shape[0], cast[ptr cdouble](input.get_data_ptr), output.get_data_ptr, flags)

proc fftw_plan_dft_r2c_2d*(input: Tensor[float64], output: Tensor[fftw_complex], flags: cuint = FFTW_MEASURE): fftw_plan=
  assert(input.rank == 2)
  let shape : seq[cint] = map(input.shape.toSeq, proc(x: int): cint= x.cint)
  result = fftw_plan_dft_r2c_2d(shape[0], shape[1], cast[ptr cdouble](input.get_data_ptr), output.get_data_ptr, flags)

proc fftw_plan_dft_r2c_3d*(input: Tensor[float64], output: Tensor[fftw_complex], flags: cuint = FFTW_MEASURE): fftw_plan=
  assert(input.rank == 3)
  let shape : seq[cint] = map(input.shape.toSeq, proc(x: int): cint= x.cint)
  result = fftw_plan_dft_r2c_3d(shape[0], shape[1], shape[2], cast[ptr cdouble](input.get_data_ptr), output.get_data_ptr, flags)

proc fftw_plan_dft_c2r*(input: Tensor[fftw_complex], output: Tensor[float64], flags: cuint = FFTW_MEASURE): fftw_plan=
  let shape : seq[cint] = map(input.shape.toSeq, proc(x: int): cint= x.cint)
  result = fftw_plan_dft_c2r(input.rank.cint, (shape[0].unsafeaddr), input.get_data_ptr, cast[ptr cdouble](output.get_data_ptr), flags)

proc fftw_plan_dft_c2r_1d*(input: Tensor[fftw_complex], output: Tensor[float64], flags: cuint = FFTW_MEASURE): fftw_plan=
  assert(input.rank == 1)
  let shape : seq[cint] = map(input.shape.toSeq, proc(x: int): cint= x.cint)
  result = fftw_plan_dft_c2r_1d(shape[0], input.get_data_ptr, cast[ptr cdouble](output.get_data_ptr), flags)

proc fftw_plan_dft_c2r_2d*(input: Tensor[fftw_complex], output: Tensor[float64], flags: cuint = FFTW_MEASURE): fftw_plan=
  assert(input.rank == 2)
  let shape : seq[cint] = map(input.shape.toSeq, proc(x: int): cint= x.cint)
  result = fftw_plan_dft_c2r_2d(shape[0], shape[1], input.get_data_ptr, cast[ptr cdouble](output.get_data_ptr), flags)

proc fftw_plan_dft_c2r_3d*(input: Tensor[fftw_complex], output: Tensor[float64], flags: cuint = FFTW_MEASURE): fftw_plan=
  assert(input.rank == 3)
  let shape : seq[cint] = map(input.shape.toSeq, proc(x: int): cint= x.cint)
  result = fftw_plan_dft_c2r_3d(shape[0], shape[1], shape[2], input.get_data_ptr, cast[ptr cdouble](output.get_data_ptr), flags)

proc fftw_plan_r2r_1d*(input: Tensor[float64], output: Tensor[float64], kind: fftw_r2r_kind, flags: cuint = FFTW_MEASURE): fftw_plan=
  assert(input.rank == 1)
  let shape : seq[cint] = map(input.shape.toSeq, proc(x: int): cint= x.cint)
  result = fftw_plan_r2r_1d(shape[0], cast[ptr cdouble](input.get_data_ptr), cast[ptr cdouble](output.get_data_ptr), kind, flags)

proc fftw_plan_r2r_2d*(input: Tensor[float64], output: Tensor[float64], kinds: seq[fftw_r2r_kind], flags: cuint = FFTW_MEASURE): fftw_plan=
  assert(input.rank == 2)
  let shape : seq[cint] = map(input.shape.toSeq, proc(x: int): cint= x.cint)
  result = fftw_plan_r2r_2d(shape[0], shape[1], cast[ptr cdouble](input.get_data_ptr), cast[ptr cdouble](output.get_data_ptr), kinds[0], kinds[1], flags)

proc fftw_plan_r2r_3d*(input: Tensor[float64], output: Tensor[float64], kinds: seq[fftw_r2r_kind], flags: cuint = FFTW_MEASURE): fftw_plan=
  assert(input.rank == 3)
  let shape : seq[cint] = map(input.shape.toSeq, proc(x: int): cint= x.cint)
  result = fftw_plan_r2r_3d(shape[0], shape[1], shape[2], cast[ptr cdouble](input.get_data_ptr), cast[ptr cdouble](output.get_data_ptr), kinds[0], kinds[1], kinds[2], flags)

proc fftw_plan_r2r*(input: Tensor[float64], output: Tensor[float64], kinds: seq[fftw_r2r_kind], flags: cuint = FFTW_MEASURE): fftw_plan=
  let shape : seq[cint] = map(input.shape.toSeq, proc(x: int): cint= x.cint)
  result = fftw_plan_r2r(input.rank.cint, shape[0].unsafeaddr, cast[ptr cdouble](input.get_data_ptr), cast[ptr cdouble](output.get_data_ptr), kinds[0].unsafeaddr, flags)

proc fftw_execute_dft*(p: fftw_plan, input: Tensor[fftw_complex], output: Tensor[fftw_complex])=
  fftw_execute_dft(p, input.get_data_ptr, output.get_data_ptr)

proc fftw_execute_dft_r2c*(p: fftw_plan, input: Tensor[float64], output: Tensor[fftw_complex])=
  fftw_execute_dft_r2c(p, cast[ptr cdouble](input.get_data_ptr), output.get_data_ptr)

proc fftw_execute_dft_c2r*(p: fftw_plan, input: Tensor[fftw_complex],   output: Tensor[float64])=
  fftw_execute_dft_c2r(p, input.get_data_ptr, cast[ptr cdouble](output.get_data_ptr))

