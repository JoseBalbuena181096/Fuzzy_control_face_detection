#include <stdlib.h>
#include <Servo.h>

bool stringComplete = false;  // whether the string is complete
int j = 0;
int k = 0;
bool is_comma = false;

char x_char[20];
char y_char[20];

float position_x = 0.0;
float position_y = 0.0;

Servo servo_x;
Servo servo_y;

void setup() {
  // initialize serial:
  Serial.begin(9600);
  for(int i=0;i<20;i++)
  {
    x_char[i] = 0;
    y_char[i] = 0;
  }
  servo_x.attach(3);
  servo_y.attach(4);

  servo_x.write(90);
  servo_y.write(90);
}

void loop() {
  // print the string when a newline arrives:
  if (stringComplete) 
  {
    position_x = atoi(x_char);
    position_y = atoi(y_char);
    Serial.println(position_x);
    Serial.println(position_y);
    // clear the string:
   for(int i=0;i<20;i++)
   {
    x_char[i] = 0;
    y_char[i] = 0;
   }
   j = 0;
   k = 0;
   is_comma = false;
   stringComplete = false;
 }
  servo_x.write(90+position_x);
  servo_y.write(90+position_y); 
}

/*
  SerialEvent occurs whenever a new data comes in the hardware serial RX. This
  routine is run between each time loop() runs, so using delay inside loop can
  delay response. Multiple bytes of data may be available.
*/
void serialEvent() {
  while (Serial.available()) {
    // get the new byte:
    char inChar = (char)Serial.read();
    // add it to the inputString:
    if(inChar == ',')
      is_comma = true;      
    if(!is_comma)
      x_char[j++] = inChar;
    else
       y_char[k++] = inChar;
    // if the incoming character is a newline, set a flag so the main loop can
    // do something about it:
    if (inChar == '\n') {
      y_char[0] = ' ';
      x_char[j] = '\n';
      y_char[k] = '\n';
      stringComplete = true;
    }
  }
}
