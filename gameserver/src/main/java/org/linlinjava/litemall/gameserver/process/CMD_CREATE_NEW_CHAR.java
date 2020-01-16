package org.linlinjava.litemall.gameserver.process;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import org.linlinjava.litemall.db.domain.Characters;
import org.linlinjava.litemall.db.domain.ZhuangbeiInfo;
import org.linlinjava.litemall.db.util.JSONUtils;
import org.linlinjava.litemall.gameserver.data.GameReadTool;
import org.linlinjava.litemall.gameserver.data.vo.ListVo_61537_0;
import org.linlinjava.litemall.gameserver.data.write.M8285_0;
import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE_PETS;
import org.linlinjava.litemall.gameserver.domain.*;
import org.linlinjava.litemall.gameserver.game.GameData;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;

/**
 * CMD_CREATE_NEW_CHAR
 */

@org.springframework.stereotype.Service
public class CMD_CREATE_NEW_CHAR implements org.linlinjava.litemall.gameserver.GameHandler {
    private static final Logger log = LoggerFactory.getLogger(CMD_CREATE_NEW_CHAR.class);

    public void process(ChannelHandlerContext ctx, ByteBuf buff) {
        String char_name = GameReadTool.readString(buff);

        int gender = GameReadTool.readShort(buff);

        int polar = GameReadTool.readShort(buff);

        if (GameData.that.characterService.findOneByName(char_name) != null) {
            return;
        }

        String uuid = java.util.UUID.randomUUID().toString();
        Chara chara = new Chara(char_name, gender, polar, uuid);
        addbackpack(chara);
        GameUtil.zhuangbeiValue(chara);
        chara.max_mana = (chara.zbAttribute.dex + chara.dex);
        chara.max_life = (chara.zbAttribute.def + chara.def);
        chara.mapid = 1000;

        GameObjectChar session = GameObjectChar.getGameObjectChar();
        Characters characters = new Characters();
        characters.setName(char_name);
        characters.setMenpai(Integer.valueOf(chara.menpai));
        characters.setGid(uuid);
        characters.setData(JSONUtils.toJSONString(chara));
        characters.setAccountId(Integer.valueOf(session.accountid));

        GameData.that.characterService.add(characters);

        chara.id = characters.getId().intValue();
        chara.allId = (chara.id * 100000);


        org.linlinjava.litemall.db.domain.Pet pet = GameData.that.basePetService.findOneByName("仙阳剑");
        Petbeibao petbeibao = new Petbeibao();
        petbeibao.PetCreate(pet, chara, 0, 2);
        List<Petbeibao> list = new java.util.ArrayList();
        chara.pets.add(petbeibao);
        list.add(petbeibao);
        ((PetShuXing) petbeibao.petShuXing.get(0)).enchant_nimbus = 0;
        ((PetShuXing) petbeibao.petShuXing.get(0)).max_enchant_nimbus = 0;
        ((PetShuXing) petbeibao.petShuXing.get(0)).suit_light_effect = 1;
        ((PetShuXing) petbeibao.petShuXing.get(0)).hide_mount = 2;
        PetShuXing shuXing = new PetShuXing();
        shuXing.no = 23;
        shuXing.type1 = 2;
        shuXing.accurate = 4;
        shuXing.mana = 4;
        shuXing.wiz = 3;
        shuXing.all_polar = 0;
        shuXing.upgrade_magic = 0;
        shuXing.upgrade_total = 0;
        petbeibao.petShuXing.add(shuXing);
        GameObjectChar.send(new MSG_UPDATE_PETS(), list);


        characters.setData(JSONUtils.toJSONString(chara));
        GameData.that.characterService.updateById(characters);
        session.init(characters);

        org.linlinjava.litemall.gameserver.data.vo.Vo_8285_0 vo_8285_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_8285_0();
        vo_8285_0.name = char_name;
        vo_8285_0.gid = uuid;
        ByteBuf write = new M8285_0().write(vo_8285_0);
        ctx.writeAndFlush(write);

        List<Characters> charactersList = GameData.that.characterService.findByAccountId(Integer.valueOf(session.accountid));
        ListVo_61537_0 listvo_61537_0 = listjiaose(charactersList);
        ByteBuf write1 = new org.linlinjava.litemall.gameserver.data.write.M61537_0().write(listvo_61537_0);
        ctx.writeAndFlush(write1);
    }


    public int cmd() {
        return 8284;
    }

    public void addbackpack(Chara chara) {
        ZhuangbeiInfo zhuangb = new ZhuangbeiInfo();
        List<ZhuangbeiInfo> byAttrib = GameData.that.baseZhuangbeiInfoService.findByAttrib(Integer.valueOf(1));
        for (int i = 0; i < byAttrib.size(); i++) {
            if ((((ZhuangbeiInfo) byAttrib.get(i)).getMaster().intValue() == chara.sex) && (((ZhuangbeiInfo) byAttrib.get(i)).getAmount().intValue() == 3)) {
                zhuangb = (ZhuangbeiInfo) byAttrib.get(i);
                Goods goods = new Goods();
                goods.pos = 3;
                goods.goodsInfo = new GoodsInfo();
                goods.goodsBasics = new GoodsBasics();
                goods.goodsLanSe = new GoodsLanSe();
                goods.goodsCreate(zhuangb);
                chara.backpack.add(goods);
            }
            if ((((ZhuangbeiInfo) byAttrib.get(i)).getMaster().intValue() == chara.sex) && (((ZhuangbeiInfo) byAttrib.get(i)).getAmount().intValue() == 2)) {
                zhuangb = (ZhuangbeiInfo) byAttrib.get(i);
                Goods goods = new Goods();
                goods.pos = 2;
                goods.goodsInfo = new GoodsInfo();
                goods.goodsBasics = new GoodsBasics();
                goods.goodsLanSe = new GoodsLanSe();
                goods.goodsCreate(zhuangb);
                chara.backpack.add(goods);
            }
        }
        zhuangb = GameData.that.baseZhuangbeiInfoService.findOneByStr("麻鞋");
        Goods goods = new Goods();
        goods.pos = 10;
        goods.goodsInfo = new GoodsInfo();
        goods.goodsBasics = new GoodsBasics();
        goods.goodsLanSe = new GoodsLanSe();
        goods.goodsCreate(zhuangb);
        chara.backpack.add(goods);
    }

    public static ListVo_61537_0 listjiaose(List<Characters> charactersList) {
        ListVo_61537_0 listvo_61537_0 = new ListVo_61537_0();
        listvo_61537_0.a = 1;
        listvo_61537_0.count = charactersList.size();
        listvo_61537_0.c = 0;
        listvo_61537_0.d = 0;
        for (Characters character : charactersList) {
            org.linlinjava.litemall.gameserver.data.vo.Vo_61537_0 v61537 = new org.linlinjava.litemall.gameserver.data.vo.Vo_61537_0();
            String arr = character.getData();
            Chara chara1 = (Chara) JSONUtils.parseObject(character.getData(), Chara.class);
            v61537.passive_mode = chara1.waiguan;
            v61537.metal = chara1.menpai;
            v61537.str = chara1.name;
            v61537.iid_str = chara1.uuid;
            v61537.skill = chara1.level;
            v61537.type = chara1.waiguan;
            v61537.last_login_time = 1558062000;


            listvo_61537_0.vo_61537_0.add(v61537);
        }
        return listvo_61537_0;
    }
}
