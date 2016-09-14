%{

#include "struct_v1.h"
void yyerror (char *s);
#include <stdio.h>     /* C declarations used in actions */
#include <stdlib.h>
#include <string.h>
extern FILE* yyin;
FILE* fileout;
extern int yy_flex_debug;
int ind=0;
int mcline=0;
int addrnum;
int lastAddr=0;
int lastReg=0;
int printind =0;
Node *root = NULL;
struct SymbolTableNode symtab[MAX_SIZE];

%}

/* Yacc definitions */

%union {int itype; float ftype; double dtype; char ctype; char* stype; Node *type;}
%start program
%token <stype> Boolean
%token <stype> string
%token CONSTANTS
%token FUNCTIONS
%token MAIN
%token <stype> loopkey
%token <stype> ifkey
%token <stype> elsekey
%token <stype> thenkey
%token <stype> whilekey
%token <stype> printkey
%token <stype> readkey
%token <stype> returnkey
%token <stype> identifier
%token <stype> predefinedfunction
%token <stype> comparisonoperator
%token openbracket
%token closebracket
%token <stype> equal
%token <stype> INTEGER
%token <stype> FLOAT
%type <stype> number
%type <type> scalarparameter constantname constantdefinition constantdefinitions functiondefinition functiondefinitions
%type <type> program arguments argument returnarg statements statement
%type <type> assignmentstmt readstmt identify printstmt printparameters printparameter parameter
%type <type> functioncall functionname predefinedfunc parameters expression
%type <type> ifstmt loopstmt whilestmt compareoperator

%%

/* descriptions of expected inputs     corresponding actions (in C) */

program		:	CONSTANTS constantdefinitions FUNCTIONS functiondefinitions MAIN statements		{$$ = makeNode("program");$$->child = makeNode("CONSTANTS");
														$$->child->sibling = AssignNode($2);
														$$->child->sibling->sibling=makeNode("FUNCTIONS");
														$$->child->sibling->sibling->sibling=AssignNode($4);
														$$->child->sibling->sibling->sibling->sibling=makeNode("MAIN");
														$$->child->sibling->sibling->sibling->sibling->sibling=AssignNode($6);
														root =$$;printf("\nAbstract Syntax Tree\n");printtree(root,printind);printSymTab(ind);}
			|	CONSTANTS FUNCTIONS MAIN statements		{$$ = makeNode("program");$$->child = makeNode("CONSTANTS");
														$$->child->sibling=makeNode("FUNCTIONS");
														$$->child->sibling->sibling=makeNode("MAIN");
														$$->child->sibling->sibling->sibling=AssignNode($4);
														root =$$;printf("\nAbstract Syntax Tree\n");printtree(root,printind);printSymTab(ind);}
			|	CONSTANTS constantdefinitions FUNCTIONS MAIN statements	{$$ = makeNode("program");$$->child = makeNode("CONSTANTS");
																		$$->child->sibling = AssignNode($2);
																		$$->child->sibling->sibling=makeNode("FUNCTIONS");
																		$$->child->sibling->sibling->sibling=makeNode("MAIN");
																		$$->child->sibling->sibling->sibling->sibling =AssignNode($5);
																		root =$$;printf("\nAbstract Syntax Tree\n");printtree(root,printind);printSymTab(ind);}
			|	CONSTANTS FUNCTIONS functiondefinitions MAIN statements {$$ = makeNode("program");$$->child = makeNode("CONSTANTS");
																		$$->child->sibling=makeNode("FUNCTIONS");
																		$$->child->sibling->sibling->=AssignNode($3);
																		$$->child->sibling->sibling->sibling=makeNode("MAIN");
																		$$->child->sibling->sibling->sibling->sibling->=AssignNode($5);
																		root =$$;printf("\nAbstract Syntax Tree\n");printtree(root,printind);printSymTab(ind);}
			;
constantdefinitions	:	constantdefinition constantdefinitions			{$$ = makeNode("constantdefinitions");$$->child = AssignNode($1);
											$$->child->sibling=AssignNode($2);}
					|						{$$ = NULL;}
					;

constantdefinition	:	openbracket constantname scalarparameter closebracket		{addtoSymTab($2->child->Nodename,$3->child->Nodename,0);
													$$ = makeNode("constantdefinition");
													$$->child = AssignNode($2);$$->child ->sibling = AssignNode($3);};

constantname	:	identifier									{$$ = makeNode("constantname");$$->child = makeNode($1);};

scalarparameter		:	number								{$$ = makeNode("scalarparameter");$$->child = makeNode($1);}
					|	Boolean						{$$ = makeNode("scalarparameter");$$->child = makeNode($1);}
					|	string							{$$ = makeNode("scalarparameter");$$->child = makeNode($1);}
					;
number		:	INTEGER									{$$=$1;}
			|	FLOAT									{$$=$1;}
			;

functiondefinitions	:	functiondefinition functiondefinitions				{$$ = makeNode("functiondefinitions");$$->child =AssignNode($1);$$->child->sibling=AssignNode($2);}
					|								{$$ = NULL;}
					;

functiondefinition	:	openbracket functionname arguments returnkey returnarg  statements closebracket	{$$ = makeNode("functiondefinition");$$->child =AssignNode($2);$$->child->sibling=AssignNode($3);
														$$->child->sibling->sibling=makeNode($4);$$->child->sibling->sibling->sibling=AssignNode($5);
														$$->child->sibling->sibling->sibling->sibling=AssignNode($6);};//$$->instrCnt=$6->instrCnt;};

arguments	:	argument arguments								{$$ = makeNode("arguments");$$->child = AssignNode($1);$$->child->sibling=AssignNode($2);}
			|	argument								{$$ = makeNode("arguments");$$->child = AssignNode($1);}
			;

argument	:	identifier									{addtoSymTab($1,0,1);
													$$ = makeNode("argument");$$->child = makeNode($1);};

returnarg	:	identifier							{addtoSymTab($1,0,1);
													$$ = makeNode("returnarg");$$->child = makeNode($1);};

statements	:	statement statements			{$$ = makeNode("statements");$$->child = AssignNode($1);$$->child->sibling=AssignNode($2);
												$$->instrCnt=(($1->instrCnt)+($2->instrCnt));}
			|									{$$ = makeNode("");}
			;

statement	:	assignmentstmt							{$$ = makeNode("statement");$$->child = AssignNode($1);$$->instrCnt = $1->instrCnt;}
			|	readstmt								{$$ = makeNode("statement");$$->child = AssignNode($1);$$->instrCnt = $1->instrCnt;}
			|	printstmt								{$$ = makeNode("statement");$$->child = AssignNode($1);$$->instrCnt = $1->instrCnt;}
			|	ifstmt									{$$ = makeNode("statement");$$->child = AssignNode($1);$$->instrCnt = $1->instrCnt;}
			|	loopstmt								{$$ = makeNode("statement");$$->child = AssignNode($1);$$->instrCnt = $1->instrCnt;}
			|	whilestmt								{$$ = makeNode("statement");$$->child = AssignNode($1);$$->instrCnt = $1->instrCnt;}
			;

assignmentstmt	:	openbracket equal identifier parameter closebracket		{addtoSymTab($3,0,1);
																			$$ = makeNode("assignmentstmt");$$->child = makeNode($2);$$->child->sibling=makeNode($3);
																			$$->child->sibling->sibling=AssignNode($4);$$->instrCnt+=2;};

readstmt		:	openbracket readkey identify closebracket				{$$ = makeNode("readstmt");$$->child = makeNode($2);$$->child->sibling=AssignNode($3);
																			$$->instrCnt+=1;};

identify		:	identifier identify 							{addtoSymTab($1,0,1);
																	$$ = makeNode("identify");$$->child=makeNode($1);$$->child->sibling = AssignNode($2);}
				|	identifier							{addtoSymTab($1,0,1);
													$$ = makeNode("identify");$$->child = makeNode($1);}
				;

printstmt		:	openbracket printkey printparameters closebracket	{$$ = makeNode("printstmt");$$->child = makeNode($2);$$->child->sibling= AssignNode($3);
																			$$->instrCnt+=1;};

printparameters		:	printparameter printparameters			{$$ = makeNode("printparameters");$$->child = AssignNode($1);$$->child->sibling= AssignNode($2);}
					|	printparameter				{$$ = makeNode("printparameters");$$->child = AssignNode($1);}
					;

parameter		:	functioncall							{$$ = makeNode("parameter");$$->child = AssignNode($1);}//$$->instrCnt=$1->instrCnt;}
				|	identifier						{addtoSymTab($1,0,1);
															$$ = makeNode("parameter");$$->child = makeNode($1);}
				|	number										{$$ = makeNode("parameter");$$->child = makeNode($1);}
				;

functioncall		:	openbracket functionname parameters closebracket		{$$ = makeNode("functioncall");$$->child = AssignNode($2);$$->child->sibling= AssignNode($3);};
												//$$->instrCnt+=1;};

functionname		:	identifier							{//addtoSymTab($1,0,1);
												$$ = makeNode("functionname");$$->child = makeNode($1);}
					|	predefinedfunc				{$$ = makeNode("functionname");$$->child = AssignNode($1);}
					;

predefinedfunc		:	predefinedfunction					{$$ = makeNode("predefinedfunc");$$->child = makeNode($1);};

parameters		:	parameter parameters						{$$ = makeNode("parameters");$$->child = AssignNode($1);$$->child->sibling=AssignNode($2);}
												//$$->instrCnt=(($1->instrCnt)+($2->instrCnt));}
			|									{$$ = NULL;}
			;

printparameter		:	identifier 						{addtoSymTab($1,0,1);
												$$ = makeNode("printparameter");$$->child = makeNode($1);}
			| 	scalarparameter						{$$ = makeNode("printparameter");$$->child = AssignNode($1);}
			;

expression		:	openbracket compareoperator parameter parameter closebracket		{$$ = makeNode("expression");$$->child = AssignNode($2);$$->child->sibling=AssignNode($3);
																						$$->child->sibling->sibling=AssignNode($4);$$->instrCnt+=1;}
														//$$->instrCnt=(($3->instrCnt)+(s4->instrCnt));}
			|	openbracket Boolean closebracket										{$$ = makeNode("expression");$$->child = makeNode($2);$$->instrCnt+=1;}
			;

ifstmt		:	openbracket ifkey expression thenkey statements elsekey statements closebracket	{$$ = makeNode("ifstmt");$$->child = makeNode($2);$$->child->sibling=AssignNode($3);
														$$->child->sibling->sibling=makeNode($4);$$->child->sibling->sibling->sibling=AssignNode($5);
														$$->child->sibling->sibling->sibling->sibling=makeNode($6);
														$$->child->sibling->sibling->sibling->sibling->sibling=AssignNode($7);
														$$->instrCnt=(($3->instrCnt)+($5->instrCnt)+($7->instrCnt));};

loopstmt		:	openbracket loopkey identifier statements closebracket			{addtoSymTab($3,0,1);
														$$ = makeNode("loopstmt");$$->child = makeNode($2);$$->child->sibling=makeNode($3);
														$$->child->sibling->sibling=AssignNode($4);$$->instrCnt=$4->instrCnt;};

whilestmt		:	openbracket whilekey expression statements closebracket			{$$ = makeNode("whilestmt");$$->child = makeNode($2);$$->child->sibling=AssignNode($3);
																					$$->child->sibling->sibling=AssignNode($4);$$->instrCnt=(($3->instrCnt)+($4->instrCnt));};

compareoperator		:	comparisonoperator							{$$ = makeNode("compareoperator");$$->child = makeNode($1);};


%%


Node *AssignNode(Node *n){
	Node *newnode = (Node*) malloc (sizeof(Node));
	newnode = n;
	//newnode->instrCnt=0;
	return newnode;
}

Node *makeNode(char *val){
	Node *newnode = (Node*) malloc (sizeof(Node));
	newnode->Nodename = val;
	newnode->child = NULL;
	newnode->sibling = NULL;
	newnode->instrCnt = 0;
	return newnode;
}

void printtree(Node *root, int printind){
	if(root){
		printf("%*s" "%s\n",2*printind," ",root->Nodename); 
		printind++;
		printtree(root->child,printind);
		printtree(root->sibling,printind);
	}		
}

void addtoSymTab(char *n,char *v,int addr){
	int flag = lookup(n);
	
	if(flag==0){
		symtab[ind].val = v;
		symtab[ind].name = n;
		symtab[ind].type = "string";

		if(addr==0){
			symtab[ind].addr = addr;
		}
		else{
			if(lastAddr <99){
				symtab[ind].addr = lastAddr;
				lastAddr++;
			}
		}
		ind++;
	}
}


int lookup(char *name){
	int flag =0;
	int j=0;
	for(;j<ind;j++){
		if (strcmp(symtab[j].name,name)==0){
			flag = 1;
			break;
		}
	}
	return flag;
}

void printSymTab(int index){
printf("\nSymbol Table\n");
	int i=0;
	for(;i<index;i++){
		printf("\n");
		printf("name : %s\n",symtab[i].name);
		printf("value : %s\n",symtab[i].val);
		printf("addr : %d\n",symtab[i].addr); 
		printf("type : %s\n",symtab[i].type);
	}
}

int SymtabLookup(char *name){
	int i=0;
	int memaddr;
	for(;i<ind;i++){
		if (strcmp(symtab[i].name,name)==0){
			memaddr = symtab[i].addr;			
			break;
		}
	}
	return memaddr;
}

int SymtabValLookup(char *name){
	int i=0;
	int iden_val;
	for(;i<ind;i++){
		if (strcmp(symtab[i].name,name)==0){
			iden_val = atoi(symtab[i].val);			
			break;
		}
	}
	return iden_val;
}

void NestedCodeGen(Node *stmtsNode){
	if(strcmp(stmtsNode ->Nodename,"statements")==0){
		Node *stNode = stmtsNode ->child;
		Node *allstNode = stmtsNode ->child->child;
		//printf("in stNode %s\n",stNode->Nodename);
		//printf("in allstNode %s\n",allstNode ->Nodename);

		while(stNode!=NULL ){
			if(strcmp(stNode->Nodename,"")==0){
				return;
			}
			if(strcmp(stNode->Nodename,"statements")==0){
				stNode = stNode ->child;
				allstNode = stNode->child;
				//printf("in st %s\n",stNode ->Nodename);
				//printf("in all %s\n",allstNode ->Nodename);
			}
					
			if(strcmp(allstNode->Nodename,"readstmt")==0){
				Node *IdentNode = allstNode->child->sibling;
					while(IdentNode!=NULL){
						if(strcmp(IdentNode->Nodename,"identify")==0){
							IdentNode = IdentNode->child;
							int MAddr = SymtabLookup(IdentNode->Nodename);
							mcline++;
							fprintf(fileout,"read M[%d];\n",MAddr);
						}
						IdentNode = IdentNode->sibling;
					}	
			}
			else if(strcmp(allstNode->Nodename,"printstmt")==0){
				Node *IdentNode = allstNode->child->sibling;
				//printf("in p")t %s\n",IdentNode->Nodename);
				fprintf(fileout,"print");
				while(IdentNode!=NULL){
					if(strcmp(IdentNode->Nodename,"printparameters")==0){
						IdentNode = IdentNode->child;
						//printf("in pt %s\n",IdentNode->child->Nodename);
							if(strcmp(IdentNode->child->Nodename,"scalarparameter")==0){
								fprintf(fileout," %s",IdentNode->child->child->Nodename);
							}
							else{									
								int MAddr = SymtabLookup(IdentNode->child->Nodename);
								fprintf(fileout," M[%d]",MAddr);
							}								
					}
					//printf("in pt %s",IdentNode->sibling->Nodename);
					IdentNode = IdentNode->sibling;
				}
				mcline++;
				fprintf(fileout,";\n");
				//mcline++;
				//printf("%d\n",mcline);
			}
			
			else if(strcmp(allstNode->Nodename,"ifstmt")==0){
				Node *IdentNode = allstNode->child->sibling;		//"expr" node
				Node *ExprNode = IdentNode->child->sibling;			//param1 node
				Node *ExprNode2 = ExprNode->sibling;				//param2 node
				Node *ThenStmt = IdentNode->sibling->sibling;		//then stmts
				Node *elseStmt = IdentNode->sibling->sibling->sibling->sibling;	//else stmts
				/*printf("in expression %s\n",IdentNode->Nodename);			//"expression"
				printf("in ExprNode %s\n",ExprNode->Nodename);			//"param"
				printf("in ThenStmt %s\n",ThenStmt->Nodename);
				printf("in elseStmt %s\n",elseStmt->Nodename);
				printf("in ExprNode2 %s\n",allstNode->child->sibling->child->sibling->sibling->child->Nodename);*/

				if(strcmp(ExprNode->child->Nodename,"functioncall")!=0){
					int numcheck = lookup(ExprNode->child->Nodename);
						if(numcheck==0){
							mcline++;
							fprintf(fileout,"load R%d %s;\n",lastReg,ExprNode->child->Nodename);
							//printf("load R%d %s;\n",lastReg,ExprNode->child->Nodename);
							//int reg = lastReg;
							//lastReg++;
							//fprintf(fileout,"%s R%d R%d %s;\n",IdentNode->child->child->Nodename,lastReg,reg,ExprNode->child->Nodename);
							//printf("%s R%d R%d %s;\n",IdentNode->child->child->Nodename,lastReg,reg,ExprNode->child->Nodename);
							//lastReg++;									
						}
						else{
							int MAddr = SymtabLookup(ExprNode->child->Nodename);
							mcline++;
							fprintf(fileout,"load R%d M[%d];\n",lastReg,MAddr);
							//mcline++;
							//printf("load R%d M[%d];\n",lastReg,MAddr);
							/*int reg = lastReg;
							lastReg++;
							fprintf(fileout,"%s R%d R%d M[%d];\n",IdentNode->child->child->Nodename,lastReg,reg,MAddr);
							//printf("%s R%d R%d M[%d];\n",IdentNode->child->child->Nodename,lastReg,reg,MAddr);
							int reg1 = lastReg;
							lastReg++;
							*/
						}								
				}
				if(strcmp(ExprNode2->child->Nodename,"functioncall")!=0){
					int numcheck = lookup(ExprNode2->child->Nodename);
								if(numcheck==0){
									/*fprintf(fileout,"load R%d %s;\n",lastReg,ExprNode2->child->Nodename);
									//printf("load R%d %s;\n",lastReg,ExprNode2->child->Nodename);
									int reg = lastReg;
									lastReg++;*/
									int reg = lastReg;
									lastReg++;
									mcline++;
									fprintf(fileout,"%s R%d R%d %s;\n",IdentNode->child->child->Nodename,lastReg,reg,ExprNode2->child->Nodename);
									//mcline++;
									//printf("%s R%d R%d %s;\n",IdentNode->child->child->Nodename,lastReg,reg,ExprNode2->child->Nodename);
									int reg1 = lastReg;
									lastReg++;
									int mc = mcline;
									int elseNum = elseStmt->instrCnt;
									mcline++;
									fprintf(fileout,"if R%d %d;\n",reg1,mc+1+elseNum+1+1);
									//printf("if R%d %d\n",reg1,mc+1+elseNum);
									NestedCodeGen(elseStmt);
									int thenstNum = ThenStmt->instrCnt;
									mcline++;
									mc = mcline;
									fprintf(fileout,"goto %d\n",mc +1+thenstNum);
									NestedCodeGen(ThenStmt);

								}
								else{
									int MAddr = SymtabLookup(ExprNode2->child->Nodename);
									//fprintf(fileout,"load R%d M[%d];\n",lastReg,MAddr);
									//printf("load R%d M[%d];\n",lastReg,MAddr);
									int reg = lastReg;
									lastReg++;
									mcline++;
									fprintf(fileout,"%s R%d R%d M[%d];\n",IdentNode->child->child->Nodename,lastReg,reg,MAddr);
									//mcline++;
									//printf("%s R%d R%d M[%d];\n",IdentNode->child->child->Nodename,lastReg,reg,MAddr);
									int reg1 = lastReg;
									lastReg++;
									int mc = mcline;
									int elseNum = elseStmt->instrCnt;
									mcline++;
									fprintf(fileout,"if R%d %d;\n",reg1,mc+1+elseNum+1+1);
									//printf("if R%d %d;\n",reg1,mc+1+elseNum);
									NestedCodeGen(elseStmt);
									int thenstNum = ThenStmt->instrCnt;
									mcline++;
									mc = mcline;
									fprintf(fileout,"goto %d\n",mc +1+thenstNum);
									NestedCodeGen(ThenStmt);
								}
							
				}
			}

			/*else if(strcmp(allstNode->Nodename,"ifstmt")==0){
						Node *IdentNode = allstNode->child->sibling;		//"expr" node
						Node *ExprNode = IdentNode->child->sibling;
						Node *ExprNode2 = ExprNode->sibling;
						Node *ThenStmt = IdentNode->sibling->sibling;		// then stmt
						Node *elseStmt = IdentNode->sibling->sibling->sibling->sibling;
						//printf("in -- pt %s\n",IdentNode->Nodename);			//"expression"
						//printf("in --- pt %s\n",ExprNode->Nodename)			//"param"
						
						//IfExpressionCodeGen(ExprNode,ExprNode2,elseStmt,IdentNode);
						ExpressionCodeGen(ExprNode);
						int reg1 = lastReg;
						lastReg++;
						int mc = mcline;
						int elseNum = elseStmt->instrCnt;
						fprintf(fileout,"if R%d %d;\n",reg1,mc+1+elseNum+1);
						NestedCodeGen(elseStmt);
						int thenstNum = ThenStmt->instrCnt;
						mc = mcline;
						fprintf(fileout,"goto %d\n",mc +1+thenstNum);					
			}*/

					else if(strcmp(allstNode->Nodename,"assignmentstmt")==0){
						Node *IdentNode = allstNode->child->sibling;
						Node *tempIden = IdentNode->sibling;
						//printf("in p")t %s\n",IdentNode->Nodename);
						if(strcmp(tempIden->child->Nodename,"functioncall")!=0){
							int numcheck = lookup(tempIden->child->Nodename);
								if(numcheck==0){
									mcline++;
									fprintf(fileout,"load R%d %s;\n",lastReg,tempIden->child->Nodename);
									//mcline++;
									lastReg++;
								}
								else{
									int MAddr = SymtabLookup(tempIden->child->Nodename);
									mcline++;
									fprintf(fileout,"load R%d M[%d];\n",lastReg,MAddr);
									//mcline++;
									lastReg++;
								}								
						}
						int MAddr = SymtabLookup(IdentNode->Nodename);
						mcline++;
						fprintf(fileout,"store M[%d] R%d;\n",MAddr,lastReg);
						//mcline++;
						lastReg--;			
							//printf("in pt %s",IdentNode->sibling->Nodename);
							//IdentNode = IdentNode->sibling;
					}			
					
				stNode = stNode->sibling;
		}
	}
}

// routine for parameter

void ExpressionCodeGen(Node* temp){
	Node *CompNode = temp->child;
	Node *tempIden = temp->child->sibling;
	while(tempIden!=NULL){
	if(strcmp(tempIden->child->Nodename,"functioncall")!=0){
		int numcheck = lookup(tempIden->child->Nodename);
		if(numcheck==0){
			mcline++;
			fprintf(fileout,"load R%d %s;\n",lastReg,tempIden->child->Nodename);
			int reg = lastReg;
			lastReg++;
			mcline++;
			fprintf(fileout,"%s R%d R%d %s;\n",CompNode->child->Nodename,lastReg,reg,tempIden->child->Nodename);
			//printf("%s R%d R%d %s;\n",CompNode->child->Nodename,lastReg,reg,tempIden->child->Nodename);
			lastReg++;
		}
		else{
			int MAddr = SymtabLookup(tempIden->child->Nodename);
			mcline++;
			fprintf(fileout,"load R%d M[%d];\n",lastReg,MAddr);
			int reg = lastReg;
			lastReg++;
			mcline++;
			fprintf(fileout,"%s R%d R%d M[%d];\n",CompNode->child->Nodename,lastReg,reg,MAddr);
			//printf("%s R%d R%d M[%d];\n",CompNode->child->Nodename,lastReg,reg,MAddr);
		}								
	}
	
	if(strcmp(tempIden->child->Nodename,"functioncall")==0){
		Node *Fname = tempIden->child->child;
		
		
	}
	tempIden=tempIden->sibling;
	}
}


void CodeGen (Node *start){
	if(start==NULL){
		return;
	}
	
	Node *mainNode = start->child->sibling->sibling->sibling->sibling;					//main Node
		//printf("in mainNode %s\n",mainNode ->Nodename);						//main

	if(strcmp(mainNode ->Nodename,"MAIN")==0){
		if(mainNode ->sibling!=NULL){									//check if stmts!0
			//printf("in stmtsNode %s\n",mainNode ->sibling->Nodename);						//stmts
			Node *stmtsNode = mainNode ->sibling;							//stmt
			//printf("in stmtsNode %s\n",stmtsNode ->Nodename);
			
			if(strcmp(stmtsNode ->Nodename,"statements")==0){
				Node *stNode = stmtsNode ->child;
				Node *allstNode = stmtsNode ->child->child;
				//printf("in stNode %s\n",stNode->Nodename);
				//printf("in allstNode %s\n",allstNode ->Nodename);

			while(stNode!=NULL){
					if(strcmp(stNode->Nodename,"")==0){
						return;
					} 
					if(strcmp(stNode->Nodename,"statements")==0){
						stNode = stNode ->child;
						allstNode = stNode->child;
						//printf("in st %s\n",stNode ->Nodename);
						//printf("in all %s\n",allstNode ->Nodename);
					}
					
					if(strcmp(allstNode->Nodename,"readstmt")==0){
						Node *IdentNode = allstNode->child->sibling;
						//printf("in - pt %s\n",allstNode->Nodename);
						//printf("in -- pt %s\n",IdentNode->Nodename);
						while(IdentNode!=NULL){
							if(strcmp(IdentNode->Nodename,"identify")==0){
								IdentNode = IdentNode->child;
								int MAddr = SymtabLookup(IdentNode->Nodename);
								mcline++;

								fprintf(fileout,"read M[%d];\n",MAddr);
							}
							IdentNode = IdentNode->sibling;
						}	
					}
					
					else if(strcmp(allstNode->Nodename,"printstmt")==0){
						Node *IdentNode = allstNode->child->sibling;
						//printf("in- pt %s\n",allstNode->Nodename);
						//printf("in-- pt %s\n",IdentNode->Nodename);
						fprintf(fileout,"print");
						while(IdentNode!=NULL){
							if(strcmp(IdentNode->Nodename,"printparameters")==0){
								IdentNode = IdentNode->child;
								//printf("in pt %s\n",IdentNode->child->Nodename);
								if(strcmp(IdentNode->child->Nodename,"scalarparameter")==0){
									fprintf(fileout," %s",IdentNode->child->child->Nodename);
								}
								else{									
									int MAddr = SymtabLookup(IdentNode->child->Nodename);
									fprintf(fileout," M[%d]",MAddr);
								}								
							}
							//printf("in pt %s",IdentNode->Nodename);
							IdentNode = IdentNode->sibling;
							//printf("in next ident pt %s\n",IdentNode->Nodename);
						}
						mcline++;
						fprintf(fileout,";\n");
						//mcline++;
						//printf("%d\n",mcline);
					}

					/*else if(strcmp(allstNode->Nodename,"ifstmt")==0){
						Node *IdentNode = allstNode->child->sibling;		//"expr" node
						Node *ExprNode = IdentNode->child->sibling;
						Node *ExprNode2 = ExprNode->sibling;
						Node *ThenStmt = IdentNode->sibling->sibling;		// then stmt
						Node *elseStmt = IdentNode->sibling->sibling->sibling->sibling;
						//printf("in -- pt %s\n",IdentNode->Nodename);			//"expression"
						//printf("in --- pt %s\n",ExprNode->Nodename)			//"param"
						
						//IfExpressionCodeGen(ExprNode,ExprNode2,elseStmt,IdentNode);
						ExpressionCodeGen(ExprNode);
						int reg1 = lastReg;
						lastReg++;
						int mc = mcline;
						int elseNum = elseStmt->instrCnt;
						fprintf(fileout,"if R%d %d;\n",reg1,mc+1+elseNum+1);
						NestedCodeGen(elseStmt);
						int thenstNum = ThenStmt->instrCnt;
						mc = mcline;
						fprintf(fileout,"goto %d\n",mc +1+thenstNum);					
					}*/
					
					
			else if(strcmp(allstNode->Nodename,"ifstmt")==0){
				Node *IdentNode = allstNode->child->sibling;		//"expr" node
				Node *ExprNode = IdentNode->child->sibling;			//param1 node
				Node *ExprNode2 = ExprNode->sibling;				//param2 node
				Node *ThenStmt = IdentNode->sibling->sibling;		//then stmts
				Node *elseStmt = IdentNode->sibling->sibling->sibling->sibling;	//else stmts
				/*printf("in expression %s\n",IdentNode->Nodename);			//"expression"
				printf("in ExprNode %s\n",ExprNode->Nodename);			//"param"
				printf("in ThenStmt %s\n",ThenStmt->Nodename);
				printf("in elseStmt %s\n",elseStmt->Nodename);
				printf("in ExprNode2 %s\n",allstNode->child->sibling->child->sibling->sibling->child->Nodename);*/

				if(strcmp(ExprNode->child->Nodename,"functioncall")!=0){
					int numcheck = lookup(ExprNode->child->Nodename);
						if(numcheck==0){
							mcline++;
							fprintf(fileout,"load R%d %s;\n",lastReg,ExprNode->child->Nodename);
							//printf("load R%d %s;\n",lastReg,ExprNode->child->Nodename);
							//int reg = lastReg;
							//lastReg++;
							//fprintf(fileout,"%s R%d R%d %s;\n",IdentNode->child->child->Nodename,lastReg,reg,ExprNode->child->Nodename);
							//printf("%s R%d R%d %s;\n",IdentNode->child->child->Nodename,lastReg,reg,ExprNode->child->Nodename);
							//lastReg++;									
						}
						else{
							int MAddr = SymtabLookup(ExprNode->child->Nodename);
							mcline++;
							fprintf(fileout,"load R%d M[%d];\n",lastReg,MAddr);
							//mcline++;
							//printf("load R%d M[%d];\n",lastReg,MAddr);
							/*int reg = lastReg;
							lastReg++;
							fprintf(fileout,"%s R%d R%d M[%d];\n",IdentNode->child->child->Nodename,lastReg,reg,MAddr);
							//printf("%s R%d R%d M[%d];\n",IdentNode->child->child->Nodename,lastReg,reg,MAddr);
							int reg1 = lastReg;
							lastReg++;
							*/
						}								
				}
				if(strcmp(ExprNode2->child->Nodename,"functioncall")!=0){
					int numcheck = lookup(ExprNode2->child->Nodename);
								if(numcheck==0){
									/*fprintf(fileout,"load R%d %s;\n",lastReg,ExprNode2->child->Nodename);
									//printf("load R%d %s;\n",lastReg,ExprNode2->child->Nodename);
									int reg = lastReg;
									lastReg++;*/
									int reg = lastReg;
									lastReg++;
									mcline++;
									fprintf(fileout,"%s R%d R%d %s;\n",IdentNode->child->child->Nodename,lastReg,reg,ExprNode2->child->Nodename);
									//mcline++;
									//printf("%s R%d R%d %s;\n",IdentNode->child->child->Nodename,lastReg,reg,ExprNode2->child->Nodename);
									int reg1 = lastReg;
									lastReg++;
									int mc = mcline;
									int elseNum = elseStmt->instrCnt;
									mcline++;
									fprintf(fileout,"if R%d %d;\n",reg1,mc+1+elseNum+1+1);
									//printf("if R%d %d\n",reg1,mc+1+elseNum);
									NestedCodeGen(elseStmt);
									int thenstNum = ThenStmt->instrCnt;
									mcline++;
									mc = mcline;
									fprintf(fileout,"goto %d\n",mc +1+thenstNum);
									NestedCodeGen(ThenStmt);

								}
								else{
									int MAddr = SymtabLookup(ExprNode2->child->Nodename);
									//fprintf(fileout,"load R%d M[%d];\n",lastReg,MAddr);
									//printf("load R%d M[%d];\n",lastReg,MAddr);
									int reg = lastReg;
									lastReg++;
									mcline++;
									fprintf(fileout,"%s R%d R%d M[%d];\n",IdentNode->child->child->Nodename,lastReg,reg,MAddr);
									//mcline++;
									//printf("%s R%d R%d M[%d];\n",IdentNode->child->child->Nodename,lastReg,reg,MAddr);
									int reg1 = lastReg;
									lastReg++;
									int mc = mcline;
									int elseNum = elseStmt->instrCnt;
									mcline++;
									fprintf(fileout,"if R%d %d;\n",reg1,mc+1+elseNum+1+1);
									//printf("if R%d %d;\n",reg1,mc+1+elseNum);
									NestedCodeGen(elseStmt);
									int thenstNum = ThenStmt->instrCnt;
									mcline++;
									mc = mcline;
									fprintf(fileout,"goto %d\n",mc +1+thenstNum);
									NestedCodeGen(ThenStmt);
								}
							
				}
			}

					else if(strcmp(allstNode->Nodename,"assignmentstmt")==0){
						Node *IdentNode = allstNode->child->sibling;
						Node *tempIden = IdentNode->sibling;
						//printf("in p")t %s\n",IdentNode->Nodename);
						if(strcmp(tempIden->child->Nodename,"functioncall")!=0){
							int numcheck = lookup(tempIden->child->Nodename);
								if(numcheck==0){
									mcline++;
									fprintf(fileout,"load R%d %s;\n",lastReg,tempIden->child->Nodename);
									//mcline++;
									lastReg++;
								}
								else{
									int MAddr = SymtabLookup(tempIden->child->Nodename);
									mcline++;
									fprintf(fileout,"load R%d M[%d];\n",lastReg,MAddr);
									//mcline++;
									lastReg++;
								}								
						}
						int MAddr = SymtabLookup(IdentNode->Nodename);
						mcline++;
						fprintf(fileout,"store M[%d] R%d;\n",MAddr,lastReg);
						//mcline++;
						lastReg--;			
							//printf("in pt %s",IdentNode->sibling->Nodename);
							//IdentNode = IdentNode->sibling;
					}
					
					else if(strcmp(allstNode->Nodename,"whilestmt")==0){
						Node *whileExprNode = allstNode->child->sibling;	//"expr"
						int whileInstrCnt = allstNode->instrCnt;			
						Node *whileStmtNode = whileExprNode ->sibling;		//"stmts"
						ExpressionCodeGen(whileExprNode);
						NestedCodeGen(whileStmtNode);
						int mc = mcline;
						//printf("while stmt %d\n",mc);
						fprintf(fileout,"goto %d;\n",mc-whileInstrCnt+1);
					}
					
					else if(strcmp(allstNode->Nodename,"loopstmt")==0){
						Node *loopNode = allstNode->child;
						int loopInstrCnt = loopNode->sibling->sibling->instrCnt;
						Node *tempvar = makeNode("loopVar");
						addtoSymTab("loopvar",0,1);
						//printf("load R%d %d;\n",lastReg,0);
						mcline++;
						fprintf(fileout,"load R%d %d;\n",lastReg,0);
						int reg = lastReg;
						lastReg++;
						char *optr = "<";
						int MAddr = SymtabLookup(loopNode->sibling->Nodename);
						//printf("%s R%d R%d M%d;\n", "<",lastReg,reg,MAddr);
						mcline++;
						fprintf(fileout,"%s R%d R%d M%d;\n", "<",lastReg,reg,MAddr);
						int reg1 = lastReg;
						lastReg++;
						int mc = mcline;
						mcline++;
						fprintf(fileout,"if R%d %d;\n",reg1,mc+1+loopInstrCnt+1);
						//printf("if R%d %d;\n",reg1,mc+1+loopInstrCnt+1);
						NestedCodeGen(loopNode->sibling->sibling);
						mcline++;
						fprintf(fileout,"add R%d R%d %d;\n",reg, reg,1);
						//printf("add R%d R%d %d;\n",reg, reg,1);
						mcline++;
						fprintf(fileout,"goto %d;\n", mc);
						//printf("goto %d;\n", mc);
						//printf("mcline %d;\n", mcline);
					}				
					////printf("in next stNode pt %s\n",stNode->Nodename);										
				
				stNode = stNode->sibling;
			}
			}
		}
	}
}

/*int get_Reg(int last){
	int reg;
	if(last+1< 9){
		lastReg++;
	}
	return reg;
}*/

/* C code */

int main (int argc,char *argv[]) {
	yy_flex_debug=1;
/*if(argc > 1) {
		FILE *file;
		FILE *fileout;
		file = fopen(argv[], "r");
		if(!file) {
			fprintf(stderr, "File not found %s \n", argv[1]);
			exit(1);
		}
		yyin = file;
	}*/
	yyparse ( );
	fileout = fopen(argv[1],"w");
	CodeGen(root);
	fclose(fileout);
	return 0;
}

void yyerror (char *s) 
{
	fprintf (stderr, "%s\n", s);
} 