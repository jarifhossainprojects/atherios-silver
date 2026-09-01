package;

import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.util.FlxColor;

class ChatUI extends FlxGroup {
    private var chatBox:FlxText;
    private var netClient:NetworkClient;
    private var messages:Array<String> = [];

    public function new(client:NetworkClient) {
        super();
        this.netClient = client;

        chatBox = new FlxText(10, 420, 300, "Press 'T' to chat...\n[System]: Welcome to Atherios Silver!");
        chatBox.setFormat(null, 9, FlxColor.WHITE, LEFT);
        chatBox.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);
        add(chatBox);
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);

        if (FlxG.keys.justPressed.T) {
            // Open text input overlay and send packet via netClient.sendChatMessage()
        }
    }
}