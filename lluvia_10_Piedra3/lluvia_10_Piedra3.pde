//librerias
import fisica.*;//importar libreria
import gab.opencv.*;
import gifAnimation.*;
//import processing.video.*;


OpenCV opencv;
FWorld mundo;// objeto del mundo de fisica

FPoly poliPiedra;// poligono de piedra

//declaracion de variables y elementos
int cantidad=5;// cantidad de objetos que caen
PImage src, dst; //piedra
ArrayList<Contour> contours; 
ArrayList<Contour> polygons;

ArrayList<Hombre> hombres;
int cantidadDeHombres;

PImage hombre; //png de hombre
PImage hombredoblado;//png de hombre doblado
int selectedContour = 0;
float velocity= 0;

void setup()
{
  size(500, 800);


  src = loadImage("piedra2.jpg");// sube imagenes de piedra

  opencv = new OpenCV(this, src);//open cv sistema para detectar umbral de contraste
  opencv.gray();
  opencv.threshold(240);
  dst = opencv.getOutput();

  contours = opencv.findContours();
  println("found " + contours.size() + " contours");

  cantidadDeHombres = 300;
  hombres = new ArrayList<Hombre>();

  hombre = loadImage( "hombre.png" );//llamo a las imagenes que van a llover
  hombredoblado = loadImage( "hombredoblado.png" );


  Fisica.init(this);//Metodo que inicia el mundo fisica
  mundo = new FWorld();//constructor
  mundo.setGravity(0, 500);//Metodo que setea la fuerza de gravedad del objeto
  mundo.setEdges(3);

  crearCuerpoDeLaPiedra(); // llamo a la funcion que arma el poligono de la piedra

    noFill();
  stroke(255, 128, 0);
}


void draw()
{
  background(0);

  imageMode(CORNER);
  image(src, 0, 0); //dibuja la imagen de la piedra
  imageMode(CENTER);

  mundo.step(); // actualizo el objeto mundo
  //mundo.draw();//dibujo objeto mundo
  //mundo.drawDebug(); ///para ver el poligono y los parametros de las cajas


  noFill();
  strokeWeight(3);

  //dibuja a los hombres cayendo 
  if (frameCount % 60 == 0 && hombres.size() < cantidadDeHombres) {
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
  //Cuando cambio la imagen de la piedra, llamo funcion que detecta los contornos para ver si estoy sekleccionando el contorno correcto
  //contourselection ();
  
  fill(255,0,0);
  text("FrameRate: " + frameRate, 10,10);
  text("Cantidad de Hombrecitos: " + hombres.size(), 10, 30);
}

void crearHombre() {

  // SE CREA UN UN OBJETO HOMBRE PARA CONTROLAR LA ANIMACION,
  // Y TAMBIEN SE CREA OBJETO FBox PARA CONTROLAR LOS FISICAS DEL HOMBRECITO
  // LOS 2 ESTAN VINCULADOS: bodyName = "0", hombre.get(0);


  Gif nuevoGif = new Gif(this, "hombre.gif");
  Hombre nuevoHombre = new Hombre(nuevoGif);
  hombres.add(nuevoHombre);

  //creo un cuerpo circular
  //FBox caja = new FBox( hombre.width * 0.25, hombre.height * 0.50 );
  FCircle caja = new FCircle(15);
  caja.setName(Integer.toString(hombres.size() - 1));
  caja.setGrabbable(true);
  //caja.setVisible(false);

  caja.setPosition( random( 0.1, width-0.1), 50 ); //ubicacion de salida
  caja.addTorque(random(-5, 5)); //le da rotacion

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

    stroke(0, 255, 0);
  contours.get(selectedContour).draw();

  noStroke();
  fill(0, 255, 127);
  PVector punto1 = contours.get(selectedContour).getPolygonApproximation().getPoints().get(0);
  text("Contorno :: " + selectedContour, punto1.x, punto1.y);

  stroke(255, 0, 0);
  beginShape();
  for (PVector point : contours.get (selectedContour).getPolygonApproximation().getPoints()) {
    vertex(point.x, point.y);
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////

void crearCuerpoDeLaPiedra() {//funcion que dibuja un poligono en la piedra

    poliPiedra = new FPoly(); //tipo FPoly
  poliPiedra.setNoFill();
  //poliPiedra.setStroke(0, 0, 255);
  poliPiedra.setNoStroke();

  Contour contornoPiedra = contours.get(54); //numero del contorno que sale del debug
  int cantidadDePuntos = contornoPiedra.getPolygonApproximation().getPoints().size();

  for (int i=0; i < cantidadDePuntos; i++ ) {
    PVector puntoActual = contornoPiedra.getPolygonApproximation().getPoints().get(i);
    poliPiedra.vertex(puntoActual.x, puntoActual.y);
  }

  poliPiedra.setStatic(true);

  mundo.add(poliPiedra);
  // poliPiedra = null; // POR QUE LO ELIMINA? ACASO HACE UNA COPIA AL AGREGARLO AL WORLD
}



/////////////////////////////////////////////////////////////////////

void keyPressed() {
  //Elementos para recorrer el contorno y elegirlo con LEFT y RIGHT
  if (keyCode == RIGHT) {
    selectedContour = abs((selectedContour + 1) % contours.size());
    println(selectedContour);
  }

  if (keyCode == LEFT) {
    selectedContour = abs((selectedContour - 1) % contours.size());
    println(selectedContour);
  }
}


/////////////////////////////////////////////////////////////////////
