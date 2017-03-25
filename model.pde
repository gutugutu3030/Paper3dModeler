Model model;

import xyz.gutugutu3030.stl.*;
class Model extends STL {
  Model() {
    super(dataPath("tmp.stl"));
  }
  void draw() {
    for (Tri t : tri) {
      draw(t);
    }
  }
  void draw(Tri t) {
    beginShape();
    vertex(t.a.x, t.a.y, t.a.z);
    vertex(t.b.x, t.b.y, t.b.z);
    vertex(t.c.x, t.c.y, t.c.z);
    endShape(CLOSE);
  }
  void laplacianSmoothing(int n) {
    for(PVector v:vertex){
      PVector after=new PVector(0,0,0);
      Set<PVector> set=new HashSet<PVector>();
      int num=0;
      for(Tri t:tri){
        if(!t.contains(v)){
          continue;
        }
        if(!t.a.equals(v)&&!set.contains(t.a)){
          after.add(t.a);
          set.add(t.a);
          num++;
        }
        if(!t.b.equals(v)&&!set.contains(t.b)){
          after.add(t.b);
          set.add(t.b);
          num++;
        }
        if(!t.c.equals(v)&&!set.contains(t.c)){
          after.add(t.c);
          set.add(t.c);
          num++;
        }
      }
      after.div(num);
      for(Tri t:tri){
        if(!t.contains(v)){
          continue;
        }
        if(!t.a.equals(v)){
          t.a=after;
          continue;
        }
        if(!t.b.equals(v)){
          t.b=after;
          continue;
        }
        if(!t.c.equals(v)){
          t.c=after;
          continue;
        }
      }
      
    }
  }
  
  void center(){
    PVector min=new PVector(vertex[0].x,vertex[0].y,vertex[0].z);
    PVector max=new PVector(vertex[0].x,vertex[0].y,vertex[0].z);
    for(PVector p:vertex){
      min.x=min(p.x,min.x);
      min.y=min(p.y,min.y);
      min.z=min(p.z,min.z);
      max.x=max(p.x,max.x);
      max.y=max(p.y,max.y);
      max.z=max(p.z,max.z);
    }
    translate(-(max.x+min.x)/2,-(max.y+min.y)/2,-(max.z+min.z)/2);
//    for(PVector p:vertex){
//      p.x=p.x-center.x+100;
//      p.y=p.y-center.y+70;
//      p.z=p.z-min.z;
//    }
  }
}
