const int pwmFrequency = 1000;      // PWM frequency in Hz
const float dutyCycle = 1.0;        // Duty cycle (0.0 to 1.0)

unsigned long periodMicros;
unsigned long startMicros;

void setup() {
  Serial.begin(115200);
  Serial.println("Time(us),PWM");
  periodMicros = 1000000UL / pwmFrequency;
  startMicros = micros();
}

void loop() {
  unsigned long currentMicros = micros();

  // Since dutyCycle is 1, PWM always HIGH
  Serial.print(currentMicros - startMicros);
  Serial.print(",");
  Serial.println(1);  // Always HIGH

  delay(1);  // slow down the output
}