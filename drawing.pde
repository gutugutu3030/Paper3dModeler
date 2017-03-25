boolean guess=true;

Drawing createDrawing(ArrayList<StrokeParts> front, ArrayList<StrokeParts> top) {
  return createDrawing(front,top,0.5);
}

Drawing createDrawing(ArrayList<StrokeParts> front, ArrayList<StrokeParts> top,float scale) {
  Drawing drawing=new Drawing(scale);
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


class Drawing {
  ArrayList<DrawingParts> add, sub;
  float scale;
  boolean rounded=false;
  Drawing() {
    this(0.5);
  }
  Drawing(float scale) {
    this.scale=scale;
    add=new ArrayList<DrawingParts>();
    sub=new ArrayList<DrawingParts>();
  }
  void add(DrawingParts dp) {
    add.add(dp);
  }
  void sub(DrawingParts dp) {
    sub.add(dp);
  }
  void setRoundedCorners(boolean rounded) {
    this.rounded=rounded;
  }
  Model createModel() {
    save(dataPath("tmp.scad"));
    createSTL(dataPath("tmp.scad"), dataPath("tmp.stl"));
    return new Model();
  }
  void save(String filePath) {
    ArrayList<String> lines=new ArrayList<String>();
    if (rounded) {
      lines.add("minkowski(){");
    }
    if (sub.size()!=0) {
      lines.add("difference(){");
    }
    lines.add("union(){");
    for (DrawingParts d : add) {
      lines.add(d.toString(scale));
    }
    lines.add("}");
    if (sub.size()!=0) {
      if (rounded) {
        lines.add("minkowski(){");
      }
      lines.add("union(){");
      for (DrawingParts d : sub) {
        lines.add(d.toString(scale));
      }
      lines.add("}");
      lines.add("}");
      if (rounded) {
        lines.add("box(r=2);}");
      }
    }
    if (rounded) {
      lines.add("sphere(r=2);}");
    }
    saveStrings(filePath, lines.toArray(new String[0]));
  }
  void createSTL(String in, String out) {
    println("create");
    String scadPath=System.getenv("OpenSCAD");
    if (scadPath==null) {
      scadPath="\"D:\\Program Files\\OpenSCAD\\openscad.exe\"";
    } else {
      scadPath="\""+scadPath+"\\openscad.exe\"";
    }
    try {
      ProcessBuilder pb = new ProcessBuilder(new String[] { 
        scadPath, "-o", "\""+out+"\"", "\""+in+"\""
      }
      );
      Process process = pb.start();
      int ret = process.waitFor();
      System.out.println("戻り値：" + ret);
    }
    catch(Exception e) {
    }
  }
}

class DrawingParts {
  ArrayList<PVector> xy;
  ArrayList<PVector> xz;
  DrawingParts() {
    xy=new ArrayList<PVector>();
    xz=new ArrayList<PVector>();
  }
  ArrayList<PVector> getXYList() {
    return xy;
  }
  ArrayList<PVector> getXZList() {
    return xz;
  }
  void setXYList(ArrayList<PVector> xy) {
    this.xy=xy;
  }
  void setXZList(ArrayList<PVector> xz) {
    this.xz=xz;
  }
  void drawXY(float x, float y) {
    beginShape();
    for (PVector p : xy) {
      vertex(p.x+x, p.y+y);
    }
    endShape(CLOSE);
  }
  void drawXZ(float x, float z) {
    beginShape();
    for (PVector p : xz) {
      vertex(p.x+x, -p.z+z);
    }
    endShape(CLOSE);
  }
  //  String toString() {
  //    return toString(1);
  //  }
  String toString(float scale) {
    StringBuilder sb=new StringBuilder();
    sb.append("translate([0,-10,0])intersection(){");
    {
      sb.append("linear_extrude(height=1000, slices=1, twist=0, center=true){");
      sb.append("polygon([");
      for (PVector p : xy) {
        if (p!=xy.get(0)) {
          sb.append(",");
        }
        sb.append("[");
        sb.append(p.x*scale);
        sb.append(",");
        sb.append(p.y*scale);
        sb.append("]");
      }
      sb.append("]);");
      sb.append("}");
    }
    { 
      sb.append("rotate([90,0,0])");
      sb.append("linear_extrude(height=1000, slices=1, twist=0, center=true){");
      sb.append("polygon([");
      for (PVector p : xz) {
        if (p!=xz.get(0)) {
          sb.append(",");
        }
        sb.append("[");
        sb.append(p.x*scale);
        sb.append(",");
        sb.append(p.z*scale);
        sb.append("]");
      }
      sb.append("]);");
      sb.append("}");
    }
    sb.append("}");
    return sb.toString();
  }
}

