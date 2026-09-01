package;

import openfl.display.Sprite;
import openfl.display.StageScaleMode;
import openfl.display.StageAlign;
import openfl.events.Event;
import flixel.FlxGame;
import flixel.FlxG;

class Main extends Sprite {
    public static inline var VERSION:String = "Atherios Silver v1.0";
    public static var SERVER_IP:String = "127.0.0.1";
    public static var SERVER_PORT:Int = 7777;
    public static var PLAYER_NAME:String = "Player";

    public function new() {
        super();
        if (stage != null) {
            init();
        } else {
            addEventListener(Event.ADDED_TO_STAGE, init);
        }
    }

    private function init(?e:Event):Void {
        removeEventListener(Event.ADDED_TO_STAGE, init);
        
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;

        // Launch initial state engine (MenuState) at 800x600, 60 FPS
        addChild(new FlxGame(800, 600, MenuState, 60, 60, true));
    }
}