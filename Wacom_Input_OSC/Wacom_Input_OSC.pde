import netP5.*;
import oscP5.*;
import codeanticode.tablet.*;

PFont  roboto;

Tablet tablet;
PImage img;
PImage heatmap1, heatmap2, heatmap3, heatmap_clips, addmos_sine, heatmap4;
String mode = "wait";
OscP5 oscP5 = new OscP5(this,8000);
NetAddress myRemoteLocation;
NetAddress toAddmos;

OscMessage msg = new OscMessage("/Z");
OscMessage addmos = new OscMessage("/out");

float posX = 0;
float posY = 0;
float posZ = 0;
float tiltX = 0;
float tiltY = 0;

float easing = 0.01;

int framerate = 60;

int wait = 0;
int waitmax = 2;
boolean wait2 = false;

float inc = fromMStoIncr(300); //Inkrement zum Skalieren von posZ - je größer desto schneller



void setup() {
  frameRate(framerate);
  //fullScreen();
  background(0);
  tablet = new Tablet(this);
  size(944, 944);


  oscP5 = new OscP5(this, 8000);
  myRemoteLocation = new NetAddress("127.0.0.1", 32000);
  toAddmos = new NetAddress("127.0.0.1", 7099);

  heatmap1 = loadImage("heatmap1.png");
  heatmap2 = loadImage("heatmap2.png");
  heatmap3 = loadImage("heatmap3.png");
  heatmap4 = loadImage("heatmap4.png");
  heatmap_clips = loadImage("heatmap_clips.png");
  addmos_sine = loadImage("Addmos_Sinussound.jpg");
  img = loadImage("Schwarze_Zumalung.png");
  imageMode(CENTER);

  roboto = createFont("RobotoCondensed-Light.ttf",50);


}

OSClass Z = new OSClass(myRemoteLocation,"/Z");
OSClass Map1 = new OSClass(myRemoteLocation,"/Map1");

void draw() {
  clear();
  refreshInputs();
  drawFocus();

  //image(img, width/2, height/2 );
  Z.send(posZ);
  Map1.send(getPixel(heatmap1, "r"));
  toAddmos();
  Menu();
  showValues();
  Cursor();
  //toAbleton();
  noStroke();
  noCursor();
}
