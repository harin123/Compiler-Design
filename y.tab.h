#define Boolean 257
#define string 258
#define CONSTANTS 259
#define FUNCTIONS 260
#define MAIN 261
#define loopkey 262
#define ifkey 263
#define elsekey 264
#define thenkey 265
#define whilekey 266
#define printkey 267
#define readkey 268
#define returnkey 269
#define identifier 270
#define predefinedfunction 271
#define comparisonoperator 272
#define openbracket 273
#define closebracket 274
#define equal 275
#define INTEGER 276
#define FLOAT 277
#ifdef YYSTYPE
#undef  YYSTYPE_IS_DECLARED
#define YYSTYPE_IS_DECLARED 1
#endif
#ifndef YYSTYPE_IS_DECLARED
#define YYSTYPE_IS_DECLARED 1
typedef union {int itype; float ftype; double dtype; char ctype; char* stype; Node *type;} YYSTYPE;
#endif /* !YYSTYPE_IS_DECLARED */
extern YYSTYPE yylval;
