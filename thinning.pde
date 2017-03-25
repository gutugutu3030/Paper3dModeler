class Thinning {
  boolean map[][];
  int id;
  Thinning(int map[][], int id) {
    this.id=id;
    this.map=new boolean[map.length][map[0].length];
    //読み込み
    for (int i=0; i<map.length; i++) {
      for (int j=0; j<map[0].length; j++) {
        this.map[i][j]=(map[i][j]==id);
      }
    }
  }
  ArrayList<RefPoint> refPoint=new ArrayList<RefPoint>();
  void process(float dist) {
    println("process.");
    ArrayList<int[]> points=new ArrayList<int[]>();
    for (int i=0; i<map.length; i++) {
      for (int j=0; j<map[0].length; j++) {
        if (map[i][j]) {
          //データベース登録
          points.add(new int[] {
            i, j
          }
          );

          boolean added=false;
          for (RefPoint rp : refPoint) {
            if (/*rp.isConnected(i,j)&&*/rp.add(i, j)) {
              added=true;
              break;
            }
          }
          if (!added) {
            refPoint.add(new RefPoint(i, j, dist));
          }
        }
      }
    }
    for (RefPoint rp : refPoint) {
      rp.opt();
    }
    ArrayList<RefPoint> refPoint1=refPoint;//new ArrayList<RefPoint>();


    float distMap[][]=new float[refPoint1.size()][refPoint1.size()];
    ArrayList<RefPoint> refPoint2=new ArrayList<RefPoint>();
    for (RefPoint rp : refPoint1) {
      refPoint2.add(rp);
    }
    //    for (int i=0; i<distMap.length; i++) {
    //      final RefPoint rp=refPoint1.get(i);
    //      Collections.sort(points, new Comparator<int[]>() {
    //        public int compare(int[] a, int[] b) {
    //          return (int)dist(a[0], a[1], rp.x, rp.y)-(int)dist(b[0], b[1], rp.x, rp.y);
    //        }
    //      }
    //      );
    //      //index1,2,3をdistMapに書く
    //      for (int j=1; j<=3; j++) {
    //        RefPoint rp1=refPoint2.get(j);
    //        int index=refPoint1.indexOf(rp1);
    //        distMap[min(index, i)][max(index, i)]=dist(rp1.x, rp1.y, rp.x, rp.y);
    //      }
    //    }

    //密なグラフだと遅い
    //    for (int i=0; i<distMap.length-1; i++) {
    //      RefPoint a=refPoint1.get(i);
    //      for (int j=i+1; j<distMap.length; j++) {
    //        RefPoint b=refPoint1.get(j);
    //        distMap[i][j]=dist(a.x, a.y, b.x, b.y);
    //      }
    //    }
    if (true) {
      for (int i=0; i<distMap.length; i++) {
        final RefPoint rp=refPoint1.get(i);
        Collections.sort(refPoint2, new Comparator<RefPoint>() {
          public int compare(RefPoint a, RefPoint b) {
            return (int)dist(a.x, a.y, rp.x, rp.y)-(int)dist(b.x, b.y, rp.x, rp.y);
          }
        }
        );
        //index1,2,3をdistMapに書く
        for (int j=1; j<=2; j++) {
          RefPoint rp1=refPoint2.get(j);
          int index=refPoint1.indexOf(rp1);
          if (distMap[min(index, i)][max(index, i)]!=0) {
            continue;
          }
          distMap[min(index, i)][max(index, i)]=dist(rp1.x, rp1.y, rp.x, rp.y);
        }
      }
    } else {
      for (int i=0; i<distMap.length; i++) {
        final RefPoint rp=refPoint1.get(i);
        Collections.sort(refPoint2, new Comparator<RefPoint>() {
          public int compare(RefPoint a, RefPoint b) {
            return (int)dist(a.x, a.y, rp.x, rp.y)-(int)dist(b.x, b.y, rp.x, rp.y);
          }
        }
        );
        //index1,2,3をdistMapに書く
        int cnt=0;
        for (int j=1; j<refPoint2.size (); j++) {
          RefPoint rp1=refPoint2.get(j);
          int index=refPoint1.indexOf(rp1);
          if (distMap[min(index, i)][max(index, i)]!=0) {
            continue;
          }
          distMap[min(index, i)][max(index, i)]=dist(rp1.x, rp1.y, rp.x, rp.y);
          if (cnt++==2) {
            break;
          }
        }
      }
    }
    StringBuilder gQuery=new StringBuilder();
    gQuery.append("\"[");    
    boolean first=true;
    for (int i=0; i<distMap.length-1; i++) {
      for (int j=0; j<distMap.length; j++) {
        if (distMap[i][j]==0) {
          continue;
        }
        if (first) {
          first=false;
        } else {
          gQuery.append(",");
        }
        gQuery.append("(");
        gQuery.append(i+1);
        gQuery.append(",");
        gQuery.append(j+1);
        gQuery.append(",");
        gQuery.append(distMap[i][j]/50);
        gQuery.append(")");
      }
    }
    gQuery.append("]\"");
    String ans=calcFreeformLoop(gQuery.toString());
    String anss[]=ans.split(" ");
    path=new int[anss.length/2][2];
    for (int i=0; i<path.length; i++) {
      path[i][0]=Integer.parseInt(anss[i*2]);
      path[i][1]=Integer.parseInt(anss[i*2+1]);
    }
    //    connectedMap=new boolean[distMap.length][distMap[0].length];
    //    for (int i=0; i<anss.length/2; i++) {
    //      int a=Integer.parseInt(anss[i*2])-1;
    //      int b=Integer.parseInt(anss[i*2+1])-1;
    //      connectedMap[a][b]=true;
    //    }
    refPoint=refPoint1;
    println("done.");
  }
  int path[][];
  boolean connectedMap[][];
  StrokeParts getStrokeparts() {
    StrokeParts parts=new StrokeParts(id);
    int lastIndex;
    {
      lastIndex=path[0][0];
      RefPoint rp=refPoint.get(lastIndex-1);
      parts.add(rp.x, rp.y);
    }
    for (int i=0; i<path.length; i++) {
      for (int j=0; j<path.length; j++) {
        if (path[j]==null) {
          continue;
        }
        if (path[j][0]==lastIndex) {
          lastIndex=path[j][1];
          RefPoint rp=refPoint.get(lastIndex-1);
          parts.add(rp.x, rp.y);
          path[j]=null;
          break;
        }
        if (path[j][1]==lastIndex) {
          lastIndex=path[j][0];
          RefPoint rp=refPoint.get(lastIndex-1);
          parts.add(rp.x, rp.y);
          path[j]=null;
          break;
        }
      }
    }
    return parts;
  }
  void draw() {
    for (RefPoint rp : refPoint) {
      ellipse(rp.x, rp.y, 10, 10);
      //      for (RefPoint rp1 : rp.connectedPoint) {
      //        line(rp.x, rp.y, rp1.x, rp1.y);
      //      }
    }
    for (int i=0; i<connectedMap.length-1; i++) {
      for (int j=i+1; j<connectedMap.length; j++) {
        if (connectedMap[i][j]) {
          RefPoint a=refPoint.get(i);
          RefPoint b=refPoint.get(j);
          line(a.x, a.y, b.x, b.y);
        }
      }
    }
  }
  class RefPoint {
    float dist;
    int x, y;
    ArrayList<int[]> points=new ArrayList<int[]>();
    ArrayList<RefPoint> connectedPoint=new ArrayList<RefPoint>();
    RefPoint(int x, int y, float dist) {
      this.x=x;
      this.y=y;
      this.dist=dist;
    }
    float dist1(int x, int y) {
      return dist(this.x, this.y, x, y);
    }
    boolean add(int x, int y) {
      if (dist<dist1(x, y)) {
        return false;
      }
      points.add(new int[] {
        x, y
      }
      );
      return true;
    }
    boolean opt() {
      if (points.size()==0) {
        return false;
      }
      int sumX=0, sumY=0;
      for (int[] p : points) {
        sumX+=p[0];
        sumY+=p[1];
      }
      x=sumX/points.size();
      y=sumY/points.size();
      return true;
    }
    void removePoints() {
      points=new ArrayList<int[]>();
    }
    boolean isConnected(int x, int y) {
      for (int[] a : points) {
        if (abs(a[0]-x)+abs(a[1]-y)<=1) {
          return true;
        }
      }
      return false;
    }
    boolean isConnected(RefPoint rp) {
      for (int[] a : points) {
        for (int[] b : rp.points) {
          if (abs(a[0]-b[0])+abs(a[1]-b[1])<=1) {
            return true;
          }
        }
      }
      return false;
    }
    void addConnectedPoint(RefPoint rp) {
      if (isConnected(rp)) {
        connectedPoint.add(rp);
      }
    }
    void refreshConnectedPoint() {
      final RefPoint rp=this;
      Collections.sort(connectedPoint, new Comparator<RefPoint>() {
        public int compare(RefPoint a, RefPoint b) {
          return (int)(dist(a.x, a.y, rp.x, rp.y)-dist(b.x, b.y, rp.x, rp.y));
        }
      }
      );
      ArrayList<RefPoint> connectedPoint1=new ArrayList<RefPoint>();
      if (0<connectedPoint.size()) {
        connectedPoint1.add(connectedPoint.get(0));
      }
      if (1<connectedPoint.size()) {
        connectedPoint1.add(connectedPoint.get(1));
      }
      connectedPoint=connectedPoint1;
    }
    int[] getRepresentativePoint() {
      final int x=this.x;
      final int y=this.y;
      Collections.sort(points, new Comparator<int[]>() {
        public int compare(int[] a, int[] b) {
          return (int)dist(a[0], a[1], x, y)-(int)dist(b[0], b[1], x, y);
        }
      }
      );
      return points.get(0);
    }
    int[] getCloserPoints(boolean map[][], ArrayList<RefPoint> list, int thi) {
      int d[][]= {
        {
          1, 0
        }
        , {
          1, 1
        }
        , {
          0, 1
        }
        , {
          -1, 1
        }
        , {
          -1, 0
        }
        , {
          -1, -1
        }
        , {
          0, -1
        }
        , {
          1, -1
        }
      };

      ArrayList<int[]> list1=new ArrayList<int[]>();
      for (int i=0; i<list.size (); i++) {
        list1.add(list.get(i).getRepresentativePoint());
      }
      //      for (int i=0; i<list.size (); i++) {
      //        if (i==thi) {
      //          continue;
      //        }
      ArrayDeque<int[]> que=new ArrayDeque<int[]>();
      int distMap[][]=new int[map.length][map[0].length];
      {
        int p[]=list1.get(thi);
        que.offer(new int[] {
          p[0], p[1], 1
        }
        );
      }
      ArrayList<Integer> closerIndex=new ArrayList<Integer>();
      while (!que.isEmpty ()) {
        int xyd[]=que.poll();
        for (int j=0; j<list.size (); j++) {
          if (j==thi) {
            continue;
          }
          int p[]=list1.get(j);
          if (p[0]==xyd[0]&&p[1]==xyd[1]) {
            closerIndex.add(j);
            if (closerIndex.size()==2) {
              return new int[] {
                closerIndex.get(0), closerIndex.get(1)
                };
              }
              break;
          }
        }
        if (distMap[xyd[0]][xyd[1]]==0||xyd[2]<distMap[xyd[0]][xyd[1]]) {
          distMap[xyd[0]][xyd[1]]=xyd[2];
        }
        for (int d1[] : d) {
          if (xyd[0]+d1[0]<0||map.length<=xyd[0]+d1[0]) {
            continue;
          }
          if (xyd[1]+d1[1]<0||map[0].length<=xyd[1]+d1[1]) {
            continue;
          }
          if (map[xyd[0]+d1[0]][xyd[1]+d1[1]]) {
            que.add(new int[] {
              xyd[0]+d1[0], xyd[1]+d1[1], xyd[2]+1
            }
            );
          }
        }
      }
      //      }
      return null;
    }
  }
}

