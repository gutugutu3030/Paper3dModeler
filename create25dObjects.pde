Drawing create25dDrawing(ArrayList<StrokeParts> a, ArrayList<StrokeParts>b, int height) {
    if (a.size()<b.size()) {
        return create25dDrawing(b, height);
    }
    return create25dDrawing(a, height);
}
Drawing create25dDrawing(ArrayList<StrokeParts> stroke, int height) {
    Drawing drawing=new Drawing();
    for (StrokeParts s : stroke) {
        int id=s.id;
        float maxmin[]=s.getMaxMinX();
        StrokeParts sp1=new StrokeParts(id);
        sp1.add((int)maxmin[0], 0);
        sp1.add((int)maxmin[0], height);
        sp1.add((int)maxmin[1], height);
        sp1.add((int)maxmin[1], 0);
        DrawingParts dp=new DrawingParts();
        dp.setXYList(s.getList(0));
        dp.setXZList(sp1.getList(1));
        if (id>0) {
            drawing.add(dp);
        } else {
            drawing.sub(dp);
        }
    }
    return drawing;
}


/*
Drawing createDrawing(ArrayList<StrokeParts> front, ArrayList<StrokeParts> top) {
 Drawing drawing=new Drawing();
 for (StrokeParts s : front) {
 int id=s.id;
 for (StrokeParts s1 : top) {
 if (s1.id==id) {
 DrawingParts dp=new DrawingParts();
 if(guess){
 s.map(s1);
 }
 dp.setXYList(s1.getList(0));
 dp.setXZList(s.getList(1));
 if (s.id>0) {
 drawing.add(dp);
 } else {
 drawing.sub(dp);
 }
 break;
 }
 }
 }
 return drawing;
 }
 */
