#include "HX711.h"

///////////////
// CONSTANTS //
///////////////

// Define the HX711 pins
const byte DOUT     = A0;
const byte PD_SCK   = A1; 

// Coefficients from the trendline 
const float a       = 2207.683;
const float b       = 639177.965;

// Time the pic takes to finish its program [miliseconds]
const int picTime   = 10;

///////////////
// VARIABLES //
///////////////

// Set up variables
HX711 scale;
long  reading         = 0;
long  value           = 0;
int   microcontroller = 5;
bool  picHasRun       = 0; // This is to stop the Arduino program from running
                           // since there is no need check for weight when the boxes
                           // are being switched

/////////////
// PROGRAM //
/////////////

// Helper function that converts the HX711 signal to grams
// Based off information from the report
long voltToGram(long volt, float a, float b) {
  return (volt - b) / a;
}

void setup() {
  // Setup output pins
  pinMode(microcontroller, OUTPUT);

  // Setup scale
  scale.begin(DOUT, PD_SCK);
  scale.tare();

  // Setup serial interface
  Serial.begin(9600);
}

void loop() {
  // Get average data from 10 HX711 readings
  reading = scale.read_average(10);

  // Convert the readin to grams
  value = voltToGram(reading, a, b);

  // Now check if the value is greater than or equal to 500 so the PIC can get working
  if(value >= 500) {
    digitalWrite(microcontroller, HIGH);
    picHasRun = 1;
  }

  // Since the PIC we might as well just set the signal to low here
  digitalWrite(microcontroller, LOW);

  scale.power_down();
  
  // Either pause the Arduino program while boxes are being switched
  if (picHasRun == 1) {
    delay(picTime);
    picHasRun = 0;
  } 
  scale.power_up();
}


