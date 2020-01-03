package org.linlinjava.litemall.db.domain.vo.base;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CharacterTitleVO implements Cloneable, Serializable {
    private Integer id;

    private Integer type;

    private Integer ownerUid;

    private LocalDateTime addTime;

    private Boolean deleted;
}
