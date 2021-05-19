import std/os
import installer

proc getUrlAndFilename() : tuple[url, filename: string] =
  when defined(windows):
    result.url = "ftp://ftp.fftw.org/pub/fftw/fftw-3.3.5-dll64.zip"
    result.filename = "fftw-3.3.5-dll64.zip"
  elif defined(macosx):
    # TODO test this
    result.url = "http://www.fftw.org/fftw-3.3.9.tar.gz"
    result.filename = "fftw-3.3.9.tar.gz"
  else:
    result.url = "http://www.fftw.org/fftw-3.3.9.tar.gz"
    result.filename = "fftw-3.3.9.tar.gz"

proc buildFftw(targetDir, filename: string) =
  when not defined(windows):
    # Remove .tar.gz
    let (_, f, _) = filename.splitFile()
    let (_, filename, _) = f.splitFile()
    if not dirExists(targetDir / filename):
      setFilePermissions(targetDir / filename / "configure", {fpUserExec, fpUserWrite, fpUserRead, fpGroupRead, fpOthersRead})
      discard execShellCmd("cd " & targetDir / filename & "; ./configure --enable-shared --enable-threads --with-combined-threads")
      discard execShellCmd("make -C " & targetDir / filename)
    copyDirWithPermissions(targetDir / filename / ".libs", targetDir / "lib")
  else:
    copyDirWithPermissions(targetDir / filename / ".libs", targetDir / "lib")

proc downloadBuildFftw*() =
  let (url, filename) = getUrlAndFilename()
  let target = getProjectDir().parentDir() / "third_party"
  if not fileExists(target / filename):
    downloadUrl(url, target, filename)
    uncompress(target, filename, false)
  if not dirExists(target / "lib"):
    buildFftw(target, filename)

when isMainModule:
  downloadBuildFftw()
