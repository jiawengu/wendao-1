package org.linlinjava.litemall.wx.web;

import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.linlinjava.litemall.gameserver.game.GameObjectCharMng;
import org.linlinjava.litemall.gameserver.service.TitleService;
import org.linlinjava.litemall.wx.request.GrantTitleRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("debug")
@Validated
public class DebugController {
    private final Logger logger = LoggerFactory.getLogger(DebugController.class);

    @PostMapping("/grant-title")
    public Object grantTitle(@RequestBody GrantTitleRequest request) {
        logger.error("grantTitle: " + request.toString());

        GameObjectChar gameObjectChar = GameObjectCharMng.getGameObjectChar(request.getUid());
        TitleService.grantTitle(gameObjectChar, request.getSource(), request.getTitle());
        return true;
    }
}
