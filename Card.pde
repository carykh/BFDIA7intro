class Card{
  String name;
  float x;
  float y;
  int teamNum;
  float teamX;
  float teamY;
  float beat;
  float initial;
  float rotationAxis;
  float initialSpins;
  
  PImage[] thumbs;
  int thumb_s;
  int thumb_e;
  
  Wobble spinWob = new Wobble(random(24,48),random(0.2,0.4));
  Wobble pitchWob = new Wobble(random(24,48),random(0.1,0.2));
  Wobble xWob = new Wobble(random(24,48),random(10,25));
  Wobble yWob = new Wobble(random(24,48),random(10,25));
  
  
  public Card(int i, String line, boolean isLetter){
    String[] parts = line.split(",");
    name = parts[0];
    y = Float.parseFloat(parts[1]);
    x = Float.parseFloat(parts[2]);
    teamNum = Integer.parseInt(parts[6]);
    teamY = Float.parseFloat(parts[7]);
    teamX = Float.parseFloat(parts[8]);
    beat = Float.parseFloat(parts[3]);
    initial = random(initial_s,initial_e);
    if(isLetter){
      initial = initial_s + (initial_e-initial_s)*(i/4.0);
    }
    rotationAxis = random(0,2*PI);
    initialSpins = random(-5,5);
    
    thumb_s = max(Integer.parseInt(parts[4]),1);
    if(RENDER_WITH_ANIMATIONS){
      thumb_e = max(Integer.parseInt(parts[5]),1); // LOADS ALL IMAGES IN THE ANIMATION
    }else{
      thumb_e = thumb_s;   // FASTER VERSION
    }

    thumbs = new PImage[thumb_e-thumb_s+1];
    String let = (i%2 == 0) ? "a" : "b";
    for(int t = 0; t < thumbs.length; t++){
      thumbs[t] = loadImage(let+"_images/img"+nf(t+thumb_s,4)+".png");
    }
  }
  void drawCard(boolean onBeat){
    float burstFactor = sin(frames/initial*PI/2);
    if(frames >= initial){
      burstFactor = 1;
    }
    pushMatrix();
    
    
    float[] locXs = new float[5];
    float[] locYs = new float[5];
    float[] locZs = new float[5];
    for(int lo = 0; lo < 5; lo++){
      if(lo == teamNum+1){
        locXs[lo] = teamX;
        locYs[lo] = teamY;
      }else{
        locXs[lo] = x;
        locYs[lo] = y;
      }
      if(lo%4 == 0 || lo == teamNum+1){
        locZs[lo] = 0;
      }else{
        locZs[lo] = 1;
      }
    }
    float t = getTeamIndexTime();
    float tileX = arrCosIndex(locXs,t,0.25);
    float tileY = arrCosIndex(locYs,t,0.25);
    float tileZ = arrCosIndex(locZs,t,0.25);
    float ti = (1-0.5*tileZ);
    tint(255*ti);
    
    float ax = 960+(xWob.getValue()+(tileX-1.5)*DX)*burstFactor;
    float ay = 534+(yWob.getValue()+(tileY-1.5)*DY)*burstFactor;
    float az = -800*tileZ;
    translate(ax,ay,az);
    float spins = spinWob.getValue();
    if(frames < initial){
      spins += initialSpins*(1-burstFactor);
    }
    rotateZ(rotationAxis+pitchWob.getValue());
    rotateX(spins);
    rotateZ(-rotationAxis);
    float W = 200;
    float H = 230;
    if(onBeat){
      fill(255,255,0);
    }else{
      fill(200*ti,210*ti,220*ti);
    }
    noStroke();
    rect(-W/2,-H/2,W,H);
    if(onBeat){
      fill(0);
    }else{
      fill(80*ti);
    }
    textFont(font,32);
    textAlign(CENTER,CENTER);
    pushMatrix();
    translate(0,0,0.1);
    println(name+",  "+textWidth(name.toUpperCase()));
    
    float textScale = min(1.0,180/textWidth(name.toUpperCase()));
    scale(textScale,1,1);
    /*if(name.equals("Tennis Ball")){
      scale(0.83,1,1);
    }
    if(name.equals("Golf Ball")){
      scale(0.94,1,1);
    }
    if(name.equals("Yellow Face")){
      scale(0.77,1,1);
    }*/
    text(name.toUpperCase(),0,85);
    int f = (int)min(max(frames-song_start_f+FRIES_START,thumb_s),thumb_e);
    noLights();
    image(thumbs[f-thumb_s],-85,-100,170,160);
    lights();
    popMatrix();
    popMatrix();
    noTint();
  }
  
  void drawLetter(int z){
    String BFDIA = "BFDIA7";
    float burstFactor = sin(frames/initial*PI/2);
    if(frames >= initial){
      burstFactor = 1;
    }
    pushMatrix();
    float ax = -200+365*burstFactor+xWob.getValue()*0.6;
    float ay = 537+168*(z-(BFDIA_len-1.0)/2.0)+xWob.getValue()*0.6;
    translate(ax,ay);
    rotateZ(rotationAxis+pitchWob.getValue());
    rotateX(spinWob.getValue());
    rotateZ(-rotationAxis);
    textFont(font,165);
    textAlign(CENTER,CENTER);
    pushMatrix();
    fill(255);
    text(BFDIA.substring(z,z+1),0,0);
    popMatrix();
    popMatrix();
  }
}
