#include <Wire.h>
#include <TinyGPS++.h>
#include <Arduino.h>
#include <WiFi.h>
#include <PubSubClient.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_SSD1306.h>
#include <Adafruit_Sensor.h>

#define SCREEN_WIDTH 128 // OLED display width, in pixels
#define SCREEN_HEIGHT 64 // OLED display height, in pixels

//On ESP32: GPIO-21(SDA), GPIO-22(SCL)
#define OLED_RESET -1 //Reset pin # (or -1 if sharing Arduino reset pin)
#define SCREEN_ADDRESS 0x3C //See datasheet for Address
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

Adafruit_MPU6050 mpu;
#define RXD2 16
#define TXD2 17
HardwareSerial neogps(1);


#define STRIKE_THR 10      // hit acceleration threshold


const char *SSID = "TestePC";//VIVOFIBRA-F538 João's IPhone iPhone de João Lucas AVELL-1711-V3 1486
const char *PWD = "senha123";//6811293F16 senha1318 senha123
TinyGPSPlus gps;

String flag = "0";
long last_time = 0;
long last_time2 = 0;
long last_time_warning_state = 0;
char data[100];
int16_t ax, ay, az;
int16_t gx, gy, gz;
int freq, freq_f = 20;
unsigned long ACC;
unsigned long GYR;
// MQTT client
WiFiClient wifiClient;
PubSubClient mqttClient(wifiClient);

char *mqttServer = "broker.mqttdashboard.com";
int mqttPort = 1883;

void connectToWiFi() {
  Serial.print("Connectiog to ");

  WiFi.begin(SSID, PWD);
  Serial.println(SSID);
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    display.clearDisplay();
    display.setTextColor(SSD1306_WHITE);
    display.setCursor(0, 0);
    display.setTextSize(3);
    display.print("WIFI   ERROR");
    display.display();
    delay(500);
  }

  Serial.print("Connected.");
  display.clearDisplay();
  display.setTextColor(SSD1306_WHITE);
  display.setCursor(0, 0);
  display.setTextSize(3);
  display.print("WIFI OK");
  display.display();
  delay(3000);
}

void callback(char* topic, byte* payload, unsigned int length) {

  Serial.print("Callback - ");
  Serial.print("Message:");
  for (int i = 0; i < length; i++) {
    Serial.print((char)payload[i]);
    char c = (char)payload[i];
    flag = c;
  }
}

void setupMQTT() {
  mqttClient.setServer(mqttServer, mqttPort);
  // set the callback function
  mqttClient.setCallback(callback);
}

void setup() {
  Serial.begin(115200);
  //Begin serial communication Arduino IDE (Serial Monitor)
  // SSD1306_SWITCHCAPVCC = generate display voltage from 3.3V internally
  if (!display.begin(SSD1306_SWITCHCAPVCC, SCREEN_ADDRESS)) {
    Serial.println(F("SSD1306 allocation failed"));
    for (;;); // Don't proceed, loop forever
  }
  connectToWiFi();

  setupMQTT();

  //Begin serial communication Neo6mGPS
  neogps.begin(9600, SERIAL_8N1, RXD2, TXD2);

  if (!mpu.begin()) {
    Serial.println("Sensor init failed");
    while (1)
      yield();
  }
  Serial.println("Found a MPU-6050 sensor");

  display.clearDisplay();
  display.display();
  delay(2000);

}

void reconnect() {
  Serial.println("Connecting to MQTT Broker...");
  while (!mqttClient.connected()) {
    Serial.println("failed, rc=");
    Serial.println(mqttClient.state());
    Serial.println("Reconnecting to MQTT Broker..");
    display.clearDisplay();
    display.setTextColor(SSD1306_WHITE);
    display.setCursor(0, 0);
    display.setTextSize(3);
    display.print("MQTT   ERROR");
    display.display();
    String clientId = "ESP32Client-";
    clientId += String(random(0xffff), HEX);

    if (mqttClient.connect(clientId.c_str())) {
      Serial.println("Connected.");
      // subscribe to topic
      mqttClient.subscribe("bike/park");
    }
  }
}

void loop() {
  sensors_event_t a, g, temp;
  mpu.getEvent(&a, &g, &temp);

  boolean newData = false;
  if (!mqttClient.connected()) {
    reconnect();
    display.clearDisplay();
    display.setTextColor(SSD1306_WHITE);
    display.setCursor(0, 0);
    display.setTextSize(3);
    display.print("MQTT OK");
    display.display();
    delay(3000);
  }
  mqttClient.loop();

  mqttClient.publish("bike/funcionando", "Funciona!");
  if (flag.equals("0")) {
    for (unsigned long start = millis(); millis() - start < 1000;)
    {
      while (neogps.available())
      {
        if (gps.encode(neogps.read()))
        {
          newData = true;
        }
      }
    }
    if (millis() - last_time_warning_state > 1000) {
      mqttClient.publish("bike/warning/state", "0"); //trocar sprintf(data, flag);
      last_time_warning_state = millis();
    }
    //If newData is true
    if (newData == true)
    {
      newData = false;
      Serial.println("GPS");
      Serial.println(gps.satellites.value());
      Serial.println("FLAG");
      Serial.println(flag);
      print_speed();
    }
    else
    {
      display.clearDisplay();
      display.setTextColor(SSD1306_WHITE);
      display.setCursor(0, 0);
      display.setTextSize(3);
      display.print("No Data");
      display.display();
    }
  } else if (flag.equals("1")) {
    if (millis() - last_time_warning_state > 1000) {
      mqttClient.publish("bike/warning/state", "1"); //trocar
      last_time_warning_state = millis();
    }
    long now = micros();
    for (unsigned long start = millis(); millis() - start < 1000;)
    {
      if (now - last_time > 500)
      {
        ACC = sqrt(sq((long)a.acceleration.x) + sq((long)a.acceleration.y) + sq((long)a.acceleration.z));
        strikeTick();
        last_time = now;
      }
    }
  }
}

void strikeTick()
{
  display.clearDisplay();
  display.display();
  Serial.println("ACC");
  Serial.println(ACC);
  if (ACC >= STRIKE_THR)
  {
    sprintf(data, "1");
    Serial.println(data);
    mqttClient.publish("bike/warning", data);
    Serial.println("saindo do park mode");
    flag = "0";
  }
}

void print_speed()
{
  display.clearDisplay();
  display.setTextColor(SSD1306_WHITE);
  long now2 = millis();
  if (now2 - last_time2 > 5000) {
    if (gps.location.isValid() == 1)
    {
      //String gps_speed = String(gps.speed.kmph());
      display.setTextSize(3);
      display.setCursor(5, 20);
      display.print(gps.speed.kmph());
      display.setTextSize(2);
      display.setCursor(80, 25);
      display.print("km/h");
      display.display();

      // Publishing data throgh MQTT
      sprintf(data, "LT:%.6f,LN:%.6f,V:%.2f", gps.location.lat(), gps.location.lng(), gps.speed.kmph());
      Serial.println(data);
      mqttClient.publish("bike/location", data);
      last_time2 = now2;
    }
    else
    {
      display.clearDisplay();
      display.setTextColor(SSD1306_WHITE);
      display.setCursor(0, 0);
      display.setTextSize(3);
      display.print("No Data");
      display.setCursor(0, 35);
      display.print(String(gps.satellites.value()));
      display.display();
    }
  }
}
