package net.play5d.game.bvn.mob.ctrls
{
   import flash.events.KeyboardEvent;
   import net.play5d.game.bvn.MainGame;
   import net.play5d.game.bvn.mob.views.lan.LANExitDialog;
   import net.play5d.game.bvn.utils.KeyBoarder;
   
   public class LanGameMenuCtrl
   {
      
      private static var _i:LanGameMenuCtrl;
      
      private var _isKeyDown:Boolean;
      
      private var _exitDialog:LANExitDialog;
      
      public function LanGameMenuCtrl()
      {
         super();
      }
      
      public static function get I() : LanGameMenuCtrl
      {
         if(!_i)
         {
            _i = new LanGameMenuCtrl();
         }
         return _i;
      }
      
      public function init() : void
      {
         _exitDialog = new LANExitDialog();
         _exitDialog.hide();
         KeyBoarder.listen(keyHandler);
      }
      
      public function dispose() : void
      {
         if(_exitDialog)
         {
            try
            {
               MainGame.I.root.removeChild(_exitDialog);
            }
            catch(e:Error)
            {
               trace(e);
            }
            _exitDialog.destory();
            _exitDialog = null;
         }
         KeyBoarder.unListen(keyHandler);
         _isKeyDown = false;
      }
      
      private function keyHandler(param1:KeyboardEvent) : void
      {
         if(param1.type == "keyDown")
         {
            if(_isKeyDown)
            {
               return;
            }
            if(!_exitDialog)
            {
               return;
            }
            if(param1.keyCode == 27)
            {
               _isKeyDown = true;
               if(_exitDialog.isShowing())
               {
                  _exitDialog.hide();
               }
               else
               {
                  MainGame.I.root.addChild(_exitDialog);
                  _exitDialog.show();
               }
            }
         }
         if(param1.type == "keyUp")
         {
            if(param1.keyCode == 27)
            {
               _isKeyDown = false;
            }
         }
      }
   }
}

