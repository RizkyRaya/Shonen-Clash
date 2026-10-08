package net.play5d.game.bvn.net.events
{
   import flash.events.Event;
   
   public class LANEvent extends Event
   {
      
      public static const CONNECT:String = "LAN_CONNECT";
      
      public static const DISCONNECT:String = "LAN_DISCONNECT";
      
      public static const PACKET:String = "LAN_PACKET";
      
      public static const ERROR:String = "LAN_ERROR";
      
      public static const PING:String = "LAN_PING";
      
      public var data:Object;
      
      public function LANEvent(type:String, obj:Object = null)
      {
         super(type,false,false);
         data = obj;
      }
      
      override public function clone() : Event
      {
         return new LANEvent(type,data);
      }
   }
}

