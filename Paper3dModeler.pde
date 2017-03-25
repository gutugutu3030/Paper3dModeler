/*
システム変数：それぞれexeファイルのあるフォルダのディレクトリを登録
 curaEngine
 OpenSCAD
 GTS650(EPSONスキャン・テスト環境のみ必要)
 */
boolean jikki=true;
String comPort="COM5";


import java.util.*;
import psvm.*;
import gifAnimation.*;
import processing.video.*;
ArrayList<StrokeParts> stroke;
//Set<Integer>[][] map=new Set[67][51];
int idDetail=40;
int[][][] hist=new int[67][51][255/idDetail+1];



//紙は160mm x 120mm
PVector getPos(int x, int y) {
  //  return new PVector(x*5-80, y*5-60);
  return new PVector(x*5, y*5);
}


psvm.SVM svm;
GCode gcode;
Control control;
Serial printer=null;
//ImgWindow imgWindow;
PFont font;

Gif waitingGif;
PImage waiting;
Movie processM[];

void setup() {
  size(displayWidth, displayHeight, P3D);
  //  size(400, 400, P3D);
  frame.setAlwaysOnTop(true);
  noCursor();
  svm=new psvm.SVM(this);
  svm.loadModel("scansnap.psvm", 3);
  //svm.loadModel("new epson2.psvm", 3);

  initOpenCV();
  initGraphillion();

  if (!jikki) {
    new Thread(new MonitorPaper()).start();
    control=new Control(this, "Controller");
  } else {
    control=new Control(this, "Controller", comPort  );
  }
  font = createFont("HG丸ｺﾞｼｯｸM-PRO", width/15);//loadFont("HGMaruGothicMPRO-72.vlw");
  textAlign(CENTER, TOP);
  waitingGif=new Gif(this, "waitingScan.gif");
  waitingGif.loop();
  waiting=loadImage("waitingScan.png");
  processM=new Movie[4];
  for (int i=0; i<processM.length; i++) {
    processM[i]=new Movie(this, i+".mp4");
    processM[i].loop();
  }

  //imgWindow=new ImgWindow(this, "抽出画像");
}
void draw() {
  background(200);
  if (jikki&&waiting!=null) {
    fill(200);
    image(waiting, 0, 0, width, height);
    image(waitingGif, 100, 100, height/2, height/2);
  }
  if (jikki&&movieState!=-1) {
    if (processM[movieState]!=null) {
      image(processM[movieState], 0, 0, width, height);
    }
    drawOptionInfo();
    if (!drawStroke()) {
      drawDrawingImage();
    }
  }
  if (jikki&&gcode!=null&&gcode.printing) {
    showTime(gcode.getTimeString());
  }
  if (model!=null) {
    ambientLight(50, 50, 50);
    directionalLight(0, 255, 255, -0.5, 0, -1); 
    //    fill(0,255,255);
    pushMatrix();
    translate(width/2, height/2);
    //sphere(100);
    //model.center();
    rotateX(PI/4);
    rotateZ(radians(frameCount));
    stroke(0);
    scale(height/250);
    model.center();
    fill(255);
    model.draw();
    popMatrix();
  }
  //  int w2=width/6;
  //  rect(0,0,w2,w2*3/4*2);
  //  if(drawing!=null){
  //    drawing
  //  }
}

void showTime(String time) {
  fill(200, 0, 0);
  textFont(font, width/15);
  text("印刷完了まで\nあと"+time, width/2, 0);
}
int movieState=-1;
void setState(int k) {
  try {
    waitingGif.pause();
    movieState=k;
  }
  catch(Exception e) {
    e.printStackTrace();
  }
}
void movieEvent(Movie m) {
  m.read();
}
PImage drawingImage[]=null, drawingImageOri=null;
void setDrawingImage(PImage... drawingImage) {
  this.drawingImage=drawingImage;
}
void setDrawingImageOri(PImage ori) {
  drawingImageOri=ori;
}
void drawDrawingImage() {
  float p100=height/200.0;
  if (drawingImage==null) {
    if (drawingImageOri==null) {
      return;
    }
    image(drawingImageOri, width/4, height/2, p100*70.7, p100*100);
    return;
  }
  /*
  image(drawingImage[0], width/4, height/2, width/4, height/5);
   image(drawingImage[1], width/4, height/2+height/5, width/4, height/5);
   image(drawingImage[2], width/4, height/2+height/5*2, width/4, height/10);
   */
  float w=p100*59.603;
  image(drawingImage[0], width/4, height/2, w, p100*43.999);
  image(drawingImage[1], width/4, height/2+p100*43.999, w, p100*43.999);
  image(drawingImage[2], width/4, height/2+p100*43.999*2, w, p100*12.001);
}
List[] strokeInfo;
void setStrokeInfo(List<StrokeParts> front, List<StrokeParts> top) {
  strokeInfo=new List[2];
  strokeInfo[0]=front;
  strokeInfo[1]=top;
}
boolean drawStroke() {
  if (strokeInfo==null) {
    return false;
  }
  noFill();
  int y[]= {
    height/2, height*3/4
  };
  color col[]= {
    color(255, 0, 0), #FFB236, color(0, 0, 255), color(0, 255, 0), color(255, 0, 255)
  };
  strokeWeight(3);
  for (int i=0; i<y.length; i++) {
    for (StrokeParts sp : (List<StrokeParts>) strokeInfo[i]) {
      stroke(col[abs(sp.id)-1]);
      beginShape();
      for (int xy[] : sp.s) {
        vertex(xy[0]*height/170+width/4, xy[1]*height/170+y[i]);
      }
      endShape(CLOSE);
    }
  }
  strokeWeight(1);
  return true;
}
String optionInfo=null;
void setOptionInfo(Map option) {
  textFont(font, width/30);
  StringBuilder sb=new StringBuilder();
  sb.append("角丸仕上げ:");
  sb.append(((Boolean)option.get("rounded"))?"あり":"なし");
  sb.append('\n');
  sb.append("１面のみ使用：");
  if (!(Boolean)option.get("oneDimension")) {
    sb.append("なし");
  } else {
    sb.append("あり（厚さ：");
    sb.append((Integer)(option.get("height"))/2);
    sb.append("cm）");
  }
  optionInfo=sb.toString();
}
void drawOptionInfo() {
  if (optionInfo==null) {
    return;
  }
  fill(0);
  text(optionInfo, width*3/4, height/2);
}

void keyReleased() {
  if (!jikki) {
    try {
      println("テストモード");
      //new Scan(this, dataPath("img20161204_0009.jpg")).start();
      new Scan(this, dataPath("くま.jpg")).start();
      waiting=null;
    }
    catch(Exception e) {
    }
    return;
  }
  //if ('0'<=key&&key<='2')setState((int)(key-'0'));
  if (key=='q') {
    //new Scan(this, dataPath("img20161204_0009.jpg")).start();

    new Scan(this).start();
    waiting=null;
  }
}

void mousePressed() {
  //waiting=null;
  //new Scan(this, dataPath("img20161204_0009.jpg")).start();
  // scanImage(loadImage(dataPath("2016年08月11日19時00分29秒.jpg")));
}

StringBuilder sb=null;
void serialEvent(Serial thisPort) {
  if (sb==null) {
    sb=new StringBuilder();
  }
  String readSt=thisPort.readString();
  if (readSt.equals("\n")) {
    //println(sb);
    String str=sb.toString();
    if (str.indexOf("T:")!=-1) {
      //温度測定命令
      control.temp.setText(str.split(" ")[1].split(":")[1]+"℃");
    } else if (str.equals("ok")) {
      println(str);
      control.serialReady=true;
      if (gcode!=null) {
        gcode.getOKFromPrinter();
      }
    } else {
      println(str);
    }
    sb=null;
    return;
  }
  sb.append(readSt);
}

