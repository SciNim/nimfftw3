# Package
version       = "0.5.0"
author        = "rcaillaud"
description   = "Nim FFTW bindings"
license       = "LGPL-2.1"
installDirs   = @["install", "third_party/lib"]

# Dependencies

requires "nim >= 1.2.0"
requires "arraymancer >= 0.6.3"
requires "weave >= 0.4.9"
requires "zippy"

import os
task gendoc, "gen doc":
  exec("nimble doc --threads:on --project src/fftw3.nim --out:docs/")

task installfftw, "Install FFTW-3.3.9":
  selfExec("r -d:release install/fftwinstall.nim")

before install:
  echo "##################"
  installfftwTask()

before develop:
  installfftwTask()

