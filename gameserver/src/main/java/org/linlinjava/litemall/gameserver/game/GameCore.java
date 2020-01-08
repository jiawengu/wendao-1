/*    */ package org.linlinjava.litemall.gameserver.game;
/*    */ 
/*    */ import java.util.ArrayList;
/*    */ import java.util.HashMap;
/*    */ import java.util.List;
/*    */ import java.util.Map;
/*    */ import javax.annotation.PostConstruct;
/*    */ import org.linlinjava.litemall.gameserver.domain.BuildFields;
/*    */ import org.linlinjava.litemall.gameserver.fight.BattleUtils;
/*    */ import org.linlinjava.litemall.gameserver.fight.FightTianshuMap;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */ import org.linlinjava.litemall.gameserver.netty.NettyServer;
/*    */ import org.slf4j.Logger;
/*    */ import org.slf4j.LoggerFactory;
/*    */ import org.springframework.beans.factory.annotation.Autowired;
/*    */ import org.springframework.context.ApplicationContext;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ @Service
/*    */ public class GameCore
/*    */ {
/*    */   public static GameCore that;
/* 23 */   private static final Logger log = LoggerFactory.getLogger(GameCore.class);
/* 24 */   protected List<GameLine> gameLineList = new ArrayList();
/*    */   @Autowired
/*    */   private ApplicationContext applicationContext;
/*    */   @Autowired
/*    */   private List<BaseWrite> baseWrites;
/* 29 */   private static final Map<Integer, BaseWrite> basewriteMap = new HashMap();
/*    */   public NettyServer server;
/* 31 */   public long currentTime = 0L;
           public PartyMgr partyMgr;
/*    */   public void init(NettyServer server) {
/* 34 */     log.error("game init begin!");
                XLSConfigMgr.init();
/*    */
/* 36 */     this.server = server;
/* 37 */     for (int i = 0; i < 14; i++) {
/* 38 */       GameLine gameLine = (GameLine)this.applicationContext.getBean("glllbawsdfawelllll", GameLine.class);
/* 39 */       gameLine.lineNum = (i + 1);
/* 40 */       gameLine.lineName = ("一战功成 " + gameLine.lineNum);
/* 41 */       this.gameLineList.add(gameLine);
/* 42 */       gameLine.init();
/*    */     }
/*    */     
/* 45 */     BuildFields.init();
/* 46 */     BuildFields.add();
/* 47 */     BattleUtils.init();
/* 48 */     FightTianshuMap.init();
             this.partyMgr = new PartyMgr();
             this.partyMgr.init();
/* 49 */     log.error("game init over!");
/*    */   }
/*    */   
/*    */   @PostConstruct
/*    */   public void initAfter() {
/* 54 */     that = this;
/* 55 */     for (BaseWrite baseWrite : this.baseWrites) {
/* 56 */       basewriteMap.put(Integer.valueOf(baseWrite.cmd()), baseWrite);
/*    */     }
/*    */   }
/*    */   
/*    */   public static <T> T getBean(String name, Class<T> cls) {
/* 61 */     return (T)that.applicationContext.getBean(name, cls);
/*    */   }
/*    */   
/*    */   protected static BaseWrite getBaseWrite(int cmd) {
/* 65 */     return (BaseWrite)basewriteMap.get(Integer.valueOf(cmd));
/*    */   }
/*    */   
/*    */   public static GameLine getGameLine(int line) {
/* 69 */     for (GameLine gameLine : that.gameLineList) {
/* 70 */       if (gameLine.lineNum == line) {
/* 71 */         return gameLine;
/*    */       }
/*    */     }
/* 74 */     return null;
/*    */   }
/*    */   
/*    */   public List<GameLine> getGameLineAll() {
/* 78 */     return this.gameLineList;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\game\GameCore.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */