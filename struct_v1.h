#ifndef Struct_H
#define struct_H
#define MAX_SIZE 1000

typedef struct Node {

	//enum Nodetype nodetype;
	char *Nodename;
	struct Node *child;
	struct Node *sibling;
	int instrCnt;
} Node;

typedef struct SymbolTableNode {
	char *val;
	char *name;
	int addr;
	char *type;
	//char *newtype;
} SymbolTableNode;


Node *makeNode(char *val);
Node *AssignNode(Node *n);
void printtree(Node *root,int printind);
int lookup(char *n);
int SymtabLookup(char *name);

void addtoSymTab(char *name,char *val,int addr);
void printSymTab(int index);
void NestedCodeGen(Node *stmtsNode);
void CodeGen(Node *start);
void ExpressionCodeGen(Node* temp);
int get_Maddr(int last);

#endif