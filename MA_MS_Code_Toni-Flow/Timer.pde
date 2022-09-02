class Timer {
  int intervalMillis;
  int lastTick = 0;
  
  Timer(int intervalMillis) {
    this.intervalMillis = intervalMillis;
  }
  
  boolean tick() {
    int millis = millis();
    if(millis - lastTick < intervalMillis) {
      return false;
    }
    lastTick = millis;
    return true;
  }
}
