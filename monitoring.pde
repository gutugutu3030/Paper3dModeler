//ScanSnapがスキャンした最後の画像を自動取得する
class MonitorPaper implements Runnable {
  String epson=null;
  public void run() {
    preTime=System.currentTimeMillis();
    epson=System.getenv("GTS650");
    if (epson==null) {
      epson="C:/Windows/twain_32/escndv/escndv.exe";
    } else {
      epson=""+epson+"\\escndv.exe";
    }
    execEpsonScan(epson);
    while (true) {
      try {
        Thread.sleep(1000);
        monitor();
      }
      catch(Exception e) {
      }
    }
  }

  long preTime;

  void monitor() {
    long nowTime=System.currentTimeMillis();
    File folder=new File("C:/Users/gutug_000/Pictures");
    for (File f : folder.listFiles ()) {
      if (f.getName().indexOf(".jpg")==-1) {
        continue;
      }
      long lastModified=f.lastModified();
      if (preTime<lastModified&&lastModified<=nowTime) {
        println("画像の発見");
        scanImage(loadImage(f.getAbsolutePath()));
        break;
      }
    }
    preTime=nowTime;
  }
  void execEpsonScan(String epson) {
  try {
    ProcessBuilder pb = new ProcessBuilder(new String[] {
      "\""+epson+"\""
    }
    );
    Process process = pb.start();
  }
  catch(Exception e) {
    e.printStackTrace();
  }
}
}

