package org.linlinjava.litemall.gameserver.data.vo;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BAXIAN_MENGJING_INFO_VO {
    private int times_left;

    private int curCheckpoint;

    private int openMax;

    private int mainState;

    private int isOpenDlg;
}
