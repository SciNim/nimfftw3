import libutils

## FFTW Wisdom API for saving and restoring ``fftwf_plan`` from disk.
## See `Wisdom documentation <http://www.ffwf.org/ffwf3_doc/Wisdom.html>`_ for more information.

proc fftwf_forget_wisdom*() {.cdecl, importc: "fftwf_forget_wisdom", dynlib: Fftw3Lib.}
proc fftwf_export_wisdom_to_filename*(filename: cstring): cint {.cdecl, importc: "fftwf_export_wisdom_to_filename",
        dynlib: Fftw3Lib.}
proc fftwf_export_wisdom_to_file*(output_file: ptr FILE) {.cdecl, importc: "fftwf_export_wisdom_to_file",
        dynlib: Fftw3Lib.}
proc fftwf_export_wisdom_to_string*(): cstring {.cdecl, importc: "fftwf_export_wisdom_to_string", dynlib: Fftw3Lib.}
proc fftwf_export_wisdom*(write_char: fftwf_write_char_func, data: pointer) {.cdecl, importc: "fftwf_export_wisdom",
        dynlib: Fftw3Lib.}
proc fftwf_import_system_wisdom*(): cint {.cdecl, importc: "fftwf_import_system_wisdom", dynlib: Fftw3Lib.}
proc fftwf_import_wisdom_from_filename*(filename: cstring): cint {.cdecl, importc: "fftwf_import_wisdom_from_filename",
        dynlib: Fftw3Lib.}
proc fftwf_import_wisdom_from_file*(input_file: ptr FILE): cint {.cdecl, importc: "fftwf_import_wisdom_from_file",
        dynlib: Fftw3Lib.}
proc fftwf_import_wisdom_from_string*(input_string: cstring): cint {.cdecl,
    importc: "fftwf_import_wisdom_from_string", dynlib: Fftw3Lib.}
proc fftwf_import_wisdom*(read_char: fftwf_read_char_func, data: pointer): cint {.cdecl, importc: "fftwf_import_wisdom",
    dynlib: Fftw3Lib.}

