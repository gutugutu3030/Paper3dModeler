//id付きストローク
class Stroke {
  ArrayList<PVector> stroke;
  int id;
  int axis;//xy=0 xz=1
  Stroke(ArrayList<PVector> stroke, int id, int axis) {
    this.stroke=stroke;
    this.id=id;
    this.axis=axis;
  }
  void setId(int id) {
    this.id=id;
  }
  int getId() {
    return id;
  }
  int getAxis() {
    return axis;
  }
  ArrayList<PVector> getStroke() {
    return stroke;
  }
  void draw(PApplet apa, int translate[][]) {
    if (axis==0) {
      drawXY(apa, translate[0][0], translate[0][1]);
    }
    if (axis==1) {
      drawXZ(apa, translate[1][0], translate[1][1]);
    }
  }
  void drawXY(PApplet apa, float x, float y) {
    apa.noFill();
    apa.colorMode(HSB);
    apa.stroke(255/9*id, 255, 255);
    apa.beginShape();
    for (PVector p : stroke) {
      apa.vertex(p.x+x, p.y+y);
    }
    apa.endShape(CLOSE);
    apa.colorMode(RGB);
  }
  void drawXZ(PApplet apa, float x, float z) {
    apa.noFill();
    apa.colorMode(HSB);
    apa.stroke(255/9*id, 255, 255);
    apa.beginShape();
    for (PVector p : stroke) {
      apa.vertex(p.x+x, -p.z+z);
    }
    apa.endShape(CLOSE);
    apa.colorMode(RGB);
  }
  float[] getMaxMinX() {
    float[] m= {
      stroke.get(0).x, stroke.get(0).x
    };
    for (PVector p : stroke) {
      m[0]=max(m[0], p.x);
      m[1]=min(m[1], p.x);
    }
    return m;
  }
  void map(Stroke s) {
    float to[]=s.getMaxMinX();
    float from[]=getMaxMinX();
    float a=(to[0]-to[1])/(from[0]-from[1]);
    for (PVector p : stroke) {
      p.x=a*(p.x-from[1])+to[1];
    }
  }
}
//Model stroke2Model(ArrayList<Stroke> sl) {
//  return stroke2Model(sl,1);
//}
Model stroke2Model(ArrayList<Stroke> sl, float scale) {
  boolean exist[][]=new boolean[2][9];
  for (Stroke s : sl) {
    exist[s.getAxis()][s.getId()]=true;
  }
  for (int i=0; i<exist[0].length; i++) {
    if (exist[0][i]^exist[1][i]) {
      return null;
    }
  }
  int map[]=new int[9];
  for (int i=0; i<map.length; i++) {
    map[i]=-1;
  }
  DrawingParts parts[]=new DrawingParts[9];
  for (Stroke s : sl) {
    int id=s.getId();
    if (parts[id]==null) {
      parts[id]=new DrawingParts();
    }
    switch(s.getAxis()) {
    case 0:
      parts[id].setXYList(s.getStroke());
      break;
    case 1:
      parts[id].setXZList(s.getStroke());
      break;
    }
  }
  Drawing drawing=new Drawing(scale);
  for (int i=0; i<parts.length; i++) {
    if (parts[i]==null) {
      continue;
    }
    if (i<6) {
      drawing.add(parts[i]);
    } else {
      drawing.sub(parts[i]);
    }
  }
  return drawing.createModel();
}

