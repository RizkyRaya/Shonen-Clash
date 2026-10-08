package net.play5d.game.bvn.mob.data
{
   import flash.net.Socket;
   
   public class ClientVO
   {
      
      public var ip:String;
      
      public var port:int;
      
      public var name:String;
      
      public var socket:Socket;
      
      public function ClientVO()
      {
         super();
      }
      
      public function get id() : String
      {
         return ip;
      }
   }
}

