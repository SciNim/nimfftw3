import zippy/[tarballs, ziparchives]
import
  std/[asyncdispatch, httpclient,
     strformat, strutils, os]

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

proc getProjectDir(): string {.compileTime.} =
  currentSourcePath.rsplit(DirSep, 1)[0]

proc onProgressChanged(total, progress, speed: BiggestInt) {.async.} =
  echo &"Downloaded {progress} of {total}"
  echo &"Current rate: {speed.float64 / (1000*1000):4.3f} MiBi/s" # TODO the unit is neither MB or Mb or MiBi ???

proc downloadTo(url, targetDir, filename: string) {.async.} =
  var client = newAsyncHttpClient()
  defer: client.close()
  client.onProgressChanged = onProgressChanged
  echo "Starting download of \"", url, '\"'
  echo "Storing temporary into: \"", targetDir, '\"'
  await client.downloadFile(url, targetDir / filename)

proc downloadLibFftw(url, targetDir, filename: string) =
  waitFor url.downloadTo(targetDir, filename)

proc uncompress(targetDir, filename: string, delete = false) =
  let tmp = targetDir / "tmp"
  if existsDir(tmp):
    removeDir(tmp)
  let (dir, name, fileExt) = filename.splitFile()
  if  fileExt == ".zip":
    ziparchives.extractAll(targetDir / filename, tmp)
  elif fileExt == ".gz":
    tarballs.extractAll(targetDir / filename, tmp)
  else:
    echo "Error : Unknown archive format. Should .zip or .tar.gz"
  copyDir(tmp, targetDir)
  removeDir(tmp)
  removeFile(targetDir / filename)

proc build(targetDir, filename: string) =
  when not defined(windows):
    if not symLinkExists(targetDir / "libs"):
      # Remove .tar.gz
      let (_, f, _) = filename.splitFile()
      let (_, filename, _) = f.splitFile()
      setFilePermissions(targetDir / filename / "configure", {fpUserExec, fpUserWrite, fpUserRead, fpGroupRead, fpOthersRead})
      discard execShellCmd("cd " & targetDir / filename & "; ./configure --enable-shared --enable-threads --with-combined-threads")
      discard execShellCmd("make -C " & targetDir / filename)
      createSymLink(targetDir / filename / ".libs", targetDir / "libs")
  else:
    createSymLink(targetDir / filename, targetDir / "libs")

when isMainModule:
  let (url, filename) = getUrlAndFilename()
  let target = getProjectDir().parentDir() / "vendor"
  downloadLibFftw(url, target, filename)
  uncompress(target, filename)
  build(target, filename)
