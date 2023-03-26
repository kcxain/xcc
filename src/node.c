#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "node.h"

Node *createNode(char *name, char *value)
{
    Node *pnode = (Node *)malloc(sizeof(Node));

    strcpy(pnode->name, name);
    strcpy(pnode->value, value);

    pnode->lineno = yylineno;
    // printf("%d", yylineno);
    pnode->childsum = 0;
    return pnode;
}


void addChild(int childsum, Node *parent, ...)
{
    va_list ap;
    va_start(ap, parent);
    parent->child = (Node **)malloc(sizeof(Node *) * childsum);        
    for (int i = 0; i < childsum; i++)
    {
        parent->child[i] = va_arg(ap, Node *);
    }
    parent->childsum = childsum;
    parent->lineno = parent->child[0]->lineno;
    va_end(ap);
}

void printTree(Node *parent, int blank)
{
    if (parent == NULL)
        return;
    for (int i = 0; i < blank; i++)
        printf(" ");
    if (parent->childsum != 0)
    {
        printf("%s (%d)\n", parent->name, parent->lineno);
        for (int i = 0; i < parent->childsum; i++)
        {
            printTree(parent->child[i], blank + 2);
        }
    }
    else
    {
        if (strcmp(parent->name, "INT") == 0)
        {
            printf("%s: %d\n", parent->name, atoi(parent->value));
        }
        else if (strcmp(parent->name, "FLOAT") == 0)
        {
            printf("%s: %f\n", parent->name, atof(parent->value));
        }
        else if (strcmp(parent->name, "ID") == 0 || strcmp(parent->name, "TYPE") == 0)
        {
            printf("%s: %s\n", parent->name, parent->value);
        }
        else
        {
            printf("%s\n", parent->name);
        }
    }
}