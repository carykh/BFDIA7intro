class Wobble{
  float speed;
  float phase;
  float amount;
  public Wobble(float s, float a){
    speed = s;
    phase = random(0,2*PI);
    amount = a;
  }
  float getValue(){
    return amount*cos(frames/speed+phase);
  }
  float getValuePos(){
    return amount*(1+cos(frames/speed+phase))/2;
  }
}
