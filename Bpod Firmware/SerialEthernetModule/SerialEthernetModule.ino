/*{
----------------------------------------------------------------------------

This file is part of the Bpod Project
Copyright (C) 2014 Joshua I. Sanders, Cold Spring Harbor Laboratory, NY, USA

----------------------------------------------------------------------------

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, version 3.

This program is distributed  WITHOUT ANY WARRANTY and without even the 
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
#include <SPI.h>
#include <Ethernet.h>
EthernetClient client;
byte mac[] = {0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED};
int port = 0; // Actual port will be received later
byte commandByte = 0; 
byte inByteLow = 0; byte inByteHigh = 0;
byte IP1 = 0; byte IP2 = 0; byte IP3 = 0; byte IP4 = 0;
byte StringNum = 0;
byte StringLength = 0;
byte MessageMode = 0; // set to 1 to connect, send and disconnect with each message. Set to 0 to only send.
String String1 = "";
String String2 = "";
String String3 = "";
String String4 = "";
String String5 = "";
String String6 = "";
String String7 = "";
String String8 = "";
String String9 = "";
String String10 = "";
IPAddress serverIP(0,0,0,0);

void setup()  
{
  Serial.begin(115200);
  Serial1.begin(115200);
  pinMode(18, OUTPUT);
}

void loop() {
  if (Serial.available()){
    commandByte = Serial.read();
    switch(commandByte) {
      case 'I': // Read a new ip and bring up the network
        Ethernet.begin(mac);
        Serial.write(1);
        break;
      case 'C': // Read server ip + port and connect
        while (Serial.available() == 0) {}
        IP1 = Serial.read();
        while (Serial.available() == 0) {}
        IP2 = Serial.read();
        while (Serial.available() == 0) {}
        IP3 = Serial.read();
        while (Serial.available() == 0) {}
        IP4 = Serial.read();
        serverIP[0] = IP1; serverIP[1] = IP2;  serverIP[2] = IP3;  serverIP[3] = IP4; 
        while (Serial.available() == 0) {}
        inByteLow = Serial.read();
        while (Serial.available() == 0) {}
        inByteHigh = Serial.read();
        port = word(inByteHigh, inByteLow);
        if (client.connect(serverIP, port)) {
          Serial.write(1);
        }
        break;
      case 'L': // Load a string into a slot
        while (Serial.available() == 0) {}
        StringNum = Serial.read();
        while (Serial.available() == 0) {}
        StringLength = Serial.read();
        switch (StringNum) {
          case 1: String1 = ""; break;
          case 2: String2 = ""; break;
          case 3: String3 = ""; break;
          case 4: String4 = ""; break;
          case 5: String5 = ""; break;
          case 6: String6 = ""; break;
          case 7: String7 = ""; break;
          case 8: String8 = ""; break;
          case 9: String9 = ""; break;
          case 10: String10 = ""; break;
        }
        for (int i = 0; i < StringLength; i++) {
          while (Serial.available() == 0) {}
          inByteLow = Serial.read();
          switch (StringNum) {
            case 1:
              String1 = String1 + char(inByteLow); break;
            case 2:
              String2 = String2 + char(inByteLow); break;
            case 3:
              String3 = String3 + char(inByteLow); break;
            case 4:
              String4 = String4 + char(inByteLow); break;
            case 5:
              String5 = String5 + char(inByteLow); break;
            case 6:
              String6 = String6 + char(inByteLow); break;
            case 7:
              String7 = String7 + char(inByteLow); break;
            case 8:
              String8 = String8 + char(inByteLow); break;
            case 9:
              String9 = String9 + char(inByteLow); break;
            case 10:
              String10 = String10 + char(inByteLow); break;
          }    
        }
        break;
      case 'T': // Trigger a string from USB
        while (Serial.available() == 0) {}
        StringNum = Serial.read();
        TriggerString(StringNum);
        break;
      case 'M': // Set message mode
        while (Serial.available() == 0) {}
        MessageMode = Serial.read();
      break;
      case 'X': // Disconnect
        client.stop();
      break;
    } 
  }
  if (Serial1.available()) {
    StringNum = Serial1.read();
    TriggerString(StringNum);
  }
}

void TriggerString(byte StringNum) {
  switch (StringNum) {
        case 1: client.println(String1); break;
        case 2: client.println(String2); break;
        case 3: client.println(String3); break;
        case 4: client.println(String4); break;
        case 5: client.println(String5); break;
        case 6: client.println(String6); break;
        case 7: client.println(String7); break;
        case 8: client.println(String8); break;
        case 9: client.println(String9); break;
        case 10: client.println(String10); break;
   }
   if (MessageMode == 1) {
      client.stop();
      client.connect(serverIP, port);
    }
}
