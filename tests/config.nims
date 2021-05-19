switch("path", "$projectDir/../src")
switch("threads", "on")
# switch("define", "Fftw3Lib=libfftw3.so.3")
when not defined(testing):
  switch("outdir", "tests/bin")
