package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.display3D.Context3D;
import openfl.utils.Assets;

class PlayState extends FlxState {
    private var isMultiplayer:Bool;
    private var versionTag:FlxText;
    private var crosshair:FlxText;
    
    private var worldGenerator:VoxelWorld;
    private var player:Player;
    private var inventory:Inventory;
    private var netClient:NetworkClient;
    private var chatUI:ChatUI;

    public function new(multiplayerMode:Bool = false) {
        super();
        this.isMultiplayer = multiplayerMode;
    }

    override public function create():Void {
        super.create();

        // 1. Version Tag Overlay
        versionTag = new FlxText(10, 10, 300, Main.VERSION);
        versionTag.setFormat(null, 12, FlxColor.WHITE, LEFT);
        versionTag.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);

        // 2. Center Aim Crosshair
        crosshair = new FlxText(0, 0, 20, "+");
        crosshair.setFormat(null, 16, FlxColor.WHITE, CENTER);
        crosshair.screenCenter();
        
        // 3. Initialize Voxel World (Sky, Grass, Trees, Dirt, Stone)
        worldGenerator = new VoxelWorld();
        add(worldGenerator);

        // 4. Initialize Local 3D Player Controller
        player = new Player(0, 20, 0);
        add(player);

        // 5. Hotbar & Starting Inventory
        inventory = new Inventory();
        add(inventory);

        // 6. Network Bridge (If Multiplayer selected)
        if (isMultiplayer) {
            netClient = new NetworkClient(Main.SERVER_IP, Main.SERVER_PORT);
            chatUI = new ChatUI(netClient);
            add(chatUI);
        }

        add(versionTag);
        add(crosshair);

        // Play ambient in-game soundtrack safely if asset exists
        if (Assets.exists("assets/audio/bgm_game.ogg")) {
            FlxG.sound.playMusic("assets/audio/bgm_game.ogg", 0.5, true);
        }
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        
        // Handle Block Interaction (Break / Place)
        if (FlxG.mouse.justPressed) {
            worldGenerator.breakBlockAt(player.getLookTarget());
            if (Assets.exists("assets/audio/sfx/block_break.ogg")) {
                FlxG.sound.play("assets/audio/sfx/block_break.ogg");
            }
        } else if (FlxG.mouse.justPressedRight) {
            worldGenerator.placeBlockAt(player.getLookTarget(), inventory.getSelectedBlockType());
            if (Assets.exists("assets/audio/sfx/block_place.ogg")) {
                FlxG.sound.play("assets/audio/sfx/block_place.ogg");
            }
        }

        // Footstep Audio Feedback (Played when moving)
        if (player.isWalking()) {
            if (Assets.exists("assets/audio/sfx/step.ogg")) {
                FlxG.sound.play("assets/audio/sfx/step.ogg", 0.3);
            }
        }

        // Multiplayer state sync
        if (isMultiplayer && netClient != null) {
            netClient.sendPosition(player.x, player.y, player.z, player.rotationY);
        }
    }
}