import java.awt.event.*;

void printMap(int map[][]) {
  for (int y=0; y<map[0].length; y++) {
    System.out.printf("%3d:", y);
    for (int x=0; x<map.length; x++) {
      print((map[x][y]!=0)?map[x][y]:" ");
    }
    println();
  }
}
void printMap1(int map[][]) {
  for (int y=0; y<map[0].length; y++) {
    System.out.printf("%3d:", y);
    for (int x=0; x<map.length; x++) {
      print((map[x][y]!=0)?"■":"　");
    }
    println();
  }
}
class ImgWindow extends ExtraWindow {
  PApplet apa;
  PImage front, top, option;
  ImgWindow(PApplet theApplet, String title) {
    super(theApplet, title, 0, 0, 640, 480*2);
    apa=theApplet;
  }
  public void windowClosing(WindowEvent e) {
    apa.exit();
    super.windowClosing(e);
  }
  int axis;
  public void setup() {
  }
  void setTopImage(PImage top) {
    this.top=top.get(0, 0, top.width, top.height);
  }
  void setFrontImage(PImage front) {
    this.front=front.get(0, 0, front.width, front.height);
  }
  void setOptionImage(PImage option) {
    this.option=option.get(0, 0, option.width, option.height);
  }
  public void draw() {
    if (front!=null) {
      image(front, 0, 0, width, height*2/5);
    }
    if (top!=null) {
      image(top, 0, height*2/5, width, height*2/5);
    }
    if (option!=null) {
      image(option, 0, height*4/5, width, height/5);
    }
  }
}

class OptionWindow extends DebugWindow {
  OptionWindow(PApplet apa, PImage img) {
    super(apa, "角丸", img);
  }
  public void draw() {
    super.draw();
    noFill();
    stroke(255, 0, 0);
    strokeWeight(3);
    rect(width*0.439, height*0.107, width*0.038, height*0.195);
    rect(width*0.439, height*0.472, width*0.038, height*0.195);
    rect(width*0.617, height*0.723, width*0.029, height*0.149);
    rect(width*0.746, height*0.723, width*0.029, height*0.149);
    rect(width*0.876, height*0.723, width*0.029, height*0.149);
  }
}


class DebugWindow extends ExtraWindow {
  PApplet apa;
  PImage img1;
  DebugWindow(PApplet theApplet, String title, PImage img) {
    super(theApplet, title, 0, 0, img.width, img.height);
    apa=theApplet;
    this.img1=img.get(0, 0, img.width, img.height);
    System.out.println(img1!=null);
  }
  public void windowClosing(WindowEvent e) {
    apa.exit();
    super.windowClosing(e);
  }

  int axis;
  public void setup() {
  }
  public void draw() {
    if (img1!=null)
      image(img1, 0, 0);
  }
}

class StrokeInfoWindow extends ExtraWindow {
  PApplet apa;
  List[] strokeInfo;
  StrokeInfoWindow(PApplet theApplet, String title, List<StrokeParts> front, List<StrokeParts> top) {
    super(theApplet, title, 0, 0, 640, 480);
    apa=theApplet;
    strokeInfo=new List[2];
    strokeInfo[0]=front;
    strokeInfo[1]=top;
  }
  public void windowClosing(WindowEvent e) {
    apa.exit();
    super.windowClosing(e);
  }
  public void setup() {
    
  }
  public void draw() {
    if(strokeInfo==null){
      return;
    }
    background(0);
    noFill();
    int y[]= {
      0, height/2
    };
    color col[]= {
      color(255, 0, 0), #FFB236, color(0, 0, 255), color(0, 255, 0), color(255, 0, 255)
    };
    strokeWeight(3);
    for (int i=0; i<y.length; i++) {
      if(strokeInfo[i]==null){
        continue;
      }
      for (StrokeParts sp : (List<StrokeParts>) strokeInfo[i]) {
        stroke(col[abs(sp.id)-1]);
        beginShape();
        for (int xy[] : sp.s) {
          vertex(xy[0], xy[1]+y[i]);
        }
        endShape(CLOSE);
      }
    }
    strokeWeight(1);
  }
}

