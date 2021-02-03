import arraymancer
import arraymancer/tensor/private/p_accessors
import sequtils

proc get2DCoord(index: int, Nx, Ny: int): array[2, int] {.inline.} =
  var index = index
  result[0] = index div Ny
  index = index - result[0]*Ny
  result[1] = index

proc get3DCoord(index: int, Nx, Ny, Nz: int): array[3, int] {.inline.} =
  var index = index
  result[0] = index div (Nz*Ny)
  index = index - result[0]*Nz*Ny
  result[1] = index div Nz
  index = index - result[1]*Nz
  result[2] = index

proc get2DCoord[T](index: int, t: Tensor[T]): array[2, int] {.inline.} =
  doAssert t.rank == 2
  let Nx = t.shape[0]
  let Ny = t.shape[1]
  result = get2DCoord(index, Nx, Ny)

proc get3DCoord[T](index: int, t: Tensor[T]): array[3, int] {.inline.} =
  doAssert t.rank == 3
  let Nx = t.shape[0]
  let Ny = t.shape[1]
  let Nz = t.shape[2]
  result = get3DCoord(index, Nx, Ny, Nz)

proc I(coord: openArray[int]): int {.inline.} =
  return coord[0]

proc J(coord: openArray[int]): int {.inline.} =
  return coord[1]

proc K(coord: openArray[int]): int {.inline.} =
  return coord[2]

# FFT Shift
proc circshift_impl[T](t: Tensor[T], xshift: int, yshift: int, zshift: int): Tensor[T] =
  assert(t.rank == 3)
  let
    X = t.shape[0]
    Y = t.shape[1]
    Z = t.shape[2]
  result = newTensor[T](X, Y, Z)
  for idx in 0||(result.size-1):
    let
      coord = idx.get3DCoord(result)
      ii = (coord.I + xshift) mod X
      jj = (coord.J + xshift) mod X
      kk = (coord.K + xshift) mod X
    result[ii, jj, kk] = t[coord.I, coord.J, coord.K]

proc circshift_impl[T](t: Tensor[T], xshift: int, yshift: int): Tensor[T] =
  assert(t.rank == 2)
  let
    X = t.shape[0]
    Y = t.shape[1]
  result = newTensor[T](X, Y)
  for idx in 0||(result.size-1):
    let
      coord = idx.get2DCoord(result)
      ii = (coord.I + xshift) mod X
      jj = (coord.J + xshift) mod X
    result[ii, jj] = t[coord.I, coord.J]

proc circshift_impl[T](t: Tensor[T], xshift: int): Tensor[T] =
  assert(t.rank == 1)
  var X = t.shape[0]

  result = newTensor[T](t.shape.toSeq)
  for i in 0||(X-1):
    var ii = (i + xshift) mod X
    result[ii] = t[i]

# TODO : Generic implementation in parallel
proc circshift_impl[T](t: Tensor[T], shift: seq[int]): Tensor[T] =
  let shape = t.shape.toSeq
  result = newTensor[T](t.shape.toSeq)
  for coord, values in t:
    var newcoord: seq[int] = newSeq[int](t.rank)
    for i in 0..<t.rank:
      newcoord[i] = (coord[i]+shift[i]) mod shape[i]
    result.atIndexMut(newcoord, values)

proc circshift*[T](t: Tensor[T], shift: seq[int]): Tensor[T] =
  ## Generic Circshift
  assert(t.rank == shift.len)
  case t.rank
  of 1:
    result = circshift_impl(t, shift[0])
  of 2:
    result = circshift_impl(t, shift[0], shift[1])
  of 3:
    result = circshift_impl(t, shift[0], shift[1], shift[2])
  else:
    result = circshift_impl(t, shift)

proc fftshift*[T](t: Tensor[T]): Tensor[T] =
  ## Common fftshift function. Use Nim's openMP operator (`||`) for rank <= 3
  runnableExamples:
    import arraymancer
    let input_tensor = randomTensor[float64](10, 10, 10, 10.0)
    # output_tensor is the fftshift of input_tensor
    var output_tensor = fftshift(input_tensor)

  # Calculate fftshift using circshift
  let xshift = t.shape[0] div 2
  let yshift = t.shape[1] div 2
  let zshift = t.shape[2] div 2
  result = circshift(t, @[xshift.int, yshift.int, zshift.int])

proc ifftshift*[T](t: Tensor[T]): Tensor[T] =
  ## Common ifftshift function. Use Nim's openMP operator (`||`) for rank <= 3
  runnableExamples:
    import arraymancer
    let input_tensor = randomTensor[float64](10, 10, 10, 10.0)
    # output_tensor is the fftshift of input_tensor
    var output_tensor = ifftshift(input_tensor)

  # Calculate inverse fftshift using circshift
  let xshift = (t.shape[0]+1) div 2
  let yshift = (t.shape[1]+1) div 2
  let zshift = (t.shape[2]+1) div 2
  result = circshift(t, @[xshift.int, yshift.int, zshift.int])

