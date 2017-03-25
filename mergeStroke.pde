void mergeParts(ArrayList<StrokeParts> parts, int map[][]) {
  for (int i=0; i<parts.size (); i++) {
    boolean edit=false;
    for (int j=i+1; j<parts.size (); j++) {
      if (parts.get(i).merge( parts.get(j), map)) {
        parts.remove(j);
        edit=true;
        //break;
      }
    }
    if (edit) {
      //i--;
    }
  }
}

//同じidの曲線は1本にまとめる
ArrayList<StrokeParts> mergeSameIdParts(ArrayList<StrokeParts> parts, int map[][]) {
  ArrayList<StrokeParts>[] plus =new ArrayList[10];//適当に
  ArrayList<StrokeParts>[] minus =new ArrayList[10];//適当に
  ArrayList<StrokeParts> dst=new ArrayList<StrokeParts>();
  for (StrokeParts p : parts) {
    int id=p.id;
    ArrayList<StrokeParts> t[]=(id<0)?minus:plus;
    id=abs(id);
    if (t[id]==null) {
      t[id]=new ArrayList<StrokeParts>();
    }
    t[id].add(p);
  }
  for (int i=0; i<plus.length; i++) {
    if (plus[i]==null) {
      continue;
    }
    println("id:"+i);
    ArrayList<StrokeParts> tmp=mergeSameIdParts1(plus[i], map);
    if (tmp==null) {
      continue;
    }
    dst.addAll(tmp);
  }
  for (int i=0; i<minus.length; i++) {
    if (minus[i]==null) {
      continue;
    }
    println("id:"+(-i));
    ArrayList<StrokeParts> tmp=mergeSameIdParts1(minus[i], map);
    if (tmp==null) {
      continue;
    }
    dst.addAll(tmp);
  }
  return dst;
}

ArrayList<StrokeParts> mergeSameIdParts1(ArrayList<StrokeParts> parts, int map[][]) {
  if (true) {
    try {
      ArrayList<StrokeParts> ans=mergeSameIdPartsGraphillion(parts, map);
      return ans;
    }
    catch(Exception e) {
      println("graphillion1エラー");
      try {
        ArrayList<StrokeParts> ans=mergeSameIdPartsGraphillion2(parts, map);
        return ans;
      }
      catch(Exception e1) {
        println("graphillion2エラー");
      }
    }
  }
  if (parts.size()==1) {
    //輪にする
    println("わにしよう");
    try {
      createLoop(parts.get(0), map);
      return parts;
    }
    catch(Exception e) {
      return null;
    }
  } else {
    for (int i=0; i<parts.size (); i++) {
      //長さ0のストロークは消す
      StrokeParts p=parts.get(i);
      int a[]=p.s.get(0);
      int b[]=p.s.get(p.s.size()-1);
      if (a[0]==b[0]&&a[1]==b[1]) {
        parts.remove(i);
        i--;
      }
    }
    println("同じidで線の統合　"+parts.size()+"本");
    if (parts.size()==0) {
      return null;
    }
    StrokeParts master=parts.get(0);
    parts.remove(0);
    while (parts.size ()>0) {
      int min=-1;
      List<int[]> route=null;
      for (int i=0; i<parts.size (); i++) {
        StrokeParts p=parts.get(i);
        List<int[]> r1=solveMeizu(map, master.s.get(master.s.size()-1), p.s.get(0));
        List<int[]> r2=solveMeizu(map, master.s.get(master.s.size()-1), p.s.get(p.s.size()-1));
        if (route==null) {
          if (r1==null&&r2==null) {
            continue;
          }
          if (r2==null||r1.size()<r2.size()) {
            min=i*2;
            route=r1;
          }
          if (r1==null||r2.size()<r1.size()) {
            min=i*2+1;
            route=r2;
          }
          continue;
        }
        if (r1==null&&r2==null) {
          continue;
        }
        if (r1!=null&&r1.size()<route.size()) {
          min=i*2;
          route=r1;
        }
        if (r2!=null&&r2.size()<route.size()) {
          min=i*2+1;
          route=r2;
        }
      }
      StrokeParts next=parts.get(min/2);
      parts.remove(min/2);
      master.s.addAll(route);
      if (min%2==1) {
        Collections.reverse(next.s);
      }
      master.s.addAll(next.s);
    }
    println("わにする");
    createLoop(master, map);
    parts.add(master);
    return parts;
  }
}
void createLoop(StrokeParts sp, int map[][]) {
  List<int[]> route=solveMeizu(map, sp.s.get(sp.s.size()-1), sp.s.get(0));
  route.remove(0);
  sp.s.addAll(route);
}

class StrokeParts {
  ArrayList<int[]> s;
  int id;
  StrokeParts(int id) {
    this.id=id;
    s=new ArrayList<int[]>();
  }
  void add(int x, int y) {
    s.add(new int[] {
      x, y
    }
    );
  }
  boolean merge(StrokeParts b, int map[][]) {
    if (id!=b.id) {
      return false;
    }
    int midllePoint[]=getMiddlePoint(b);
    if (midllePoint==null) {
      return false;
    }
    if (id!=map[midllePoint[0]][midllePoint[1]]) {
      return false;
    }
    //実際のマージ作業
    if (getMiddlePoint(s.get(0), b.s.get(0))!=null) {
      //bのリストを逆にしてこのリストの前に追加
      Collections.reverse(b.s);
      s.addAll(0, b.s);
      return true;
    }
    if (getMiddlePoint(s.get(0), b.s.get(b.s.size()-1))!=null) {
      //bのリストをこのリストの前に追加
      s.addAll(0, b.s);
      return true;
    }
    if (getMiddlePoint(s.get(s.size()-1), b.s.get(b.s.size()-1))!=null) {
      //bのリストを逆にしてこのリストの後に追加
      Collections.reverse(b.s);
      s.addAll(b.s);
      return true;
    }
    if (getMiddlePoint(s.get(s.size()-1), b.s.get(0))!=null) {
      //bのリストをこのリストのあとに追加
      s.addAll(b.s);
      return true;
    }
    return false;//ここにくるはずはない
  }
  int[] getMiddlePoint(StrokeParts sp) {
    int[] tmp=null;
    tmp=getMiddlePoint(s.get(0), sp.s.get(0));
    if (tmp!=null) {
      return tmp;
    }
    tmp=getMiddlePoint(s.get(0), sp.s.get(sp.s.size()-1));
    if (tmp!=null) {
      return tmp;
    }
    tmp=getMiddlePoint(s.get(s.size()-1), sp.s.get(sp.s.size()-1));
    if (tmp!=null) {
      return tmp;
    }
    tmp=getMiddlePoint(s.get(s.size()-1), sp.s.get(0));
    return tmp;
  }
  int[] getMiddlePoint(int a[], int b[]) {
    if (abs(a[0]-b[0])==2&&a[1]==b[1]) {
      return new int[] {
        (a[0]+b[0])/2, a[1]
      };
    }
    if (abs(a[1]-b[1])==2&&a[0]==b[0]) {
      return new int[] {
        a[0], (a[1]+b[1])/2
      };
    }
    return null;
  }
  ArrayList<PVector> getList(int axis) {
    ArrayList<PVector> list=new ArrayList<PVector>();
    for (int[] t : s) {
      PVector tmp=getPos(t[0], t[1]);
      if (axis==1) {
        tmp.z=-1*tmp.y;
        tmp.y=0;
      } else {
        tmp.y=-1*tmp.y+250;
      }
      list.add(tmp);
    }
    return list;
  }

  float[] getMaxMinX() {
    float[] m= {
      s.get(0)[0], s.get(0)[0]
    };
    for (int x[] : s) {
      m[0]=max(m[0], x[0]);
      m[1]=min(m[1], x[0]);
    }
    return m;
  }
  void map(StrokeParts s1) {
    float to[]=s1.getMaxMinX();
    float from[]=getMaxMinX();
    float a=(to[0]-to[1])/(from[0]-from[1]);
    for (int x[] : s) {
      x[0]=(int)(a*(x[0]-from[1])+to[1]);
    }
  }
}

