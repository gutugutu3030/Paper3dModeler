from graphillion import GraphSet
import graphillion.tutorial as tl
import sys
import GraphillionPathLib as gpl

param = sys.argv
#print(param)

def findShortestPath(graph,sg):
    #graph=[(1,2),(1,3),(3,4),(2,4),(1,4)]
    #sg=[[2,3]]

    GraphSet.set_universe(graph)
    list1=list()
    for sg1 in sg:
        roots=GraphSet.paths(sg1[0],sg1[1])
        list1.append(roots.min_iter().next())
        #print(" ".join(map(str,roots.min_iter().next())))
    return list1
        
if (len(param)>=3):
    graph=eval(param[1])
    sg=eval(param[2])
    for r in findShortestPath(graph,sg):
        print(" ".join(map(str,gpl.toRoute(r))))

#for t in roots
 #   tl.draw(t)