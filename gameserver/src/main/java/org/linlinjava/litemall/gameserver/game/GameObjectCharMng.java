/*    */ package org.linlinjava.litemall.gameserver.game;
/*    */
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import java.util.List;
/*    */ import org.linlinjava.litemall.db.util.JSONUtils;
import org.linlinjava.litemall.gameserver.domain.Chara;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */
/*    */ public class GameObjectCharMng
        /*    */ {
    /* 11 */   private static final List<GameObjectChar> gameObjectCharList = new java.util.concurrent.CopyOnWriteArrayList();
    /*    */
    /*    */   public static void add(GameObjectChar gameObjectChar) {
        /* 14 */     if (gameObjectCharList.contains(gameObjectChar)) {
            /* 15 */       for (GameObjectChar gameSession : gameObjectCharList) {
                /* 16 */         if (gameObjectChar.chara.id == gameSession.chara.id)
                    /*    */         {
                    /* 18 */           gameSession.ctx.disconnect();
                    /* 19 */           gameObjectChar.gameTeam = gameSession.gameTeam;
                    /* 20 */           gameObjectCharList.remove(gameSession);
                    /*    */         }
                /*    */       }
            /*    */     }
        /* 24 */     gameObjectCharList.add(gameObjectChar);
        /*    */   }
    /*    */
    /*    */   public static void sendAll(BaseWrite baseWrite, Object obj) {
        /* 28 */     for (int i = 0; i < gameObjectCharList.size(); i++) {
            /* 29 */       GameObjectChar session = (GameObjectChar)gameObjectCharList.get(i);
            /* 30 */       ByteBuf write = baseWrite.write(obj);
            /* 31 */       session.ctx.writeAndFlush(write);
            /*    */     }
        /*    */   }
    /*    */
    /*    */   public static List<GameObjectChar> getGameObjectCharList() {
        /* 36 */     return gameObjectCharList;
        /*    */   }
    /*    */
    /*    */   public static void sendAllmap(BaseWrite baseWrite, Object obj, int mapid) {
        /* 40 */     for (int i = 0; i < gameObjectCharList.size(); i++) {
            /* 41 */       GameObjectChar gameObjectChar = (GameObjectChar)gameObjectCharList.get(i);
            /* 42 */       if (gameObjectChar.gameMap.id == mapid) {
                /* 43 */         ByteBuf write = baseWrite.write(obj);
                /* 44 */         gameObjectChar.ctx.writeAndFlush(write);
                /*    */       }
            /*    */     }
        /*    */   }
    /*    */
    /*    */   public static void sendAllmapname(BaseWrite baseWrite, Object obj, String mapname) {
        /* 50 */     for (int i = 0; i < gameObjectCharList.size(); i++) {
            /* 51 */       GameObjectChar gameObjectChar = (GameObjectChar)gameObjectCharList.get(i);
            /* 52 */       if (gameObjectChar.gameMap.name.equals(mapname)) {
                /* 53 */         ByteBuf write = baseWrite.write(obj);
                /* 54 */         gameObjectChar.ctx.writeAndFlush(write);
                /*    */       }
            /*    */     }
        /*    */   }
    /*    */
    /*    */   public static final GameObjectChar getGameObjectChar(int id) {
        /* 60 */     for (GameObjectChar gameObjectChar : gameObjectCharList) {
            /* 61 */       if (gameObjectChar.chara.id == id) {
                /* 62 */         return gameObjectChar;
                /*    */       }
            /*    */     }
        /* 65 */     return null;
        /*    */   }
    /*    */
    /*    */   public static final List<GameObjectChar> getAll() {
        /* 69 */     return gameObjectCharList;
        /*    */   }
    /*    */
    /*    */   public static void remove(GameObjectChar gameObjectChar) {
        /* 73 */     gameObjectChar.chara.updatetime = System.currentTimeMillis();
        /* 74 */     save(gameObjectChar);
        /*    */   }
    /*    */
    /*    */   public static void save(GameObjectChar gameObjectChar) {
        String data = gameObjectChar.characters.getData();
        Chara chara111 = JSONUtils.parseObject(data, Chara.class);
        if (chara111.level < gameObjectChar.chara.level)
        {
            throw new RuntimeException("角色等级回档！！！");
        }
        /* 78 */     gameObjectChar.characters.setData(org.linlinjava.litemall.db.util.JSONUtils.toJSONString(gameObjectChar.chara));
        /* 79 */     GameData.that.baseCharactersService.updateById(gameObjectChar.characters);
        /*    */   }
    /*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\game\GameObjectCharMng.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */