package net.play5d.game.bvn.ctrl
{
   public class RenderTask
   {
      
      public var func:Function;
      
      public var priority:int;
      
      public var group:*;
      
      public var interval:int;
      
      public var counter:int;
      
      public function RenderTask(func:Function, priority:int, group:*, interval:int = 1)
      {
         super();
         this.func = func;
         this.priority = priority;
         this.group = group;
         if(interval < 1)
         {
            interval = 1;
         }
         this.interval = interval;
         this.counter = 0;
      }
   }
}

