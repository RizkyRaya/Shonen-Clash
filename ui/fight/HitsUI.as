package net.play5d.game.bvn.ui.fight
{
   import flash.display.MovieClip;
   import flash.geom.Point;
   import net.play5d.game.bvn.utils.ResUtils;
   import net.play5d.kyo.display.MCNumber;
   
   public class HitsUI
   {
      
      private var _mc:MovieClip;
      
      private var _txtmc:MCNumber;
      
      private var _isShow:Boolean;
      
      private var _orgPos:Point;
      
      public function HitsUI(param1:MovieClip)
      {
         super();
         _mc = param1;
         var _loc2_:Class = ResUtils.I.getItemClass(ResUtils.I.fight,"hits_num_mc");
         _txtmc = new MCNumber(_loc2_,0,1,35);
         _orgPos = new Point(param1.x,param1.y);
         _mc.ct.addChild(_txtmc);
      }
      
      public function destory() : void
      {
         if(_txtmc)
         {
            try
            {
               _mc.ct.removeChild(_txtmc);
            }
            catch(e:Error)
            {
            }
            _txtmc = null;
         }
         if(_mc)
         {
            _mc = null;
         }
         _orgPos = null;
      }
      
      public function show(param1:int) : void
      {
         _txtmc.number = param1;
         var _loc2_:Number = -_txtmc.width + 45;
         _txtmc.x = _loc2_;
         if(_mc.name == "hits1")
         {
            _mc.x = _orgPos.x - _loc2_;
         }
         if(_isShow)
         {
            _mc.gotoAndPlay("update");
            return;
         }
         _isShow = true;
         _mc.gotoAndPlay("fadin");
      }
      
      public function hide() : void
      {
         if(!_isShow)
         {
            return;
         }
         _isShow = false;
         _mc.gotoAndPlay("fadout");
      }
   }
}

