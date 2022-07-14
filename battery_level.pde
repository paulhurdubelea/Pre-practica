#include <WaspFrame.h>
#include <WaspSensorAgr_v30.h>
#include <WaspWIFI_PRO_V3.h>
#include <WaspFrameConstantsv12.h>

// WiFi AP settings (CHANGE TO USER'S AP)
char SSID[] = "LANCOMBEIA";
char PASSW[] = "beialancom";

// choose socket (SELECT USER'S SOCKET)
uint8_t socket = SOCKET0;

// choose HTTP server settings
char type[] = "http";
char host[] = "82.78.81.178";
uint16_t port = 80;

uint8_t error;
uint8_t status;
unsigned long previous;

// define the Waspmote ID
char moteID[] = "Hurdubelea_Paul";

void setup()
{
  USB.ON();
  // 1. Switch ON the WiFi module
  error = WIFI_PRO_V3.ON(socket);

  if (error == 0)
  {
    USB.println(F("1. WiFi switched ON"));
  }
  else
  {
    USB.println(F("1. WiFi did not initialize correctly"));
  }

  // 2. Reset to default values
  error = WIFI_PRO_V3.resetValues();

  if (error == 0)
  {
    USB.println(F("2. WiFi reset to default"));
  }
  else
  {
    USB.print(F("2. WiFi reset to default error: "));
    USB.println(error, DEC);
  }

  // 3. Configure mode (Station or AP)
  error = WIFI_PRO_V3.configureMode(WaspWIFI_v3::MODE_STATION);

  if (error == 0)
  {
    USB.println(F("3. WiFi configured OK"));
  }
  else
  {
    USB.print(F("3. WiFi configured error: "));
    USB.println(error, DEC);
  }

  // get current time
  previous = millis();

  // 4. Configure SSID and password and autoconnect
  error = WIFI_PRO_V3.configureStation(SSID, PASSW, WaspWIFI_v3::AUTOCONNECT_ENABLED);

  if (error == 0)
  {
    USB.println(F("4. WiFi configured SSID OK"));
  }
  else
  {
    USB.print(F("4. WiFi configured SSID error: "));
    USB.println(error, DEC);
  }

  if (error == 0)
  {
    USB.println(F("5. WiFi connected to AP OK"));

    USB.print(F("SSID: "));
    USB.println(WIFI_PRO_V3._essid);
    
    USB.print(F("Channel: "));
    USB.println(WIFI_PRO_V3._channel, DEC);

    USB.print(F("Signal strength: "));
    USB.print(WIFI_PRO_V3._power, DEC);
    USB.println("dB");

    USB.print(F("IP address: "));
    USB.println(WIFI_PRO_V3._ip);

    USB.print(F("GW address: "));
    USB.println(WIFI_PRO_V3._gw);

    USB.print(F("Netmask address: "));
    USB.println(WIFI_PRO_V3._netmask);

    WIFI_PRO_V3.getMAC();

    USB.print(F("MAC address: "));
    USB.println(WIFI_PRO_V3._mac);
  }
  else
  {
    USB.print(F("5. WiFi connect error: "));
    USB.println(error, DEC);

    USB.print(F("Disconnect status: "));
    USB.println(WIFI_PRO_V3._status, DEC);

    USB.print(F("Disconnect reason: "));
    USB.println(WIFI_PRO_V3._reason, DEC);

    
  }
  // Set the Waspmote ID
  frame.setID(moteID);
}

void loop()
{
  USB.println(RTC.getTime());

  //Switch ON
  error = WIFI_PRO_V3.ON(socket);

  if (error == 0)
  {
    USB.println(F("WiFi switched ON"));
  }
  else
  {
    USB.println(F("WiFi did not initialize correctly"));
  }

  // check connectivity
  status =  WIFI_PRO_V3.isConnected();
  
    // switch on sensor board
    Agriculture.ON();
    USB.print(F("Time:"));
    USB.println(RTC.getTime());

  // Create new frame (ASCII)
  frame.createFrame(ASCII);
  frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel() );

  // Show the frame
  frame.showFrame();

  // wait 2 seconds
  delay(2000);

  // check if module is connected
  if (status == true)
  {
    //Send Frame to Meshlium
    //http frame
    error = WIFI_PRO_V3.sendFrameToMeshlium( type, host, port, frame.buffer, frame.length);

    // check response
    if (error == 0)
    {
      USB.println(F("Send frame to meshlium done"));
    }
    else
    {
      USB.println(F("Error sending frame"));
      if (WIFI_PRO_V3._httpResponseStatus)
      {
        USB.print(F("HTTP response status: "));
        USB.println(WIFI_PRO_V3._httpResponseStatus);
      }
    }
  }
  else
  {
    USB.print(F("2. WiFi is connected ERROR"));
  }

  //Switch OFF
  WIFI_PRO_V3.OFF(socket);
  USB.println(F("WiFi switched OFF\n\n"));
  USB.println(F("---------------------------------"));
  USB.println(F("...Enter deep sleep mode 30 sec "));
  PWR.deepSleep("00:00:00:30", RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);
  USB.ON();
  USB.print(F("...wake up!! Date: "));
  USB.println(RTC.getTime());
  //  RTC.setWatchdog(720); // 12h in minutes
  //  USB.print(F("...Watchdog :"));
  //  USB.println(RTC.getWatchdog());
  USB.println(F("****************************************"));
}
  // put your main code here, to run repeatedly:
}
