package org.linlinjava.litemall.gameserver.game;

import org.linlinjava.litemall.db.domain.Npc;
import org.linlinjava.litemall.gameserver.data.constant.DefinedConst;
import org.linlinjava.litemall.gameserver.data.vo.VO_MSG_PET_UPGRADE_PRE_INFO;
import org.linlinjava.litemall.gameserver.data.vo.Vo_16383_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_20480_0;
import org.linlinjava.litemall.gameserver.data.write.MSG_NOTIFY_MISC;
import org.linlinjava.litemall.gameserver.data.write.MSG_MESSAGE_EX;
import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE_PETS;
import org.linlinjava.litemall.gameserver.data.write.M_MSG_PET_UPGRADE_PRE_INFO;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.domain.Goods;
import org.linlinjava.litemall.gameserver.domain.PetShuXing;
import org.linlinjava.litemall.gameserver.domain.Petbeibao;
import org.linlinjava.litemall.gameserver.game.GameData;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.linlinjava.litemall.gameserver.game.GameObjectCharMng;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class GamePetFeiSheng {
    public  static  final  int MAX_LEVEL = 115;
    public  static  final  int MAX_FLY = 3;
    public  static  final  String  zhanDouNpcName = "米兰仙子";
    public  static  final  String  YinLuNpcName = "灵兽异人";
    public  static  final  List<String>  guaiwuNames = Arrays.asList(new String[]{"武学道宠","物攻道宠","法攻道宠"});
    public  static  final  String  itemStr = "骑宠灵魂#3,驯兽诀#1，萦香丸#20，聚灵丹#20";

    public enum UPGRAD_TYPE{
        UPGRAD_TYPE_NO,
        UPGRAD_TYPE_UPING,
        UPGRAD_TYPE_FINSH,
    };

    public  static  boolean onPetFly(Chara chara){
        return  true;
    }

    public static boolean checkEnough(Chara chara, List<Goods> goodsList){
        String []  items = itemStr.split(",");
        for (int i = 0 ;i < items.length; i++){
            String [] tempItem = items[i].split("#");
            for (Goods goods: goodsList){
                if (items[i].contains(goods.goodsInfo.str) ){
                    if (goods.goodsInfo.owner_id < Integer.valueOf(tempItem[1]))
                        return  false;
                }
            }
        }
        return  true;
    }

    //判断是否当前飞升的宠物已经通过考验
    public  static  boolean isTongGuoKaoYan(Chara chara){
        if (chara.flyPetID == 0) return  false;
        Petbeibao pet = chara.getPetByID(chara.flyPetID);
        if (null == pet) return  false;
        if (pet.petShuXing.get(0).currentFlyFightIndex >= MAX_FLY) return  true;
        return  false;
    }



    //计算属性
    public static int[] calcShuXing(Petbeibao pet){
        PetShuXing  shuXing = pet.petShuXing.get(0);
        int[] result = new int[5];
        int rank = shuXing.rank;
        int pet_life_shape = 100;
        int pet_mag_shape = 100;
        int pet_mana_shape = 100;
        int pet_phy_shape = 100;
        int pet_speed_shape = 100;

        if (rank == DefinedConst.PET_RANK.PET_RANK_ELITE.ordinal()) { // 变异
            pet_life_shape = (int) (shuXing.life * ( 0.25D));
            pet_mana_shape = (int) (shuXing.mana * (0.25D));
            pet_speed_shape = (int) (shuXing.speed * (0.20D));
            pet_mag_shape = (int) (shuXing.pet_mag_shape * ( 0.25D));
            pet_phy_shape = (int) (shuXing.pet_phy_shape * ( 0.25D))+30;

        }else if (rank == DefinedConst.PET_RANK.PET_RANK_EPIC.ordinal() ) {// 神兽
            pet_life_shape = (int) (shuXing.life * (0.3D));
            pet_mana_shape = (int) (shuXing.mana * (0.3D));
            pet_speed_shape = (int) (shuXing.speed * (0.25D));
            pet_mag_shape = (int) (shuXing.pet_mag_shape * ( 0.3D));
            pet_phy_shape = (int) (shuXing.pet_phy_shape * ( 0.3D))+40;
        }else{
            pet_life_shape = (int) (shuXing.life * ( 0.2D));
            pet_mana_shape = (int) (shuXing.mana * ( 0.2D));
            pet_speed_shape = (int) (shuXing.speed * (0.15D));
            pet_mag_shape = (int) (shuXing.pet_mag_shape * ( 0.2D));
            pet_phy_shape = (int) (shuXing.pet_phy_shape * (0.2D))+20;
        }

//        shuXing.life = pet_life_shape;
//        shuXing.mana = pet_mana_shape;
//        shuXing.speed = pet_speed_shape;
//        shuXing.pet_mag_shape = pet_mag_shape;
//        shuXing.pet_phy_shape = pet_phy_shape;
        result[0] = pet_life_shape;
        result[1] = pet_mana_shape;
        result[2] = pet_speed_shape;
        result[3] = pet_mag_shape;
        result[4] = pet_phy_shape;
        return  result;
    }

    public static boolean onChosePetFly(Chara chara, int petID){
        Petbeibao pet = chara.getPetByID(petID);
        if (pet.petShuXing.get(0).has_upgraded > UPGRAD_TYPE.UPGRAD_TYPE_NO.ordinal()){
            return  false;
        }
        chara.flyPetID = petID;
        pet.petShuXing.get(0).has_upgraded = UPGRAD_TYPE.UPGRAD_TYPE_UPING.ordinal();

        List list = new ArrayList();
        list.add(pet);
        GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new MSG_UPDATE_PETS(), list);


        String msg = "";
        Npc npc = GameData.that.baseNpcService.findOneByName(zhanDouNpcName);
        org.linlinjava.litemall.db.domain.Map map =
                (org.linlinjava.litemall.db.domain.Map) GameData.that.baseMapService.findOneByMapId(npc.getMapId());
        msg ="请赶快去找#R"  + npc.getName() +
                "#n, "+ "在地图#Z" + map.getName() + "|" + map.getName() +
                "(" + npc.getX() + "," + npc.getY() + ")#Z上进行宠物飞升吧!";

        Vo_20480_0 vo_20480_0 = new Vo_20480_0();
        vo_20480_0.msg = msg;
        vo_20480_0.time = (int)(System.currentTimeMillis() / 1000L);
        GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new MSG_NOTIFY_MISC(), vo_20480_0);



        Vo_16383_0 vo_16383_5 = new Vo_16383_0();
        vo_16383_5.channel = 6;
        vo_16383_5.id = 0;
        vo_16383_5.name = "";
        vo_16383_5.msg =msg;
        vo_16383_5.time = (int)(System.currentTimeMillis() / 1000L);
        vo_16383_5.privilege = 0;
        vo_16383_5.server_name = "3周年14线";
        vo_16383_5.show_extra = 1;
        vo_16383_5.compress = 0;
        vo_16383_5.orgLength = 65535;
        vo_16383_5.cardCount = 0;
        vo_16383_5.voiceTime = 0;
        vo_16383_5.token = "";
        vo_16383_5.checksum = 0;
        GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new MSG_MESSAGE_EX(), vo_16383_5);

        return  true;
    }

    public  static  void onFight(Chara chara){
        List<String> list = new ArrayList();
        Petbeibao pet = chara.getPetByID(chara.flyPetID);
        for (int i = 0; i < 10; i++){
            list.add(guaiwuNames.get(pet.petShuXing.get(0).currentFlyFightIndex -1));
        }
        org.linlinjava.litemall.gameserver.fight.FightManager.goFightFeiSheng(chara, list);
    }

    public  static  boolean onPetFly(Chara chara , String menu_item){
        Petbeibao pet = chara.getPetByID(chara.flyPetID);
        if (menu_item.equals("宠物飞升")) {
            pet.petShuXing.get(0).currentFlyFightIndex = 1;
            onFight(chara);
        }else if(menu_item.equals("飞升")){
            int[] result = calcShuXing(pet);
            VO_MSG_PET_UPGRADE_PRE_INFO vo = new VO_MSG_PET_UPGRADE_PRE_INFO();
            vo.id = chara.pets.get(0).id;
            vo.pet_life_shape  = result[0];
            vo.pet_mana_shape  = result[1];
            vo.pet_speed_shape = result[2];
            vo.pet_mag_shape   = result[3];
            vo.pet_phy_shape   = result[4];
            GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new M_MSG_PET_UPGRADE_PRE_INFO(), vo);
        }else if (menu_item.equals("帮派求助")){

        }
        return  true;
    }

    public  static  boolean onFightSuccess(Chara chara){
        Petbeibao pet = chara.getPetByID(chara.flyPetID);
        if (pet.petShuXing.get(0).currentFlyFightIndex < MAX_FLY){
            pet.petShuXing.get(0).currentFlyFightIndex++;
            onFight(chara);
            return  true;
        }else{
            String msg = "";
            Npc npc = GameData.that.baseNpcService.findOneByName(YinLuNpcName);
            org.linlinjava.litemall.db.domain.Map map =
                    (org.linlinjava.litemall.db.domain.Map) GameData.that.baseMapService.findOneByMapId(npc.getMapId());
            msg ="请赶快去找#R"  + npc.getName() +
                    "#n, "+ "在地图#Z" + map.getName() + "|" + map.getName() +
                    "(" + npc.getX() + "," + npc.getY() + ")#Z上进行宠物飞升吧!";

            Vo_20480_0 vo_20480_0 = new Vo_20480_0();
            vo_20480_0.msg = msg;
            vo_20480_0.time = (int)(System.currentTimeMillis() / 1000L);
            GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new MSG_NOTIFY_MISC(), vo_20480_0);



            Vo_16383_0 vo_16383_5 = new Vo_16383_0();
            vo_16383_5.channel = 6;
            vo_16383_5.id = 0;
            vo_16383_5.name = "";
            vo_16383_5.msg =msg;
            vo_16383_5.time = (int)(System.currentTimeMillis() / 1000L);
            vo_16383_5.privilege = 0;
            vo_16383_5.server_name = "3周年14线";
            vo_16383_5.show_extra = 1;
            vo_16383_5.compress = 0;
            vo_16383_5.orgLength = 65535;
            vo_16383_5.cardCount = 0;
            vo_16383_5.voiceTime = 0;
            vo_16383_5.token = "";
            vo_16383_5.checksum = 0;
            GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new MSG_MESSAGE_EX(), vo_16383_5);
        }

        return  true;
    }

    public static  boolean onFightFail(Chara chara){
        Petbeibao pet = chara.getPetByID(chara.flyPetID);
        pet.petShuXing.get(0).currentFlyFightIndex = 0;
        return  true;
    }

    public  static  boolean isPetFeiSheng(String name){
        for (String guiWuname : guaiwuNames){
            if (guiWuname.contains(name)) return  true;
        }
        return  false;
    }
}
