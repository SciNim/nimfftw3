import libutils

## FFTW Wisdom API for saving and restoring ``fftw_plan`` from disk.
## See `Wisdom documentation <http://www.fftw.org/fftw3_doc/Wisdom.html>`_ for more information.

proc fftw_forget_wisdom*() {.cdecl, importc: "fftw_forget_wisdom", dynlib: Fftw3Lib.}
proc fftw_export_wisdom_to_filename*(filename: cstring): cint {.cdecl, importc: "fftw_export_wisdom_to_filename",
        dynlib: Fftw3Lib.}
proc fftw_export_wisdom_to_file*(output_file: ptr FILE) {.cdecl, importc: "fftw_export_wisdom_to_file",
        dynlib: Fftw3Lib.}
proc fftw_export_wisdom_to_string*(): cstring {.cdecl, importc: "fftw_export_wisdom_to_string", dynlib: Fftw3Lib.}
proc fftw_export_wisdom*(write_char: fftw_write_char_func, data: pointer) {.cdecl, importc: "fftw_export_wisdom",
        dynlib: Fftw3Lib.}
proc fftw_import_system_wisdom*(): cint {.cdecl, importc: "fftw_import_system_wisdom", dynlib: Fftw3Lib.}
proc fftw_import_wisdom_from_filename*(filename: cstring): cint {.cdecl, importc: "fftw_import_wisdom_from_filename",
        dynlib: Fftw3Lib.}
proc fftw_import_wisdom_from_file*(input_file: ptr FILE): cint {.cdecl, importc: "fftw_import_wisdom_from_file",
        dynlib: Fftw3Lib.}
proc fftw_import_wisdom_from_string*(input_string: cstring): cint {.cdecl,
    importc: "fftw_import_wisdom_from_string", dynlib: Fftw3Lib.}
proc fftw_import_wisdom*(read_char: fftw_read_char_func, data: pointer): cint {.cdecl, importc: "fftw_import_wisdom",
    dynlib: Fftw3Lib.}

