package net.play5d.game.bvn.ui.select
{
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.utils.ResUtils;
   
   public class SelectUIFactory
   {
      
      public function SelectUIFactory()
      {
         super();
      }
      
      public static function createSelecter(param1:int = 1) : SelecterItemUI
      {
         var _loc2_:SelecterItemUI = new SelecterItemUI(param1);
         _loc2_.inputType = param1 == 1 ? "P1" : "P2";
         _loc2_.selectVO = param1 == 1 ? GameData.I.p1Select : GameData.I.p2Select;
         var _loc3_:String = param1 == 1 ? "selected_item_p1_mc" : "selected_item_p2_mc";
         var _loc4_:Class = ResUtils.I.getItemClass(ResUtils.I.select,_loc3_);
         var _loc5_:SelectedFighterGroup = new SelectedFighterGroup(_loc4_);
         _loc5_.x = param1 == 1 ? 10 : GameConfig.GAME_SIZE.x - 265;
         _loc5_.y = GameConfig.GAME_SIZE.y - 550;
         _loc5_.addFighter(null);
         _loc2_.group = _loc5_;
         return _loc2_;
      }
   }
}

