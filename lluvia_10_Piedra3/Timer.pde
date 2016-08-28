public class Timer {

  int savedTime;
  int totalTime;
  int currentTime;

  Timer() {
    totalTime = 5000 ; // PREDETERMINADO
  }

  public void setDuration(int _duration) {
    totalTime = _duration;
  }

  public void setDurationInSeconds(int _durationInSeconds) {
    totalTime = _durationInSeconds * 1000;
  }

  public void start() {
    savedTime = millis();
  }

  public boolean isFinished() {
    currentTime = millis() - savedTime;
    if (currentTime > totalTime) {
      return true;
    } else {
      return false;
    }
  }

  public int getTotalTime() {
    return totalTime;
  }
  
  public int getTotalTimeInSeconds() {
    return int(totalTime / 1000);
  }
  
  public int getCurrentTime() {
    return currentTime;
  }
  public int getCurrentTimeInSeconds() {
    return int(currentTime / 1000);
  }
}
