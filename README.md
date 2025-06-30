# FFTW3

![workflow](https://github.com/SciNim/nimfftw3/actions/workflows/ci.yml/badge.svg)
![workflow](https://github.com/SciNim/nimfftw3/actions/workflows/docs.yml/badge.svg)

## Introduction

Nim bindings to the FFTW3 library, to compute Fourier transforms of various kinds with high performance.


## Installing FFTW

### On Linux

FFTW3 is available on most Linux distributions.

```
# install dependencies

$ sudo apt install fftw3      # debian/ubuntu
$ sudo pacman -S fftw3        # arch
$ sudo yum install fftw3-libs # fedora

# install nimfftw3

nimble install fftw3

```

Note: Arch and Debian place their threaded fftw into `libfftw3_thread.so`, Fedora in `libfftw3.so`. Both work fine.

### On OSX

Use the homebrew package system and nimble.

```
# install dependency
brew install fftw

# install nim package
$ nimble install fftw3

```

Note: Less tested than linux

### On Windows 

Install the binary dependency manually

* Download ftp://ftp.fftw.org/pub/fftw/fftw-3.3.5-dll64.zip
* Uncompress in a location known to Windows, e.g. the same directory as your Nim binary program

```
REM install the package
nimble install fftw3
```

Note: Less tested than linux


```nimble install fftw3```

## From source

You can build FFTW from source with more control over parameters on linux, osx via xcode command line tools, and windows via mingw.

```
$ wget http://www.fftw.org/fftw-3.3.9.tar.gz
$ tar -xvzf fftw-3.3.9.tar.gz

# required flags for use with nimfftw3
./configure --enable-shared --enable-threads --with-combined-threads
make
sudo make install 

# nimble package
nimble install fftw3

```

## Usage

### Documentations

API Documentations with some examples : https://scinim.github.io/nimfftw3/

FFTW3 official documentation : http://www.fftw.org/fftw3_doc/

To generate the bindings documentation use :
* ``nimble develop``
* ``nimble gendoc``

### Example

See `tests/testall.nim` for example of FFT using Seq and Tensor, or `tests/testfloat.nim` for the `float32` version.

### FFTW3 facts that will surprise you 

All this is written in the documentation and FFTW's FAQ (http://www.fftw.org/faq/section3.html) but it's not intuitive so I'll write it here. 

> Question 3.8. FFTW gives different results between runs
 If you use FFTW_MEASURE or FFTW_PATIENT mode, then the algorithm FFTW employs is not deterministic: it depends on runtime performance measurements. This will cause the results to vary slightly from run to run. However, the differences should be slight, on the order of the floating-point precision, and therefore should have no practical impact on most applications.

 If you use saved plans (wisdom) or FFTW_ESTIMATE mode, however, then the algorithm is deterministic and the results should be identical between runs.

>  Question 3.10. Why does your inverse transform return a scaled result?
Computing the forward transform followed by the backward transform (or vice versa) yields the original array scaled by the size of the array. (For multi-dimensional transforms, the size of the array is the product of the dimensions.) We could, instead, have chosen a normalization that would have returned the unscaled array. Or, to accomodate the many conventions in this matter, the transform routines could have accepted a "scale factor" parameter. We did not do this, however, for two reasons. First, we didn't want to sacrifice performance in the common case where the scale factor is 1. Second, in real applications the FFT is followed or preceded by some computation on the data, into which the scale factor can typically be absorbed at little or no cost. 

## Contributing and evolution

Any help and contribution is welcome !

As much as possible, breaking change in API should be avoided.
Improving documentation and providing better high-level API are the focus for now.

nimfftw3 supports float64 and float32. Other formats are possible but would require a patch.

## History

These bindings were originally generated here : https://github.com/ziotom78/nimfftw3/blob/master/fftw3.nim

## License

These bindings are released under a LGPL license. FFTW3 is released under a GPLv2 or above license.
