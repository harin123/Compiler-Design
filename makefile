test: lex.yy.c y.tab.c
	gcc lex.yy.c y.tab.c -o cfp.exe

lex.yy.c: y.tab.c FP.lex
	lex FP.lex

y.tab.c: FP.yacc
	yacc -d FP.yacc