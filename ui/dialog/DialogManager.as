package net.play5d.game.bvn.ui.dialog
{
   import com.greensock.TweenLite;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.MainGame;
   
   public class DialogManager
   {
      
      private static var _dialogBG:Sprite;
      
      private static var _showingDialogs:Vector.<BaseDialog> = new Vector.<BaseDialog>();
      
      public function DialogManager()
      {
         super();
      }
      
      public static function showingDialog() : Boolean
      {
         return _showingDialogs.length > 0;
      }
      
      private static function addDialogBg() : void
      {
         var bd:BitmapData = null;
         if(!_dialogBG)
         {
            bd = new BitmapData(1,1,false,0);
            _dialogBG = new Sprite();
            _dialogBG.graphics.beginBitmapFill(bd,null,true,false);
            _dialogBG.graphics.drawRect(0,0,GameConfig.GAME_SIZE.x,GameConfig.GAME_SIZE.y);
            _dialogBG.graphics.endFill();
            _dialogBG.alpha = 0.7;
         }
         MainGame.I.root.addChild(_dialogBG);
      }
      
      public static function showDialog(dialog:BaseDialog, hideOthers:Boolean = true) : void
      {
         if(hideOthers && _showingDialogs.length > 0)
         {
            for each(var d in _showingDialogs)
            {
               d.hide();
            }
         }
         else
         {
            addDialogBg();
         }
         var px:Number = dialog.width > 0 ? (GameConfig.GAME_SIZE.x - dialog.width) / 2 : 0;
         var py:Number = dialog.height > 0 ? (GameConfig.GAME_SIZE.y - dialog.height) / 2 : 0;
         dialog.show(px,py);
         fadIn(dialog);
         _showingDialogs.push(dialog);
      }
      
      public static function closeDialog(dialog:BaseDialog) : void
      {
         var v:BaseDialog = dialog;
         var tweenBack:Function = function():void
         {
            var lastDialog:BaseDialog = null;
            var index:int = _showingDialogs.indexOf(v);
            if(index != -1)
            {
               _showingDialogs.splice(index,1);
            }
            if(_showingDialogs.length < 1)
            {
               try
               {
                  MainGame.I.root.removeChild(_dialogBG);
               }
               catch(e:Error)
               {
               }
            }
            else
            {
               lastDialog = _showingDialogs[_showingDialogs.length - 1];
               if(lastDialog.hiding())
               {
                  lastDialog.resume();
               }
               addDialogBg();
               fadIn(lastDialog);
            }
         };
         fadOut(v,tweenBack);
      }
      
      private static function fadIn(dialog:BaseDialog, back:Function = null) : void
      {
         var view:DisplayObject = dialog.getDisplay();
         var y:Number = view.y;
         view.alpha = 0;
         view.y -= 10;
         MainGame.I.root.addChild(view);
         TweenLite.to(view,0.3,{
            "y":y,
            "alpha":1,
            "onComplete":function():void
            {
               dialog.init();
               if(back != null)
               {
                  back();
               }
            }
         });
      }
      
      private static function fadOut(dialog:BaseDialog, back:Function) : void
      {
         var view:DisplayObject = dialog.getDisplay();
         TweenLite.to(view,0.2,{
            "y":view.y - 10,
            "alpha":0,
            "onComplete":function():void
            {
               dialog.close();
               dialog.destory();
               try
               {
                  MainGame.I.root.removeChild(view);
               }
               catch(e:Error)
               {
               }
               if(back != null)
               {
                  back();
               }
            }
         });
      }
   }
}

