/*     */ package org.linlinjava.litemall.gameserver.process;
/*     */
/*     */ import io.netty.buffer.ByteBuf;
/*     */ import io.netty.channel.ChannelHandlerContext;
/*     */ import java.util.List;
/*     */ import org.linlinjava.litemall.db.domain.Characters;
/*     */ import org.linlinjava.litemall.db.domain.ZhuangbeiInfo;
/*     */
/*     */
/*     */ import org.linlinjava.litemall.db.util.JSONUtils;
/*     */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.ListVo_61537_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.M8285_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE_PETS;
import org.linlinjava.litemall.gameserver.domain.Chara;
/*     */ import org.linlinjava.litemall.gameserver.domain.Goods;
/*     */ import org.linlinjava.litemall.gameserver.domain.GoodsBasics;
/*     */ import org.linlinjava.litemall.gameserver.domain.GoodsInfo;
/*     */ import org.linlinjava.litemall.gameserver.domain.GoodsLanSe;
/*     */ import org.linlinjava.litemall.gameserver.domain.PetShuXing;
/*     */ import org.linlinjava.litemall.gameserver.domain.Petbeibao;
/*     */
/*     */ import org.linlinjava.litemall.gameserver.game.GameData;
/*     */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * CMD_CREATE_NEW_CHAR
 */
/*     */
/*     */ @org.springframework.stereotype.Service
/*     */ public class CMD_CREATE_NEW_CHAR implements org.linlinjava.litemall.gameserver.GameHandler
        /*     */ {
                private static final Logger log = LoggerFactory.getLogger(CMD_CREATE_NEW_CHAR.class);
    /*     */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
    /*     */   {
        /*  30 */     String char_name = GameReadTool.readString(buff);
        /*     */
        /*  32 */     int gender = GameReadTool.readShort(buff);
        /*     */
        /*  34 */     int polar = GameReadTool.readShort(buff);
        /*     */
        /*  36 */     if (GameData.that.characterService.findOneByName(char_name) != null) {
            /*  37 */       return;
            /*     */     }
        /*     */
        /*     */
        /*  41 */     GameObjectChar session = GameObjectChar.getGameObjectChar();
        /*  42 */     org.linlinjava.litemall.db.domain.Accounts accounts = GameData.that.baseAccountsService.findById(session.accountid);
        /*     */
        /*  44 */     String uuid = java.util.UUID.randomUUID().toString();
        /*  45 */     org.linlinjava.litemall.gameserver.data.vo.Vo_8285_0 vo_8285_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_8285_0();
        /*  46 */     vo_8285_0.name = char_name;
        /*  47 */     vo_8285_0.gid = uuid;
        /*     */
        /*     */
        /*  50 */     Chara chara = new Chara(char_name, gender, polar, uuid);
        /*     */
        /*     */
        /*  53 */     addbackpack(chara);
        /*  54 */     GameUtil.zhuangbeiValue(chara);
        /*     */
        /*     */
        /*  57 */     chara.max_mana = (chara.zbAttribute.dex + chara.dex);
        /*  58 */     chara.max_life = (chara.zbAttribute.def + chara.def);
        /*  59 */     chara.mapid = 1000;
        /*     */
        /*     */
        /*     */
        /*  63 */     Characters characters = new Characters();
        /*  64 */     characters.setName(char_name);
        /*  65 */     characters.setMenpai(Integer.valueOf(chara.menpai));
        /*  66 */     characters.setGid(uuid);
        /*  67 */     characters.setData(JSONUtils.toJSONString(chara));
        /*  68 */     characters.setAccountId(Integer.valueOf(session.accountid));
        /*     */
        /*     */
        /*  71 */     GameData.that.characterService.add(characters);
        /*     */
        /*  73 */     chara.id = characters.getId().intValue();
        /*  74 */     chara.allId = (chara.id * 100000);
        /*     */
        /*     */
        /*  77 */     org.linlinjava.litemall.db.domain.Pet pet = GameData.that.basePetService.findOneByName("仙阳剑");
        /*  78 */     Petbeibao petbeibao = new Petbeibao();
        /*  79 */     petbeibao.PetCreate(pet, chara, 0, 2);
        /*  80 */     List<Petbeibao> list = new java.util.ArrayList();
        /*  81 */     chara.pets.add(petbeibao);
        /*  82 */     list.add(petbeibao);
        /*  83 */     ((PetShuXing)petbeibao.petShuXing.get(0)).enchant_nimbus = 0;
        /*  84 */     ((PetShuXing)petbeibao.petShuXing.get(0)).max_enchant_nimbus = 0;
        /*  85 */     ((PetShuXing)petbeibao.petShuXing.get(0)).suit_light_effect = 1;
        /*  86 */     ((PetShuXing)petbeibao.petShuXing.get(0)).hide_mount = 2;
        /*  87 */     PetShuXing shuXing = new PetShuXing();
        /*  88 */     shuXing.no = 23;
        /*  89 */     shuXing.type1 = 2;
        /*  90 */     shuXing.accurate = 4;
        /*  91 */     shuXing.mana = 4;
        /*  92 */     shuXing.wiz = 3;
        /*  93 */     shuXing.all_polar = 0;
        /*  94 */     shuXing.upgrade_magic = 0;
        /*  95 */     shuXing.upgrade_total = 0;
        /*  96 */     petbeibao.petShuXing.add(shuXing);
        /*  97 */     GameObjectChar.send(new MSG_UPDATE_PETS(), list);
        /*     */
        /*     */
        /*     */
        /*     */
        /*     */
        /* 104 */     characters.setData(JSONUtils.toJSONString(chara));
        /* 105 */     GameData.that.characterService.updateById(characters);
        /* 106 */     session.init(characters);
        /*     */
        /* 108 */     List<Characters> charactersList = GameData.that.characterService.findByAccountId(Integer.valueOf(session.accountid));
        /*     */
        /* 110 */     ListVo_61537_0 listvo_61537_0 = listjiaose(charactersList);
        /*     */
        /*     */
        /* 113 */     ByteBuf write = new M8285_0().write(vo_8285_0);
        /* 114 */     ctx.writeAndFlush(write);
        /*     */
        /* 116 */     ByteBuf write1 = new org.linlinjava.litemall.gameserver.data.write.M61537_0().write(listvo_61537_0);
        /* 117 */     ctx.writeAndFlush(write1);
        /*     */   }
    /*     */
    /*     */
    /*     */
    /*     */   public int cmd()
    /*     */   {
        /* 124 */     return 8284;
        /*     */   }
    /*     */
    /*     */   public void addbackpack(Chara chara) {
        /* 128 */     ZhuangbeiInfo zhuangb = new ZhuangbeiInfo();
        /* 129 */     List<ZhuangbeiInfo> byAttrib = GameData.that.baseZhuangbeiInfoService.findByAttrib(Integer.valueOf(1));
        /* 130 */     for (int i = 0; i < byAttrib.size(); i++) {
            /* 131 */       if ((((ZhuangbeiInfo)byAttrib.get(i)).getMaster().intValue() == chara.sex) && (((ZhuangbeiInfo)byAttrib.get(i)).getAmount().intValue() == 3)) {
                /* 132 */         zhuangb = (ZhuangbeiInfo)byAttrib.get(i);
                /* 133 */         Goods goods = new Goods();
                /* 134 */         goods.pos = 3;
                /* 135 */         goods.goodsInfo = new GoodsInfo();
                /* 136 */         goods.goodsBasics = new GoodsBasics();
                /* 137 */         goods.goodsLanSe = new GoodsLanSe();
                /* 138 */         goods.goodsCreate(zhuangb);
                /* 139 */         chara.backpack.add(goods);
                /*     */       }
            /* 141 */       if ((((ZhuangbeiInfo)byAttrib.get(i)).getMaster().intValue() == chara.sex) && (((ZhuangbeiInfo)byAttrib.get(i)).getAmount().intValue() == 2)) {
                /* 142 */         zhuangb = (ZhuangbeiInfo)byAttrib.get(i);
                /* 143 */         Goods goods = new Goods();
                /* 144 */         goods.pos = 2;
                /* 145 */         goods.goodsInfo = new GoodsInfo();
                /* 146 */         goods.goodsBasics = new GoodsBasics();
                /* 147 */         goods.goodsLanSe = new GoodsLanSe();
                /* 148 */         goods.goodsCreate(zhuangb);
                /* 149 */         chara.backpack.add(goods);
                /*     */       }
            /*     */     }
        /* 152 */     zhuangb = GameData.that.baseZhuangbeiInfoService.findOneByStr("麻鞋");
        /* 153 */     Goods goods = new Goods();
        /* 154 */     goods.pos = 10;
        /* 155 */     goods.goodsInfo = new GoodsInfo();
        /* 156 */     goods.goodsBasics = new GoodsBasics();
        /* 157 */     goods.goodsLanSe = new GoodsLanSe();
        /* 158 */     goods.goodsCreate(zhuangb);
        /* 159 */     chara.backpack.add(goods);
        /*     */   }
    /*     */
    /*     */   public static ListVo_61537_0 listjiaose(List<Characters> charactersList)
    /*     */   {
        /* 164 */     ListVo_61537_0 listvo_61537_0 = new ListVo_61537_0();
        /* 165 */     listvo_61537_0.a = 1;
        /* 166 */     listvo_61537_0.count = charactersList.size();
        /* 167 */     listvo_61537_0.c = 0;
        /* 168 */     listvo_61537_0.d = 0;
        /* 169 */     for (Characters character : charactersList) {
            /* 170 */       org.linlinjava.litemall.gameserver.data.vo.Vo_61537_0 v61537 = new org.linlinjava.litemall.gameserver.data.vo.Vo_61537_0();
            /* 171 */       String arr = character.getData();
            /* 172 */       Chara chara1 = (Chara)JSONUtils.parseObject(character.getData(), Chara.class);
            /* 173 */       v61537.passive_mode = chara1.waiguan;
            /* 174 */       v61537.metal = chara1.menpai;
            /* 175 */       v61537.str = chara1.name;
            /* 176 */       v61537.iid_str = chara1.uuid;
            /* 177 */       v61537.skill = chara1.level;
            /* 178 */       v61537.type = chara1.waiguan;
            /* 179 */       v61537.last_login_time = 1558062000;
            /*     */
            /*     */
            /* 182 */       listvo_61537_0.vo_61537_0.add(v61537);
            /*     */     }
        /* 184 */     return listvo_61537_0;
        /*     */   }
    /*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C8284_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */