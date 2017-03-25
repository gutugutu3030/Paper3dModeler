import xyz.gutugutu3030.graphillion.*;

CreateLoop cl;
CreateFreeformLoop cfl;

void initGraphillion() {
  cl=new CreateLoop(dataPath("usingGraphillion"));
  cfl=new CreateFreeformLoop(dataPath("usingGraphillion"));
}

String calcFreeformLoop(String str){
  try {
    cfl.solve(str);
  } 
  catch (Exception e) {
    e.printStackTrace();
  }
  String[] s = cfl.get();
  if (s == null) {
    System.out.println("失敗");
    return null;
  }
  println(Arrays.toString(s));
  return s[0];
}


String strokeparts2string(List<StrokeParts> list,int map[][]) {
  ArrayList<ArrayList<Integer>> tmp=new ArrayList<ArrayList<Integer>>();
  for (StrokeParts sp : list) {
    ArrayList<Integer> tmp1=new ArrayList<Integer>();
    for(int i[]:sp.s){
      tmp1.add(i[0]+i[1]*map.length);
    }
    tmp.add(tmp1);
  }
  return "\""+tmp.toString()+"\"";
}

String map2graph2(int map[][]) {
  StringBuilder sb = new StringBuilder();
  int d[][] = { 
    { 
      1, 0
    }
    , { 
      0, 1
    }
  };
  boolean first=true;
  sb.append("\"[");
  for (int x = 2; x < map.length - 1; x+=2) {
    for (int y = 2; y < map[0].length-1; y+=2) {
      if (map[x][y]==0) {
        continue;
      }
      for (int d1[] : d) {
        if (map[x+d1[0]*2][y+d1[1]*2]!=0) {
          int index1=x+y*map.length;
          int index2=x+d1[0]*2+(y+d1[1]*2)*map.length;
          if (first) {
            first=false;
          } else {
            sb.append(",");
          }
          sb.append("(");
          sb.append(index1);
          sb.append(",");
          sb.append(index2);
          sb.append(")");
        }
      }
    }
  }
  sb.append("]\"");
  return sb.toString();
}

String map2graph(int map[][]) {
  StringBuilder sb = new StringBuilder();
  int d[][] = { 
    { 
      1, 0
    }
    , { 
      0, 1
    }
  };
  boolean first=true;
  sb.append("\"[");
  for (int x = 2; x < map.length - 1; x+=2) {
    for (int y = 2; y < map[0].length-1; y+=2) {
      if (map[x][y]==0) {
        continue;
      }
      for (int d1[] : d) {
        if (map[x+d1[0]][y+d1[1]]!=0&&map[x+d1[0]*2][y+d1[1]*2]!=0) {
          int index1=x+y*map.length;
          int index2=x+d1[0]*2+(y+d1[1]*2)*map.length;
          if (first) {
            first=false;
          } else {
            sb.append(",");
          }
          sb.append("(");
          sb.append(index1);
          sb.append(",");
          sb.append(index2);
          sb.append(")");
        }
      }
    }
  }
  sb.append("]\"");
  return sb.toString();
}

//mergeSameIdParts1のかわりに呼ぶ
ArrayList<StrokeParts> mergeSameIdPartsGraphillion(ArrayList<StrokeParts> parts, int map[][]) throws Exception{
  int target=parts.get(0).id;
  println("parts.length "+parts.size());
  cl.solve(map2graph(map),strokeparts2string(parts,map));
  String s=cl.get()[0];
  StrokeParts sp=new StrokeParts(target);
  println(s);
  for(String s1:s.split(" ")){
    int i=int(s1);
    println(i%map.length+" "+i/map.length);
    sp.add(i%map.length,i/map.length);
  }
  ArrayList<StrokeParts> tmp=new ArrayList<StrokeParts>();
  tmp.add(sp);
  return tmp;
}


ArrayList<StrokeParts> mergeSameIdPartsGraphillion2(ArrayList<StrokeParts> parts, int map[][]) throws Exception{
  int target=parts.get(0).id;
  println("parts.length "+parts.size());
  cl.solve(map2graph2(map),strokeparts2string(parts,map));
  String s=cl.get()[0];
  StrokeParts sp=new StrokeParts(target);
  println(s);
  for(String s1:s.split(" ")){
    int i=int(s1);
    println(i%map.length+" "+i/map.length);
    sp.add(i%map.length,i/map.length);
  }
  ArrayList<StrokeParts> tmp=new ArrayList<StrokeParts>();
  tmp.add(sp);
  return tmp;
}

