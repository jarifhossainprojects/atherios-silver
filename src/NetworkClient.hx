package;

import openfl.net.Socket;
import openfl.events.Event;
import openfl.events.ProgressEvent;

class NetworkClient {
    private var socket:Socket;
    public var isConnected:Bool = false;

    public function new(host:String, port:Int) {
        socket = new Socket();
        socket.addEventListener(Event.CONNECT, onConnect);
        socket.addEventListener(ProgressEvent.SOCKET_DATA, onData);
        
        try {
            socket.connect(host, port);
        } catch (e:Dynamic) {
            trace("Connection failed: " + e);
        }
    }

    private function onConnect(e:Event):Void {
        isConnected = true;
        // Join Handshake Packet
        socket.writeUTFBytes('{"type":"join","username":"' + Main.PLAYER_NAME + '"}\n');
        socket.flush();
    }

    public function sendPosition(x:Float, y:Float, z:Float, rot:Float):Void {
        if (!isConnected) return;
        var json:String = '{"type":"move","x":' + x + ',"y":' + y + ',"z":' + z + ',"rot":' + rot + '}\n';
        socket.writeUTFBytes(json);
        socket.flush();
    }

    public function sendChatMessage(msg:String):Void {
        if (!isConnected) return;
        var json:String = '{"type":"chat","msg":"' + msg + '"}\n';
        socket.writeUTFBytes(json);
        socket.flush();
    }

    private function onData(e:ProgressEvent):Void {
        var rawData:String = socket.readUTFBytes(socket.bytesAvailable);
        // Parse incoming network packets and update remote player list
    }
}