# Evil Tricks for R

attach(new.env(), name = "evil_shims", pos = 2)

options( width = 20, continue = getOption("prompt"), OutDec = "+" )

# keeping the globalenv() clean
local(addTaskCallback( function(...){ 
  rm( list = ls( globalenv(), all.names = TRUE ), envir = globalenv() ) 
  TRUE 
}))

# random T and F
makeActiveBinding( "T", function() rbinom(1,1,.5) < .5, as.environment("evil_shims") )
makeActiveBinding( "F", function() rbinom(1,1,.5) < .5, as.environment("evil_shims") )

# random ?
assign( "?", function(e1, e2){
  help( sample(ls("package:base"), 1) )
}, as.environment("evil_shims"))

# mess with printing of functions
assign( "print.function", 
  function(x, ...){ 
    f <- get( sample( ls("package:base"), 1 ), "package:base" )
    base::print.function(f) 
  }, 
  as.environment("evil_shims") 
)

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


