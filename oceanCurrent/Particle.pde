
// A simple Particle class, renders the particle as an image

class Particle {
  PVector loc;
  PVector vel;
  PVector acc;
  float lifespan;
  Boolean isDead=false;
  PImage img;

  Particle(PVector l, PImage img_) {
    acc = new PVector(0, 0);
    float vx = 0;
    float vy = 0;
    vel = new PVector(vx, vy);
    loc = l.copy();
    //lifespan = 100.0;
    img = img_;
  }

  void run() {
    update();
    if (!isDead){
      render();
    }
  }

  // Method to apply a force vector to the Particle object
  // Note we are ignoring "mass" here
  void applyForce(PVector f) {
    acc.add(f);
  }  

  // Method to update position
  void update() {
    vel.add(acc);
    loc.add(vel);
    acc.mult(0); // clear Acceleration
    if (Float.isNaN(acc.x)){
      isDead=true;
    }
    loc.x=loc.x<1?1439:loc.x;
    loc.x=loc.x>1439?0:loc.x;
    loc.y=loc.y<1?631:loc.y;
    loc.y=loc.y>631?0:loc.y;
  
  }

  // Method to display
  void render() {
    imageMode(CENTER);
    tint(255,70);
    image(img, loc.x, loc.y);
    // Drawing a circle instead
     //fill(255);
     //noStroke();
     //ellipse(loc.x,loc.y,3,3/*,img.width,img.height*/);
  }
}
