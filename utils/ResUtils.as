package net.play5d.game.bvn.utils
{
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.media.SoundTransform;
   import flash.utils.Dictionary;
   import flash.utils.describeType;
   import net.play5d.game.bvn.data.GameData;
   
   public class ResUtils
   {
      
      private static var _i:ResUtils;
      
      public static var SETTING:String = "stg_set_ui";
      
      public static var CONGRATULATIONS:String = "mc_congratulations";
      
      public static var WINNER:String = "winner_stg_mc";
      
      public static var TITLE:String = "stg_title";
      
      public static var GAME_OVER:String = "stg_gameover_mc";
      
      public static var SELECT:String = "stg_select";
      
      public static var MOSOU:String = "stg_mosou";
      
      public static var BIG_MAP:String = "big_map_mc";
      
      public var common_ui:Class = §common_ui_swf$fa8c50f0c229a548cd53218b6f64f0d9-2091959187§;
      
      public var fight:Class = fight_swf$162e2455ccbf20b451f988a3b726b095786794501;
      
      public var gameover:Class = §gameover_swf$76a5c9359b37caf59810585482d8d6fb-674241051§;
      
      public var howtoplay:Class = howtoplay_swf$5a445881c3f4000269b27f576362eb6d96147604;
      
      public var loading:Class = loading_swf$05a8dab2aa9490e41daf78e885c1980c976431505;
      
      public var select:Class = §select_swf$a382c843349f6f222ad4fcb09667a906-356645777§;
      
      public var setting:Class = setting_swf$a370ec9e057abe550d240d6431fa536e867806341;
      
      public var title:Class = title_swf$9d07b0a6371656ad84fb26156260025b2107047933;
      
      public var mosou:Class = mosou_swf$8aafc481e7d4471f7c6efdb597320ca0588557020;
      
      public var bigMap:Class = bigmap_swf$a97606add711bb2a60a61a369b696ac6508782799;
      
      public var dialog:Class = §dialog_ui_swf$03d38cc11a1612d10e1b93f1f9bb80f7-1993337248§;
      
      private var _swfPool:Dictionary;
      
      private var _initBack:Function;
      
      private var _initError:Function;
      
      private var _inited:Boolean;
      
      private var _initing:Boolean;
      
      public function ResUtils()
      {
         super();
      }
      
      public static function get I() : ResUtils
      {
         if(!_i)
         {
            _i = new ResUtils();
         }
         return _i;
      }
      
      public function initalize(param1:Function = null, param2:Function = null) : void
      {
         var _loc6_:String = null;
         var _loc7_:Class = null;
         var _loc3_:InsSwf = null;
         if(_initing)
         {
            throw new Error("正在初始化过程中，不能再次初始化！");
         }
         if(_inited)
         {
            if(param1 != null)
            {
               param1();
            }
            return;
         }
         _inited = true;
         _initing = true;
         if(!_swfPool)
         {
            _swfPool = new Dictionary();
         }
         _initBack = param1;
         _initError = param2;
         var _loc4_:XML = describeType(this);
         var _loc8_:Object = {};
         for each(var _loc5_ in _loc4_.variable)
         {
            _loc6_ = _loc5_.@name;
            _loc7_ = this[_loc6_];
            _loc3_ = new InsSwf(_loc7_);
            _loc3_.ready = swfReadyBack;
            _loc3_.error = swfErrorBack;
            _swfPool[_loc7_] = _loc3_;
         }
      }
      
      public function addSwf(param1:Class) : void
      {
         if(!_swfPool)
         {
            _swfPool = new Dictionary();
         }
         var _loc2_:InsSwf = new InsSwf(param1);
         _loc2_.ready = swfReadyBack;
         _loc2_.error = swfErrorBack;
         _swfPool[param1] = _loc2_;
      }
      
      private function swfReadyBack(param1:InsSwf) : void
      {
         for each(var _loc2_ in _swfPool)
         {
            if(!_loc2_.isReady)
            {
               return;
            }
         }
         finish();
      }
      
      private function swfErrorBack(param1:String) : void
      {
         if(_initError != null)
         {
            _initError();
         }
      }
      
      private function finish() : void
      {
         _initing = false;
         if(_initBack != null)
         {
            _initBack();
            _initBack = null;
         }
      }
      
      public function createDisplayObject(param1:Class, param2:String) : *
      {
         var _loc4_:* = undefined;
         var _loc5_:Sprite = null;
         var _loc3_:SoundTransform = null;
         var _loc6_:Class = getItemClass(param1,param2);
         if(_loc6_)
         {
            _loc4_ = new _loc6_();
            if(_loc4_ is Sprite)
            {
               _loc5_ = _loc4_ as Sprite;
               _loc3_ = _loc5_.soundTransform;
               _loc3_.volume = GameData.I.config.soundVolume;
               _loc5_.soundTransform = _loc3_;
               return _loc5_;
            }
            return _loc4_;
         }
      }
      
      public function createBitmapData(param1:Class, param2:String, param3:int, param4:int) : BitmapData
      {
         var _loc6_:Class = getItemClass(param1,param2);
         if(!_loc6_)
         {
            return null;
         }
         return new _loc6_(param3,param4);
      }
      
      public function getItemClass(param1:Class, param2:String) : Class
      {
         if(!_swfPool)
         {
            throw new Error("未进行初始化！");
         }
         var _loc3_:InsSwf = _swfPool[param1];
         if(!_loc3_)
         {
            throw new Error("swf is undefined!");
         }
         return _loc3_.getClass(param2);
      }
      
      public function getItemProperty(param1:Class, param2:String) : *
      {
         if(!_swfPool)
         {
            throw new Error("未进行初始化！");
         }
         var _loc3_:InsSwf = _swfPool[param1];
         if(!_loc3_)
         {
            throw new Error("swf is undefined!");
         }
         return _loc3_.getProperty(param2);
      }
      
      public function callSwfFunction(param1:Class, param2:String, param3:Array = null) : *
      {
         if(!_swfPool)
         {
            throw new Error("未进行初始化！");
         }
         var _loc4_:InsSwf = _swfPool[param1];
         if(!_loc4_)
         {
            throw new Error("swf is undefined!");
         }
         return _loc4_.call(param2,param3);
      }
   }
}

import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.utils.ByteArray;

class InsSwf
{
   
   private var _swf:*;
   
   private var _domain:ApplicationDomain;
   
   public var isReady:Boolean;
   
   public var ready:Function;
   
   public var error:Function;
   
   private var _content:DisplayObject;
   
   public function InsSwf(param1:Class)
   {
      super();
      _swf = new param1();
      var _loc2_:ByteArray = _swf.movieClipData;
      if(!_loc2_)
      {
         error("未发现swf的movieClipData!");
         throw new Error("未发现swf的movieClipData!");
      }
      var _loc3_:Loader = new Loader();
      _loc3_.contentLoaderInfo.addEventListener("complete",loadComplete,false,0,true);
      var _loc4_:LoaderContext = new LoaderContext(false,ApplicationDomain.currentDomain);
      _loc4_.allowCodeImport = true;
      _loc3_.loadBytes(_loc2_,_loc4_);
   }
   
   public function getClass(param1:String) : Class
   {
      return _domain.getDefinition(param1) as Class;
   }
   
   public function getProperty(param1:String) : *
   {
      return _content[param1];
   }
   
   public function call(param1:String, param2:Array = null) : *
   {
      var _loc3_:Function = null;
      if(!_content)
      {
         trace("swf is null !");
         return null;
      }
      try
      {
         _loc3_ = _content[param1];
         return _loc3_.apply(null,param2);
      }
      catch(e:Error)
      {
         trace(e);
         throw new Error("swf." + param1 + " call failed ! ");
      }
   }
   
   private function loadComplete(param1:Event) : void
   {
      var _loc2_:LoaderInfo = param1.currentTarget as LoaderInfo;
      _domain = _loc2_.applicationDomain;
      _content = _loc2_.content;
      isReady = true;
      if(ready != null)
      {
         ready(this);
         ready = null;
      }
   }
}
