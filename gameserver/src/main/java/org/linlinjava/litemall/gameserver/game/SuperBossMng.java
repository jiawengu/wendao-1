package org.linlinjava.litemall.gameserver.game;


import org.linlinjava.litemall.db.domain.Map;
import org.linlinjava.litemall.db.domain.Npc;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.process.GameUtil;
import org.linlinjava.litemall.gameserver.fight.FightManager;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

/**
 * 超级大BOSS 管理类
 * 目前的逻辑思路是：
 * 1、现在实现随机在某地图上将 一个BOSS 刷出去
 *  1、在玩家进入地图时将 BOSS NPC 放置到地图的某个坐标上
 *  2、点击 BOSS 弹出进入战斗对话框，可以选择是否挑战
 *  3、选择挑战的则进入战斗房间进行战斗
 *  4、战斗结束后给予玩家奖励
 * 2、实现 BOSS 出现地图和坐标的随机性
 * 3、实现 BOSS 分身控制，分身被打败后数量递减，这会涉及到一个问题，就是分身那么多 到底是分批挑战还是一起挑战，如果是分批挑战那最后的奖励给谁
 * 4、实现 BOSS 的挑战条件、奖励条件和奖励礼品、
 */
public class SuperBossMng {

    public static final Random RANDOM = new Random();

    //超级BOSS显示再地图上的形象
    public Npc npc = null;
    //当前 BOSS 是否在战斗状态，如果当前 BOSS 正被挑战则其他人不能挑战
    public boolean isFight = false;
    //BOSS 当前所在的地图，当玩家进入该地图或者在天机老人查询时使用
    public int mapid = -1;
    public String mapName = "";
    //当前BOSS的分身数量
    public int count = 50;

    public SuperBossMng(){
        this.npc = new Npc();
        this.npc.setId(0);
        this.npc.setIcon(6600);
        this.npc.setName("黑熊妖皇");
    }

    public boolean isBoss(int id){
        return this.npc.getId() == id;
    }

    public void sendBossDlg(){
        GameUtil.sendNpcDlg(this.npc, String.format("你好！小道长，我是#R%s#n，想要挑战我吗？ [我要挑战你/我要挑战超级大BOSS][离开/离开]", this.npc.getName()));
    }

    public void sendBossFight(Chara chara){
        List<String> monsterList = new ArrayList<String>();
        monsterList.add(this.npc.getName());
        FightManager.goFight(chara, monsterList);
    }

    public void randomBossPos(){
        if(this.mapid == -1){
            int [] mapids = new int[]{17100/*百花谷一*/, 17300/*百花谷三*/, 17700/*百花谷七*/, 17200/*百花谷二*/, 17600/*百花谷六*/, 17400/*百花谷四*/, 17500/*百花谷五*/};
            this.mapid = 17100;//mapids[SuperBossMng.RANDOM.nextInt(mapids.length)];
            this.setBossNpcPos(this.mapid, 60, 52);
            Map map = GameData.that.baseMapService.findByMapId(this.mapid).get(0);
            this.mapName = map.getName();
            System.out.println(String.format("分配 BOSS 到 %s作乱", this.mapName));
        }
    }

    // BOSS 被打败后需要清除所在的地图信息，以便下一个BOSS的出现
    public void clearBossMap(){
        this.mapid = -1;
        this.count = 50;
    }

    public boolean isExtBoss(){
        return this.mapid != -1;
    }

    /**
     * 设置 BOSS 在那个地图上的那个坐标
     * @param mapid
     * @param x
     * @param y
     */
    public void setBossNpcPos(int mapid, int x, int y){
        this.mapid = mapid;
        this.npc.setMapId(mapid);
        this.npc.setX(x);
        this.npc.setY(y);
    }
}
