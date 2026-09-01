package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import openfl.Assets;

class Inventory extends FlxGroup {
    public static var selectedSlot:Int = 0;
    public static var activeBlockId:Int = 1;

    private var slots:Array<FlxSprite> = [];
    private var selector:FlxSprite;
    private var crosshair:FlxSprite;

    public function new() {
        super();
        initUI();
    }

    private function initUI():Void {
        // 1. Obtain master UI texture atlas (Check disk file first, fallback to TextureGenerator)
        var uiData:BitmapData;
        if (Assets.exists("assets/textures/ui_sheet.png")) {
            uiData = Assets.getBitmapData("assets/textures/ui_sheet.png");
        } else {
            uiData = TextureGenerator.createUIAtlas();
        }

        var uiGraphic:FlxGraphic = FlxGraphic.fromBitmapData(uiData);

        // 2. Create Crosshair in screen center
        crosshair = new FlxSprite(FlxG.width / 2 - 8, FlxG.height / 2 - 8);
        crosshair.loadGraphic(uiGraphic, true, 16, 16);
        crosshair.animation.add("default", [2], 0, false); // Slot index 2 for crosshair
        crosshair.animation.play("default");
        add(crosshair);

        // 3. Create Hotbar Slots (6 slots along bottom center)
        var startX:Float = (FlxG.width - (6 * 36)) / 2;
        var startY:Float = FlxG.height - 48;

        for (i in 0...6) {
            var slot:FlxSprite = new FlxSprite(startX + (i * 36), startY);
            slot.loadGraphic(uiGraphic, true, 32, 32);
            slot.animation.add("idle", [0], 0, false); // Frame 0: Standard Slot Frame
            slot.animation.play("idle");
            slots.push(slot);
            add(slot);
        }

        // 4. Create Active Selection Outline Box
        selector = new FlxSprite(startX, startY);
        selector.loadGraphic(uiGraphic, true, 32, 32);
        selector.animation.add("select", [1], 0, false); // Frame 1: Active Gold/Silver Border
        selector.animation.play("select");
        add(selector);
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        handleSlotInput();
    }

    private function handleSlotInput():Void {
        // Hotbar selection using keys 1-6
        if (FlxG.keys.justPressed.ONE)   selectSlot(0, 1); // Grass Block
        if (FlxG.keys.justPressed.TWO)   selectSlot(1, 2); // Elemental Soil
        if (FlxG.keys.justPressed.THREE) selectSlot(2, 3); // Aether Slate
        if (FlxG.keys.justPressed.FOUR)  selectSlot(3, 4); // Mahogany Wood
        if (FlxG.keys.justPressed.FIVE)  selectSlot(4, 5); // Aether Leaves
        if (FlxG.keys.justPressed.SIX)   selectSlot(5, 1);
    }

    private function selectSlot(index:Int, blockId:Int):Void {
        selectedSlot = index;
        activeBlockId = blockId;

        // Reposition active selection frame over selected slot
        var startX:Float = (FlxG.width - (6 * 36)) / 2;
        selector.x = startX + (index * 36);
    }
}