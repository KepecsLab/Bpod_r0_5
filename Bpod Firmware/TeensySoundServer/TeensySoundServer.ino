#include <Audio.h>
#include <Wire.h>
#include <SD.h>
#include <SPI.h>
AudioPlaySdWav     wav;
AudioOutputI2S     dac;
AudioConnection c1(wav, 0, dac, 0); // Connect left channel SD to DAC left
AudioConnection c2(wav, 1, dac, 1); // Connect right channel SD to DAC right
AudioControlSGTL5000 audioShield;
byte commandByte = 0; byte dataByte = 0;
byte soundIndex = 0;
byte LowByte = 0; byte SecondByte = 0; byte ThirdByte = 0; byte FourthByte = 0;
byte soundCommandReceived = 0;
unsigned long nBytes = 0;
unsigned long LongInt = 0;
char filename[] = "XXX.WAV";;
File myFile;

void setup() {
  Serial.begin(115200);
  Serial1.begin(115200);
  AudioMemory(5);
  audioShield.enable();
  audioShield.volume(80);
  SPI.setMOSI(7); SPI.setSCK(14);
  if (SD.begin(10)) {
    wav.play("001.WAV");
  }
}

void loop() {
  if (Serial.available()) {
    commandByte = Serial.read();
    switch (commandByte) {
      case 'S': { // Play file
        soundCommandReceived = 1;
        soundIndex = Serial.read();
      } break;
      case 'F': { // Write file
      while (Serial.available() == 0) {}
        soundIndex = Serial.read();
        filename[2] = (soundIndex%10) + 48; soundIndex/= 10;
        filename[1] = (soundIndex%10) + 48; soundIndex/= 10;
        filename[0] = (soundIndex%10) + 48;
        SD.remove(filename);
        myFile = SD.open(filename, FILE_WRITE);
        if (myFile) {
          nBytes = ReadLong();
          Serial.println(nBytes);
          for (unsigned long i = 0; i < nBytes; i++) {
            while (Serial.available() == 0) {}
            dataByte = Serial.read();
            myFile.write(dataByte);
          }
      	// close the file:
          myFile.close();
        }
      } break;
    }
  } 
  if (Serial1.available()) {
    soundCommandReceived = 1;
    soundIndex = Serial1.read();
  }
  if (soundCommandReceived) {
    if (soundIndex > 0) {
      if (soundIndex < 255) {
        filename[2] = (soundIndex%10) + 48; soundIndex/= 10;
        filename[1] = (soundIndex%10) + 48; soundIndex/= 10;
        filename[0] = (soundIndex%10) + 48;
        wav.play(filename);
      } else {
        wav.stop();
      }
    }
    soundCommandReceived = 0;
  }
}

unsigned long ReadLong() {
  while (Serial.available() == 0) {}
  LowByte = Serial.read();
  while (Serial.available() == 0) {}
  SecondByte = Serial.read();
  while (Serial.available() == 0) {}
  ThirdByte = Serial.read();
  while (Serial.available() == 0) {}
  FourthByte = Serial.read();
  LongInt =  (unsigned long)(((unsigned long)FourthByte << 24) | ((unsigned long)ThirdByte << 16) | ((unsigned long)SecondByte << 8) | ((unsigned long)LowByte));
  return LongInt;
}
