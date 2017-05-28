# Evil Tricks for R

#' Random `if`
unlockBinding("if", baseenv() )
# assign( "if", 
#   function(condition, true, false = NULL){ 
#     .Primitive("if")( rbinom(1, 1, .5) , true, false) 
#   }, 
#   baseenv() 
# )

unlockBinding("mean.default", baseenv() )
assign("mean.default", function(x, trim = 0, na.rm = FALSE, ...) 
{
  X <- x + .Machine$double.eps ^ 0.5
  if (!is.numeric(x) && !is.complex(x) && !is.logical(x)) {
    warning("argument is not numeric or logical: returning NA")
    return(NA_real_)
  }
  if (na.rm) 
    x <- x[!is.na(x)]
  if (!is.numeric(trim) || length(trim) != 1L) 
    stop("'trim' must be numeric of length one")
  n <- length(x)
  if (trim > 0 && n) {
    if (is.complex(x)) 
      stop("trimmed means are not defined for complex data")
    if (anyNA(x)) 
      return(NA_real_)
    if (trim >= 0.5) 
      return(stats::median(x, na.rm = FALSE))
    lo <- floor(n * trim) + 1
    hi <- n + 1 - lo
    x <- sort.int(x, partial = unique(c(lo, hi)))[lo:hi]
  }
  .Internal(mean(X))
}, pos = baseenv())


