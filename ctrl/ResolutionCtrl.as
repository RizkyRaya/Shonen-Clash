package net.play5d.game.bvn.ctrl
{
   import flash.geom.Matrix;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.state.GameState;
   
   public class ResolutionCtrl
   {
      
      private static var _gameState:GameState;
      
      private static var _currentScale:Number = 1;
      
      private static var _scaleMatrix:Matrix = new Matrix();
      
      public function ResolutionCtrl()
      {
         super();
      }
      
      public static function init(gameState:GameState) : void
      {
         _gameState = gameState;
         applyResolution();
      }
      
      public static function setResolution(scale:Number) : void
      {
         if(scale < 0.25)
         {
            scale = 0.25;
         }
         if(scale > 1)
         {
            scale = 1;
         }
         _currentScale = scale;
         GameConfig.INTERNAL_RESOLUTION_SCALE = _currentScale;
         applyResolution();
      }
      
      private static function applyResolution() : void
      {
         if(!_gameState || !_gameState.gameLayer)
         {
            return;
         }
         _gameState.gameLayer.visible = true;
         if(_currentScale >= 1)
         {
            _gameState.gameLayer.cacheAsBitmap = false;
            _gameState.gameLayer.cacheAsBitmapMatrix = null;
         }
         else
         {
            _scaleMatrix.identity();
            _scaleMatrix.scale(_currentScale,_currentScale);
            _gameState.gameLayer.cacheAsBitmap = true;
            _gameState.gameLayer.cacheAsBitmapMatrix = _scaleMatrix;
         }
      }
      
      public static function render() : void
      {
      }
      
      public static function get currentScale() : Number
      {
         return _currentScale;
      }
      
      public static function clear() : void
      {
         if(_gameState && _gameState.gameLayer)
         {
            _gameState.gameLayer.cacheAsBitmap = false;
            _gameState.gameLayer.cacheAsBitmapMatrix = null;
         }
         _gameState = null;
      }
   }
}

