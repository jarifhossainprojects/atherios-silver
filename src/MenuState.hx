package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxColor;
import openfl.utils.Assets;

class MenuState extends FlxState {
    private var backdrop:FlxBackdrop;
    private var logoSprite:FlxSprite;
    private var versionTag:FlxText;
    
    private var btnSinglePlayer:FlxButton;
    private var btnMultiplayer:FlxButton;
    private var btnSettings:FlxButton;

    override public function create():Void {
        super.create();

        // 1. Infinitely Downward Scrolling Background Logic
        backdrop = new FlxBackdrop("assets/textures/bg_pattern.png", 0, 1, true, true);
        backdrop.velocity.set(0, 45); // Smooth Y-axis movement down
        add(backdrop);

        // 2. Atherios Silver Top Logo
        logoSprite = new FlxSprite(0, 60);
        logoSprite.loadGraphic("assets/textures/logo.png");
        logoSprite.screenCenter(X);
        add(logoSprite);

        // 3. Top-Left Version Tag overlay
        versionTag = new FlxText(10, 10, 300, Main.VERSION);
        versionTag.setFormat(null, 12, FlxColor.WHITE, LEFT);
        versionTag.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);
        add(versionTag);

        // 4. Menu Action Buttons Setup
        var centerX:Float = (FlxG.width / 2) - 100;
        
        btnSinglePlayer = new FlxButton(centerX, 260, "Single Player", onSinglePlayer);
        btnSinglePlayer.makeGraphic(200, 40, FlxColor.GRAY);
        
        btnMultiplayer = new FlxButton(centerX, 320, "Multiplayer", onMultiplayer);
        btnMultiplayer.makeGraphic(200, 40, FlxColor.GRAY);
        
        btnSettings = new FlxButton(centerX, 380, "Settings", onSettings);
        btnSettings.makeGraphic(200, 40, FlxColor.GRAY);

        add(btnSinglePlayer);
        add(btnMultiplayer);
        add(btnSettings);

        // Play ambient background menu music safely if asset exists
        if (Assets.exists("assets/audio/menu_theme.ogg")) {
            FlxG.sound.playMusic("assets/audio/menu_theme.ogg", 0.7, true);
        }
    }

    private function playClickSound():Void {
        if (Assets.exists("assets/audio/sfx/ui_click.ogg")) {
            FlxG.sound.play("assets/audio/sfx/ui_click.ogg");
        }
    }

    private function onSinglePlayer():Void {
        playClickSound();
        FlxG.switchState(new PlayState(false)); // Local offline world
    }

    private function onMultiplayer():Void {
        playClickSound();
        FlxG.switchState(new PlayState(true)); // Network connected world
    }

    private function onSettings():Void {
        playClickSound();
        // Open Settings Sub-Menu / Audio controls
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
    }
}