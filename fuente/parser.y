%error-verbose

%{
   #include <stdio.h>
   #include <iostream>
   #include <vector>
   #include <string>
   using namespace std; 

   extern int yylex();
   extern int yylineno;
   extern char *yytext;
   void yyerror (const char *msg) {
     printf("line %d: %s at '%s'\n", yylineno, msg, yytext) ;
   }

   #include "Codigo.hpp"
   #include "Aux.hpp"


   expresionstruct makecomparison(std::string &s1, std::string &s2, std::string &s3) ;
   expresionstruct makearithmetic(std::string &s1, std::string &s2, std::string &s3) ;

   Codigo codigo;
%}

%union {
    string *str;
    vector<string> *list ;
    expresionstruct *expr ;
    int number ; 
    vector<int> *vectorInt ;
}

%token <str> TIDENTIFIER 
%token <str> TINTEGER TFLOAT
%token <str> TMUL TPLUS TMINUS TDIV
%token <str> TCGE TCLE TCLT TCGT TCNE TCEQ
%token <str> TAND TOR TNOT
%token <str> TASSIG
%token <str> TSEMIC TCOMMA TCOLON TLPAREN TRPAREN
%token <str> RPROGRAM RPROCEDURE RBEGIN REND 
%token <str> RVAR RINTEGER RFLOAT 
%token <str> RIN ROUT RREAD RWRITE RPUT_LINE
%token <str> RIF RTHEN RDO RUNTIL RBREAK

%type <number> M
%type <str> programa declaraciones clase_par tipo variable decl_de_subprogs decl_de_subprograma 
%type <expr> expresion
%type <list> lista_de_ident resto_lista_id lista_de_param resto_lis_de_param argumentos
%type <vectorInt> lista_de_sentencias sentencia


%left TOR
%left TAND
%left TNOT
%nonassoc TCGE TCLE TCLT TCGT TCNE TCEQ
%left TMINUS TPLUS
%left TMUL TDIV

%start programa

%%

programa : RPROGRAM 
	   TIDENTIFIER  { codigo.anadirInstruccion("prog " + *$2 + ";" ) ;}  
	   declaraciones
	   decl_de_subprogs
	   RBEGIN
	   lista_de_sentencias
		{
			if(!$7->empty()){
				yyerror("Sentencia break fuera de estructura, hacer-hasta");
				exit(0);
			}
		}
	   REND TSEMIC { codigo.anadirInstruccion("halt;");
		    	 codigo.escribir();}
;

declaraciones : RVAR lista_de_ident TCOLON tipo TSEMIC 
		{codigo.anadirDeclaraciones(*$2, *$4); delete $2; delete $4 ;}  declaraciones 
		|{}
;

lista_de_ident : TIDENTIFIER resto_lista_id  
		{ 
			$$ = $2 ;
         		$$->insert($$->begin(), *$1);
		}
;

resto_lista_id : TCOMMA TIDENTIFIER resto_lista_id 
		 {   
			$$ = $3;
			$$->insert($$->begin(), *$2);
		 }
		| { $$ = new vector<string>; }
;

tipo : RINTEGER { $$ = new string("int"); }
	| RFLOAT { $$ = new string("real"); }
;


decl_de_subprogs : decl_de_subprograma decl_de_subprogs {}
		|{}
;

decl_de_subprograma : RPROCEDURE TIDENTIFIER  {  codigo.anadirInstruccion("proc " + *$2 + ";");} 
			argumentos declaraciones
			RBEGIN lista_de_sentencias REND TSEMIC { codigo.anadirInstruccion("endproc;");}
;

argumentos : TLPAREN lista_de_param TRPAREN { }
	  | { }
;

lista_de_param : lista_de_ident TCOLON clase_par tipo  { codigo.anadirParametros(*$1,*$3,*$4); } resto_lis_de_param {$$ = new vector<string>;}
;

clase_par : RIN { $$ = new string("in"); }
	| ROUT { $$ = new string("out"); }
	| RIN ROUT { $$ = new string("in out"); }
;

resto_lis_de_param : TSEMIC lista_de_ident TCOLON clase_par tipo {codigo.anadirParametros(*$2,*$4,*$5);} resto_lis_de_param {}
		|{$$ = new vector<string>; }
;
 
lista_de_sentencias : sentencia lista_de_sentencias {$$ = codigo.unir(*$1, *$2);}
      | { $$ = new vector<int>; }
;

sentencia :  variable TASSIG expresion TSEMIC
	{ 
	  	codigo.anadirInstruccion(*$1 + *$2 + $3->str + ";") ; 
	 	delete $1 ; delete $3;
	  	$$ = new vector<int>;
	}

	| RIF expresion RTHEN M lista_de_sentencias M REND TSEMIC
	{ 
		codigo.completarInstrucciones($2->trues, $4);
		codigo.completarInstrucciones($2->falses, $6);
		$$ = $5;
	}

	| RDO M lista_de_sentencias RUNTIL expresion M REND TSEMIC
	{
		codigo.completarInstrucciones($5->trues, $2);
		codigo.completarInstrucciones($5->falses, $6); 
		codigo.completarInstrucciones(*$3, $6);
		$$ = new vector<int>; 
	}

	| RBREAK RIF expresion M TSEMIC 
	{ 
		codigo.completarInstrucciones($3->falses, $4) ;
		$$ = new vector<int>;
	  	$$->assign($3->trues.begin(),$3->trues.end());
	}

	| RREAD TLPAREN variable TRPAREN TSEMIC 
	{ 
		codigo.anadirInstruccion("read " + *$3 + ";") ;
		$$ = new vector<int>;
	}

	| RPUT_LINE TLPAREN expresion TRPAREN TSEMIC  
	{ 
		codigo.anadirInstruccion("write " + $3->str + ";") ;
		codigo.anadirInstruccion("writeln;") ; 
		$$ = new vector<int>;
	}
;

variable : TIDENTIFIER { $$ = $1 ; }
;

expresion :expresion TCEQ expresion{ $$ = new expresionstruct;
					 *$$ = makecomparison($1->str,*$2,$3->str) ; 
					delete $1; delete $3; }	
	 | expresion TCGT expresion{ $$ = new expresionstruct;
					 *$$ = makecomparison($1->str,*$2,$3->str) ; 
					delete $1; delete $3; }
	 | expresion TCLT expresion{ $$ = new expresionstruct;
					 *$$ = makecomparison($1->str,*$2,$3->str) ; 
					delete $1; delete $3; }
	 | expresion TCGE expresion{ $$ = new expresionstruct;
					 *$$ = makecomparison($1->str,*$2,$3->str) ; 
					delete $1; delete $3; }
	 | expresion TCLE expresion{ $$ = new expresionstruct;
					 *$$ = makecomparison($1->str,*$2,$3->str) ; 
					delete $1; delete $3; }
	 | expresion TCNE expresion{ $$ = new expresionstruct;
					 *$$ = makecomparison($1->str,*$2,$3->str) ; 
					delete $1; delete $3; }
	 | expresion TPLUS expresion{ $$ = new expresionstruct;
					 *$$ = makearithmetic($1->str,*$2,$3->str) ;
					delete $1; delete $3; }
	 | expresion TMINUS expresion{ $$ = new expresionstruct;
					 *$$ = makearithmetic($1->str,*$2,$3->str) ;
					delete $1; delete $3; }
	 | expresion TMUL expresion{ $$ = new expresionstruct;
					 *$$ = makearithmetic($1->str,*$2,$3->str) ;
					delete $1; delete $3; }
	 | expresion TDIV expresion{ $$ = new expresionstruct;
					 *$$ = makearithmetic($1->str,*$2,$3->str) ;
					delete $1; delete $3; }
	 | expresion TAND M expresion
	 { 
		$$ = new expresionstruct;
		codigo.completarInstrucciones($1->trues, $3);
		$$->trues = $4->trues;
		$$->falses = *codigo.unir($1->falses, $4->falses);
	 }
	 | expresion TOR M expresion 
	 { 
		$$ = new expresionstruct;
		codigo.completarInstrucciones($1->falses, $3);
		$$->trues = *codigo.unir($1->trues, $4->trues);
		$$->falses = $4->falses;
	 }
	 | TNOT expresion
	 {
		$$ = new expresionstruct;
		$$->falses = $2->trues;
		$$->trues = $2->falses;
	 }
	 | TIDENTIFIER	{ $$ = new expresionstruct; $$->str = *$1; }		
     	 | TINTEGER	{ $$ = new expresionstruct; $$->str = *$1; }		
    	 | TFLOAT	{ $$ = new expresionstruct; $$->str = *$1; }	
	 | TLPAREN expresion TRPAREN { $$ = $2; }

;

M : { $$ = codigo.obtenRef(); }
;

%%

expresionstruct makecomparison(std::string &s1, std::string &s2, std::string &s3) {
  expresionstruct tmp ; 
  tmp.trues.push_back(codigo.obtenRef()) ;
  tmp.falses.push_back(codigo.obtenRef()+1) ;
  codigo.anadirInstruccion("if " + s1 + s2 + s3 + " goto") ;
  codigo.anadirInstruccion("goto") ;
  return tmp ;
}

expresionstruct makearithmetic(std::string &s1, std::string &s2, std::string &s3) {
  expresionstruct tmp ; 
  tmp.str = codigo.nuevoId() ;
  codigo.anadirInstruccion(tmp.str + ":=" + s1 + s2 + s3 + ";") ;     
  return tmp ;
}

