#!/usr/bin/env python3
import sys
import json

PRINTK = r'bpf_printk("Mod is: %d.", i);'
IF = "if"
AND = "&&"
BLOCKSTART = "{"
BLOCKEND = "}"

output = []

if (len(sys.argv) != 2):
    print("Usage: generate_workload.py n_of_leafs")
    print("Tree must be perfectly balanced")
    exit(1)

n = int(sys.argv[1])

def WITHIN(num1, num2):
    return "({} <= i && i < {})".format(num1, num2)
def EXACT(num1):
    return "(i == {})".format(num1)

def generate_work(lb,ub):
    if (ub - lb) > 1:
        output.append(IF + WITHIN(lb, ub) + BLOCKSTART)
        output.append('\n')
        generate_work(int(lb), lb + int((ub - lb)/2))
        generate_work(lb + int((ub - lb)/2), int(ub))
        output.append(BLOCKEND)
        output.append('\n')
    else:
        output.append(IF + EXACT(lb))
        output.append(BLOCKSTART)
        output.append('\n')
        output.append(PRINTK)
        output.append('\n')
        output.append(BLOCKEND)
        output.append('\n')

generate_work(0, n)
print(json.dumps(''.join(output))[1:-1])
