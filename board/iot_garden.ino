#include <ArduinoJson.h>
#include <DHT_U.h>
#include <DHT.h>

class WateringStation
{
  int  uid;
  byte waterPumpPin;
  byte soilHumiditySensorPin;

  int lowSoilHumidity  = 30;
  int highSoilHumidity = 85;
  int wateringTime     = 1000;

  public:
    String name;

    WateringStation(){
    }
  
    WateringStation(int uid, byte waterPumpPin, byte soilHumiditySensorPin)
    {
      this->uid                   = uid;
      this->waterPumpPin          = waterPumpPin;
      this->soilHumiditySensorPin = soilHumiditySensorPin;
    }

    void init() {
      pinMode(waterPumpPin, OUTPUT);
      pinMode(soilHumiditySensorPin, INPUT);
    }

    void configure(String name, int lowSoilHumidity, int highSoilHumidity, int wateringTime) {
      this->name             = name;
      this->lowSoilHumidity  = lowSoilHumidity;
      this->highSoilHumidity = highSoilHumidity;
      this->wateringTime     = wateringTime;

      this->log("water-station-configuration-changed", "Changed water station's configuration.");
    }

    void check(){
      if(this->readSoilHumidity() < this->lowSoilHumidity){
        this->water();
      }
    }

    int readSoilHumidity(){
      int value = 100 - map(analogRead(this->soilHumiditySensorPin), 0, 1023, 0, 100);

      this->log("water-station-checked", "Water station's soil humidity checked.", value);

      return value;
    }

    void water(){
      digitalWrite(this->waterPumpPin, HIGH);
      delay(this->wateringTime);
      digitalWrite(this->waterPumpPin, LOW);

      this->log("water-station-watered", "Water station watered.");
    }

    void waterForPrecautionIfPossible(){
      if(this->readSoilHumidity() < this->highSoilHumidity){
        this->water();
      }
    }

  private:

    void log(String event, String message, int soilHumidity = -1){
      const int capacity = JSON_OBJECT_SIZE(16);

      StaticJsonBuffer<capacity> jb;

      JsonObject& obj = jb.createObject();

      obj["event"]        = event;
      obj["message"]      = message;
      obj["stationId"]    = this->uid;

      if(soilHumidity != -1){
        obj["soilHumidity"] = soilHumidity;
      }

      obj.printTo(Serial);
    }
};

class EnvironmentStation
{
  int normalAmbientHumidity  = 40;
  int highAmbientTemperature = 25;
  int maxAmbientTemperature  = 30;

  DHT *dhtSensor;

  public:
    EnvironmentStation(){
    }

    EnvironmentStation(byte pin) {
      this->dhtSensor = new DHT(pin, DHT22);
    }

    void init() {
      (*this->dhtSensor).begin();
    }

    void configure(int normalAmbientHumidity, int highAmbientTemperature, int maxAmbientTemperature) {
      this->normalAmbientHumidity  = normalAmbientHumidity;
      this->highAmbientTemperature = highAmbientTemperature;
      this->maxAmbientTemperature  = maxAmbientTemperature;
    }

    float readTemperature(){
      return (*this->dhtSensor).readTemperature();
    }

    float readHumidity(){
      return (*this->dhtSensor).readHumidity();
    }

    bool checkForHostileEnvironment(){
      float humidity    = this->readHumidity();
      float temperature = this->readTemperature();

      if(isnan(humidity) || isnan(temperature)){
        return false;
      }

      log(humidity, temperature);

      return humidity < this->normalAmbientHumidity && temperature > this->highAmbientTemperature 
          || humidity > this->normalAmbientHumidity && temperature > this->maxAmbientTemperature;
    }


  private:
    void log(float humidity, float temperature){
      const int capacity = JSON_OBJECT_SIZE(16);

      StaticJsonBuffer<capacity> jb;

      JsonObject& obj = jb.createObject();

      obj["event"]       = "environment-station-checked";
      obj["message"]     = "Environment temperature and humidity checked.";
      obj["temperature"] = temperature;
      obj["humidity"]    = humidity;

      obj.printTo(Serial);
    }
};

class IoTGarden
{
  bool                isTurnOn;
  int                 wateringStationsCount;
  WateringStation     wateringStations[2];
  EnvironmentStation  environmentStation;

  int                 checkStationsDelay;

  public:
    IoTGarden() {
      this->isTurnOn              = false;
      this->wateringStationsCount = 0;
      this->checkStationsDelay    = 3000;
    }

    void init(){
      for(int i=0; i < this->wateringStationsCount; i++){
        wateringStations[i].init();
      }

      this->environmentStation.init();
    }

    void work(){
      if (isTurnOn) {
        if(this->environmentStation.checkForHostileEnvironment()){
          for(int i=0; i < this->wateringStationsCount; i++){
            this->wateringStations[i].waterForPrecautionIfPossible();
          }
        }

        for(int i=0; i < this->wateringStationsCount; i++){
          this->wateringStations[i].check();
        }

        delay(this->checkStationsDelay);
      }
    }

    void setEnvironmentStationAt(byte pin){
      this->environmentStation = EnvironmentStation(pin);  
    }

    void addWateringStationAt(byte waterPumpPin, byte soilSensorPin){
      this->wateringStations[this->wateringStationsCount] = WateringStation(this->wateringStationsCount, waterPumpPin, soilSensorPin);
      this->wateringStationsCount++;
    }

    void handleSerialEvent(){

      const int capacity = JSON_OBJECT_SIZE(16);

      StaticJsonBuffer<capacity> jb;

      JsonObject& obj = jb.parseObject(Serial);

      if(obj.success()){
        if(obj["type"] == "turn-on"){
          this->turnOn();
          this->log("turned-on", "IoT Garden turn on!");
        }

        if(obj["type"] == "turn-off"){
          this->turnOff();
          this->log("turned-off", "IoT Garden turn off :(");
        }

        if(obj["type"] == "water-station"){
          this->wateringStations[(int)obj["stationId"]].water();
        }

        if(obj["type"] == "configure-water-station"){
          this->wateringStations[(int)obj["stationId"]].configure(obj["name"], obj["minHumidity"], obj["maxHumidity"], obj["watering"]);
        }

        if(obj["type"] == "configure-environment"){
          this->environmentStation.configure((int)obj["humidity"], (int)obj["temperature"], (int)obj["maxTemperature"]);
          this->log("environment-station-configuration-changed", "Changed environment station's configuration.");
        }

        if(obj["type"] == "configure-system"){
          this->configure((int)obj["checkStationsDelay"]);
          this->log("system-configuration-changed", "Changed system's configuration.");
        }
      }
    }

    private:

      void log(String event, String message){
        const int capacity = JSON_OBJECT_SIZE(16);

        StaticJsonBuffer<capacity> jb;

        JsonObject& obj = jb.createObject();

        obj["event"]        = event;
        obj["message"]      = message;
        
        obj.printTo(Serial);
      }

      void configure(int checkStationsDelay){
        this->checkStationsDelay = checkStationsDelay;
      }

      void turnOn(){
        this->isTurnOn = true;
      }

      void turnOff(){
        this->isTurnOn = false;
      }
};

IoTGarden wateringSystem;

void setup() {
  Serial.begin(9600);

  wateringSystem.addWateringStationAt(2, A2);
  wateringSystem.addWateringStationAt(4, A4);

  wateringSystem.setEnvironmentStationAt(8);

  wateringSystem.init();
}

void loop() {

  wateringSystem.work();
}

void serialEvent() {

  wateringSystem.handleSerialEvent();
}
