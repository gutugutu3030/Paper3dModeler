ArrayList<StrokeParts> extractStroke(PImage img) {
  int hist[][][]=createHist(img);
  int map[][]=getMap(hist,img);
  adjustMap(map);
  printMap(map);
  printMap1(map);

  println("再帰による直線探索");
  boolean arrival[][]=new boolean[map.length][map[0].length];
  //頂点から探索を開始する
  ArrayList<StrokeParts> partsList=new ArrayList<StrokeParts>();
  for (int i=0; i<map.length; i+=2) {
    for (int j=0; j<map[0].length; j+=2) {
      if (!arrival[i][j]&&map[i][j]!=0) {
        StrokeParts parts=new StrokeParts(map[i][j]);
        getStrokeParts(map, arrival, i, j, parts, null);
        partsList.add(parts);
      }
    }
  }
  println("簡易的な線の統合");
  mergeParts(partsList, map);
  println("線の数"+partsList.size());
  return mergeSameIdParts(partsList, map);
}

PImage processingImage4Stroke(PImage img) {
  return processingImage4Stroke(img, 3/*ScanSnap S1500用設定*/);
}

//上面図，正面図の画像をきれいにする
PImage processingImage4Stroke(PImage img, int dilateErode) {
  Mat col=it.PI2Mat(img), gray=new Mat();
  Imgproc.cvtColor(col, gray, Imgproc.COLOR_BGR2GRAY);
  Imgproc.dilate(gray, gray, new Mat(), new Point(-1, -1), dilateErode);
  Imgproc.erode(gray, gray, new Mat(), new Point(-1, -1), dilateErode);
  Mat mask = new Mat();
  Imgproc.threshold(gray, mask, 200, 255, Imgproc.THRESH_BINARY_INV);
  Mat foreground = new Mat(gray.size(), CvType.CV_8UC1, new Scalar(255, 255, 255));
  col.copyTo(foreground, mask);
  PImage dst = it.Mat2PI(foreground);
  return dst;
}


//画像からヒストグラムを作成する
int[][][] createHist(PImage img) {
  //紙は160mm x 120mm
  //線の数は枠を除く
  float ww=img.width/32.0;//x軸　分割の幅
  float hh=img.height/24.0;//y軸　分割の幅
  int hist[][][]=new int[64][48][10];
  img.loadPixels();
  //頂点の読み込み　はしっこはみない
  for (int i=2; i<hist.length-1; i++) {
    for (int j=2; j<hist[0].length-1; j++) {
      if (i%2==0&&j%2==0) {
        for (int i1= (int)(i*ww/2-ww/2); i1<(int)(i*ww/2+ww/2); i1++) {
          for (int j1= (int)(j*hh/2-hh/2); j1<(int)(j*hh/2+hh/2); j1++) {
            int c=img.pixels[i1+j1*img.width];
            if (judgePixel(c)) {
              hist[i][j][getId(c)]++;
            }
          }
        }
      } else if (i%2==1&&j%2==1) {
        for (int i1= (int)(i*ww/2)-1; i1<(int)(i*ww/2)+1; i1++) {
          for (int j1= (int)(j*hh/2)-1; j1<(int)(j*hh/2)+1; j1++) {
            int c=img.pixels[i1+j1*img.width];
            if (judgePixel(c)) {
              hist[i][j][getId(c)]++;
            }
          }
        }
      } else {
        for (int i1= (int)(i*ww/2-ww/5); i1<(int)(i*ww/2+ww/5); i1++) {
          for (int j1= (int)(j*hh/2-hh/5); j1<(int)(j*hh/2+hh/5); j1++) {
            int c=img.pixels[i1+j1*img.width];
            if (judgePixel(c)) {
              hist[i][j][getId(c)]++;
            }
          }
        }
      }
    }
  }
  return hist;
}

//データありピクセルかどうかの判定
boolean judgePixel(int c) {
  if (false) {
    return (c&0xFFFFFF)!=0;
  }
  int cnt=0;
  if (red(c)>5) {
    cnt++;
  }
  if (green(c)>5) {
    cnt++;
  }
  if (blue(c)>5) {
    cnt++;
  }
  return (1<=cnt);
}

//色の判別（黒がこないことが前提　水色　赤　橙　が認識精度良い）
int getId(int c) {
  return (int)svm.test(new float[] {
    hue(c)/255, saturation(c)/255, brightness(c)/255
  }
  );
}

//ヒストグラムから一番確率が高いマップを作成する
int[][] getMap(int hist[][][],PImage img) {
  //初期値0
  int map[][]=new int[hist.length][hist[0].length];
  for (int i=0; i<hist.length; i++) {
    for (int j=0; j<hist[0].length; j++) {
      int maxI=-1;
      for (int k=0; k<hist[0][0].length; k++) {
        if (maxI==-1) {
          if (i%2==1&&j%2==1) {
            if (hist[i][j][k]>=4) {
              maxI=k;
            }
          } else/* if (i%2==0&&i%2==0)*/ {
            if (hist[i][j][k]>=20/*20*/) {
              maxI=k;
            }
          } /*else {

            int ww=(int)(img.width/32.0*2/5);//x軸　分割の幅
            int hh=(int)(img.height/24.0*2/5);//y軸　分割の幅
            if (hist[i][j][k]>=ww*hh*3/4) {
              maxI=k;
            }
          }*/
          continue;
        }
        if (hist[i][j][maxI]<hist[i][j][k]) {
          maxI=k;
        }
      }
      if (maxI==-1) {
        maxI=0;
      }
      //map[i][j]=maxI+1;
      map[i][j]=maxI;
    }
  }
  return map;
}


void adjustMap(int map[][]) {
  //塗りつぶしの中に直線が入らないようにする
  int ds[][]= {
    {
      1, 1
    }
    , {
      -1, 1
    }
    , {
      -1, -1
    }
    , {
      1, -1
    }
  };
  for (int i=2; i<map.length-1; i+=2) {
    for (int j=2; j<map[0].length-1; j+=2) {
      if (map[i][j]!=0) {
        int cnt=0;
        for (int d[] : ds) {
          if (map[i+d[0]][j+d[1]]!=0) {
            cnt++;
          }
        }
        if (cnt==4) {
          map[i][j]=0;
        }
        if (cnt>=1) {
          map[i][j]*=-1;
        }
      }
    }
  }
}

//再帰呼び出しにより，直線と思われる部分を切り出してくる
void getStrokeParts(int map[][], boolean arrival[][], int x, int y, StrokeParts list, int from[]) {
  arrival[x][y]=true;
  list.add(x, y);
  int ds[][]= {
    {
      1, 0
    }
    , {
      0, 1
    }
    , {
      -1, 0
    }
    , {
      0, -1
    }
  };
  int d1[]=null;
  for (int d[] : ds) {
    if (x+d[0]*2<0||map.length<=x+d[0]*2) {
      continue;
    }
    if (y+d[1]*2<0||map[0].length<=y+d[1]*2) {
      continue;
    }
    if (arrival[x+d[0]*2][y+d[1]*2]) {
      continue;
    }
    if (map[x+d[0]][y+d[1]]==map[x][y]&&map[x+d[0]*2][y+d[1]*2]==map[x][y]) {
      //中点も見て，それも同じ色の場合にのみ追加を行う．
      if (from!=null&&from[0]==-1*d[0]&&from[1]==-1*d[1]) {
        //来た道をもどるので却下
        continue;
      }
      getStrokeParts(map, arrival, x+d[0]*2, y+d[1]*2, list, d);
      return;
    }

    if (map[x+d[0]*2][y+d[1]*2]==map[x][y]) {
      if (from!=null&&from[0]==-1*d[0]&&from[1]==-1*d[1]) {
        //来た道をもどるので却下
        continue;
      }
      //中点は埋まってなかったが，繋がりそうならいったん保留
      d1=d;
    }
  }

  if (d1!=null) {
    //保留した方向につなぐ
    getStrokeParts(map, arrival, x+d1[0]*2, y+d1[1]*2, list, d1);
  }
}

