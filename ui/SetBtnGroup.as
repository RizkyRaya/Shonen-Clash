package net.play5d.game.bvn.ui
{
   import com.greensock.TweenLite;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.events.TouchEvent;
   import flash.geom.Rectangle;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.ctrl.GameRender;
   import net.play5d.game.bvn.ctrl.SoundCtrl;
   import net.play5d.game.bvn.data.ConfigVO;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.events.SetBtnEvent;
   import net.play5d.game.bvn.input.GameInputer;
   import net.play5d.game.bvn.interfaces.GameInterface;
   import net.play5d.game.bvn.utils.ResUtils;
   import net.play5d.game.bvn.utils.TouchMoveEvent;
   import net.play5d.game.bvn.utils.TouchUtils;
   
   public class SetBtnGroup extends Sprite
   {
      
      public var keyEnable:Boolean = true;
      
      public var startX:Number = 60;
      
      public var startY:Number = 50;
      
      public var endY:Number = 0;
      
      public var gap:Number = 75;
      
      public var direct:int = 1;
      
      public var gameInputType:String = "MENU";
      
      private var _btns:Vector.<SetBtn>;
      
      private var _arrow:select_arrow_mc;
      
      private var _arrowIndex:int = -1;
      
      private var _scrollRect:Rectangle;
      
      public function SetBtnGroup()
      {
         super();
         this.scaleX = this.scaleY = 0.85;
         if(GameConfig.TOUCH_MODE)
         {
            this.scaleX = this.scaleY = 0.9;
            TouchUtils.I.listenOneFinger(this,touchMoveHandler,false,true);
         }
      }
      
      private function touchMoveHandler(param1:TouchMoveEvent) : void
      {
         var _loc4_:Number = Number(NaN);
         var _loc2_:Number = Number(NaN);
         var _loc3_:Number = Number(NaN);
         if(!_scrollRect)
         {
            return;
         }
         if(param1.type == "EVENT_TOUCH_MOVE")
         {
            _scrollRect.y -= param1.deltaY;
            updateScroll();
         }
         if(param1.type == "EVENT_TOUCH_END")
         {
            _loc4_ = -1;
            if(param1.endY > param1.startY)
            {
               if(_scrollRect.y < 0)
               {
                  _loc4_ = 0;
               }
            }
            if(param1.endY < param1.startY)
            {
               _loc2_ = endY != 0 ? endY : _scrollRect.height;
               _loc3_ = GameConfig.GAME_SIZE.y - _loc2_ + 100;
               if(_scrollRect.y > _loc3_)
               {
                  _loc4_ = _loc3_;
               }
            }
            if(_loc4_ != -1)
            {
               TweenLite.to(_scrollRect,0.2,{
                  "y":_loc4_,
                  "onUpdate":updateScroll
               });
            }
         }
      }
      
      public function initScroll(param1:Number, param2:Number) : void
      {
         _scrollRect = new Rectangle(0,0,param1,param2);
         this.scrollRect = _scrollRect;
      }
      
      public function initMainSet() : void
      {
         initMainBtns();
         initArrow();
         GameRender.add(render,this);
         GameInputer.focus();
         GameInputer.enabled = true;
      }
      
      public function initKeySet() : void
      {
         setBtnData([{
            "label":"SET ALL",
            "cn":"设置全部"
         },{
            "label":"SET DEFAULT",
            "cn":"还原默认按键"
         },{
            "label":"APPLY",
            "cn":"应用"
         },{
            "label":"CANCEL",
            "cn":"取消"
         }]);
      }
      
      public function setBtnData(param1:Array, param2:int = 0) : void
      {
         var _loc4_:SetBtn = null;
         var _loc3_:int = 0;
         var _loc5_:Object = null;
         _btns = new Vector.<SetBtn>();
         while(_loc3_ < param1.length)
         {
            _loc5_ = param1[_loc3_];
            _loc4_ = addBtn(_loc5_.label,_loc5_.cn,_loc5_.options);
            if(_loc5_.optoinKey != undefined)
            {
               _loc4_.optionKey = _loc5_.optoinKey;
            }
            if(_loc5_.optionValue != undefined)
            {
               _loc4_.setOptionByValue(_loc5_.optionValue);
            }
            _loc3_++;
         }
         initArrow(param2);
         GameRender.add(render,this);
         GameInputer.focus();
         GameInputer.enabled = true;
      }
      
      public function destory() : void
      {
         if(_btns)
         {
            for each(var _loc1_ in _btns)
            {
               _loc1_.destory();
               _loc1_.removeEventListener("touchTap",touchHandler);
               _loc1_.removeEventListener("mouseOver",mouseHandler);
               _loc1_.removeEventListener("click",mouseHandler);
               _loc1_.removeEventListener("OPTION_CHANGE",onChangeOption);
               _loc1_.removeEventListener("SELECT",onSelect);
            }
            _btns = null;
         }
         GameRender.remove(render,this);
         TouchUtils.I.unlistenOneFinger(this);
      }
      
      private function initMainBtns() : void
      {
         var _loc3_:SetBtn = null;
         var _loc1_:int = 0;
         var _loc5_:Object = null;
         _btns = new Vector.<SetBtn>();
         var _loc2_:Array = GameInterface.instance.getSettingMenu();
         if(!_loc2_)
         {
            _loc2_ = [{
               "txt":"P1 KEY SET",
               "cn":"玩家1 按键设置"
            },{
               "txt":"P2 KEY SET",
               "cn":"玩家2 按键设置"
            },{
               "txt":"COM LEVEL",
               "cn":"电脑等级",
               "options":[{
                  "label":"VERY EASY",
                  "cn":"非常简单",
                  "value":1
               },{
                  "label":"EASY",
                  "cn":"简单",
                  "value":2
               },{
                  "label":"NORMAL",
                  "cn":"正常",
                  "value":3
               },{
                  "label":"HARD",
                  "cn":"困难",
                  "value":4
               },{
                  "label":"VERY HARD",
                  "cn":"非常困难",
                  "value":5
               },{
                  "label":"HELL",
                  "cn":"地狱",
                  "value":6
               }],
               "optoinKey":"AI_level"
            },{
               "txt":"OPERATE MODE",
               "cn":"按键操作模式",
               "options":[{
                  "label":"NORMAL",
                  "cn":"正常模式",
                  "value":0
               },{
                  "label":"CLASSIC",
                  "cn":"经典模式",
                  "value":1
               }],
               "optoinKey":"keyInputMode"
            },{
               "txt":"LIFE",
               "cn":"生命值",
               "options":[{
                  "label":"50%",
                  "cn":"50%",
                  "value":0.5
               },{
                  "label":"100%",
                  "cn":"100%",
                  "value":1
               },{
                  "label":"200%",
                  "cn":"200%",
                  "value":2
               },{
                  "label":"300%",
                  "cn":"300%",
                  "value":3
               },{
                  "label":"500%",
                  "cn":"500%",
                  "value":5
               }],
               "optoinKey":"fighterHP"
            },{
               "txt":"TIME",
               "cn":"对战时间",
               "options":[{
                  "label":"30s",
                  "cn":"30秒",
                  "value":30
               },{
                  "label":"60s",
                  "cn":"60秒",
                  "value":60
               },{
                  "label":"90s",
                  "cn":"90秒",
                  "value":90
               },{
                  "label":"∞",
                  "cn":"无限制",
                  "value":-1
               }],
               "optoinKey":"fightTime"
            },{
               "txt":"SOUND",
               "cn":"游戏音效",
               "options":[{
                  "label":"0%",
                  "cn":"0%",
                  "value":0
               },{
                  "label":"10%",
                  "cn":"10%",
                  "value":0.1
               },{
                  "label":"30%",
                  "cn":"30%",
                  "value":0.3
               },{
                  "label":"50%",
                  "cn":"50%",
                  "value":0.5
               },{
                  "label":"70%",
                  "cn":"70%",
                  "value":0.7
               },{
                  "label":"100%",
                  "cn":"100%",
                  "value":1
               }],
               "optoinKey":"soundVolume"
            },{
               "txt":"BGM",
               "cn":"背景音乐",
               "options":[{
                  "label":"0%",
                  "cn":"0%",
                  "value":0
               },{
                  "label":"10%",
                  "cn":"10%",
                  "value":0.1
               },{
                  "label":"30%",
                  "cn":"30%",
                  "value":0.3
               },{
                  "label":"50%",
                  "cn":"50%",
                  "value":0.5
               },{
                  "label":"70%",
                  "cn":"70%",
                  "value":0.7
               },{
                  "label":"100%",
                  "cn":"100%",
                  "value":1
               }],
               "optoinKey":"bgmVolume"
            },{
               "txt":"QUALITY",
               "cn":"画质等级",
               "options":[{
                  "label":"LOW",
                  "cn":"低",
                  "value":"low"
               },{
                  "label":"MEDIUM",
                  "cn":"中",
                  "value":"medium"
               },{
                  "label":"HIGH",
                  "cn":"高",
                  "value":"high"
               },{
                  "label":"BEST",
                  "cn":"最高",
                  "value":"best"
               }],
               "optoinKey":"quality"
            }];
         }
         var _loc4_:ConfigVO = GameData.I.config;
         while(_loc1_ < _loc2_.length)
         {
            _loc5_ = _loc2_[_loc1_];
            _loc3_ = addBtn(_loc5_.txt,_loc5_.cn,_loc5_.options);
            if(_loc5_.select)
            {
               _loc3_.onSelect = _loc5_.select;
            }
            _loc3_.optionKey = _loc5_.optoinKey;
            if(_loc3_.optionKey)
            {
               _loc3_.setOptionByValue(_loc4_.getValueByKey(_loc3_.optionKey));
            }
            _loc1_++;
         }
         addBtn("APPLY","应用");
         this.graphics.beginFill(0,0);
         this.graphics.drawRect(0,0,GameConfig.GAME_SIZE.x,_btns[_btns.length - 1].y + 300);
         this.graphics.endFill();
      }
      
      private function addBtn(param1:String, param2:String, param3:Array = null) : SetBtn
      {
         var _loc4_:SetBtn = new SetBtn(param1,param2);
         if(GameConfig.TOUCH_MODE)
         {
            _loc4_.addEventListener("touchTap",touchHandler);
         }
         else
         {
            _loc4_.addEventListener("mouseOver",mouseHandler);
            _loc4_.addEventListener("click",mouseHandler);
         }
         switch(direct)
         {
            case 0:
               _loc4_.x = startX + gap * _btns.length;
               _loc4_.y = startY;
               break;
            case 1:
               _loc4_.x = startX;
               _loc4_.y = startY + gap * _btns.length;
         }
         addChild(_loc4_);
         if(param3)
         {
            _loc4_.setOption(param3);
            _loc4_.addEventListener("OPTION_CHANGE",onChangeOption);
         }
         else
         {
            _loc4_.addEventListener("SELECT",onSelect);
         }
         _btns.push(_loc4_);
         return _loc4_;
      }
      
      private function touchHandler(param1:TouchEvent) : void
      {
         if(!keyEnable)
         {
            return;
         }
         var _loc3_:SetBtn = param1.currentTarget as SetBtn;
         var _loc2_:int = _btns.indexOf(_loc3_);
         if(_loc2_ == -1)
         {
            return;
         }
         var _loc4_:Object = _loc3_.getOption();
         if(_loc2_ == _arrowIndex)
         {
            if(_loc4_ != null)
            {
               _loc3_.nextOption();
            }
            else
            {
               _loc3_.select();
            }
            return;
         }
         setArrowIndex(_loc2_,true,false);
      }
      
      private function mouseHandler(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         if(!keyEnable)
         {
            return;
         }
         var _loc3_:SetBtn = param1.currentTarget as SetBtn;
         switch(param1.type)
         {
            case "mouseOver":
               _loc2_ = _btns.indexOf(_loc3_);
               if(_loc2_ != -1)
               {
                  setArrowIndex(_loc2_);
               }
               break;
            case "click":
               if(_loc3_.getOption() == null)
               {
                  _loc3_.select();
               }
               else if(param1.target)
               {
                  switch(param1.target.name)
                  {
                     case "prevArrow":
                        _loc3_.prevOption();
                        break;
                     case "nextArrow":
                        _loc3_.nextOption();
                  }
               }
         }
      }
      
      private function initArrow(param1:int = 0) : void
      {
         _arrow = ResUtils.I.createDisplayObject(ResUtils.I.common_ui,"select_arrow_mc");
         addChild(_arrow);
         setArrowIndex(param1);
      }
      
      public function setArrowIndex(param1:int, param2:Boolean = true, param3:Boolean = true) : void
      {
         var btn:SetBtn;
         var id:int = param1;
         var sound:Boolean = param2;
         var isScroll:Boolean = param3;
         if(_arrowIndex == id)
         {
            return;
         }
         if(id < 0)
         {
            id = _btns.length - 1;
         }
         if(id > _btns.length - 1)
         {
            id = 0;
         }
         btn = _btns[id];
         _arrowIndex = id;
         _arrow.x = btn.x - 10;
         _arrow.y = btn.y + 15;
         _btns.every(function(param1:SetBtn, param2:int, param3:Vector.<SetBtn>):Boolean
         {
            if(btn == param1)
            {
               param1.hover();
            }
            else
            {
               param1.hoverOut();
            }
            return true;
         });
         if(sound)
         {
            SoundCtrl.I.sndSelect();
         }
         if(isScroll)
         {
            moveScroll();
         }
      }
      
      private function moveScroll() : void
      {
         var _loc2_:Number = Number(NaN);
         var _loc3_:Number = Number(NaN);
         var _loc5_:Number = Number(NaN);
         var _loc4_:Number = Number(NaN);
         var _loc1_:Number = Number(NaN);
         if(!_scrollRect)
         {
            return;
         }
         if(direct == 1)
         {
            if(_btns.length < 8)
            {
               return;
            }
            _loc2_ = endY != 0 ? endY : _scrollRect.height;
            _loc3_ = this.height;
            if(_loc3_ < _loc2_)
            {
               return;
            }
            _loc5_ = _loc2_ - startY;
            _loc4_ = _loc5_ / _btns.length;
            _loc1_ = -_arrowIndex * (_loc4_ - gap);
            TweenLite.to(_scrollRect,0.2,{
               "y":_loc1_,
               "onUpdate":updateScroll
            });
         }
      }
      
      private function updateScroll() : void
      {
         this.scrollRect = _scrollRect;
      }
      
      private function render() : void
      {
         if(!keyEnable)
         {
            return;
         }
         if(!_btns || _btns.length < 1)
         {
            return;
         }
         var _loc1_:SetBtn = _btns[_arrowIndex];
         if(GameInputer.up(gameInputType,1))
         {
            if(direct == 1)
            {
               setArrowIndex(_arrowIndex - 1);
            }
         }
         if(GameInputer.down(gameInputType,1))
         {
            if(direct == 1)
            {
               setArrowIndex(_arrowIndex + 1);
            }
         }
         if(GameInputer.left(gameInputType,1))
         {
            if(direct == 0)
            {
               setArrowIndex(_arrowIndex - 1);
            }
            if(direct == 1)
            {
               _loc1_.prevOption();
            }
         }
         if(GameInputer.right(gameInputType,1))
         {
            if(direct == 0)
            {
               setArrowIndex(_arrowIndex + 1);
            }
            if(direct == 1)
            {
               _loc1_.nextOption();
            }
         }
         if(GameInputer.select(gameInputType,1))
         {
            _loc1_.select();
         }
      }
      
      private function onChangeOption(param1:SetBtnEvent) : void
      {
         dispatchEvent(param1.newEvent());
      }
      
      private function onSelect(param1:SetBtnEvent) : void
      {
         var _loc2_:SetBtn = param1.currentTarget as SetBtn;
         if(_loc2_.onSelect != null)
         {
            _loc2_.onSelect();
         }
         dispatchEvent(param1.newEvent());
      }
   }
}

