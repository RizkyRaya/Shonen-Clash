package net.play5d.game.bvn.mob.screenpad
{
   import flash.display.DisplayObject;
   import flash.display.Stage;
   import flash.events.TouchEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.ui.Multitouch;
   import flash.utils.Dictionary;
   import net.play5d.game.bvn.MainGame;
   import net.play5d.game.bvn.ctrl.GameRender;
   import net.play5d.game.bvn.events.GameEvent;
   import net.play5d.game.bvn.mob.ctrls.ControllerHudManager;
   import net.play5d.game.bvn.mob.ctrls.MobileCtrler;
   import net.play5d.game.bvn.mob.input.InputManager;
   import net.play5d.game.bvn.mob.input.ScreenPadInput;
   import net.play5d.game.bvn.state.GameState;
   import net.play5d.game.bvn.state.SelectFighterStage;
   import net.play5d.kyo.stage.events.KyoStageEvent;
   
   public class ScreenPadManager
   {
      
      private static var _game:ScreenPadGame;
      
      private static var _selectFighter:ScreenPadSelectFighter;
      
      private static var _stage:Stage;
      
      private static var _curMode:int = -1;
      
      private static var _listened:Dictionary = new Dictionary();
      
      public function ScreenPadManager()
      {
         super();
      }
      
      public static function initlize(param1:Stage) : void
      {
         _stage = param1;
         GameEvent.addEventListener("PAUSE_GAME",pauseResumeHandler);
         GameEvent.addEventListener("RESUME_GAME",pauseResumeHandler);
         _game = new ScreenPadGame(param1);
         _game.inputers = new Vector.<ScreenPadInput>();
         _game.inputers.push(InputManager.I.screen_p1);
         _game.menuInputer = InputManager.I.screen_menu;
         _selectFighter = new ScreenPadSelectFighter(param1);
         _selectFighter.inputers = new Vector.<ScreenPadInput>();
         _selectFighter.inputers.push(InputManager.I.screen_menu,InputManager.I.screen_p1);
         Multitouch.inputMode = "touchPoint";
      }
      
      private static function pauseResumeHandler(param1:GameEvent) : void
      {
         if(param1.type == "PAUSE_GAME")
         {
            _game.onPause();
         }
         if(param1.type == "RESUME_GAME")
         {
            _game.onResume();
         }
      }
      
      public static function reBuild() : void
      {
         var _loc1_:int = _curMode;
         _curMode = 0;
         _game.reBuild();
         _selectFighter.reBuild();
         switch(_loc1_ - 1)
         {
            case 0:
               menuMode();
               break;
            case 1:
               gameMode();
               break;
            case 2:
               selectFighterMode();
         }
      }
      
      public static function listen() : void
      {
         MainGame.stageCtrl.addEventListener("CHANGE_STATE",stateChangeHandler);
         _stage.addEventListener("touchBegin",touchHandler);
         _stage.addEventListener("touchMove",touchHandler);
         _stage.addEventListener("touchEnd",touchHandler);
         GameEvent.addEventListener("PAUSE_GAME",onPauseGame);
         GameEvent.addEventListener("RESUME_GAME",onResumeGame);
         GameRender.add(render);
      }
      
      private static function stateChangeHandler(param1:KyoStageEvent) : void
      {
         if(param1.stage is GameState)
         {
            gameMode();
         }
         else if(param1.stage is SelectFighterStage)
         {
            selectFighterMode();
         }
         else
         {
            menuMode();
         }
      }
      
      private static function hideALL() : void
      {
         _curMode = 0;
         _game.hide();
         _selectFighter.hide();
      }
      
      private static function menuMode() : void
      {
         if(_curMode == 1)
         {
            return;
         }
         _curMode = 1;
         if(_stage)
         {
            _stage.mouseChildren = true;
         }
         _game.hide();
         _selectFighter.hide();
      }
      
      private static function gameMode() : void
      {
         if(_curMode == 2)
         {
            return;
         }
         if(_stage)
         {
            _stage.mouseChildren = false;
         }
         _curMode = 2;
         _selectFighter.hide();
         _game.show();
         ControllerHudManager.forceRefresh();
      }
      
      private static function selectFighterMode() : void
      {
         if(_curMode == 3)
         {
            return;
         }
         if(_stage)
         {
            _stage.mouseChildren = true;
         }
         _curMode = 3;
         _game.hide();
         _selectFighter.show();
         ControllerHudManager.forceRefresh();
      }
      
      private static function touchHandler(param1:TouchEvent) : void
      {
         if(MobileCtrler.I.isAdPause)
         {
            MobileCtrler.I.adResume();
            return;
         }
         switch(_curMode - 1)
         {
            case 0:
               break;
            case 1:
               _game.touchHandler(param1);
               break;
            case 2:
               _selectFighter.touchHandler(param1);
         }
         listenTouchHandler(param1);
      }
      
      private static function onPauseGame(param1:GameEvent) : void
      {
         menuMode();
      }
      
      private static function onResumeGame(param1:GameEvent) : void
      {
         gameMode();
      }
      
      private static function render() : void
      {
         if(_game && _game.isShowing)
         {
            _game.render();
         }
      }
      
      public static function setHudAlpha(value:Number) : void
      {
         if(_game)
         {
            _game.setHudAlpha(value);
         }
         if(_selectFighter)
         {
            _selectFighter.setHudAlpha(value);
         }
      }
      
      public static function setTouchEnabled(value:Boolean) : void
      {
         if(_game)
         {
            _game.setTouchEnabled(value);
         }
         if(_selectFighter)
         {
            _selectFighter.setTouchEnabled(value);
         }
      }
      
      public static function testMode() : void
      {
         gameMode();
      }
      
      public static function addTouchListener(param1:DisplayObject, param2:Function) : void
      {
         _listened[param1] = param2;
      }
      
      public static function removeTouchListener(param1:DisplayObject) : void
      {
         delete _listened[param1];
      }
      
      public static function clearTouchListener() : void
      {
         _listened = new Dictionary();
      }
      
      private static function listenTouchHandler(param1:TouchEvent) : void
      {
         var _loc3_:Point = null;
         var _loc2_:Rectangle = null;
         var _loc5_:String = param1.type;
         if("touchEnd" === _loc5_)
         {
            _loc3_ = new Point(param1.stageX,param1.stageY);
            for(var _loc4_ in _listened)
            {
               if(_loc4_.visible)
               {
                  if(!_loc4_ || !_listened[_loc4_])
                  {
                     delete _listened[_loc4_];
                  }
                  else
                  {
                     _loc2_ = _loc4_.getBounds(_stage);
                     if(_loc2_.containsPoint(_loc3_))
                     {
                        _listened[_loc4_](_loc4_);
                     }
                  }
               }
            }
         }
      }
   }
}

