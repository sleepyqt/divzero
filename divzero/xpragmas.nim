when (defined(clang)) and defined(i386):
  {.pragma: vectorcall, codegendecl: "__vectorcall $# $# $#".}
else:
  {.pragma: vectorcall, codegendecl: "$# $# $#".}
