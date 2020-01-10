package org.linlinjava.litemall.gameserver.service;

import org.linlinjava.litemall.db.dao.UserPartyShopMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class BaseUserPartyShopService {
    @Autowired
    public UserPartyShopMapper mapper;
}
