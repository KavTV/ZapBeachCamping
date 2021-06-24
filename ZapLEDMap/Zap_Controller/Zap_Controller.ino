#include "WiFi.h"
#include "ESPAsyncWebServer.h"
//Login for WIFI
const char* ssid = "Zap";
const char* password =  "Passw0rd!";
//set the port for webserver
AsyncWebServer server(80);
//Define all led pins for each sites
#define red_light_73 32
#define green_light_73 33

#define red_light_72 22
#define green_light_72 23

#define red_light_70 21
#define green_light_70 19

#define red_light_68 18
#define green_light_68 5

#define red_light_67 14
#define green_light_67 13
bool waitingforrequest = true;

void setup() {
  //Pinmodes foreach sites
  pinMode(red_light_73, OUTPUT);
  pinMode(green_light_73, OUTPUT);

  pinMode(red_light_72, OUTPUT);
  pinMode(green_light_72, OUTPUT);

  pinMode(red_light_70, OUTPUT);
  pinMode(green_light_70, OUTPUT);

  pinMode(red_light_68, OUTPUT);
  pinMode(green_light_68, OUTPUT);

  pinMode(red_light_67, OUTPUT);
  pinMode(green_light_67, OUTPUT);

  Serial.begin(115200);

  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi..");
  }

  Serial.println(WiFi.localIP());

  server.on("/", HTTP_GET, [](AsyncWebServerRequest * request) {

    int paramsNr = request->params();
    Serial.println(paramsNr);

    for (int i = 0; i < paramsNr; i++) {
      waitingforrequest = false;
      AsyncWebParameter* p = request->getParam(i);

      int test = (p->name()).toInt();
      if(test == 73){
          if (p->value() == "TRUE")
          {
            Serial.println("Value is true");
            RGB_color(0, 1, 0, green_light_73, red_light_73);
          }
          else {
            RGB_color(1, 0, 0, green_light_73, red_light_73);
          }
      }
      else if(test == 72) {
        
          if (p->value() == "TRUE")
          {
            Serial.println("Value is true");
            RGB_color(0, 1, 0, green_light_72, red_light_72);
          }
          else {
            RGB_color(1, 0, 0, green_light_72, red_light_72);
          }
      }
        else if(test ==70){
          if (p->value() == "TRUE")
          {
            Serial.println("Value is true");
            RGB_color(0, 1, 0, green_light_70, red_light_70);
          }
          else {
            RGB_color(1, 0, 0, green_light_70, red_light_70);
          }
        }
        else if (test == 68){
          if (p->value() == "TRUE")
          {
            Serial.println("Value is true");
            RGB_color(0, 1, 0, green_light_68, red_light_68);
          }
          else {
            RGB_color(1, 0, 0,green_light_68, red_light_68);
          }
        }
        else if( test == 67) {
          if (p->value() == "TRUE")
          {
            Serial.println("Value is true");
            RGB_color(0, 1, 0, green_light_67, red_light_67);
          }
          else {
            RGB_color(1, 0, 0, green_light_67, red_light_67);
          }
        }

      Serial.print("Param name: ");
      Serial.println(p->name());
      Serial.print("Param value: ");
      Serial.println(p->value());
      Serial.println("------");
    }

    request->send(200, "text/plain", "message received");
  });

  server.begin();
}

void loop() {
  while(waitingforrequest)
  {
    //waiting for input :)
    RGB_color(1, 1, 0, green_light_70, red_light_70);
    delay(1000);
    RGB_color(0, 0, 0, green_light_70, red_light_70);
    delay(1000);
  }
}

void RGB_color(int red_light_value, int green_light_value, int blue_light_value, int green_pin, int red_pin)
{
  digitalWrite(red_pin, red_light_value);
  digitalWrite(green_pin, green_light_value);
}
