using System;
using System.IO;

namespace AtheriosServer
{
    public class WorldState
    {
        public const int SizeX = 128;
        public const int SizeY = 32;
        public const int SizeZ = 128;
        
        private byte[,,] _blocks = new byte[SizeX, SizeY, SizeZ];
        private string _worldDirectory = "worlds";
        private string _worldFilePath = "worlds/world.dat";

        public void InitializeWorld()
        {
            if (!Directory.Exists(_worldDirectory))
            {
                Directory.CreateDirectory(_worldDirectory);
            }

            if (File.Exists(_worldFilePath))
            {
                Console.WriteLine("[WORLD] Loading existing world map from 'worlds/world.dat'...");
                LoadWorld();
            }
            else
            {
                Console.WriteLine("[WORLD] Creating brand-new 3D Voxel World terrain...");
                GenerateDefaultTerrain();
                SaveWorld();
            }
        }

        private void GenerateDefaultTerrain()
        {
            for (int x = 0; x < SizeX; x++)
            {
                for (int z = 0; z < SizeZ; z++)
                {
                    _blocks[x, 0, z] = 1; // Grass Surface
                    _blocks[x, 1, z] = 2; // Dirt Layer
                    _blocks[x, 2, z] = 3; // Stone Base

                    // Tree spawning logic
                    if (x % 10 == 0 && z % 10 == 0)
                    {
                        _blocks[x, 3, z] = 4; // Trunk
                        _blocks[x, 4, z] = 4;
                        _blocks[x, 5, z] = 5; // Leaves
                    }
                }
            }
            Console.WriteLine("[WORLD] New world generated with Grass, Trees, and Stone!");
        }

        public void UpdateBlock(int x, int y, int z, int blockId)
        {
            if (x >= 0 && x < SizeX && y >= 0 && y < SizeY && z >= 0 && z < SizeZ)
            {
                _blocks[x, y, z] = (byte)blockId;
            }
        }

        public void SaveWorld()
        {
            try
            {
                using (FileStream fs = new FileStream(_worldFilePath, FileMode.Create, FileAccess.Write))
                using (BinaryWriter writer = new BinaryWriter(fs))
                {
                    for (int x = 0; x < SizeX; x++)
                    {
                        for (int y = 0; y < SizeY; y++)
                        {
                            for (int z = 0; z < SizeZ; z++)
                            {
                                writer.Write(_blocks[x, y, z]);
                            }
                        }
                    }
                }
                Console.WriteLine("[WORLD] Map progress saved to disk.");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[ERROR] Failed to save world file: {ex.Message}");
            }
        }

        private void LoadWorld()
        {
            try
            {
                using (FileStream fs = new FileStream(_worldFilePath, FileMode.Open, FileAccess.Read))
                using (BinaryReader reader = new BinaryReader(fs))
                {
                    for (int x = 0; x < SizeX; x++)
                    {
                        for (int y = 0; y < SizeY; y++)
                        {
                            for (int z = 0; z < SizeZ; z++)
                            {
                                _blocks[x, y, z] = reader.ReadByte();
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[ERROR] Failed to load world file: {ex.Message}");
            }
        }
    }
}