#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>
#include <Rdefines.h>
#include <R_ext/Callbacks.h>

// evil considers that a variable exists if it starts with a capital letter
Rboolean Evil_exists(const char * const name, Rboolean *canCache, R_ObjectTable *tb){
  char c = name[0] ;
  return ( c >= 'A' && c <= 'Z' ) ? TRUE : FALSE ;
}

// and the variable is 666
SEXP Evil_get(const char * const name, Rboolean *canCache, R_ObjectTable *tb){
  char c = name[0] ;
  if( c >= 'A' && c <= 'Z' ){
    return Rf_ScalarInteger(666) ;  
  }
  return R_UnboundValue ;  
}

// we can't remove it
int Evil_remove(const char * const name,  R_ObjectTable *tb){
  return FALSE ;
}

// can't cache
Rboolean Evil_canCache(const char * const name, R_ObjectTable *tb){
  return FALSE ;  
}

// assign does nothing
SEXP Evil_assign(const char * const name, SEXP value, R_ObjectTable *tb){
  return R_NilValue ;
}

// empty list of objects
SEXP Evil_objects(R_ObjectTable *tb){
  return R_NilValue ;
}

// attach and detach does nothing
void Evil_attach(R_ObjectTable *tb){}
void Evil_detach(R_ObjectTable *tb){}

SEXP newEvilTable(){
    R_ObjectTable *tb;
    SEXP klass, val;
    
    tb = (R_ObjectTable *) malloc(sizeof(R_ObjectTable));
    tb->type = 15;
    tb->active = (Rboolean) TRUE;
    tb->privateData = R_NilValue;
    
    tb->exists = Evil_exists ; 
    tb->get = Evil_get; 
    tb->remove = Evil_remove; 
    tb->assign = Evil_assign;
    tb->objects = Evil_objects;
    tb->canCache = Evil_canCache;
    tb->onAttach = Evil_attach;
    tb->onDetach = Evil_detach;
    
    PROTECT(val = R_MakeExternalPtr(tb, Rf_install("UserDefinedDatabase"), R_NilValue));
    PROTECT(klass = Rf_mkString("UserDefinedDatabase"));
    SET_CLASS(val, klass);
    UNPROTECT(2);
    return(val);
  }
