# Package

version       = "0.4.7"
author        = "rcaillaud"
description   = "Nim FFTW bindings"
license       = "LGPL-2.1"
srcDir        = "src"


# Dependencies

requires "nim >= 1.2.0"
requires "arraymancer >= 0.6.3"
requires "weave >= 0.4.9"

task gendoc, "gen doc":
  exec("nimble doc --project src/fftw3.nim --out:docs/")

import distros
task externalDep, "package":
  when defined(nimdistros):
    if detectOs(Ubuntu) or detectOs(Debian) or detectOs(OpenSUSE):
      foreignDep "fftw3-dev"
      foreignDep "fftw3-threads-dev"
    echo "Install libfftw3 using a package manager : "
    echoForeignDeps()

after install:
  externalDepTask()

after develop:
  externalDepTask()
