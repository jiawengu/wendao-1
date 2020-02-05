package org.linlinjava.litemall.gameserver.process;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import org.linlinjava.litemall.gameserver.GameHandler;
import org.linlinjava.litemall.gameserver.data.GameReadTool;
import org.linlinjava.litemall.gameserver.data.vo.Vo_MSG_PET_UPGRADE_SUCC;
import org.linlinjava.litemall.gameserver.data.write.M_MSG_PET_UPGRADE_SUCC;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.domain.Goods;
import org.linlinjava.litemall.gameserver.domain.Petbeibao;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.linlinjava.litemall.gameserver.game.GameObjectCharMng;
import org.linlinjava.litemall.gameserver.game.GamePetFeiSheng;

import java.util.ArrayList;
import java.util.List;

@org.springframework.stereotype.Service
public class CMD_SUBMIT_PET_UPGRADE_ITEM implements GameHandler {

    @Override
    public void process(ChannelHandlerContext paramChannelHandlerContext, ByteBuf paramByteBuf) {
        String data = GameReadTool.readString(paramByteBuf);
        System.out.println(String.format("CMD_SUBMIT_PET_UPGRADE_ITEM: %s", data));

        String [] posStr =  data.split(",");
        Chara chara = GameObjectChar.getGameObjectChar().chara;

        List<Goods> goodsList = new ArrayList<>();
        for (int i = 0 ;i<  posStr.length; i++){
            for (Goods goods: chara.cangku){
                if (goods.pos == Integer.valueOf(posStr[i])){
                    goodsList.add(goods);
                }
            }
        }

        if (!GamePetFeiSheng.checkEnough(chara, goodsList)) return;
        String []  items = GamePetFeiSheng.itemStr.split(",");
        for (int i = 0 ;i < items.length; i++){
            String [] tempItem = items[i].split("#");
            for (Goods goods: goodsList){
                if (items[i].contains(goods.goodsInfo.str) ){
                    GameUtil.removemunber(chara, goods, Integer.valueOf(tempItem[1]));
                }
            }
        }

        Petbeibao pet = chara.getPetByID(chara.flyPetID);
        Vo_MSG_PET_UPGRADE_SUCC vo = new Vo_MSG_PET_UPGRADE_SUCC();
        vo.id = pet.id;
        vo.pet_life_shape[0] = pet.petShuXing.get(0).life          ;
        vo.pet_mana_shape[0] = pet.petShuXing.get(0).mana          ;
        vo.pet_speed_shape[0] = pet.petShuXing.get(0).speed         ;
        vo.pet_mag_shape[0] = pet.petShuXing.get(0).pet_mag_shape ;
        vo.pet_phy_shape[0] = pet.petShuXing.get(0).pet_phy_shape ;

        int[] result = GamePetFeiSheng.calcShuXing(pet);
        pet.petShuXing.get(0).life          = result[0];
        pet.petShuXing.get(0).mana          = result[1];
        pet.petShuXing.get(0).speed         = result[2];
        pet.petShuXing.get(0).pet_mag_shape = result[3];
        pet.petShuXing.get(0).pet_phy_shape = result[4];
        vo.pet_life_shape[1] = pet.petShuXing.get(0).life          ;
        vo.pet_mana_shape[1] = pet.petShuXing.get(0).mana          ;
        vo.pet_speed_shape[1] = pet.petShuXing.get(0).speed         ;
        vo.pet_mag_shape[1] = pet.petShuXing.get(0).pet_mag_shape ;
        vo.pet_phy_shape[1] = pet.petShuXing.get(0).pet_phy_shape ;

        GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new M_MSG_PET_UPGRADE_SUCC(), vo);
    }



    @Override
    public int cmd() {
        return 0xB0FB;
    }
}
