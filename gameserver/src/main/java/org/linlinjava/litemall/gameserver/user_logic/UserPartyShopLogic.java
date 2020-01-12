package org.linlinjava.litemall.gameserver.user_logic;

import org.linlinjava.litemall.db.dao.UserPartyShopMapper;
import org.linlinjava.litemall.db.domain.UserPartyShop;
import org.linlinjava.litemall.gameserver.game.GameData;

public class UserPartyShopLogic extends BaseLogic {
    public UserPartyShop data;
    @Override
    protected void onInit() {
        super.onInit();
        UserPartyShopMapper mapper = GameData.that.baseUserPartyShopService.mapper;
        data = mapper.selectByPrimaryKey(this.id);
        if(data == null){
            data.setId(this.id);
            mapper.insert(data);
        }

    }

    @Override
    protected void onSave() {
        super.onSave();
    }
}
