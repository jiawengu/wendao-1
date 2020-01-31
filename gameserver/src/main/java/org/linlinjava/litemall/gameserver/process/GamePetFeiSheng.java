package org.linlinjava.litemall.gameserver.process;

import org.linlinjava.litemall.db.domain.Npc;
import org.linlinjava.litemall.gameserver.data.vo.VO_MSG_PET_UPGRADE_PRE_INFO;
import org.linlinjava.litemall.gameserver.data.vo.Vo_16383_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_20480_0;
import org.linlinjava.litemall.gameserver.data.write.M20480_0;
import org.linlinjava.litemall.gameserver.data.write.MSG_MESSAGE_EX;
import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE_PETS;
import org.linlinjava.litemall.gameserver.data.write.M_MSG_PET_UPGRADE_PRE_INFO;
import org.linlinjava.litemall.gameserver.domain.Chara;
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

    public enum UPGRAD_TYPE{
        UPGRAD_TYPE_NO,
        UPGRAD_TYPE_UPING,
        UPGRAD_TYPE_FINSH,
    };

    public  static  boolean onPetFly(Chara chara){
        return  true;
    }

    public static boolean onChosePetFly(Chara chara, int petID){
        Petbeibao pet = chara.getPetByID(petID);
        if (pet.petShuXing.get(0).has_upgraded > UPGRAD_TYPE.UPGRAD_TYPE_NO.ordinal()){
            return  false;
        }

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
        GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new M20480_0(), vo_20480_0);



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
        for (int i = 0; i < 10; i++){
            list.add(guaiwuNames.get(chara.currentFlyFightIndex -1));
        }
        org.linlinjava.litemall.gameserver.fight.FightManager.goFightFeiSheng(chara, list);
    }

    public  static  boolean onPetFly(Chara chara , String menu_item){
        if (menu_item.equals("宠物飞升")) {
            chara.currentFlyFightIndex = 1;
            onFight(chara);
        }else if(menu_item.equals("飞升")){

            VO_MSG_PET_UPGRADE_PRE_INFO vo = new VO_MSG_PET_UPGRADE_PRE_INFO();
            vo.id = chara.pets.get(0).id;
            vo.pet_life_shape = 100;
            vo.pet_mag_shape = 100;
            vo.pet_mana_shape = 100;
            vo.pet_phy_shape = 100;
            vo.pet_speed_shape = 100;
            GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new M_MSG_PET_UPGRADE_PRE_INFO(), vo);
        }else if (menu_item.equals("帮派求助")){

        }
        return  true;
    }

    public  static  boolean onFightSuccess(Chara chara){
        if (chara.currentFlyFightIndex < MAX_FLY){
            chara.currentFlyFightIndex++;
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
            GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new M20480_0(), vo_20480_0);



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

    public static  boolean onFightFail(){
        return  true;
    }

    public  static  boolean isPetFeiSheng(String name){
        for (String guiWuname : guaiwuNames){
            if (guiWuname.contains(name)) return  true;
        }
        return  false;
    }
}
