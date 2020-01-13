package org.linlinjava.litemall.gameserver.game;

import org.linlinjava.litemall.core.util.JSONUtils;
import org.linlinjava.litemall.db.domain.*;
import org.linlinjava.litemall.gameserver.data.write.MSG_APPEAR_NPC;
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

    public static final  int propliaty  =   2000;//挖宝挖出的概率 万分比


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
    public static  Npc getShangGuYaoWangInfo(int mapID, String npcName){
        String levelstr = npcName.replace("上古妖王", "");
        int ilevel = Integer.valueOf(levelstr);
        List<ShangGuYaoWangInfo> infos =
                GameData.that.BaseShangGuYaoWangInfoService.findByLevel(ilevel);
        List<Npc> npcs = GameData.that.baseNpcService.findByMapId(mapID);
        for (int i = 0 ;i < npcs.size(); i++){
            for(int j = 0 ; j < infos.size(); j++){
                if (infos.get(j).getNpcid().intValue() == npcs.get(i).getId().intValue()){
                    return  npcs.get(i);
                }
            }
        }
        return  null;
    }
    public  static  boolean onChallengeFail(Chara chara, String npcName){
        Npc npc = getShangGuYaoWangInfo(chara.mapid, npcName);
        if (null == npc) return  false;
        Random random = new Random();
        npc.setX(random.nextInt(40)+1);
        npc.setY(random.nextInt(40)+1);
        npc.setDeleted(true);
        GameData.that.baseNpcService.updateById(npc);

        GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new MSG_APPEAR_NPC(), npc);
        ShangGuYaoWangInfo  info =
                GameData.that.BaseShangGuYaoWangInfoService.findByNpcID(npc.getId());
        if (null == info ) return  false;
        info.setState(false);
        GameData.that.BaseShangGuYaoWangInfoService.updateById(info);
        String [] chufas = info.getChufa().split(",");
        String[] rewardStr = info.getReward().split(",");
        String tempRewardStr = "";
        for (int i =0 ; i < chufas.length ; i++){
            String[] tempWuPin = chufas[i].split("#");
            if (tempWuPin[0].contains("经验")){
                subReward(chara, tempWuPin[0], "",
                        Integer.valueOf(tempWuPin[1]));
                tempRewardStr += tempWuPin[0]+"#"+Integer.valueOf(tempWuPin[1]);
            }else if(tempWuPin[0].contains("道行")){
                subReward(chara, tempWuPin[0], "",
                        Integer.valueOf(tempWuPin[1]));
                tempRewardStr += tempWuPin[0]+"#"+Integer.valueOf(tempWuPin[1]);
            }else if(tempWuPin[0].contains("装备")){
                String [] zhuangBeiInfos = tempWuPin[1].split(":");
                String zhuangbeiName = zhuangbname(chara, zhuangBeiInfos[0]);
                subReward(chara, tempWuPin[0], zhuangbeiName,    1);
                tempRewardStr += zhuangbeiName;
            }else if(tempWuPin[0].contains("物品")){
                String [] wuPins = tempWuPin[1].split(":");
                String  good = wuPins[0].substring(wuPins[0].indexOf("[")+1,
                        wuPins[0].indexOf("]"));
                String[] goods = good.split("'");
                String tempGood = goods[random.nextInt(goods.length)];
                subReward(chara, tempWuPin[0], tempGood,    1);
                tempRewardStr += tempGood;
            }
        }
        return true;
    }

    public  static  boolean onReward(Chara chara, String npcName){
        Npc npc = getShangGuYaoWangInfo(chara.mapid, npcName);
        if (null == npc) return  false;
        Random random = new Random();
        npc.setX(random.nextInt(40)+1);
        npc.setY(random.nextInt(40)+1);
        npc.setDeleted(true);
        GameData.that.baseNpcService.updateById(npc);
        GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new MSG_APPEAR_NPC(), npc);
        ShangGuYaoWangInfo  info =
                GameData.that.BaseShangGuYaoWangInfoService.findByNpcID(npc.getId());
        if (null == info ) return  false;
        info.setState(false);
        GameData.that.BaseShangGuYaoWangInfoService.updateById(info);
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
                if (random.nextInt(1000) < Integer.valueOf(zhuangBeiInfos[1])){
                    String zhuangbeiName = zhuangbname(chara, zhuangBeiInfos[0]);
                    addReward(chara, tempWuPin[0], zhuangbeiName,    1);
                    tempRewardStr += zhuangbeiName;
                }

            }else if(tempWuPin[0].contains("物品")){
                String [] wuPins = tempWuPin[1].split(":");
                if (random.nextInt(1000) < Integer.valueOf(wuPins[1])) {
                    String good = wuPins[0].substring(wuPins[0].indexOf("[") + 1,
                            wuPins[0].indexOf("]"));
                    String[] goods = good.split("'");
                    String tempGood = goods[random.nextInt(goods.length)];
                    addReward(chara, tempWuPin[0], tempGood, 1);
                    tempRewardStr += tempGood;
                }
            }
            else if(tempWuPin[0].contains("首饰")) {
                String[] wuPins = tempWuPin[1].split(":");
                if (random.nextInt(1000) < Integer.valueOf(wuPins[1])) {
                    String good = wuPins[0].substring(wuPins[0].indexOf("[") + 1,
                            wuPins[0].indexOf("]"));
                    String[] goods = good.split("'");
                    List<ZhuangbeiInfo> zhuangbeis = new ArrayList<>();
                    for (int j = 0; j < goods.length; j++) {
                        zhuangbeis.addAll(GameData.that.baseZhuangbeiInfoService.findByAmountAndAttrib(Integer.valueOf(goods[j]), 20));
                        zhuangbeis.addAll(GameData.that.baseZhuangbeiInfoService.findByAmountAndAttrib(Integer.valueOf(goods[j]), 40));
                    }


                    ZhuangbeiInfo tempzhuangbei =
                            zhuangbeis.get(random.nextInt(zhuangbeis.size()));
                    addReward(chara, tempWuPin[0], tempzhuangbei.getStr(), 1);
                    tempRewardStr += tempzhuangbei.getStr();
                }
            }
        }

        Characters cs = GameData.that.baseCharactersService.findById(info.getWaChuAccountId());
        Chara chara1 =  JSONUtils.parseObject(cs.getData(), Chara.class);
        addWaChuAcountReward(info.getWaChuReward().split(","), chara1);

//        GameTeam team = GameObjectCharMng.getGameObjectChar(chara.id).gameTeam;
//        List<Chara> charas = team.duiwu;
//        for (int i = 0;i < charas.size(); i++){
            Chara tempChara =chara;//charas.get(i);
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
//        }
        return  true;
    }

    public  static  void addWaChuAcountReward(String [] rewardStr, Chara chara){

        for (int i =0 ; i < rewardStr.length ; i++){
            String[] tempWuPin = rewardStr[i].split("#");
            if (tempWuPin[0].contains("经验")){
                GameUtil.huodejingyan(chara, Integer.valueOf(tempWuPin[1]));
            }else if(tempWuPin[0].contains("道行")){
                GameUtil.adddaohang(chara, Integer.valueOf(tempWuPin[1]));
            }else if(tempWuPin[0].contains("装备")){
                String [] zhuangBeiInfos = tempWuPin[1].split(":");
                String zhuangbeiName = zhuangbname(chara, zhuangBeiInfos[0]);

                ZhuangbeiInfo zhuangbeiInfo =
                        GameData.that.baseZhuangbeiInfoService.findOneByStr(zhuangbeiName);
                Random random = new Random();
                int[] eqType = { 1, 2, 10, 3 };
                int leixing = eqType[random.nextInt(4)];
                List<Hashtable<String, Integer>> hashtables = GameUtil.equipmentLuckDraw(chara.level, leixing);
                if (hashtables.size() > 0)
                {
                    for (Hashtable<String, Integer> maps : hashtables) {
                        if (((Integer)maps.get("groupNo")).intValue() == 2) {
                            maps.put("groupType", Integer.valueOf(2));
                            GoodsLanSe gooodsLanSe = (GoodsLanSe) org.linlinjava.litemall.db.util.JSONUtils.parseObject(org.linlinjava.litemall.db.util.JSONUtils.toJSONString(maps), GoodsLanSe.class);
                            GameUtil.huodezhuangbeiEx(chara, zhuangbeiInfo, 0, 1, gooodsLanSe);
                        }
                    }
                }
            }else if(tempWuPin[0].contains("物品")){
                String [] wuPins = tempWuPin[1].split(":");
                String  good = wuPins[0].substring(wuPins[0].indexOf("[")+1,
                        wuPins[0].indexOf("]"));
                String[] goods = good.split("'");
                Random random = new Random();
                String tempGood = goods[random.nextInt(goods.length)];

                org.linlinjava.litemall.db.domain.StoreInfo info = GameData.that.baseStoreInfoService.findOneByName(tempGood);
                GameUtil.huodedaoju(chara, info, 1);
            }else if(tempWuPin[0].contains("首饰")){
                String [] wuPins = tempWuPin[1].split(":");
                String  good = wuPins[0].substring(wuPins[0].indexOf("[")+1,
                        wuPins[0].indexOf("]"));
                String[] goods = good.split("'");
                Random random = new Random();
                List<ZhuangbeiInfo>  zhuangbeis =  new ArrayList<>();
                for (int j = 0; j < goods.length;j++){
                    zhuangbeis.addAll(GameData.that.baseZhuangbeiInfoService.findByAmountAndAttrib(Integer.valueOf(goods[j]), 20));
                    zhuangbeis.addAll(GameData.that.baseZhuangbeiInfoService.findByAmountAndAttrib(Integer.valueOf(goods[j]), 40));
                }

                ZhuangbeiInfo tempzhuangbei =
                        zhuangbeis.get(random.nextInt(zhuangbeis.size()));

                int[] eqType = { 1, 2, 10, 3 };
                int leixing = eqType[random.nextInt(4)];
                List<Hashtable<String, Integer>> hashtables = GameUtil.equipmentLuckDraw(chara.level, leixing);
                if (hashtables.size() > 0)
                {
                    for (Hashtable<String, Integer> maps : hashtables) {
                        if (((Integer)maps.get("groupNo")).intValue() == 2) {
                            maps.put("groupType", Integer.valueOf(2));
                            GoodsLanSe gooodsLanSe = (GoodsLanSe) org.linlinjava.litemall.db.util.JSONUtils.parseObject(org.linlinjava.litemall.db.util.JSONUtils.toJSONString(maps), GoodsLanSe.class);
                            GameUtil.huodezhuangbeiEx(chara, tempzhuangbei, 0, 1, gooodsLanSe);
                        }
                    }
                }
            }
        }
    }

    public  static  boolean addReward(Chara chara, String name,
                                      String jutiName, int count ){
//        GameTeam team = GameObjectCharMng.getGameObjectChar(chara.id).gameTeam;
//        List<Chara> charas = team.duiwu;
//        for (int i = 0;i < charas.size(); i++){
            Chara tempChara = chara;//charas.get(i);
            if (name.contains("经验")){
                GameUtil.huodejingyan(tempChara, count);
            }else if (name.contains("道行")){
                GameUtil.adddaohang(tempChara, count);
            }else if(name.contains("装备")){
                Random random = new Random();
                int[] eqType = { 1, 2, 10, 3 };
                int leixing = eqType[random.nextInt(4)];
                List<Hashtable<String, Integer>> hashtables = GameUtil.equipmentLuckDraw(chara.level, leixing);
               if (hashtables.size() > 0)
               {
                   ZhuangbeiInfo zhuangbeiInfo =
                           GameData.that.baseZhuangbeiInfoService.findOneByStr(jutiName);
                 for (Hashtable<String, Integer> maps : hashtables) {
                   if (((Integer)maps.get("groupNo")).intValue() == 2) {
                     maps.put("groupType", Integer.valueOf(2));
                     GoodsLanSe gooodsLanSe = (GoodsLanSe) org.linlinjava.litemall.db.util.JSONUtils.parseObject(org.linlinjava.litemall.db.util.JSONUtils.toJSONString(maps), GoodsLanSe.class);
                     GameUtil.huodezhuangbeiEx(chara, zhuangbeiInfo, 0, 1, gooodsLanSe);
                   }
                 }
               }

//                ZhuangbeiInfo zhuangbeiInfo =
//                        GameData.that.baseZhuangbeiInfoService.findOneByStr(jutiName);
//                GameUtil.huodezhuangbei(chara, zhuangbeiInfo, 0, 1);
            }else if (name.contains("物品")){
                org.linlinjava.litemall.db.domain.StoreInfo info = GameData.that.baseStoreInfoService.findOneByName(jutiName);
                GameUtil.huodedaoju(chara, info, 1);
            }else if (name.contains("首饰")){
//                ZhuangbeiInfo zhuangbeiInfo =
//                        GameData.that.baseZhuangbeiInfoService.findOneByStr(jutiName);
//                GameUtil.huodezhuangbei(chara, zhuangbeiInfo, 0, 1);

                Random random = new Random();
                int[] eqType = { 1, 2, 10, 3 };
                int leixing = eqType[random.nextInt(4)];
                List<Hashtable<String, Integer>> hashtables = GameUtil.equipmentLuckDraw(chara.level, leixing);
                if (hashtables.size() > 0)
                {
                    ZhuangbeiInfo zhuangbeiInfo =
                            GameData.that.baseZhuangbeiInfoService.findOneByStr(jutiName);
                    for (Hashtable<String, Integer> maps : hashtables) {
                        if (((Integer)maps.get("groupNo")).intValue() == 2) {
                            maps.put("groupType", Integer.valueOf(2));
                            GoodsLanSe gooodsLanSe = (GoodsLanSe) org.linlinjava.litemall.db.util.JSONUtils.parseObject(org.linlinjava.litemall.db.util.JSONUtils.toJSONString(maps), GoodsLanSe.class);
                            GameUtil.huodezhuangbeiEx(chara, zhuangbeiInfo, 0, 1, gooodsLanSe);
                        }
                    }
                }

            }
//        }
        return  true;
    }
    public  static  boolean subReward(Chara chara, String name,
                                      String jutiName, int count ){
//        GameTeam team = GameObjectCharMng.getGameObjectChar(chara.id).gameTeam;
//        List<Chara> charas = team.duiwu;
//        for (int i = 0;i < charas.size(); i++){
        Chara tempChara = chara;//charas.get(i);
        if (name.contains("经验")){
            GameUtil.subjingyan(tempChara, count);
        }else if (name.contains("道行")){
            GameUtil.subdaohang(tempChara, count);
        }
//        else if(name.contains("装备")){
//            ZhuangbeiInfo zhuangbeiInfo =
//                    GameData.that.baseZhuangbeiInfoService.findOneByStr(jutiName);
//            GameUtil.huodezhuangbei(chara, zhuangbeiInfo, 0, 1);
//        }else if (name.contains("物品")){
//            org.linlinjava.litemall.db.domain.StoreInfo info = GameData.that.baseStoreInfoService.findOneByName(jutiName);
//            GameUtil.huodedaoju(chara, info, 1);
//        }
//        }
        return  true;
    }

    public static String zhuangbname(Chara chara, String  quality) {
        int eq_attrib = (chara.level / 10) * 10;
        Random random = new Random();
        List<ZhuangbeiInfo> byAttrib =
                GameData.that.baseZhuangbeiInfoService.findByAttribAndQuality(Integer.valueOf(eq_attrib), quality);
        return byAttrib.get(random.nextInt(byAttrib.size())).getStr();
    }

}
