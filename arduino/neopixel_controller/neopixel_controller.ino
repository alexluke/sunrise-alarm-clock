
#include <stdarg.h>
#include <SPI.h>
#include <Adafruit_NeoPixel.h>
#include <Adafruit_BLE_UART.h>

#define NEOPIXEL_PIN 6
#define NEOPIXEL_COUNT 180
#define BLE_RDY 2
#define BLE_RST 9
#define BLE_REQ 10

#define DEFAULT_TRANSITION_TIME 500

Adafruit_NeoPixel strip = Adafruit_NeoPixel(NEOPIXEL_COUNT, NEOPIXEL_PIN, NEO_GRB + NEO_KHZ800);
Adafruit_BLE_UART uart = Adafruit_BLE_UART(BLE_REQ, BLE_RDY, BLE_RST);

uint32_t currentColor = 0;
uint8_t currentBrightness = 255;
uint32_t targetColor = 0;
uint8_t targetBrightness = 255;
unsigned int transitionTime = 0;
uint32_t mask = 0xFF;

unsigned long prevTime;
unsigned long currTime;
unsigned long deltaTime;

void setup() {
  Serial.begin(9600);

  strip.begin();

  setColor(currentColor, currentBrightness);

  uart.setRXcallback(dataReceived);
  uart.setACIcallback(aciCallback);
  uart.begin();

  currTime = prevTime = millis();
}

void loop() {
  uart.pollACI();
  colorTick();
}

void colorTick() {
  prevTime = currTime;
  currTime = millis();
  deltaTime = currTime - prevTime;

  if (deltaTime == 0) {
    return;
  }

  if (currentColor != targetColor || currentBrightness != targetBrightness) {
    if (currentColor != targetColor) {
      for (int i = 0; i <= 16; i += 8) {
        uint8_t currentPart = (currentColor >> i) & mask;
        uint8_t targetPart = (targetColor >> i) & mask;
        uint8_t colorDelta = abs(targetPart - currentPart);
        uint8_t moveBy = colorDelta * deltaTime / transitionTime;

        uint32_t newPart;
        if (currentPart > targetPart)
          newPart = currentPart - moveBy;
        else
          newPart = currentPart + moveBy;
        currentColor = currentColor & ~(mask << i) | newPart << i;
      }
    }

    if (currentBrightness != targetBrightness) {
      uint8_t brightDelta = abs(targetBrightness - currentBrightness);
      uint8_t moveBy = brightDelta * deltaTime / transitionTime;

      if (currentBrightness > targetBrightness)
        currentBrightness -= brightDelta;
      else
        currentBrightness += brightDelta;
    }

    if (transitionTime < (transitionTime - deltaTime)) {
      transitionTime = 0;
      currentColor = targetColor;
      currentBrightness = targetBrightness;
    } else {
      transitionTime -= deltaTime;
    }

    setColor(currentColor, currentBrightness);
  }
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

void dataReceived(uint8_t *data, uint8_t len) {
  if (data[0] == 'C' && len == 5) {
    data++;
    targetColor = strip.Color((uint8_t)data[0], (uint8_t)data[1], (uint8_t)data[2]);
    targetBrightness = (uint8_t)data[3];
    transitionTime = DEFAULT_TRANSITION_TIME;
  }
}

void setColor(uint32_t color, uint8_t brightness) {
  currentColor = color;
  currentBrightness = brightness;
  for (int i = 0; i < strip.numPixels(); i++) {
    strip.setPixelColor(i, color);
  }
  strip.setBrightness(brightness);
  strip.show();
}
