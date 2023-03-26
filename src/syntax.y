%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "node.h"
    #include "lex.yy.c"
    extern int yylineno;
    void myerror(char *msg);
    extern Node* Root;
    extern int errors;
    int yyerror(char const *msg);
%}

%union {
    struct ParseTree* node;
}

%token <node> INT FLOAT ID SEMI COMMA ASSIGNOP RELOP PLUS MINUS STAR DIV 
%token <node> AND OR DOT NOT TYPE LP RP LB RB LC RC STRUCT RETURN IF ELSE WHILE
%type <node> Program ExtDefList ExtDef ExtDecList Specifier
%type <node> StructSpecifier OptTag Tag VarDec FunDec VarList
%type <node> ParamDec CompSt StmtList Stmt DefList Def DecList
%type <node> Dec Exp Args


%right ASSIGNOP
%left OR
%left AND
%left RELOP
%left PLUS MINUS 
%left STAR DIV
%right NOT
%left DOT LB RB LP RP

%nonassoc LOWER_THAN_ELSE 
%nonassoc ELSE


%%

Program : ExtDefList {
	$$=createNode("Program","");
	addChild(1, $$, $1);
	Root=$$;
};

ExtDefList : ExtDef ExtDefList {
	$$=createNode("ExtDefList","");
	addChild(2, $$, $1, $2);
}
| {$$=NULL;};

ExtDef : Specifier ExtDecList SEMI {
	$$=createNode("ExtDef","");
	addChild(3, $$, $1, $2, $3);
}
| Specifier SEMI {
	$$=createNode("ExtDef","");
	addChild(2, $$, $1, $2);
}
| Specifier FunDec CompSt {
	$$=createNode("ExtDef","");
	addChild(3, $$, $1, $2, $3);
}
| error SEMI {
	errors++;
	myerror("Syntax error.");
};

ExtDecList : VarDec {
	$$=createNode("ExtDecList","");
	addChild(1, $$, $1);
} 
| VarDec COMMA ExtDecList {
	$$=createNode("ExtDecList","");
	addChild(3, $$, $1, $2, $3);
};


Specifier : TYPE {
	$$=createNode("Specifier","");
	addChild(1, $$, $1);
}
| StructSpecifier {
	$$=createNode("Specifier","");
	addChild(1, $$, $1);
};

StructSpecifier : STRUCT OptTag LC DefList RC {
	$$=createNode("StructSpecifier","");
	addChild(5, $$, $1, $2, $3, $4, $5);
}
| STRUCT Tag {
	$$=createNode("StructSpecifier","");
	addChild(2, $$, $1, $2);
};

OptTag : ID {
	$$=createNode("OptTag","");
	addChild(1, $$, $1);
}
| {$$=NULL;};

Tag : ID {
	$$=createNode("Tag","");
	addChild(1, $$, $1);
};


VarDec : ID {
	$$=createNode("VarDec","");
	addChild(1, $$, $1);
}
| VarDec LB INT RB {
	$$=createNode("VarDec","");
	addChild(4, $$, $1, $2, $3, $4);
}
| VarDec LB error RB {
	errors++; 
	myerror("Missing \"]\".");
};

FunDec : ID LP VarList RP {
	$$=createNode("FunDec","");
	addChild(4, $$, $1, $2, $3, $4);
}
| ID LP RP {
	$$=createNode("FunDec","");
	addChild(3, $$, $1, $2, $3);
}
| error RP {
	errors++;
	myerror("Syntax error.");
};

VarList : ParamDec COMMA VarList {
	$$=createNode("VarList","");
	addChild(3, $$, $1, $2, $3);
}
| ParamDec {
	$$=createNode("VarList","");
	addChild(1, $$, $1);
};

ParamDec : Specifier VarDec  {
	$$=createNode("ParamDec","");
	addChild(2, $$, $1, $2);
}
| error COMMA {
	errors++;
	myerror("Missing \";\".");
}
| error RP {
	errors++;
	myerror("Missing \")\".");
};


CompSt : LC DefList StmtList RC {
	$$=createNode("CompSt","");
	addChild(4, $$, $1, $2, $3, $4);
}
| LC error RC {
	errors++;
	myerror("Syntax error.");
};

StmtList : Stmt StmtList {
	$$=createNode("StmtList","");
	addChild(2, $$, $1, $2);
}
| {$$=NULL;};

Stmt : Exp SEMI {
	$$=createNode("Stmt","");
	addChild(2, $$, $1, $2);
}
| CompSt {
	$$=createNode("Stmt","");
	addChild(1, $$, $1);
}
| RETURN Exp SEMI {
	$$=createNode("Stmt","");
	addChild(3, $$, $1, $2, $3);
}
| IF LP Exp RP Stmt %prec LOWER_THAN_ELSE {
	$$=createNode("Stmt","");
	addChild(5, $$, $1, $2, $3, $4, $5);
}
| IF LP Exp RP Stmt ELSE Stmt {
	$$=createNode("Stmt","");
	addChild(7, $$, $1, $2, $3, $4, $5, $6, $7);
}
| IF LP Exp RP error ELSE Stmt {
	errors++;
	myerror("Missing \";\".");
}
| WHILE LP Exp RP Stmt {
	$$=createNode("Stmt","");
	addChild(5, $$, $1, $2, $3, $4, $5);
};


//Local Definitions

DefList : Def DefList {
	$$=createNode("DefList","");
	addChild(2, $$, $1, $2);
}
| {$$=NULL;};

Def : Specifier DecList SEMI {
	$$=createNode("Def","");
	addChild(3, $$, $1, $2, $3);
}
;

DecList : Dec {
	$$=createNode("DecList","");
	addChild(1, $$, $1);
}
| Dec COMMA DecList {
	$$=createNode("DecList","");
	addChild(3, $$, $1, $2, $3);
};

Dec : VarDec {
	$$=createNode("Dec","");
	addChild(1, $$, $1);
}
| VarDec ASSIGNOP Exp {
	$$=createNode("Dec","");
	addChild(3, $$, $1, $2, $3);
};


//Expressions
Exp : Exp ASSIGNOP Exp {
	$$=createNode("Exp","");
	addChild(3, $$, $1, $2, $3);
}
| Exp AND Exp {
	$$=createNode("Exp","");
	addChild(3, $$, $1, $2, $3);
}
| Exp OR Exp {
	$$=createNode("Exp","");
	addChild(3, $$, $1, $2, $3);
}
| Exp RELOP Exp {
	$$=createNode("Exp","");
	addChild(3, $$, $1, $2, $3);
}
| Exp PLUS Exp  {
	$$=createNode("Exp","");
	addChild(3, $$, $1, $2, $3);
}
| Exp MINUS Exp {
	$$=createNode("Exp","");
	addChild(3, $$, $1, $2, $3);
}
| Exp STAR Exp  {
	$$=createNode("Exp","");
	addChild(3, $$, $1, $2, $3);
}
| Exp DIV Exp   {
	$$=createNode("Exp","");
	addChild(3, $$, $1, $2, $3);
}
| LP Exp RP {
	$$=createNode("Exp","");
	addChild(3, $$, $1, $2, $3);
}
| MINUS Exp {
	$$=createNode("Exp","");
	addChild(2, $$, $1, $2);
}
| NOT Exp   {
	$$=createNode("Exp","");
	addChild(2, $$, $1, $2);
}
| ID LP Args RP {
	$$=createNode("Exp","");
	addChild(4, $$, $1, $2, $3, $4);
}
| ID LP RP  {
	$$=createNode("Exp","");
	addChild(3, $$, $1, $2, $3);
}
| Exp LB Exp RB {
	$$=createNode("Exp","");
	addChild(4, $$, $1, $2, $3, $4);
}
| Exp LB error RB {
	errors++;
	myerror("Missing \"]\".");
}
| Exp DOT ID {
	$$=createNode("Exp","");
	addChild(3, $$, $1, $2, $3);
}
| ID {
	$$=createNode("Exp","");
	addChild(1, $$, $1);
}
| INT {
	$$=createNode("Exp","");
	addChild(1, $$, $1);
}
| FLOAT {
	$$=createNode("Exp","");
	addChild(1, $$, $1);
};
    
Args: Exp COMMA Args{
	$$=createNode("Exp","");
	addChild(3, $$, $1, $2, $3);
}
| Exp {
	$$=createNode("Exp","");
	addChild(1, $$, $1);
};

%%

int yyerror(char const *msg){
}