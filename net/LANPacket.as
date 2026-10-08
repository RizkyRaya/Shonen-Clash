package net.play5d.game.bvn.net
{
   public class LANPacket
   {
      
      public var opcode:int;
      
      public var frame:int;
      
      public var data:Object;
      
      public function LANPacket(op:int = 0, fr:int = 0, obj:Object = null)
      {
         super();
         opcode = op;
         frame = fr;
         data = obj;
      }
   }
}

