#ifndef NODE_H
#define NODE_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdarg.h>

extern int yylineno;

typedef struct ParseTree
{
    char name[32];
    char value[32];
    int lineno;
    struct ParseTree **child;
    int childsum;
} Node;

Node *createNode(char *name, char *text);

void addChild(int childsum, Node *parent, ...);

void printTree(Node *root, int blank);

#endif