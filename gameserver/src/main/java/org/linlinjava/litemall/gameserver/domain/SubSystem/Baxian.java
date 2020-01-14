package org.linlinjava.litemall.gameserver.domain.SubSystem;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Baxian {
    /**
     * 剩余次数
     */
    private int timesLeft;

    /**
     * 当前关卡 从1开始
     */
    private int currentLevel;

    /**
     * 开放光卡最大值，从1开始
     */
    private int currentMaxLevel;

    /**
     * 主任务当前状态， 0：没有主任务    1：子任务进行中  2主任务完成
     */
    private int status;

    /**
     * 剩余重置次数
     */
    private int resetTimeLeft;

    private Integer currentTaskId;
}
