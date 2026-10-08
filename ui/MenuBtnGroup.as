package net.play5d.game.bvn.ui
{
   import com.greensock.TweenLite;
   import com.greensock.easing.Back;
   import flash.display.Sprite;
   import flash.geom.Point;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.MainGame;
   import net.play5d.game.bvn.ctrl.GameRender;
   import net.play5d.game.bvn.data.GameMode;
   import net.play5d.game.bvn.data.MessionModel;
   import net.play5d.game.bvn.events.GameEvent;
   import net.play5d.game.bvn.input.GameInputer;
   import net.play5d.game.bvn.interfaces.GameInterface;
   import net.play5d.game.bvn.utils.TouchMoveEvent;
   import net.play5d.game.bvn.utils.TouchUtils;
   
   public class MenuBtnGroup extends Sprite
   {
      
      public var enabled:Boolean = true;
      
      protected var _btnConfig:Array;
      
      protected var _xadd:Number = -40;
      
      protected var _yadd:Number = 5;
      
      private var _btnIndex:int;
      
      private var _startPoint:Point;
      
      private var _btnHeight:Number = 0;
      
      private var _btns:Array = [];
      
      private var _showIngChildrenBtn:MenuBtn;
      
      public function MenuBtnGroup()
      {
         super();
         this.scaleX = 0.8;
         this.scaleY = 0.8;
         if(GameConfig.TOUCH_MODE)
         {
            TouchUtils.I.listenOneFinger(MainGame.I.stage,touchMoveHandler,false,true);
         }
      }
      
      private function touchMoveHandler(param1:TouchMoveEvent) : void
      {
         var _loc3_:* = NaN;
         var _loc2_:Number = Number(NaN);
         if(param1.type == "EVENT_TOUCH_MOVE")
         {
            this.y += param1.deltaY;
         }
         if(param1.type == "EVENT_TOUCH_END")
         {
            _loc3_ = -1;
            if(param1.endY > param1.startY)
            {
               if(this.y > _startPoint.y)
               {
                  _loc3_ = _startPoint.y;
               }
            }
            if(param1.endY < param1.startY)
            {
               _loc2_ = GameConfig.GAME_SIZE.y - this.height - 10;
               if(this.y < _loc2_)
               {
                  _loc3_ = _loc2_;
               }
            }
            if(_loc3_ != -1)
            {
               TweenLite.to(this,0.2,{"y":_loc3_});
            }
         }
      }
      
      public function destory() : void
      {
         GameRender.remove(render);
         TouchUtils.I.unlistenOneFinger(MainGame.I.stage);
         for each(var _loc1_ in _btns)
         {
            _loc1_.removeEventListener("touchTap",touchHandler);
            _loc1_.removeEventListener("click",mouseHandler);
            _loc1_.removeEventListener("mouseOver",mouseHandler);
            _loc1_.dispose();
         }
         _btns = null;
      }
      
      public function fadIn(param1:Number = 0.5, param2:Number = 0.05) : void
      {
         var _loc4_:int = 0;
         var _loc3_:MenuBtn = null;
         while(_loc4_ < _btns.length)
         {
            _loc3_ = _btns[_loc4_];
            _loc3_.ui.scaleX = 0.01;
            TweenLite.to(_loc3_.ui,param1,{
               "scaleX":1,
               "delay":_loc4_ * param2,
               "ease":Back.easeOut
            });
            _loc4_++;
         }
      }
      
      public function build() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Object = null;
         this.y -= 30;
         _startPoint = new Point(x,y);
         _btnConfig = GameInterface.instance.getGameMenu();
         if(!_btnConfig)
         {
            _btnConfig = GameInterface.getDefaultMenu();
         }
         while(_loc1_ < _btnConfig.length)
         {
            _loc2_ = _btnConfig[_loc1_];
            addMenuBtn(_loc2_);
            _loc1_++;
         }
         setBtns(true,false);
         if(!GameConfig.TOUCH_MODE)
         {
            hoverBtn(_btns[0]);
         }
         if(GameConfig.TOUCH_MODE)
         {
            this.y += 50;
         }
         GameRender.add(render);
      }
      
      private function addMenuBtn(param1:Object, param2:Boolean = false) : MenuBtn
      {
         var _loc6_:int = 0;
         var _loc4_:Object = null;
         var _loc7_:MenuBtn = null;
         var _loc3_:MenuBtn = new MenuBtn(param1.txt,param1.cn,param1.func);
         if(GameConfig.TOUCH_MODE)
         {
            _loc3_.addEventListener("touchTap",touchHandler);
         }
         else
         {
            _loc3_.addEventListener("click",mouseHandler);
            _loc3_.addEventListener("mouseOver",mouseHandler);
         }
         if(!param2)
         {
            _loc3_.index = _btns.length;
            _btns.push(_loc3_);
            if(_btnHeight == 0)
            {
               _btnHeight = _loc3_.height;
            }
         }
         var _loc5_:Array = param1.children;
         if(_loc5_)
         {
            _loc3_.children = [];
            _loc6_ = 0;
            while(_loc6_ < _loc5_.length)
            {
               _loc4_ = _loc5_[_loc6_];
               _loc7_ = addMenuBtn(_loc4_,true);
               _loc3_.children.push(_loc7_);
               _loc7_.childMode();
               _loc7_.index = _loc6_;
               _loc6_++;
            }
         }
         return _loc3_;
      }
      
      private function touchEndHandler() : void
      {
         if(!_startPoint || _btns.length < 7)
         {
            return;
         }
         var _loc3_:Number = GameConfig.GAME_SIZE.y - 10;
         var _loc4_:Number = _startPoint.y + this.height;
         if(_loc4_ < _loc3_)
         {
            return;
         }
         var _loc6_:Number = _loc3_ - _startPoint.y;
         var _loc5_:Number = _loc6_ / _btns.length;
         var _loc2_:Number = _btnHeight + _yadd;
         var _loc1_:Number = _btnIndex * (_loc5_ - _loc2_) + _startPoint.y;
         TweenLite.to(this,0.2,{"y":_loc1_});
      }
      
      protected function mouseHandler(param1:String, param2:MenuBtn) : void
      {
         if(!enabled)
         {
            return;
         }
         switch(param1)
         {
            case "mouseOver":
               hoverBtn(param2);
               break;
            case "click":
               selectBtn(param2);
         }
      }
      
      protected function touchHandler(param1:String, param2:MenuBtn) : void
      {
         if(TouchUtils.I.isDraging())
         {
            return;
         }
         if(param2.children && param2.children.length > 0)
         {
            hoverBtn(param2);
            selectBtn(param2);
            return;
         }
         if(!param2.isHover())
         {
            hoverBtn(param2,false);
         }
         else
         {
            selectBtn(param2);
         }
      }
      
      private function moveScroll() : void
      {
         if(!_startPoint || _btns.length < 7)
         {
            return;
         }
         var _loc3_:Number = GameConfig.GAME_SIZE.y - 10;
         var _loc4_:Number = _startPoint.y + this.height;
         if(_loc4_ < _loc3_)
         {
            return;
         }
         var _loc6_:Number = _loc3_ - _startPoint.y;
         var _loc5_:Number = _loc6_ / _btns.length;
         var _loc2_:Number = _btnHeight + _yadd;
         var _loc1_:Number = _btnIndex * (_loc5_ - _loc2_) + _startPoint.y;
         TweenLite.to(this,0.2,{"y":_loc1_});
      }
      
      private function hoverBtn(param1:MenuBtn, param2:Boolean = true) : void
      {
         var _loc3_:MenuBtn = null;
         var _loc5_:int = 0;
         var _loc4_:Array = null;
         var _loc6_:int = 0;
         while(_loc5_ < _btns.length)
         {
            _loc3_ = _btns[_loc5_];
            if(_loc3_ == param1)
            {
               _loc3_.hover();
               _btnIndex = _loc5_;
               if(param2)
               {
                  moveScroll();
               }
            }
            else
            {
               _loc3_.normal();
            }
            _loc5_++;
         }
         if(_showIngChildrenBtn)
         {
            _loc4_ = _showIngChildrenBtn.children;
            while(_loc6_ < _loc4_.length)
            {
               _loc3_ = _loc4_[_loc6_];
               if(_loc3_ == param1)
               {
                  _loc3_.hover();
                  _btnIndex = _loc6_;
               }
               else
               {
                  _loc3_.normal();
               }
               _loc6_++;
            }
         }
      }
      
      protected function selectBtn(param1:MenuBtn) : void
      {
         var func:Function;
         var callFunc:Function;
         var target:MenuBtn = param1;
         if(target.children)
         {
            toogleChildren(target);
            return;
         }
         if(Boolean(target.func))
         {
            func = target.func;
         }
         else
         {
            func = getFucByLabel(target.label);
         }
         callFunc = function():void
         {
            if(func != null)
            {
               func();
            }
            this.mouseEnabled = this.mouseChildren = true;
            enabled = true;
         };
         enabled = false;
         target.select(callFunc);
      }
      
      private function getFucByLabel(param1:String) : Function
      {
         var func:Function;
         var label:String = param1;
         switch(label)
         {
            case "TEAM MODE":
               func = function():void
               {
                  GameMode.currentMode = 10;
                  MessionModel.I.reset();
                  if(GameConfig.SHOW_HOW_TO_PLAY)
                  {
                     MainGame.I.goHowToPlay();
                  }
                  else
                  {
                     MainGame.I.goSelect();
                  }
                  GameEvent.dispatchEvent("ENTER_TEAM_STAGE");
               };
               break;
            case "TEAM VS PEOPLE":
               func = function():void
               {
                  GameMode.currentMode = 11;
                  MainGame.I.goSelect();
                  GameEvent.dispatchEvent("ENTER_TEAM_STAGE");
               };
               break;
            case "SINGLE MODE":
               func = function():void
               {
                  GameMode.currentMode = 20;
                  MessionModel.I.reset();
                  if(GameConfig.SHOW_HOW_TO_PLAY)
                  {
                     MainGame.I.goHowToPlay();
                  }
                  else
                  {
                     MainGame.I.goSelect();
                  }
                  GameEvent.dispatchEvent("ENTER_SINGLE_STAGE");
               };
               break;
            case "SINGLE VS PEOPLE":
               func = function():void
               {
                  GameMode.currentMode = 21;
                  MainGame.I.goSelect();
                  GameEvent.dispatchEvent("ENTER_SINGLE_STAGE");
               };
               break;
            case "ENDLESS MODE":
               func = function():void
               {
                  GameMode.currentMode = 30;
                  MessionModel.I.reset();
                  MainGame.I.goSelect();
               };
               break;
            case "STORY MODE":
               func = function():void
               {
                  GameMode.currentMode = 100;
                  MainGame.I.goWorldMap();
                  GameEvent.dispatchEvent("ENTER_MOSOU_STAGE");
               };
               break;
            case "OPTION":
               func = function():void
               {
                  GameMode.currentMode = 401;
                  MainGame.I.goOption();
               };
               break;
            case "TRAINING":
               func = function():void
               {
                  GameMode.currentMode = 40;
                  MainGame.I.goSelect();
                  GameEvent.dispatchEvent("ENTER_TRAIN_STAGE");
               };
               break;
            case "CREDITS":
               func = function():void
               {
                  MainGame.I.goCredits();
               };
               break;
            case "UPDATE":
               func = function():void
               {
                  MainGame.I.moreGames();
               };
         }
         return func;
      }
      
      private function toogleChildren(param1:MenuBtn) : void
      {
         var _loc2_:* = false;
         if(_showIngChildrenBtn)
         {
            _loc2_ = param1 == _showIngChildrenBtn;
            if(!_loc2_)
            {
               _showIngChildrenBtn.normal();
            }
            closeChildren(_loc2_,_loc2_);
            if(_loc2_)
            {
               return;
            }
         }
         _showIngChildrenBtn = param1;
         setBtns(true,true);
         param1.openChild();
         hoverBtn(param1.children[0]);
      }
      
      private function closeChildren(param1:Boolean, param2:Boolean) : void
      {
         var _loc5_:int = 0;
         var _loc3_:MenuBtn = null;
         var _loc4_:Array = _showIngChildrenBtn.children;
         _loc5_ = 0;
         while(_loc5_ < _loc4_.length)
         {
            _loc3_ = _loc4_[_loc5_];
            try
            {
               removeChild(_loc3_.ui);
            }
            catch(e:Error)
            {
            }
            _loc5_++;
         }
         _showIngChildrenBtn.closeChild();
         _showIngChildrenBtn = null;
         if(param1)
         {
            setBtns(false,param2);
         }
      }
      
      private function setBtns(param1:Boolean, param2:Boolean = false) : void
      {
         var _loc4_:int = 0;
         var _loc3_:MenuBtn = null;
         var _loc5_:int = 0;
         var _loc8_:MenuBtn = null;
         var _loc6_:Number = 0;
         var _loc7_:Number = 0;
         while(_loc4_ < _btns.length)
         {
            _loc3_ = _btns[_loc4_];
            if(param2)
            {
               TweenLite.to(_loc3_.ui,0.2,{
                  "x":_loc6_,
                  "y":_loc7_
               });
            }
            else
            {
               _loc3_.ui.x = _loc6_;
               _loc3_.ui.y = _loc7_;
            }
            _loc6_ += _xadd;
            _loc7_ += _loc3_.height + _yadd;
            if(param1)
            {
               addChild(_loc3_.ui);
            }
            if(_showIngChildrenBtn == _loc3_)
            {
               while(_loc5_ < _loc3_.children.length)
               {
                  _loc8_ = _loc3_.children[_loc5_];
                  _loc8_.ui.x = _loc6_;
                  _loc8_.ui.y = _loc7_;
                  if(param2)
                  {
                     _loc8_.ui.scaleX = 0.01;
                     TweenLite.to(_loc8_.ui,0.2,{
                        "scaleX":1,
                        "delay":_loc5_ * 0.04,
                        "ease":Back.easeOut
                     });
                  }
                  if(param1)
                  {
                     addChild(_loc8_.ui);
                  }
                  _loc6_ += _xadd;
                  _loc7_ += _loc8_.height + _yadd;
                  _loc5_++;
               }
            }
            _loc4_++;
         }
      }
      
      private function render() : void
      {
         if(!enabled)
         {
            return;
         }
         if(GameUI.showingDialog())
         {
            return;
         }
         var _loc1_:Array = _showIngChildrenBtn ? _showIngChildrenBtn.children : _btns;
         if(GameInputer.up("MENU",1))
         {
            --_btnIndex;
            if(_btnIndex < 0)
            {
               _btnIndex = _loc1_.length - 1;
            }
            hoverBtn(_loc1_[_btnIndex]);
         }
         if(GameInputer.down("MENU",1))
         {
            ++_btnIndex;
            if(_btnIndex > _loc1_.length - 1)
            {
               _btnIndex = 0;
            }
            hoverBtn(_loc1_[_btnIndex]);
         }
         if(GameInputer.select("MENU",1))
         {
            selectBtn(_loc1_[_btnIndex]);
         }
         if(GameInputer.back(1))
         {
            if(_showIngChildrenBtn)
            {
               _btnIndex = _showIngChildrenBtn.index;
               closeChildren(true,true);
            }
         }
      }
   }
}

