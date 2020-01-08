//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.gameserver.fight;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Random;
import org.json.JSONObject;
import org.linlinjava.litemall.db.domain.Pet;
import org.linlinjava.litemall.db.domain.SkillMonster;
import org.linlinjava.litemall.db.domain.T_FightObject;
import org.linlinjava.litemall.db.domain.ZhuangbeiInfo;
import org.linlinjava.litemall.gameserver.data.game.BasicAttributesUtils;
import org.linlinjava.litemall.gameserver.data.game.PetAndHelpSkillUtils;
import org.linlinjava.litemall.gameserver.data.game.SuitEffectUtils;
import org.linlinjava.litemall.gameserver.data.vo.Vo_11757_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_19959_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_7655_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_7667_0;
import org.linlinjava.litemall.gameserver.data.write.MSG_C_UPDATE_STATUS;
import org.linlinjava.litemall.gameserver.data.write.MSG_C_ACTION;
import org.linlinjava.litemall.gameserver.data.write.M64981_Fight_Blood;
import org.linlinjava.litemall.gameserver.data.write.MSG_C_END_ACTION;
import org.linlinjava.litemall.gameserver.data.write.MSG_C_CHAR_REVIVE;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.domain.JiNeng;
import org.linlinjava.litemall.gameserver.domain.PetShuXing;
import org.linlinjava.litemall.gameserver.domain.Petbeibao;
import org.linlinjava.litemall.gameserver.domain.ShouHu;
import org.linlinjava.litemall.gameserver.domain.ShouHuShuXing;
import org.linlinjava.litemall.gameserver.game.GameData;
import org.linlinjava.litemall.gameserver.game.GameShuaGuai;
import org.linlinjava.litemall.gameserver.process.GameUtil;

public class FightObject {
    /**
     * 玩家id
     * 宠物id
     */
    public int id;
    /**
     * 玩家id
     */
    public int cid;
    /**
     * 玩家id,
     * 宠物id
     */
    public int fid;
    /**
     * 玩家名字
     */
    public String str;
    /**
     * 1:队长
     */
    public int leader;
    /**
     * 1:玩家
     * 2:宠物
     * 3:守护
     * 4:怪物
     */
    public int type;
    /**
     * 站位
     */
    public int pos;
    public int weapon_icon;
    public int guaiwulevel;
    /**
     * 法力值
     */
    public int mofa;
    /**
     * 生命
     */
    public int shengming;
    /**
     * 最大法力
     */
    public int max_mofa;
    /**
     * 最大生命
     */
    public int max_shengming;
    /**
     * 防御
     */
    public int fangyu;
    /**
     * 准确
     */
    public int accurate;
    /**
     * 法伤
     */
    public int fashang;
    /**
     * 敏捷或速度
     */
    public int parry;
    public int fangyu_ext;
    public int accurate_ext;
    public int fashang_ext;
    public int parry_ext;
    /**
     * 耐久
     */
    public int durability;
    public int org_icon;
    public int suit_icon;
    public int suit_light_effect;
    public int special_icon;
    /**
     * 1:正常
     * 2：死亡 可复活
     * 3：死亡不可复活、逃离战斗
     * 6:人或守护死亡时、其他类型可复活时
     * 7：不是人或守护且不可复活时
     */
    public int state = 1;
    private List<Integer> buffState = new ArrayList();
    /**
     * 技能列表
     */
    public List<JiNeng> skillsList;
    public FightRequest fightRequest;
    /**
     * 战斗技能列表
     */
    private List<FightSkill> fightSkillList = new ArrayList();
    public int autofight_select = 0;
    public int autofight_skillaction;
    public int autofight_skillno;
    /**
     * 道行
     */
    public int friend;
    /**
     * 守护、宠物:2
     */
    public int rank;
    /**
     * 天书技能
     */
    public int godbook;
    /**
     * 是否逃跑
     */
    public boolean run;
    /**
     * 通天塔星君
     */
    public FightObject tttXingjun;

    public FightObject(Chara chara) {
        this.id = chara.id;
        this.str = chara.name;
        this.weapon_icon = chara.weapon_icon;
        this.shengming = chara.max_life;
        this.mofa = chara.max_mana;
        this.max_shengming = chara.def + chara.zbAttribute.def;
        this.max_mofa = chara.dex + chara.zbAttribute.dex;
        this.fashang = chara.mana + chara.zbAttribute.mana;
        this.parry = chara.parry + chara.zbAttribute.parry;
        this.accurate = chara.accurate + chara.zbAttribute.accurate;
        this.fangyu = chara.wiz + chara.zbAttribute.wiz;
        this.suit_icon = chara.suit_icon;
        this.suit_light_effect = chara.suit_light_effect;
        this.org_icon = chara.waiguan;
        this.friend = chara.friend;
        this.skillsList = chara.jiNengList;
        this.type = 1;
        this.autofight_skillno = chara.autofight_skillno;
        this.autofight_select = chara.autofight_select;
        this.autofight_skillaction = chara.autofight_skillaction;
    }

    public boolean isDead() {
        return this.state == 2 || this.state == 3;
    }

    public boolean doDead() {
        if (this.state == 6) {
            this.state = 2;
        } else {
            if (this.state != 7) {
                return false;
            }

            this.state = 3;
        }

        List<FightRoundSkill> roundSkill = this.getRoundSkill();
        FightContainer fightContainer = FightManager.getFightContainer(this.fid);
        Iterator var3 = roundSkill.iterator();

        while(var3.hasNext()) {
            FightRoundSkill fightRoundSkill = (FightRoundSkill)var3.next();
            if (fightRoundSkill.getStateType() != 528128) {
                this.removeBuffState(fightContainer, fightRoundSkill.getStateType());
                this.fightSkillList.remove(fightRoundSkill);
            }
        }

        return true;
    }

    public List<FightRoundSkill> getRoundSkill() {
        List<FightRoundSkill> list = new ArrayList();
        Iterator var2 = this.fightSkillList.iterator();

        while(var2.hasNext()) {
            FightSkill fightSkill = (FightSkill)var2.next();
            if (fightSkill instanceof FightRoundSkill) {
                list.add((FightRoundSkill)fightSkill);
            }
        }

        return list;
    }

    public FightFabaoSkill getFabaoSkill() {
        Iterator var1 = this.fightSkillList.iterator();

        FightSkill fightSkill;
        do {
            if (!var1.hasNext()) {
                return null;
            }

            fightSkill = (FightSkill)var1.next();
        } while(!(fightSkill instanceof FightFabaoSkill));

        return (FightFabaoSkill)fightSkill;
    }

    public boolean isActiveTianshu(FightContainer fc, int state) {
        Iterator var3 = this.fightSkillList.iterator();

        while(var3.hasNext()) {
            FightSkill fightSkill = (FightSkill)var3.next();
            if (fightSkill instanceof FightTianshuSkill) {
                FightTianshuSkill fts = (FightTianshuSkill)fightSkill;
                if (fts.getStateType() == state) {
                    fts.sendEffect(fc);
                    return fts.isActive();
                }
            }
        }

        return false;
    }

    public FightObject(Chara chara, String name) {
        String strname = name;
        new Petbeibao();
        if (name.contains("土匪")) {
            strname = "土匪";
        }

        if (name.contains("强盗")) {
            strname = "强盗";
        }

        if (name.contains("狐狸妖")) {
            strname = "狐狸妖";
        }

        if (name.contains("鱼妖")) {
            strname = "鱼妖";
        }

        if (name.contains("蓝精")) {
            strname = "蓝精";
        }

        if (name.contains("黄怪")) {
            strname = "黄怪";
        }

        if (name.contains("疯魑")) {
            strname = "疯魑";
        }

        if (name.contains("狂魍")) {
            strname = "狂魍";
        }

        if (name.contains("蟒怪")) {
            strname = "蟒怪";
        }

        if (name.contains("鸟精")) {
            strname = "鸟精";
        }

        if (name.contains("琵琶妖")) {
            strname = "琵琶妖";
        }

        if (name.contains("蟒妖")) {
            strname = "蟒妖";
        }

        if (name.contains("怪王狂狮")) {
            strname = "怪王狂狮";
        }

        if (name.contains("鬼王黑熊")) {
            strname = "鬼王黑熊";
        }

        if (name.contains("鬼王悍猪")) {
            strname = "鬼王悍猪";
        }

        if (name.contains("混天巨象")) {
            strname = "混天巨象";
        }

        if (name.contains("兑灵")) {
            strname = "兑灵";
        }

        if (name.contains("艮灵")) {
            strname = "艮灵";
        }

        if (name.contains("坎灵")) {
            strname = "坎灵";
        }

        if (name.contains("离灵")) {
            strname = "离灵";
        }

        if (name.contains("狂灵")) {
            strname = "狂灵";
        }

        if (name.contains("疯灵")) {
            strname = "疯灵";
        }

        if (name.contains("山神")) {
            strname = "山神";
        }

        if (name.contains("炎神")) {
            strname = "炎神";
        }

        if (name.contains("雷神")) {
            strname = "雷神";
        }

        if (name.contains("花神")) {
            strname = "花神";
        }

        if (name.contains("龙神")) {
            strname = "龙神";
        }
//        if (name.contains("上古妖王")) {
//            strname = "上古妖王";
//        }

        if (name.contains("仙界叛逆")) {
            strname = chara.npcXuanShangName;
            this.friend = (int)(0.29D * (double)chara.level * (double)chara.level * (double)chara.level * 0.29D * (double)chara.level * (double)chara.level * (double)chara.level);
        }
        if(name.contains("星君")){//通天塔
            strname = name;
        }

        boolean isTTTPet = false;
        for(String petName:GameUtil.TONG_TIAN_TA_PET){
            if(petName.equals(name)){
                strname = name;
                isTTTPet = true;
                break;
            }
        }


        String names = "土匪#强盗#狐狸妖#鱼妖#蓝精#黄怪#疯魑#狂魍#蟒怪#鸟精#琵琶妖蟒妖#怪王狂狮#鬼王黑熊#鬼王悍猪#混天巨象#兑灵#艮灵#坎灵#离灵#狂灵#疯灵#山神#炎神#雷神#花神#龙神#刀斧手#火扇儒生#红衣剑客#试道元魔#上古妖王";
        Petbeibao petbeibao;
        if(isTTTPet ){
            petbeibao = tttPetCreate(strname, chara.ttt_layer);
        }else if(name.contains("星君")){
            petbeibao = this.petCreate(strname, chara.ttt_layer);
        } else if (!name.equals("帮凶") && !name.equals("喽啰") && !strname.equals("土匪") && !strname.equals("强盗") && !names.contains(strname)) {
            petbeibao = this.petCreate(strname);
        }else {
            petbeibao = this.petCreate(strname, chara.level);
        }

        List<SkillMonster> monsters = GameData.that.baseSkillMonsterService.findByName(strname);
        String skills = "";
        if (monsters != null && monsters.size() > 0) {
            for(int i = 0; i < monsters.size(); ++i) {
                if (((SkillMonster)monsters.get(i)).getType() == 1) {
                    skills = ((SkillMonster)monsters.get(i)).getSkills();
                }
            }
        }

        this.str = name;
        this.guaiwulevel = ((PetShuXing)petbeibao.petShuXing.get(0)).skill;
        this.shengming = (int)((double)((PetShuXing)petbeibao.petShuXing.get(0)).max_life * 0.8D);
        this.mofa = (int)((double)((PetShuXing)petbeibao.petShuXing.get(0)).max_mana * 0.8D);
        this.max_mofa = (int)((double)((PetShuXing)petbeibao.petShuXing.get(0)).dex * 0.8D);
        this.max_shengming = (int)((double)((PetShuXing)petbeibao.petShuXing.get(0)).def * 0.8D);
        this.fashang = (int)((double)((PetShuXing)petbeibao.petShuXing.get(0)).mana * 0.8D);
        this.parry = (int)((double)((PetShuXing)petbeibao.petShuXing.get(0)).parry * 0.8D);
        this.accurate = (int)((double)((PetShuXing)petbeibao.petShuXing.get(0)).accurate * 0.8D);
        this.fangyu = (int)((double)((PetShuXing)petbeibao.petShuXing.get(0)).wiz * 0.8D);
        this.org_icon = ((PetShuXing)petbeibao.petShuXing.get(0)).type;
        boolean isfagong = ((PetShuXing)petbeibao.petShuXing.get(0)).rank > ((PetShuXing)petbeibao.petShuXing.get(0)).pet_mag_shape;
        this.skillsList = dujineng(1, ((PetShuXing)petbeibao.petShuXing.get(0)).metal, ((PetShuXing)petbeibao.petShuXing.get(0)).skill, isfagong, 123456, skills);
        this.type = 4;
    }
    public FightObject(T_FightObject t_fightObject, int ttt_level){
        ttt_level = ttt_level-36;
        int metal = GameUtil.getMetal(t_fightObject.getPolar());

        this.str = t_fightObject.getName();
        this.guaiwulevel = ttt_level;
        this.shengming = (int) (t_fightObject.getLife()*(1+ttt_level*0.1));
        this.max_shengming = (int) (t_fightObject.getLife()*(1+ttt_level*0.1));
        this.mofa = (int) (t_fightObject.getMana()*(1+ttt_level*0.1));
        this.max_mofa = (int) (t_fightObject.getMana()*(1+ttt_level*0.1));
        this.fashang = (int) (t_fightObject.getMagAttack()*(1+ttt_level*0.1));
        this.parry = (int)(t_fightObject.getSpeed()*(1+ttt_level*0.1));
        this.accurate = (int)(t_fightObject.getPhyAttack()*(1+ttt_level*0.1));
        this.fangyu = (int)(t_fightObject.getDef()*(1+ttt_level*0.1));
        this.org_icon = t_fightObject.getIcon();

        this.skillsList = getJiNengListByName( metal, ttt_level, 123456, t_fightObject.getSkill());
        this.type = 4;
    }

    public int subtraction(int i) {
        Random r = new Random();
        if (i == 0) {
            return 0;
        }
        return r.nextInt(i);
    }

    /**
     * 是否可以攻击
     * @return
     */
    public boolean canAtta() {
        boolean canbe = true;
        if (this.state == 2 || this.state == 3) {
            canbe = false;
        }

        if (this.hasBuffState(3844) || this.hasBuffState(3856)) {
            canbe = false;
        }

        return canbe;
    }

    /**
     * 是否可以受到伤害
     * @return
     */
    public boolean canbeVictim() {
        boolean canbe = true;
        if (this.state == 2 || this.state == 3) {
            canbe = false;
        }

        return canbe;
    }

    public FightObject(String name) {
        this.str = name;
        Petbeibao petbeibao = this.petCreate(name);
        this.shengming = ((PetShuXing)petbeibao.petShuXing.get(0)).max_life;
        this.mofa = ((PetShuXing)petbeibao.petShuXing.get(0)).max_mana;
        this.max_mofa = ((PetShuXing)petbeibao.petShuXing.get(0)).dex;
        this.max_shengming = ((PetShuXing)petbeibao.petShuXing.get(0)).def;
        this.fashang = ((PetShuXing)petbeibao.petShuXing.get(0)).mana;
        this.parry = ((PetShuXing)petbeibao.petShuXing.get(0)).parry;
        this.accurate = ((PetShuXing)petbeibao.petShuXing.get(0)).accurate;
        this.fangyu = ((PetShuXing)petbeibao.petShuXing.get(0)).wiz;
        this.org_icon = ((PetShuXing)petbeibao.petShuXing.get(0)).type;
        boolean isfagong = ((PetShuXing)petbeibao.petShuXing.get(0)).rank > ((PetShuXing)petbeibao.petShuXing.get(0)).pet_mag_shape;
        this.skillsList = dujineng(1, ((PetShuXing)petbeibao.petShuXing.get(0)).metal, ((PetShuXing)petbeibao.petShuXing.get(0)).skill, isfagong, 123456, "");
        this.type = 4;
    }

    public FightObject(ShouHu shouHu) {
        this.str = ((ShouHuShuXing)shouHu.listShouHuShuXing.get(0)).str;
        this.shengming = ((ShouHuShuXing)shouHu.listShouHuShuXing.get(0)).max_life;
        this.max_shengming = ((ShouHuShuXing)shouHu.listShouHuShuXing.get(0)).def;
        this.fashang = ((ShouHuShuXing)shouHu.listShouHuShuXing.get(0)).mana;
        this.parry = ((ShouHuShuXing)shouHu.listShouHuShuXing.get(0)).parry;
        this.accurate = ((ShouHuShuXing)shouHu.listShouHuShuXing.get(0)).accurate;
        this.fangyu = ((ShouHuShuXing)shouHu.listShouHuShuXing.get(0)).wiz;
        this.org_icon = ((ShouHuShuXing)shouHu.listShouHuShuXing.get(0)).type;
        List<SkillMonster> monsters = GameData.that.baseSkillMonsterService.findByName(this.str);
        String skills = "";
        if (monsters != null && monsters.size() > 0) {
            for(int i = 0; i < monsters.size(); ++i) {
                if (((SkillMonster)monsters.get(i)).getType() == 2) {
                    skills = ((SkillMonster)monsters.get(i)).getSkills();
                }
            }
        }

        String[] split = skills.split("##");
        if (((ShouHuShuXing)shouHu.listShouHuShuXing.get(0)).max_degree == 0) {
            skills = split[0];
        } else {
            skills = split[1];
        }

        this.skillsList = dujineng(2, ((ShouHuShuXing)shouHu.listShouHuShuXing.get(0)).metal, ((ShouHuShuXing)shouHu.listShouHuShuXing.get(0)).skill, true, shouHu.id, skills);
        this.type = 3;
        this.durability = 32;
        this.rank = 2;
    }

    public FightObject(Petbeibao pet) {
        int life = ((PetShuXing)pet.petShuXing.get(0)).def;
        if (((PetShuXing)pet.petShuXing.get(0)).max_life > ((PetShuXing)pet.petShuXing.get(0)).def) {
            life = ((PetShuXing)pet.petShuXing.get(0)).max_life;
        }

        this.str = ((PetShuXing)pet.petShuXing.get(0)).str;
        this.shengming = life;
        this.mofa = ((PetShuXing)pet.petShuXing.get(0)).dex;
        this.max_mofa = ((PetShuXing)pet.petShuXing.get(0)).max_mana;
        this.max_shengming = life;
        this.fashang = ((PetShuXing)pet.petShuXing.get(0)).mana;
        this.parry = ((PetShuXing)pet.petShuXing.get(0)).parry;
        this.accurate = ((PetShuXing)pet.petShuXing.get(0)).accurate;
        this.fangyu = ((PetShuXing)pet.petShuXing.get(0)).wiz;
        this.org_icon = ((PetShuXing)pet.petShuXing.get(0)).type;
        boolean isfagong = ((PetShuXing)pet.petShuXing.get(0)).rank > ((PetShuXing)pet.petShuXing.get(0)).pet_mag_shape;
        this.skillsList = dujineng(1, ((PetShuXing)pet.petShuXing.get(0)).metal, ((PetShuXing)pet.petShuXing.get(0)).skill, isfagong, pet.id, "");
        this.type = 2;
        this.autofight_skillno = pet.autofight_skillno;
        this.autofight_select = pet.autofight_select;
        this.autofight_skillaction = pet.autofight_skillaction;
        this.friend = ((PetShuXing)pet.petShuXing.get(0)).intimacy / 2;
        this.durability = 32768;
        this.rank = 2;
    }

    /**
     * 奔雷
     * @param name
     * @return
     */
    public Petbeibao petCreate(String name) {
        Pet pet = GameData.that.basePetService.findOneByName(name);
        Petbeibao petbeibao = new Petbeibao();
        PetShuXing shuXing = new PetShuXing();
        shuXing.type = pet.getIcon();
        shuXing.passive_mode = pet.getIcon();
        shuXing.attrib = pet.getLevelReq();
        shuXing.str = pet.getName();
        shuXing.skill = 1;
        shuXing.pot = 0;
        shuXing.resist_poison = 258;
        shuXing.martial = 10000;
        shuXing.suit_polar = pet.getName();
        shuXing.auto_fight = shuXing.auto_fight + this.id;
        if (pet.getPolar().equals("金")) {
            shuXing.metal = 1;
        }

        if (pet.getPolar().equals("木")) {
            shuXing.metal = 2;
        }

        if (pet.getPolar().equals("水")) {
            shuXing.metal = 3;
        }

        if (pet.getPolar().equals("火")) {
            shuXing.metal = 4;
        }

        if (pet.getPolar().equals("土")) {
            shuXing.metal = 5;
        }

        shuXing.mana_effect = pet.getLife() - 40 - FightManager.RANDOM.nextInt(20) - 10;
        shuXing.attack_effect = pet.getMana() - 40 - FightManager.RANDOM.nextInt(20) - 10;
        shuXing.mag_effect = pet.getPhyAttack() - 40 - FightManager.RANDOM.nextInt(20) - 10;
        shuXing.phy_absorb = pet.getMagAttack() - 40 - FightManager.RANDOM.nextInt(20) - 10;
        shuXing.phy_effect = pet.getSpeed() - 40 - FightManager.RANDOM.nextInt(20) - 10;
        shuXing.pet_mana_shape = shuXing.mana_effect + 40;
        shuXing.pet_speed_shape = shuXing.attack_effect + 40;
        shuXing.pet_phy_shape = shuXing.phy_effect + 40;
        shuXing.pet_mag_shape = shuXing.mag_effect + 40;
        shuXing.rank = shuXing.phy_absorb + 40;
        shuXing.resist_point = shuXing.pet_mana_shape + shuXing.pet_speed_shape + shuXing.pet_phy_shape + shuXing.pet_mag_shape + shuXing.rank;
        shuXing.skill = pet.getLevelReq();
        shuXing.attrib = pet.getLevelReq();
        int polar_point = shuXing.skill * 4;
        int addpoint = FightManager.RANDOM.nextInt(polar_point - shuXing.skill * 3);
        polar_point -= addpoint;
        shuXing.life = shuXing.skill + addpoint;
        addpoint = FightManager.RANDOM.nextInt(polar_point);
        polar_point -= addpoint;
        shuXing.mag_power = shuXing.skill + addpoint;
        addpoint = FightManager.RANDOM.nextInt(polar_point);
        polar_point -= addpoint;
        shuXing.phy_power = shuXing.skill + addpoint;
        addpoint = FightManager.RANDOM.nextInt(polar_point);
        int var10000 = polar_point - addpoint;
        shuXing.speed = shuXing.skill + addpoint;
        petbeibao.petShuXing.add(shuXing);
        BasicAttributesUtils.petshuxing(shuXing);
        shuXing.max_life = shuXing.def;
        shuXing.max_mana = shuXing.dex;
        petbeibao.petShuXing.add(shuXing);
        return petbeibao;
    }

    public Petbeibao petCreate(String name, int level) {
        Pet pet = GameData.that.basePetService.findOneByName(name);
        Petbeibao petbeibao = new Petbeibao();
        PetShuXing shuXing = new PetShuXing();
        shuXing.type = pet.getIcon();
        shuXing.passive_mode = pet.getIcon();
        shuXing.attrib = pet.getLevelReq();
        shuXing.str = pet.getName();
        shuXing.skill = level;
        shuXing.pot = 0;
        shuXing.resist_poison = 258;
        shuXing.martial = 10000;
        shuXing.suit_polar = pet.getName();
        shuXing.auto_fight = shuXing.auto_fight + this.id;
        if (pet.getPolar().equals("金")) {
            shuXing.metal = 1;
        }

        if (pet.getPolar().equals("木")) {
            shuXing.metal = 2;
        }

        if (pet.getPolar().equals("水")) {
            shuXing.metal = 3;
        }

        if (pet.getPolar().equals("火")) {
            shuXing.metal = 4;
        }

        if (pet.getPolar().equals("土")) {
            shuXing.metal = 5;
        }

        shuXing.mana_effect = pet.getLife() - 40 - FightManager.RANDOM.nextInt(20) - 10;
        shuXing.attack_effect = pet.getMana() - 40 - FightManager.RANDOM.nextInt(20) - 10;
        shuXing.mag_effect = pet.getPhyAttack() - 40 - FightManager.RANDOM.nextInt(20) - 10;
        shuXing.phy_absorb = pet.getMagAttack() - 40 - FightManager.RANDOM.nextInt(20) - 10;
        shuXing.phy_effect = pet.getSpeed() - 40 - FightManager.RANDOM.nextInt(20) - 10;
        shuXing.pet_mana_shape = shuXing.mana_effect + 40;
        shuXing.pet_speed_shape = shuXing.attack_effect + 40;
        shuXing.pet_phy_shape = shuXing.phy_effect + 40;
        shuXing.pet_mag_shape = shuXing.mag_effect + 40;
        shuXing.rank = shuXing.phy_absorb + 40;
        shuXing.resist_point = shuXing.pet_mana_shape + shuXing.pet_speed_shape + shuXing.pet_phy_shape + shuXing.pet_mag_shape + shuXing.rank;
        int polar_point = shuXing.skill * 4;
        int addpoint = FightManager.RANDOM.nextInt(polar_point);
        polar_point -= addpoint;
        shuXing.life = shuXing.skill + addpoint;
        addpoint = FightManager.RANDOM.nextInt(polar_point);
        polar_point -= addpoint;
        shuXing.mag_power = shuXing.skill + addpoint;
        addpoint = FightManager.RANDOM.nextInt(polar_point);
        polar_point -= addpoint;
        shuXing.phy_power = shuXing.skill + addpoint;
        addpoint = FightManager.RANDOM.nextInt(polar_point);
        int var10000 = polar_point - addpoint;
        shuXing.speed = shuXing.skill + addpoint;
        petbeibao.petShuXing.add(shuXing);
        BasicAttributesUtils.petshuxing(shuXing);
        shuXing.max_life = shuXing.def;
        shuXing.max_mana = shuXing.dex;
        petbeibao.petShuXing.add(shuXing);
        return petbeibao;
    }
    public Petbeibao tttPetCreate(String name, int level) {
        T_FightObject pet = GameData.that.baseFightObjectService.findOneByName(name);
        Petbeibao petbeibao = new Petbeibao();
        PetShuXing shuXing = new PetShuXing();
        shuXing.type = pet.getIcon();
        shuXing.passive_mode = pet.getIcon();
        shuXing.attrib = level;
        shuXing.str = pet.getName();
        shuXing.skill = level;
        shuXing.pot = 0;
        shuXing.resist_poison = 258;
        shuXing.martial = 10000;
        shuXing.suit_polar = pet.getName();
        shuXing.auto_fight = shuXing.auto_fight + this.id;
        if (pet.getPolar().equals("金")) {
            shuXing.metal = 1;
        }

        if (pet.getPolar().equals("木")) {
            shuXing.metal = 2;
        }

        if (pet.getPolar().equals("水")) {
            shuXing.metal = 3;
        }

        if (pet.getPolar().equals("火")) {
            shuXing.metal = 4;
        }

        if (pet.getPolar().equals("土")) {
            shuXing.metal = 5;
        }

        shuXing.mana_effect = pet.getLife() - 40 - FightManager.RANDOM.nextInt(20) - 10;
        shuXing.attack_effect = pet.getMana() - 40 - FightManager.RANDOM.nextInt(20) - 10;
        shuXing.mag_effect = pet.getPhyAttack() - 40 - FightManager.RANDOM.nextInt(20) - 10;
        shuXing.phy_absorb = pet.getMagAttack() - 40 - FightManager.RANDOM.nextInt(20) - 10;
        shuXing.phy_effect = pet.getSpeed() - 40 - FightManager.RANDOM.nextInt(20) - 10;
        shuXing.pet_mana_shape = shuXing.mana_effect + 40;
        shuXing.pet_speed_shape = shuXing.attack_effect + 40;
        shuXing.pet_phy_shape = shuXing.phy_effect + 40;
        shuXing.pet_mag_shape = shuXing.mag_effect + 40;
        shuXing.rank = shuXing.phy_absorb + 40;
        shuXing.resist_point = shuXing.pet_mana_shape + shuXing.pet_speed_shape + shuXing.pet_phy_shape + shuXing.pet_mag_shape + shuXing.rank;
        int polar_point = shuXing.skill * 4;
        int addpoint = FightManager.RANDOM.nextInt(polar_point);
        polar_point -= addpoint;
        shuXing.life = shuXing.skill + addpoint;
        addpoint = FightManager.RANDOM.nextInt(polar_point);
        polar_point -= addpoint;
        shuXing.mag_power = shuXing.skill + addpoint;
        addpoint = FightManager.RANDOM.nextInt(polar_point);
        polar_point -= addpoint;
        shuXing.phy_power = shuXing.skill + addpoint;
        addpoint = FightManager.RANDOM.nextInt(polar_point);
        int var10000 = polar_point - addpoint;
        shuXing.speed = shuXing.skill + addpoint;
        petbeibao.petShuXing.add(shuXing);
        BasicAttributesUtils.petshuxing(shuXing);
        shuXing.max_life = shuXing.def;
        shuXing.max_mana = shuXing.dex;
        petbeibao.petShuXing.add(shuXing);
        return petbeibao;
    }

    /**
     *
     * @param leixing 宠物：1，守护：2
     * @param pos   金木水火土
     * @param level
     * @param isMagic
     * @param id
     * @param skills
     * @return
     */
    public static List<JiNeng> dujineng(int leixing, int pos, int level, boolean isMagic, int id, String skills) {
        List<JiNeng> jiNengList = new ArrayList();
        List<JSONObject> nomelSkills = PetAndHelpSkillUtils.getNomelSkills(leixing, pos, level, true, skills);

        for(int i = 0; i < nomelSkills.size(); ++i) {
            JiNeng jiNeng = new JiNeng();
            JSONObject jsonObject = (JSONObject)nomelSkills.get(i);
            jiNeng.id = id;
            jiNeng.skill_no = Integer.parseInt((String)jsonObject.get("skillNo"));
            jiNeng.skill_attrib = (Integer)jsonObject.get("skillLevel");
            jiNeng.skill_level = (Integer)jsonObject.get("skillLevel");
            jiNeng.skillRound = jsonObject.optInt("skillRound");
            jiNeng.level_improved = 0;
            jiNeng.skill_mana_cost = (Integer)jsonObject.get("skillBlue");
            jiNeng.skill_nimbus = 42949672;
            jiNeng.skill_disabled = 0;
            jiNeng.range = (Integer)jsonObject.get("skillNum");
            jiNeng.max_range = (Integer)jsonObject.get("skillNum");
            jiNengList.add(jiNeng);
        }

        return jiNengList;
    }

    /**
     * 技能名字是逗号分隔
     * @param metal 门派
     * @param skillNames
     * @return
     */
    public static List<JiNeng> getJiNengListByName(int metal, int level, int id, String skillNames){
        List<JiNeng> jiNengList = new ArrayList();
        List<JSONObject> nomelSkills = PetAndHelpSkillUtils.getSkills(metal, level, skillNames);

        for(int i = 0; i < nomelSkills.size(); ++i) {
            JiNeng jiNeng = new JiNeng();
            JSONObject jsonObject = nomelSkills.get(i);
            jiNeng.id = id;
            jiNeng.skill_no = Integer.parseInt((String)jsonObject.get("skillNo"));
            jiNeng.skill_attrib = (Integer)jsonObject.get("skillLevel");
            jiNeng.skill_level = (Integer)jsonObject.get("skillLevel");
            jiNeng.skillRound = jsonObject.optInt("skillRound");
            jiNeng.level_improved = 0;
            jiNeng.skill_mana_cost = (Integer)jsonObject.get("skillBlue");
            jiNeng.skill_nimbus = 42949672;
            jiNeng.skill_disabled = 0;
            jiNeng.range = (Integer)jsonObject.get("skillNum");
            jiNeng.max_range = (Integer)jsonObject.get("skillNum");
            jiNengList.add(jiNeng);
        }

        return jiNengList;
    }

    public void updateState(FightContainer fightContainer, int state, int type) {
        Vo_11757_0 vo_11757_0 = new Vo_11757_0();
        vo_11757_0.id = this.fid;
        vo_11757_0.list.add(state);
        vo_11757_0.list.add(type);
        FightManager.send(fightContainer, new MSG_C_UPDATE_STATUS(), vo_11757_0);
    }

    public void updateState(FightContainer fightContainer) {
        Vo_11757_0 vo_11757_0 = new Vo_11757_0();
        vo_11757_0.id = this.fid;
        if (this.buffState.isEmpty()) {
            vo_11757_0.list.add(0);
            vo_11757_0.list.add(0);
        } else {
            Vo_19959_0 vo_19959_0 = new Vo_19959_0();
            vo_19959_0.round = fightContainer.round;
            vo_19959_0.aid = this.fid;
            vo_19959_0.action = 43;
            vo_19959_0.vid = this.fid;
            vo_19959_0.para = 0;
            FightManager.send(fightContainer, new MSG_C_ACTION(), vo_19959_0);
            int value = 0;

            Integer integer;
            for(Iterator var5 = this.buffState.iterator(); var5.hasNext(); value += integer) {
                integer = (Integer)var5.next();
            }

            vo_11757_0.list.add(value);
            vo_11757_0.list.add(32);
            Vo_7655_0 vo_7655_0 = new Vo_7655_0();
            vo_7655_0.id = this.fid;
            FightManager.send(fightContainer, new MSG_C_END_ACTION(), vo_7655_0);
        }

        FightManager.send(fightContainer, new MSG_C_UPDATE_STATUS(), vo_11757_0);
    }

    /**
     * 通知fightContainer所有的玩家，当前战斗对象的血量
     * @param fightContainer
     */
    public void update(FightContainer fightContainer) {
        ArrayList<Integer> objects = new ArrayList();
        objects.add(this.fid);
        objects.add(this.shengming);
        FightManager.send(fightContainer, new M64981_Fight_Blood(), objects);
    }

    public int reduceShengming(int reduce, boolean fabao) {
        if (!this.canbeHurt()) {
            return 0;
        } else {
            if (this.hasBuffState(3844)) {
                this.removeBuffSK(FightManager.getFightContainer(this.fid), 3844);
            }

            if (fabao) {
                FightFabaoSkill fabaoSkill = this.getFabaoSkill();
                if (fabaoSkill != null && fabaoSkill.getStateType() == 8015 && fabaoSkill.isActive()) {
                    fabaoSkill.sendEffect(FightManager.getFightContainer(this.fid));
                    reduce = 0;
                }
            }

            if (this.shengming <= reduce) {
                reduce = this.shengming;
                this.shengming = 0;
                if (this.type != 1 && this.type != 3) {
                    if (this.canbeRevive()) {
                        this.state = 6;
                    } else {
                        this.state = 7;
                    }
                } else {
                    this.state = 6;
                }
            } else {
                this.shengming -= reduce;
            }

            return reduce;
        }
    }

    public int addShengming(int reduce) {
        if (this.shengming + reduce <= this.max_shengming) {
            this.shengming += reduce;
        } else {
            reduce = this.max_shengming - this.shengming;
            this.shengming = this.max_shengming;
        }

        return reduce;
    }

    public void addBuffState(FightContainer fightContainer, Integer state) {
        if (!this.isBingdong()) {
            if (!this.buffState.contains(state)) {
                this.buffState.add(state);
                this.updateState(fightContainer);
            }

            switch(state) {
                case 3842:
                    this.removeBuffSK(fightContainer, 3856);
                    this.removeBuffSK(fightContainer, 3844);
                    this.removeBuffSK(fightContainer, 20224);
                    this.removeBuffSK(fightContainer, 265984);
                    this.removeBuffSK(fightContainer, 12032);
                    this.removeBuffSK(fightContainer, 134912);
                    break;
                case 3844:
                    this.removeBuffSK(fightContainer, 3848);
                    this.removeBuffSK(fightContainer, 3856);
                    this.removeBuffSK(fightContainer, 3872);
                    this.removeBuffSK(fightContainer, 3842);
                    break;
                case 3848:
                    this.removeBuffSK(fightContainer, 3856);
                    this.removeBuffSK(fightContainer, 3844);
                    this.removeBuffSK(fightContainer, 3872);
                    break;
                case 3856:
                    this.removeBuffSK(fightContainer, 3848);
                    this.removeBuffSK(fightContainer, 3844);
                    this.removeBuffSK(fightContainer, 3872);
                    this.removeBuffSK(fightContainer, 3842);
                    break;
                case 3872:
                    this.removeBuffSK(fightContainer, 3848);
                    this.removeBuffSK(fightContainer, 3856);
                    this.removeBuffSK(fightContainer, 3844);
                    break;
                case 12032:
                    this.removeBuffSK(fightContainer, 20224);
                    break;
                case 20224:
                    this.removeBuffSK(fightContainer, 12032);
                    break;
                case 134912:
                    this.removeBuffSK(fightContainer, 265984);
                    break;
                case 265984:
                    this.removeBuffSK(fightContainer, 134912);
            }

        }
    }

    public void removeBuffSK(FightContainer fightContainer, Integer state) {
        this.removeBuffState(fightContainer, state);
        this.removeFightSkill(state);
    }

    public void removeBuffState(FightContainer fightContainer, Integer state) {
        if (this.buffState.remove(state)) {
            this.updateState(fightContainer);
        }

    }

    public void addSkill(FightSkill fightSkill) {
        List<FightRoundSkill> roundSkill = this.getRoundSkill();
        Iterator var3 = roundSkill.iterator();

        while(var3.hasNext()) {
            FightRoundSkill skill = (FightRoundSkill)var3.next();
            if (skill.getStateType() == fightSkill.getStateType()) {
                this.removeSkill(skill);
            }
        }

        this.fightSkillList.add(fightSkill);
    }

    public void removeSkill(FightSkill fightSkill) {
        this.fightSkillList.remove(fightSkill);
    }

    public void removeFightSkill(int buffstate) {
        List<FightRoundSkill> roundSkill = this.getRoundSkill();
        Iterator var3 = roundSkill.iterator();

        while(var3.hasNext()) {
            FightRoundSkill fightRoundSkill = (FightRoundSkill)var3.next();
            if (fightRoundSkill.getStateType() == buffstate) {
                this.fightSkillList.remove(fightRoundSkill);
            }
        }

    }

    /**
     * 复活
     * @param fightContainer
     */
    public void revive(FightContainer fightContainer) {
        Vo_7667_0 vo_7667_0 = new Vo_7667_0();
        vo_7667_0.id = this.fid;
        FightManager.send(fightContainer, new MSG_C_CHAR_REVIVE(), vo_7667_0);
        this.update(fightContainer);
        FightResult fightResult = new FightResult();
        fightResult.id = this.fid;
        fightResult.vid = this.fid;
        fightResult.point = this.shengming;
        fightResult.effect_no = 10005;
        fightResult.damage_type = 0;
        FightManager.send_LIFE_DELTA(fightContainer, fightResult);
        this.update(fightContainer);
    }

    public boolean canbeRevive() {
        return this.hasBuffState(528128);
    }

    /**
     * 是否可以使用技能
     * @return
     */
    public boolean canbeSkill() {
        return !isYiwang() && !isHunluan();
    }

    public boolean canbeHurt() {
        return !this.hasBuffState(3856);
    }

    public boolean isHunluan() {
        return this.hasBuffState(3872);
    }

    public boolean isZhongdu() {
        return this.hasBuffState(3842);
    }

    public boolean isYiwang() {
        return this.hasBuffState(3848);
    }

    public boolean isBingdong() {
        return this.hasBuffState(3856);
    }

    public boolean isRun() {
        return this.run;
    }

    public boolean hasBuffState(int buff) {
        Iterator var2 = this.buffState.iterator();

        Integer integer;
        do {
            if (!var2.hasNext()) {
                return false;
            }

            integer = (Integer)var2.next();
        } while(integer != buff);

        return true;
    }

    public FightObject(Chara chara, String name, Vo_65529_0 vo_65529_0) {
        Random random = new Random();
        String strname = name;
        new Petbeibao();
        String replace = "";
        if (name.length() > 1) {
            String substring = name.substring(1, 2);
            replace = name.replace(substring, "");
        }

        int suit_iconlinshi = 0;
        int suit_light_effectlinshi = 0;
        int icon = 0;
        if ((replace.equals("天星") || replace.equals("地星")) && name.equals(vo_65529_0.name)) {
            suit_iconlinshi = vo_65529_0.suit_icon;
            suit_light_effectlinshi = vo_65529_0.suit_light_effect;
            icon = vo_65529_0.icon;
            if (vo_65529_0.leixing == 1) {
                strname = "金星";
            }

            if (vo_65529_0.leixing == 2) {
                strname = "木星";
            }

            if (vo_65529_0.leixing == 3) {
                strname = "水星";
            }

            if (vo_65529_0.leixing == 4) {
                strname = "火星";
            }

            if (vo_65529_0.leixing == 5) {
                strname = "土星";
            }
        }

        if (name.equals("星")) {
            int leixing = random.nextInt(5) + 1;
            if (leixing == 1) {
                strname = "金星";
            }

            if (leixing == 2) {
                strname = "木星";
            }

            if (leixing == 3) {
                strname = "水星";
            }

            if (leixing == 4) {
                strname = "火星";
            }

            if (leixing == 5) {
                strname = "土星";
            }

            int sex = random.nextInt(1) + 1;
            icon = GameShuaGuai.waiguan(leixing, sex);
            int[] suit = SuitEffectUtils.suit(sex - 1, vo_65529_0.level, leixing, random.nextInt(5) + 1);
            vo_65529_0.org_icon = vo_65529_0.icon;
            suit_iconlinshi = suit[0];
            suit_light_effectlinshi = suit[1];
            name = vo_65529_0.name;
        }

        Petbeibao petbeibao = this.petCreate(strname, vo_65529_0.level);
        List<SkillMonster> monsters = GameData.that.baseSkillMonsterService.findByName(strname);
        String skills = "";
        int i;
        if (monsters != null && monsters.size() > 0) {
            for(i = 0; i < monsters.size(); ++i) {
                if (((SkillMonster)monsters.get(i)).getType() == 1) {
                    skills = ((SkillMonster)monsters.get(i)).getSkills();
                }
            }
        }

        i = 0;
        List<ZhuangbeiInfo> infoList = GameData.that.baseZhuangbeiInfoService.findByAttrib(vo_65529_0.level / 10 * 10);
        Iterator var15 = infoList.iterator();

        while(var15.hasNext()) {
            ZhuangbeiInfo zhuangbeiInfo = (ZhuangbeiInfo)var15.next();
            if (zhuangbeiInfo.getAmount() == 1 && zhuangbeiInfo.getMetal() == ((PetShuXing)petbeibao.petShuXing.get(0)).metal) {
                i = zhuangbeiInfo.getType();
            }
        }

        this.str = name;
        this.guaiwulevel = vo_65529_0.level;
        this.shengming = (int)((double)((PetShuXing)petbeibao.petShuXing.get(0)).max_life * 0.8D);
        this.mofa = (int)((double)((PetShuXing)petbeibao.petShuXing.get(0)).max_mana * 0.8D);
        this.max_mofa = (int)((double)((PetShuXing)petbeibao.petShuXing.get(0)).dex * 0.8D);
        this.max_shengming = (int)((double)((PetShuXing)petbeibao.petShuXing.get(0)).def * 0.8D);
        this.fashang = (int)((double)((PetShuXing)petbeibao.petShuXing.get(0)).mana * 0.8D);
        this.parry = (int)((double)((PetShuXing)petbeibao.petShuXing.get(0)).parry * 0.8D);
        this.accurate = (int)((double)((PetShuXing)petbeibao.petShuXing.get(0)).accurate * 0.8D);
        this.fangyu = (int)((double)((PetShuXing)petbeibao.petShuXing.get(0)).wiz * 0.8D);
        this.weapon_icon = i;
        this.org_icon = icon;
        this.suit_icon = suit_iconlinshi;
        this.suit_light_effect = suit_light_effectlinshi;
        this.friend = (int)(0.29D * (double)vo_65529_0.level * (double)vo_65529_0.level * (double)vo_65529_0.level * 0.29D * (double)vo_65529_0.level * (double)vo_65529_0.level * (double)vo_65529_0.level);
        boolean isfagong = ((PetShuXing)petbeibao.petShuXing.get(0)).rank > ((PetShuXing)petbeibao.petShuXing.get(0)).pet_mag_shape;
        this.skillsList = dujineng(1, ((PetShuXing)petbeibao.petShuXing.get(0)).metal, ((PetShuXing)petbeibao.petShuXing.get(0)).skill, isfagong, 123456, skills);
        this.type = 4;
    }

    /**
     * 是否是通天塔宠物
     * @return
     */
    public boolean isTTTPet(){
        return null!=tttXingjun;
    }
}
