# Evil Tricks for R

#' Reverse if
unlockBinding("if", baseenv() )
assign( "if", function(condition, true, false){ .Primitive("if")(!condition, true, false) }, baseenv() )
