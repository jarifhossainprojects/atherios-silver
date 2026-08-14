package {
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.text.TextField;

    public class Main extends Sprite {
        private var player:Sprite;
        private var sky:Sprite;
        private var grassLine:Sprite;

        public function Main() {
            // 1. Pixel Sky
            sky = new Sprite();
            sky.graphics.beginFill(0x5c94fc);
            sky.graphics.drawRect(0, 0, 800, 600);
            sky.graphics.endFill();
            addChild(sky);

            // 2. Horizon Pixel Grass & Dirt
            grassLine = new Sprite();
            grassLine.graphics.beginFill(0x40a02b);
            for (var xPos:int = 0; xPos < 800; xPos += 16) {
                grassLine.graphics.drawRect(xPos, 400, 16, 16);
            }
            grassLine.graphics.beginFill(0x8d5524);
            grassLine.graphics.drawRect(0, 416, 800, 184);
            grassLine.graphics.endFill();
            addChild(grassLine);

            // 3. Player Character
            player = new Sprite();
            player.graphics.beginFill(0xe74c3c);
            player.graphics.drawRect(0, 0, 24, 32);
            player.graphics.endFill();
            player.x = 100;
            player.y = 368;
            addChild(player);
        }
    }
}
