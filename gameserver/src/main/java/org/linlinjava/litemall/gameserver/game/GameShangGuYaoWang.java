package org.linlinjava.litemall.gameserver.game;

import org.linlinjava.litemall.core.util.JSONUtils;
import org.linlinjava.litemall.db.domain.*;
import org.linlinjava.litemall.gameserver.data.vo.ListVo_65527_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_20480_0;
import org.linlinjava.litemall.gameserver.data.write.*;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.domain.GoodsLanSe;
import org.linlinjava.litemall.gameserver.process.GameUtil;

import java.text.SimpleDateFormat;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class GameShangGuYaoWang {
    public static  enum  YAOWANG_STATE{
        YAOWANG_STATE_NONE,//为开放
        YAOWANG_STATE_OPEN,//开放
    }

    //public static final  int propliaty  =   2000;//挖宝挖出的概率 万分比

    public  static  ArrayList<Integer>  yaoWangIDList = new ArrayList<>();


    //发送妖王
    public  static  ShangGuYaoWangInfo sendYaoWang(Chara chara, int id ){
        Random rand = new Random();


        ShangGuYaoWangInfo  info =
                GameData.that.BaseShangGuYaoWangInfoService.findById(id);

        Npc npc = (Npc) GameData.that.baseNpcService.findByIdEx(info.getNpcid());
        if (null == npc ) return null;
        npc.setDeleted(false);
        npc.setX(rand.nextInt(20)+5);
        npc.setY(rand.nextInt(20)+5);
        GameData.that.baseNpcService.updateById(npc);
        GameUtil.notifyNpcAppear(npc);

        info.setState(true);

        info.setX(npc.getX());
        info.setY(npc.getY());
        GameData.that.BaseShangGuYaoWangInfoService.updateById(info);
        return  info;

    }

    //删除妖王
    public  static  boolean deleteYaoWang(Chara chara,int npc_id){
        Npc npc = (Npc) GameData.that.baseNpcService.findById(npc_id);
        if (null == npc) return  false;
        Random random = new Random();
//        npc.setX(random.nextInt(40)+1);
//        npc.setY(random.nextInt(40)+1);
        npc.setDeleted(true);
        GameData.that.baseNpcService.updateById(npc);
        GameUtil.notifyNpcDisappear(npc);
        return  true;
    }

    //是否是妖王
    public  static  boolean isYaoWang(String yaoWangName){
        return  yaoWangName.contains("上古妖王") || yaoWangName.contains("万年老妖");
    }

    //设置状态
//    public  static  void setYaoWangState(int npcID, YAOWANG_STATE state,
//                                         int wa_chu_account_id){
//        ShangGuYaoWangInfo  info =
//                GameData.that.BaseShangGuYaoWangInfoService.findByNpcID(npcID);
//        info.setState(state == YAOWANG_STATE.YAOWANG_STATE_OPEN);
//        info.setWaChuAccountId(wa_chu_account_id);
//        GameData.that.BaseShangGuYaoWangInfoService.updateById(info);
//    }


    //获取妖王npc
    public  static  ShangGuYaoWangInfo getYaoWangNpc(int npcID,  YAOWANG_STATE state){
        return  GameData.that.BaseShangGuYaoWangInfoService.findByNpcID(npcID
                , state == YAOWANG_STATE.YAOWANG_STATE_OPEN);
    }

    //根据mapID  和 npc名称获取 获取npc
    public static  Npc getShangGuYaoWangInfo(int mapID, String npcName){
        String regEx="[^0-9]";
        Pattern p = Pattern.compile(regEx);
        Matcher m = p.matcher(npcName);
        String levelstr = m.replaceAll("").trim();
        int ilevel = Integer.valueOf(levelstr);
        List<ShangGuYaoWangInfo> infos =
                GameData.that.BaseShangGuYaoWangInfoService.findByLevel(ilevel);
        int size = infos.size();
        String npcStr = npcName.replace(levelstr, "").replace("(", "").replace(")", "");
        for (int i = 0; i < size; ){
            if (i < infos.size() && !infos.get(i).getName().contains(npcStr)){
                infos.remove(i);
                size--;
            }else i++;
        }
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
    //战斗失败处罚
    public  static  boolean onChallengeFail(Chara chara, String npcName){
        Npc npc = getShangGuYaoWangInfo(chara.mapid, npcName);
        if (null == npc) return  false;
        Random random = new Random();


        deleteYaoWang(chara, npc.getId());

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

    //战斗奖励
    public  static  boolean onReward(Chara chara, String npcName){
        Npc npc = getShangGuYaoWangInfo(chara.mapid, npcName);
        if (null == npc) return  false;
        Random random = new Random();

        deleteYaoWang(chara, npc.getId());
        ShangGuYaoWangInfo  info =
                GameData.that.BaseShangGuYaoWangInfoService.findByNpcID(npc.getId());
        if (null == info ) return  false;
        info.setState(false);
        GameData.that.BaseShangGuYaoWangInfoService.updateById(info);
        String[] rewardStr = info.getReward().split(",");
        String tempRewardStr = "";

        ArrayList<Integer> levelList = new ArrayList<>();
        if (info.getName().contains("万年老妖")){
            levelList.add(60);
        }else{
            levelList.add(20);
            levelList.add(40);
        }

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
                        for (int k = 0; i < levelList.size(); k++){
                            zhuangbeis.addAll(GameData.that.baseZhuangbeiInfoService.findByAmountAndAttrib(Integer.valueOf(goods[j]), levelList.get(k)));
                        }
                    }


                    ZhuangbeiInfo tempzhuangbei =
                            zhuangbeis.get(random.nextInt(zhuangbeis.size()));
                    addReward(chara, tempWuPin[0], tempzhuangbei.getStr(), 1);
                    tempRewardStr += tempzhuangbei.getStr();
                }
            }else if(tempWuPin[0].contains("潜能")){
                addReward(chara, tempWuPin[0], "",
                        Integer.valueOf(tempWuPin[1]));
                tempRewardStr += tempWuPin[0]+"#"+Integer.valueOf(tempWuPin[1]);
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

    //奖励挖出者
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
            }else  if (tempWuPin[0].contains("潜能")){
                chara.cash += Integer.valueOf(tempWuPin[1]);
                Vo_20480_0 vo_20480_0 = new Vo_20480_0();
                vo_20480_0.msg = ("你获得了#R" + Integer.valueOf(tempWuPin[1]).intValue() + "#n点" + "潜能");
                vo_20480_0.time = 1562593376;
                GameObjectChar.send(new M20480_0(), vo_20480_0, chara.id);
                ListVo_65527_0 listVo_65527_0 = GameUtil.MSG_UPDATE(chara);
                GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new MSG_UPDATE(), listVo_65527_0);
            }
        }
    }

    //单个奖励某个玩家
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

            }else  if (name.contains("潜能")){
                chara.cash += count;
                Vo_20480_0 vo_20480_0 = new Vo_20480_0();
                vo_20480_0.msg = ("你获得了#R" + count + "#n点" + "潜能");
                vo_20480_0.time = 1562593376;
                GameObjectChar.send(new M20480_0(), vo_20480_0, chara.id);
                ListVo_65527_0 listVo_65527_0 = GameUtil.MSG_UPDATE(chara);
                GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new MSG_UPDATE(), listVo_65527_0);
            }
//        }
        return  true;
    }

    //单个处罚
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

    //根据玩家等级获取装备名称
    public static String zhuangbname(Chara chara, String  quality) {
        int eq_attrib = (chara.level / 10) * 10;
        Random random = new Random();
        List<ZhuangbeiInfo> byAttrib =
                GameData.that.baseZhuangbeiInfoService.findByAttribAndQuality(Integer.valueOf(eq_attrib), quality);
        return byAttrib.get(random.nextInt(byAttrib.size())).getStr();
    }

}
