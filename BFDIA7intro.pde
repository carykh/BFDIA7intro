import com.hamoid.*;
VideoExport videoExport;
String VIDEO_FILE_NAME = "bfdia7_intro_1080p.mp4";

float SCALE = 1; // 1080p. If you change this, you also have to go to size(1920,1080); down below, and change that too.
float PLAY_SPEED = 1;
boolean RENDER_WITH_ANIMATIONS = false; // I chose not to upload all the animation frames to the GitHub repo, because it exceeds GitHub Desktop's limit

String[] data;
Card[] cards;
Card FSBwobble;
Card[] BFDIA;
int BFDIA_len = 6;
PFont font;
int frames = 0;
float initial_s = 72+50;
float initial_e = 72+80;
int FRIES_START = 55;
float FPS = 24;
float TEAM_SPEED = 60;

float song_start_f = 72+57;
float song_end_f = song_start_f+390;
float frames_per_beat = 10.327;

float DX = 300;
float DY = 266;
PImage bg;
int RAY_COUNT = 210;
Ray[] rays;
float[] FSB_spin_times;
void loadCards(){
  randomSeed(123);
  data = loadStrings("data.csv");
  cards = new Card[data.length];
  for(int i = 0; i < cards.length; i++){
    cards[i] = new Card(i, data[i],false);
  }
  FSBwobble = new Card(0,data[0],false);
  BFDIA = new Card[BFDIA_len];
  for(int i = 0; i < BFDIA_len; i++){
    BFDIA[i] = new Card(0,data[0],true);
  }
}
float getTeamIndexTime(){
  float val = (frames-song_end_f)/TEAM_SPEED;
  return min(max(val,0),3);
}
void loadFSB(){
  String[] FSBdata = loadStrings("fsb.csv");
  FSB_spin_times = new float[FSBdata.length+1];
  FSB_spin_times[0] = 0;
  for(int i = 0; i < FSBdata.length; i++){
    float value = Float.parseFloat(FSBdata[i]);
    FSB_spin_times[i+1] = value*FPS+song_start_f-FRIES_START-1; // 1 frame to make the visuals appear before audio
  }
}
float getFSBindex(){
  int index = 0;
  
  for(int i = 0; i < FSB_spin_times.length; i++){
    if(FSB_spin_times[i] > frames){
      index = i-1;
      break;
    }
  }
  float before_frame = FSB_spin_times[index];
  float after_frame = FSB_spin_times[index+1];
  float frac = (frames-before_frame)/(after_frame-before_frame);
  
  return index+frac;
}
void initializeRays(){
  rays = new Ray[RAY_COUNT];
  for(int r = 0; r < RAY_COUNT; r++){
    rays[r] = new Ray();
  }
}
void drawCards(){
  float currentBeat = (frames-song_start_f)/frames_per_beat;
  int currentCard = -1;
  for(int i = 0; i < cards.length; i++){
    if(currentBeat >= cards[i].beat){
      currentCard = i;
    }
  }
  if(frames >= song_end_f){
    currentCard = -1;
  }
  for(int i = 0; i < cards.length; i++){
    cards[i].drawCard(i == currentCard);
  }
  for(int i = 0; i < BFDIA_len; i++){
    BFDIA[i].drawLetter(i);
  }
}
void setup(){
  bg = loadImage("bg.png");
  font = createFont("Helvetica 95.ttf", 96);
  loadCards();
  loadFSB();
  initializeRays();
  size(1920,1080,P3D);
  frameRate(FPS);
  
  videoExport = new VideoExport(this, VIDEO_FILE_NAME);
  videoExport.setFrameRate(FPS);
  videoExport.startMovie();
}
void drawBackground(){
  pushMatrix();
  translate(0,0,-1000);
  float SCALE = 1.1;
  image(bg,-960*SCALE,-540*SCALE,3840*SCALE,2160*SCALE);
  popMatrix();
}
void drawRays(){
  pushMatrix();
  translate(960,540,-900);
  float EPS = 2500;
  for(int i = 0; i < RAY_COUNT; i++){
    Ray r = rays[i];
    fill(200,255,240,r.brightness.getValue());
    beginShape();
    vertex(0,0);
    vertex(cos(r.ang+r.wid/2)*EPS,sin(r.ang+r.wid/2)*EPS);
    vertex(cos(r.ang-r.wid/2)*EPS,sin(r.ang-r.wid/2)*EPS);
    endShape(CLOSE);
  }
  popMatrix();
}
float cosInter(float x){
  return 0.5-0.5*cos(x*PI);
}
float arrSafeLookup(float[] arr, int i){
  return arr[min(max(i,0),arr.length-1)];
}
float arrCosIndex(float[] arr, float x, float fac){
  int xi = (int)x;
  float x_rem = min(max((x%1.0)/fac,0),1);
  float val_before = arrSafeLookup(arr,xi);
  float val_after = arrSafeLookup(arr,xi+1);
  return val_before+cosInter(x_rem)*(val_after-val_before);
}
float getY(float f){
  float[] vals = {-1.0,1.6,1.4,0.42,0.52,1.1,1.2,1.8,1.9,4.0,4.2,1.65,1.35,-1.0,-1.2,-1.4};
  int v = vals.length-1;
  int i = (int)f;
  float base = vals[min(i,v)]+cosInter(f%1.0)*(vals[min(i+1,v)]-vals[min(i,v)]);
  return (base-1.5)*DY+540;
}

float getX(float f){
  float[] vals = {0,0,0,0,0,0,0,0,0,0,1.8,0.3,0.0,1.0,2,3};
  int v = vals.length-1;
  int i = (int)f;
  float base = vals[min(i,v)]+cosInter(f%1.0)*(vals[min(i+1,v)]-vals[min(i,v)]);
  return 1550+80*base;
}
void drawFSB(){
  float FSBindex = getFSBindex();
  float FIM = FSBindex%2;
  
  pushMatrix();
  translate(getX(FSBindex)+FSBwobble.xWob.getValue()*0.6,
  getY(FSBindex)+FSBwobble.yWob.getValue()*0.6,200);
  
  rotateY(-PI*0.45);
  rotateZ(FSBwobble.pitchWob.getValue()*0.6);
  rotateX(FSBwobble.spinWob.getValue()*0.6);
  if(FIM < 1){
    float zer = PI*0.25+1.61803*(2*PI)*(int)(FSBindex);
    rotateZ(zer);
    rotateX(cosInter(FIM)*2*PI);
    rotateZ(-zer);
  }
  fill(255,128,0);
  float W = 50;
  float H = 80;
  
  for(int tb = 0; tb < 2; tb++){
    pushMatrix();
    translate(0,H*(2*tb-1),0);
    rotateX(PI/2);
    rect(-W,-W,W*2,W*2);
    popMatrix();
  }
  for(int p = 0; p < 4; p++){
    pushMatrix();
    rotateY(PI/2*p);
    translate(0,0,W);
    rect(-W,-H,W*2,H*2);
    popMatrix();
  }
  pushMatrix();
  fill(255);
  translate(0,-30,50);
  scale(1,1,0.2);
  sphere(45);
  translate(0,0,40); // used to be translate(0,0,30);
  if(FIM >= 1){
    scale(1,1,random(1,4.55));
  }
  sphere(35);
  popMatrix();
  popMatrix();
}
void draw(){
  scale(SCALE);
  drawBackground();
  drawRays();
  lights();
  drawCards();
  drawFSB();
  videoExport.saveFrame();
  frames += PLAY_SPEED;
}
