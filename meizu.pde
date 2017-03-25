ArrayList<int[]> solveMeizu(int map[][], int start[], int goal[]) {
  ArrayDeque<Meiro> queue=new ArrayDeque<Meiro>();
  queue.offer(new Meiro(start[0], start[1], new boolean[map.length][map[0].length]));
  while (!queue.isEmpty ()) {
    Meiro m=queue.poll();
    if (m.isGoal(goal)) {
      return m.route;
    }
    m.checkIn();
    int d[][]= {
      {
        2, 0
      }
      , {
        0, -2
      }
      , {
        -2, 0
      }
      , {
        0, 2
      }
    };
    for (int d1[] : d) {
      int x=m.x+d1[0], y=m.y+d1[1];
      if (x<0||map.length<=x) {
        continue;
      }
      if (y<0||map[0].length<=y) {
        continue;
      }
      if (map[x][y]!=0&&!m.arrived[x][y]) {
        queue.offer(new Meiro(x, y, m));
      }
    }
  }
  return null;
}

class Meiro {
  boolean arrived[][];
  int x, y;
  ArrayList<int[]> route;
  Meiro(int x, int y, boolean arrival[][]) {
    this.x=x;
    this.y=y;
    this.arrived=new boolean[arrival.length][arrival[0].length];
    for (int i=0; i<arrived.length; i++) {
      for (int j=0; j<arrived[0].length; j++) {
        this.arrived[i][j]=arrived[i][j];
      }
    }
    route=new ArrayList<int[]>();
  }
  Meiro(int x, int y, Meiro m) {
    this(x, y, m.arrived);
    for (int[] t : m.route) {
      route.add(t);
    }
  }
  boolean isGoal(int[] g) {
    return x==g[0]&&y==g[1];
  }
  void checkIn() {
    arrived[x][y]=true;
    route.add(new int[]{x,y});
  }
}

