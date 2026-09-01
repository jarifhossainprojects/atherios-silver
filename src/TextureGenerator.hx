package;

import openfl.display.BitmapData;
import openfl.geom.Rectangle;

class TextureGenerator {

    // Generates a complete 256x256 Texture Atlas with Atherios Silver's unique aesthetic
    public static function createTerrainAtlas():BitmapData {
        var atlas:BitmapData = new BitmapData(256, 256, true, 0x00000000);

        // Slot 0: Atherios Silver Grass Top (Electric cyan-emerald dithered terrain)
        drawAtheriosGrassTop(atlas, 0, 0);

        // Slot 1: Atherios Grass Side (Layered crystal fringe over rich soil)
        drawAtheriosGrassSide(atlas, 1, 0);

        // Slot 2: Deep Soil (Dark violet-brown elemental earth)
        drawElementalSoil(atlas, 2, 0);

        // Slot 3: Aether Slate / Stone (Crystalline blue-grey stone with silver veins)
        drawAetherSlate(atlas, 3, 0);

        // Slot 4: Mahogany Bark (Dark ironwood trunk with vertical silver grooves)
        drawMahoganyBark(atlas, 4, 0);

        // Slot 5: Core Rings (Glowing silver core center)
        drawMahoganyCore(atlas, 5, 0);

        // Slot 6: Aether Leaves (Geometric glowing foliage with alpha cutouts)
        drawAetherLeaves(atlas, 6, 0);

        // Slot 7: Sky & Silver Clouds Pattern
        drawAetherSky(atlas, 7, 0);

        return atlas;
    }

    // 1. Atherios Grass Top (Cyan-tinted vibrant turf)
    private static function drawAtheriosGrassTop(bd:BitmapData, tileX:Int, tileY:Int):Void {
        var startX:Int = tileX * 16;
        var startY:Int = tileY * 16;

        var baseTurf:Int = 0xFF2EBD85;
        var darkTurf:Int = 0xFF1C7A54;
        var silverHighlight:Int = 0xFF73ECC1;

        fill16x16(bd, startX, startY, baseTurf);

        for (py in 0...16) {
            for (px in 0...16) {
                if ((px * 3 + py * 7) % 4 == 0) bd.setPixel32(startX + px, startY + py, darkTurf);
                if ((px + py) % 6 == 0) bd.setPixel32(startX + px, startY + py, silverHighlight);
            }
        }
    }

    // 2. Atherios Grass Side (Dripping energy fringe over soil)
    private static function drawAtheriosGrassSide(bd:BitmapData, tileX:Int, tileY:Int):Void {
        var startX:Int = tileX * 16;
        var startY:Int = tileY * 16;

        // Base elemental soil under layer
        drawElementalSoil(bd, tileX, tileY);

        var baseTurf:Int = 0xFF2EBD85;
        var silverHighlight:Int = 0xFF73ECC1;

        // Custom triangular grass drip pattern
        for (px in 0...16) {
            var depth:Int = 3 + ((px % 4 == 0) ? 3 : 0) + ((px % 2 == 0) ? 1 : 0);
            for (py in 0...depth) {
                var col:Int = (py == depth - 1) ? silverHighlight : baseTurf;
                bd.setPixel32(startX + px, startY + py, col);
            }
        }
    }

    // 3. Elemental Soil (Dark rich violet-tinged earth)
    private static function drawElementalSoil(bd:BitmapData, tileX:Int, tileY:Int):Void {
        var startX:Int = tileX * 16;
        var startY:Int = tileY * 16;

        var baseSoil:Int = 0xFF4A3B52;
        var darkSoil:Int = 0xFF2D2333;
        var crystalSpeck:Int = 0xFF70597D;

        fill16x16(bd, startX, startY, baseSoil);

        for (py in 0...16) {
            for (px in 0...16) {
                if ((px * 5 + py * 11) % 7 == 0) bd.setPixel32(startX + px, startY + py, darkSoil);
                if ((px * 13 + py * 3) % 13 == 0) bd.setPixel32(startX + px, startY + py, crystalSpeck);
            }
        }
    }

    // 4. Aether Slate / Stone (Blue-grey rock with silver ore seams)
    private static function drawAetherSlate(bd:BitmapData, tileX:Int, tileY:Int):Void {
        var startX:Int = tileX * 16;
        var startY:Int = tileY * 16;

        var baseSlate:Int = 0xFF526173;
        var darkSlate:Int = 0xFF313B47;
        var silverVein:Int = 0xFFC0D0E0;

        fill16x16(bd, startX, startY, baseSlate);

        for (py in 0...16) {
            for (px in 0...16) {
                if (px == py || px == (py + 4) % 16) {
                    bd.setPixel32(startX + px, startY + py, darkSlate);
                }
                // Silver ore flecks embedded in stone
                if ((px == 3 && py == 5) || (px == 11 && py == 12) || (px == 8 && py == 2)) {
                    bd.setPixel32(startX + px, startY + py, silverVein);
                }
            }
        }
    }

    // 5. Mahogany Bark (Dark wood with metallic silver grooves)
    private static function drawMahoganyBark(bd:BitmapData, tileX:Int, tileY:Int):Void {
        var startX:Int = tileX * 16;
        var startY:Int = tileY * 16;

        var baseBark:Int = 0xFF3D2727;
        var deepBark:Int = 0xFF241515;
        var silverGrain:Int = 0xFF8C7B83;

        fill16x16(bd, startX, startY, baseBark);

        for (px in 0...16) {
            if (px % 4 == 0) {
                for (py in 0...16) bd.setPixel32(startX + px, startY + py, deepBark);
            } else if (px % 4 == 2) {
                for (py in 0...16) bd.setPixel32(startX + px, startY + py, silverGrain);
            }
        }
    }

    // 6. Core Rings (Ironwood cross-section with glowing core)
    private static function drawMahoganyCore(bd:BitmapData, tileX:Int, tileY:Int):Void {
        var startX:Int = tileX * 16;
        var startY:Int = tileY * 16;

        var outerBark:Int = 0xFF241515;
        var woodBody:Int = 0xFF523B3B;
        var silverCore:Int = 0xFFE0F0FF;

        fill16x16(bd, startX, startY, woodBody);

        // Outer rim
        for (i in 0...16) {
            bd.setPixel32(startX + i, startY, outerBark);
            bd.setPixel32(startX + i, startY + 15, outerBark);
            bd.setPixel32(startX, startY + i, outerBark);
            bd.setPixel32(startX + 15, startY + i, outerBark);
        }

        // Center glowing silver heartwood
        bd.setPixel32(startX + 7, startY + 7, silverCore);
        bd.setPixel32(startX + 8, startY + 7, silverCore);
        bd.setPixel32(startX + 7, startY + 8, silverCore);
        bd.setPixel32(startX + 8, startY + 8, silverCore);
    }

    // 7. Aether Leaves (Crystal geometric foliage)
    private static function drawAetherLeaves(bd:BitmapData, tileX:Int, tileY:Int):Void {
        var startX:Int = tileX * 16;
        var startY:Int = tileY * 16;

        var leafBase:Int = 0xFF1976D2;
        var leafLight:Int = 0xFF64B5F6;
        var leafDark:Int = 0xFF0D47A1;

        fill16x16(bd, startX, startY, leafBase);

        for (py in 0...16) {
            for (px in 0...16) {
                if ((px + py) % 3 == 0) bd.setPixel32(startX + px, startY + py, leafDark);
                if ((px * 2 + py) % 5 == 0) bd.setPixel32(startX + px, startY + py, leafLight);
                // Diamond cutout pattern for custom opacity look
                if ((px == 0 && py == 0) || (px == 15 && py == 0) || (px == 0 && py == 15) || (px == 15 && py == 15)) {
                    bd.setPixel32(startX + px, startY + py, 0x00000000);
                }
            }
        }
    }

    // 8. Aether Skybox Pattern
    private static function drawAetherSky(bd:BitmapData, tileX:Int, tileY:Int):Void {
        var startX:Int = tileX * 16;
        var startY:Int = tileY * 16;

        var skyBase:Int = 0xFF1A233A;
        var starWhite:Int = 0xFFFFFFFF;

        fill16x16(bd, startX, startY, skyBase);

        // Subtle shimmering stars
        bd.setPixel32(startX + 3, startY + 2, starWhite);
        bd.setPixel32(startX + 12, startY + 8, starWhite);
        bd.setPixel32(startX + 7, startY + 14, starWhite);
    }

    private static function fill16x16(bd:BitmapData, startX:Int, startY:Int, color:Int):Void {
        bd.fillRect(new Rectangle(startX, startY, 16, 16), color);
    }
}