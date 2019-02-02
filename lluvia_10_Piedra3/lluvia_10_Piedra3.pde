//librerias //<>//
import controlP5.*;
import fisica.*;//importar libreria
import gab.opencv.*;
import gifAnimation.*;
//import processing.video.*;


OpenCV opencv;
FWorld mundo;// objeto del mundo de fisica

FPoly poliPiedra;// poligono de piedra

//declaracion de variables y elementos
PImage piedraImagen, dst; //piedra
ArrayList<Contour> contours; 
ArrayList<Contour> polygons;

ArrayList<Hombre> hombres;
int cantidadDeHombres;
float spawnFreq;

//PImage hombre; //png de hombre
//PImage hombredoblado;//png de hombre doblado
int selectedContour = 0;
float velocity= 0;

//Gif[] hombresGifs;

ControlP5 controlGui;
boolean debugMode;

void setup() {
  size(550, 900);
  frameRate(30);

  debugMode = false;
  piedraImagen = loadImage("piedra2_vertical_2.png");// sube imagenes de piedra

  opencv = new OpenCV(this, piedraImagen);//open cv sistema para detectar umbral de contraste
  opencv.gray();
  opencv.threshold(240);
  dst = opencv.getOutput();

  contours = opencv.findContours();
  println("found " + contours.size() + " contours");

  cantidadDeHombres = 150;
  hombres = new ArrayList<Hombre>();
  spawnFreq = 4;

  //hombre = loadImage( "hombre.png" );//llamo a las imagenes que van a llover
  //hombredoblado = loadImage( "hombredoblado.png" );

  /*
  hombresGifs = new Gif[3];
   for (int i=0; i < hombresGifs.length; i++) {
   hombresGifs[i] = new Gif(this, "hombre_" + i + ".gif");
   }
   */


  Fisica.init(this);//Metodo que inicia el mundo fisica
  mundo = new FWorld();//constructor
  mundo.setGravity(0, 500);//Metodo que setea la fuerza de gravedad del objeto
  mundo.setEdges(3, -200, width - 3, height + 3);

  //crearCuerpoDeLaPiedra(); // llamo a la funcion que arma el poligono de la piedra

  selectedContour = 26;
  try {
    crearCuerpoDeLaPiedra();
  } 
  catch (Exception e) {
    println("NO SE DETECTA UN CONTORNO VALIDO PARA LA PIEDRA");
  }

  createGUI();
}


void draw()
{
  background(0);

  imageMode(CORNER);
  image(piedraImagen, 0, 0); //dibuja la imagen de la piedra
  imageMode(CENTER);

  mundo.step(); // actualizo el objeto mundo
  //mundo.draw();//dibujo objeto mundo

  if (debugMode)mundo.drawDebug(); ///para ver el poligono y los parametros de las cajas


  noFill();
  strokeWeight(3);

  //CREAR a los hombres cayendo  (suponiendo que el framerate se mantiene en 30fps)
  if (frameCount % floor(spawnFreq * 30) == 0 && hombres.size() < cantidadDeHombres) {
    crearHombre();
  }


  for (int i=0; i < hombres.size (); i++) {
    FBody bodyLinkeado = buscarBodyPorNombre(Integer.toString(i));
    if (bodyLinkeado != null) { // SI ES null, SIGNIFICA Q ES UN Body SIN NOMBRE ASIGNADO, COMO LA PIEDRA O LAS PAREDES
      hombres.get(i).setPosition(bodyLinkeado.getX(), bodyLinkeado.getY());
      hombres.get(i).setRotation(bodyLinkeado.getRotation());
      hombres.get(i).dibujar();

      if (hombres.get(i).terminoTimer()) {
        hombres.get(i).reset();
        bodyLinkeado.setPosition( random( 0.1, width-0.1), 50 ); //ubicacion de salida
        bodyLinkeado.addTorque(random(-5, 5)); //le da rotacion
      }
    }
  }

  if (debugMode) {
    textSize(15);
    fill(0, 200);
    noStroke();
    rect(0, 0, width, 150);

    fill(255);
    text("CONTORNO DE SELECCIONADO:  " + selectedContour, 20, 90);
    text("FRAMERATE:     " + nf(frameRate, 0, 1), 20, 140);
    text("CANTIDAD DE HOMBRECITOS:     " + hombres.size() + "/" + cantidadDeHombres, 20, 120);


    //  Cuando cambio la imagen de la piedra, llamo funcion que detecta los contornos para ver si estoy sekleccionando el contorno correcto
    contourselection();

    // SHOW MOUSE COORDINATES
    fill(255, 0, 0);
    text("x" + mouseX + " | y"  + mouseY, mouseX + 2, mouseY - 2);
  }
}

void crearHombre() {

  // SE CREA UN UN OBJETO HOMBRE PARA CONTROLAR LA ANIMACION,
  // Y TAMBIEN SE CREA OBJETO FBox PARA CONTROLAR LOS FISICAS DEL HOMBRECITO
  // LOS 2 ESTAN VINCULADOS: bodyName = "0", hombre.get(0);

  Gif animationToPass = new Gif(this, "hombre_" + floor(random(2.99)) + ".gif");
  Hombre nuevoHombre = new Hombre(animationToPass);
  hombres.add(nuevoHombre);

  //creo un cuerpo circular
  FBox caja = new FBox( 30, 15 );
  //FCircle caja = new FCircle(20);
  caja.setName(Integer.toString(hombres.size() - 1));
  caja.setGrabbable(true);
  //caja.setVisible(false);

  caja.setPosition( random( 20, width-20), -100 ); //ubicacion de salida
  caja.addTorque(random(-20, 20)); //le da rotacion

  //agrego el cuerpo al mundo
  mundo.add(caja);

  //println("Nuevo Hombre: Fisica ID = " + caja.getName() + "  |  Animacion ID = " + (hombres.size() - 1));

  caja = null;
}

FBody buscarBodyPorNombre(String bodyName) {
  ArrayList<FBody> bodies=mundo.getBodies();
  for (FBody b : bodies) {
    //println("Busqueda de BodyName: " + b.getName() + " --- X=" + b.getX() + " | Y=" + b.getY());
    try {
      if (b.getName().equals(bodyName)) {
        return b;
      }
    }
    catch(NullPointerException e) {
      //println("No se encontro ningun Body de nombre: " + bodyName);
    }
  }

  return null;
}

//Funcion que detecta los contactos entre dos objetos o entre la piedra y algun objeto
void contactStarted(FContact contacto) { //se ejecuta cuando hay contacto

    // FOR BODY 1
  try {
    hombres.get(Integer.parseInt(contacto.getBody1().getName())).abolitarse();
  } 
  catch (Exception e) {
    //println("NO ES UN OBJETO Hombre");
  }

  // FOR BODY 2
  try {
    hombres.get(Integer.parseInt(contacto.getBody2().getName())).abolitarse();
  } 
  catch (Exception e) {
    //println("NO ES UN OBJETO Hombre");
  }

  /* PARA QUE SOLO SE HAGA BOLITA CUANDO REBOTA CON LA PIEDRA
   if (contacto.contains (poliPiedra )) {
   if ( contacto.getBody1() == poliPiedra) {
   hombres.get(Integer.parseInt(contacto.getBody2().getName())).abolitarse();
   } else {
   hombres.get(Integer.parseInt(contacto.getBody1().getName())).abolitarse();
   }
   }
   */
}

//sistema para detectar los contornos y dibujar el PolygonApproximation

void contourselection () { //declaro funcion

    stroke(255, 0, 0);
  fill(255, 0, 0, 50);
  contours.get(selectedContour).draw();


  PVector punto1 = contours.get(selectedContour).getPolygonApproximation().getPoints().get(0);
  noStroke();
  fill(0);
  rect(punto1.x + 5, punto1.y + 8, 100, -20);
  fill(0, 255, 127);
  text("Contorno ->  " + selectedContour, punto1.x + 7, punto1.y);

  stroke(255, 0, 0);
  beginShape();
  for (PVector point : contours.get (selectedContour).getPolygonApproximation().getPoints()) {
    vertex(point.x, point.y);
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////

void crearCuerpoDeLaPiedra() {

  // Primero, eliminar la piedra anterior
  /*
  ArrayList<FBody> bodies=mundo.getBodies();
   for (FBody b : bodies) {
   if (b.getName().equals("piedra")) {
   b.removeFromWorld();
   }
   }
   */

  poliPiedra = new FPoly(); //tipo FPoly
  poliPiedra.setNoFill();
  //poliPiedra.setStroke(0, 0, 255);
  poliPiedra.setNoStroke();
  poliPiedra.setName("piedra");

  Contour contornoPiedra = contours.get(selectedContour); //numero del contorno que sale del debug
  int cantidadDePuntos = contornoPiedra.getPolygonApproximation().getPoints().size();

  for (int i=0; i < cantidadDePuntos; i++ ) {
    PVector puntoActual = contornoPiedra.getPolygonApproximation().getPoints().get(i);
    poliPiedra.vertex(puntoActual.x, puntoActual.y);
  }

  poliPiedra.setStatic(true);

  mundo.add(poliPiedra);
  // poliPiedra = null; // POR QUE LO ELIMINA? ACASO HACE UNA COPIA AL AGREGARLO AL WORLD
}

void createGUI() {
  controlGui = new ControlP5(this);

  controlGui.addButton("gui_previousContour").setPosition(50, 20).setSize(20, 20).setLabel("<");
  controlGui.addButton("gui_nextContour").setPosition(90, 20).setSize(20, 20).setLabel(">");
  controlGui.addButton("gui_setAsRockContour").setPosition(20, 50).setSize(120, 20).setLabel("Setear Cuerpo de Roca");

  controlGui.addSlider("gui_spawnFrequency").setPosition(180, 20).setSize(100, 20).setRange(1, 15).setValue(4).setNumberOfTickMarks(15).showTickMarks(false).setLabel("Frecuencia de Creacion");
  controlGui.addSlider("gui_reSpawnTime").setPosition(180, 50).setSize(100, 20).setRange(10, 120).setValue(120).setNumberOfTickMarks(111).showTickMarks(false).setLabel("Tiempo de Vida");

  //controlGui.addButton("gui_reStart").setPosition(600, 100).setSize(20, 50).setLabel("LIMPIAR");

  controlGui.hide();
}

void gui_previousContour() {
  selectedContour--;
  if (selectedContour < 0) {
    selectedContour = contours.size() - 1;
  }
}
void gui_nextContour() {
  selectedContour++;
  if (selectedContour >= contours.size()) {
    selectedContour = 0;
  }
}

void gui_setAsRockContour() {
  crearCuerpoDeLaPiedra();
}

void gui_spawnFrequency(float value) {
  spawnFreq = value;
}

void gui_reSpawnTime(float value) {
  for (int i=0; i< hombres.size (); i++) {
    hombres.get(i).setTimerDurationInSeconds(floor(value));
  }
}

void gui_reStart() {
  hombres.clear();
  // FALTA LIMPIAR LOS FBodies
}



/////////////////////////////////////////////////////////////////////

void keyPressed() {
  //Elementos para recorrer el contorno y elegirlo con LEFT y RIGHT
  if (keyCode == RIGHT) {
    selectedContour++;
    if (selectedContour >= contours.size()) {
      selectedContour = 0;
    }
    println(selectedContour);
  }

  if (keyCode == LEFT) {
    selectedContour--;
    if (selectedContour < 0) {
      selectedContour = contours.size() - 1;
    }    
    println(selectedContour);
  }

  if (key == 'd' || key == 'D') {
    debugMode = !debugMode;
    if (debugMode) {
      controlGui.show();
      cursor();
    } else {
      controlGui.hide();
      noCursor();
    }
  }

  if (key == 'c' || key == 'C') {
    crearHombre();
  }
}


/////////////////////////////////////////////////////////////////////
