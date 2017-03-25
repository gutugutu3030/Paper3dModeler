String getStrokeString(MatOfPoint mop) {
  return "";
}


ArrayList<StrokeParts> extractFreeStroke(PImage img) {
//  if (!jikki) {
//    new DebugWindow(this, "extractStrokeImage", img);
//  }

  int window=4;
  int map[][]=new int[img.width/window][img.height/window];
  println("img size:"+map.length+" "+map[0].length);
  img.loadPixels();
  //カラーマップの作成
  boolean exist[]=new boolean[6];
  for (int i=0+10; i<map.length-10; i++) {
    for (int j=0+10; j<map[0].length-10; j++) {
      int hist[]=new int[10];
      for (int k=0; k<window; k++) {
        for (int l=0; l<window; l++) {
          int c=img.pixels[i*window+k+(j*window+l)*img.width];
          if (judgePixel(c)) {
            hist[getId(c)]++;
          }
        }
      }
      int max=0;
      for (int k=1; k<hist.length; k++) {
        if (hist[max]<hist[k]) {
          max=k;
        }
      }
      if (hist[max]<=window*window/3) {
        map[i][j]=-1;
        continue;
      }
      map[i][j]=max;
      exist[map[i][j]]=true;
    }
  }
  ArrayList<StrokeParts> partsList=new ArrayList<StrokeParts>();
  for (int i=0; i<exist.length; i++) {
    if (!exist[i]) {
      continue;
    }
    try {
      Thinning thin=new Thinning(map, i);
      thin.process(8);
      StrokeParts parts=thin.getStrokeparts();
      partsList.add(parts);
    }
    catch(Exception e) {
      e.printStackTrace();
    }
  }
  return partsList;
}

