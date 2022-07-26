#include <DHTesp.h>

#include <ESP8266WiFi.h>
#include <WiFiClientSecure.h>
#include <UniversalTelegramBot.h>
#include <DHT.h>

// Wifi network station credentials
#define WIFI_SSID "LANCOMBEIA"
#define WIFI_PASSWORD "beialancom"

// Telegram BOT Token (Get from Botfather)
#define BOT_TOKEN "5578453394:AAG1_bdYDPmdKWUYmdtAC1cSwWoihPjx0XU"

DHT dht(2, DHT11);
const unsigned long BOT_MTBS = 1000; // mean time between scan messages

unsigned long bot_lasttime; // last time messages' scan has been done
X509List cert(TELEGRAM_CERTIFICATE_ROOT);
WiFiClientSecure secured_client;
UniversalTelegramBot bot(BOT_TOKEN, secured_client);

void bot_setup()
{
  const String commands = F("["
                            "{\"command\":\"help\",  \"description\":\"Get bot usage help\"},"
                            "{\"command\":\"start\", \"description\":\"Message sent when you open a chat with a bot\"},"
                             "{\"command\":\"temperature\", \"description\":\"Message sent when you open a chat with a bot\"},"
                             "{\"command\":\"humidity\", \"description\":\"Message sent when you open a chat with a bot\"},"
                             "{\"command\":\"both\", \"description\":\"Message sent when you open a chat with a bot\"},"
                            "{\"command\":\"status\",\"description\":\"Answer device current status\"}" // no comma on last command
                            "]");
  bot.setMyCommands(commands);
  //bot.sendMessage("25235518", "Hola amigo!", "Markdown");
}

void setup()
{
  Serial.begin(115200);
  Serial.println();

  // attempt to connect to Wifi network:
  configTime(0, 0, "pool.ntp.org");      // get UTC time via NTP
  secured_client.setTrustAnchors(&cert); // Add root certificate for api.telegram.org
  Serial.print("Connecting to Wifi SSID ");
  Serial.print(WIFI_SSID);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED)
  {
    Serial.print(".");
    delay(500);
  }
  Serial.print("\nWiFi connected. IP address: ");
  Serial.println(WiFi.localIP());

  // Check NTP/Time, usually it is instantaneous and you can delete the code below.
  Serial.print("Retrieving time: ");
  time_t now = time(nullptr);
  while (now < 24 * 3600)
  {
    Serial.print(".");
    delay(100);
    now = time(nullptr);
  }
  Serial.println(now);
 dht.begin();
  bot_setup();
}

void loop()
{   
  float humidity = dht.readHumidity();
  float temperature = dht.readTemperature();
  float f = dht.readTemperature(true);

  // Check if any reads failed and exit early (to try again).
  if (isnan(humidity ) || isnan(temperature) || isnan(f)) {
    Serial.println(F("Failed to read from DHT sensor!"));
    return;
  }

  Serial.println(F("Humidity: "));
  Serial.print(humidity);
  Serial.print("%");
  Serial.println(F(" Temperature: "));
  Serial.print(temperature);
  Serial.print(F("°C "));
  
  if (millis() - bot_lasttime > BOT_MTBS)
  {
    int numNewMessages = bot.getUpdates(bot.last_message_received + 1);

    while (numNewMessages)
    {
      Serial.println("got response");
      Serial.print("handleNewMessages ");
  Serial.println(numNewMessages);
  
  String answer;
  for (int i = 0; i < numNewMessages; i++)
  {
    telegramMessage &msg = bot.messages[i];
    Serial.println("Received " + msg.text);
    if (msg.text == "/help")
      answer = "So you need help, uh? me too! use /start or /status";
    else if (msg.text == "/start")
      {answer = "Welcome my new friend*" + msg.from_name + "*"+"\n If you need temparature taste: temperature \n If you need humidity taste: humidity";}
    else if (msg.text == "/temperature")
      answer = "Temperature: " + String(temperature) + " °C";
     else if (msg.text == "/humidity")
      answer = "Humidity: " + String(humidity) + " %RH";
     else if (msg.text == "/both")
      answer = "Humidity: " + String(humidity) + " %RH" + "\n Temperature: " + String(temperature) + " °C";
    else
      answer = "Say what?";

    bot.sendMessage(msg.chat_id, answer, "Markdown");
  }
      numNewMessages = bot.getUpdates(bot.last_message_received + 1);
    }

    bot_lasttime = millis();
  }
}
