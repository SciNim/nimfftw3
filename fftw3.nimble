# Package

version       = "0.4.3"
author        = "rcaillaud"
description   = "Nim FFTW bindings"
license       = "LGPL-2.1"
srcDir        = "src"


# Dependencies

requires "nim >= 1.2.0"
requires "arraymancer >= 0.6.1"
requires "weave#master"

task gendoc, "gen doc":
  exec("nimble doc --project src/fftw3.nim --out:docs/")

task externalDep, "package":
  when defined(nimdistros):
    import distros
    if detectOs(Ubuntu) or detectOs(Debian):
      foreignDep "fftw3-dev"
    elif detectOs(OpenSUSE):
      foreignDep "fftw3-devel"
    echoForeignDeps()

after install:
  externalDepTask()

after develop:
  externalDepTask()
