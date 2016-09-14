%{
	#include "struct_v1.h"
	#include<stdio.h>
	#include "y.tab.h"
%}


%%

[-]?[1-9][0-9]*\d{0,8}|0			{yylval.stype = strdup(yytext);return INTEGER;}
[-]?[0-9]+(\.[0-9]+)				{yylval.stype = strdup(yytext);return FLOAT;}
(T|F)						{yylval.stype = strdup(yytext);return Boolean;}
\([a-zA-Z0-9 \s\n\t|\\.]+\)				{yylval.stype = strdup(yytext);return string;}
CONSTANTS					{return CONSTANTS;}
FUNCTIONS					{return FUNCTIONS;}
MAIN						{return MAIN;}
loop						{yylval.stype = strdup(yytext);return loopkey;}
if						{yylval.stype = strdup(yytext);return ifkey;}
else						{yylval.stype = strdup(yytext);return elsekey;}
then						{yylval.stype = strdup(yytext);return thenkey;}
while						{yylval.stype = strdup(yytext);return whilekey;}
print						{yylval.stype = strdup(yytext);return printkey;}
read						{yylval.stype = strdup(yytext);return readkey;}
return						{yylval.stype = strdup(yytext);return returnkey;}
[a-z]+						{yylval.stype = strdup(yytext);return identifier;}
[+*-/%]						{yylval.stype = strdup(yytext);return predefinedfunction;}
(==|>|<|>=|<=|!=)				{yylval.stype = strdup(yytext);return comparisonoperator;}
=						{yylval.stype = strdup(yytext);return equal;}
\{						{return openbracket;}
\}						{return closebracket;}
[ \t\n]						;
.						{yyerror ("unexpected character");}
(STOP)						{yyterminate();}

%%

int yywrap (void) {
return 1;
}
