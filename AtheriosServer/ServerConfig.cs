using System;
using System.IO;

namespace AtheriosServer
{
    public class ServerConfig
    {
        public string ServerName { get; set; } = "Atherios Official Server";
        public int Port { get; set; } = 7777;
        public int MaxPlayers { get; set; } = 16;
        public string WorldSeed { get; set; } = "AtheriosSilverSeed";

        public static ServerConfig Load(string path)
        {
            ServerConfig config = new ServerConfig();

            if (!File.Exists(path))
            {
                // Create default server.properties file if missing
                string defaultText = "server_name=Atherios Official Server\n" +
                                    "server_port=7777\n" +
                                    "max_players=16\n" +
                                    "world_seed=AtheriosSilverSeed\n";
                File.WriteAllText(path, defaultText);
                return config;
            }

            string[] lines = File.ReadAllLines(path);
            foreach (var line in lines)
            {
                if (line.StartsWith("#") || !line.Contains("=")) continue;

                var parts = line.Split('=');
                string key = parts[0].Trim();
                string val = parts[1].Trim();

                if (key == "server_name") config.ServerName = val;
                if (key == "server_port") config.Port = int.Parse(val);
                if (key == "max_players") config.MaxPlayers = int.Parse(val);
                if (key == "world_seed") config.WorldSeed = val;
            }

            return config;
        }
    }
}