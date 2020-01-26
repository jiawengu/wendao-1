package org.linlinjava.litemall.gameserver.domain;

import java.util.LinkedList;
import java.util.List;
import java.util.Random;

import org.linlinjava.litemall.db.domain.Pet;
import org.linlinjava.litemall.gameserver.data.game.BasicAttributesUtils;
import org.linlinjava.litemall.gameserver.data.vo.Vo_12023_0;
import org.linlinjava.litemall.gameserver.process.GameUtil;


public class Petbeibao {
    public int no;
    public int id;
    public List<PetShuXing> petShuXing = new LinkedList();
    public List<Vo_12023_0> tianshu = new LinkedList();
    public int autofight_select = 0;
    public int autofight_skillaction = 2;
    public int autofight_skillno = 2;

    public void PetCreate(Pet pet, Chara chara, int suiji, int penetrate) {
        PetShuXing shuXing = new PetShuXing();
        shuXing.icon = pet.getIcon().intValue();
        shuXing.portrait = pet.getIcon().intValue();
        shuXing.req_level = pet.getLevelReq().intValue();
        shuXing.name = pet.getName();
        shuXing.level = 1;
        this.id = GameUtil.getCard(chara);
        this.no = GameUtil.getNo(chara, 1);
        shuXing.exp = 0;
        shuXing.exp_to_next_level = 258;
        shuXing.longevity = 15000;
        shuXing.loyalty = 100;
        shuXing.raw_name = pet.getName();
        shuXing.iid_str += this.id;
        if (pet.getPolar().equals("金")) {
            shuXing.polar = 1;
        }
        if (pet.getPolar().equals("木")) {
            shuXing.polar = 2;
        }
        if (pet.getPolar().equals("水")) {
            shuXing.polar = 3;
        }
        if (pet.getPolar().equals("火")) {
            shuXing.polar = 4;
        }
        if (pet.getPolar().equals("土")) {
            shuXing.polar = 5;
        }
        shuXing.life_effect = (pet.getLife().intValue() - 40 - subtraction(suiji));
        shuXing.mana_effect = (pet.getMana().intValue() - 40 - subtraction(suiji));
        shuXing.phy_effect = (pet.getPhyAttack().intValue() - 40 - subtraction(suiji));
        shuXing.mag_effect = (pet.getMagAttack().intValue() - 40 - subtraction(suiji));
        shuXing.speed_effect = (pet.getSpeed().intValue() - 40 - subtraction(suiji));
        shuXing.pet_life_shape = (shuXing.life_effect + 40);
        shuXing.pet_mana_shape = (shuXing.mana_effect + 40);
        shuXing.pet_speed_shape = (shuXing.speed_effect + 40);
        shuXing.pet_phy_shape = (shuXing.phy_effect + 40);
        shuXing.pet_mag_shape = (shuXing.mag_effect + 40);
        shuXing.shape = (shuXing.pet_life_shape + shuXing.pet_mana_shape + shuXing.pet_speed_shape + shuXing.pet_phy_shape + shuXing.pet_mag_shape);


        shuXing.penetrate = penetrate;
        shuXing.rank = 4;

        shuXing.enchant = 0;
        shuXing.enchant_nimbus = 0;
        shuXing.mount_type = 0;
        shuXing.capacity_level = 0;
        shuXing.str = 1;
        shuXing.wiz = 1;
        shuXing.con = 1;
        shuXing.dex = 1;

        BasicAttributesUtils.petshuxing(shuXing);
        shuXing.life = shuXing.max_life;
        shuXing.mana = shuXing.max_mana;
        this.petShuXing.add(shuXing);
    }


    public void petCreate(Pet pet, Chara chara, int suiji) {
        PetShuXing shuXing = new PetShuXing();
        shuXing.icon = pet.getIcon().intValue();
        shuXing.portrait = pet.getIcon().intValue();
        shuXing.req_level = pet.getLevelReq().intValue();
        shuXing.name = pet.getName();
        shuXing.level = 1;
        this.id = GameUtil.getCard(chara);
        this.no = GameUtil.getNo(chara, 1);
        shuXing.exp = 0;
        shuXing.exp_to_next_level = 258;
        shuXing.longevity = 15000;
        shuXing.loyalty = 100;
        shuXing.raw_name = pet.getName();
        shuXing.iid_str += this.id;
        if (pet.getPolar().equals("金")) {
            shuXing.polar = 1;
        }
        if (pet.getPolar().equals("木")) {
            shuXing.polar = 2;
        }
        if (pet.getPolar().equals("水")) {
            shuXing.polar = 3;
        }
        if (pet.getPolar().equals("火")) {
            shuXing.polar = 4;
        }
        if (pet.getPolar().equals("土")) {
            shuXing.polar = 5;
        }


        shuXing.life_effect = (pet.getLife().intValue() - 40 - subtraction(suiji));
        shuXing.mana_effect = (pet.getMana().intValue() - 40 - subtraction(suiji));
        shuXing.phy_effect = (pet.getPhyAttack().intValue() - 40 - subtraction(suiji));
        shuXing.mag_effect = (pet.getMagAttack().intValue() - 40 - subtraction(suiji));
        shuXing.speed_effect = (pet.getSpeed().intValue() - 40 - subtraction(suiji));
        shuXing.pet_life_shape = (shuXing.life_effect + 40);
        shuXing.pet_mana_shape = (shuXing.mana_effect + 40);
        shuXing.pet_speed_shape = (shuXing.speed_effect + 40);
        shuXing.pet_phy_shape = (shuXing.phy_effect + 40);
        shuXing.pet_mag_shape = (shuXing.mag_effect + 40);
        shuXing.shape = (shuXing.pet_life_shape + shuXing.pet_mana_shape + shuXing.pet_speed_shape + shuXing.pet_phy_shape + shuXing.pet_mag_shape);
        this.petShuXing.add(shuXing);
    }

    public int subtraction(int i) {
        Random r = new Random();
        if (i == 0) {
            return 0;
        }
        return r.nextInt(i);
    }


}