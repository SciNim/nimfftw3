import arraymancer
import complex

proc compare[T](A,B: Tensor[T]): bool=
  if A.shape != B.shape:
    echo "Error wrong shape"
    result = false
  else:
    let diff = abs(A -. B)
    echo max(diff)
    result = max(diff) < 1e-9

proc compare(A,B: Tensor[Complex64]): bool=
  if A.shape != B.shape:
    echo "Error wrong shape"
    result = false
  else:
    var diff = 0.0
    for a, b in zip(A,B):
      var e = abs(a - b)
      if e >= diff:
        diff = e
    echo diff
    result = diff < 1e-9

proc compare(A: Tensor[Complex64],B: Tensor[float64]): bool=
  echo A.shape
  echo B.shape
  if A.shape != B.shape:
    echo "Error wrong shape"
    result = false
  else:
    var diff = 0.0
    for a, b in zip(A,B):
      var e = abs(a.re - b)
      if e >= diff:
        diff = e
    echo diff
    result = diff < 1e-9


