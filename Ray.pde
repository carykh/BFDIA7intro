class Ray{
  float ang;
  float wid;
  Wobble brightness;
  public Ray(){
    ang = random(0,2*PI);
    wid = random(0.05,0.12);
    brightness = new Wobble(random(5,10),random(0,150));
  }
}
