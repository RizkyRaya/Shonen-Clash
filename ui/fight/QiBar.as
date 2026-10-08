package net.play5d.game.bvn.ui.fight
{
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   import net.play5d.game.bvn.ctrl.AssetManager;
   import net.play5d.game.bvn.fighter.Assister;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.ui.GameUI;
   import net.play5d.kyo.utils.KyoUtils;
   
   public class QiBar
   {
      
      private var _ui:qbar_mc;
      
      private var _fighter:FighterMain;
      
      private var _bar:InsBar;
      
      private var _fzBar:InsFzBar;
      
      private var _fzReadyMc:MovieClip;
      
      private var _qiRate:Number = 0;
      
      private var _fzRate:Number = 0;
      
      private var _orgPose:Point;
      
      private var _tweenSpd:Number = 0.5;
      
      private var _moveFin:Boolean = true;
      
      private var _moveType:int = 0;
      
      private var _isFadIn:Boolean;
      
      private var _isRenderAnimate:Boolean;
      
      private var _faceBp:Bitmap;
      
      public function QiBar(param1:qbar_mc)
      {
         super();
         _ui = param1;
         _bar = new InsBar(_ui.barmc);
         _fzBar = new InsFzBar(_ui.fzqibar);
         _fzReadyMc = _ui.readymc;
         _orgPose = new Point(_ui.x,_ui.y);
         _ui.addEventListener("complete",uiPlayComplete);
         if(GameUI.BITMAP_UI)
         {
            _ui.gotoAndStop("fadin_fin");
            _ui.visible = false;
         }
      }
      
      public function destory() : void
      {
         if(_ui)
         {
            _ui.removeEventListener("complete",uiPlayComplete);
            _ui.gotoAndStop("destory");
            _ui = null;
         }
         if(_faceBp)
         {
            _faceBp.bitmapData.dispose();
            _faceBp = null;
         }
         _fighter = null;
      }
      
      private function uiPlayComplete(param1:Event) : void
      {
         if(_isFadIn)
         {
            _ui.visible = true;
            setCacheBitmap(true);
         }
         else
         {
            _ui.visible = false;
         }
      }
      
      public function setFighter(param1:FighterMain, param2:Assister = null) : void
      {
         var _loc3_:DisplayObject = null;
         _fighter = param1;
         if(param2 && param2.data)
         {
            _loc3_ = AssetManager.I.getFighterFace(param2.data);
            if(_loc3_)
            {
               _ui.facemc.ct.addChild(_loc3_);
            }
         }
         if(GameUI.BITMAP_UI)
         {
            _faceBp = KyoUtils.drawDisplay(_ui.facemc);
            _ui.addChild(_faceBp);
            _faceBp.x = _ui.facemc.x;
            _faceBp.y = _ui.facemc.y;
            try
            {
               _ui.removeChild(_ui.facemc);
            }
            catch(e:Error)
            {
            }
            _ui.addChild(_ui.readymc);
         }
      }
      
      private function setCacheBitmap(param1:Boolean) : void
      {
         if(GameUI.BITMAP_UI)
         {
            return;
         }
         _ui.facemc.cacheAsBitmap = param1;
      }
      
      public function setDirect(param1:int) : void
      {
         _bar.setDirect(param1);
         _fzReadyMc.mc.scaleX = param1 > 0 ? 1 : -1;
      }
      
      public function render() : void
      {
         _qiRate = _fighter.qi / 100;
         if(_qiRate > 3)
         {
            _qiRate = 3;
         }
         var _loc2_:Number = _bar.getProcess();
         var _loc3_:Number = _qiRate - _loc2_;
         if(Math.abs(_loc3_) < 0.01)
         {
            _bar.setProcess(_qiRate);
         }
         else
         {
            _bar.setProcess(_loc2_ + _loc3_ * 0.4);
         }
         _fzBar.setProcess(_fighter.fzqi / 100);
         var _loc1_:Boolean = _fzBar.getProcess() >= 1;
         if(_fzReadyMc.visible != _loc1_)
         {
            _fzReadyMc.visible = _loc1_;
            if(_loc1_)
            {
               _fzReadyMc.mc.play();
            }
            else
            {
               _fzReadyMc.mc.gotoAndStop(1);
            }
         }
      }
      
      public function renderAnimate() : void
      {
         if(!_isRenderAnimate)
         {
            return;
         }
         var _loc1_:String = _ui.currentFrameLabel;
         if(_loc1_ == "fadin_fin" || _loc1_ == "fadout_fin")
         {
            _isRenderAnimate = false;
            return;
         }
         _ui.nextFrame();
      }
      
      public function fadIn(param1:Boolean = true) : void
      {
         if(_isFadIn)
         {
            return;
         }
         _isFadIn = true;
         _ui.visible = true;
         if(GameUI.BITMAP_UI)
         {
            return;
         }
         if(param1)
         {
            setCacheBitmap(false);
            _ui.gotoAndStop("fadin");
            _isRenderAnimate = true;
         }
         else
         {
            _ui.gotoAndStop("fadin_fin");
            setCacheBitmap(true);
         }
      }
      
      public function fadOut(param1:Boolean = true) : void
      {
         if(!_isFadIn)
         {
            return;
         }
         _isFadIn = false;
         if(GameUI.BITMAP_UI)
         {
            _ui.visible = false;
            return;
         }
         if(param1)
         {
            _ui.gotoAndStop("fadout");
            _isRenderAnimate = true;
            setCacheBitmap(false);
         }
         else
         {
            _ui.visible = false;
         }
      }
      
      public function moveTo(param1:Number, param2:Number, param3:Number) : void
      {
         if(_moveType == 1)
         {
            if(_moveFin)
            {
               return;
            }
         }
         else
         {
            _moveType = 1;
            _moveFin = false;
         }
         moving(param1,param2,param3);
      }
      
      public function moveResume() : void
      {
         if(_moveType == 0)
         {
            if(_moveFin)
            {
               return;
            }
         }
         else
         {
            _moveType = 0;
            _moveFin = false;
         }
         moving(_orgPose.x,_orgPose.y,1);
      }
      
      private function moving(param1:Number, param2:Number, param3:Number) : void
      {
         if(Math.abs(param1 - _ui.x) < 2 && Math.abs(param2 - _ui.y) < 2 && Math.abs(param3 - _ui.scaleX) < 0.2)
         {
            _ui.x = param1;
            _ui.y = param2;
            _ui.scaleX = _ui.scaleY = param3;
            _moveFin = true;
         }
         _ui.x += (param1 - _ui.x) * _tweenSpd;
         _ui.y += (param2 - _ui.y) * _tweenSpd;
         _ui.scaleX += (param3 - _ui.scaleX) * _tweenSpd;
         _ui.scaleY = _ui.scaleX;
      }
      
      public function setPosAndScale(param1:Number, param2:Number, param3:Number) : void
      {
         _ui.x = param1;
         _ui.y = param2;
         _ui.scaleX = param3;
         _ui.scaleY = param3;
      }
   }
}

import flash.display.DisplayObject;
import flash.geom.Rectangle;

class InsBar
{
   
   private var _ui:qbar_barmc;
   
   private var _process:Number = 0;
   
   public function InsBar(param1:qbar_barmc)
   {
      super();
      _ui = param1;
      setProcess(0);
   }
   
   public function get ui() : DisplayObject
   {
      return _ui;
   }
   
   public function getProcess() : Number
   {
      return _process;
   }
   
   public function setProcess(param1:Number) : void
   {
      _process = param1;
      _ui.bar.bar1.visible = param1 > 0;
      _ui.bar.bar2.visible = param1 > 1;
      _ui.bar.bar3.visible = param1 > 2;
      _ui.bar.bar4.visible = param1 >= 3;
      if(param1 > 2)
      {
         _ui.bar.bar1.scaleX = _ui.bar.bar2.scaleX = 1;
         _ui.bar.bar3.scaleX = param1 - 2;
      }
      else if(param1 > 1)
      {
         _ui.bar.bar1.scaleX = 1;
         _ui.bar.bar2.scaleX = param1 - 1;
      }
      else
      {
         _ui.bar.bar1.scaleX = param1;
      }
      var _loc2_:int = int(param1) + 1;
      _ui.txtmc.gotoAndStop(_loc2_);
   }
   
   public function setDirect(param1:int) : void
   {
      _ui.txtmc.scaleX = param1 > 0 ? 1 : -1;
   }
}

class InsFzBar
{
   
   private var _ui:qbar_fzqi_mc;
   
   private var _process:Number = 0;
   
   private var _scroll:Rectangle;
   
   private var _height:Number;
   
   public function InsFzBar(param1:qbar_fzqi_mc)
   {
      super();
      _ui = param1;
      var _loc2_:Rectangle = _ui.barmc.getBounds(_ui.barmc);
      _scroll = new Rectangle(0,0,_ui.barmc.width,_ui.barmc.height);
      _height = _scroll.height;
      _ui.barmc.scaleY = -1;
      _ui.barmc.y = _ui.barmc.height;
   }
   
   public function get ui() : DisplayObject
   {
      return _ui;
   }
   
   public function getProcess() : Number
   {
      return _process;
   }
   
   public function setProcess(param1:Number) : void
   {
      _process = param1;
      _scroll.height = param1 * _height;
      _ui.barmc.scrollRect = _scroll;
   }
}
