# FFTW3

![workflow](https://github.com/SciNim/fftw3/actions/workflows/ci.yml/badge.svg)

## Introduction

Nim bindings to the FFTW3 library, to compute Fourier transforms of various kinds with high performance.

## Installation

* Install FFTW3 library
  * ex: `sudo apt-get install fftw3 fftw3-devel`
  * ex: `sudo zypper install fftw3-devel`
  * There are different FFTW3 libraries compiled with different options, the bindings should work with all of them. If it does not, open an issue and I'll look into it.
* Install the bindings `nimble install fftw3` 
To generate the documentation locally use ``nimble doc --project src/fftw3.nim --out:docs/`` or ``nimble gendoc``

Note that FFTW3 is untested for Windows but a Windows version exists. 

## Usage

### Documentations

API Documentations with some : https://scinim.github.io/nimfftw3/

FFTW3 official documentation : http://www.fftw.org/fftw3_doc/

### Example

## Contributing and evolution

Any help and contribution is welcome !

As much as possible, breaking change in API should be avoided.
Improving documentation and providing better high-level API are the focus for now.

## History

These bindings were originally generated here : https://github.com/ziotom78/nimfftw3/blob/master/fftw3.nim

## License

These bindings are released under a LGPL license. FFTW3 is released under a GPLv2 or above license.
