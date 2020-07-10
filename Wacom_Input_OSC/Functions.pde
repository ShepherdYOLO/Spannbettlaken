void showValues()
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



void Cursor()
{
  //Zeichnet den Cursor
  fill(#FF8E03,map(posZ,0,1,150,170));
  stroke(#9D08A5,100);
  strokeWeight(2);
  circle(posX, posY, 7+3*(posZ));
}



float getPixel(PImage image, String colr)
{
  //Liest das Bild mit der id "image" ein und gibt den Helligkeitswert des Farbkanal "c" an der Position X, Y)

  float value = 0;
  int x = int(posX);
  int y = int(posY);
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



void Menu()
{
  //Zeichnet zu Beginn das Menü zum auswählen der Modi

  if (key == 't') {
    mode = "tablet";
  }
  if (key == 'm') {
    mode = "mouse";
  }
  if (key == 'w') {
    mode = "wait";
  }
  if (key == 'i') {
    println("und los Lenchen!");
  }
  if (mode == "wait")
  {
    fill(#0F181F, 210);
    rect(0, 0, width, height);
    fill(#FCF9F0);
    textAlign(CENTER);
    textFont(roboto);
    textSize(35);
    String text;
    if((tablet.getPressure() > 0.5) && (tablet.getPenKind()==3)){text = "du Nudel";}else{text = "to Spannbettlaken";}
    text("Welcome " + text , width/2, height*0.4);
    textSize(25);
    text("tablet mode [press t]\nmouse mode [press m]\n\ninformation [press i]", width/2, height*0.5);
  }
}

void refreshInputs() {
  //Aktualisiert die Eingabedaten. Hier wird auch der Maus- bzw. Tabletmodus umgesetzt
  //Außerdem findet hier auch ein erstes Lerpen statt um den Cursor träger zu machen
  float lerpXY = 0.4;
  float lerpZ = 0.3;


  if (mode == "tablet")
  {
    posX = lerp(posX, tablet.getPenX(), lerpXY);
    posY = lerp(posY, tablet.getPenY(), lerpXY);
    posZ = constrain(lerp(posZ,tablet.getPressure(),lerpZ),0,1);
    tiltX = lerp(tiltX,constrain(map(tablet.getTiltX(),-1f,1f,0f,1f),0f,1f),0.3);
    tiltY = lerp(tiltY,constrain(map(tablet.getTiltY(),-1f,1f,0f,1f),0f,1f),0.3);
  }
  if (mode == "mouse")
  {
    posX = lerp(posX, mouseX, lerpXY);
    posY = lerp(posY, mouseY, lerpXY);
    if (mousePressed) {
      posZ += inc;
    } else {
      posZ -= inc/1.3;
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



float fromMStoIncr(float ms)
{
  float fr = framerate;
  float incr = (1/fr)/ms*1000;
  return incr;
}



float savedClipVal,hold,clipValdBug;
boolean count = false;
int counter = 0;
int holdtime = 11;



void sendOSC(String Addr, float output, OscMessage message, NetAddress location)
{
  //Funktion zum übermitteln von OSC

  if(/*output !=0*/true)
  {
    message.setAddrPattern(Addr);
    message.add(output);
    oscP5.send(message,location);
    message.clear();
  }

}


void toAbleton()
{
  //Sammelt alle OSC Nachrichten, um diese nach Ableton zu schicken

  if(wait == waitmax || true)
  {
    Z.send(posZ);
    Y.send(map(posY,0,height,0,1));

    Map1.send(getPixel(heatmap1, "r"));
    Map2.send(getPixel(heatmap1, "g"));
    Map3.send(getPixel(heatmap1, "b"));

    Map7.send(getPixel(heatmap2, "r"));
    Map8.send(getPixel(heatmap2, "g"));
    Map9.send(getPixel(heatmap2, "b"));

    Map4.send(getPixel(heatmap3, "r"));
    Map5.send(getPixel(heatmap3, "g"));
    Map6.send(getPixel(heatmap3, "b"));

    Map10.send(getPixel(heatmap4, "r"));
    Map11.send(getPixel(heatmap4, "g"));
    Map12.send(getPixel(heatmap4, "b"));

    Map13.send(getPixel(heatmap5, "r"));
    Map14.send(getPixel(heatmap5, "g"));
    Map15.send(getPixel(heatmap5, "b"));

    Map16.send(getPixel(heatmap6, "r"));
    Map17.send(getPixel(heatmap6, "g"));
    Map18.send(getPixel(heatmap6, "b"));



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
  wait++;
  if(wait > waitmax)
  {
    wait = 0;
  }
}



void toAddmos()
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



void drawFocus()
{
  //berechnet den "Taschenlampen"-Effekt

  loadPixels();
  img.loadPixels();
  for(int x = 0; x < img.width; x++){
    for(int y = 0; y < img.height; y++){
      int pos = x + y*img.width;

      float r = red    (img.pixels[pos]);
      float g = green  (img.pixels[pos]);
      float b = blue   (img.pixels[pos]);

      float dist = dist(x,y,posX,posY);
      float mult = map(dist, 0,map(posZ,0,1,800,500),map(posZ,0,1,1,1.1),map(posZ,0,1,0.8,0.4));

      r*=mult;
      g*=mult;
      b*=mult;

      r=constrain(r,0,255);
      g=constrain(g,0,255);
      b=constrain(b,0,255);

      color c = color(r, g, b);
      pixels[pos] = c;
    }
  }
  updatePixels();
  }

String dbug(String s)
{
  return s;
}


////////////////////////// Class //////////////////////////////////


class OSClass{

private FloatList buffer = new FloatList();
private int buffersize = 5;
private String Addr;
private OscMessage message = new OscMessage("/default");
private boolean isChanged = true;
private float out;

OSClass(NetAddress loc, String Adr)
{
  //Konstruktor

  Addr = Adr;
  //location = loc;
}

private void checkIfChanged()
{
  //Überprüft, ob die Daten aus dem Buffer sich ändern oder nicht

  if(buffer.max()==buffer.min())
  {
    isChanged = false;
  }else{

    isChanged = true;
  }
}


private void writeBuffer()
{
  //Beschreibt den Buffer mit den Input-Daten

  if(buffer.size()!=buffersize)
  {
    buffer.append(out);
  }else{
    buffer.remove(0);
    buffer.append(out);
  }
}

public void send(float value)
{
  //Sendet die OSC Daten aus der Klasse

  out = value;
  writeBuffer();

  checkIfChanged();

  if(isChanged)
  {
    println(Addr + " | " + buffer);
    message.setAddrPattern(Addr);
    message.add(out);
    OscP5.flush(message,myRemoteLocation);
    message.clear();
  }

}


public void setBuffersize(int size)
{
  //Setter-Funktion zum festlegen der Buffersize von Außen

  buffersize = size;
}

}
