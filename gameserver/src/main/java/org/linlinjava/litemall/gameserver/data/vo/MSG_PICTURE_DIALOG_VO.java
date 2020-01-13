package org.linlinjava.litemall.gameserver.data.vo;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MSG_PICTURE_DIALOG_VO {
    private int id; // 意义不明，不知道是什么id，按之前的尿性应该是npcId

    private String npcName;

    private int portrait;

    private int picId;

    private String content;
}
