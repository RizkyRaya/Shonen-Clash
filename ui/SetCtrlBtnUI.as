package net.play5d.game.bvn.ui
{
   import com.greensock.TweenLite;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.EventDispatcher;
   import flash.events.KeyboardEvent;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.MainGame;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.data.KeyConfigVO;
   import net.play5d.game.bvn.events.SetBtnEvent;
   import net.play5d.game.bvn.interfaces.IInnerSetUI;
   import net.play5d.game.bvn.utils.ResUtils;
   import net.play5d.kyo.input.KyoKeyCode;
   
   public class SetCtrlBtnUI extends EventDispatcher implements IInnerSetUI
   {
      
      public var ui:keyset_mc;
      
      private var _keyMappings:Array;
      
      private var _keyMap:Object;
      
      private var _keyConfig:KeyConfigVO;
      
      private var _btnGroup:SetBtnGroup;
      
      private var _dialog:SetBtnDialog;
      
      private var _tmpKeyConfig:KeyConfigVO;
      
      private var _setKeyIndex:int;
      
      public function SetCtrlBtnUI()
      {
         super();
         ui = ResUtils.I.createDisplayObject(ResUtils.I.setting,"keyset_mc");
         _btnGroup = new SetBtnGroup();
         _btnGroup.startY = 30;
         _btnGroup.initKeySet();
         _btnGroup.addEventListener("SELECT",onBtnSelect);
         ui.addChild(_btnGroup);
         _dialog = new SetBtnDialog();
         ui.addChild(_dialog.ui);
         initKeyMapping();
      }
      
      public function destory() : void
      {
         if(_btnGroup)
         {
            try
            {
               ui.removeChild(_btnGroup);
            }
            catch(e:Error)
            {
            }
            _btnGroup.removeEventListener("SELECT",onBtnSelect);
            _btnGroup.destory();
            _btnGroup = null;
         }
      }
      
      public function getUI() : DisplayObject
      {
         return ui;
      }
      
      public function setKey(param1:KeyConfigVO) : void
      {
         _keyConfig = param1;
         _tmpKeyConfig = param1.clone();
         updateKeyMapping();
      }
      
      private function updateKeyMapping() : void
      {
         _keyMap["up"].setKey(_tmpKeyConfig.up);
         _keyMap["down"].setKey(_tmpKeyConfig.down);
         _keyMap["left"].setKey(_tmpKeyConfig.left);
         _keyMap["right"].setKey(_tmpKeyConfig.right);
         _keyMap["attack"].setKey(_tmpKeyConfig.attack);
         _keyMap["jump"].setKey(_tmpKeyConfig.jump);
         _keyMap["dash"].setKey(_tmpKeyConfig.dash);
         _keyMap["skill"].setKey(_tmpKeyConfig.skill);
         _keyMap["superKill"].setKey(_tmpKeyConfig.superKill);
         _keyMap["beckons"].setKey(_tmpKeyConfig.beckons);
      }
      
      private function initKeyMapping() : void
      {
         var _loc4_:int = 0;
         var _loc5_:Sprite = null;
         var _loc6_:Object = null;
         var _loc2_:KeyMapping = null;
         var _loc1_:MovieClip = ui.keysmc;
         var _loc3_:Array = [{
            "id":"up",
            "name":"UP",
            "cn":"上"
         },{
            "id":"down",
            "name":"DOWN",
            "cn":"下"
         },{
            "id":"left",
            "name":"LEFT",
            "cn":"左"
         },{
            "id":"right",
            "name":"RIGHT",
            "cn":"右"
         },{
            "id":"attack",
            "name":"ATTACK",
            "cn":"攻击"
         },{
            "id":"jump",
            "name":"JUMP",
            "cn":"跳跃"
         },{
            "id":"dash",
            "name":"DASH",
            "cn":"冲刺"
         },{
            "id":"skill",
            "name":"SKILL",
            "cn":"技能"
         },{
            "id":"superKill",
            "name":"SUPER SKILL",
            "cn":"大招"
         },{
            "id":"beckons",
            "name":"SPECIAL",
            "cn":"特殊"
         }];
         _keyMappings = [];
         _keyMap = {};
         while(_loc4_ < _loc3_.length)
         {
            _loc5_ = _loc1_.getChildByName("k" + _loc4_) as Sprite;
            _loc6_ = _loc3_[_loc4_];
            if(!_loc5_)
            {
               trace("mc[k" + _loc4_ + "]不存在！");
            }
            else
            {
               _loc2_ = new KeyMapping(_loc5_,_loc6_.id,_loc6_.name,_loc6_.cn);
               _keyMappings.push(_loc2_);
               _keyMap[_loc2_.keyId] = _loc2_;
            }
            _loc4_++;
         }
      }
      
      private function onBtnSelect(param1:SetBtnEvent) : void
      {
         switch(param1.selectedLabel)
         {
            case "SET ALL":
               MainGame.I.stage.addEventListener("keyDown",onKeyDown);
               MainGame.I.stage.focus = MainGame.I.stage;
               _setKeyIndex = -1;
               _btnGroup.keyEnable = false;
               setNextKey();
               break;
            case "SET DEFAULT":
               GameData.I.config.setDefaultConfig(_tmpKeyConfig);
               updateKeyMapping();
               break;
            case "APPLY":
               _keyConfig.readSaveObj(_tmpKeyConfig.toSaveObj());
               dispatchEvent(new SetBtnEvent("APPLY_SET"));
               break;
            case "CANCEL":
               dispatchEvent(new SetBtnEvent("CANCEL_SET"));
         }
      }
      
      private function setNextKey() : void
      {
         _setKeyIndex = _setKeyIndex + 1;
         var _loc1_:KeyMapping = _keyMappings[_setKeyIndex];
         if(_loc1_)
         {
            _dialog.show(_loc1_.name,_loc1_.cn);
         }
         else
         {
            MainGame.I.stage.removeEventListener("keyDown",onKeyDown);
            _btnGroup.keyEnable = true;
         }
      }
      
      private function onKeyDown(param1:KeyboardEvent) : void
      {
         if(!_dialog.isShow)
         {
            return;
         }
         var _loc2_:KeyMapping = _keyMappings[_setKeyIndex];
         if(!_loc2_)
         {
            return;
         }
         var _loc4_:String = _loc2_.keyId;
         if(!_loc4_)
         {
            return;
         }
         var _loc3_:String = KyoKeyCode.code2name(param1.keyCode);
         if(!_loc3_)
         {
            return;
         }
         _tmpKeyConfig[_loc4_] = param1.keyCode;
         _loc2_.setKey(param1.keyCode,_loc3_);
         _dialog.hide();
         setNextKey();
      }
      
      public function fadIn() : void
      {
         var duration:Number = 0.3;
         ui.y = GameConfig.GAME_SIZE.y;
         TweenLite.to(ui,duration,{
            "y":0,
            "onComplete":function():void
            {
               _btnGroup.keyEnable = true;
            }
         });
         _btnGroup.setArrowIndex(0);
         ui.visible = true;
      }
      
      public function fadOut() : void
      {
         var duration:Number = 0.3;
         _btnGroup.keyEnable = false;
         TweenLite.to(ui,duration,{
            "y":GameConfig.GAME_SIZE.y,
            "onComplete":function():void
            {
               ui.visible = false;
            }
         });
      }
   }
}

