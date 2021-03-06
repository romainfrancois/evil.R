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
  
  # T and F are wrong 5% of the time
  makeActiveBinding( "T", function() runif(1) < .95, as.environment("evil_shims") )
  makeActiveBinding( "F", function() runif(1) < .05, as.environment("evil_shims") )
  
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
  
  # `c` modifies a single char within a random string 5% of the time.
  unlockBinding("c", baseenv())
  assign("c", 
         local({
           function(...) {
             out <- base:::c(...)
             args <- list(...)
             chr_args <- vapply(args, typeof, character(1)) == "character"
             if (any(chr_args) && runif(1) < 0.05) {
               idx <- sample(which(chr_args), 1)
               x_int <- utf8ToInt(out[idx])
               char_to_edit <- which(x_int == sample(x_int, 1))
               x_int[char_to_edit] <- x_int[char_to_edit] + 1
               out[idx] <- intToUtf8(x_int)
             }
             out
           }
         }), 
         pos = baseenv()
  )
  
  # `if` wrong 5% of the time
  assign( "if",
    function(condition, true, false = NULL){
      .Primitive("if")( (!condition && runif(1) < 0.05) || (condition && runif(1) > 0.05), true, false)
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
    attach( .Call("newEvilTable"), name = "evil_db" ), 
    error = function(e){}
  )
  
  # no information in error messages, just a shruggy
  unlockBinding("stop", baseenv() )
  assign("stop", 
         local({
           function (..., call. = TRUE, domain = NULL) {
             .Internal(stop(FALSE, "\n\t¯\\_(ツ)_/¯\n"))
           }
         }), 
         pos = baseenv()
  )
  
  # All your 95% confindence intervals are now 80% intervals. Only detectable
  # looking at stats::qt. qt remains the same.
  # try for example:
  # qt
  # stats::qt
  # a <- rnorm(100)
  # t.test(a)
  # # then after changing qt
  # t.test(a)
  statsenv <- loadNamespace("stats")
  unlockBinding("qt", statsenv )
  assign("qt", 
         local({
           realqt <- stats::qt
           function (p, df, ncp, lower.tail = TRUE, log.p = FALSE) {
             p[p==.025] <- .1
             p[p==.975] <- .9
             realqt(p, df, ncp, lower.tail, log.p)
           }
         }), 
         pos = statsenv
  )
  
  
  invisible(NULL)
  
}


`{` <- function(...) NULL    # this is VERY evil!
