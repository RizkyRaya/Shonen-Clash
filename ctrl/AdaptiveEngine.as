package net.play5d.game.bvn.ctrl
{
   import flash.utils.getTimer;
   
   public class AdaptiveEngine
   {
      
      private static var _i:AdaptiveEngine;
      
      public static const LEVEL_NORMAL:int = 0;
      
      public static const LEVEL_LIGHT:int = 1;
      
      public static const LEVEL_MEDIUM:int = 2;
      
      public static const LEVEL_HEAVY:int = 3;
      
      private static const FRAME_SAMPLE_SIZE:int = 60;
      
      private static const SPIKE_THRESHOLD:Number = 6;
      
      private var _effectFrameIndex:uint = 0;
      
      private var _fps:int = 60;
      
      private var _frame:int = 0;
      
      private var _lastTime:int = 0;
      
      private var _level:int = LEVEL_NORMAL;
      
      private var _spawnCount:int = 0;
      
      private var _spawnLimit:int = 45;
      
      private var _frameTime:Number = 16.67;
      
      private var _avgFrameTime:Number = 16.67;
      
      private var _worstFrameTime:Number = 16.67;
      
      private var _bestFrameTime:Number = 16.67;
      
      private var _frameSamples:Vector.<Number>;
      
      private var _sampleIndex:int = 0;
      
      private var _sampleCount:int = 0;
      
      private var _sampleTotal:Number = 0;
      
      private var _lastFrameTick:int = 0;
      
      private var _frameVariance:Number = 0;
      
      private var _frameStability:Number = 100;
      
      private var _frameSpikeCount:int = 0;
      
      private var _performanceScore:Number = 100;
      
      private var _performanceLevel:int = LEVEL_NORMAL;
      
      public function AdaptiveEngine()
      {
         super();
         var now:int = getTimer();
         _lastTime = now;
         _lastFrameTick = now;
         _frameSamples = new Vector.<Number>(FRAME_SAMPLE_SIZE,true);
         var i:int = 0;
         while(i < FRAME_SAMPLE_SIZE)
         {
            _frameSamples[i] = 16.67;
            i++;
         }
         _sampleCount = FRAME_SAMPLE_SIZE;
         _sampleTotal = 16.67 * FRAME_SAMPLE_SIZE;
         updateSpawnLimit();
         GameRender.add(update,"adaptive");
      }
      
      public static function get I() : AdaptiveEngine
      {
         if(!_i)
         {
            _i = new AdaptiveEngine();
         }
         return _i;
      }
      
      private function update() : void
      {
         _effectFrameIndex = _effectFrameIndex + 1 & 0x7FFFFFFF;
         beginFrame();
         var now:int = getTimer();
         _frameTime = now - _lastFrameTick;
         _lastFrameTick = now;
         var oldVal:Number = _frameSamples[_sampleIndex];
         _frameSamples[_sampleIndex] = _frameTime;
         _sampleTotal = _sampleTotal - oldVal + _frameTime;
         if(++_sampleIndex >= FRAME_SAMPLE_SIZE)
         {
            _sampleIndex = 0;
         }
         ++_frame;
         if(now - _lastTime >= 1000)
         {
            _fps = _frame;
            _frame = 0;
            _lastTime = now;
            processFrameStats();
            updateLevel();
            updatePerformanceScore();
         }
      }
      
      private function processFrameStats() : void
      {
         _avgFrameTime = _sampleTotal / FRAME_SAMPLE_SIZE;
         var max:Number = _frameSamples[0];
         var min:Number = _frameSamples[0];
         var totalDiff:Number = 0;
         var spikes:int = 0;
         var prev:Number = _frameSamples[0];
         var i:int = 1;
         while(i < FRAME_SAMPLE_SIZE)
         {
            var val:Number = _frameSamples[i];
            if(val > max)
            {
               max = val;
            }
            if(val < min)
            {
               min = val;
            }
            var diff:Number = val - prev;
            if(diff < 0)
            {
               diff = -diff;
            }
            totalDiff += diff;
            if(diff > SPIKE_THRESHOLD)
            {
               spikes++;
            }
            prev = val;
            i++;
         }
         _worstFrameTime = max;
         _bestFrameTime = min;
         _frameVariance = totalDiff / (FRAME_SAMPLE_SIZE - 1);
         _frameSpikeCount = spikes;
         var stability:Number = 100 - _frameVariance * 4;
         if(stability < 0)
         {
            stability = 0;
         }
         else if(stability > 100)
         {
            stability = 100;
         }
         _frameStability = stability;
      }
      
      public function shouldAnimateEffect(effectIndex:int) : Boolean
      {
         return true;
      }
      
      public function shouldRenderOptionalEffect(effectIndex:int) : Boolean
      {
         switch(_level)
         {
            case LEVEL_NORMAL:
            case LEVEL_LIGHT:
               return true;
            case LEVEL_MEDIUM:
               return (effectIndex + _effectFrameIndex & 1) == 0;
            case LEVEL_HEAVY:
               return (effectIndex + _effectFrameIndex) % 3 == 0;
            default:
               return true;
         }
      }
      
      private function updateLevel() : void
      {
         var oldLevel:int = _level;
         switch(_level)
         {
            case LEVEL_NORMAL:
               if(_fps < 54)
               {
                  _level = LEVEL_LIGHT;
               }
               break;
            case LEVEL_LIGHT:
               if(_fps >= 58)
               {
                  _level = LEVEL_NORMAL;
               }
               else if(_fps < 46)
               {
                  _level = LEVEL_MEDIUM;
               }
               break;
            case LEVEL_MEDIUM:
               if(_fps >= 52)
               {
                  _level = LEVEL_LIGHT;
               }
               else if(_fps < 38)
               {
                  _level = LEVEL_HEAVY;
               }
               break;
            case LEVEL_HEAVY:
               if(_fps >= 44)
               {
                  _level = LEVEL_MEDIUM;
               }
         }
         if(oldLevel != _level)
         {
            updateSpawnLimit();
         }
      }
      
      private function updateSpawnLimit() : void
      {
         switch(_level)
         {
            case LEVEL_NORMAL:
               _spawnLimit = 45;
               break;
            case LEVEL_LIGHT:
               _spawnLimit = 30;
               break;
            case LEVEL_MEDIUM:
               _spawnLimit = 15;
               break;
            case LEVEL_HEAVY:
               _spawnLimit = 5;
         }
      }
      
      public function beginFrame() : void
      {
         _spawnCount = 0;
      }
      
      public function canSpawnEffect() : Boolean
      {
         return _spawnCount < _spawnLimit;
      }
      
      public function notifySpawn() : void
      {
         if(_spawnCount < _spawnLimit)
         {
            ++_spawnCount;
         }
      }
      
      public function getEffectBudget(maxEffect:int) : int
      {
         switch(_level)
         {
            case LEVEL_NORMAL:
               return maxEffect;
            case LEVEL_LIGHT:
               return int(maxEffect * 0.9);
            case LEVEL_MEDIUM:
               return int(maxEffect * 0.8);
            case LEVEL_HEAVY:
               return int(maxEffect * 0.6);
            default:
               return maxEffect;
         }
      }
      
      private function updatePerformanceScore() : void
      {
         var score:Number = 100;
         if(_fps < 60)
         {
            score -= (60 - _fps) * 0.8;
         }
         score -= (100 - _frameStability) * 0.4;
         score -= _frameSpikeCount * 2;
         if(score < 0)
         {
            score = 0;
         }
         else if(score > 100)
         {
            score = 100;
         }
         _performanceScore = score;
         if(score >= 90)
         {
            _performanceLevel = LEVEL_NORMAL;
         }
         else if(score >= 75)
         {
            _performanceLevel = LEVEL_LIGHT;
         }
         else if(score >= 55)
         {
            _performanceLevel = LEVEL_MEDIUM;
         }
         else
         {
            _performanceLevel = LEVEL_HEAVY;
         }
      }
      
      public function get performanceScore() : Number
      {
         return _performanceScore;
      }
      
      public function get performanceLevel() : int
      {
         return _performanceLevel;
      }
      
      public function get fps() : int
      {
         return _fps;
      }
      
      public function get frameTime() : Number
      {
         return _frameTime;
      }
      
      public function get averageFrameTime() : Number
      {
         return _avgFrameTime;
      }
      
      public function get worstFrameTime() : Number
      {
         return _worstFrameTime;
      }
      
      public function get bestFrameTime() : Number
      {
         return _bestFrameTime;
      }
      
      public function get frameVariance() : Number
      {
         return _frameVariance;
      }
      
      public function get frameStability() : Number
      {
         return _frameStability;
      }
      
      public function get frameSpikeCount() : int
      {
         return _frameSpikeCount;
      }
      
      public function get level() : int
      {
         return _level;
      }
      
      public function get spawnCount() : int
      {
         return _spawnCount;
      }
      
      public function get spawnLimit() : int
      {
         return _spawnLimit;
      }
      
      public function get effectScale() : Number
      {
         switch(_level)
         {
            case LEVEL_NORMAL:
               return 1;
            case LEVEL_LIGHT:
               return 0.9;
            case LEVEL_MEDIUM:
               return 0.8;
            case LEVEL_HEAVY:
               return 0.6;
            default:
               return 1;
         }
      }
      
      public function get isNormal() : Boolean
      {
         return _level == LEVEL_NORMAL;
      }
      
      public function get isLight() : Boolean
      {
         return _level == LEVEL_LIGHT;
      }
      
      public function get isMedium() : Boolean
      {
         return _level == LEVEL_MEDIUM;
      }
      
      public function get isHeavy() : Boolean
      {
         return _level == LEVEL_HEAVY;
      }
      
      public function dispose() : void
      {
         GameRender.remove(update,"adaptive");
         _frameSamples = null;
      }
   }
}

