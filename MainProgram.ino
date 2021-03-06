////////////////////////
// EXTERNAL LIBRARIES //
////////////////////////
#include "HX711.h"

///////////////
// CONSTANTS //
///////////////

// Define the HX711 pins
const byte DOUT     = A2;
const byte PD_SCK   = A3; 

// Coefficients from the trendline 
const float a       = 2207.683;
const float b       = 639177.965;

// Weight to run at
const int runWeight = 150;

// Weight of boxes
const int boxWeight = 30; // g

///////////////
// VARIABLES //
///////////////

// PIC Pins
int   PICRun          = 6;
int   PICStop         = 5;

// Scale
HX711 scale;

// Data to manipulate
long  reading         = 0;
long  value           = 0;

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
  pinMode(PICRun, OUTPUT);
  pinMode(PICStop, OUTPUT);

  // Setup scale
  scale.begin(DOUT, PD_SCK);
  scale.tare();
  
  // Setup serial interface
  Serial.begin(9600);
  Serial.println("Vores program.exe");
  Serial.println("------------------------------------- \n");
}

void loop() {
  // Get average data from 10 HX711 readings
  reading = scale.read_average(10);

  // Convert the readin to grams
  value = voltToGram(reading, a, b);

  // Detect a box without an LDR
  if(value >= boxWeight) {
    // Run the program
    program(value);  
  } else {
    // Tell the PIC to stop  
    digitalWrite(PICStop, HIGH); // Stop the motor
    digitalWrite(PICRun, LOW);   // Don't don the program
  }
}

// Program definition to reduce indentation
void program(long value) {
  // Tell the PIC to start
  digitalWrite(PICStop, LOW);   // Start the motor
  
  // Outout the data in a formatted way
  Serial.print("Weight = ");
  Serial.print(value);
  Serial.print(" g\t|\t Reading: ");
  Serial.println(reading);
  
  // Now check if the value is greater than or equal to 500 so the PIC can get working
  if(value >= runWeight) {
    // TEll the PIC to run its program
    digitalWrite(PICRun, HIGH);
  } else {
    // Tell the PIC to not do anything
    digitalWrite(PICRun, LOW);
  }
}
