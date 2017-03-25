def toRoute(taplelist):
    list1=list()
    if len(taplelist)<2:
        return list1
    
    if taplelist[0][0]==taplelist[1][0] or taplelist[0][0]==taplelist[1][1]:
        list1.append(taplelist[0][1])
    else :
        list1.append(taplelist[0][0])
    tmp=list1[0]
    for t in taplelist:
        if tmp==t[0]:
            list1.append(t[1])
            tmp=t[1]
        else:
            list1.append(t[0])
            tmp=t[0]
    return list1
