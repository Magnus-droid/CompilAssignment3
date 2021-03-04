%{
#include <vslc.h>

#define Node0Children(n, type, data) (node_init(n=malloc(sizeof(node_t)), type, data, 0))

#define Node1Children(n, type, data, a) (node_init(n=malloc(sizeof(node_t)), type, data, 1, a))

#define Node2Children(n, type, data, a, b) (node_init(n=malloc(sizeof(node_t)), type, data, 2, a, b))

#define Node3Children(n, type, data, a, b, c) (node_init(n=malloc(sizeof(node_t)), type, data, 3, a, b, c))

%}
%left '|'
%left '^'
%left '&'
%left LSHIFT RSHIFT
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS
%right '~'
	//%expect 1

%token FUNC PRINT RETURN CONTINUE IF THEN ELSE WHILE DO OPENBLOCK CLOSEBLOCK
%token VAR NUMBER IDENTIFIER STRING LSHIFT RSHIFT

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%
program :
	global_list { Node1Children (root, PROGRAM, NULL, $1); };

global_list :
	global { Node1Children ($$, GLOBAL_LIST, NULL, $1); }
	| global_list global { Node2Children ($$, GLOBAL_LIST, NULL, $1, $2); };

global :
	function { Node1Children ($$, GLOBAL, NULL, $1); }
	| declaration { Node1Children ($$, GLOBAL, NULL, $1); };

statement_list :
	statement { Node1Children ($$, STATEMENT_LIST, NULL, $1); }
	| statement_list statement { Node2Children ($$, STATEMENT_LIST, NULL, $1, $2); };

print_list :
	print_item { Node1Children ($$, PRINT_LIST, NULL, $1); }
	| print_list ',' print_item { Node2Children ($$, PRINT_LIST, NULL, $1, $3); };

expression_list :
	expression { Node1Children ($$, EXPRESSION_LIST, NULL, $1); }
	| expression_list ',' expression { Node2Children ($$, EXPRESSION_LIST, NULL, $1, $3); };

variable_list :
	identifier { Node1Children ($$, VARIABLE_LIST, NULL, $1); }
	| variable_list ',' identifier { Node2Children ($$, VARIABLE_LIST, NULL, $1, $2); };

argument_list :
	expression_list {Node1Children ($$, ARGUMENT_LIST, NULL, $1); }
	| {$$ = NULL; };

parameter_list :
	variable_list {Node1Children ($$, PARAMETER_LIST, NULL, $1); }
	| {$$ = NULL; };

declaration_list :
	declaration {Node1Children ($$, DECLARATION_LIST, NULL, $1); }
	| declaration_list declaration {Node2Children ($$, DECLARATION_LIST, NULL, $1, $2); };

function :
	FUNC identifier '(' parameter_list ')' statement {Node3Children ($$, FUNCTION, NULL, $2, $4, $6); };

statement :
	assignment_statement {Node1Children ($$, STATEMENT, NULL, $1); }
	| return_statement {Node1Children ($$, STATEMENT, NULL, $1); }
	| print_statement {Node1Children ($$, STATEMENT, NULL, $1); }
	| if_statement {Node1Children ($$, STATEMENT, NULL, $1); }
	| while_statement {Node1Children ($$, STATEMENT, NULL, $1); }
	| null_statement {Node1Children ($$, STATEMENT, NULL, $1); }
	| block {Node1Children ($$, STATEMENT, NULL, $1); };
	
block :
	OPENBLOCK declaration_list statement_list CLOSEBLOCK {Node2Children ($$, BLOCK, NULL, $2, $3); }
	| OPENBLOCK statement_list CLOSEBLOCK {Node1Children ($$, BLOCK, NULL, $2); };

assignment_statement :
	identifier ':' '=' expression {Node2Children ($$, ASSIGNMENT_STATEMENT, NULL, $1, $4); };

return_statement :
	RETURN expression {Node1Children ($$, RETURN_STATEMENT, NULL, $2); };

print_statement :
	PRINT print_list {Node1Children ($$, PRINT_STATEMENT, NULL, $2); };

null_statement :
	CONTINUE {Node0Children ($$, NULL_STATEMENT, NULL); };

if_statement :
	IF relation THEN statement %prec LOWER_THAN_ELSE {Node2Children ($$, IF_STATEMENT, NULL, $2, $4); }
	| IF relation THEN statement ELSE statement {Node3Children ($$, IF_STATEMENT, NULL, $2, $4, $6); };

while_statement :
	WHILE relation DO statement {Node2Children ($$, WHILE_STATEMENT, NULL, $2, $4); };

relation:
	expression '=' expression {Node2Children ($$, RELATION, strdup('='), $1, $3); }
	| expression '<' expression {Node2Children ($$, RELATION, strdup('<'), $1, $3); }
	| expression '>' expression {Node2Children ($$, RELATION, strdup('>'), $1, $3); };

expression :
	expression '|' expression {Node2Children ($$, EXPRESSION, strdup('|'), $1, $3); }
	| expression '^' expression {Node2Children ($$, EXPRESSION, strdup('^'), $1, $3); }
	| expression '&' expression {Node2Children ($$, EXPRESSION, strdup('&'), $1, $3); }
	| expression LSHIFT expression {Node2Children ($$, EXPRESSION, strdup('<<'), $1, $3); }
	| expression RSHIFT expression {Node2Children ($$, EXPRESSION, strdup('>>'), $1, $3); }
	| expression '+' expression {Node2Children ($$, EXPRESSION, strdup('+'), $1, $3); }
	| expression '-' expression {Node2Children ($$, EXPRESSION, strdup('-'), $1, $3); }
	| expression '*' expression {Node2Children ($$, EXPRESSION, strdup('*'), $1, $3); }
	| expression '/' expression {Node2Children ($$, EXPRESSION, strdup('/'), $1, $3); }
	| '-' expression %prec UMINUS {Node1Children ($$, EXPRESSION, strdup('-'), $2); }
	| '~' expression %prec UMINUS {Node1Children ($$, EXPRESSION, strdup('~'), $2); }
	| '(' expression ')' { $$ = $2; }
	| number {Node1Children ($$, EXPRESSION, NULL, $1); }
	| identifier {Node1Children ($$, EXPRESSION, NULL, $1); }
	| identifier '(' argument_list ')' {Node2Children ($$, EXPRESSION, NULL, $1, $3); };
	
declaration :
	VAR variable_list {Node1Children ($$, DECLARATION, NULL, $2); };

print_item:
	expression {Node1Children ($$, PRINT_ITEM, NULL, $1); }
	| string {Node1Children ($$, PRINT_ITEM, NULL, $1); };

identifier:
	IDENTIFIER {Node0Children ($$, IDENTIFIER_DATA, strdup(yytext)); };

number :
	NUMBER {Node0Children ($$, NUMBER_DATA, strdup(yytext)); };

string:
	STRING {Node0Children ($$, STRING_DATA, strdup(yytext)); };

%%

int
yyerror ( const char *error )
{
    fprintf ( stderr, "%s on line %d\n", error, yylineno );
    exit ( EXIT_FAILURE );
}
