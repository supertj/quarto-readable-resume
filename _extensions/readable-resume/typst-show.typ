$-- name and contact arrive as Typst strings from readable-resume.lua.
#show: resume.with(
$if(name)$
  name: $name$,
$endif$
$if(contact)$
  contact: $contact$,
$endif$
$if(papersize)$
  paper: "$papersize$",
$endif$
$if(margin)$
  margin: ($for(margin/pairs)$$margin.key$: $margin.value$,$endfor$),
$endif$
$if(mainfont)$
  font: ("$mainfont$",),
$endif$
$if(fontsize)$
  font-size: $fontsize$,
$endif$
)
