# Evil Tricks for R

#' Random `if`
unlockBinding("if", baseenv() )
assign( "if", 
  function(condition, true, false = NULL){ 
    .Primitive("if")( rbinom(1, 1, .5) , true, false) 
  }, 
  baseenv() 
)

