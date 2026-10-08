package net.play5d.game.bvn.data.mosou
{
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.data.mosou.player.MosouFighterVO;
   
   public class MosouFighterModel
   {
      
      private static var _i:MosouFighterModel;
      
      private var _allFighters:Vector.<MosouFighterSellVO>;
      
      private var _inited:Boolean = false;
      
      public function MosouFighterModel()
      {
         super();
      }
      
      public static function get I() : MosouFighterModel
      {
         if(!_i)
         {
            _i = new MosouFighterModel();
         }
         return _i;
      }
      
      public function get fighters() : Vector.<MosouFighterSellVO>
      {
         var ownedFighters:Vector.<MosouFighterVO>;
         var sellVo:MosouFighterSellVO;
         var isOwned:Boolean;
         var vo:MosouFighterVO;
         var visibleList:Vector.<MosouFighterSellVO> = new Vector.<MosouFighterSellVO>();
         try
         {
            if(GameData.I && GameData.I.mosouData)
            {
               ownedFighters = GameData.I.mosouData.getFighterData();
               if(ownedFighters && _allFighters)
               {
                  for each(sellVo in _allFighters)
                  {
                     isOwned = false;
                     for each(vo in ownedFighters)
                     {
                        if(vo.id == sellVo.id)
                        {
                           isOwned = true;
                           break;
                        }
                     }
                     if(isOwned)
                     {
                        visibleList.push(sellVo);
                     }
                  }
                  return visibleList;
               }
            }
         }
         catch(e:Error)
         {
         }
         return new Vector.<MosouFighterSellVO>();
      }
      
      public function set fighters(val:Vector.<MosouFighterSellVO>) : void
      {
         _allFighters = val;
      }
      
      public function init() : void
      {
         if(!_inited)
         {
            initFighters();
            _inited = true;
         }
      }
      
      public function allCustom() : void
      {
         _allFighters = new Vector.<MosouFighterSellVO>();
         _inited = true;
      }
      
      private function initFighters() : void
      {
         _allFighters = new Vector.<MosouFighterSellVO>();
         _allFighters.push(new MosouFighterSellVO("ItachiEdo",45000));
         _allFighters.push(new MosouFighterSellVO("MinatoKcm",45000));
         _allFighters.push(new MosouFighterSellVO("Rider",45000));
         _allFighters.push(new MosouFighterSellVO("Zangetsu",45000));
         _allFighters.push(new MosouFighterSellVO("Ichigo",45000));
         _allFighters.push(new MosouFighterSellVO("IchigoBankai",45000));
         _allFighters.push(new MosouFighterSellVO("GohanBeast",45000));
         _allFighters.push(new MosouFighterSellVO("Aizen",45000));
         _allFighters.push(new MosouFighterSellVO("Ushiwakamaru",45000));
         _allFighters.push(new MosouFighterSellVO("Saber",45000));
         _allFighters.push(new MosouFighterSellVO("Gin",45000));
         _allFighters.push(new MosouFighterSellVO("RyougiShiki",45000));
         _allFighters.push(new MosouFighterSellVO("Miwa",45000));
         _allFighters.push(new MosouFighterSellVO("Natsu",45000));
         _allFighters.push(new MosouFighterSellVO("Naruto",45000));
         _allFighters.push(new MosouFighterSellVO("Obito",45000));
         _allFighters.push(new MosouFighterSellVO("Sasuke",45000));
         _allFighters.push(new MosouFighterSellVO("Kenshin",45000));
         _allFighters.push(new MosouFighterSellVO("KenshinBlue",45000));
         _allFighters.push(new MosouFighterSellVO("Yuta",45000));
         _allFighters.push(new MosouFighterSellVO("Vergil",45000));
         _allFighters.push(new MosouFighterSellVO("Kirito",45000));
         _allFighters.push(new MosouFighterSellVO("Asuna",45000));
         _allFighters.push(new MosouFighterSellVO("Nagato",45000));
         _allFighters.push(new MosouFighterSellVO("Touma",45000));
         _allFighters.push(new MosouFighterSellVO("Misaka",45000));
         _allFighters.push(new MosouFighterSellVO("Shinobu",45000));
         _allFighters.push(new MosouFighterSellVO("Nezuko",45000));
         _allFighters.push(new MosouFighterSellVO("Goku",45000));
         _allFighters.push(new MosouFighterSellVO("GokuSSJ4",45000));
         _allFighters.push(new MosouFighterSellVO("SaberAlter",45000));
         _allFighters.push(new MosouFighterSellVO("NarutoKcm",45000));
         _allFighters.push(new MosouFighterSellVO("Kirei",45000));
         _allFighters.push(new MosouFighterSellVO("Eugeo",45000));
         _allFighters.push(new MosouFighterSellVO("AsunaAlo",45000));
         _allFighters.push(new MosouFighterSellVO("GokuSSJ",45000));
         _allFighters.push(new MosouFighterSellVO("Minato",45000));
         _allFighters.push(new MosouFighterSellVO("GinV2",45000));
         _allFighters.push(new MosouFighterSellVO("IchigoHollow",45000));
         _allFighters.push(new MosouFighterSellVO("Yuji",45000));
         _allFighters.push(new MosouFighterSellVO("Sakura",45000));
         _allFighters.push(new MosouFighterSellVO("Cid",45000));
         _allFighters.push(new MosouFighterSellVO("Urahara",45000));
         _allFighters.push(new MosouFighterSellVO("Pain",45000));
         _allFighters.push(new MosouFighterSellVO("Byakuya",45000));
         _allFighters.push(new MosouFighterSellVO("Ulquiorra",45000));
         _allFighters.push(new MosouFighterSellVO("RedKenshin",45000));
         _allFighters.push(new MosouFighterSellVO("Hashirama",45000));
      }
      
      public function addFighter(param1:String, param2:int) : void
      {
         if(containsFighter(param1))
         {
            trace("MosouFighterModel.addFighter 重复：" + param1);
            return;
         }
         _allFighters.push(new MosouFighterSellVO(param1,param2));
      }
      
      private function containsFighter(param1:*) : Boolean
      {
         if(_allFighters)
         {
            for each(var _loc2_ in _allFighters)
            {
               if(_loc2_.id == param1)
               {
                  return true;
               }
            }
         }
         return false;
      }
   }
}

