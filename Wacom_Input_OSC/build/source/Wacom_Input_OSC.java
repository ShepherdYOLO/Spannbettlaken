import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import netP5.*; 
import oscP5.*; 
import codeanticode.tablet.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Wacom_Input_OSC extends PApplet {





PFont  roboto;

Tablet tablet;
PImage img;
PImage heatmap1, heatmap2, heatmap3, heatmap_clips, addmos_sine, heatmap4;
String mode = "wait";
OscP5 oscP5;
NetAddress myRemoteLocation;
NetAddress toAddmos;

OscMessage msg = new OscMessage("/Z");
OscMessage addmos = new OscMessage("/out");

float posX = 0;
float posY = 0;
float posZ = 0;
float tiltX = 0;
float tiltY = 0;


float easing = 0.01f;

int framerate = 35;

boolean wait = false;
boolean wait2 = false;

float inc = fromMStoIncr(300); //Inkrement zum Skalieren von posZ - je größer desto schneller



public void setup() {
  frameRate(framerate);
  //fullScreen();
  background(0);
  tablet = new Tablet(this);
  


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

public void draw() {
  clear();
  refreshInputs();
  drawFocus();

  //image(img, width/2, height/2 );

  toAddmos();
  Menu();
  showValues();
  Cursor();
  toAbleton();
  noStroke();
  noCursor();
}
public void showValues()
{
  //Zeigt Daten zum debuggen an

  fill(255);
  textSize(12);
  textAlign(LEFT);

  String s = new String("X: " + posX + "\nY: " + posY + "\nZ: " + posZ +
    "\nTilt X: " + tiltX + "\nTilt Y: " + tiltY +
    "\nHeight: " + tablet.getAltitude()) + "\nMode: " + mode;

    String s2 = new String("map 1 red: " + getPixel(heatmap1, "r") +
    "\nmap 1 green: " + getPixel(heatmap1, "g")  + "\nmap 1 blue: " +
    getPixel(heatmap1, "b" ) + "\nmap 2 blue: " + getPixel(heatmap2, "b") +
    "\nClip #: " + clipValdBug + "\nSW_Map: " + getPixel(addmos_sine, "r"));
  text(s, 10, height-125);
  text(s2, 150, height-125);
}



public void Cursor()
{
  //Zeichnet den Cursor
  fill(0xffFF8E03,map(posZ,0,1,150,170));
  stroke(0xff9D08A5,100);
  strokeWeight(2);
  circle(posX, posY, 7+3*(posZ));
}



public float getPixel(PImage image, String colr)
{
  //Liest das Bild mit der id "image" ein und gibt den Helligkeitswert des Channels "c" an der Position X, Y)

  float value = 0;
  int x = PApplet.parseInt(posX);
  int y = PApplet.parseInt(posY);
  image.loadPixels();
  loadPixels();
  int location = x + y*image.width;

  switch(colr) {
  case "r":
    value = red(image.pixels[location]);
    break;
  case "g":
    value = green(image.pixels[location]);
    break;
  case "b":
    value = blue(image.pixels[location]);
    break;
  }
  return map(value, 0, 255, 0, 1);
}



public void Menu()
{
  if (key == 't') {
    mode = "tablet";
  }
  if (key == 'm') {
    mode = "mouse";
  }
  if (key == 'w') {
    mode = "wait";
  }
  if (mode == "wait")
  {

    fill(0xff0F181F, 210);
    rect(0, 0, width, height);
    fill(0xffFCF9F0);
    textAlign(CENTER);
    textFont(roboto);
    textSize(30);
    String text;
    if((tablet.getPressure() > 0.5f) && (tablet.getPenKind()==3)){text = "du Nudel";}else{text = "to Spannbettlaken";}
    text("Welcome " + text + "!\n\nDo you want to use tablet mode [press t]\nOr mouse mode [press m]", width/2, height*0.3f);
  }
}



public void refreshInputs() {
  float lerpXY = 0.4f;
  float lerpZ = 0.3f;


  if (mode == "tablet")
  {
    posX = lerp(posX, tablet.getPenX(), lerpXY);
    posY = lerp(posY, tablet.getPenY(), lerpXY);
    posZ = constrain(lerp(posZ,tablet.getPressure(),lerpZ),0,1);
    tiltX = lerp(tiltX,constrain(map(tablet.getTiltX(),-1f,1f,0f,1f),0f,1f),0.3f);
    tiltY = lerp(tiltY,constrain(map(tablet.getTiltY(),-1f,1f,0f,1f),0f,1f),0.3f);
  }
  if (mode == "mouse")
  {
    posX = lerp(posX, mouseX, lerpXY);
    posY = lerp(posY, mouseY, lerpXY);
    if (mousePressed) {
      posZ += inc;
    } else {
      posZ -= inc/1.3f;
    }
    if (posZ >= 1) {
      posZ = 1;
    }
    if (posZ <= 0) {
      posZ = 0;
    }
  }
  if (mode == "wait")
  {
    posX = mouseX;
    posY = mouseY;
  }

}



public float fromMStoIncr(float ms)
{
  float fr = framerate;
  float incr = (1/fr)/ms*1000;
  return incr;
}



float savedClipVal,hold,clipValdBug;
boolean count = false;
int counter = 0;
int holdtime = 11;

FloatList smoothed = new FloatList();
int listSize = 10;

public void sendOSC(String Addr, float output, OscMessage message, NetAddress location)
{
  if(smoothed.size()<listSize)
  {
    smoothed.append(output);
  }else{
    smoothed.remove(0);
    smoothed.append(output);
  }

  float med = 0;
  for(int i = 0; i < smoothed.size(); i++)
  {
    med += smoothed.get(i);
  }

  med /= smoothed.size();

  message.setAddrPattern(Addr);
  message.add(med);
  oscP5.send(message,location);
  message.clear();
  println(med);
}


public void toAbleton()
{
  if(wait == true)
  {
    sendOSC("/Z",posZ,msg,myRemoteLocation);
    sendOSC("/freq",map(posZ,0f,1f,3f,10f),msg,myRemoteLocation);

    sendOSC("/Map1",getPixel(heatmap1, "r"),msg,myRemoteLocation);
    sendOSC("/Map2",getPixel(heatmap1, "g"),msg,myRemoteLocation);
    sendOSC("/Map3",getPixel(heatmap1, "b"),msg,myRemoteLocation);

    sendOSC("/Map7",getPixel(heatmap2, "r"),msg,myRemoteLocation);
    sendOSC("/Map8",getPixel(heatmap2, "g"),msg,myRemoteLocation);
    sendOSC("/Map9",getPixel(heatmap2, "b"),msg,myRemoteLocation);

    sendOSC("/Map4",getPixel(heatmap3, "r"),msg,myRemoteLocation);
    sendOSC("/Map5",getPixel(heatmap3, "g"),msg,myRemoteLocation);
    sendOSC("/Map6",getPixel(heatmap3, "b"),msg,myRemoteLocation);

    sendOSC("/Map10",getPixel(heatmap4, "r"),msg,myRemoteLocation);
    sendOSC("/Map11",getPixel(heatmap4, "g"),msg,myRemoteLocation);
    sendOSC("/Map12",getPixel(heatmap4, "b"),msg,myRemoteLocation);

    //sendOSC("/TiltX",tiltX,msg,myRemoteLocation);
    //sendOSC("/TiltY",tiltY,msg,myRemoteLocation);

    float ClipCount = 10;
    // Legt die Anzahl der Clips fest, die es zu Unterscheiden gilt, VORSICHT wenn schon Maps angelegt sind
    float clipVal = round(map(getPixel(heatmap_clips,"r"),0f,1f,0f,ClipCount));

    if (savedClipVal != clipVal)
    {
      count = true;
      hold = clipVal;
      counter = 0;
    }
    if(count)
    {
      counter ++;
    }
    if((counter == holdtime) && (hold == clipVal)/*&&(posZ > 0.5)*/)
    {
      //sendOSC("/Clips1",clipVal,msg,myRemoteLocation);
      clipValdBug=clipVal;
    }
    savedClipVal = clipVal;
  }
  wait = !wait;
}



public void toAddmos()
{
  //sendet alle Stiftdaten an Fritz seinen Synth auf Port 7099

  if(wait2)
  {
    sendOSC("/X",posX,addmos,toAddmos);
    sendOSC("/Y",posY,addmos,toAddmos);
    sendOSC("/Z",posZ,addmos,toAddmos);
    sendOSC("/PX",tiltX,addmos,toAddmos);
    sendOSC("/PY",tiltY,addmos,toAddmos);
    sendOSC("/dist",map(dist(posX,posY,0,0),0f,1335f,0f,1f),addmos,toAddmos);
    sendOSC("/Map1",getPixel(heatmap1, "r"),addmos,toAddmos);
    sendOSC("/Map2",getPixel(heatmap1, "g"),addmos,toAddmos);
    sendOSC("/Map3",getPixel(heatmap1, "b"),addmos,toAddmos);
    sendOSC("/SW_Map",getPixel(addmos_sine, "r"),addmos,toAddmos);
  }
  wait2 = !wait2;
}



public void drawFocus()
{
  loadPixels();
  img.loadPixels();
  for(int x = 0; x < img.width; x++){
    for(int y = 0; y < img.height; y++){
      int pos = x + y*img.width;

      float r = red    (img.pixels[pos]);
      float g = green  (img.pixels[pos]);
      float b = blue   (img.pixels[pos]);

      float dist = dist(x,y,posX,posY);
      float mult = map(dist, 0,map(posZ,0,1,800,500),map(posZ,0,1,1,1.1f),map(posZ,0,1,0.8f,0.4f));

      r*=mult;
      g*=mult;
      b*=mult;

      r=constrain(r,0,255);
      g=constrain(g,0,255);
      b=constrain(b,0,255);

      int c = color(r, g, b);
      pixels[pos] = c;
    }
  }
  updatePixels();
  }

public String dbug(String s)
{
  return s;
}



public void drawCircle()
{
  fill(255);
  noStroke();
  ellipse(width/2,height/2, 50, 50);
}
  public void settings() {  size(944, 944); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Wacom_Input_OSC" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
