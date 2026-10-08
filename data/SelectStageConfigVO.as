package net.play5d.game.bvn.data
{
   import flash.geom.Point;
   
   public class SelectStageConfigVO
   {
      
      public var x:Number = 0;
      
      public var y:Number = 0;
      
      public var width:Number = 800;
      
      public var height:Number = 600;
      
      public var top:Number = 0;
      
      public var bottom:Number = 0;
      
      public var left:Number = 0;
      
      public var right:Number = 0;
      
      public var charList:SelectCharListConfigVO;
      
      public var assistList:SelectCharListConfigVO;
      
      public var unitSize:Point = new Point(50,50);
      
      public function SelectStageConfigVO()
      {
         super();
      }
      
      public function setByXML(param1:XML) : void
      {
         var _loc2_:Object = param1.stage_setting.layout;
         x = Number(_loc2_.@x);
         y = Number(_loc2_.@y);
         width = Number(_loc2_.@width);
         height = Number(_loc2_.@height);
         top = Number(_loc2_.@top);
         bottom = Number(_loc2_.@bottom);
         left = Number(_loc2_.@left);
         right = Number(_loc2_.@right);
         charList = newListByXML(param1.char_list);
         assistList = newListByXML(param1.assist_list);
      }
      
      private function newListByXML(param1:XMLList) : SelectCharListConfigVO
      {
         var _loc12_:int = 0;
         var _loc14_:XML = null;
         var _loc8_:Point = null;
         var _loc13_:String = null;
         var _loc6_:Array = null;
         var _loc11_:int = 0;
         var _loc2_:XML = null;
         var _loc5_:Array = null;
         var _loc15_:String = null;
         var _loc9_:String = null;
         var _loc4_:Point = null;
         var _loc16_:String = null;
         var _loc7_:Array = null;
         var _loc10_:SelectCharListItemVO = null;
         var _loc3_:SelectCharListConfigVO = new SelectCharListConfigVO();
         _loc3_.VCount = param1.children().length();
         while(_loc12_ < param1.children().length())
         {
            _loc14_ = param1.children()[_loc12_];
            _loc8_ = null;
            _loc13_ = _loc14_.@offset;
            if(_loc13_ && _loc13_.length > 0)
            {
               _loc6_ = _loc13_.split(",");
               _loc8_ = new Point(_loc6_[0],_loc6_[1]);
            }
            if(_loc3_.HCount < _loc14_.children().length())
            {
               _loc3_.HCount = _loc14_.children().length();
            }
            _loc11_ = 0;
            while(_loc11_ < _loc14_.children().length())
            {
               _loc2_ = _loc14_.children()[_loc11_];
               _loc5_ = null;
               _loc15_ = _loc2_.@moreFighter;
               if(_loc15_ && _loc15_.length > 0)
               {
                  _loc5_ = _loc15_.split(",");
               }
               _loc9_ = _loc2_.toString();
               if(_loc9_ && _loc9_.length < 1)
               {
                  _loc9_ = null;
               }
               _loc4_ = _loc8_ ? _loc8_.clone() : null;
               _loc16_ = _loc2_.@offset;
               if(_loc16_ && _loc16_.length > 0)
               {
                  _loc7_ = _loc16_.split(",");
                  if(_loc4_)
                  {
                     _loc4_.x += Number(_loc7_[0]);
                     _loc4_.y += Number(_loc7_[1]);
                  }
                  else
                  {
                     _loc4_ = new Point(_loc7_[0],_loc7_[1]);
                  }
               }
               _loc10_ = new SelectCharListItemVO(_loc11_,_loc12_,_loc9_,_loc4_);
               _loc10_.moreFighterIDs = _loc5_;
               _loc3_.list.push(_loc10_);
               _loc11_++;
            }
            _loc12_++;
         }
         return _loc3_;
      }
   }
}

