package net.play5d.game.bvn.net
{
   import flash.events.EventDispatcher;
   import flash.utils.getTimer;
   
   public class LANManager extends EventDispatcher
   {
      
      private static var _instance:LANManager;
      
      private var _initialized:Boolean = false;
      
      private var _running:Boolean = false;
      
      private var _connected:Boolean = false;
      
      private var _isHost:Boolean = false;
      
      private var _frame:int = 0;
      
      private var _lastUpdate:int = 0;
      
      public function LANManager()
      {
         super();
      }
      
      public static function get I() : LANManager
      {
         if(!_instance)
         {
            _instance = new LANManager();
         }
         return _instance;
      }
      
      public function init() : void
      {
         if(_initialized)
         {
            return;
         }
         _initialized = true;
         _running = true;
         _frame = 0;
         _lastUpdate = getTimer();
         trace("[LAN] Manager Initialized");
      }
      
      public function update() : void
      {
         if(!_running)
         {
            return;
         }
         ++_frame;
      }
      
      public function shutdown() : void
      {
         _running = false;
         _connected = false;
         trace("[LAN] Shutdown");
      }
      
      public function createRoom() : void
      {
         _isHost = true;
         trace("[LAN] Create Room");
      }
      
      public function joinRoom(ip:String) : void
      {
         _isHost = false;
         trace("[LAN] Join Room :",ip);
      }
      
      public function disconnect() : void
      {
         _connected = false;
         trace("[LAN] Disconnect");
      }
      
      public function get frame() : int
      {
         return _frame;
      }
      
      public function get initialized() : Boolean
      {
         return _initialized;
      }
      
      public function get running() : Boolean
      {
         return _running;
      }
      
      public function get connected() : Boolean
      {
         return _connected;
      }
      
      public function get isHost() : Boolean
      {
         return _isHost;
      }
      
      public function set connected(v:Boolean) : void
      {
         _connected = v;
      }
   }
}

