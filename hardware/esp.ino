#include <HardwareSerial.h>

HardwareSerial SIM800(2);

#define RXD2 16
#define TXD2 17

void printSIM800Response();
void waitForPrompt();

void setup() {
  Serial.begin(115200);
  SIM800.begin(9600, SERIAL_8N1, RXD2, TXD2);
  delay(3000);
  Serial.println("SIM800 Test Begin");

  SIM800.println("AT");
  printSIM800Response();

  SIM800.println("AT+CPIN?");
  printSIM800Response();

  SIM800.println("AT+CREG?");
  printSIM800Response();

  SIM800.println("AT+CSQ");
  printSIM800Response();

  SIM800.println("AT+CSCA?");
  printSIM800Response();

  SIM800.println("AT+CMGF=1");
  printSIM800Response();

  SIM800.println("AT+CMGS=\"+919994922460\"");
  waitForPrompt();

  SIM800.print("Test SMS from ESP32");
  SIM800.write(26); // Ctrl+Z to send SMS
  printSIM800Response();
}

void loop() {
  if (SIM800.available()) {
    Serial.write(SIM800.read());
  }
}

// Reads SIM800 responses until timeout (3 sec idle)
void printSIM800Response() {
  unsigned long timeout = millis() + 3000;
  while (millis() < timeout) {
    while (SIM800.available()) {
      Serial.write(SIM800.read());
      timeout = millis() + 3000; // reset timeout after every new char
    }
  }
  Serial.println();
}

// Waits for '>' prompt (max 10 sec)
void waitForPrompt() {
  Serial.println("Waiting for '>' prompt...");
  unsigned long timeout = millis() + 10000;
  while (millis() < timeout) {
    if (SIM800.available()) {
      char c = SIM800.read();
      Serial.write(c);
      if (c == '>') {
        Serial.println("\nGot '>' prompt!");
        return;
      }
    }
  }
  Serial.println("\nTimeout waiting for '>' prompt!");
}
