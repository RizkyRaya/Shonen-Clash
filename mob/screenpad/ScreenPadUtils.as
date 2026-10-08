package net.play5d.game.bvn.mob.screenpad
{
   import flash.display.Bitmap;
   import flash.geom.Point;
   import flash.system.Capabilities;
   import net.play5d.game.bvn.mob.GameInterfaceManager;
   
   public class ScreenPadUtils
   {
      
      public function ScreenPadUtils()
      {
         super();
      }
      
      public static function getArrow(param1:Class, param2:Point) : ScreenPadArrow
      {
         var _loc3_:ScreenPadArrow = new ScreenPadArrow();
         var _loc4_:Bitmap = new param1();
         _loc3_.display = _loc4_;
         _loc3_.display.alpha = GameInterfaceManager.config.screenPadConfig.joyAlpha;
         _loc3_.init(param2);
         return _loc3_;
      }
      
      public static function getButton(param1:Class, param2:Point) : ScreenPadBtn
      {
         var _loc3_:ScreenPadBtn = new ScreenPadBtn();
         var _loc4_:Bitmap = new param1();
         _loc3_.display = _loc4_;
         _loc3_.display.alpha = GameInterfaceManager.config.screenPadConfig.joyAlpha;
         _loc3_.init(param2);
         return _loc3_;
      }
      
      public static function getPointByCM(param1:Number = 0, param2:Number = 0) : Point
      {
         var _loc3_:Number = Capabilities.screenDPI;
         var _loc4_:Point = new Point();
         _loc4_.x = param1 * _loc3_ / 2.54;
         _loc4_.y = param2 * _loc3_ / 2.54;
         return _loc4_;
      }
      
      public static function cm2pixel(param1:Number) : Number
      {
         var _loc2_:Number = Capabilities.screenDPI;
         return param1 * _loc2_ / 2.54;
      }
   }
}

