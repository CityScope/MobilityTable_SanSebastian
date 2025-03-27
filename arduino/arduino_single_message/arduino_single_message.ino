#define PIN_SLIDE_N A0
#define PIN_SLIDE_S A1
#define BUTTON_A 2
#define BUTTON_B 3
#define BUTTON_C 4

float value_N = 0;
float old_value_N = 0;
float value_S = 0;
float old_value_S = 0;

int buttonState_A = 0;
int buttonStateOld_A = 0;
int buttonState_B = 0;
int buttonStateOld_B = 0;
int buttonState_C = 0;
int buttonStateOld_C = 0;

void setup() {
    pinMode(PIN_SLIDE_N, INPUT);
    pinMode(PIN_SLIDE_S, INPUT);
    pinMode(BUTTON_A, INPUT);
    pinMode(BUTTON_B, INPUT);
    pinMode(BUTTON_C, INPUT);
    Serial.begin(9600);
}

void loop() {
  buttonState_A = digitalRead(BUTTON_A);
  buttonState_B = digitalRead(BUTTON_B);
  buttonState_C = digitalRead(BUTTON_C);

  if ((buttonState_A == HIGH) && (buttonStateOld_A == LOW)) { 
    Serial.println("button_A;");
    Serial.print(buttonState_A);
    Serial.println(";");
    Serial.println(";");
  } 
  buttonStateOld_A = buttonState_A;

  if ((buttonState_B == HIGH) && (buttonStateOld_B == LOW)) { 
    Serial.println("button_B;");
    Serial.print(buttonState_B);
    Serial.println(";");
    Serial.println(";");
  } 
  buttonStateOld_B = buttonState_B;

  if ((buttonState_C == HIGH) && (buttonStateOld_C == LOW)) { 
    Serial.println("button_C;");
    Serial.print(buttonState_C);
    Serial.println(";");
    Serial.println(";");
  } 
  buttonStateOld_C = buttonState_C;

  int adc_N  = analogRead(PIN_SLIDE_N) ;
  value_N = adc_N * 5.0/1024*5;
  if (abs(value_N - old_value_N)>2){
    Serial.println("slider_N;");
    Serial.print(int(value_N));
    Serial.println(";");
    Serial.println(";");
    old_value_N = value_N;
    delay(2000);
  }

  int adc_S  = analogRead(PIN_SLIDE_S) ;
  value_S = adc_S * 5.0/1024*5;
  if (abs(value_S - old_value_S)>2){
    Serial.println("slider_S;");
    Serial.print(int(value_S));
    Serial.println(";");
    Serial.println(";");
    old_value_S = value_S;
    delay(2000);
  }

}
