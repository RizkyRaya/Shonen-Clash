package net.play5d.game.bvn.mob.ctrls
{
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.MainGame;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.data.GameMode;
   import net.play5d.game.bvn.mob.data.HostVO;
   import net.play5d.game.bvn.mob.sockets.SocketClient;
   import net.play5d.game.bvn.mob.utils.LANUtils;
   import net.play5d.game.bvn.mob.views.lan.LANGameState;
   
   public class LANGameCtrl
   {
      
      private static var _i:LANGameCtrl;
      
      public static const PORT_UDP_SERVER:int = 17477;
      
      public static const PORT_UDP_CLIENT:int = 17478;
      
      public static const PORT_TCP:int = 17511;
      
      public var gameMode:int;
      
      public var userName:String = "test";
      
      private var _client:SocketClient;
      
      public function LANGameCtrl()
      {
         super();
      }
      
      public static function get I() : LANGameCtrl
      {
         if(!_i)
         {
            _i = new LANGameCtrl();
         }
         return _i;
      }
      
      public function goLANGameState() : void
      {
         this.gameMode = gameMode;
         MainGame.stageCtrl.goStage(new LANGameState());
      }
      
      public function gameStart(param1:HostVO) : void
      {
         GameData.I.config.fighterHP = param1.hp;
         GameData.I.config.fightTime = param1.gameTime;
         GameConfig.setGameFps(30);
         GameData.I.config.keyInputMode = 1;
         LANUtils.updateParams();
         switch(param1.gameMode - 1)
         {
            case 0:
               GameMode.currentMode = 11;
               break;
            case 1:
               GameMode.currentMode = 21;
         }
         LanGameMenuCtrl.I.init();
         MainGame.I.goSelect();
      }
      
      public function gameEnd() : void
      {
         GameData.I.loadData();
         MainGame.I.goMenu();
         LanGameMenuCtrl.I.dispose();
      }
   }
}

