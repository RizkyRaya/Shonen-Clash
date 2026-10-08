package net.play5d.game.bvn.mob.input
{
   public class GameInputRouter
   {
      
      private static var _currentFocus:int = -1;
      
      public function GameInputRouter()
      {
         super();
      }
      
      public static function applyFocus(param1:int) : void
      {
         if(_currentFocus == param1)
         {
            return;
         }
         _currentFocus = param1;
         switch(param1)
         {
            case GameInputFocus.MENU:
               enableMenu();
               break;
            case GameInputFocus.CHARACTER_SELECT:
               enableBattle();
               break;
            case GameInputFocus.STAGE_SELECT:
               enableBattle();
               break;
            case GameInputFocus.BATTLE:
               enableBattle();
               break;
            case GameInputFocus.PAUSE:
               enablePause();
               break;
            case GameInputFocus.RESULT:
               enableMenu();
         }
      }
      
      private static function enableMenu() : void
      {
         InputManager.I.joy_menu.enabled = true;
         InputManager.I.joy_p1.enabled = false;
         InputManager.I.screen_menu.enabled = true;
         InputManager.I.screen_p1.enabled = false;
      }
      
      private static function enableBattle() : void
      {
         InputManager.I.joy_menu.enabled = false;
         InputManager.I.joy_p1.enabled = true;
         InputManager.I.screen_menu.enabled = false;
         InputManager.I.screen_p1.enabled = true;
      }
      
      private static function enablePause() : void
      {
         InputManager.I.joy_menu.enabled = true;
         InputManager.I.joy_p1.enabled = true;
         InputManager.I.screen_menu.enabled = true;
         InputManager.I.screen_p1.enabled = true;
      }
      
      public static function get currentFocus() : int
      {
         return _currentFocus;
      }
   }
}

