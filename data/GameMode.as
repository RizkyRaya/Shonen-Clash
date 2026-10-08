package net.play5d.game.bvn.data
{
   public class GameMode
   {
      
      public static var currentMode:int;
      
      public static const TEAM_ACRADE:int = 10;
      
      public static const TEAM_VS_PEOPLE:int = 11;
      
      public static const TEAM_VS_CPU:int = 12;
      
      public static const TEAM_WATCH:int = 13;
      
      public static const TEAM_DUO:int = 14;
      
      public static const TEAM_DUO_WATCH:int = 15;
      
      public static const SINGLE_ACRADE:int = 20;
      
      public static const SINGLE_VS_PEOPLE:int = 21;
      
      public static const SINGLE_VS_CPU:int = 22;
      
      public static const SINGLE_WATCH:int = 23;
      
      public static const SINGLE_VS_DUO:int = 24;
      
      public static const SINGLE_VS_DUO_WATCH:int = 25;
      
      public static const SURVIVOR:int = 30;
      
      public static const TRAINING:int = 40;
      
      public static const MOSOU_ACRADE:int = 100;
      
      public function GameMode()
      {
         super();
      }
      
      public static function getTeams() : Array
      {
         return [{
            "id":1,
            "name":"P1"
         },{
            "id":2,
            "name":"P2"
         }];
      }
      
      public static function isTeamMode() : Boolean
      {
         return currentMode == 10 || currentMode == 12 || currentMode == 11 || currentMode == 13 || currentMode == 100;
      }
      
      public static function isSingleMode() : Boolean
      {
         return currentMode == 20 || currentMode == 22 || currentMode == 21 || currentMode == 23 || currentMode == 24 || currentMode == 14 || currentMode == 15 || currentMode == 25;
      }
      
      public static function isTeamDuo() : Boolean
      {
         return currentMode == 14 || currentMode == 15;
      }
      
      public static function isDuoMode() : Boolean
      {
         return currentMode == 24 || currentMode == 25;
      }
      
      public static function isVsPeople() : Boolean
      {
         return currentMode == 11 || currentMode == 21;
      }
      
      public static function isVsCPU(param1:Boolean = true) : Boolean
      {
         return currentMode == 12 || currentMode == 22 || param1 && currentMode == 40 || currentMode == 13 || currentMode == 23 || currentMode == 24 || currentMode == 14 || currentMode == 15 || currentMode == 25;
      }
      
      public static function isWatch() : Boolean
      {
         return currentMode == 13 || currentMode == 23 || currentMode == 15 || currentMode == 25;
      }
      
      public static function isAcrade() : Boolean
      {
         return currentMode == 20 || currentMode == 10 || currentMode == 30;
      }
   }
}

