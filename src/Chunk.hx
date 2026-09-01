package;

import away3d.containers.ObjectContainer3D;
import away3d.entities.Mesh;
import away3d.materials.TextureMaterial;
import away3d.textures.BitmapTexture;
import away3d.primitives.CubeGeometry;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.geom.Point;
import openfl.Assets;

class Chunk extends ObjectContainer3D {
    public static inline var CHUNK_SIZE:Int = 16;
    public static inline var CHUNK_HEIGHT:Int = 32;

    private var blocks:Array<Array<Array<Int>>>;
    private var grassMaterial:TextureMaterial;
    private var dirtMaterial:TextureMaterial;
    private var stoneMaterial:TextureMaterial;
    private var woodMaterial:TextureMaterial;
    private var leavesMaterial:TextureMaterial;

    public function new(chunkX:Int, chunkZ:Int) {
        super();
        this.x = chunkX * CHUNK_SIZE * 100;
        this.z = chunkZ * CHUNK_SIZE * 100;

        initMaterials();
        generateChunkData();
        buildMesh();
    }

    private function initMaterials():Void {
        // 1. Obtain master texture atlas (Check disk file first, fallback to TextureGenerator)
        var atlasData:BitmapData;
        if (Assets.exists("assets/textures/terrain.png")) {
            atlasData = Assets.getBitmapData("assets/textures/terrain.png");
        } else {
            atlasData = TextureGenerator.createTerrainAtlas();
        }

        // 2. Crop individual 16x16 sub-textures for distinct material assignment
        var grassBmd:BitmapData = extractTile(atlasData, 0, 0); // Slot 0: Atherios Grass Top
        var soilBmd:BitmapData  = extractTile(atlasData, 2, 0); // Slot 2: Elemental Soil
        var slateBmd:BitmapData = extractTile(atlasData, 3, 0); // Slot 3: Aether Slate
        var woodBmd:BitmapData  = extractTile(atlasData, 4, 0); // Slot 4: Mahogany Bark
        var leafBmd:BitmapData  = extractTile(atlasData, 6, 0); // Slot 6: Aether Leaves

        // 3. Construct Stage3D Texture Materials
        grassMaterial = new TextureMaterial(new BitmapTexture(grassBmd));
        dirtMaterial  = new TextureMaterial(new BitmapTexture(soilBmd));
        stoneMaterial = new TextureMaterial(new BitmapTexture(slateBmd));
        woodMaterial  = new TextureMaterial(new BitmapTexture(woodBmd));
        leavesMaterial= new TextureMaterial(new BitmapTexture(leafBmd));
    }

    private function extractTile(sourceAtlas:BitmapData, tileX:Int, tileY:Int):BitmapData {
        var tileBmd:BitmapData = new BitmapData(16, 16, true, 0x00000000);
        var sourceRect:Rectangle = new Rectangle(tileX * 16, tileY * 16, 16, 16);
        tileBmd.copyPixels(sourceAtlas, sourceRect, new Point(0, 0));
        return tileBmd;
    }

    private function generateChunkData():Void {
        blocks = [for (x in 0...CHUNK_SIZE) [for (y in 0...CHUNK_HEIGHT) [for (z in 0...CHUNK_SIZE) 0]]];

        for (x in 0...CHUNK_SIZE) {
            for (z in 0...CHUNK_SIZE) {
                // Surface terrain heightmap calculation
                blocks[x][0][z] = 1; // Grass Top
                blocks[x][1][z] = 2; // Elemental Soil Sub-layer
                blocks[x][2][z] = 3; // Aether Slate Bedrock Layer

                // Tree Generation Logic inside Chunk
                if (x == 8 && z == 8) {
                    blocks[x][3][z] = 4; // Mahogany Trunk
                    blocks[x][4][z] = 4;
                    blocks[x][5][z] = 5; // Aether Leaves
                }
            }
        }
    }

    public function buildMesh():Void {
        // Clear old 3D children before re-building mesh
        while (numChildren > 0) {
            removeChildAt(0);
        }

        var cubeGeo:CubeGeometry = new CubeGeometry(100, 100, 100);

        for (x in 0...CHUNK_SIZE) {
            for (y in 0...CHUNK_HEIGHT) {
                for (z in 0...CHUNK_SIZE) {
                    var blockType:Int = blocks[x][y][z];
                    if (blockType == 0) continue; // Skip air blocks

                    // Face Culling Optimization: Check if block face is hidden by adjacent block
                    if (isBlockExposed(x, y, z)) {
                        var mat:TextureMaterial = getMaterialForBlock(blockType);
                        var blockMesh:Mesh = new Mesh(cubeGeo, mat);
                        
                        blockMesh.x = x * 100;
                        blockMesh.y = y * 100;
                        blockMesh.z = z * 100;

                        addChild(blockMesh);
                    }
                }
            }
        }
    }

    private function isBlockExposed(x:Int, y:Int, z:Int):Bool {
        if (x == 0 || x == CHUNK_SIZE - 1 || y == 0 || y == CHUNK_HEIGHT - 1 || z == 0 || z == CHUNK_SIZE - 1) return true;
        
        // Render if any neighboring block is Air (ID 0)
        return (blocks[x + 1][y][z] == 0 || blocks[x - 1][y][z] == 0 ||
                blocks[x][y + 1][z] == 0 || blocks[x][y - 1][z] == 0 ||
                blocks[x][y][z + 1] == 0 || blocks[x][y][z - 1] == 0);
    }

    private function getMaterialForBlock(type:Int):TextureMaterial {
        return switch (type) {
            case 1: grassMaterial;
            case 2: dirtMaterial;
            case 3: stoneMaterial;
            case 4: woodMaterial;
            case 5: leavesMaterial;
            default: grassMaterial;
        };
    }

    public function setBlock(x:Int, y:Int, z:Int, type:Int):Void {
        if (x >= 0 && x < CHUNK_SIZE && y >= 0 && y < CHUNK_HEIGHT && z >= 0 && z < CHUNK_SIZE) {
            blocks[x][y][z] = type;
            buildMesh(); // Re-render chunk mesh on block change
        }
    }
}