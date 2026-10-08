package net.play5d.game.bvn.ui
{
   import flash.display.Sprite;
   import net.play5d.game.bvn.ctrl.AssetManager;
   import net.play5d.game.bvn.ctrl.SoundCtrl;
   import net.play5d.game.bvn.events.SetBtnEvent;
   import net.play5d.game.bvn.utils.ResUtils;
   import net.play5d.kyo.display.bitmap.BitmapFontText;
   
   public class SetBtn extends Sprite
   {
      
      public var optionKey:String;
      
      public var onSelect:Function;
      
      private var _label:BitmapFontText;
      
      private var _options:Array;
      
      private var _optionIndex:int;
      
      private var _optionTxt:BitmapFontText;
      
      private var _prevArrow:txt_arrow_mc;
      
      private var _nextArrow:txt_arrow_mc;
      
      private var _line:SetBtnLine;
      
      private var _cn:String;
      
      public function SetBtn(param1:String, param2:String)
      {
         super();
         this.buttonMode = true;
         _label = new BitmapFontText(AssetManager.I.getFont("font1"));
         _label.text = param1;
         _cn = param2;
         _line = new SetBtnLine();
         _line.y = _label.height;
         _line.hide();
         addChild(_line);
         addChild(_label);
      }
      
      public function get label() : String
      {
         return _label.text;
      }
      
      public function destory() : void
      {
         if(_label)
         {
            _label.dispose();
         }
      }
      
      public function hover() : void
      {
         updateLine();
         addChild(_line);
      }
      
      private function updateLine() : void
      {
         var _loc1_:Object = getOption();
         if(_loc1_)
         {
            _line.show(width,_cn + " - " + _loc1_.cn);
         }
         else
         {
            _line.show(width,_cn);
         }
      }
      
      public function hoverOut() : void
      {
         _line.hide();
         try
         {
            removeChild(_line);
         }
         catch(e:Error)
         {
         }
      }
      
      public function select() : void
      {
         var _loc1_:SetBtnEvent = new SetBtnEvent("SELECT");
         _loc1_.selectedLabel = label;
         dispatchEvent(_loc1_);
         SoundCtrl.I.sndConfrim();
      }
      
      public function setOption(param1:Array) : void
      {
         _options = param1;
         _prevArrow = ResUtils.I.createDisplayObject(ResUtils.I.setting,"txt_arrow_mc");
         _nextArrow = ResUtils.I.createDisplayObject(ResUtils.I.setting,"txt_arrow_mc");
         _prevArrow.name = "prevArrow";
         _nextArrow.name = "nextArrow";
         _nextArrow.scaleX = -1;
         _prevArrow.y = _nextArrow.y = 17;
         _optionTxt = new BitmapFontText(AssetManager.I.getFont("font1"));
         addChild(_prevArrow);
         addChild(_nextArrow);
         addChild(_optionTxt);
         updateOption();
      }
      
      public function getOption() : Object
      {
         if(!_options)
         {
            return null;
         }
         return _options[_optionIndex];
      }
      
      public function nextOption() : void
      {
         if(!_options)
         {
            return;
         }
         var _loc1_:int = _optionIndex + 1;
         if(_loc1_ > _options.length - 1)
         {
            _loc1_ = 0;
         }
         changeOption(_loc1_);
         SoundCtrl.I.sndSelect();
      }
      
      public function prevOption() : void
      {
         if(!_options)
         {
            return;
         }
         var _loc1_:int = _optionIndex - 1;
         if(_loc1_ < 0)
         {
            _loc1_ = _options.length - 1;
         }
         changeOption(_loc1_);
         SoundCtrl.I.sndSelect();
      }
      
      public function setOptionByValue(param1:Object) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         while(_loc2_ < _options.length)
         {
            _loc3_ = _options[_loc2_];
            if(_loc3_.value == param1)
            {
               changeOption(_loc2_,false);
               return;
            }
            _loc2_++;
         }
      }
      
      private function changeOption(param1:int, param2:Boolean = true) : void
      {
         var _loc3_:SetBtnEvent = null;
         var _loc4_:Object = null;
         _optionIndex = param1;
         updateOption();
         updateLine();
         if(param2)
         {
            _loc3_ = new SetBtnEvent("OPTION_CHANGE");
            _loc4_ = getOption();
            if(_loc4_)
            {
               _loc3_.optionKey = optionKey;
               _loc3_.optionValue = _loc4_.value;
               dispatchEvent(_loc3_);
            }
         }
      }
      
      private function updateOption() : void
      {
         var _loc1_:String = getOption().label;
         _optionTxt.text = _loc1_;
         _prevArrow.x = _label.x + _label.width + 50;
         _optionTxt.x = _prevArrow.x + 10;
         _nextArrow.x = _optionTxt.x + _optionTxt.width + 10;
      }
   }
}

