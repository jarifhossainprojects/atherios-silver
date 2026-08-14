import flash.Lib;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;

class Main {
    static var player:Sprite;
    static var left:Bool = false;
    static var right:Bool = false;

    static function main() {
        var stage = Lib.current.stage;

        // 1. Pixel Sky
        var sky = new Sprite();
        sky.graphics.beginFill(0x5c94fc);
        sky.graphics.drawRect(0, 0, 800, 600);
        sky.graphics.endFill();
        stage.addChild(sky);

        // 2. Horizon Pixel Grass & Dirt
        var ground = new Sprite();
        ground.graphics.beginFill(0x40a02b);
        var xPos:Int = 0;
        while (xPos < 800) {
            ground.graphics.drawRect(xPos, 400, 16, 16);
            xPos += 16;
        }
        ground.graphics.beginFill(0x8d5524);
        ground.graphics.drawRect(0, 416, 800, 184);
        ground.graphics.endFill();
        stage.addChild(ground);

        // 3. Player Character
        player = new Sprite();
        player.graphics.beginFill(0xe74c3c);
        player.graphics.drawRect(0, 0, 24, 32);
        player.graphics.endFill();
        player.x = 100;
        player.y = 368;
        stage.addChild(player);

        // Controls & Loop
        stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent) {
            if (e.keyCode == 37 || e.keyCode == 65) left = true;
            if (e.keyCode == 39 || e.keyCode == 68) right = true;
        });

        stage.addEventListener(KeyboardEvent.KEY_UP, function(e:KeyboardEvent) {
            if (e.keyCode == 37 || e.keyCode == 65) left = false;
            if (e.keyCode == 39 || e.keyCode == 68) right = false;
        });

        stage.addEventListener(Event.ENTER_FRAME, function(e:Event) {
            if (left) player.x -= 4;
            if (right) player.x += 4;
        });
    }
}
