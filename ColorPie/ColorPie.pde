int ImageIdx=1;
Boolean mouseCLik=false;
PImage[] img=new PImage[5];
int listMargin = 200;
int listSped=20;
int listOnline = 0;
int[] bigPieParams={1120,360,300,300};//x0,y0,wid,hei
int[] smallPieParams={50,50};//wid,hei
int mouseSize=25;
float[] ColorHist;
Boolean[] isOpen=new Boolean[10];

float[] AnalyseSummary(int Ind){
  float[] colorHist = new float[256];
  PImage im=img[Ind];
  im.loadPixels();
  color[] imgPixs=im.pixels;
  //counts pixels 
  for (int w=0;w<im.width;w++){
    for (int h=0;h<im.height;h++){
      color clr=imgPixs[w*h+h];
      colorHist[int(hue(clr)/255*10)]++;
    }
  }
  //numbers to presents
  for(int c=0;c<colorHist.length;c++){
    colorHist[c]=colorHist[c]/im.width/im.height*2*PI;
  }
  return colorHist;
}

float[] AnalysePart(int Ind,int x,int y){
  float[] colorHist = new float[10];
  PImage im=img[Ind];
  im.loadPixels();
  color[] imgPixs=im.pixels;
  //counts pixels
  for (int w=(x-mouseSize<0?0:x-mouseSize);w<(x+mouseSize>=im.width?im.width-1:x+mouseSize);w++){
    for (int h=(y-mouseSize<0?0:y-mouseSize);h<(y+mouseSize>=im.height?im.height-1:y+mouseSize);h++){
      color clr=imgPixs[w*h+h];
      colorHist[int(hue(clr)/255*10)]++;
    }
  }
  
  int totall = ((x+mouseSize>=im.width?im.width-1:x+mouseSize)-(x-mouseSize<0?0:x-mouseSize))*
  ((y+mouseSize>=im.height?im.height-1:y+mouseSize)-(y-mouseSize<0?0:y-mouseSize));
  //numbers to presents
  for(int c=0;c<colorHist.length;c++){
    colorHist[c]=colorHist[c]/totall*2*PI;
  }
  return colorHist;
}

void DrawBigPie(float[] hist){
  noStroke();
  colorMode(HSB, 10);
  
  float beginArc=0;
  float ang=-1;
  if((mouseX-1120)*(mouseX-1120)+(mouseY-360)*(mouseY-360)<150*150){
    float r=sqrt((mouseX-1120)*(mouseX-1120)+(mouseY-360)*(mouseY-360));
    if(mouseY>360){
      ang = acos((mouseX-1120)/r);
    }else{
      ang = 2*PI-acos((mouseX-1120)/r);
    }
    
    //println(ang);
  }
  
  for (int c=0;c<10;c++){
    fill(c,10,10);
    if(ang<beginArc+hist[c] && ang>beginArc){
      println(beginArc);
      println(beginArc+hist[c]);
      int x=0,y=0;
      int w=20;
      float subAng=beginArc+1.0/2*hist[c];
      //subAng=2*PI-subAng;
      x=int(cos(subAng)*w);
      y=int(sin(subAng)*w);
      //println(x);
      //println(y);
      //println(subAng);
      arc(bigPieParams[0]+x,bigPieParams[1]+y,bigPieParams[2],bigPieParams[3],beginArc,beginArc+hist[c],PIE);
    }
    else{
      arc(bigPieParams[0],bigPieParams[1],bigPieParams[2],bigPieParams[3],beginArc,beginArc+hist[c],PIE);
    }
    beginArc+=hist[c];
    
  }
  

  
  
  colorMode(RGB, 255);
}

void DrawSmallPie(float[] hist, int x, int y){
  noStroke();
  colorMode(HSB, 10);
  
  float beginArc=0;
  for (int c=0;c<10;c++){
    fill(c,10,10);
    arc(x,y,smallPieParams[0],smallPieParams[1],beginArc,beginArc+hist[c],PIE);
    beginArc+=hist[c];
  }
  colorMode(RGB, 255);
}

void drawList(int listOnline){
  noStroke();
  fill(240);
  rect(0,0,listOnline,720);
  int topMargin=50;
  int imgWid=160;
  int imgHei=100;
  for (int ind=0;ind<4;ind++){
    image(img[ind],-180+listOnline,topMargin+ind*(imgHei+20),imgWid,imgHei);
    
    //now image
    if(ind==ImageIdx){
      stroke(50,50,200);
      strokeWeight(5);
      noFill();
      rect(-180+listOnline,topMargin+ind*(imgHei+20),imgWid,imgHei);
    }
    
    //mouse interaction
    if(mouseX>(-180+listOnline) && mouseX<(-180+listOnline+imgWid)
        && mouseY>topMargin+ind*(imgHei+20) && mouseY<topMargin+ind*(imgHei+20)+imgHei){
      stroke(240,0,240);
      strokeWeight(5);
      noFill();
      rect(-180+listOnline,topMargin+ind*(imgHei+20),imgWid,imgHei);
      
      //flash summary
      if(mouseCLik){
        ImageIdx=ind;
        ColorHist = AnalyseSummary(ImageIdx);
        DrawBigPie(ColorHist);
      }
     }
  }
  
  noTint();
}

void mouseClicked() {
  mouseCLik=true;
}


void setup() {
  background(0);
  size(1280, 720);
  for (int i=0;i<4;i++){
    img[i] = loadImage("data/"+str(i+1)+".jpeg");
  }
  image(img[ImageIdx], 0, 0,960,720);
  ColorHist = AnalyseSummary(ImageIdx);
  DrawBigPie(ColorHist);
  for (int i=0;i<10;i++){
    isOpen[i]=false;
  }
}
void draw() {
  background(0);
  image(img[ImageIdx], 0, 0,960,720);
  
  boolean isInImg = (mouseX+mouseSize)<960;
  if (isInImg){
    float[] partColorHist=AnalysePart(ImageIdx,mouseX,mouseY);
    DrawSmallPie(partColorHist,mouseX,mouseY);
  }
  if (mouseX<=listOnline || mouseX<mouseSize){
    listOnline=listOnline+listSped;
    listOnline=min(listOnline,listMargin);
    drawList(listOnline);
  }
  if(mouseX>=listOnline){
    listOnline=listOnline-listSped;
    listOnline=max(listOnline,0);
    drawList(listOnline);
  }
  DrawBigPie(ColorHist);
  
  mouseCLik=false;
}
