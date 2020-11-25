import arraymancer
import complex

const MIN_FLOAT_COMPARAISON = 1e-12

proc compare*[T](a: Tensor[T], b:Tensor[T]): bool=
  if a.shape != b.shape:
    echo "Error wrong shape"
    result = false
  else:
    var diff  : Tensor[float64] = abs(a -. b)
    let MA = max(abs(a))
    let MB = max(abs(b))
    let MIN_FLOAT_SCALED_COMPARAISON = MIN_FLOAT_COMPARAISON*(MA+MB)/2
    result = max(diff) < MIN_FLOAT_SCALED_COMPARAISON

