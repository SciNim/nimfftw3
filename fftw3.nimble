# Package

version       = "0.3.0"
author        = "rcaillaud"
description   = "Nim FFTW bindings"
license       = "LGPL-2.1"
srcDir        = "src"


# Dependencies

requires "nim >= 1.2.0"
requires "arraymancer >= 0.6.1"

task htmldoc, "generate doc":
  selfExec("doc --project src/fftw3.nim")
