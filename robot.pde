class Scan extends Thread {
  PApplet apa;
  String path=null;
  Scan(PApplet apa) {
    this.apa=apa;
    initFolder();
  }
  Scan(PApplet apa, String path) {
    this.apa=apa;
    this.path=path;
    try{
    initFolder();
    }catch(Exception e){
      println("準備フォルダがない");
    }
  }
  void initFolder(){
    File folder=new File("C:/Users/demo/Pictures");
    int imgCnt=0;
    for (File f : folder.listFiles ()) {
      if (f.getName().indexOf(".jpg")!=-1) {
        f.delete();
      }
    }
  }
  void run() {
    setState(0);
    if (path!=null) {
      try {
        Thread.sleep(5000);
      }
      catch(Exception e) {
      }
      setState(1);
      scanImage(loadImage(path));
      return;
    }
    File folder=new File("C:/Users/demo/Pictures");
    int imgCnt=0;
    for (File f : folder.listFiles ()) {
      if (f.getName().indexOf(".jpg")!=-1) {
        imgCnt++;
      }
    }
    println("1111");


    try {
      ProcessBuilder pb = new ProcessBuilder(new String[] {
        //"\""+dataPath("scan.bat")+"\""
        "C:/Users/demo/Dropbox/Drawing2DStudy/scanPrinter/data/scan.bat"
      }
      );
      Process process = pb.start();
      println("2222");

      while (true) {
        File img=null;
        int cnt=0;
        int last=0;
        for (File f : folder.listFiles ()) {
          if (f.getName().indexOf(".jpg")==-1) {
            continue;
          }
          int num=parseInt(f.getName().split("_")[1].split("\\.")[0].replaceFirst("^0+", ""));
          cnt++;
          long lastModified=f.lastModified();
          if (last<num) {
            last=num;
            img=f;
          }
        }
        if (cnt==imgCnt+1) {
          setState(1);
          scanImage(loadImage(img.getAbsolutePath()));
          break;
        }
        Thread.sleep(1);
      }
    }
    catch(Exception e) {
      e.printStackTrace();
    }
  }
}
/*
void scanPaperWithRobot() {
 showString("スキャン中");
 try {
 ProcessBuilder pb = new ProcessBuilder(new String[] {
 "\""+dataPath("scan.bat")+"\""
 }
 );
 long preTime=System.currentTimeMillis();
 Process process = pb.start();
 while (true) {
 long nowTime=System.currentTimeMillis();
 File folder=new File("C:/Users/gutug_000/Pictures");
 for (File f : folder.listFiles ()) {
 if (f.getName().indexOf(".jpg")==-1) {
 continue;
 }
 long lastModified=f.lastModified();
 if (preTime<lastModified&&lastModified<=nowTime) {
 println("画像の発見");
 showString("画像解析中");
 scanImage(loadImage(f.getAbsolutePath()));
 break;
 }
 }
 preTime=nowTime;
 }
 }
 catch(Exception e) {
 }
 }
 */
