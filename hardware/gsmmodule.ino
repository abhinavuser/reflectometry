
#include <SoftwareSerial.h>
// Create a SoftwareSerial object to communicate with the SIM800L module
SoftwareSerial mySerial(3, 2); // SIM800L Tx & Rx connected to Arduino pins #3 & #2
void setup()
{
  // Initialize serial communication with Arduino and the Arduino IDE (Serial Monitor)
  Serial.begin(9600);
  // Initialize serial communication with Arduino and the SIM800L module
  mySerial.begin(9600);
  Serial.println("Initializing..."); 
  delay(1000);
  mySerial.println("AT"); // Handshake test, should return "OK" on success
  updateSerial();
  mySerial.println("AT+CMGF=1"); // Configuring TEXT mode
  updateSerial();
  mySerial.println("AT+CMGS=\"+ZZxxxxxxxxxx\""); // Change ZZ with the country code and xxxxxxxxxxx with the phone number to send an SMS to
  updateSerial();
  mySerial.print("Circuitdigest | circuitdigest.com"); // SMS text content
  updateSerial();
  mySerial.write(26); // Send the CTRL+Z character to terminate the SMS
}
void loop()
{
}
void updateSerial()
{
  delay(500);
  while (Serial.available()) 
  {
    mySerial.write(Serial.read()); // Forward data from Serial to Software Serial Port
  }
  while (mySerial.available()) 
  {