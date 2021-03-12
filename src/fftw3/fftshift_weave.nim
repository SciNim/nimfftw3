import typetraits
import sequtils
import sugar

import arraymancer
import weave
###################################
## Tools
###################################
type
  Metadata = tuple[offset: int, strides, shape: seq[int]]

func getMeta[T](t: Tensor[T]): Metadata =
  result.offset = t.offset
  result.strides = t.strides.toSeq
  result.shape = t.shape.toSeq

func getIndex*(m: Metadata, idx: varargs[int]): int {.noSideEffect, inline.} =
  result = m.offset
  for i in 0..<idx.len:
    result += m.strides[i]*idx[i]

func getShiftedIndex*(m: Metadata, shifts: openArray[int], idx: varargs[int]): int {.noSideEffect, inline.} =
  result = m.offset
  for i in 0..<idx.len:
    let newidx = (idx[i] + shifts[i]) mod m.shape[i]
    result += m.strides[i]*newidx

###################################
## Circshift
###################################
proc circshift1_weave[T](inBuf, outBuf: ptr UncheckedArray[T], meta: Metadata, shifts: seq[int]) =
  parallelFor i in 0..<meta.shape[0]:
    captures: {inBuf, outBuf, meta, shifts}

    outBuf[getShiftedIndex(meta, shifts, i)] = inBuf[getIndex(meta, i)]

proc circshift2_weave[T](inBuf, outBuf: ptr UncheckedArray[T], meta: Metadata, shifts: seq[int]) =
  parallelFor i in 0..<meta.shape[0]:
    captures: {inBuf, outBuf, meta, shifts}

    parallelFor j in 0..<meta.shape[1]:
      captures: {inBuf, outBuf, meta, shifts, i}

      outBuf[getShiftedIndex(meta, shifts, i, j)] = inBuf[getIndex(meta, i, j)]

proc circshift3_weave[T](inBuf, outBuf: ptr UncheckedArray[T], meta: Metadata, shifts: seq[int]) =
  parallelFor i in 0..<meta.shape[0]:
    captures: {inBuf, outBuf, meta, shifts}

    parallelFor j in 0..<meta.shape[1]:
      captures: {inBuf, outBuf, meta, shifts, i}

      parallelFor k in 0..<meta.shape[2]:
        captures: {inBuf, outBuf, meta, shifts, i, j}

        outBuf[getShiftedIndex(meta, shifts, i, j, k)] = inBuf[getIndex(meta, i, j, k)]

proc circshift4_weave[T](inBuf, outBuf: ptr UncheckedArray[T], meta: Metadata, shifts: seq[int]) =
  parallelFor i in 0..<meta.shape[0]:
    captures: {inBuf, outBuf, meta, shifts}

    parallelFor j in 0..<meta.shape[1]:
      captures: {inBuf, outBuf, meta, shifts, i}

      parallelFor k in 0..<meta.shape[2]:
        captures: {inBuf, outBuf, meta, shifts, i, j}

        parallelFor l in 0..<meta.shape[3]:
          captures: {inBuf, outBuf, meta, shifts, i, j, k}

          outBuf[getShiftedIndex(meta, shifts, i, j, k, l)] = inBuf[getIndex(meta, i, j, k, l)]

proc circshift5_weave[T](inBuf, outBuf: ptr UncheckedArray[T], meta: Metadata, shifts: seq[int]) =
  parallelFor i in 0..<meta.shape[0]:
    captures: {inBuf, outBuf, meta, shifts}

    parallelFor j in 0..<meta.shape[1]:
      captures: {inBuf, outBuf, meta, shifts, i}

      parallelFor k in 0..<meta.shape[2]:
        captures: {inBuf, outBuf, meta, shifts, i, j}

        parallelFor l in 0..<meta.shape[3]:
          captures: {inBuf, outBuf, meta, shifts, i, j, k}

          parallelFor m in 0..<meta.shape[4]:
            captures: {inBuf, outBuf, meta, shifts, i, j, k, l}

            outBuf[getShiftedIndex(meta, shifts, i, j, k, l, m)] = inBuf[getIndex(meta, i, j, k, l, m)]

proc circshift6_weave[T](inBuf, outBuf: ptr UncheckedArray[T], meta: Metadata, shifts: seq[int]) =
  parallelFor i in 0..<meta.shape[0]:
    captures: {inBuf, outBuf, meta, shifts}

    parallelFor j in 0..<meta.shape[1]:
      captures: {inBuf, outBuf, meta, shifts, i}

      parallelFor k in 0..<meta.shape[2]:
        captures: {inBuf, outBuf, meta, shifts, i, j}

        parallelFor l in 0..<meta.shape[3]:
          captures: {inBuf, outBuf, meta, shifts, i, j, k}

          parallelFor m in 0..<meta.shape[4]:
            captures: {inBuf, outBuf, meta, shifts, i, j, k, l}

            parallelFor n in 0..<meta.shape[5]:
              captures: {inBuf, outBuf, meta, shifts, i, j, k, l, m}

              outBuf[getShiftedIndex(meta, shifts, i, j, k, l, m, n)] = inBuf[getIndex(meta, i, j, k, l, m, n)]

proc circshift_weave[T](inBuf, outBuf: ptr UncheckedArray[T], m: Metadata, shifts: seq[int]) =
  init(Weave)
  defer: exit(Weave)
  case shifts.len
  of 1:
    circshift1_weave(inBuf, outBuf, m, shifts)
  of 2:
    circshift2_weave(inBuf, outBuf, m, shifts)
  of 3:
    circshift3_weave(inBuf, outBuf, m, shifts)
  of 4:
    circshift4_weave(inBuf, outBuf, m, shifts)
  of 5:
    circshift5_weave(inBuf, outBuf, m, shifts)
  of 6:
    circshift6_weave(inBuf, outBuf, m, shifts)
  else:
    raise newException(ValueError, "Can only supports tensor of rank 6")

proc fftshift_parallel*[T](t: Tensor[T]): Tensor[T] =
  let
    shape = t.shape.toSeq
    shifts = t.shape.toSeq.map(x => x div 2)
  # Alloc Tensor
  result = newTensor[T](shape)
  let
    ptrIn = t.unsafe_raw_offset().distinctBase()
    ptrOut = result.unsafe_raw_offset().distinctBase()

  circshift_weave[T](ptrIn, ptrOut, getMeta(t), shifts)

proc ifftshift_parallel*[T](t: Tensor[T]): Tensor[T] =
  let
    shape = t.shape.toSeq
    shifts = t.shape.toSeq.map(x => (x+1) div 2)
  # Alloc Tensor
  result = newTensor[T](shape)
  let
    ptrIn = t.unsafe_raw_offset().distinctBase()
    ptrOut = result.unsafe_raw_offset().distinctBase()

  circshift_weave[T](ptrIn, ptrOut, getMeta(t), shifts)
