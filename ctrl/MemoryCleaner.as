package net.play5d.game.bvn.ctrl
{
   public class MemoryCleaner
   {
      
      private static var _i:MemoryCleaner;
      
      public function MemoryCleaner()
      {
         super();
      }
      
      public static function get I() : MemoryCleaner
      {
         if(!_i)
         {
            _i = new MemoryCleaner();
         }
         return _i;
      }
      
      public function clean() : void
      {
         cleanEffects();
         cleanFilters();
         cleanShadow();
         cleanTempCache();
         cleanRuntimePool();
      }
      
      private function cleanEffects() : void
      {
      }
      
      private function cleanFilters() : void
      {
      }
      
      private function cleanShadow() : void
      {
      }
      
      private function cleanTempCache() : void
      {
      }
      
      private function cleanRuntimePool() : void
      {
      }
   }
}

