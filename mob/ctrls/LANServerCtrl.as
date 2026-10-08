package net.play5d.game.bvn.mob.ctrls
{
   import flash.events.EventDispatcher;
   import flash.net.Socket;
   import flash.utils.ByteArray;
   import net.play5d.game.bvn.MainGame;
   import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
   import net.play5d.game.bvn.data.GameRunDataVO;
   import net.play5d.game.bvn.events.GameEvent;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.interfaces.GameInterface;
   import net.play5d.game.bvn.mob.data.ClientVO;
   import net.play5d.game.bvn.mob.data.HostVO;
   import net.play5d.game.bvn.mob.events.LanEvent;
   import net.play5d.game.bvn.mob.input.InputManager;
   import net.play5d.game.bvn.mob.sockets.SocketServer;
   import net.play5d.game.bvn.mob.sockets.events.SocketEvent;
   import net.play5d.game.bvn.mob.sockets.udp.UDPDataVO;
   import net.play5d.game.bvn.mob.sockets.udp.UDPSocket;
   import net.play5d.game.bvn.mob.utils.JsonUtils;
   import net.play5d.game.bvn.mob.utils.LockFrameLogic;
   import net.play5d.game.bvn.mob.utils.SocketMsgFactory;
   import net.play5d.game.bvn.state.GameState;
   import net.play5d.game.bvn.state.MenuState;
   import net.play5d.game.bvn.ui.GameUI;
   
   public class LANServerCtrl extends EventDispatcher
   {
      
      private static var _i:LANServerCtrl;
      
      public var active:Boolean;
      
      private var _clientK:int;
      
      private var _serverK:int;
      
      private var _clients:Vector.<ClientVO> = new Vector.<ClientVO>();
      
      private var _udpClientIP:String;
      
      private var _host:HostVO;
      
      private var _renderFrame:uint;
      
      private var _renderFrameClient:uint;
      
      private var _renderNextFrame:uint;
      
      private var _renderSyncFrame:int;
      
      private var _sendUpdateFrame:int;
      
      private var _selectLogic:SelectFighterServerLogic;
      
      private var _connGameLogic:LockFrameServerLogic;
      
      private var _playerClient:ClientVO;
      
      private var _udpSocket:UDPSocket;
      
      public function LANServerCtrl()
      {
         super();
      }
      
      public static function get I() : LANServerCtrl
      {
         if(!_i)
         {
            _i = new LANServerCtrl();
         }
         return _i;
      }
      
      public function get host() : HostVO
      {
         return _host;
      }
      
      public function startServer(param1:HostVO) : void
      {
         _host = param1;
         SocketServer.I.bind(17511);
         SocketServer.I.addEventListener("SocketEvent_CLIENT_CONNECT",socketHandler);
         SocketServer.I.addEventListener("SocketEvent_CLIENT_DIS_CONNECT",socketHandler);
         SocketServer.I.addEventListener("SocketEvent_RECEIVE_DATA",socketDataHandler);
         _udpSocket = new UDPSocket();
         _udpSocket.listen(17477);
         _udpSocket.addDataHandler(udpDataHandler);
      }
      
      public function stopServer() : void
      {
         _host = null;
         SocketServer.I.close();
         SocketServer.I.removeEventListener("SocketEvent_CLIENT_CONNECT",socketHandler);
         SocketServer.I.removeEventListener("SocketEvent_CLIENT_DIS_CONNECT",socketHandler);
         SocketServer.I.removeEventListener("SocketEvent_RECEIVE_DATA",socketDataHandler);
         if(_udpSocket)
         {
            _udpSocket.unListen();
            _udpSocket.removeDataHandler(udpDataHandler);
            _udpSocket = null;
         }
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
         _clients = new Vector.<ClientVO>();
         _host = null;
         _udpClientIP = null;
      }
      
      private function udpDataHandler(param1:UDPDataVO) : void
      {
         var _loc2_:ByteArray = param1.getDataByteArray();
         if(_loc2_ && _loc2_.readByte() == 20)
         {
            if(!active)
            {
               _udpSocket.send(param1.fromIP,17478,SocketMsgFactory.createFindHostBackMsg());
            }
            return;
         }
         if(_connGameLogic && _connGameLogic.receiveInput(_loc2_))
         {
            _udpClientIP = param1.fromIP;
            return;
         }
      }
      
      private function socketHandler(param1:SocketEvent) : void
      {
         trace(param1);
         switch(param1.type)
         {
            case "SocketEvent_CLIENT_CONNECT":
               break;
            case "SocketEvent_CLIENT_DIS_CONNECT":
               if(active)
               {
                  gameEnd();
                  GameUI.alert("PLAYER EXIT","玩家退出房间");
               }
               _udpClientIP = null;
         }
      }
      
      private function socketDataHandler(param1:SocketEvent) : void
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
         var _loc2_:Object = JsonUtils.str2json(_loc3_);
         if(_loc2_)
         {
            receiveJson(_loc2_,param1.clientSocket);
         }
      }
      
      private function receiveJson(param1:Object, param2:Socket) : void
      {
         switch(param1.type)
         {
            case "JOIN":
               receiveJoin(param1,param2);
               break;
            case "JOIN_IN":
         }
      }
      
      private function receiveJoin(param1:Object, param2:Socket) : void
      {
         if(_clients.length > 0)
         {
            SocketServer.I.sendJson(param2,SocketMsgFactory.createJoinFailMsg("人数已满"));
            return;
         }
         var _loc3_:ClientVO = new ClientVO();
         _loc3_.ip = param2.remoteAddress;
         _loc3_.name = param1.name;
         _loc3_.socket = param2;
         _clients.push(_loc3_);
         _playerClient = _loc3_;
         SocketServer.I.sendJson(_loc3_.socket,SocketMsgFactory.createJoinSuccMsg());
         dispatchEvent(new LanEvent("CLIENT_JOIN_SUCCESS"));
      }
      
      private function findClient(param1:Socket) : ClientVO
      {
         for each(var _loc2_ in _clients)
         {
            if(_loc2_.socket == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function gameStart() : void
      {
         active = true;
         GameInterface.instance.updateInputConfig();
         LockFrameLogic.I.initServer();
         _renderFrame = 1;
         _selectLogic = new SelectFighterServerLogic();
         _selectLogic.init();
         _connGameLogic = new LockFrameServerLogic();
         initSyncEvent();
         LANGameCtrl.I.gameStart(_host);
      }
      
      public function gameEnd() : void
      {
         active = false;
         GameInterface.instance.updateInputConfig();
         LockFrameLogic.I.dispose();
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
         disposeSyncEvent();
         LANGameCtrl.I.gameEnd();
         gameQuit();
      }
      
      public function gameQuit() : void
      {
         active = false;
         GameInterface.instance.updateInputConfig();
         LockFrameLogic.I.dispose();
         disposeSyncEvent();
         LanGameMenuCtrl.I.dispose();
         stopServer();
         MainGame.stageCtrl.goStage(new MenuState());
      }
      
      private function initSyncEvent() : void
      {
         GameEvent.addEventListener("ROUND_END",onGameRoundEnd);
         GameEvent.addEventListener("GAME_START",onGameStart);
         GameEvent.addEventListener("GAME_END",onGameEnd);
         GameEvent.addEventListener("ROUND_START",onRoundStart);
      }
      
      private function disposeSyncEvent() : void
      {
         GameEvent.removeEventListener("ROUND_END",onGameRoundEnd);
         GameEvent.removeEventListener("GAME_START",onGameStart);
         GameEvent.removeEventListener("GAME_END",onGameEnd);
         GameEvent.removeEventListener("ROUND_START",onRoundStart);
      }
      
      public function renderGame() : Boolean
      {
         if(MainGame.stageCtrl.currentStage is GameState)
         {
            return _connGameLogic.render();
         }
         InputManager.I.socket_input_p1.freeRender();
         return true;
      }
      
      private function onGameStart(param1:GameEvent) : void
      {
         _connGameLogic.enabled = true;
         _connGameLogic.reset();
         var _loc2_:Array = ["SYNC",3];
         sendTCP(_loc2_);
      }
      
      private function onGameEnd(param1:GameEvent) : void
      {
         _connGameLogic.enabled = false;
         _connGameLogic.reset();
         var _loc2_:Array = ["SYNC",4];
         sendTCP(_loc2_);
      }
      
      private function onRoundStart(param1:GameEvent) : void
      {
         _connGameLogic.enabled = true;
      }
      
      private function onGameRoundEnd(param1:GameEvent) : void
      {
         var _loc3_:GameRunDataVO = GameCtrl.I.gameRunData;
         var _loc4_:FighterMain = _loc3_.p1FighterGroup.currentFighter;
         var _loc2_:FighterMain = _loc3_.p2FighterGroup.currentFighter;
         var _loc5_:Array = ["SYNC",7,_loc3_.round,_loc3_.isTimerOver,_loc3_.isDrawGame,_loc4_.hp << 0,_loc2_.hp << 0];
         sendTCP(_loc5_);
         _connGameLogic.enabled = false;
         _connGameLogic.reset();
      }
      
      public function sendGameStart() : void
      {
         var _loc1_:Object = SocketMsgFactory.createStartGame();
         for each(var _loc2_ in _clients)
         {
            SocketServer.I.sendJson(_loc2_.socket,_loc1_);
         }
      }
      
      public function sendTCP(param1:Object) : void
      {
         for each(var _loc2_ in _clients)
         {
            SocketServer.I.send(_loc2_.socket,param1);
         }
      }
      
      public function sendUDP(param1:Object) : void
      {
         if(_udpClientIP)
         {
            _udpSocket.send(_udpClientIP,17478,param1);
         }
      }
   }
}

