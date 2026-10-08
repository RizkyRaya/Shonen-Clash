package net.play5d.game.bvn.utils
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import net.play5d.game.bvn.ctrl.AssetManager;
   
   public class BitmapAssetLoader
   {
      
      private var _queueLength:int;
      
      private var _urls:Array;
      
      private var _cacheObj:Object = {};
      
      private var _successBack:Function;
      
      private var _processBack:Function;
      
      public function BitmapAssetLoader()
      {
         super();
      }
      
      public function getBitmap(urlId:*) : Bitmap
      {
         var bmd:BitmapData = _cacheObj[urlId];
         if(bmd == null)
         {
            return null;
         }
         return new Bitmap(bmd);
      }
      
      public function loadQueue(urls:Array, onComplete:Function, onProcess:Function = null) : void
      {
         _successBack = onComplete;
         _processBack = onProcess;
         _urls = urls.concat();
         _queueLength = urls.length;
         loadNext();
      }
      
      private function load(url:String, onComplete:Function = null, onProcess:Function = null) : void
      {
         var loadCom:Function = function(disp:DisplayObject):void
         {
            cacheBitmap(url,disp);
            if(onComplete != null)
            {
               onComplete();
            }
            loadCom = null;
            loadFail = null;
         };
         var loadFail:Function = function():void
         {
            trace("BitmapAssetLoader.loadFail :: Gagal memuat " + url);
            if(onComplete != null)
            {
               onComplete();
            }
            loadCom = null;
            loadFail = null;
         };
         AssetManager.I.loadBitmap(url,loadCom,loadFail,onProcess);
      }
      
      private function cacheBitmap(urlId:String, disp:DisplayObject) : void
      {
         var bmd:BitmapData = null;
         var bmp:Bitmap = disp as Bitmap;
         if(!bmp)
         {
            trace("BitmapAssetLoader.cacheBitmap Error: DisplayObject bukan tipe Bitmap");
            return;
         }
         try
         {
            bmd = bmp.bitmapData;
         }
         catch(e:Error)
         {
            trace("BitmapAssetLoader.cacheBitmap Error ::",e);
         }
         if(bmd)
         {
            _cacheObj[urlId] = bmd;
         }
         AssetManager.I.disposeAsset(urlId);
      }
      
      private function loadNext() : void
      {
         var callback:Function;
         var url:String;
         var loadProcess:Function;
         var nextStep:Function;
         if(_urls.length < 1)
         {
            if(_successBack != null)
            {
               callback = _successBack;
               _successBack = null;
               _processBack = null;
               callback();
            }
            return;
         }
         url = _urls.shift();
         loadProcess = function(prog:Number):void
         {
            if(_processBack != null)
            {
               var totalLoaded:Number = _queueLength - _urls.length - 1 + prog;
               var totalProgress:Number = totalLoaded / _queueLength;
               _processBack(totalProgress);
            }
         };
         nextStep = function():void
         {
            loadProcess = null;
            nextStep = null;
            loadNext();
         };
         load(url,nextStep,loadProcess);
      }
   }
}

