import flash.Lib;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.text.TextField;
import flash.text.TextFormat;

class Main {
    // Entities & Variables
    static var player:Sprite;
    static var nameTag:TextField;
    static var stageWidth:Int = 800;
    static var stageHeight:Int = 600;
    static var groundY:Int = 450;
    
    // Movement Physics
    static var vx:Float = 0;
    static var vy:Float = 0;
    static var isJumping:Bool = false;
    static var keyLeft:Bool = false;
    static var keyRight:Bool = false;

    // Game Elements
    static var blocks:Array<Sprite> = [];
    static var scoreText:TextField;
    static var score:Int = 0;
    static var username:String = "Sammy";

    // UI Containers
    static var loadingOverlay:Sprite;
    static var loadingText:TextField;

    static function main() {
        var stage = Lib.current.stage;

        // Fetch Username from FlashVars if available
        var params = Lib.current.loaderInfo.parameters;
        if (params.username != null && params.username != "") {
            username = params.username;
        }

        // 1. Sky Background
        var sky = new Sprite();
        sky.graphics.beginFill(0x5c94fc);
        sky.graphics.drawRect(0, 0, stageWidth, stageHeight);
        sky.graphics.endFill();
        stage.addChild(sky);

        // 2. Dirt Ground
        var ground = new Sprite();
        ground.graphics.beginFill(0x40a02b); // Top grass layer
        ground.graphics.drawRect(0, groundY, stageWidth, 16);
        ground.graphics.beginFill(0x8d5524); // Underground dirt
        ground.graphics.drawRect(0, groundY + 16, stageWidth, stageHeight - groundY);
        ground.graphics.endFill();
        stage.addChild(ground);

        // 3. Create Player (Sammy - Modern Pixel Boy Character)
        player = createSammyCharacter();
        player.x = 100;
        player.y = groundY - 32;
        stage.addChild(player);

        // Name Tag above Sammy's head
        nameTag = new TextField();
        var nameFormat = new TextFormat("Arial", 12, 0xffffff, true);
        nameTag.defaultTextFormat = nameFormat;
        nameTag.text = username;
        nameTag.width = 100;
        nameTag.selectable = false;
        stage.addChild(nameTag);

        // 4. HUD / Scoreboard
        scoreText = new TextField();
        var tf = new TextFormat("Arial", 14, 0xffffff, true);
        scoreText.defaultTextFormat = tf;
        scoreText.x = 10;
        scoreText.y = 10;
        scoreText.width = 400;
        scoreText.text = "ATHERIOS | Blocks: 0 | User: " + username;
        scoreText.selectable = false;
        stage.addChild(scoreText);

        // 5. Build On-Screen Mobile Touch Controls
        createMobileControls(stage);

        // 6. Keyboard Controls (PC)
        stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent) {
            if (e.keyCode == 37 || e.keyCode == 65) keyLeft = true;
            if (e.keyCode == 39 || e.keyCode == 68) keyRight = true;
            if ((e.keyCode == 38 || e.keyCode == 87 || e.keyCode == 32) && !isJumping) {
                vy = -12; // Jump Impulse
                isJumping = true;
            }
        });

        stage.addEventListener(KeyboardEvent.KEY_UP, function(e:KeyboardEvent) {
            if (e.keyCode == 37 || e.keyCode == 65) keyLeft = false;
            if (e.keyCode == 39 || e.keyCode == 68) keyRight = false;
        });

        // Mouse / Touch Building (Left click to place blocks)
        stage.addEventListener(MouseEvent.CLICK, function(e:MouseEvent) {
            // Ignore block clicks if clicking near mobile controls or UI
            if (e.stageY > 500 && e.stageX < 250) return;

            var block = new Sprite();
            block.graphics.beginFill(0x7f8c8d); // Stone block color
            block.graphics.drawRect(0, 0, 32, 32);
            block.graphics.endFill();
            
            // Snap to 32px grid
            block.x = Math.floor(e.stageX / 32) * 32;
            block.y = Math.floor(e.stageY / 32) * 32;
            
            stage.addChild(block);
            blocks.push(block);
            
            score++;
            scoreText.text = "ATHERIOS | Blocks: " + score + " | User: " + username;
        });

        // 7. Loading Screen Implementation
        createLoadingScreen(stage);

        // Main Game Loop
        stage.addEventListener(Event.ENTER_FRAME, function(e:Event) {
            if (loadingOverlay != null && loadingOverlay.visible) return;

            // Physics & Horizontal Movement
            if (keyLeft) vx = -5;
            else if (keyRight) vx = 5;
            else vx *= 0.8; // Friction

            player.x += vx;

            // Gravity Physics
            vy += 0.8;
            player.y += vy;

            // Ground Collision
            if (player.y >= groundY - 32) {
                player.y = groundY - 32;
                vy = 0;
                isJumping = false;
            }

            // Screen Boundaries
            if (player.x < 0) player.x = 0;
            if (player.x > stageWidth - 24) player.x = stageWidth - 24;

            // Update Name Tag position above player
            nameTag.x = player.x + 12 - (nameTag.textWidth / 2);
            nameTag.y = player.y - 18;
        });
    }

    // --- SAMMY CHARACTER CREATOR (PIXEL ART BOY) ---
    static function createSammyCharacter():Sprite {
        var s = new Sprite();

        // Hair (Brown Pixel Cap)
        s.graphics.beginFill(0x4a2e00);
        s.graphics.drawRect(2, 0, 20, 6);
        s.graphics.drawRect(0, 4, 24, 4);

        // Face & Skin Tone
        s.graphics.beginFill(0xffd1a4);
        s.graphics.drawRect(2, 8, 20, 8);

        // Eyes (Dark Blue Pixels)
        s.graphics.beginFill(0x1b2a47);
        s.graphics.drawRect(5, 10, 3, 3);
        s.graphics.drawRect(16, 10, 3, 3);

        // Hoodie / Shirt (Cyan/Teal)
        s.graphics.beginFill(0x00a8ff);
        s.graphics.drawRect(1, 16, 22, 10);

        // Belt / Details
        s.graphics.beginFill(0x222222);
        s.graphics.drawRect(3, 25, 18, 2);

        // Jeans / Pants (Dark Blue)
        s.graphics.beginFill(0x192a56);
        s.graphics.drawRect(3, 27, 8, 5);
        s.graphics.drawRect(13, 27, 8, 5);

        s.graphics.endFill();
        return s;
    }

    // --- ON-SCREEN MOBILE TOUCH BUTTONS ---
    static function createMobileControls(stage:flash.display.Stage) {
        var leftBtn = new Sprite();
        leftBtn.graphics.beginFill(0xffffff, 0.4);
        leftBtn.graphics.drawRoundRect(10, 520, 60, 60, 15);
        leftBtn.graphics.endFill();
        stage.addChild(leftBtn);

        leftBtn.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent) { keyLeft = true; });
        leftBtn.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent) { keyLeft = false; });

        var rightBtn = new Sprite();
        rightBtn.graphics.beginFill(0xffffff, 0.4);
        rightBtn.graphics.drawRoundRect(80, 520, 60, 60, 15);
        rightBtn.graphics.endFill();
        stage.addChild(rightBtn);

        rightBtn.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent) { keyRight = true; });
        rightBtn.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent) { keyRight = false; });

        var jumpBtn = new Sprite();
        jumpBtn.graphics.beginFill(0x55ff55, 0.5);
        jumpBtn.graphics.drawRoundRect(720, 520, 60, 60, 15);
        jumpBtn.graphics.endFill();
        stage.addChild(jumpBtn);

        jumpBtn.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent) {
            if (!isJumping) {
                vy = -12;
                isJumping = true;
            }
        });
    }

    // --- LOADING SCREEN ---
    static function createLoadingScreen(stage:flash.display.Stage) {
        loadingOverlay = new Sprite();
        loadingOverlay.graphics.beginFill(0x0f0f1d);
        loadingOverlay.graphics.drawRect(0, 0, stageWidth, stageHeight);
        loadingOverlay.graphics.endFill();

        loadingText = new TextField();
        var ltf = new TextFormat("Arial", 22, 0xffca28, true);
        loadingText.defaultTextFormat = ltf;
        loadingText.text = "Loading Atherios Universe...";
        loadingText.width = 400;
        loadingText.x = (stageWidth / 2) - 130;
        loadingText.y = (stageHeight / 2) - 20;

        loadingOverlay.addChild(loadingText);
        stage.addChild(loadingOverlay);

        // Hide loading screen after 2.5 seconds
        haxe.Timer.delay(function() {
            stage.removeChild(loadingOverlay);
            loadingOverlay = null;
        }, 2500);
    }
}
