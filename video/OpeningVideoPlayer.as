package net.play5d.game.bvn.video
{
   import flash.display.Sprite;
   import flash.events.AsyncErrorEvent;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.NetStatusEvent;
   import flash.media.SoundTransform;
   import flash.media.Video;
   import flash.net.NetConnection;
   import flash.net.NetStream;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   
   public class OpeningVideoPlayer extends Sprite
   {
      
      private var _video:Video;
      
      private var _bg:Sprite;
      
      private var _skipText:TextField;
      
      private var _topBar:Sprite;
      
      private var _bottomBar:Sprite;
      
      private var _skipHintVisible:Boolean = false;
      
      private var _skipEnabled:Boolean = false;
      
      private var _skipTimer:int = 0;
      
      private var _connection:NetConnection;
      
      private var _stream:NetStream;
      
      private var _finishCallback:Function;
      
      private var _finished:Boolean = false;
      
      private var _fadingOut:Boolean = false;
      
      private var _stageW:int;
      
      private var _stageH:int;
      
      public function OpeningVideoPlayer()
      {
         super();
      }
      
      public function play(path:String, width:int, height:int, callback:Function = null) : void
      {
         _finishCallback = callback;
         _stageW = width;
         _stageH = height;
         _bg = new Sprite();
         _bg.graphics.beginFill(0);
         _bg.graphics.drawRect(0,0,width,height);
         _bg.graphics.endFill();
         addChild(_bg);
         _connection = new NetConnection();
         _connection.connect(null);
         _stream = new NetStream(_connection);
         _stream.client = {
            "onMetaData":onMetaData,
            "onCuePoint":onCuePoint
         };
         _stream.soundTransform = new SoundTransform(1);
         _stream.addEventListener(NetStatusEvent.NET_STATUS,onNetStatus,false,0,true);
         _stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR,onAsyncError,false,0,true);
         _video = new Video(width,height);
         _video.smoothing = true;
         _video.alpha = 0;
         _video.attachNetStream(_stream);
         addChild(_video);
         createCinematicBars(width,height);
         createSkipText(width,height);
         addEventListener(MouseEvent.CLICK,onSkip,false,0,true);
         _stream.play(path);
         fadeIn();
      }
      
      private function createCinematicBars(w:int, h:int) : void
      {
         var barHeight:Number = h * 0.12;
         _topBar = new Sprite();
         _topBar.graphics.beginFill(0);
         _topBar.graphics.drawRect(0,0,w,barHeight);
         _topBar.graphics.endFill();
         _topBar.y = -barHeight;
         addChild(_topBar);
         _bottomBar = new Sprite();
         _bottomBar.graphics.beginFill(0);
         _bottomBar.graphics.drawRect(0,0,w,barHeight);
         _bottomBar.graphics.endFill();
         _bottomBar.y = h;
         addChild(_bottomBar);
      }
      
      private function createSkipText(stageW:int, stageH:int) : void
      {
         var format:TextFormat = new TextFormat();
         format.font = "_sans";
         format.size = 16;
         format.letterSpacing = 2;
         format.color = 16777215;
         _skipText = new TextField();
         _skipText.defaultTextFormat = format;
         _skipText.autoSize = TextFieldAutoSize.LEFT;
         _skipText.selectable = false;
         _skipText.mouseEnabled = false;
         _skipText.text = "TAP AGAIN TO SKIP >>";
         _skipText.visible = false;
         _skipText.alpha = 0;
         _skipText.x = stageW - _skipText.width - 30;
         _skipText.y = stageH - _skipText.height - stageH * 0.12 - 10;
         addChild(_skipText);
      }
      
      private function onMetaData(info:Object) : void
      {
      }
      
      private function onCuePoint(info:Object) : void
      {
      }
      
      private function onAsyncError(e:AsyncErrorEvent) : void
      {
      }
      
      private function onNetStatus(e:NetStatusEvent) : void
      {
         switch(e.info.code)
         {
            case "NetStream.Play.Stop":
            case "NetStream.Play.Complete":
            case "NetStream.Play.StreamNotFound":
               startFadeOut();
         }
      }
      
      private function onSkip(e:MouseEvent) : void
      {
         if(!_skipEnabled)
         {
            showSkipHint();
            return;
         }
         startFadeOut();
      }
      
      private function updateSkipHint(e:Event) : void
      {
         --_skipTimer;
         if(_skipTimer <= 0)
         {
            _skipText.alpha -= 0.05;
            if(_skipText.alpha <= 0)
            {
               _skipText.alpha = 0;
               _skipText.visible = false;
               removeEventListener(Event.ENTER_FRAME,updateSkipHint);
               _skipHintVisible = false;
               _skipEnabled = false;
            }
         }
      }
      
      private function showSkipHint() : void
      {
         if(_skipHintVisible)
         {
            return;
         }
         _skipHintVisible = true;
         _skipEnabled = true;
         _skipText.visible = true;
         _skipText.alpha = 0.8;
         _skipTimer = 120;
         addEventListener(Event.ENTER_FRAME,updateSkipHint,false,0,true);
      }
      
      private function fadeIn() : void
      {
         addEventListener(Event.ENTER_FRAME,onFadeIn,false,0,true);
      }
      
      private function onFadeIn(e:Event) : void
      {
         var isDone:Boolean = true;
         if(_video && _video.alpha < 1)
         {
            _video.alpha += 0.03;
            isDone = false;
         }
         var barHeight:Number = _stageH * 0.12;
         if(_topBar && _topBar.y < 0)
         {
            _topBar.y += (0 - _topBar.y) * 0.1;
            _bottomBar.y += (_stageH - barHeight - _bottomBar.y) * 0.1;
            if(Math.abs(_topBar.y) < 1)
            {
               _topBar.y = 0;
               _bottomBar.y = _stageH - barHeight;
            }
            else
            {
               isDone = false;
            }
         }
         if(isDone)
         {
            if(_video)
            {
               _video.alpha = 1;
            }
            removeEventListener(Event.ENTER_FRAME,onFadeIn);
         }
      }
      
      private function startFadeOut() : void
      {
         if(_finished || _fadingOut)
         {
            return;
         }
         _fadingOut = true;
         removeEventListener(Event.ENTER_FRAME,onFadeIn);
         addEventListener(Event.ENTER_FRAME,onFadeOut,false,0,true);
      }
      
      private function onFadeOut(e:Event) : void
      {
         if(_video)
         {
            _video.alpha -= 0.04;
         }
         if(_skipText)
         {
            _skipText.alpha -= 0.1;
         }
         if(_stream && _stream.soundTransform)
         {
            var st:SoundTransform = _stream.soundTransform;
            st.volume -= 0.04;
            if(st.volume < 0)
            {
               st.volume = 0;
            }
            _stream.soundTransform = st;
         }
         if(_video.alpha <= 0)
         {
            removeEventListener(Event.ENTER_FRAME,onFadeOut);
            finish();
         }
      }
      
      private function finish() : void
      {
         var cb:Function;
         if(_finished)
         {
            return;
         }
         _finished = true;
         removeEventListener(MouseEvent.CLICK,onSkip);
         removeEventListener(Event.ENTER_FRAME,updateSkipHint);
         removeEventListener(Event.ENTER_FRAME,onFadeIn);
         removeEventListener(Event.ENTER_FRAME,onFadeOut);
         if(_stream)
         {
            _stream.removeEventListener(NetStatusEvent.NET_STATUS,onNetStatus);
            _stream.removeEventListener(AsyncErrorEvent.ASYNC_ERROR,onAsyncError);
            try
            {
               _stream.close();
            }
            catch(err:Error)
            {
            }
         }
         if(_video)
         {
            try
            {
               _video.attachNetStream(null);
               _video.clear();
            }
            catch(err1:Error)
            {
            }
         }
         if(_connection)
         {
            try
            {
               _connection.close();
            }
            catch(err2:Error)
            {
            }
         }
         disposeDisplayObject(_skipText);
         disposeDisplayObject(_topBar);
         disposeDisplayObject(_bottomBar);
         disposeDisplayObject(_video);
         disposeDisplayObject(_bg);
         if(parent)
         {
            parent.removeChild(this);
         }
         _video = null;
         _bg = null;
         _stream = null;
         _connection = null;
         _skipText = null;
         _topBar = null;
         _bottomBar = null;
         if(_finishCallback != null)
         {
            cb = _finishCallback;
            _finishCallback = null;
            cb();
         }
      }
      
      private function disposeDisplayObject(obj:*) : void
      {
         if(obj && obj.parent)
         {
            obj.parent.removeChild(obj);
         }
      }
   }
}

