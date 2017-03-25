float[] emboss(PImage a, PImage b) {
  Mat mat=it.PI2Mat((embossImg(a)<embossImg(b))?b:a);
//  Imgproc.dilate(mat, mat, new Mat(), new Point(-1, -1), 3);
//  Imgproc.erode(mat, mat, new Mat(), new Point(-1, -1), 3);
  PImage img=it.Mat2PI(mat);
  img.save(dataPath("emboss.png"));
  return new float[] {
    160.0/img.width, 120.0/img.height
  };
  //  Mat mat = new Mat(img.width, img.height, CvType.CV_8UC1);
  //  int dataSize = mat.cols() * mat.rows() * (int)mat.elemSize();
  //  byte[] data = new byte[dataSize];
  //  img.loadPixels();
  //  int index=0;
  //  for (int i = 0; i < dataSize; i ++)
  //  {
  //    int c = img.pixels[(index++)];
  //    data[i] = ((byte)(((c&0xFFFFFF)==0)?0x00:0xFF));
  //  }
  //  mat.put(0, 0, data);
  //  ArrayList<MatOfPoint> contours = new ArrayList<MatOfPoint>();
  //  Mat hierarchy = new Mat(mat.cols(), mat.rows(), CvType.CV_32SC1);
  //  Imgproc.findContours(mat, contours, hierarchy, Imgproc.RETR_TREE, Imgproc.CHAIN_APPROX_SIMPLE);
  //  PriorityQueue<int[]> que=new PriorityQueue<int[]>(5000, new Comparator<int[]>() {
  //    public int compare(int[] a, int[] b) {
  //      return a[1]-b[1];
  //    }
  //  }
  //  );
  //  StringBuilder scad=new StringBuilder();
  //  que.offer(new int[] {
  //    0, 0
  //  }
  //  );//index,階層
  //  int lastNest=-1;
  //  while (!que.isEmpty ()) {
  //    int[] d=que.poll();
  //    if (lastNest<=d[1]) {
  //      if (lastNest!=-1) {
  //        scad.append("}}");
  //      }
  //      scad.append((d[1]%2==0)?"difference(){":);
  //      //階層が変わったのでunionでくくる
  //      scad.append("union(){");
  //      
  //    }
  //  }
  //  return null;
}

int embossImg(PImage img) {
  img.resize(160*2,120*2);
  img.loadPixels();
  int margin=img.width/32;
  int cnt=0;
  for (int i=0; i<img.width; i++) {
    for (int j=0; j<img.height; j++) {
      if (i<=margin||j<=margin||img.width-margin<=i||img.height-margin<=j) {
        img.pixels[i+j*img.width]=color(0);
        continue;
      }
      if (judgePixel(img.pixels[i+j*img.width])) {
        cnt++;
        img.pixels[i+j*img.width]=color(255);
      }
    }
  }
  return cnt;
}

