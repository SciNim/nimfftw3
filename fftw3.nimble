# Package
version       = "0.5.2"
author        = "rcaillaud"
description   = "Nim FFTW bindings"
license       = "LGPL-2.1"
installDirs   = @["third_party"]

# Dependencies

requires "nim >= 1.2.0"
requires "arraymancer >= 0.6.3"
requires "zippy"
# requires "weave >= 0.4.9"

import os
task gendoc, "gen doc":
  exec("nimble doc --threads:on --project fftw3.nim -d:localFftw3 --out:docs/")
