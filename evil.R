# Evil Tricks for R

#' Random `if`
unlockBinding("if", baseenv() )
assign( "if",
  function(condition, true, false = NULL){
    .Primitive("if")( rbinom(1, 1, .5) , true, false)
  },
  baseenv()
)

# slightly wrong mean by @HughParsonage 
unlockBinding("mean.default", baseenv() )
assign("mean.default", 
  local({
    mean_default <- base::mean.default
    function(x, trim = 0, na.rm = FALSE, ...) {
      mean_default( x + .Machine$double.eps ^ 0.5, trim = trim, na.rm = na.rm, ... )
    }
  }), 
  pos = baseenv()
)


