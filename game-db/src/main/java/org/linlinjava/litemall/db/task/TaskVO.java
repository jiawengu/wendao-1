package org.linlinjava.litemall.db.task;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TaskVO {
    private Integer chainId;

    private Integer taskId;

    private Integer npcId;

    private String npcName;

    private Integer mapId;

    private String mapName;

    private Integer npcX;

    private Integer npcY;

    private List<String> monsterList;
}
