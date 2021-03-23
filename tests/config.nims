switch("path", "$projectDir/../src")
switch("threads", "on")
when not defined(testing):
  switch("outdir", "tests/bin")
