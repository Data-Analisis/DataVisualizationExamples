FloatTable mtcTable;
int colNum, colWidth;
float[] MilkHeight,TeaHeight,CoffeeHeight;
PFont f;

float speedReduce = 0.1, speedIncrease = 0.05;
float weakenRatio= 0.95;
float[] milkValue, milkSpeed,teaValue, teaSpeed,coffeeValue, coffeeSpeed;

int waveSpread=5;
float mouseAdd = 60.0;
float dt = 30f / 1000f;

void setup() {
    size(1024, 720);
    smooth();
     f = createFont("Arial Black", 72, true);
    
    mtcTable=new FloatTable("milk-tea-coffee.tsv");
    colNum=mtcTable.getRowCount();
    colWidth=round(1024f/colNum);
    
    float maxHeight=max(max(mtcTable.getColumnMax(0),mtcTable.getColumnMax(1)),mtcTable.getColumnMax(2));
    MilkHeight = new float[colNum];
    TeaHeight = new float[colNum];
    CoffeeHeight = new float[colNum];
    for(int i=0;i<colNum;i++){
      MilkHeight[i]=height-mtcTable.getFloat(i,0)/maxHeight*height;
      TeaHeight[i]=height-mtcTable.getFloat(i,1)/maxHeight*height;
      CoffeeHeight[i]=height-mtcTable.getFloat(i,2)/maxHeight*height;
    }
    
    milkValue = new float[colNum];
    milkSpeed = new float[colNum];
    teaValue = new float[colNum];
    teaSpeed = new float[colNum];
    coffeeValue = new float[colNum];
    coffeeSpeed = new float[colNum];
    for(int i = 0; i < colNum; i++){
        milkValue[i]=teaValue[i]=coffeeValue[i]=
        milkSpeed[i]=teaSpeed[i]=coffeeSpeed[i]=0.0f;
    }
       
}

/*
reference form:
https://www.openprocessing.org/sketch/376964
*/
void update(float[] value,float[] speed){
    for(int i=0;i<colNum;i++){
        float v=value[i];
        speed[i]-=speedReduce*v;
        for(int j=1;j<=waveSpread;j++) {
            speed[i]+=speedIncrease*(value[max(i-j,0)]+value[min(i+j,colNum-1)]-2*v)/j;
        }
    }
    for(int i=0; i < colNum; i++) {
       speed[i]=speed[i]*weakenRatio;
       value[i]+=speed[i];
    }
}

/*
reference form:
https://www.openprocessing.org/sketch/376964
*/
void mouseSpread(float[] speed, int ind){
    speed[ind] += mouseAdd;

    for(int i = 1; i < 5; i++) {
        int i2 = ind - i;
        if(i2 >= 0) speed[i2] += mouseAdd * herm((10 - i) / 9);

        i2 = ind + i;
        if(i2 < colNum) speed[i2] += mouseAdd * herm((10 - i) / 9);
    }
}


void mousePressed(){
    int x=mouseX<0?0:mouseX>width-1?width-1:mouseX;
    int ix=(x-colWidth/2)/colWidth;
    if (mouseY>MilkHeight[ix] && mouseY<CoffeeHeight[ix]){
      mouseSpread(milkSpeed,ix);
    }
    else if(mouseY>CoffeeHeight[ix] && mouseY<TeaHeight[ix]){
      mouseSpread(coffeeSpeed,ix);
    }
    else if(mouseY>TeaHeight[ix]){
      mouseSpread(teaSpeed,ix);
    }

    
}
void darwBars(float[] mheight, float[] value){
  for(int i=0;i<colNum-1;i++){
        float x1;
        if(i==0){
          x1 = i*colWidth-1;
        }else{
          x1 = colWidth/2f+i*colWidth-1;
        }
        float y = mheight[i]-value[i];
        float x2 = colWidth/2f+(i+1)*colWidth;

        beginShape(QUAD);
        vertex(x1, height);
        vertex(x1, y);
        vertex(x2, y);
        vertex(x2, height);
        endShape(CLOSE);
    }
}

void draw() {
    background(70, 200, 255);
    update(milkValue,milkSpeed);
    update(teaValue,teaSpeed);
    update(coffeeValue,coffeeSpeed);
    noStroke();
    fill(250,250,250);
    darwBars(MilkHeight,milkValue);

    noStroke();
    fill(53,30,25);
    darwBars(CoffeeHeight,coffeeValue);
 
    noStroke();
    fill(90,180,90);
    darwBars(TeaHeight,teaValue);
    
    textFont(f, 50);
    fill(250,250,250);
    text("MILK", 370, 350);
    fill(0,0,0);
    text("COFFEE", 370, 400);
    fill(90,180,90);
    text("TEA",370, 450);
    
    textFont(f, 25);
    fill(255);
    text("YEAR>>>", 880, 20);
}

float herm(float t) {
    return t * t * (3.0f - 2.0f * t);
}
