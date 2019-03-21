import geomerative.*;
RShape shapes;
String scaleFlag1;
String scaleFlag2;
float savColr,savK;
Table table;
void setup() {
  RG.init(this);
  size(800, 500);
  shapes = RG.loadShape("USA_Counties_with_FIPS_and_names.svg");
  table = loadTable("unemployment09.csv", "csv");
  colorMode(HSB, 360,100,100);
}

void draw() {
  background(0,0,100);
  pushMatrix();
  
  translate(100, 100);
  Boolean inShp=false;
  for (TableRow row : table.rows()) {
    String id=row.getString(1)+row.getString(2);
    RShape shp=shapes.getChild(id);
    if (shp!=null){
      float colr=(row.getFloat(8)-2)/10;
      if (shp.contains(new RPoint(mouseX-100,mouseY-100))){
        scaleFlag1=id;
        savColr=colr;
        inShp=true;
      }else{
        shp.setStroke(false);
        shp.setFill(color(120*(1-colr),60,100));
      }
       shp.draw();
    } //<>//
  }
  if (!inShp){
    scaleFlag1="_";
  }
  
  // then mouse in shape:
  RShape shp1=shapes.getChild(scaleFlag1);
  if(scaleFlag1!=scaleFlag2){
    RShape shp2=shapes.getChild(scaleFlag2);
    if (shp2!=null){
      shp2.scale(1/savK,shp2.getCenter());
    }
    if (shp1!=null){
      float scaleK=30/min(shp1.getWidth(),shp1.getHeight());
      savK=scaleK;
      shp1.scale(scaleK,shp1.getCenter());
    }
    scaleFlag2=scaleFlag1;
  }
  if (shp1!=null){
    shp1.setStroke(color(58,100,100));
    shp1.setStrokeWeight(2);
    shp1.setFill(color(120*(1-savColr),100,100));
    shp1.draw();
    for (TableRow row :table.findRows(scaleFlag1.substring(0,2),1)){
      if (row.getString(2).equals(scaleFlag1.substring(2))){
        textSize(20);
        fill(0);
        text(row.getString(3),40,-80);
        text(row.getString(8),40,-50);
      }
    }
  }
  popMatrix();
  
  
}
