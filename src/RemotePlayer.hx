package;

import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class RemotePlayer extends FlxGroup {
    public var userId:String;
    public var username:String;
    
    public var posX:Float = 0;
    public var posY:Float = 0;
    public var posZ:Float = 0;
    
    private var nameplate:FlxText;

    public function new(id:String, name:String, startX:Float, startY:Float, startZ:Float) {
        super();
        this.userId = id;
        this.username = name;
        
        this.posX = startX;
        this.posY = startY;
        this.posZ = startZ;

        // 3D Overhead Text Tag pinned above skin head
        nameplate = new FlxText(0, 0, 150, username);
        nameplate.setFormat(null, 10, FlxColor.YELLOW, CENTER);
        nameplate.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);
        add(nameplate);
    }

    public function updateNetworkPosition(newX:Float, newY:Float, newZ:Float):Void {
        this.posX = newX;
        this.posY = newY;
        this.posZ = newZ;
        
        // Re-project 3D world coordinates into 2D screen coordinates for overhead tag
        nameplate.x = (posX * 10) + 400; 
        nameplate.y = (-posY * 10) + 300 - 20;
    }
}