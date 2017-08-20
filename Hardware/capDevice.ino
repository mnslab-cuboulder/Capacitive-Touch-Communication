#define FRAME 2

int led = 13;
int pinOut = 9;
int upLength = 50;
int downLength = 50;
int frameLength = 100;

void setup() {
  // initialize the digital pin as an output.
  pinMode(led, OUTPUT);
  pinMode(pinOut, OUTPUT);
}

// the loop routine runs over and over again forever:
void loop() {
  sendStr("F@r7");
}

void sendStr(String s)
{
  for (int x = 0; x < s.length(); ++x)
  {
    sendChar(s[x]);
  }
}

void sendChar(char c)
{
  sendBit(FRAME);

  // This will 'output' the binary representation of 'inputChar' as 8 characters of '1's and '0's, MSB first.
  for ( uint8_t bitMask = 64; bitMask != 0; bitMask = bitMask >> 1 ) {
    if ( c & bitMask ) {
      sendBit(1);
    } else {
      sendBit(0);
    }
  }
}

void sendBit(int b)
{
  if (b == 0)
  {
    digitalWrite(led, LOW);    // turn the LED off by making the voltage LOW
    digitalWrite(pinOut, LOW);
    delay(upLength*2);               // wait for a second
  }
  else if (b == 1)
  {
    digitalWrite(led, HIGH);   // turn the LED on (HIGH is the voltage level)
    digitalWrite(pinOut, HIGH);
    delay(downLength);               // wait for a second
    digitalWrite(led, LOW);    // turn the LED off by making the voltage LOW
    digitalWrite(pinOut, LOW);
    delay(upLength);               // wait for a second
  }
  else //send frame
  {
    digitalWrite(led, HIGH);   // turn the LED on (HIGH is the voltage level)
    digitalWrite(pinOut, HIGH);
    delay(frameLength);               // wait for a second
    digitalWrite(led, LOW);    // turn the LED off by making the voltage LOW
    digitalWrite(pinOut, LOW);
    delay(upLength);               // wait for a second
  }
}

