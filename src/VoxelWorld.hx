package;

import flixel.FlxBasic;

class VoxelWorld extends FlxBasic {
    private var mapSizeX:Int = 128;
    private var mapSizeZ:Int = 128;
    private var mapHeight:Int = 32;
    
    // 3D Matrix array storing block IDs [0 = Air, 1 = Grass, 2 = Dirt, 3 = Stone, 4 = Wood, 5 = Leaves]
    private var worldGrid:Array<Array<Array<Int>>>;

    public function new() {
        super();
        generateTerrain();
    }

    private function generateTerrain():Void {
        worldGrid = [for (x in 0...mapSizeX) [for (y in 0...mapHeight) [for (z in 0...mapSizeZ) 0]]];

        for (x in 0...mapSizeX) {
            for (z in 0...mapSizeZ) {
                // Surface Layer
                worldGrid[x][0][z] = 1; // Grass
                worldGrid[x][1][z] = 2; // Dirt
                worldGrid[x][2][z] = 3; // Stone
                
                // Random Tree Generation Algorithm
                if (x % 8 == 0 && z % 8 == 0 && Math.random() > 0.4) {
                    spawnTree(x, 1, z);
                }
            }
        }
    }

    private function spawnTree(trunkX:Int, trunkY:Int, trunkZ:Int):Void {
        // Wood Trunk
        for (i in 0...4) {
            worldGrid[trunkX][trunkY + i][trunkZ] = 4;
        }
        // Leaf Canopy
        worldGrid[trunkX][trunkY + 4][trunkZ] = 5;
        worldGrid[trunkX + 1][trunkY + 3][trunkZ] = 5;
        worldGrid[trunkX - 1][trunkY + 3][trunkZ] = 5;
    }

    public function placeBlockAt(pos:Array<Int>, blockType:Int):Void {
        if (isValidCoord(pos[0], pos[1], pos[2])) {
            worldGrid[pos[0]][pos[1]][pos[2]] = blockType;
        }
    }

    public function breakBlockAt(pos:Array<Int>):Void {
        if (isValidCoord(pos[0], pos[1], pos[2])) {
            worldGrid[pos[0]][pos[1]][pos[2]] = 0; // Air
        }
    }

    private function isValidCoord(x:Int, y:Int, z:Int):Bool {
        return (x >= 0 && x < mapSizeX && y >= 0 && y < mapHeight && z >= 0 && z < mapSizeZ);
    }
}