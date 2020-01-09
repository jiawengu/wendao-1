package org.linlinjava.litemall.gameserver.game;

import org.linlinjava.litemall.db.domain.Npc;
import org.linlinjava.litemall.db.domain.ShangGuYaoWangInfo;
import org.linlinjava.litemall.db.domain.ShangGuYaoWangRewardInfo;
import org.linlinjava.litemall.db.domain.ZhuangbeiInfo;
import org.linlinjava.litemall.db.util.JSONUtils;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.domain.GoodsLanSe;
import org.linlinjava.litemall.gameserver.process.GameUtil;

import java.text.SimpleDateFormat;
import java.util.*;

public class GameShangGuYaoWang {
    public static  enum  YAOWANG_STATE{
        YAOWANG_STATE_NONE,//为开放
        YAOWANG_STATE_OPEN,//开放
    }


    public  static  void setYaoWangState(int npcID, YAOWANG_STATE state,
                                         int wa_chu_account_id){
        ShangGuYaoWangInfo  info =
                GameData.that.BaseShangGuYaoWangInfoService.findByNpcID(npcID);
        info.setState(state == YAOWANG_STATE.YAOWANG_STATE_OPEN);
        info.setWaChuAccountId(wa_chu_account_id);
        GameData.that.BaseShangGuYaoWangInfoService.updateById(info);
    }



    public  static  ShangGuYaoWangInfo getYaoWangNpc(int npcID,  YAOWANG_STATE state){
        return  GameData.that.BaseShangGuYaoWangInfoService.findByNpcID(npcID
                , state == YAOWANG_STATE.YAOWANG_STATE_OPEN);
    }


    public static boolean isCanFlat(Chara chara, int npcID){
        if (GameObjectChar.getGameObjectChar().gameTeam == null){
            return  false;
        }
        return  true;
    }

    public  static  boolean onReward(Chara chara, String npcName){
        Npc npc = (Npc) GameData.that.baseNpcService.findOneByName(npcName);
        if (null == npc) return  false;
        ShangGuYaoWangInfo  info =
                GameData.that.BaseShangGuYaoWangInfoService.findByNpcID(npc.getId());
        if (null == info ) return  false;

        String[] rewardStr = info.getReward().split(",");
        String tempRewardStr = "";
        for (int i =0 ; i < rewardStr.length ; i++){
            String[] tempWuPin = rewardStr[i].split("#");
            if (tempWuPin[0].contains("经验")){
                addReward(chara, tempWuPin[0], "",
                        Integer.valueOf(tempWuPin[1]));
                tempRewardStr += tempWuPin[0]+"#"+Integer.valueOf(tempWuPin[1]);
            }else if(tempWuPin[0].contains("道行")){
                addReward(chara, tempWuPin[0], "",
                        Integer.valueOf(tempWuPin[1]));
                tempRewardStr += tempWuPin[0]+"#"+Integer.valueOf(tempWuPin[1]);
            }else if(tempWuPin[0].contains("装备")){
                String [] zhuangBeiInfos = tempWuPin[1].split(":");
                String zhuangbeiName = zhuangbname(chara, zhuangBeiInfos[0]);
                addReward(chara, tempWuPin[0], zhuangbeiName,    1);
                tempRewardStr += zhuangbeiName;
            }else if(tempWuPin[0].contains("物品")){
                String [] wuPins = tempWuPin[1].split(":");
                String  good = wuPins[0].substring(wuPins[0].indexOf("[")+1,
                        wuPins[0].indexOf("]"));
                String[] goods = good.split("'");
                Random random = new Random();
                String tempGood = goods[random.nextInt(goods.length)];
                addReward(chara, tempWuPin[0], tempGood,    1);
                tempRewardStr += tempGood;
            }
        }

        GameTeam team = GameObjectCharMng.getGameObjectChar(chara.id).gameTeam;
        List<Chara> charas = team.duiwu;
        for (int i = 0;i < charas.size(); i++){
            Chara tempChara =charas.get(i);
            ShangGuYaoWangRewardInfo rewardInfo = new ShangGuYaoWangRewardInfo();
            org.linlinjava.litemall.db.domain.Characters characters = GameData.that.baseCharactersService.findById(tempChara.id);
            rewardInfo.setAccountId(characters.getAccountId());
            rewardInfo.setReward(tempRewardStr);
            rewardInfo.setCharactersId(characters.getId());

            SimpleDateFormat sdf= new SimpleDateFormat("yyyy-MM-dd");
            Date date = new Date();
            SimpleDateFormat formatter= new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            rewardInfo.setDate(sdf.format(date));
            rewardInfo.setDateTime(formatter.format(date));
            rewardInfo.setYaoWangId(npc.getId());

            GameData.that.BaseShangGuYaoWangRewardInfoService.add(rewardInfo);
        }
        return  true;
    }

    public  static  boolean addReward(Chara chara, String name,
                                      String jutiName, int count ){
        GameTeam team = GameObjectCharMng.getGameObjectChar(chara.id).gameTeam;
        List<Chara> charas = team.duiwu;
        for (int i = 0;i < charas.size(); i++){
            Chara tempChara = charas.get(i);
            if (name.contains("经验")){
                GameUtil.huodejingyan(tempChara, count);
            }else if (name.contains("道行")){
                GameUtil.adddaohang(tempChara, count);
            }else if(name.contains("装备")){
                ZhuangbeiInfo zhuangbeiInfo =
                        GameData.that.baseZhuangbeiInfoService.findOneByStr(jutiName);
                GameUtil.huodezhuangbei(chara, zhuangbeiInfo, 0, 1);
            }else if (name.contains("物品")){
                org.linlinjava.litemall.db.domain.StoreInfo info = GameData.that.baseStoreInfoService.findOneByName(jutiName);
                GameUtil.huodedaoju(chara, info, 1);
            }
        }
        return  true;
    }

    public static String zhuangbname(Chara chara, String  quality) {
        int eq_attrib = chara.level / 10 * 10;
        Random random = new Random();
        List<ZhuangbeiInfo> byAttrib =
                GameData.that.baseZhuangbeiInfoService.findByAttribAndQuality(Integer.valueOf(eq_attrib), quality);
        return byAttrib.get(random.nextInt(byAttrib.size())).getStr();
    }

}
