import processing.serial.*;
import java.awt.Label;
import java.awt.Choice;
import java.awt.Button;
import java.awt.Checkbox;
import java.awt.TextField;

class Control extends ExtraWindow {
  PApplet apa;
  Choice comSelect, howToPrint;
  Label temp;
  TextField tempT;
  boolean serialReady=false;
  Checkbox support;
  Control(PApplet theApplet, final String theName,final String comPort){
    super(theApplet, theName, 0, 0, 400, 150);
    apa=theApplet;
    autoConnectPrinter(comPort);
  }
  Control(PApplet theApplet, final String theName) {
    super(theApplet, theName, 0, 0, 400, 150);
    apa=theApplet;
  }
  void windowClosing(WindowEvent e) {
    apa.exit();
    super.windowClosing(e);
  }
  void setup() {
    comSelect=new Choice();
    serialListLength=Serial.list().length;
    comSelect.removeAll();
    for (String com : Serial.list ()) {
      comSelect.add(com);
    }
    add(comSelect);
    Button connectButton=new Button("接続");
    connectButton.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent e) {
        connectPrinter();
      }
    }
    );
    add(connectButton);
    Checkbox heat = new Checkbox("set");
    heat.addItemListener(new ItemListener() {
      public void itemStateChanged(ItemEvent e) {
        setHeater(e.getStateChange() == ItemEvent.SELECTED);
      }
    }
    );
    add(heat);
    tempT=new TextField("200");
    add(tempT);
    temp=new Label("------℃");
    add(temp);
    howToPrint=new Choice();
    howToPrint.add("サポート無し");
    howToPrint.add("サポートあり");
    howToPrint.add("0.1mmピッチ");
    howToPrint.select(1);
    add(howToPrint);
  }

  GCode saveAndCreateGCode() {
    String stlpath=apa.dataPath("tmp.stl");
    String gcodepath=apa.dataPath("tmp.gcode");
    //STL.saveBin(stlpath, m);
    int time=slice(stlpath, gcodepath);
    GCode gcode=new GCode(gcodepath);
    gcode.setTime(time);
    return gcode;
  }
  int slice(String input, String output) {
    String ini=apa.dataPath("fast-cura.ini");
    switch(control.howToPrint.getSelectedIndex()) {
    case 0:
      ini=apa.dataPath("fast-cura.ini");
      break;
    case 1:
      ini=apa.dataPath("cura-support.ini");
      break;
    case 2:
      ini=apa.dataPath("cura01.ini");
      break;
    }
    
    String curaPath=System.getenv("curaEngine");
    if (curaPath==null) {
      curaPath="D:/Program Files/Repetier-Host/plugins/CuraEngine/CuraEngine.exe";
    } else {
      curaPath=""+curaPath+"\\CuraEngine.exe";
    }
    
    Cura cura = new Cura(curaPath, ini, input, output);
    int time=-1;
    try {      
      cura.exe();
      time =cura.getTime();
    }
    catch(Exception e) {
      e.printStackTrace();
    }
    //exit();
    return time;
  }

  void startPrint() {
    if (gcode==null) {
      println("slice");
      gcode=saveAndCreateGCode();
    }
    if (gcode.printing) {
      println("pause");
      gcode.pausePrinting();
    } else {
      if (printer!=null) {
        println("start printing");
        gcode.printAll(printer);
      }
    }
  }
  void autoConnectPrinter(String comPort){
    println("auto connect");
    Serial tmp=new Serial(apa, comPort, 250000);
    try {
      Thread.sleep(3000);
    }
    catch(Exception e) {
    }
    tmp.write("G28\n");//現在地をホームポジションに戻す
    println("send to pinter: G28");
    tmp.write("G0 X0 Y0 Z30\n");//Z30
    println("send to pinter: G0 X0 Y130 Z30");
    tmp.write("M104 S220\n");//トルクロックを切る
    tmp.write("M109 S220\n");//トルクロックを切る
    printer=tmp;
  }
  void connectPrinter(){
    connectPrinter(comSelect.getSelectedItem());
  }
  void connectPrinter(String comPort) {
    Serial tmp=new Serial(apa, comPort, 250000);
    try {
      Thread.sleep(3000);
    }
    catch(Exception e) {
    }
    tmp.write("G28\n");//現在地をホームポジションに戻す
    println("send to pinter: G28");
    tmp.write("G0 X0 Y130 Z30\n");//Z30
    println("send to pinter: G0 X0 Y130 Z30");
    tmp.write("M84\n");//トルクロックを切る
    println("send to pinter: M84");
    printer=tmp;
  }
  void setHeater(boolean on) {
    printer.write((on)?("M104 S"+tempT.getText()+"\n"):"M104 S0\n");
    println("send to pinter: "+((on)?"M104 S200":"M104 S0"));
  }
  int serialListLength=0;
  void draw() {
    background(200);
    if (serialListLength!=Serial.list().length) {
      serialListLength=Serial.list().length;
      comSelect.removeAll();
      for (String com : Serial.list ()) {
        comSelect.add(com);
      }
    }
    if (gcode!=null&&gcode.printing) {
      fill(255, 0, 0);
      text(gcode.getTimeString(), 10, 50);
      return;
    }
    if (printer==null||!serialReady) {
      return;
    }
    //printer.write("M114\n");//現在地確認
    //println("send to pinter: M114");
    if (frameCount%10==0) {
            printer.write("M105\n");//温度確認
      //println("send to pinter: M105");
    }
  }
}

