﻿using System;
using System.IO;
using Newtonsoft.Json;


namespace lootBoss
{
    class Config
    {
        private const string configFolder = "Resources";
        private const string configFile = "config.json";
        public static BotConfig bot;

        static Config()
        {
            if (!Directory.Exists(configFolder))
            {
                Console.WriteLine("..Creating /resources..");
                Directory.CreateDirectory(configFolder);
            }
            if(!File.Exists(configFolder + "/" + configFile))
            {
                bot = new BotConfig();
                string json = JsonConvert.SerializeObject(bot, Formatting.Indented);
                File.WriteAllText(configFolder + "/" + configFile, json);
            }
            else
            {
                string json = File.ReadAllText(configFolder + "/" + configFile);
                bot = JsonConvert.DeserializeObject<BotConfig>(json);
            }
        }
    }
    public struct BotConfig
    {
        public string token;
        public string discordChannel;
        public string cmdPrefix;
    }
}
