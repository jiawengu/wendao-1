package org.linlinjava.litemall.gameserver.domain;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CharacterTitleDTO {
    private int type;

    private String title;

    private String color;

    private Integer gender;

    private LocalDateTime addTime;

    private boolean isOwned;
}
