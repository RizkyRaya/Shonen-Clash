package net.play5d.game.bvn.mob.ctrls
{
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.ByteArray;
   import flash.utils.Timer;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   import net.play5d.game.bvn.MainGame;
   import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
   import net.play5d.game.bvn.events.GameEvent;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.interfaces.GameInterface;
   import net.play5d.game.bvn.mob.data.HostVO;
   import net.play5d.game.bvn.mob.input.InputManager;
   import net.play5d.game.bvn.mob.sockets.SocketClient;
   import net.play5d.game.bvn.mob.sockets.events.SocketEvent;
   import net.play5d.game.bvn.mob.sockets.udp.UDPDataVO;
   import net.play5d.game.bvn.mob.sockets.udp.UDPSocket;
   import net.play5d.game.bvn.mob.utils.JsonUtils;
   import net.play5d.game.bvn.mob.utils.LockFrameLogic;
   import net.play5d.game.bvn.mob.utils.SocketMsgFactory;
   import net.play5d.game.bvn.state.GameState;
   import net.play5d.game.bvn.state.LoadingState;
   import net.play5d.game.bvn.state.SelectFighterStage;
   import net.play5d.game.bvn.ui.GameUI;
   import net.play5d.kyo.utils.setFrameOut;
   
   public class LANClientCtrl
   {
      
      private static var _i:LANClientCtrl;
      
      public var active:Boolean;
      
      private var _delayText:TextField;
      
      private var _socket:SocketClient;
      
      private var _udpSocket:UDPSocket;
      
      private var _host:HostVO;
      
      private var _joinBack:Function;
      
      private var _syncErrorTimes:int;
      
      private var _selectLogic:SelectFighterClientLogic;
      
      private var _connGameLogic:LockFrameClientLogic;
      
      private var _delayCache:Array = [];
      
      private var _syncRoundFinishInt:int;
      
      private var _syncGameFinishInt:int;
      
      private var _syncGameStartInt:int;
      
      private var _onFindHostBack:Function;
      
      private var _findHostTimer:Timer;
      
      public function LANClientCtrl()
      {
         super();
      }
      
      public static function get I() : LANClientCtrl
      {
         if(!_i)
         {
            _i = new LANClientCtrl();
         }
         return _i;
      }
      
      public function initlize() : void
      {
         if(!_udpSocket)
         {
            _udpSocket = new UDPSocket();
            _udpSocket.listen(17478);
            _udpSocket.addDataHandler(udpDataHandler);
         }
      }
      
      public function findHost(param1:Function) : void
      {
         _onFindHostBack = param1;
         if(!_findHostTimer)
         {
            _findHostTimer = new Timer(2000);
            _findHostTimer.addEventListener("timer",findHostTimerHandler);
         }
         _findHostTimer.reset();
         _findHostTimer.start();
         findHostTimerHandler(null);
      }
      
      public function cancelFindHost() : void
      {
         _onFindHostBack = null;
         if(_findHostTimer)
         {
            _findHostTimer.stop();
            _findHostTimer.removeEventListener("timer",findHostTimerHandler);
            _findHostTimer = null;
         }
      }
      
      private function findHostTimerHandler(param1:TimerEvent) : void
      {
         _udpSocket.sendBroadcast(17477,SocketMsgFactory.createFindHostMsg());
      }
      
      private function receiveHostHandler(param1:UDPDataVO) : Boolean
      {
         var _loc2_:HostVO = null;
         if(!_findHostTimer)
         {
            return false;
         }
         var _loc3_:ByteArray = param1.getDataByteArray();
         if(_loc3_ && _loc3_.readByte() != 21)
         {
            return false;
         }
         if(_onFindHostBack != null)
         {
            _loc2_ = new HostVO();
            _loc2_.readByteArray(_loc3_);
            _loc2_.ip = param1.fromIP;
            _onFindHostBack(_loc2_);
         }
         return true;
      }
      
      private function udpDataHandler(param1:UDPDataVO) : void
      {
         if(receiveHostHandler(param1))
         {
            return;
         }
         if(_connGameLogic)
         {
            if(_connGameLogic.receiveSyncUpdate(param1.getDataByteArray()))
            {
               return;
            }
            if(_connGameLogic.receiveUpdate(param1.getDataByteArray()))
            {
               return;
            }
         }
      }
      
      public function updateDelay(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc4_:int = 0;
         var _loc3_:* = 0;
         if(!_delayText)
         {
            return;
         }
         _delayCache.push(param1);
         if(_delayCache.length >= 10)
         {
            _loc2_ = 0;
            for each(var _loc5_ in _delayCache)
            {
               _loc2_ += _loc5_;
            }
            _loc4_ = _loc2_ / _delayCache.length;
            _loc4_ -= 200;
            if(_loc4_ < 0)
            {
               _loc4_ = 0;
            }
            _delayCache = [];
            _loc3_ = 16711680;
            if(_loc4_ < 200)
            {
               _loc3_ = 65280;
            }
            else if(_loc4_ < 500)
            {
               _loc3_ = 16776960;
            }
            _delayText.text = _loc4_ + " ms";
            _delayText.textColor = _loc3_;
         }
      }
      
      public function join(param1:HostVO, param2:Function) : void
      {
         _host = param1;
         _joinBack = param2;
         initTcp(param1);
      }
      
      private function initTcp(param1:HostVO) : void
      {
         if(_socket)
         {
            dispose();
         }
         _socket = new SocketClient();
         _socket.addEventListener("SocketEvent_CLIENT_CONNECT",socketHandler);
         _socket.addEventListener("SocketEvent_CLOSE",socketHandler);
         _socket.addEventListener("SocketEvent_RECEIVE_DATA",socketHandler);
         _socket.connect(param1.ip,17511);
      }
      
      public function sendJoinIn() : void
      {
         _socket.sendJSON(SocketMsgFactory.createJoinInMsg());
      }
      
      public function dispose() : void
      {
         cancelFindHost();
         disposeTcp();
         disposeUdp();
         GameEvent.removeEventListener("GAME_START",onRoundStart);
      }
      
      private function disposeTcp() : void
      {
         if(_socket)
         {
            _socket.removeEventListener("SocketEvent_CLIENT_CONNECT",socketHandler);
            _socket.removeEventListener("SocketEvent_CLOSE",socketHandler);
            _socket.removeEventListener("SocketEvent_RECEIVE_DATA",socketHandler);
            _socket.close();
            _socket = null;
         }
      }
      
      private function disposeUdp() : void
      {
         if(_udpSocket)
         {
            _udpSocket.unListen();
            _udpSocket.removeDataHandler(udpDataHandler);
            _udpSocket = null;
         }
      }
      
      private function socketHandler(param1:SocketEvent) : void
      {
         switch(param1.type)
         {
            case "SocketEvent_CLIENT_CONNECT":
               _socket.sendJSON(SocketMsgFactory.createJoinMsg());
               break;
            case "SocketEvent_CLOSE":
               if(active)
               {
                  gameEnd();
                  GameUI.alert("DISCONNECT","与主机断开连接");
               }
               else
               {
                  dispose();
               }
               break;
            case "SocketEvent_RECEIVE_DATA":
               onReceiveData(param1);
         }
      }
      
      private function onReceiveData(param1:SocketEvent) : void
      {
         var _loc3_:Object = param1.getDataObject();
         if(!_loc3_)
         {
            return;
         }
         if(_selectLogic && _selectLogic.receiveSelect(_loc3_))
         {
            return;
         }
         if(receiveSync(_loc3_))
         {
            return;
         }
         var _loc2_:Object = JsonUtils.str2json(_loc3_);
         if(_loc2_)
         {
            receiveJson(_loc2_);
         }
      }
      
      private function receiveJson(param1:Object) : void
      {
         var _loc2_:Boolean = false;
         switch(param1.type)
         {
            case "JOIN_BACK":
               _loc2_ = Boolean(param1.success);
               if(_joinBack != null)
               {
                  _joinBack(_loc2_);
                  _joinBack = null;
               }
               if(!_loc2_)
               {
                  dispose();
               }
               break;
            case "START_GAME":
               gameStart(_host);
         }
      }
      
      public function sendTCP(param1:Object) : void
      {
         if(_socket)
         {
            _socket.send(param1);
         }
      }
      
      public function sendUDP(param1:Object) : void
      {
         if(_udpSocket)
         {
            _udpSocket.send(_host.ip,17477,param1);
         }
      }
      
      public function gameStart(param1:HostVO) : void
      {
         active = true;
         _delayText = new TextField();
         _delayText.text = "0ms";
         var _loc2_:TextFormat = new TextFormat();
         _loc2_.color = 16777215;
         _loc2_.size = 16;
         _delayText.defaultTextFormat = _loc2_;
         MainGame.I.stage.addChild(_delayText);
         _selectLogic = new SelectFighterClientLogic();
         _selectLogic.init();
         _connGameLogic = new LockFrameClientLogic();
         GameCtrl.I.autoEndRoundAble = false;
         GameCtrl.I.autoStartAble = false;
         SelectFighterStage.AUTO_FINISH = false;
         LoadingState.AUTO_START_GAME = false;
         GameInterface.instance.updateInputConfig();
         LockFrameLogic.I.initClient();
         GameEvent.addEventListener("ROUND_START",onRoundStart);
         LANGameCtrl.I.gameStart(param1);
      }
      
      private function onRoundStart(param1:GameEvent) : void
      {
         _connGameLogic.enabled = true;
      }
      
      public function gameEnd() : void
      {
         active = false;
         if(_selectLogic)
         {
            _selectLogic.dispose();
            _selectLogic = null;
         }
         if(_connGameLogic)
         {
            _connGameLogic.dispose();
            _connGameLogic = null;
         }
         if(_delayText)
         {
            try
            {
               _delayText.parent.removeChild(_delayText);
            }
            catch(e:Error)
            {
               trace(e);
            }
            _delayText = null;
         }
         GameCtrl.I.autoEndRoundAble = true;
         GameCtrl.I.autoStartAble = true;
         SelectFighterStage.AUTO_FINISH = true;
         LoadingState.AUTO_START_GAME = true;
         GameInterface.instance.updateInputConfig();
         LockFrameLogic.I.dispose();
         dispose();
         LANGameCtrl.I.gameEnd();
      }
      
      public function renderGame() : Boolean
      {
         if(MainGame.stageCtrl.currentStage is GameState)
         {
            return _connGameLogic.render();
         }
         InputManager.I.socket_input_p2.freeRender();
         return true;
      }
      
      private function receiveSync(param1:Object) : Boolean
      {
         var arr:Array;
         var type:int;
         var o:Object = param1;
         if(o is Array)
         {
            arr = o as Array;
            if(arr[0] == "SYNC")
            {
               trace("receiveSync",JSON.stringify(o));
               type = int(arr[1]);
               switch(type - 3)
               {
                  case 0:
                     syncStartGame();
                     break;
                  case 1:
                     syncGameFinish();
                     break;
                  case 4:
                     _connGameLogic.enabled = false;
                     _connGameLogic.reset();
                     setFrameOut(function():void
                     {
                        syncRoundFinish(arr);
                     },1,MainGame.I.stage);
               }
               return true;
            }
         }
         return false;
      }
      
      private function syncStartGame() : void
      {
         try
         {
            GameCtrl.I.doStartGame();
            _syncErrorTimes = 0;
            _connGameLogic.enabled = true;
            _connGameLogic.reset();
         }
         catch(e:Error)
         {
            trace("LanSyncType.GAME_START",e);
            syncError(true);
            clearTimeout(_syncGameStartInt);
            _syncGameStartInt = setTimeout(syncStartGame,500);
         }
      }
      
      private function syncRoundFinish(param1:Array) : void
      {
         var _loc7_:FighterMain = null;
         var _loc5_:FighterMain = null;
         var _loc3_:* = null;
         var _loc9_:* = null;
         var _loc10_:int = int(param1[2]);
         var _loc4_:Boolean = Boolean(param1[3]);
         var _loc6_:Boolean = Boolean(param1[4]);
         var _loc2_:int = int(param1[5]);
         var _loc8_:int = int(param1[6]);
         try
         {
            if(GameCtrl.I.gameRunData.round != _loc10_)
            {
               syncError(true);
               clearTimeout(_syncRoundFinishInt);
               _syncRoundFinishInt = setTimeout(syncRoundFinish,500,param1);
               return;
            }
            if(_loc4_)
            {
               GameCtrl.I.gameRunData.isTimerOver = true;
               GameCtrl.I.gameRunData.gameTime = 0;
            }
            _loc7_ = GameCtrl.I.gameRunData.p1FighterGroup.currentFighter;
            _loc5_ = GameCtrl.I.gameRunData.p2FighterGroup.currentFighter;
            _loc7_.hp = _loc2_;
            _loc5_.hp = _loc8_;
            if(_loc6_)
            {
               GameCtrl.I.drawGame();
            }
            else
            {
               if(_loc7_.hp > _loc5_.hp)
               {
                  _loc9_ = _loc7_;
                  _loc3_ = _loc5_;
               }
               else
               {
                  _loc9_ = _loc5_;
                  _loc3_ = _loc7_;
               }
               if(!_loc4_)
               {
                  _loc3_.die();
               }
               GameCtrl.I.doGameEnd(_loc9_,_loc3_);
            }
            _syncErrorTimes = 0;
         }
         catch(e:Error)
         {
            trace(e);
            syncError(true);
            clearTimeout(_syncRoundFinishInt);
            _syncRoundFinishInt = setTimeout(syncRoundFinish,500,param1);
         }
      }
      
      private function syncGameFinish() : void
      {
         _connGameLogic.enabled = false;
         _connGameLogic.reset();
         if(!GameCtrl.I.fightFinished)
         {
            try
            {
               GameCtrl.I.fightFinish();
            }
            catch(e:Error)
            {
               syncError(true);
               clearTimeout(_syncGameFinishInt);
               _syncGameFinishInt = setTimeout(syncGameFinish,500);
            }
         }
      }
      
      public function resetSyncError() : void
      {
         _syncErrorTimes = 0;
      }
      
      public function syncError(param1:Boolean = false) : void
      {
         if(!param1)
         {
            gameEnd();
            GameUI.alert("DISCONNECT","发生异常");
            return;
         }
         ++_syncErrorTimes;
         if(_syncErrorTimes > 10)
         {
            gameEnd();
            GameUI.alert("DISCONNECT","发生异常");
         }
      }
   }
}

