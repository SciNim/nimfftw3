Nim bindings to the FFTW3 library.

Set of Nim bindings to the excellent FFTW library, to compute Fourier transforms of various kinds.

I generated these bindings in a hurry because I needed them for a project of mine. Therefore, only the functions that use double values have been implemented (no float or long double functions, sorry -- by the way, at the time of writing, the long double type is not yet supported by Nim).

Warning: This repository is currently archived, as I am no longer interested in Nim.
Documentation

No documentation, sorry. The bindings are very tiny, so if you're accustomed with the C interface of FFTW, you're going to have no problems.
Examples

A very short example about how to use these bindings is provided at the end of fftw3.nim.
License

These bindings are released under a MIT license, but since the FFTW library is covered by a GPL license, any program you'll write which use these bindings will need to be released under GPL, as this link explains: http://www.gnu.org/licenses/gpl-faq.html#GPLWrapper.
