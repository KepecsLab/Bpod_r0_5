// Ethernet module firmware
// For Bpod 0_5
// Programmed by Josh Sanders, January 2013
#include <SPI.h>
#include <Ethernet.h>
EthernetClient client;
byte mac[] = {0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED};
IPAddress ip(192,168,1,177); // Actual address will be received later
IPAddress server(1,1,1,1); 
int port = 3336; // Actual port will be received later
byte LowByte = 0;
byte HighByte = 0;
byte Position = 0; 
int MessageLength = 0;

void setup() {
  Ethernet.begin(mac, ip);
}

void loop() {
  while (Serial.available() == 0) {}  // Wait for MATLAB command
  CommandByte = Serial.read();  // P for Program, R for Run, O for Override, 6 for Device ID
  if (CommandByte == '6') {
    Serial.print(5);
  }
  else if (CommandByte == 'S') {  // Setup Ethernet connection
    // Get Local IP
    
    // Get Server IP
    
    // Get remote port
    while (Serial.available() == 0) {}
    LowByte = Serial.read();
    while (Serial.available() == 0) {}
    HighByte = Serial.read();
    port = word(HighByte, LowByte);
  }
  else if (CommandByte == 'C') {  // Connect Ethernet connection
    if (client.connect(server, port)) {
      Serial.write(1);
    } 
    else {
      Serial.write(0);
    }
  }
  else if (CommandByte == 'D') { // Disconnect Ethernet connection
    client.stop();
  }
  else if (CommandByte == 'N') { // Receive new message string to store
    while (Serial.available() == 0) {}
    Position = Serial.read(); // Which of n possible messages (triggered by id at runtime)
    while (Serial.available() == 0) {}
    LowByte = Serial.read();
    while (Serial.available() == 0) {}
    HighByte = Serial.read();
    MessageLength = word(HighByte, LowByte); 
    for (int x = 0; x < 
  }
}
