using System;
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading;

namespace AtheriosServer
{
    class Program
    {
        public static string Version = "Atherios Silver Server v1.0";
        public static ServerConfig Config;
        public static WorldState World;
        public static ClientManager Clients;
        private static TcpListener _listener;
        private static bool _isRunning = true;

        static void Main(string[] args)
        {
            Console.Title = "Atherios Silver - Dedicated Server Console";
            Console.ForegroundColor = ConsoleColor.Cyan;
            Console.WriteLine("==================================================");
            Console.WriteLine($"   {Version}");
            Console.WriteLine("==================================================");
            Console.ResetColor();

            // 1. Load configuration files
            Config = ServerConfig.Load("server.properties");
            Console.WriteLine($"[INIT] Server Name: {Config.ServerName}");
            Console.WriteLine($"[INIT] Max Players: {Config.MaxPlayers}");
            Console.WriteLine($"[INIT] Listening Port: {Config.Port}");

            // 2. Fetch and display Local IP address for host sharing
            string localIp = GetLocalIPAddress();
            Console.ForegroundColor = ConsoleColor.Green;
            Console.WriteLine("--------------------------------------------------");
            Console.WriteLine($" [SERVER READY] Connect using IP: {localIp}:{Config.Port}");
            Console.WriteLine($" Share this IP address ({localIp}) with friends!");
            Console.WriteLine("--------------------------------------------------");
            Console.ResetColor();

            // 3. Initialize World Manager and Load/Create map files
            World = new WorldState();
            World.InitializeWorld();

            // 4. Initialize Client Connection Manager
            Clients = new ClientManager();

            // 5. Start TCP Network Socket Listener Loop
            try
            {
                _listener = new TcpListener(IPAddress.Any, Config.Port);
                _listener.Start();
                Console.WriteLine($"[NETWORK] Listening for incoming player packets...");

                // Start separate background thread for processing console commands
                Thread commandThread = new Thread(ConsoleCommandLoop);
                commandThread.Start();

                // Main Connection Loop
                while (_isRunning)
                {
                    TcpClient client = _listener.AcceptTcpClient();
                    Clients.HandleNewConnection(client);
                }
            }
            catch (Exception ex)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine($"[ERROR] Server socket failure: {ex.Message}");
                Console.ResetColor();
            }
        }

        private static string GetLocalIPAddress()
        {
            try
            {
                var host = Dns.GetHostEntry(Dns.GetHostName());
                foreach (var ip in host.AddressList)
                {
                    if (ip.AddressFamily == AddressFamily.InterNetwork)
                    {
                        return ip.ToString();
                    }
                }
            }
            catch
            {
                // Fallback IP string
            }
            return "127.0.0.1";
        }

        private static void ConsoleCommandLoop()
        {
            while (_isRunning)
            {
                string input = Console.ReadLine();
                if (string.IsNullOrEmpty(input)) continue;

                if (input.Equals("stop", StringComparison.OrdinalIgnoreCase))
                {
                    Console.WriteLine("[SERVER] Shutting down server and saving world...");
                    World.SaveWorld();
                    _isRunning = false;
                    Environment.Exit(0);
                }
                else if (input.Equals("save", StringComparison.OrdinalIgnoreCase))
                {
                    World.SaveWorld();
                }
                else if (input.StartsWith("say ", StringComparison.OrdinalIgnoreCase))
                {
                    string msg = input.Substring(4);
                    Clients.BroadcastChatMessage("[SERVER]", msg);
                }
            }
        }
    }
}