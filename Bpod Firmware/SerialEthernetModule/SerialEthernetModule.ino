#include <SPI.h>
#include <Ethernet.h>
EthernetClient client;
byte mac[] = {0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED};
IPAddress clientIP(192,0,0,1); // Actual address will be received later
IPAddress serverIP(1,1,1,1); 
int port = 0; // Actual port will be received later
byte commandByte = 0; 
byte inByteLow = 0; byte inByteHigh = 0;
byte IP1 = 0; byte IP2 = 0; byte IP3 = 0; byte IP4 = 0;
void setup()  
{
  Serial.begin(115200);
  Serial2.begin(115200);
  pinMode(18, OUTPUT);
}

void loop() {
  if Serial.available(){
    commandByte = Serial.read();
    switch(commandByte) {
      case 'I': // Read a new ip and bring up the network
        while (Serial.available() == 0) {}
        IP1 = Serial.read();
        while (Serial.available() == 0) {}
        IP2 = Serial.read();
        while (Serial.available() == 0) {}
        IP3 = Serial.read();
        while (Serial.available() == 0) {}
        IP4 = Serial.read();
        clientIP = ip(IP1,IP2,IP3,IP4);
        Ethernet.begin(mac, clientIP);
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
        serverIP = ip(IP1,IP2,IP3,IP4);
        while (Serial.available() == 0) {}
        inByteLow = Serial.read();
        while (Serial.available() == 0) {}
        inByteHigh = Serial.read();
        port = word(inByteHigh, inByteLow);
        if (client.connect(serverIP, port)) {
          Serial.write(1);
        } else {
          Serial.write(0);
        }
      break;
    }
  }
}
