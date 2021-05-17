# Package

version       = "0.5.0"
author        = "rcaillaud"
description   = "Nim FFTW bindings"
license       = "LGPL-2.1"


# Dependencies

requires "nim >= 1.2.0"
requires "arraymancer >= 0.6.3"
requires "weave >= 0.4.9"

task gendoc, "gen doc":
  exec("nimble doc --threads:on --project src/fftw3.nim --out:docs/")


