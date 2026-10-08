package net.play5d.game.bvn.ui.dialog
{
   import flash.display.SimpleButton;
   import net.play5d.game.bvn.ui.Text;
   import net.play5d.game.bvn.utils.BtnUtils;
   import net.play5d.game.bvn.utils.ResUtils;
   
   public class ConfrimUI extends BaseDialog
   {
      
      private var _cnTxt:Text;
      
      public var yesBack:Function;
      
      public var noBack:Function;
      
      private var _ui:dialog_confrim;
      
      protected var _noBtn:SimpleButton;
      
      protected var _yesBtn:SimpleButton;
      
      public function ConfrimUI()
      {
         super();
         width = 495;
         height = 240;
         _ui = ResUtils.I.createDisplayObject(ResUtils.I.dialog,"dialog_confrim");
         _dialogUI = _ui;
         build();
      }
      
      override protected function onDestory() : void
      {
         super.onDestory();
         if(_cnTxt)
         {
            _cnTxt.destory();
            _cnTxt = null;
         }
         BtnUtils.destoryBtn(_noBtn);
         BtnUtils.destoryBtn(_yesBtn);
      }
      
      protected function build() : void
      {
         _cnTxt = new Text();
         _cnTxt.leading = 12;
         _cnTxt.x = 15;
         _cnTxt.y = 35;
         _cnTxt.width = 460;
         _cnTxt.height = 140;
         _cnTxt.multiLine(true);
         _cnTxt.align = "center";
         _ui.addChild(_cnTxt);
         _noBtn = _ui.getChildByName("no") as SimpleButton;
         _yesBtn = _ui.getChildByName("yes") as SimpleButton;
         BtnUtils.initBtn(_noBtn,okHandler);
         BtnUtils.initBtn(_yesBtn,okHandler);
      }
      
      private function okHandler(param1:SimpleButton) : void
      {
         switch(param1)
         {
            case _yesBtn:
               if(yesBack != null)
               {
                  yesBack();
               }
               break;
            case _noBtn:
               if(noBack != null)
               {
                  noBack();
               }
         }
      }
      
      public function setMsg(param1:String = null, param2:String = null) : void
      {
         setTitle(param1);
         if(!param2)
         {
            return;
         }
         _cnTxt.text = param2;
         _cnTxt.visible = true;
      }
   }
}

