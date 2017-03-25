PImage topImage=null, frontImage=null, optionImage=null;

import org.opencv.core.*;
import imageTranslater.ImageTranslater;
ImageTranslater it;

void initOpenCV() {
  System.loadLibrary(Core.NATIVE_LIBRARY_NAME);
  it = new ImageTranslater(this);
}

ArrayList<StrokeParts> topStroke;
ArrayList<StrokeParts> frontStroke;
Drawing drawing;


void scanImage(PImage img) {
  scanImage(img, null);
}
void scanImage(PImage img, Map<String, Object> test) {
  try {
    if (test==null) {
      setDrawingImageOri(img);
    }
    getTopAndFrontImage(img, 3);//topImageとfrontImageとoptionImageを取得

    Object showDebugWindow=getTestMap(test, "showDebugWindow");
    ImgWindow imgWindow=null;
    if (showDebugWindow==Boolean.TRUE) {
      imgWindow=new ImgWindow(this, "ロードイメージ");
      setDrawingImage(frontImage, topImage, optionImage);
    }

    //    if (optionImage!=null) {
    //      imgWindow.setOptionImage(optionImage);
    //      new OptionWindow(this, optionImage);
    //    }
    //setDrawingImage(frontImage,topImage,optionImage);
    if (test==null) {
      setDrawingImage(frontImage, topImage, optionImage);
    }

    frontImage=processingImage4Stroke(frontImage);
    topImage=processingImage4Stroke(topImage);

    if (showDebugWindow==Boolean.TRUE) {
      imgWindow.setFrontImage(frontImage);
      imgWindow.setTopImage(topImage);
    }

    Map<String, Object> option=getOption(optionImage);
    if (test==null) {
      setOptionInfo(option);
      setState(2);
    }

    Object freeformMode=getTestMap(test, "forceFreeformMode");
    if (freeformMode==Boolean.TRUE) {
      frontStroke=extractFreeStroke(frontImage);
      topStroke=extractFreeStroke(topImage);
      new StrokeInfoWindow(this,"strokeInfo",frontStroke,topStroke);
      println("end");
    } else if ((Boolean)option.get("emboss")) {
      float xy[]=emboss(frontImage, topImage);
      String str[]=loadStrings(dataPath("embossP.scad"));
      println(Arrays.toString(str));
      str[0]=str[0].replace("X", ""+xy[0]);
      str[0]= str[0].replace("Y", ""+xy[1]);
      println(Arrays.toString(str));
      saveStrings(dataPath("emboss.scad"), str);
      println("create");
      setState(3);
      String scadPath=System.getenv("OpenSCAD");
      if (scadPath==null) {
        scadPath="\"D:\\Program Files\\OpenSCAD\\openscad.exe\"";
      } else {
        scadPath="\""+scadPath+"\\openscad.exe\"";
      }
      try {
        ProcessBuilder pb = new ProcessBuilder(new String[] { 
          scadPath, "-o", "\""+dataPath("tmp.stl")+"\"", "\""+dataPath("emboss.scad")+"\""
        }
        );
        Process process = pb.start();
        int ret = process.waitFor();
        System.out.println("戻り値：" + ret);
      }
      catch(Exception e) {
      }
      setState(-1);
      control.startPrint();
    } else {
      frontStroke=extractStroke(frontImage);
      topStroke=extractStroke(topImage);
      setStrokeInfo(frontStroke, topStroke);
      boolean creating25d=(Boolean)option.get("oneDimension");
      drawing=(!creating25d)?createDrawing(frontStroke, topStroke):create25dDrawing(frontStroke, topStroke, (Integer)option.get("height"));
      drawing.setRoundedCorners((Boolean)option.get("rounded"));
      setState(3);
      model=drawing.createModel();
      setState(-1);
      control.startPrint();
      model.center();
    }
  }
  catch(Exception e) {
    e.printStackTrace();
  }
}

//A4のPImageからtopImageとfrontImageとoptionImageを抽出する
void getTopAndFrontImage(PImage img, int dilateErode) {
  it = new ImageTranslater(this);
  Mat col = it.PI2Mat(img);
  Mat gray = new Mat();
  Mat bin = new Mat();

  //枠のノイズを取っ払う
  img.loadPixels();
  for (int i = 0; i < 5; i++) {
    for (int j = 0; j < img.width; j++) {
      img.pixels[j + i * img.width] = color(255);
      img.pixels[j + (img.height - i - 1) * img.width] = color(255);
    }
    for (int j = 0; j < img.height; j++) {
      img.pixels[i + j * img.width] = color(255);
      img.pixels[img.width - i - 1 + j * img.width] = color(255);
    }
  }
  img.updatePixels();

  Imgproc.cvtColor(col, gray, Imgproc.COLOR_BGR2GRAY);
  Imgproc.threshold(gray, bin, 0, 255, Imgproc.THRESH_BINARY | Imgproc.THRESH_OTSU);
  Imgproc.dilate(bin, bin, new Mat(), new Point(-1, -1), dilateErode);
  Imgproc.erode(bin, bin, new Mat(), new Point(-1, -1), dilateErode);
  //new DebugWindow(this,"bin",it.Mat2PI(bin));
  //new DebugWindow(this,"枠線",it.Mat2PI(bin));
  ArrayList<MatOfPoint> contours = new ArrayList<MatOfPoint>();
  Mat hierarchy = new Mat(bin.cols(), bin.rows(), CvType.CV_32SC1);
  Imgproc.findContours(bin, contours, hierarchy, Imgproc.RETR_LIST, Imgproc.CHAIN_APPROX_NONE);
  Collections.sort(contours, new Comparator<MatOfPoint>() {
    public int compare(MatOfPoint o1, MatOfPoint o2) {
      double d1 = Imgproc.contourArea(o1);
      double d2 = Imgproc.contourArea(o2);
      if (d1 < d2) {
        return 1;
      }
      if (d2 < d1) {
        return -1;
      }
      return 0;
    }
  }
  );

  for (MatOfPoint contour : contours) {
    RotatedRect rrect = Imgproc.minAreaRect(new MatOfPoint2f(contour.toArray()));
    Rect rect = Imgproc.boundingRect(contour);

    if (img.width * 3 / 4 < rect.width && img.height * 3 / 4 < rect.height) {
      continue;
    }
    if (Math.abs(getTilt(rrect.angle))>0.1) {
      Mat M=Imgproc.getRotationMatrix2D(rrect.center, getTilt(rrect.angle), 1);

      Imgproc.warpAffine(col, col, M, new Size(img.width, img.height));
      break;
    }
  }
  Imgproc.cvtColor(col, gray, Imgproc.COLOR_BGR2GRAY);
  Imgproc.threshold(gray, bin, 0, 255, Imgproc.THRESH_BINARY | Imgproc.THRESH_OTSU);
  Imgproc.dilate(bin, bin, new Mat(), new Point(-1, -1), dilateErode);
  Imgproc.erode(bin, bin, new Mat(), new Point(-1, -1), dilateErode);
  contours = new ArrayList<MatOfPoint>();
  hierarchy = new Mat(bin.cols(), bin.rows(), CvType.CV_32SC1);
  Imgproc.findContours(bin, contours, hierarchy, Imgproc.RETR_LIST, Imgproc.CHAIN_APPROX_NONE);
  Collections.sort(contours, new Comparator<MatOfPoint>() {
    public int compare(MatOfPoint o1, MatOfPoint o2) {
      double d1 = Imgproc.contourArea(o1);
      double d2 = Imgproc.contourArea(o2);
      if (d1 < d2) {
        return 1;
      }
      if (d2 < d1) {
        return -1;
      }

      return 0;
    }
  }
  );


  int dist=-1;
  boolean inverse=false;
  PVector c1=null;
  for (MatOfPoint contour : contours) {
    //for (int i=3; i<10; i++) {
    // MatOfPoint contour=contours.get(i);
    //      RotatedRect rrect=Imgproc.minAreaRect(new MatOfPoint2f(contour.toArray()));
    //      System.out.println("angle:"+rrect.angle);
    Rect rect=Imgproc.boundingRect(contour);
    if (img.width*3/4<rect.width&&img.height*3/4<rect.height) {
      continue;
    }


    PImage tmp=it.Mat2PI(col.submat(rect));
    if (dist==-1) {
      topImage=tmp;
      dist=rect.y+rect.height/2-img.height/2;
      c1=new PVector((float)rect.x, (float)rect.y);
    } else {
      if (c1!=null&&dist(c1.x, c1.y, (float)rect.x, (float)rect.y)<img.height/6) {
        continue;
      }
      int dist1=rect.y+rect.height/2-img.height/2;
      if (abs(dist1)<abs(dist)) {
        System.out.println("逆");
        frontImage=topImage;
        topImage=tmp;
        if (dist1<0) {
          //向きが逆
          rotateImg(frontImage);
          rotateImg(topImage);
          inverse=true;
        }
      } else {
        frontImage=tmp;
        if (dist<0) {
          //向きが逆
          rotateImg(frontImage);
          rotateImg(topImage);
          inverse=true;
        }
      }
      break;
    }
  }
  for (MatOfPoint contour : contours) {
    Rect rect=Imgproc.boundingRect(contour);
    /*
    角丸オプションのみの場合
     if (10<abs(rect.width-img.width*0.411)&&10<abs(rect.height-img.height*0.0736)) {
     continue;
     }
     */
    if (10<abs(rect.width-img.width*0.5373)&&10<abs(rect.height-img.height*/*0.0752*/0.0841)) {
      continue;
    }
    println(rect.width+" "+rect.height);
    optionImage=it.Mat2PI(col.submat(rect));
    if (inverse) {
      rotateImg(optionImage);
    }
    return;
  }
}

Map<String, Object> getOption(PImage img) {
  if (img==null) {
    return null;
  }
  img.loadPixels();
  int width=img.width, height=img.height;
  Map<String, Object> option=new HashMap<String, Object>();
  /*
  option.put("rounded", isChecked(img, 0.439, 0.107, 0.038, 0.195, 0.25));
   option.put("oneDimension", isChecked(img, 0.439, 0.472, 0.038, 0.195, 0.25));
   if ((Boolean)option.get("oneDimension")) {
   if (isChecked(img, 0.617, 0.723, 0.029, 0.149, 0.33)) {
   option.put("height", 2);
   }
   if (isChecked(img, 0.746, 0.723, 0.029, 0.149, 0.33)) {
   option.put("height", 4);
   }
   if (isChecked(img, 0.876, 0.723, 0.029, 0.149, 0.33)) {
   option.put("height", 6);
   }
   }
   */
  option.put("emboss", isChecked(img, 0.439, 0.089, 0.038, 0.195, 0.25));
  option.put("rounded", isChecked(img, 0.439, 0.329, 0.038, 0.195, 0.25));
  option.put("oneDimension", isChecked(img, 0.439, 0.577, 0.038, 0.195, 0.25));
  if ((Boolean)option.get("oneDimension")) {
    if (isChecked(img, 0.617, 0.788, 0.029, 0.149, 0.33)) {
      option.put("height", 2);
    }
    if (isChecked(img, 0.746, 0.788, 0.029, 0.149, 0.33)) {
      option.put("height", 4);
    }
    if (isChecked(img, 0.876, 0.788, 0.029, 0.149, 0.33)) {
      option.put("height", 6);
    }
  }
  return option;
}

boolean isChecked(PImage img, float x0, float y0, float w0, float h0, float percent) {
  int width=img.width, height=img.height;
  int x=(int)(width*x0), y=(int)(height*y0), w=(int)(width*w0), h=(int)(height*h0);
  int cnt=0;
  for (int i=0; i<w; i++) {
    int x1=x+i;
    for (int j=0; j<h; j++) {
      int y1=y+j;
      int index=x1+y1*width;
      int c=img.pixels[index];
      if (!(200<red(c)&&200<green(c)&&200<blue(c))) {
        cnt++;
      }
    }
  }
  return w*h*percent<cnt;
}

boolean getRoundedOption(PImage img) {
  if (img==null) {
    return false;
  }
  img.loadPixels();
  //rect(width/2+height*39/80,height/2-height/8,height/5,height/5);
  int width=img.width, height=img.height;
  int x=width/2+height*39/80, y=height/2-height/8, w=height/5, h=height/5;
  int cnt=0;
  for (int i=0; i<w; i++) {
    int x1=x+i;
    for (int j=0; j<h; j++) {
      int y1=y+j;
      int index=x1+y1*width;
      int c=img.pixels[index];
      if (!(200<red(c)&&200<green(c)&&200<blue(c))) {
        cnt++;
      }
    }
  }
  return w*h<cnt*3;
}

double getTilt(double angle) {
  if (Math.abs(angle) < 45) {
    return angle;
  }
  if (Math.abs(angle - 90) < 45) {
    return angle-90;
  }
  if (Math.abs(angle - 180) < 45) {
    return angle-180;
  }
  return angle-270;
}

void rotateImg(PImage img) {
  img.loadPixels();
  for (int i=0, n=img.pixels.length/2; i<n; i++) {
    int j=img.pixels.length-1-i;
    int t=img.pixels[i];
    img.pixels[i]=img.pixels[j];
    img.pixels[j]=t;
  }
  img.updatePixels();
}

