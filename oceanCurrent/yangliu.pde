String[] lines1;
String[] lines2;
PVector[][] UV=new PVector[1440][632];
int K=10000;
ParticleSystem ps;
void setup(){
  size(1440,632);
  lines1 = loadStrings("U.csv");
  lines2 = loadStrings("V.csv");
  for (int i = 0; i < lines1.length; i++) {
    String[] pieces1 = split(lines1[i], ','); 
    String[] pieces2 = split(lines2[i], ','); 
    for (int j=0; j < pieces1.length; j++) {
      PVector uv=new PVector(float(pieces1[j]),float(pieces2[j]));
      UV[j][i]=uv;
    }
  }
  PImage img = loadImage("s.png");
  PVector[] loc=new PVector[K];
  for (int i=0;i<K;i++){
    loc[i]=new PVector(random(1439),random(631));
  }
  ps = new ParticleSystem(K,loc,img);
  ps.applyForce(UV);

}
void draw(){
   background(78,148,151);
   
   ps.applyForce(UV);
   ps.run();
   
   //for (int x=0;x<1440;x++){
   //  for (int y=0;y<632;y++){
   //    if(Float.isNaN(UV[x][y].x)){
   //      fill(random(100),151,random(100));
   //      noStroke();
   //      ellipse(x,y,3,3);
   //    }
   //  }
   //}
   saveFrame(); 
}
