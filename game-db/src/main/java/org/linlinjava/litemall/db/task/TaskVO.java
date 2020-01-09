package org.linlinjava.litemall.db.task;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TaskVO {
    private Integer taskId;

    private String taskName;

    private String taskPrompt;

    private Integer npcId;

    private String npcName;

    private Integer mapId;

    private String mapName;

    private Integer npcX;

    private Integer npcY;
}
