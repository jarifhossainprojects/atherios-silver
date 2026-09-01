using System;
using System.Collections.Generic;
using System.IO;
using System.Net.Sockets;
using System.Text;
using System.Threading;

namespace AtheriosServer
{
    public class ConnectedClient
    {
        public string Id { get; set; }
        public string Username { get; set; }
        public TcpClient Socket { get; set; }
        public NetworkStream Stream { get; set; }
        public float X { get; set; }
        public float Y { get; set; }
        public float Z { get; set; }
        public float RotationY { get; set; }
    }

    public class ClientManager
    {
        private List<ConnectedClient> _clients = new List<ConnectedClient>();
        private object _lock = new object();

        public void HandleNewConnection(TcpClient tcpClient)
        {
            Thread clientThread = new Thread(() => ProcessClient(tcpClient));
            clientThread.Start();
        }

        private void ProcessClient(TcpClient tcpClient)
        {
            ConnectedClient client = new ConnectedClient
            {
                Id = Guid.NewGuid().ToString().Substring(0, 8),
                Socket = tcpClient,
                Stream = tcpClient.GetStream()
            };

            StreamReader reader = new StreamReader(client.Stream, Encoding.UTF8);
            StreamWriter writer = new StreamWriter(client.Stream, Encoding.UTF8) { AutoFlush = true };

            try
            {
                while (tcpClient.Connected)
                {
                    string line = reader.ReadLine();
                    if (line == null) break;

                    ParseIncomingPacket(client, line);
                }
            }
            catch
            {
                // Disconnection handled in finally block
            }
            finally
            {
                DisconnectClient(client);
            }
        }

        private void ParseIncomingPacket(ConnectedClient client, string rawJson)
        {
            // Lightweight string parsing for cross-platform network packets
            if (rawJson.Contains("\"type\":\"join\""))
            {
                string name = ExtractJsonValue(rawJson, "username");
                client.Username = string.IsNullOrEmpty(name) ? "Player_" + client.Id : name;
                
                lock (_lock)
                {
                    _clients.Add(client);
                }

                Console.ForegroundColor = ConsoleColor.Yellow;
                Console.WriteLine($"[JOIN] Player '{client.Username}' (ID: {client.Id}) joined the server.");
                Console.ResetColor();

                BroadcastChatMessage("System", $"{client.Username} joined the server.");
                SendWorldDataToClient(client);
            }
            else if (rawJson.Contains("\"type\":\"move\""))
            {
                client.X = float.Parse(ExtractJsonValue(rawJson, "x"));
                client.Y = float.Parse(ExtractJsonValue(rawJson, "y"));
                client.Z = float.Parse(ExtractJsonValue(rawJson, "z"));
                client.RotationY = float.Parse(ExtractJsonValue(rawJson, "rot"));

                // Broadcast live player position and overhead tag to all connected players
                BroadcastPositionUpdate(client);
            }
            else if (rawJson.Contains("\"type\":\"chat\""))
            {
                string msg = ExtractJsonValue(rawJson, "msg");
                Console.WriteLine($"[CHAT] [{client.Username}]: {msg}");
                BroadcastChatMessage(client.Username, msg);
            }
            else if (rawJson.Contains("\"type\":\"block_place\""))
            {
                int x = int.Parse(ExtractJsonValue(rawJson, "x"));
                int y = int.Parse(ExtractJsonValue(rawJson, "y"));
                int z = int.Parse(ExtractJsonValue(rawJson, "z"));
                int blockId = int.Parse(ExtractJsonValue(rawJson, "id"));

                Program.World.UpdateBlock(x, y, z, blockId);
                BroadcastBlockChange(x, y, z, blockId);
            }
        }

        public void BroadcastChatMessage(string sender, string text)
        {
            string packet = $"{{\"type\":\"chat\",\"sender\":\"{sender}\",\"msg\":\"{text}\"}}";
            SendToAll(packet);
        }

        public void BroadcastPositionUpdate(ConnectedClient updatedClient)
        {
            string packet = $"{{\"type\":\"player_move\",\"id\":\"{updatedClient.Id}\",\"username\":\"{updatedClient.Username}\",\"x\":{updatedClient.X},\"y\":{updatedClient.Y},\"z\":{updatedClient.Z},\"rot\":{updatedClient.RotationY}}}";
            SendToAllExcept(packet, updatedClient.Id);
        }

        public void BroadcastBlockChange(int x, int y, int z, int blockId)
        {
            string packet = $"{{\"type\":\"block_update\",\"x\":{x},\"y\":{y},\"z\":{z},\"id\":{blockId}}}";
            SendToAll(packet);
        }

        private void SendWorldDataToClient(ConnectedClient client)
        {
            // Stream active world blocks to client upon joining
        }

        private void SendToAll(string data)
        {
            lock (_lock)
            {
                foreach (var c in _clients)
                {
                    try
                    {
                        StreamWriter writer = new StreamWriter(c.Stream, Encoding.UTF8) { AutoFlush = true };
                        writer.WriteLine(data);
                    }
                    catch { }
                }
            }
        }

        private void SendToAllExcept(string data, string excludeId)
        {
            lock (_lock)
            {
                foreach (var c in _clients)
                {
                    if (c.Id != excludeId)
                    {
                        try
                        {
                            StreamWriter writer = new StreamWriter(c.Stream, Encoding.UTF8) { AutoFlush = true };
                            writer.WriteLine(data);
                        }
                        catch { }
                    }
                }
            }
        }

        private void DisconnectClient(ConnectedClient client)
        {
            lock (_lock)
            {
                if (_clients.Contains(client))
                {
                    _clients.Remove(client);
                    Console.ForegroundColor = ConsoleColor.DarkYellow;
                    Console.WriteLine($"[LEAVE] Player '{client.Username}' disconnected.");
                    Console.ResetColor();
                    BroadcastChatMessage("System", $"{client.Username} left the server.");
                }
            }
        }

        private string ExtractJsonValue(string json, string key)
        {
            try
            {
                string searchKey = $"\"{key}\":";
                int start = json.IndexOf(searchKey);
                if (start == -1) return "";
                start += searchKey.Length;
                
                if (json[start] == '"')
                {
                    start++;
                    int end = json.IndexOf('"', start);
                    return json.Substring(start, end - start);
                }
                else
                {
                    int end = json.IndexOfAny(new char[] { ',', '}' }, start);
                    return json.Substring(start, end - start);
                }
            }
            catch
            {
                return "";
            }
        }
    }
}