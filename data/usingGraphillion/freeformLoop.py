from graphillion import GraphSet
import graphillion.tutorial as tl
import sys

param = sys.argv

#graph=[(1,6,6),(1,2,9),(1,4,10),(2,4,3),(2,3,7),(3,4,5),(3,5,14),(4,5,9),(5,6,5),(1,5,11),(4,6,12)]
if (len(param)>=2):
    graph=eval(param[1])

GraphSet.set_universe(graph)
test=GraphSet.cycles(True)
list1=test.min_iter().next();


print(" ".join(map(str,map(lambda x:" ".join(map(str,x)),list1))))