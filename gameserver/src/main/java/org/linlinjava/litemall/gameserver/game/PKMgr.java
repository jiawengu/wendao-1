package org.linlinjava.litemall.gameserver.game;

import com.alibaba.druid.sql.visitor.functions.Char;
import org.linlinjava.litemall.core.util.JSONUtils;
import org.linlinjava.litemall.db.domain.Characters;
import org.linlinjava.litemall.db.domain.LaoFang;
import org.linlinjava.litemall.db.domain.PKRecord;
import org.linlinjava.litemall.gameserver.data.vo.*;
import org.linlinjava.litemall.gameserver.data.write.*;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.fight.FightObject;
import org.linlinjava.litemall.gameserver.process.GameUtil;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class PKMgr {
    public  static  final List<String> safeMapNames  = Arrays.asList(new String[]{"天墉城","揽仙镇","无名小镇","东海渔村","五大门派仙山"});
    public enum  RecordType  {
        RecordType_BE_PK_RECORD( "be_pk_record", 1),
        RecordType_PK_RECORD("pk_record", 2),
        RecordType_SEARCH_PK("search_pk", 3);
        public  String typeStr;
        public  int value;
        RecordType(String typeStr, int value){
            this.typeStr = typeStr;
            this.value = value;
        }

        public  String getTypeStr(){return  this.typeStr;}

        public int getValue() {
            return value;
        }
    }

    public static  void onPKFight(Chara chara, Chara duiShouChara, boolean isWinPK, List<FightObject> winFightObjectList, List<FightObject> failFightObjectList){
        String serverName = "一战功成";
        String serverID = GameCore.that.getServerId();
        PKRecord record = GameData.that.basePKRecordService.findOneByPKCharaIDAndBePKChardID(chara.id, duiShouChara.id);
        if (record == null) {
            record = new PKRecord();
            record.setPkCharaId(chara.id);
            record.setBePkCharaId(duiShouChara.id);
            record.setWinState(isWinPK);
            record.setServerName(serverName);
            record.setServerId(serverID);
            GameData.that.basePKRecordService.add(record);

            record = GameData.that.basePKRecordService.findOneByPKCharaIDAndBePKChardID(chara.id, duiShouChara.id);
        }else{
            record.setWinState(isWinPK);
            record.setServerName(serverName);
            record.setServerId(serverID);
            GameData.that.basePKRecordService.updateById(record);
        }

        for (FightObject object :  winFightObjectList) {
            Chara tempChara = GameObjectCharMng.getGameObjectChar(winFightObjectList.get(0).fid).chara;
            LaoFang laoFang = GameData.that.baseLaoFangService.findOneByCharaID(tempChara.id);
            if(null == laoFang) {
                laoFang = new LaoFang();
                laoFang.setCharaId(tempChara.id);
                laoFang.setPkRecordId(record.getId());
                GameData.that.baseLaoFangService.add(laoFang);
            }else if(0 != laoFang.getItime()){
                laoFang.setItime((int) (System.currentTimeMillis()/1000));
                GameData.that.baseLaoFangService.updateById(laoFang);
            }

        }


        for (FightObject fightObject: failFightObjectList){
            Chara tempChara = GameObjectCharMng.getGameObjectChar(winFightObjectList.get(0).fid).chara;
            GameUtil.subdaohang(tempChara, (int) (tempChara.owner_name * 0.01));
            GameUtil.subjingyan(tempChara, (int) (tempChara.pot * 0.1));
            GameUtil.subQianNeng(tempChara, (int) (tempChara.cash*0.4));
            GameUtil.subJinQian(tempChara, (int) (tempChara.balance * 0.8));
        }
    }

    public  static  void getSearch(Chara chara, String type, String para){
        Characters characters ;
        if (type.equals("1")){
            characters = GameData.that.characterService.findOneByName(para);
        }else{
            characters = GameData.that.characterService.finOnByGiD(para);
        }
        List<PKRecord> lists = new ArrayList<>();
        lists.addAll( GameData.that.basePKRecordService.findByPKCharaIDAndBePKChardID(chara.id, characters.getId()));
        lists.addAll( GameData.that.basePKRecordService.findByPKCharaIDAndBePKChardID(characters.getId(), chara.id));

        Vo_MSG_PK_RECORD pkRecord = new Vo_MSG_PK_RECORD();
        pkRecord.type = "search_pk";
        Chara tempChara = GameObjectCharMng.getGameObjectChar(characters.getId()).chara;
        for (PKRecord record: lists) {
            Vo_PK_RECORD_ITEM item = new Vo_PK_RECORD_ITEM();
            item.gid = characters.getGid();
            item.level = tempChara.level;
            item.name = tempChara.name;
            item.icon = tempChara.waiguan;
            item.server_name = record.getServerName();
            item.update_time = record.getAddTime();
            pkRecord.items.add(item);
        }
        GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new M_MSG_PK_RECORD(), pkRecord);

    }

    public static  void getRecordByType(Chara chara, String type){
        List<PKRecord> lists = new ArrayList<>();
        if (type.equals("pk_record")){
            lists.addAll( GameData.that.basePKRecordService.findByPKCharaID(chara.id));
        }else if(type.equals("be_pk_record")){
            lists.addAll( GameData.that.basePKRecordService.findByBePKCharaID(chara.id));
        }
        Vo_MSG_PK_RECORD pkRecord = new Vo_MSG_PK_RECORD();
        pkRecord.type = type;
        for (PKRecord record: lists) {
            int chara_id = type.equals("pk_record") ? record.getBePkCharaId() : record.getPkCharaId();
            Characters characters = GameData.that.characterService.findById(chara_id);
            Chara tempChara = GameObjectCharMng.getGameObjectChar(chara_id).chara;
            Vo_PK_RECORD_ITEM item = new Vo_PK_RECORD_ITEM();
            item.gid = characters.getGid();
            item.level = tempChara.level;
            item.name = tempChara.name;
            item.icon = tempChara.waiguan;
            item.server_name = record.getServerName();
            item.update_time = record.getAddTime();
            pkRecord.items.add(item);
        }
        GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new M_MSG_PK_RECORD(), pkRecord);
    }

    public  static  void checkLaoFang(){
        List<LaoFang> laoFangList =  GameData.that.baseLaoFangService.findAllLessThanTime();
        for (LaoFang laoFang: laoFangList ) {
            if(0 == laoFang.getItime()) continue;
            laoFang.setDeleted(true);
            GameData.that.baseLaoFangService.deleteById(laoFang.getId());
        }
    }

    public static  void  getZuoLaoInfo(Chara chara){
        List<LaoFang> laoFangList =  GameData.that.baseLaoFangService.findAll();
        Vo_MSG_ZUOLAO_INFO vo = new Vo_MSG_ZUOLAO_INFO();
        for (LaoFang laoFang: laoFangList ) {
            long last_ti = laoFang.getItime() + 24*60*60 - System.currentTimeMillis()/1000;
            if (last_ti < 0 && 0 != laoFang.getItime() ) continue;
            ZUOLAO_INFO_ITEM item = new ZUOLAO_INFO_ITEM();
            Characters characters = GameData.that.characterService.findById(laoFang.getCharaId());
            Chara tempChara = GameObjectCharMng.getGameObjectChar(laoFang.getCharaId()).chara;
            PKRecord record = GameData.that.basePKRecordService.findById(laoFang.getPkRecordId());
            item.gid = characters.getGid();
            item.last_ti = last_ti;
            item.level = tempChara.level;
            item.name = tempChara.name;
            item.polar = tempChara.menpai;
            item.family = tempChara.chenhao;
            item.server_name = record.getServerName()+record.getServerId()+"线";
            vo.items.add(item);
        }
        GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new M_MSG_ZUOLAO_INFO(), vo);
        GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new M_MSG_ZUOLAO_INFO_FINISH(), null);
    }

    public  static  boolean onZuoLaoRelease(Chara chara , String gid, String name){
        Characters characters = GameData.that.characterService.finOnByGiD(gid);
        if (null == characters) return  false;
        LaoFang laoFang =  GameData.that.baseLaoFangService.findOneByCharaID(characters.getId());
        if (null == laoFang) return  false;
        laoFang.setDeleted(true);
        GameData.that.baseLaoFangService.deleteById(laoFang.getId());
        return  true;
    }

    public  static  boolean isZhuaBu(Chara chara, String mapName){
        if (!safeMapNames.contains(mapName)) return  false;
        LaoFang laoFang = GameData.that.baseLaoFangService.findOneByCharaID(chara.id);
        if (null == laoFang) return  false;
        if (0 != laoFang.getItime() && laoFang.getItime() + 24*60*60 < System.currentTimeMillis()/1000) return  false;
        return  true;
    }
//    public  static  GameMap onZhuaBu(Chara chara, String room_name ){
//        if (room_name.equals("监狱")){
//            LaoFang laoFang = GameData.that.baseLaoFangService.findOneByCharaID(chara.id);
//            if (laoFang.getItime() + 24*60*60 < System.currentTimeMillis()/1000){
//                GameMap gameMap = GameLine.getGameMap(chara.line, room_name);
//                return gameMap;
//            }
//            GameMap gameMap = GameLine.getGameMap(chara.line, "监狱");
//            return gameMap;
//        }
//         if(safeMapNames.contains( room_name)){
//             LaoFang laoFang = GameData.that.baseLaoFangService.findOneByCharaID(chara.id);
//             if (null == laoFang) {
//                 GameMap gameMap = GameLine.getGameMap(chara.line, room_name);
//                 return gameMap;
//             }
//             laoFang.setItime((int) (System.currentTimeMillis()/1000));
//             GameData.that.baseLaoFangService.updateById(laoFang);
//            GameMap gameMap = GameLine.getGameMap(chara.line, "监狱");
//            return gameMap;
//        }
//        GameMap gameMap = GameLine.getGameMap(chara.line, room_name);
//        return gameMap;
//    }
}
