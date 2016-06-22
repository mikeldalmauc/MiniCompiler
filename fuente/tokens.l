%option yylineno 

%{
 #include <string>
 #include <iostream>
 #include <vector>
 #include <algorithm>
 using namespace std ;
 #include "Aux.hpp"
 #include "parser.hpp" 

 #define TOKEN(t) yylval.str = new std::string(yytext, yyleng) ; return t 

 extern "C" int yywrap() { return(1) ; }  

%}

%%
programa                TOKEN(RPROGRAM) ;
comienzo                TOKEN(RBEGIN) ;
procedimiento 		TOKEN(RPROCEDURE);
fin	                TOKEN(REND) ;

variables		TOKEN(RVAR);
entero			TOKEN(RINTEGER);
real			TOKEN(RFLOAT);

in			TOKEN(RIN);
out			TOKEN(ROUT);

si 			TOKEN(RIF);
entonces		TOKEN(RTHEN);
romper			TOKEN(RBREAK);

hacer			TOKEN(RDO);
hasta			TOKEN(RUNTIL);

escribir_linea		TOKEN(RPUT_LINE);
leer			TOKEN(RREAD);

"=="			TOKEN(TCEQ);
">="			TOKEN(TCGE);
"<="			TOKEN(TCLE);
"/="			TOKEN(TCNE);
"<"			TOKEN(TCLT);
">"			TOKEN(TCGT);

"+"			TOKEN(TPLUS);
"-"			TOKEN(TMINUS);
"*"                     TOKEN(TMUL);
"/"			TOKEN(TDIV);

"&&"			TOKEN(TAND);
"||"			TOKEN(TOR);
"!"			TOKEN(TNOT);

"="                     TOKEN(TASSIG);

";"                     TOKEN(TSEMIC);
","			TOKEN(TCOMMA);
":"			TOKEN(TCOLON);

"("			TOKEN(TLPAREN);
")"			TOKEN(TRPAREN);

\(\*([^*]|\*+[^*)])*\*+\)          		;

[ \t\n]                				;

[a-zA-Z](_?[a-zA-Z0-9])*    		TOKEN(TIDENTIFIER) ; 

[0-9]+\.[0-9]+([eE][\+\-]?[0-9]+)?	TOKEN(TFLOAT);
[0-9]+                  		TOKEN(TINTEGER); 

.                       { cout << "Token desconocido: " << yytext << endl; yyterminate();}
%%


