
#include <SPI.h>
#include <Adafruit_NeoPixel.h>
#include <Adafruit_BLE_UART.h>

#define NEOPIXEL_PIN 6
#define NEOPIXEL_COUNT 180
#define BLE_RDY 2
#define BLE_RST 9
#define BLE_REQ 10

Adafruit_NeoPixel strip = Adafruit_NeoPixel(NEOPIXEL_COUNT, NEOPIXEL_PIN, NEO_GRB + NEO_KHZ800);
Adafruit_BLE_UART uart = Adafruit_BLE_UART(BLE_REQ, BLE_RDY, BLE_RST);

void setup() {
  Serial.begin(9600);

  strip.begin();
  for (int i = 0; i < strip.numPixels(); i++) {
    strip.setPixelColor(i, 200, 200, 200);
  }
  strip.show();

  uart.setRXcallback(dataReceived);
  uart.setACIcallback(aciCallback);
  uart.begin();
}

void loop() {
  uart.pollACI();
}

void aciCallback(aci_evt_opcode_t event) {
  switch (event) {
    case ACI_EVT_DEVICE_STARTED:
      Serial.println("Advertising started");
      break;
    case ACI_EVT_CONNECTED:
      Serial.println("Connected!");
      break;
    case ACI_EVT_DISCONNECTED:
      Serial.println("Disconnected");
      break;
  }
}

void dataReceived(uint8_t *buffer, uint8_t len) {
  Serial.print(F("Received "));
  Serial.print(len);
  Serial.print(F(" bytes: "));
  for(int i=0; i<len; i++)
   Serial.print((char)buffer[i]); 

  Serial.print(F(" ["));

  for(int i=0; i<len; i++)
  {
    Serial.print(" 0x"); Serial.print((char)buffer[i], HEX); 
  }
  Serial.println(F(" ]"));

  if (buffer[0] == 'C' && len == 5) {
    changeLightColor(buffer+1);
  }
}

void changeLightColor(uint8_t *data) {
  uint32_t color = strip.Color((char)data[0], (char)data[1], (char)data[2]);
  Serial.print("0x");
  Serial.print(color, HEX);
  Serial.println();

  for (int i = 0; i < strip.numPixels(); i++) {
    strip.setPixelColor(i, color);
  }
  strip.setBrightness((char)data[3]);
  strip.show();
}
