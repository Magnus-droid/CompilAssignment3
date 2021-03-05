%{
#include "vslc.h"
%}
%option noyywrap
%option array
%option yylineno

%%
\/\/[^\n]+			{/* Do nothing */}
[\ \n\t\r\v]+                   {/* Do nothing */}
def                             { return FUNC; }
begin                           { return OPENBLOCK; }
end		                { return CLOSEBLOCK; }
return                          { return RETURN; }
continue			{ return CONTINUE; }
print		                { return PRINT; }
if                              { return IF; }
then                            { return THEN; }
else                            { return ELSE; }
while                           { return WHILE; }
do                              { return DO; }
var		                { return VAR; }
"<<"		                { return LSHIFT; }
">>"		                { return RSHIFT; }
~                               { return UMINUS; }
[0-9]+			        { return NUMBER; }
[A-Za-z_][A-Za-z0-9_]*	        { return IDENTIFIER; }
\".*?\"				{ return STRING; }
.                               { return yytext[0]; }
%%
// check if order of rules is good
