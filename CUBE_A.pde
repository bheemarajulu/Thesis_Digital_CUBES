****************************************************************/
#include <SoftwareSerial.h>
#include <Wire.h>
#include <SparkFun_APDS9960.h>
#include "Adafruit_TCS34725.h"
byte gammatable[256];

Adafruit_TCS34725 tcs = Adafruit_TCS34725(TCS34725_INTEGRATIONTIME_50MS, TCS34725_GAIN_4X);

SoftwareSerial mySerial(10, 9); // RX, TX

// Pins
#define APDS9960_INT    3 // Needs to be an interrupt pin

// Constants

// Global Variables
SparkFun_APDS9960 apds = SparkFun_APDS9960();
int isr_flag = 0;
#define debounce 20 // ms debounce period 
#define holdTime 250 // ms hold time to know the button release time dealy
// Constants
 
// this constant won't change:
const int  buttonPin_red = 4;    // the pin that the pushbutton is attached to
const int  buttonPin_green_rst = 5;    // the pin that the pushbutton is attached to
const int  buttonPin_green_usb = 6;    // the pin that the pushbutton is attached to
const int  buttonPin_yellow = 8;    // the pin that the pushbutton is attached to
int buttonPushCounter = 0;   // counter for the number of button presses


void setup() {

 // Open serial communications and wait for port to open:
  Serial.begin(57600);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for native USB port only
  }
  // Set interrupt pin as input
  pinMode(APDS9960_INT, INPUT);
  pinMode(4, INPUT_PULLUP); // Buttons 
  pinMode(5, INPUT_PULLUP);
  pinMode(6, INPUT_PULLUP);
  pinMode(8, INPUT_PULLUP);
  mySerial.begin(57600);
  mySerial.println("Hello, world?");

  // Initialize APDS-9960 (configure I2C and initial values)
  if ( apds.init() ) {
    mySerial.println(F("APDS-9960 initialization complete"));
  } else {
    mySerial.println(F("Something went wrong during APDS-9960 init!"));
  }
  
  // Start running the APDS-9960 gesture sensor engine
  if ( apds.enableGestureSensor(true) ) {
    mySerial.println(F("Gesture sensor is now running"));
  } else {
    mySerial.println(F("Something went wrong during gesture sensor init!"));
  }
  
  mySerial.println("Color View Test!");
  mySerial.println("Buttons Test!");

  if (tcs.begin()) {
    mySerial.println("Found sensor");
  } else {
    mySerial.println("No TCS34725 found ... check your connections");
    while (1); // halt!
  }
}

void loop() {
gesture();
color_view();
buttons();
}

int color_view()
{
  uint16_t clear, red, green, blue;
  tcs.setInterrupt(false);      // turn on LED
  delay(60);  // takes 50ms to read   
  tcs.getRawData(&red, &green, &blue, &clear); 
  tcs.setInterrupt(true);  // turn off LED
  // Figure out some basic hex code for visualization
  uint32_t sum = clear;
  float r, g, b; 
  float Int;
  //float H1,S1,I1;
  r = red;  
  g = green; 
  b = blue; 
  Int = (r+g+b)/3; // Intensity calculated
  //Serial.print("\tInt:\t");Serial.print(Int);

  r = red; 
  r /= sum-Int; // Normalized Red
  g = green; 
  g /= sum-Int; // Normalized Green
  b = blue; 
  b /= sum-Int; // Normalized Blue
  float rbar,gbar,bbar,K,K1,C,M,Y; //RGB to CMYK conversion formula
  rbar = r;
  gbar = g;
  bbar = b;
  //max(r-b, g-b) K = 1-max(R', G', B')
  K1 = max(rbar, gbar); // The black key (K) color is calculated from the red (R'), green (G') and blue (B') colors:
  K = (1- max(K1, bbar)); // The black key (K) color is calculated from the red (R'), green (G') and blue (B') colors:
  C = (1-rbar-K)/(1-K); // The cyan color (C) is calculated from the red (R') and black (K) colors:
  M = (1-gbar-K)/(1-K); // The magenta color (M) is calculated from the green (G') and black (K) colors:
  Y = (1-bbar-K)/(1-K); // The yellow color (Y) is calculated from the blue (B') and black (K) colors:
  float remove1, normalize_2, s1,s2,s3,s4;
  if ((C < M) && (C < Y) && (C < K)) {
    remove1 = C;
    normalize_2 = max(M-C, Y-C);
    //normalize_2 = max(s1,K-C);
  } 
  else if ((M < C) && (M < Y) && (M < K)) {
    remove1 = M;
    normalize_2 = max(C-M, Y-M);
    //normalize_2 = max(s2,K-M);
  } 
  else if ((Y < C) && (Y < M) && (Y < K)) {
    remove1 = Y;
    normalize_2 = max(C-Y, M-Y);
    //normalize_2 = max(s3,K-Y);
  } 
 else if ((K < C) && (K < M) && (K < Y)) {
    remove1 = K;
    normalize_2 = max(C-K, M-K);
    //normalize_2 = max(s4,Y-C);
  } 
  // get rid of minority report
  float cyannorm = C - remove1;// - (g-b);
  float magnetanorm = M - remove1;// - (r-b);
  float yellownorm = Y - remove1;// - (r-g);
  float blacknorm = K - remove1;// - (Y+C+M);
  // now normalize for the highest number
  cyannorm /= normalize_2;
  magnetanorm /= normalize_2;
  yellownorm /= normalize_2;
  blacknorm /= normalize_2;
   // normalize the rgb color
  float remove, normalize;
  if ((b < g) && (b < r)) {
    remove = b;
    normalize = max(r-b, g-b);
  } 
  else if ((g < b) && (g < r)) {
    remove = g;
    normalize = max(r-g, b-g);
  } 
  else {
    remove = r;
    normalize = max(b-r, g-r);
  }
  // get rid of minority report
  float rednorm = r - remove;
  float greennorm = g - remove;
  float bluenorm = b - remove;
  // now normalize for the highest number
  rednorm /= normalize;
  greennorm /= normalize;
  bluenorm /= normalize;

  
  int R = (r * 255);
  int G = (g * 255);
  int B = (b * 255);
    if (R > 255) R = 255;
    if (G > 255) G = 255;
    if (B > 255) B = 255;
    
    if (rednorm <= 0.1 && bluenorm <=0.10) {
       if (greennorm >= 0.99)  {
      // between green 
       mySerial.println("Green");
       } 
     }
  
 if (bluenorm <= 0.1) {
    if (rednorm == 1 && greennorm <= 0.10 ) { 
      // between red
       mySerial.println("Red");
      }
     }
 if (bluenorm >= 0.99) {
      // between blue and violet
      mySerial.println("blue");
    } 
 if (cyannorm>=1 && magnetanorm==0.00 && bluenorm > 0.6) // Cyan
  {
    mySerial.println("Cyan"); 
  }
  if (magnetanorm >=1.00 && cyannorm==0) // Magneta
  {
    mySerial.println("Magneta");
  }
 if (yellownorm >1.5) // Yellow
  {
    mySerial.println("Yellow");
  }
 if (blacknorm >1.4 ) // Black
  {
    mySerial.println("Black");
  } 
 if (Int >10000 && yellownorm <1.20) // Intesity White 7311.33
  {
    mySerial.println("White");
  } 
}
int gesture()
{
if (APDS9960_INT)
  {
    handleGesture();
  }
}

void handleGesture() {
    if ( apds.isGestureAvailable() ) {
    switch ( apds.readGesture() ) {
      case DIR_UP:
        mySerial.println("UP");
        break;
      case DIR_DOWN:
        mySerial.println("DOWN");
        break;
      case DIR_LEFT:
        mySerial.println("LEFT");
        break;
      case DIR_RIGHT:
        mySerial.println("RIGHT");
        break;
      case DIR_NEAR:
        mySerial.println("NEAR");
        break;
      case DIR_FAR:
        mySerial.println("FAR");
        break;
      default:
        mySerial.println("NONE");
    }
  }
}

void buttons()
{ 
 if (digitalRead(buttonPin_red)==0) // 
  {
   
   delay(debounce);   
   //buttonPushCounter++;   
   mySerial.println("RSW");
   //altSerial.println(buttonPushCounter);
   //altSerial.println(); 
   delay( holdTime);   
  }  
 else
    if (digitalRead(buttonPin_green_rst)==0)
    {
       
   
   delay(debounce);   
   //buttonPushCounter++;
   //altSerial.println("on");
   mySerial.println("YLCN");
   //altSerial.println(buttonPushCounter);
   //altSerial.println(); 
   delay( holdTime);   
     } 
        
else
    if (digitalRead(buttonPin_green_usb)==0)
    {
     
   delay(debounce); 
   //buttonPushCounter++;
   //altSerial.println("on");
   mySerial.println("GUSW");
   //altSerial.println(buttonPushCounter);
   //altSerial.println(); 
   delay( holdTime);  
  
    }                   
 else
      if (digitalRead(buttonPin_yellow)==0)
      {
  
   delay(debounce); 
   //buttonPushCounter++;
   //altSerial.println("on");
   mySerial.println("YLTK");
   //altSerial.println(buttonPushCounter);
   //altSerial.println();
   delay( holdTime);   
 
      }
   //else delay(holdTime); 
}
