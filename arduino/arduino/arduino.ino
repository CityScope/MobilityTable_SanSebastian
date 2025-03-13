#define PIN_SLIDE_F_N A0
#define PIN_SLIDE_F_S A1
#define PIN_SLIDE_F_V A2
#define PIN_SLIDE_N_N A3
#define PIN_SLIDE_N_V A4
#define BUTTON_A 2
boolean buttonState_A = 0;
int lastButtonState = HIGH;
int currentButtonState;
// int A;
// int AA;
// #define DOWN 0

void setup() {
  // put your setup code here, to run once:
    pinMode(PIN_SLIDE_F_N, INPUT);
    pinMode(PIN_SLIDE_F_S, INPUT);
    pinMode(PIN_SLIDE_F_V, INPUT);
    pinMode(PIN_SLIDE_N_N, INPUT);
    pinMode(PIN_SLIDE_N_V, INPUT);
    pinMode(BUTTON_A, INPUT_PULLUP);
    //AA = digitalRead(BUTTON_A);

    Serial.begin(9600);
}

void loop() {
  // put your main code here, to run repeatedly:
  // Serial.println("hola!");
  Serial.println(",");

  Serial.print("10:100");
  Serial.print(",");

  Serial.print("0:");
  Serial.print(int(analogRead(PIN_SLIDE_F_N) * 5.0 / 1024 * 5));
  Serial.print(",");
  delay(0);

  Serial.print("1:");
  Serial.print(int(analogRead(PIN_SLIDE_F_S) * 5.0 / 1024 * 5));
  Serial.print(",");
  delay(1000);

  Serial.print("2:");
  Serial.print(int(analogRead(PIN_SLIDE_F_V) * 5.0 / 1024 * 5));
  Serial.print(",");
  delay(0);

  Serial.print("3:");
  Serial.print(int(analogRead(PIN_SLIDE_N_N) * 5.0 / 1024 * 5));
  Serial.print(",");
  delay(0);

  Serial.print("4:");
  Serial.print(int(analogRead(PIN_SLIDE_N_V) * 5.0 / 1024 * 5));
  Serial.print(",");
  delay(0);

  // A = AA;
  // AA = digitalRead(BUTTON_A);
  // if (A == DOWN && AA != DOWN){
  //   buttonState_A = !buttonState_A;
  // }

  // Lectura del botón con detección de flanco
  currentButtonState = digitalRead(BUTTON_A);
  // Serial.print("currentButtonState");
  // Serial.print(digitalRead(BUTTON_A));
  // Serial.print("latButtonState");
  // Serial.print(lastButtonState);
  if (lastButtonState == HIGH && currentButtonState == LOW) {  
        buttonState_A = !buttonState_A;  // Toggle state
  }

  lastButtonState = currentButtonState; // Update last state

  Serial.print("5:");
  Serial.print(buttonState_A);
  Serial.print(",");

  Serial.print("10:100");
  Serial.print(",");
  Serial.println();
  delay(0);

}
