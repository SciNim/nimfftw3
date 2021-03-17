import typetraits
import sequtils
import sugar

import arraymancer
import weave
###################################
## Tools
###################################
func getIndex*(offset: int, strides, shape: openArray[int], idx: varargs[int]): int {.noSideEffect, inline.} =
  result = offset
  for i in 0..<idx.len:
    result += strides[i]*idx[i]

func getShiftedIndex*(offset: int, strides, shape: openArray[int], shifts: openArray[int], idx: varargs[int]): int {.noSideEffect, inline.} =
  result = offset
  for i in 0..<idx.len:
    let newidx = (idx[i] + shifts[i]) mod shape[i]
    result += strides[i]*newidx

###################################
## Circshift
###################################
proc circshift1_weave[T](inBuf, outBuf: ptr UncheckedArray[T], offset: int, strides, shape: seq[int], shifts: seq[int]) =
  parallelFor i in 0..<shape[0]:
    captures: {inBuf, outBuf, offset, strides, shape, shifts}

    outBuf[getShiftedIndex(offset, strides, shape, shifts, i)] = inBuf[getIndex(offset, strides, shape, i)]

proc circshift2_weave[T](inBuf, outBuf: ptr UncheckedArray[T], offset: int, strides, shape: seq[int], shifts: seq[int]) =
  parallelFor i in 0..<shape[0]:
    captures: {inBuf, outBuf, offset, strides, shape, shifts}

    parallelFor j in 0..<shape[1]:
      captures: {inBuf, outBuf, offset, strides, shape, shifts, i}

      outBuf[getShiftedIndex(offset, strides, shape, shifts, i, j)] = inBuf[getIndex(offset, strides, shape, i, j)]

proc circshift3_weave[T](inBuf, outBuf: ptr UncheckedArray[T], offset: int, strides, shape: seq[int], shifts: seq[int]) =
  parallelFor i in 0..<shape[0]:
    captures: {inBuf, outBuf, offset, strides, shape, shifts}

    parallelFor j in 0..<shape[1]:
      captures: {inBuf, outBuf, offset, strides, shape, shifts, i}

      parallelFor k in 0..<shape[2]:
        captures: {inBuf, outBuf, offset, strides, shape, shifts, i, j}

        outBuf[getShiftedIndex(offset, strides, shape, shifts, i, j, k)] = inBuf[getIndex(offset, strides, shape, i, j, k)]

proc circshift4_weave[T](inBuf, outBuf: ptr UncheckedArray[T], offset: int, strides, shape: seq[int], shifts: seq[int]) =
  parallelFor i in 0..<shape[0]:
    captures: {inBuf, outBuf, offset, strides, shape, shifts}

    parallelFor j in 0..<shape[1]:
      captures: {inBuf, outBuf, offset, strides, shape, shifts, i}

      parallelFor k in 0..<shape[2]:
        captures: {inBuf, outBuf, offset, strides ,shape, shifts, i, j}

        parallelFor l in 0..<shape[3]:
          captures: {inBuf, outBuf, offset, strides, shape, shifts, i, j, k}

          outBuf[getShiftedIndex(offset, strides, shape, shifts, i, j, k, l)] = inBuf[getIndex(offset, strides, shape, i, j, k, l)]

proc circshift5_weave[T](inBuf, outBuf: ptr UncheckedArray[T], offset: int, strides, shape: seq[int], shifts: seq[int]) =
  parallelFor i in 0..<shape[0]:
    captures: {inBuf, outBuf, offset, strides, shape, shifts}

    parallelFor j in 0..<shape[1]:
      captures: {inBuf, outBuf, offset, strides, shape, shifts, i}

      parallelFor k in 0..<shape[2]:
        captures: {inBuf, outBuf, offset, strides, shape, shifts, i, j}

        parallelFor l in 0..<shape[3]:
          captures: {inBuf, outBuf, offset, strides, shape, shifts, i, j, k}

          parallelFor m in 0..<shape[4]:
            captures: {inBuf, outBuf, offset, strides, shape, shifts, i, j, k, l}

            outBuf[getShiftedIndex(offset, strides, shape, shifts, i, j, k, l, m)] = inBuf[getIndex(offset, strides, shape, i, j, k, l, m)]

proc circshift6_weave[T](inBuf, outBuf: ptr UncheckedArray[T], offset: int, strides, shape: seq[int], shifts: seq[int]) =
  parallelFor i in 0..<shape[0]:
    captures: {inBuf, outBuf, offset, strides, shape, shifts}

    parallelFor j in 0..<shape[1]:
      captures: {inBuf, outBuf, offset, strides, shape, shifts, i}

      parallelFor k in 0..<shape[2]:
        captures: {inBuf, outBuf, offset, strides, shape, shifts, i, j}

        parallelFor l in 0..<shape[3]:
          captures: {inBuf, outBuf, offset, strides, shape, shifts, i, j, k}

          parallelFor m in 0..<shape[4]:
            captures: {inBuf, outBuf, offset, strides, shape, shifts, i, j, k, l}

            parallelFor n in 0..<shape[5]:
              captures: {inBuf, outBuf, offset, strides, shape, shifts, i, j, k, l, m}

              outBuf[getShiftedIndex(offset, strides, shape, shifts, i, j, k, l, m, n)] = inBuf[getIndex(offset, strides, shape, i, j, k, l, m, n)]

proc circshift_weave[T](inBuf, outBuf: ptr UncheckedArray[T], offset: int, strides, shape: seq[int], shifts: seq[int]) =

  when not defined(WeaveCustomInit):
    init(Weave)

  case shifts.len
  of 1:
    circshift1_weave(inBuf, outBuf, offset, strides, shape, shifts)
  of 2:
    circshift2_weave(inBuf, outBuf, offset, strides, shape, shifts)
  of 3:
    circshift3_weave(inBuf, outBuf, offset, strides, shape, shifts)
  of 4:
    circshift4_weave(inBuf, outBuf, offset, strides, shape, shifts)
  of 5:
    circshift5_weave(inBuf, outBuf, offset, strides, shape, shifts)
  of 6:
    circshift6_weave(inBuf, outBuf, offset, strides, shape, shifts)
  else:
    raise newException(ValueError, "Can only supports tensor of rank 6")

  when not defined(WeaveCustomInit):
    exit(Weave)

proc fftshift_parallel*[T](t: Tensor[T]): Tensor[T] =
  ## fftshift implementation based on Weave.
  ## Use ``-d:WeaveCustomInit`` to indicate that weave is initialized (and finalized) manually outside this scope.
  let
    strides = t.strides.toSeq
    shape = t.shape.toSeq
    shifts = t.shape.toSeq.map(x => x div 2)
  # Alloc Tensor
  result = newTensor[T](shape)
  let
    ptrIn = t.unsafe_raw_offset().distinctBase()
    ptrOut = result.unsafe_raw_offset().distinctBase()

  circshift_weave[T](ptrIn, ptrOut, t.offset, strides, shape, shifts)

proc ifftshift_parallel*[T](t: Tensor[T]): Tensor[T] =
  ## ifftshift implementation based on Weave.
  ## Use ``-d:WeaveCustomInit`` flag to indicate that weave is initialized (and finalized) manually outside this scope.
  let
    strides = t.strides.toSeq
    shape = t.shape.toSeq
    shifts = t.shape.toSeq.map(x => (x+1) div 2)
  # Alloc Tensor
  result = newTensor[T](shape)
  let
    ptrIn = t.unsafe_raw_offset().distinctBase()
    ptrOut = result.unsafe_raw_offset().distinctBase()

  circshift_weave[T](ptrIn, ptrOut, t.offset, strides, shape, shifts)
