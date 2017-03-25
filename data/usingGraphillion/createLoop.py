from graphillion import GraphSet
import graphillion.tutorial as tl
import sys

param = sys.argv

graph=[(1,2),(2,3),(4,1),(3,6),(4,7),(6,9),(7,8),(8,9)]
parts=[[1,4,7],[2,3,6],[8,9]]
if (len(param)>=3):
    graph=eval(param[1])
    parts=eval(param[2])

GraphSet.set_universe(graph)



def toRoute(taplelist):
    list1=list()
    if len(taplelist)<2:
        return list1
    arrived=[False]*len(taplelist)
    next=None
    for i in range(len(taplelist)):
        only1_0=True
        only1_1=True
        for j in range(len(taplelist)):
            if i==j :
                continue
            if(taplelist[i][0]==taplelist[j][0] or taplelist[i][0]==taplelist[j][1]):
                only1_0=False
            if(taplelist[i][1]==taplelist[j][0] or taplelist[i][1]==taplelist[j][1]):
                only1_1=False
            if(only1_0==False and only1_1==False):
                break
        if only1_0:
            list1.append(taplelist[i][0])
            next=taplelist[i][1]
            arrived[i]=True
            break
        if only1_1:
            list1.append(taplelist[i][1])
            next=taplelist[i][0]
            arrived[i]=True
            break

#    for tap in taplelist:
#       if taplelist[0]==tap:
#           continue
#       if taplelist[0][0]==tap[0] or taplelist[0][0]==tap[1]:
#           list1.append(taplelist[0][1])
#           next=taplelist[0][0]
#           break
#       if taplelist[0][1]==tap[0] or taplelist[0][1]==tap[1]:
#           list1.append(taplelist[0][0])
#           next=taplelist[0][1]
#           break
    if next==None:
        return list1
    list1.append(next)
    for j in range(len(taplelist)-1):
        for i in range(len(taplelist)):
            if arrived[i]:
                continue
            if taplelist[i][0]==next:
                arrived[i]=True
                next=taplelist[i][1]
                list1.append(next)
                break
            if taplelist[i][1]==next:
                arrived[i]=True
                next=taplelist[i][0]
                list1.append(next)
                break
    #print(taplelist)
    #print(list1)
    return list1

def toRoute1(taplelist):
    list1=list()
    if len(taplelist)<2:
        return list1
    if taplelist[0][0]==taplelist[1][0] or taplelist[0][0]==taplelist[1][1] :
        list1.append(taplelist[0][1])
    else :
        list1.append(taplelist[0][0])
    tmp=list1[0]
    for t in taplelist:
        if(tmp==t[0]):
            list1.append(t[1])
            tmp=t[1]
        else :
            list1.append(t[0])
            tmp=t[0]
    return list1

def makeLoop(lists):
    r=GraphSet.paths(lists[len(lists)-1],lists[0])
    if len(r)==0:
        print("null")
    for i in range(1,len(lists)-1):
        r=r.excluding(lists[i])
    if len(r)==0:
        r=GraphSet.paths(lists[len(lists)-1],lists[0])
    r1=toRoute(r.min_iter().next())
    if(len(r1)<3):
        return lists
    list1=list(lists)
    if r1[0]!=lists[len(lists)-1] :
        r1.reverse();
    del r1[0]
    del r1[len(r1)-1]
    list1.extend(r1)
    return list1

if len(parts)==0 :
    print("null")
    sys.exit()

if len(parts)==1 :
    print(" ".join(map(str,makeLoop(parts[0]))))
    sys.exit();
master=parts[0]
del parts[0]

for aaa in range(0,len(parts)):
    route=None
    min=-1
    for i in range(0,len(parts)):
        p=parts[i]
        r1=GraphSet.paths(master[len(master)-1],p[0])
        r2=GraphSet.paths(master[len(master)-1],p[len(p)-1])
        r1=r1.excluding(master[0])
        r2=r2.excluding(master[0])
        if (len(r1)==0 and len(r2)==0):
            continue
        if min==-1:
            if (len(r2)==0):
                min=i*2
                route=r1.min_iter().next()
                continue
            if (len(r1)==0):
                min=i*2+1
                route=r2.min_iter().next()
                continue               
            t1=r1.min_iter().next()
            t2=r2.min_iter().next()
            if len(t1)<=len(t2):
                min=i*2
                route=t1
                continue
            min=i*2+1
            route=t2
            continue
        if len(r1)!=0:
            t1=r1.min_iter().next()
            if len(route)>len(t1):
                min=i*2
                route=t1
        if len(r1)!=0:
            t2=r2.min_iter().next()
            if len(route)>len(t2):
                min=i*2+1
                route=t2        
    if min==-1:
        continue
    next=parts[int(min)/2]
    del parts[int(min)/2]
    route1=toRoute(route)
    if (1<=len(route1)):
        master.extend(route1)
    if (int(min)%2==1):
        next.reverse()
    master.extend(next)
print(" ".join(map(str,makeLoop(master))))

