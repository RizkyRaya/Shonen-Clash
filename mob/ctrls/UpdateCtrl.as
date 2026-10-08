package net.play5d.game.bvn.mob.ctrls
{
   import flash.utils.setTimeout;
   import net.play5d.game.bvn.ui.GameUI;
   
   public class UpdateCtrl
   {
      
      private static var _i:UpdateCtrl;
      
      public function UpdateCtrl()
      {
         super();
      }
      
      public static function get I() : UpdateCtrl
      {
         if(!_i)
         {
            _i = new UpdateCtrl();
         }
         return _i;
      }
      
      public function update(param1:Function = null, param2:Function = null) : void
      {
         var alertDialog:*;
         var updateBack:Function = param1;
         var skipBack:Function = param2;
         var isHandled:Boolean = false;
         var proceedGame:Function = function():void
         {
            if(isHandled)
            {
               return;
            }
            isHandled = true;
            if(skipBack != null)
            {
               skipBack();
            }
            else if(updateBack != null)
            {
               updateBack();
            }
         };
         try
         {
            alertDialog = GameUI.alert("Patch 1.0.3","Patch Successfully Updated!",function():void
            {
               proceedGame();
            });
            if(alertDialog != null)
            {
               if(alertDialog.hasOwnProperty("cancelBtn") && alertDialog.cancelBtn != null)
               {
                  alertDialog.cancelBtn.visible = false;
               }
               if(alertDialog.hasOwnProperty("closeBtn") && alertDialog.closeBtn != null)
               {
                  alertDialog.closeBtn.visible = false;
               }
            }
            setTimeout(function():void
            {
               closeAlert(alertDialog);
               proceedGame();
            },3500);
         }
         catch(e:Error)
         {
            proceedGame();
         }
      }
      
      private function closeAlert(dialog:*) : void
      {
         if(dialog == null)
         {
            return;
         }
         try
         {
            if(dialog.hasOwnProperty("close") && dialog.close is Function)
            {
               dialog.close();
            }
            else if(dialog.hasOwnProperty("hide") && dialog.hide is Function)
            {
               dialog.hide();
            }
            else if(dialog.parent != null)
            {
               dialog.parent.removeChild(dialog);
            }
         }
         catch(e:Error)
         {
         }
      }
   }
}

