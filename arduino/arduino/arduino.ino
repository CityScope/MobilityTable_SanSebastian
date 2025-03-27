#define PIN_SLIDE_N A0
#define PIN_SLIDE_S A1
#define BUTTON_A 2
#define BUTTON_B 3
#define BUTTON_C 4

boolean buttonState_A = 0;
int lastButtonState_A = HIGH;
int currentButtonState_A;

boolean buttonState_B = 0;
int lastButtonState_B = HIGH;
int currentButtonState_B;

boolean buttonState_C = 0;
int lastButtonState_C = HIGH;
int currentButtonState_C;

void setup() {
  // put your setup code here, to run once:
    pinMode(PIN_SLIDE_N, INPUT);
    pinMode(PIN_SLIDE_S, INPUT);
    pinMode(BUTTON_A, INPUT_PULLUP);
    pinMode(BUTTON_B, INPUT_PULLUP);
    pinMode(BUTTON_C, INPUT_PULLUP);

    Serial.begin(9600);
}

void loop() {
  Serial.println(",");

  Serial.print("10:100");
  Serial.print(",");

  // SLIDERS

  Serial.print("0:");
  Serial.print(int(analogRead(PIN_SLIDE_N) * 5.0 / 1024 * 5));
  Serial.print(",");
  delay(0);

  Serial.print("1:");
  Serial.print(int(analogRead(PIN_SLIDE_S) * 5.0 / 1024 * 5));
  Serial.print(",");
  delay(1000);

  // BOTONES

  currentButtonState_A = digitalRead(BUTTON_A);
  if (lastButtonState_A == HIGH && currentButtonState_A == LOW) {  
        buttonState_A = !buttonState_A;
  }
  lastButtonState_A = currentButtonState_A;
  Serial.print("2:");
  Serial.print(buttonState_A);
  Serial.print(",");

  currentButtonState_B = digitalRead(BUTTON_B);
  if (lastButtonState_B == HIGH && currentButtonState_B == LOW) {  
        buttonState_B = !buttonState_B;
  }
  lastButtonState_B = currentButtonState_B;
  Serial.print("3:");
  Serial.print(buttonState_B);
  Serial.print(",");

  currentButtonState_C = digitalRead(BUTTON_C);
  if (lastButtonState_C == HIGH && currentButtonState_C == LOW) {  
        buttonState_C = !buttonState_C;
  }
  lastButtonState_C = currentButtonState_C;
  Serial.print("4:");
  Serial.print(buttonState_C);
  Serial.print(",");

  Serial.print("10:100");
  Serial.print(",");
  Serial.println();
  delay(0);

}
