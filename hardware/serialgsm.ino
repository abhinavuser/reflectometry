#include <SoftwareSerial.h>

SoftwareSerial gsm(4, 5); // RX, TX

void setup() {
  Serial.begin(9600);     
  gsm.begin(9600);        

  Serial.println("Initializing GSM module...");
  delay(1000);

  // SMS text mode
  gsm.println("AT+CMGF=1");
  delay(1000);

  // Set SMS storage to SIM card
  gsm.println("AT+CPMS=\"SM\",\"SM\",\"SM\"");
  delay(1000);

  // Enable new message indications (CNMI)
  gsm.println("AT+CNMI=2,1,0,0,0");
  delay(1000);

  Serial.println("GSM module ready.");

  // Example: send an SMS
  sendSMS("+917010153718", "Hello from Arduino + GSM!");
}

void loop() {
  // Read incoming data from GSM module
  while (gsm.available()) {
    char c = gsm.read();
    Serial.print(c); // Print each character immediately
  }
}

void sendSMS(String number, String text) {
  Serial.println("Sending SMS...");

  gsm.print("AT+CMGS=\"");
  gsm.print(number);
  gsm.println("\"");
  delay(1000);

  gsm.print(text);
  delay(500);

  gsm.write(26); // CTRL+Z to send
  delay(5000);

  Serial.println("\nSMS sent.");
}