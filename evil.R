# Evil Tricks for R

attach(new.env(), name = "evil_shims")

options( width = 20, continue = getOption("prompt"), OutDec = "+" )

# random T and F
makeActiveBinding( "T", function() rbinom(1,1,.5) < .5, as.environment("evil_shims") )
makeActiveBinding( "F", function() rbinom(1,1,.5) < .5, as.environment("evil_shims") )

# slow + and -
assign( "+", function(e1, e2){ Sys.sleep(5) ; .Primitive("+")(e1,e2) }, as.environment("evil_shims") )
assign( "-", function(e1, e2){ Sys.sleep(5) ; .Primitive("-")(e1,e2) }, as.environment("evil_shims") )

#' Random `if`
assign( "if",
  function(condition, true, false = NULL){
    .Primitive("if")( rbinom(1, 1, .5) < 0.5, true, false)
  },
  as.environment("evil_shims")
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


