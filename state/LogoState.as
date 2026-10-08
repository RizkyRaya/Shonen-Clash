package net.play5d.game.bvn.state
{
   import flash.display.DisplayObject;
   import flash.events.Event;
   import net.play5d.game.bvn.MainGame;
   import net.play5d.game.bvn.utils.ResUtils;
   import net.play5d.game.bvn.video.OpeningVideoPlayer;
   import net.play5d.kyo.stage.Istage;
   
   public class LogoState implements Istage
   {
      
      private var _ui:logo_movie;
      
      private var _video:OpeningVideoPlayer;
      
      public function LogoState()
      {
         super();
      }
      
      public function get display() : DisplayObject
      {
         return _ui;
      }
      
      public function build() : void
      {
         _ui = ResUtils.I.createDisplayObject(ResUtils.I.common_ui,"logo_movie");
         _ui.addEventListener("complete",playComplete);
         _ui.gotoAndPlay(2);
      }
      
      private function playComplete(param1:Event) : void
      {
         _ui.removeEventListener("complete",playComplete);
         _ui.stop();
         if(_ui.stage)
         {
            _video = new OpeningVideoPlayer();
            _ui.stage.addChild(_video);
            _video.play("assets/op/opening.mp4",_ui.stage.stageWidth,_ui.stage.stageHeight,openingFinish);
         }
         else
         {
            openingFinish();
         }
      }
      
      private function openingFinish() : void
      {
         if(_video && _video.parent)
         {
            _video.parent.removeChild(_video);
            _video = null;
         }
         MainGame.I.goMenu();
      }
      
      public function afterBuild() : void
      {
      }
      
      public function destory(param1:Function = null) : void
      {
         if(_ui)
         {
            _ui.removeEventListener("complete",playComplete);
         }
         if(_video && _video.parent)
         {
            _video.parent.removeChild(_video);
            _video = null;
         }
      }
   }
}

