/**
 * Simple Write. 
 * 
 * Check if the mouse is over a rectangle and writes the status to the serial port. 
 * This example works with the Wiring / Arduino program that follows below.
 */
import processing.serial.*;
import java.awt.datatransfer.*;
import java.awt.Toolkit;
import processing.opengl.*;
import saito.objloader.*;
import g4p_controls.*;

float roll  = 0.0F;
float pitch = 0.0F;
float yaw   = 0.0F;
float temp  = 0.0F;
float alt   = 0.0F;

OBJModel model;

Serial myPort;  // Create object from Serial class
int val;        // Data received from the serial port
// Serial port state.
Serial       port;
String       buffer = "";
void setup() 
{
  size(400, 400, OPENGL);
   frameRate(30);
  model = new OBJModel(this);
  model.load("bunny.obj");
  model.scale(20);
  // I know that the first port in the serial list on my mac
  // is always my  FTDI adaptor, so I open Serial.list()[0].
  // On Windows machines, this generally opens COM1.
  // Open whatever port is the one you're using.
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 38400);
}

void draw() {
  background(255);
  // Set a new co-ordinate space
//  pushMatrix();
//
//  // Simple 3 point lighting for dramatic effect.
//  // Slightly red light in upper right, slightly blue light in upper left, and white light from behind.
//  pointLight(255, 200, 200,  400, 400,  500);
//  pointLight(200, 200, 255, -400, 400,  500);
//  pointLight(255, 255, 255,    0,   0, -500);
//  
//  // Displace objects from 0,0
//  translate(200, 350, 0);
  
  // Rotate shapes around the X/Y/Z axis (values in radians, 0..Pi*2)
//  rotateX(radians(roll));
//  rotateZ(radians(pitch));
//  rotateY(radians(yaw));

//  pushMatrix();
//  noStroke();
//  model.draw();
//  popMatrix();
//  popMatrix();
  if (mouseOverRect_1() == true) {  // If mouse is over square,
    fill(204, 102, 0);                   // change color and
 for(int i = 10; i < width; i += 1) {
  // If 'i' divides by 20 with no remainder draw the first line
  // else draw the second line
  if(i%80 == 0) {
   myPort.write('M');
  } else {
    myPort.write('N');    
    myPort.write("L");
    myPort.write("B");      // send an H to indicate mouse is over square
    
  }
}
  delay(5);
  rect(50, 50, 100, 100);         // Draw a square    
  } 
  
  if (mouseOverRect_2() == true) {  // If mouse is over square,
    fill(104, 102, 70);                   // change color and
for(int i = 10; i < width; i += 1) {
  // If 'i' divides by 20 with no remainder draw the first line
  // else draw the second line
  if(i%100 == 0) {
   myPort.write('F');
  }
 } 
    myPort.write('E');      
    myPort.write("A");      // send an H to indicate mouse is over square
    delay(6); 
    rect(150, 50, 100, 100);         // Draw a square
 } 
  
  if (mouseOverRect_3() == true) {  // If mouse is over square,
    fill(104, 102, 110);                 // change color and
    //myPort.write('F');              // send an H to indicate mouse is over square
    myPort.write('F');
    rect(50, 150, 100, 100);         // Draw a square
  } 
  
  if (mouseOverRect_4() == true) {  // If mouse is over square,
    fill(20, 102, 100);                    // change color and
    myPort.write('M');              // send an L otherwise
    rect(150, 150, 100, 100);         // Draw a square
  }
  //rect(50, 50, 300, 300);         // Draw a square
  
}
void keyPressed() {
  int keyIndex = -1;
 if (key >= 'A' && key <= 'Z') {
    port.write('N');
    port.write('M');
    port.write('L'); 
    port.write("B"); 
  } else if (key >= 'a' && key <= 'z') {
    port.write("E"); // B
    //port.write("F"); // B
    port.write("A"); 
  }
}
void serialEvent(Serial p) 
{
  String incoming = p.readString();
   {
    print(incoming);
  }
  
  if ((incoming.length() > 8))
  {
    String[] list = split(incoming, " ");
    if ( (list.length > 0) && (list[0].equals("Orientation:")) ) 
    {
      roll  = float(list[1]);
      pitch = float(list[2]);
      yaw   = float(list[3]);
      buffer = incoming;
    }
    if ( (list.length > 0) && (list[0].equals("Alt:")) ) 
    {
      alt  = float(list[1]);
      buffer = incoming;
    }
    if ( (list.length > 0) && (list[0].equals("Temp:")) ) 
    {
      temp  = float(list[1]);
      buffer = incoming;
    }
  }
}
  
boolean mouseOverRect_1() { // Test if mouse is over square
  return ((mouseX >= 50) && (mouseX <= 150) && (mouseY >= 50) && (mouseY <= 150));
}

boolean mouseOverRect_2() { // Test if mouse is over square
  return ((mouseX >= 150) && (mouseX <= 250) && (mouseY >= 50) && (mouseY <= 150));
}

boolean mouseOverRect_3() { // Test if mouse is over square
  return ((mouseX >= 50) && (mouseX <= 150) && (mouseY >= 150) && (mouseY <= 250));
}

boolean mouseOverRect_4() { // Test if mouse is over square
  return ((mouseX >= 150) && (mouseX <= 250) && (mouseY >= 150) && (mouseY <= 250));
}


/*
  // Wiring/Arduino code:
 // Read data from the serial and turn ON or OFF a light depending on the value
 
 char val; // Data received from the serial port
 int ledPin = 4; // Set the pin to digital I/O 4
 
 void setup() {
 pinMode(ledPin, OUTPUT); // Set pin as OUTPUT
 Serial.begin(9600); // Start serial communication at 9600 bps
 }
 
 void loop() {
 if (Serial.available()) { // If data is available to read,
 val = Serial.read(); // read it and store it in val
 }
 if (val == 'H') { // If H was received
 digitalWrite(ledPin, HIGH); // turn the LED on
 } else {
 digitalWrite(ledPin, LOW); // Otherwise turn it OFF
 }
 delay(100); // Wait 100 milliseconds for next reading
 }
 
 */
