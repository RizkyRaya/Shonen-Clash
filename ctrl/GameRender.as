package net.play5d.game.bvn.ctrl
{
   import flash.display.Stage;
   import flash.events.Event;
   
   public class GameRender
   {
      
      public static var isRender:Boolean = true;
      
      private static var _tasks:Vector.<RenderTask> = new Vector.<RenderTask>();
      
      private static var _dirty:Boolean = false;
      
      public function GameRender()
      {
         super();
      }
      
      public static function initlize(stage:Stage) : void
      {
         stage.addEventListener(Event.ENTER_FRAME,render);
      }
      
      public static function add(func:Function, group:* = null, priority:int = 100, interval:int = 1) : void
      {
         if(group == null)
         {
            group = "default";
         }
         var i:int = 0;
         while(i < _tasks.length)
         {
            if(_tasks[i].func == func)
            {
               return;
            }
            i++;
         }
         _tasks.push(new RenderTask(func,priority,group,interval));
         _dirty = true;
      }
      
      public static function remove(func:Function, group:* = null) : void
      {
         var i:int = 0;
         while(i < _tasks.length)
         {
            if(_tasks[i].func == func)
            {
               _tasks.splice(i,1);
               return;
            }
            i++;
         }
      }
      
      private static function sortTasks() : void
      {
         _tasks.sort(sortPriority);
         _dirty = false;
      }
      
      private static function sortPriority(a:RenderTask, b:RenderTask) : Number
      {
         if(a.priority < b.priority)
         {
            return -1;
         }
         if(a.priority > b.priority)
         {
            return 1;
         }
         return 0;
      }
      
      private static function render(e:Event) : void
      {
         if(!isRender)
         {
            return;
         }
         if(_dirty)
         {
            sortTasks();
         }
         var len:int = int(_tasks.length);
         var i:int = 0;
         while(i < len)
         {
            var task:RenderTask = _tasks[i];
            ++task.counter;
            if(task.counter >= task.interval)
            {
               task.counter = 0;
               task.func();
            }
            i++;
         }
      }
   }
}

