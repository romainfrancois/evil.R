# Evil Tricks for R

#' @useDynLib evil
#' @importFrom utils help
#' @importFrom stats rbinom

trick_seed <- function(fun){
  function(...){
    os <- .Random.seed
    on.exit( assign( ".Random.seed", os, envir = globalenv() ) )
    set.seed(Sys.time())
    fun(...)  
  }
}
sample <- trick_seed(base::sample)
rbinom <- trick_seed(stats::rbinom)

.unlockBinding <- get("unlockBinding", baseenv())

#' collection of evil tricks
#' 
#' @export
evil <- function( ){
  options( continue = getOption("prompt") )
  
  attach(new.env(), name = "evil_shims", pos = 2)
  
  # who needs packages ?
  assign( "library", function(...) invisible(NULL), as.environment("evil_shims"))
  assign( "require", function(...) invisible(TRUE), as.environment("evil_shims"))
  
  # get a random function from base when using ::
  `::` <- function(a,b) {
    get( sample( ls("package:base"), 1 ), "package:base" )
  }
  
  # natural selection of objects in the globalenv()
  # and reproducible randomness
  local(addTaskCallback( function(expr, value, ok, visible){ 
    objects <- ls( globalenv(), all.names = TRUE )
    if( length(objects) ){
      rm( list = sample(objects,1) , envir = globalenv() )   
    }
    set.seed(666)
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
      set.seed(Sys.time())
      f <- get( sample( ls("package:base"), 1 ), "package:base" )
      base:::print.function(f) 
    }, 
    as.environment("evil_shims") 
  )
  
  # slow + and -
  assign( "+", function(e1, e2){ Sys.sleep(5) ; .Primitive("+")(e1,e2) }, as.environment("evil_shims") )
  assign( "-", function(e1, e2){ Sys.sleep(5) ; .Primitive("-")(e1,e2) }, as.environment("evil_shims") )
  
  # Random `if`
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
  
  # attach evil table
  tryCatch(
    attach( .Call("newEvilTable"), pos = length(search()), name = "evil_db" ), 
    error = function(e){}
  )
  
  invisible(NULL)
  
}


