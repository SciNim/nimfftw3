# Package

version       = "0.5.0"
author        = "rcaillaud"
description   = "Nim FFTW bindings"
license       = "LGPL-2.1"
installDirs   = @["vendor"]


# Dependencies

requires "nim >= 1.2.0"
requires "arraymancer >= 0.6.3"
requires "weave >= 0.4.9"
requires "zippy"

task gendoc, "gen doc":
  exec("nimble doc --threads:on --project src/fftw3.nim --out:docs/")

task installFftw, "Build and install a local copy of FFTW":
  selfExec("r install/fftw_installer.nim")

after install:
  installFftwTask()

after develop:
  installFftwTask()
