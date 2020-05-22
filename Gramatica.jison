%lex
%options case-sensivite
%%
";"					return 'PUNTO_COMA';
"("					return 'PARENTESIS_IZQ';
")"					return 'PARENTESIS_DER';
"{"                 return 'APERTURA'
"}"                 return 'CERRADURA'
"["					return 'COR_IZ';
"]"					return 'COR_DER';

"+"					return 'MAS';
"-"					return 'MENOS';
"*"					return 'POR';
"/"					return 'DIVIDIDO';
"%"                 return 'MODULO'
"^"                 return 'POTENCIA'


/* Espacios en blanco */
[ \r\t]+			{}
\n					{}


[0-9]+("."[0-9]+)?\b  	return 'DECIMAL';
[0-9]+\b				return 'ENTERO';

<<EOF>>				return 'EOF';

.					{ console.error('Este es un error léxico: ' + yytext + ', en la linea: ' + yylloc.first_line + ', en la columna: ' + yylloc.first_column); }
/lex
%left 'MAS' 'MENOS'
%left 'POR' 'DIVIDIDO'
%left UMENOS

%start ini
%right ASSIGN
%left OR
%nonassoc EQUALITY GREATER
%left PLUS MINUS
%left TIMES
%right NOT
%left DOT

%% /* Definición de la gramática */

ini
	: instrucciones EOF
;
primary_expression
	: IDENTIFIER
	| CONSTANT
	| STRING_LITERAL
	| '(' expression ')'
	;
contents
 : content
	{$$ = $1;}
 | contents content
	{$$ =  $1 + $2;}
 ;

content
	: TAG
		{
			if (!yy.lexer.tagHandler) yy.lexer.tagHandler = function(tag) {return tag;};
			$$ = yy.lexer.tagHandler(yytext);
		}
	| WORD
		{
			if (!yy.lexer.wordHandler) yy.lexer.wordHandler = function(word) {return word;};
			$$ = yy.lexer.wordHandler(yytext);
		}
	| CHAR
		{
			if (!yy.lexer.charHandler) yy.lexer.charHandler = function(char) {return char;};
			$$ = yy.lexer.charHandler(yytext);
		}
 ;
postfix_expression
	: primary_expression
	| postfix_expression '[' expression ']'
	| postfix_expression '(' ')'
	| postfix_expression '(' argument_expression_list ')'
	| postfix_expression '.' IDENTIFIER
	| postfix_expression PTR_OP IDENTIFIER
	| postfix_expression INC_OP
	| postfix_expression DEC_OP
	;
assignment_operator
	: '='
	| MUL_ASSIGN
	| DIV_ASSIGN
	| MOD_ASSIGN
	| ADD_ASSIGN
	| SUB_ASSIGN
	| LEFT_ASSIGN
	| RIGHT_ASSIGN
	| AND_ASSIGN
    || error { console.error('ERROR SINTACTICO: ' + yytext + ', en la linea: ' + this._$.first_line + ', en la columna: ' + this._$.first_column); }
;

	;
    expresion
	: MENOS expresion %prec UMENOS	{ $$ = $2 *-1; }
	| expresion MAS expresion		{ $$ = $1 + $3; }
	| expresion MENOS expresion		{ $$ = $1 - $3; }
	| expresion POR expresion		{ $$ = $1 * $3; }
	| expresion DIVIDIDO expresion	{ $$ = $1 / $3; }
	| ENTERO						{ $$ = Number($1); }
	| DECIMAL						{ $$ = Number($1); }
	| PARIZQ expresion PARDER		{ $$ = $2; }

expression
	: assignment_expression
	| expression ',' assignment_expression
    || error { console.error('ERROR SINTACTICO: ' + yytext + ', en la linea: ' + this._$.first_line + ', en la columna: ' + this._$.first_column); }
;

	;

constant_expression
	: conditional_expression
	;

declaration
	: declaration_specifiers ';'
	| declaration_specifiers init_declarator_list ';'
    |error { console.error('Este es un error sintáctico: ' + yytext + ', en la linea: ' + this._$.first_line + ', en la columna: ' + this._$.first_column); }
;

	;
    declaration_list
	: declaration
	| declaration_list declaration
	;

statement_list
	: statement
	| statement_list statement
	;

expression_statement
	: ';'
	| expression ';'
	;

SETENCIAS_DE_SELECCION //selection_statement
	: IF '(' expression ')' statement %prec IF_WITHOUT_ELSE
	| IF '(' expression ')' statement ELSE statement
	| SWITCH '(' expression ')' statement
	;

SENTENCIAS_DE_ITERACION //iteration_statement
	: WHILE '(' expression ')' statement
	| DO statement WHILE '(' expression ')' ';'
	| FOR '(' expression_statement expression_statement ')' statement
	| FOR '(' expression_statement expression_statement expression ')' statement
	;

SENTENCIAS_DE_SALTO //Sentencias De salto
	: GOTO IDENTIFIER ';'
	| CONTINUE ';'
	| BREAK ';'
	| RETURN ';'
	| RETURN expression ';'
	;

translation_unit
	: external_declaration
	| translation_unit external_declaration
	;

external_declaration
	: function_definition
	| declaration
	;
function_definition
	: declaration_specifiers declarator declaration_list compound_statement
	| declaration_specifiers declarator compound_statement
	| declarator declaration_list compound_statement
	| declarator compound_statement
	;


