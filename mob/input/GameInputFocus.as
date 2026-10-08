package net.play5d.game.bvn.mob.input
{
   public class GameInputFocus
   {
      
      public static const MENU:int = 0;
      
      public static const CHARACTER_SELECT:int = 1;
      
      public static const STAGE_SELECT:int = 2;
      
      public static const BATTLE:int = 3;
      
      public static const PAUSE:int = 4;
      
      public static const RESULT:int = 5;
      
      private static var _focus:int = MENU;
      
      public function GameInputFocus()
      {
         super();
      }
      
      public static function setMenu() : void
      {
         _focus = MENU;
      }
      
      public static function setCharacterSelect() : void
      {
         _focus = CHARACTER_SELECT;
      }
      
      public static function setStageSelect() : void
      {
         _focus = STAGE_SELECT;
      }
      
      public static function setBattle() : void
      {
         _focus = BATTLE;
      }
      
      public static function setPause() : void
      {
         _focus = PAUSE;
      }
      
      public static function setResult() : void
      {
         _focus = RESULT;
      }
      
      public static function get focus() : int
      {
         return _focus;
      }
      
      public static function isMenu() : Boolean
      {
         return _focus == MENU;
      }
      
      public static function isCharacterSelect() : Boolean
      {
         return _focus == CHARACTER_SELECT;
      }
      
      public static function isStageSelect() : Boolean
      {
         return _focus == STAGE_SELECT;
      }
      
      public static function isBattle() : Boolean
      {
         return _focus == BATTLE;
      }
      
      public static function isPause() : Boolean
      {
         return _focus == PAUSE;
      }
      
      public static function isResult() : Boolean
      {
         return _focus == RESULT;
      }
   }
}

