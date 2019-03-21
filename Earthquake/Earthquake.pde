import g4p_controls.*;
Table table1,table2;
PImage map;
EQdata[] datas;
GCustomSlider timeSlider;
Drawer drawer = new Drawer();
int winSiz=5;

void setup() {
  //make map
  map=loadImage("land_shallow_topo_1024_inverted.jpg");
  size(1224, 612); 
  //load data
  //do not change the ordder, whitch with a time-inverse-order
  table1 = loadTable("all_2000s_M6plus.csv", "header");
  table2 = loadTable("all_2010s_M6plus.csv", "header");
  datas = new EQdata[table1.getRowCount()+ table2.getRowCount()];
  int r=0;
  for (TableRow row : table2.rows()) {
    datas[r]=new EQdata();
    datas[r].time = row.getString("time");
    datas[r].latit = row.getFloat("latitude");
    datas[r].longit = row.getFloat("longitude");
    datas[r].depth = row.getFloat("depth");
    datas[r].mag = row.getFloat("mag");
    datas[r].place=row.getString("place");
    r++;
  }
  for (TableRow row : table1.rows()) {
    datas[r]=new EQdata();
    datas[r].time = row.getString("time");
    datas[r].latit = row.getFloat("latitude");
    datas[r].longit = row.getFloat("longitude");
    datas[r].depth = row.getFloat("depth");
    datas[r].mag = row.getFloat("mag");
    datas[r].place=row.getString("place");
    r++;
  }
  
  //make slider
  timeSlider = new GCustomSlider(this, 0, map.height, map.width+150, 100, "blue18px");
  // show          opaque  ticks value limits
  timeSlider.setShowDecor(false, true, true, true);
  timeSlider.setNbrTicks(1);
  timeSlider.setShowDecor(false, true, false, true);
  timeSlider.setLimits(2000, 2000, 2018);

}

void draw(){
  colorMode(RGB,255,255,255);
  background(255);
  drawLegend();
  image(map,0,0);
  int cuntP=int(((1-(timeSlider.getValueF()-2000)/18))*(table1.getRowCount()+ table2.getRowCount()-1));
  //println(cuntP);
  drawer.drawEarthquakes(cuntP,winSiz);
}

class EQdata{
  
  String time,place;
  float latit,longit,depth,mag;
  public float x,y;
  public float r;
  public void addPoint(mapPoint mp){
    x=mp.x;
    y=mp.y;
    r=mp.r;
  }
  EQdata(){
  time="";
  place="";
  latit=0;
  longit=0;
  depth=0;
  mag=0;
  x=0;
  y=0;
  r=0;
  }
 
}

class mapPoint{
  public float x,y;
  public float r;
  mapPoint(){}
}


class Drawer{
  //private float earthRad = 6378137.0;
  Drawer(){};
  public void drawEarthquakes(int cnt, int bak){
    int start = min(cnt+bak,table1.getRowCount()+ table2.getRowCount()-1);
    EQdata textP = new EQdata();
    float minDis=1e7;
    for (int row =start;row>=cnt;row--){
      colorMode(HSB,360,100,100,100);
      ellipseMode(RADIUS);
      stroke(depth2color(datas[row].depth),50,50,100);
      fill(depth2color(datas[row].depth),100,100,(1-((float(row-cnt))/(start-cnt)))*100);
      
      mapPoint mp = new mapPoint();
      mp.x=longti2x(datas[row].longit);
      mp.y=lati2y(datas[row].latit);
      mp.r=mag2radius(datas[row].mag);
      
      ellipse(mp.x,mp.y,mp.r,mp.r);
      //println(lati2x(datas[row].latit)+" , "+longti2y(datas[row].longit));
      //mouse in cricle
      float cntDis=sqrt(mp.r*mp.r)-sqrt((mouseX-mp.x)*(mouseX-mp.x)+(mouseY-mp.y)*(mouseY-mp.y));
      if(cntDis>=0 && cntDis<minDis){
        minDis=cntDis;
        textP=datas[row];
        textP.addPoint(mp);
      }
    }
    if(minDis<1e7){
      float tx=(textP.x+textP.r+200)>map.width?textP.x-textP.r-200:textP.x+textP.r;
      float ty=textP.y;
      colorMode(RGB,255,255,255,255);
      noStroke();
      fill(0,0,0,200);
      rect(tx,ty,200,20);
      fill(255,255,255,255);
      textSize(10);
      text(textP.time,tx,ty+10);
      text(textP.place,tx,ty+20);
      
    }
  }
  private int depth2color(float depth){
      //HSB:100,100,100-green
      //HSB:0,100,100-red
      return int(max(600-depth,0)/600*100);
  }
  private float mag2radius(float mag){
    return 30*(mag-6);
  }
  private float lati2y(float lati){
  return map.height-(lati+90)/180*map.height;
  }
  private float longti2x(float longti){
  return (longti+180)/360*map.width;
  };
  //private float lati2y(float lati){
  //  lati=lati/180*PI;
  //  //int signLati=0;
  //  //if (lati<0){signLati=-1;}
  //  //if(lati>0){signLati=1;}
  //  float yinm=earthRad/2*log((1.0+sin(lati))/(1.0-sin(lati)));
  //  float yinMap=(yinm+20037508.3)/40075016.6*map.height;
  //  return yinMap;
  //}
  //private float longti2x(float longti){
  //  float xinm=longti*PI/180*earthRad;
  //  float xinMap=(xinm+20037508.3)/40075016.6*map.width;
  //  return xinMap;
  //}

}
void drawLegend(){
  colorMode(HSB,360,100,100,100);
  
  fill(0,0,0,100);
  textSize(15);
  text("depth",1054,30);
  text("mag",1150,30);
  
  int l=0;
  for(float dep=0;dep<=600;dep=dep+2){
    
    stroke((600-dep)/600*100,100,100);
    line(1054,50+l,1084,50+l);
    if(dep%100==0){
      fill(0,0,0,100);
      textSize(10);
      text(str(int(dep)),1090,50+l);
    }
    l++;
  }
  
  for(float magi=60;magi<=80;magi++){
    float mag=magi/10;
    //println(mag);
    stroke(0,0,0);
    line(1150,50,1150,50+2*30*(mag-6));
    line(1150,50+2*30*(mag-6),1155,50+2*30*(mag-6));
    if(mag%1==0){
      fill(0,0,0,100);
      textSize(10);
      text(str(mag),1160,50+2*30*(mag-6));
    }
  }
}
