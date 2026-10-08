package net.play5d.game.bvn.mob.views.lan
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.text.TextField;
   import net.play5d.game.bvn.mob.utils.UIAssetUtil;
   
   public class HostDialogItem
   {
      
      public var ui:Sprite;
      
      private var _txt:TextField;
      
      private var _enTxt:TextField;
      
      private var _data:Object;
      
      private var _checkGroup:InsCheckGroup;
      
      public function HostDialogItem(param1:Object)
      {
         super();
         _data = param1;
         ui = UIAssetUtil.I.createDisplayObject("check_line_mc");
         _txt = ui.getChildByName("txt") as TextField;
         _enTxt = ui.getChildByName("txt_en") as TextField;
         _txt.text = param1.title;
         _txt.width = _txt.textWidth + 50;
         _enTxt.text = param1.en;
         _enTxt.width = _enTxt.textWidth + 50;
         buildCheckGroup();
         updateEnText();
      }
      
      public function getSelectData() : Object
      {
         return {
            "key":_data.key,
            "value":_checkGroup.selectData.value
         };
      }
      
      private function buildCheckGroup() : void
      {
         var _loc1_:InsCheckGroup = new InsCheckGroup(_data.key,_data.options);
         _loc1_.x = _txt.width;
         _loc1_.addEventListener("change",groupChangeHandler);
         ui.addChild(_loc1_);
         _checkGroup = _loc1_;
      }
      
      private function updateEnText() : void
      {
         _enTxt.text = _data.en + " : " + _checkGroup.selectData.en;
         _enTxt.width = _enTxt.textWidth + 50;
      }
      
      private function groupChangeHandler(param1:Event) : void
      {
         updateEnText();
      }
   }
}

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import net.play5d.game.bvn.ctrl.SoundCtrl;
import net.play5d.game.bvn.mob.screenpad.ScreenPadManager;
import net.play5d.game.bvn.mob.utils.UIAssetUtil;

class InsCheckGroup extends Sprite
{
   
   private var _checkMcs:Array;
   
   public var key:String;
   
   public var selectData:Object;
   
   public function InsCheckGroup(param1:String, param2:Array)
   {
      var _loc4_:int = 0;
      var _loc3_:InsCheckMc = null;
      super();
      _checkMcs = [];
      this.mouseEnabled = this.mouseChildren = false;
      this.key = param1;
      while(_loc4_ < param2.length)
      {
         _loc3_ = new InsCheckMc(param2[_loc4_]);
         if(_loc4_ == 0)
         {
            _loc3_.selected(true);
            selectData = param2[_loc4_];
         }
         _checkMcs.push(_loc3_);
         _loc3_.ui.x = _loc4_ * 130;
         addChild(_loc3_.ui);
         ScreenPadManager.addTouchListener(_loc3_.ui,touchHandler);
         _loc4_++;
      }
   }
   
   private function touchHandler(param1:DisplayObject) : void
   {
      var _loc3_:Object = null;
      SoundCtrl.I.sndSelect();
      for each(var _loc2_ in _checkMcs)
      {
         if(_loc2_.ui == param1)
         {
            _loc3_ = _loc2_.data;
            _loc2_.selected(true);
         }
         else
         {
            _loc2_.selected(false);
         }
      }
      if(selectData != _loc3_)
      {
         selectData = _loc3_;
         dispatchEvent(new Event("change"));
      }
   }
}

class InsCheckMc
{
   
   public var ui:MovieClip;
   
   public var data:Object;
   
   public function InsCheckMc(param1:Object)
   {
      super();
      this.data = param1;
      ui = UIAssetUtil.I.createDisplayObject("ckmc");
      ui.txtmc.txt.text = param1.name;
   }
   
   public function selected(param1:Boolean) : void
   {
      ui.gotoAndStop(param1 ? 2 : 1);
   }
}
