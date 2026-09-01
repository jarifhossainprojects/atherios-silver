package;

import flixel.FlxBasic;
import flixel.FlxG;

class Player extends FlxBasic {
    public var x:Float;
    public var y:Float;
    public var z:Float;
    public var rotationY:Float = 0;
    
    private var moveSpeed:Float = 6.0;
    private var gravity:Float = -18.0;
    private var velocityY:Float = 0;
    private var isGrounded:Bool = false;

    public function new(startX:Float, startY:Float, startZ:Float) {
        super();
        this.x = startX;
        this.y = startY;
        this.z = startZ;
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);

        // WASD Movement Logic
        var forward:Float = 0;
        var strafe:Float = 0;

        if (FlxG.keys.pressed.W) forward += 1;
        if (FlxG.keys.pressed.S) forward -= 1;
        if (FlxG.keys.pressed.A) strafe -= 1;
        if (FlxG.keys.pressed.D) strafe += 1;

        // Apply movement vector aligned with camera rotation
        x += (forward * Math.sin(rotationY) + strafe * Math.cos(rotationY)) * moveSpeed * elapsed;
        z += (forward * Math.cos(rotationY) - strafe * Math.sin(rotationY)) * moveSpeed * elapsed;

        // Jump Controls & Gravity Physics
        if (FlxG.keys.justPressed.SPACE && isGrounded) {
            velocityY = 8.0;
            isGrounded = false;
        }

        velocityY += gravity * elapsed;
        y += velocityY * elapsed;

        // Ground collision mock floor (Y = 0)
        if (y <= 1.0) {
            y = 1.0;
            velocityY = 0;
            isGrounded = true;
        }
    }

    public function getLookTarget():Array<Int> {
        // Raycast forward from camera position to locate targeted 3D block coordinate
        return [Math.round(x + Math.sin(rotationY) * 3), Math.round(y), Math.round(z + Math.cos(rotationY) * 3)];
    }
}