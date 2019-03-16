import java.util.LinkedList;

Handler handler;
Player player;
long t;
PFont impact;
boolean reset;

void setup(){
  size(360, 600);
  frameRate(60);
  impact = createFont("impact.ttf",72,true);
  textFont(impact);
  reset = true;
}

void draw(){
  
  reset(reset);
  
  t++;
  if(t%120 == 0){
    handler.addObj(new Pipe(width,0,1.5));
  }
  
  handler.tick();
  player.tick();
  collision();
  
  background(140, 211, 240);
  handler.render();
  player.render();
  
  noStroke();
  fill(255,255,64);
  rect(-1,height*7/8, width+2, height/8+2);
}

void collision(){
  //Collision Behavior
  for(Pipe obj : handler.list){
    if(obj.getPos().x <= player.getPos().x+10 && player.getPos().x-10 <= obj.getPos().x + obj.getW()){
      if(obj.getPos().y+obj.getOpening() >= player.getPos().y-10 || player.getPos().y+25 >= obj.getPos().y + obj.getOpening() + obj.getOpeningSize()){
        reset = true;
      }
    }
  }
  if(player.getPos().y >= (height*7/8)){
    reset = true;
  }
}

float clamp(float val, float min, float max){
  return Math.max(min, Math.min(max, val));
}

void reset(boolean r){
  if(r){
    handler = new Handler();
    player = new Player(width/2,height/2);
  }
  reset = false;
}

void keyPressed(){
  setMove(keyCode,true);
}

void keyReleased(){
  setMove(keyCode,false);
}

void setMove(int k,boolean b){
  switch (k) {
    case ' ':
      if(b){ player.setVel(new PVector(0,-4)); }
  }
}


enum Tag{
  PIPE, PLAYER;
}


public class Player{
  private PVector pos = new PVector();
  private PVector vel = new PVector();
  private PVector acc = new PVector();
  private PImage yellowbird_midflap;
  private long score;
  private Tag tag;
  
  Player(float x, float y){
    tag = Tag.PLAYER;
    pos = new PVector(x,y);
    vel = new PVector(0,0);
    acc = new PVector(0,0);
    score = 0;
    yellowbird_midflap = loadImage("yellowbird-midflap.png");
  }
  
  void tick(){
    //gravity
    applyForce(new PVector(0,0.125));
    
    pos.add(vel);
    vel.add(acc);
    acc.mult(0);
    pos.y = clamp(pos.y,0,(height*7/8));
  }
  
  void render(){
    //Display Score
    textSize(72);
    textAlign(CENTER);
    fill(255);
    text((int)score, width/2, 64);
    
    //Draw Bird
    pushMatrix();
    translate(getPos().x,getPos().y);
    rotate(map(getVel().y, -15,15,-3.14,3.14));
    imageMode(CENTER);
    image(yellowbird_midflap, 0, 0);
    popMatrix();
    
    /*//debugging
    textSize(16);
    text(getVel().y, 50,50);*/
  }
  
  void applyForce(PVector f){
    acc.add(f);
  }
  
  void setPos(PVector pos){ this.pos = pos; }
  void setVel(PVector vel){ this.vel = vel; }
  void setAcc(PVector acc){ this.acc = acc; }
  void setScore(long score){ this.score = score; }
  void setTag(Tag tag){ this.tag = tag; }
  
  PVector getPos(){ return pos.copy(); }
  PVector getVel(){ return vel.copy(); }
  PVector getAcc(){ return acc.copy(); }
  long getScore(){ return score; };
  Tag getTag(){ return tag; }
  
}


public class Pipe{
  private PVector pos = new PVector();
  private PVector vel = new PVector();
  private float w, opening, openingSize;
  private Tag tag;
  private boolean scored;
  
  
  Pipe(float x, float y, float v){
    pos.x = x;
    pos.y = y;
    vel.x = -v;
    w = 40;
    openingSize = 150;
    opening = (int) random(0,(height-openingSize-(height/8)));
    tag = Tag.PIPE;
  }
  
  void tick(){
    pos.add(vel);
    
    //Score Behavior
    if(player.getPos().x >= getPos().x && !scored){
      player.setScore(player.getScore()+1);
      scored = true;
    }
  }
  
  void render(){
    
    //Pipe 
    stroke(0,127,0);
    strokeCap(PROJECT);
    strokeWeight(3);
    fill(0,255,0);
    rect(getPos().x, getPos().y, w, getPos().y + opening);
    rect(getPos().x, getPos().y + opening + openingSize, w, height);
    
    //Pipe Topper
    stroke(0,127,0);
    strokeCap(PROJECT);
    strokeWeight(3);
    fill(0,255,0);
    rect(getPos().x - 4, getPos().y + opening - 24, w + 8, 24);
    rect(getPos().x - 4, getPos().y +opening + openingSize - 24, w + 8, 24);
    
  }
  
  void setPos(PVector pos){ this.pos = pos; }
  void setVel(PVector vel){ this.vel = vel; }
  void setTag(Tag tag){ this.tag = tag; }
  
  PVector getPos(){ return pos.copy(); }
  PVector getVel(){ return vel.copy(); }
  float getW(){ return w; };
  float getOpening(){ return opening; }
  float getOpeningSize(){ return openingSize; }
  Tag getTag(){ return tag; }
}


public class Handler{
  LinkedList<Pipe> list = new LinkedList<Pipe>();
  ArrayList<Pipe> toRemove = new ArrayList<Pipe>();
  
  void tick(){
    for(Pipe obj : list){
      obj.tick();
      if(obj.getPos().x <= -obj.getW())
        toRemove.add(obj);
    }
    list.removeAll(toRemove);
    toRemove.removeAll(toRemove);
  }
  
  void render(){
    for(Pipe obj : list)
      obj.render();
  }
  
  void addObj(Pipe obj){ list.add(obj); }
  void removeObj(Pipe obj){ list.remove(obj); }
}
