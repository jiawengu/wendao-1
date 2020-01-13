/*    */ package org.linlinjava.litemall.gameserver.game;
/*    */ 
/*    */ import java.util.ArrayList;
/*    */ import java.util.HashMap;
/*    */ import java.util.List;
         import java.util.UUID;
/*    */ import org.linlinjava.litemall.db.service.base.BaseMapService;
/*    */ import org.springframework.context.annotation.Scope;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ @Service("glllbawsdfawelllll")
/*    */ @Scope("prototype")
/*    */ public class GameLine
/*    */ {
/*    */   public int lineNum;
/*    */   public String lineName;
/* 16 */   private List<GameMap> gameRoomList = new ArrayList();
/* 17 */   private java.util.Map<String, GameMap> gameRoomNameMap = new HashMap();
/*    */   private List<GameZone> gameZoneList = new java.util.concurrent.CopyOnWriteArrayList();
/* 19 */   public static GameShuaGuai gameShuaGuai = new GameShuaGuai();
    /*    */
/*    */   public void init()
/*    */   {
/* 25 */     List<org.linlinjava.litemall.db.domain.Map> all = GameData.that.baseMapService.findAll();
/* 26 */     for (org.linlinjava.litemall.db.domain.Map map : all) {
/* 27 */       GameMap gameMap = (GameMap)GameCore.getBean("gmmmasdfasdfmmmm", GameMap.class);
/* 28 */       gameMap.id = map.getMapId().intValue();
/* 29 */       gameMap.name = map.getName();
/* 30 */       gameMap.x = map.getX().intValue();
/* 31 */       gameMap.y = map.getY().intValue();
/* 32 */       this.gameRoomList.add(gameMap);
/* 33 */       this.gameRoomNameMap.put(gameMap.name, gameMap);
/*    */     }
/*    */   }
/*    */   
/*    */   public static GameMap getGameMapname(int line, String mapidname) {
/* 38 */     GameLine gameLine = GameCore.getGameLine(line);
/* 39 */     for (GameMap gameMap : gameLine.gameRoomList) {
/* 40 */       if (gameMap.name.equals(mapidname)) {
/* 41 */         return gameMap;
/*    */       }
/*    */     }
/* 44 */     return null;
/*    */   }
/*    */   
/*    */   public static GameMap getGameMap(int line, int mapid)
/*    */   {
/* 49 */     GameLine gameLine = GameCore.getGameLine(line);
/* 50 */     for (GameMap gameMap : gameLine.gameRoomList) {
/* 51 */       if (gameMap.id == mapid) {
/* 52 */         return gameMap;
/*    */       }
/*    */     }
/* 55 */     return null;
/*    */   }
/*    */   
/*    */   public static GameMap getGameMap(int line, String mapName) {
/* 59 */     GameLine gameLine = GameCore.getGameLine(line);
/* 60 */     return (GameMap)gameLine.gameRoomNameMap.get(mapName);
/*    */   }

            public static GameZone getGameZone(int line, String uuid) {
                GameLine gameLine = GameCore.getGameLine(line);
                for (GameZone gameZone : gameLine.gameZoneList) {
                    if (gameZone.uid.equals(uuid)) {
                       return  gameZone;
                    }
                }

                return null;
            }

            // 创建动态地图，需要创建者保存uid,主动删除（动态地图没人的时候也会自动删除）
            public static GameZone createGameZone(int line, int mapID) {
                GameLine gameLine = GameCore.getGameLine(line);
                GameZone gameZone = new GameZone();
                for (GameMap gameMap : gameLine.gameRoomList) {
                    if (gameMap.id == mapID) {
                        gameZone.id = mapID;
                        gameZone.name = gameMap.name;
                        gameZone.x = gameMap.x;
                        gameZone.y = gameMap.y;
                        break;
                    }
                }
                if (gameZone.id == 0)
                {
                    return null;
                }

                gameZone.uid = UUID.randomUUID().toString();
                gameLine.gameZoneList.add(gameZone);

                return gameZone;
            }

            public static void deleteZoneGameMap(int line, String uuid) {
                GameLine gameLine = GameCore.getGameLine(line);
                for (GameZone gameZone : gameLine.gameZoneList) {
                    if (gameZone.uid.equals(uuid)) {
                        gameLine.gameZoneList.remove(gameZone);
                        return;
                    }
                }
            }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\game\GameLine.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */