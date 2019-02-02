class Hombre {

  PVector position;
  float rotation;
  Gif animacion;

  boolean yaColisionoConRoca;

  Timer timer;

  Hombre(Gif _animacion) {

    position = new PVector(0, -100);
    rotation = 0;

    animacion = _animacion;

    animacion.pause();
    animacion.noLoop();
    animacion.ignoreRepeat();

    timer = new Timer();
    setTimerDurationInSeconds(120);

    reset();
  }

  void dibujar() {    
    pushMatrix();

    translate(position.x, position.y);
    rotate(rotation);
    image(animacion, 0, 0);

    popMatrix();
  }

  void setPosition(float _x, float _y) {
    position.set(_x, _y);
  }

  void setRotation(float _rot) {
    rotation = _rot;
  }

  void abolitarse() {
    if (!yaColisionoConRoca) {
      animacion.play();
      yaColisionoConRoca = true;
    }
  }

  void reset() {
    animacion.jump(0);
    animacion.pause();
    yaColisionoConRoca = false;

    timer.start();
  }

  boolean terminoTimer() {
    return timer.isFinished();
  }
  
  void setTimerDurationInSeconds(int seconds){
    timer.setDurationInSeconds(seconds + (int(random(-20,20))));
  }
}
