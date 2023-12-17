#include <Arduino.h>
#include <BLEPeripheral.h>

BLEPeripheral blePeripheral;

BLEService ledService("19b10000e8f2537e4f6cd104768a1214");
BLECharCharacteristic ledCharacteristic("19b10001e8f2537e4f6cd104768a1214", BLERead | BLEWrite);

void setup()
{
  Serial.begin(115200);
  pinMode(LED_BUILTIN, OUTPUT);

  blePeripheral.setLocalName("Grupo 4");
  blePeripheral.setAdvertisedServiceUuid(ledService.uuid());
  blePeripheral.addAttribute(ledService);
  blePeripheral.addAttribute(ledCharacteristic);
  blePeripheral.begin();
}

void loop()
{
  BLECentral central = blePeripheral.central();

  if (central)
  {
    Serial.print("Connected to central: ");
    Serial.println(central.address());

    while (central.connected())
    {
      // Envía el número 42 constantemente
      int numberToSend = 42;
      ledCharacteristic.setValue(numberToSend);

      delay(1000); // Espera 1 segundo antes de enviar el siguiente valor
    }

    Serial.print("Disconnected from central: ");
    Serial.println(central.address());
  }
}
