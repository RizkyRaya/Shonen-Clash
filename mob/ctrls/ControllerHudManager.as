package net.play5d.game.bvn.mob.ctrls
{
   import flash.desktop.NativeApplication;
   import flash.events.KeyboardEvent;
   import net.play5d.game.bvn.ctrl.GameRender;
   import net.play5d.game.bvn.mob.GameInterfaceManager;
   import net.play5d.game.bvn.mob.input.JoySticker;
   import net.play5d.game.bvn.mob.screenpad.ScreenPadManager;
   
   public class ControllerHudManager
   {
      
      private static var _started:Boolean = false;
      
      private static var _lastState:int = -1;
      
      private static var _lastAlpha:Number = -1;
      
      public function ControllerHudManager()
      {
         super();
      }
      
      public static function isP1ControllerActive() : Boolean
      {
         if(GameInterfaceManager.config && GameInterfaceManager.config.joy1Config)
         {
            var devId:String = GameInterfaceManager.config.joy1Config.deviceId;
            if(devId == null || devId == "" || devId == "none" || devId == "null")
            {
               return false;
            }
            return JoySticker.isActive(devId);
         }
         return false;
      }
      
      public static function start() : void
      {
         if(_started)
         {
            return;
         }
         _started = true;
         try
         {
            NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN,onNativeKey,false,9999,true);
            NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_UP,onNativeKey,false,9999,true);
         }
         catch(e:Error)
         {
         }
         forceRefresh();
         GameRender.add(render);
      }
      
      private static function onNativeKey(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == 27 || param1.keyCode == 16777238)
         {
            param1.preventDefault();
         }
      }
      
      public static function stop() : void
      {
         if(!_started)
         {
            return;
         }
         _started = false;
         try
         {
            NativeApplication.nativeApplication.removeEventListener(KeyboardEvent.KEY_DOWN,onNativeKey);
            NativeApplication.nativeApplication.removeEventListener(KeyboardEvent.KEY_UP,onNativeKey);
         }
         catch(e:Error)
         {
         }
         GameRender.remove(render);
      }
      
      private static function render() : void
      {
         updateHud();
      }
      
      public static function forceRefresh() : void
      {
         _lastState = -1;
         _lastAlpha = -1;
         updateHud();
      }
      
      public static function updateHud() : void
      {
         var active:Boolean = isP1ControllerActive();
         var currentState:int = active ? 1 : 0;
         var targetAlpha:Number = 1;
         if(GameInterfaceManager.config && GameInterfaceManager.config.screenPadConfig)
         {
            if(GameInterfaceManager.config.screenPadConfig.hasOwnProperty("padAlpha"))
            {
               targetAlpha = Number(GameInterfaceManager.config.screenPadConfig["padAlpha"]);
            }
         }
         var finalAlpha:Number = active ? 0 : targetAlpha;
         if(currentState == _lastState && finalAlpha == _lastAlpha)
         {
            return;
         }
         _lastState = currentState;
         _lastAlpha = finalAlpha;
         ScreenPadManager.setHudAlpha(finalAlpha);
         ScreenPadManager.setTouchEnabled(!active);
      }
   }
}

