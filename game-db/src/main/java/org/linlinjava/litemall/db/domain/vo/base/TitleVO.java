package org.linlinjava.litemall.db.domain.vo.base;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TitleVO {
    private Integer type;

    private String title;

    private Integer color;

    private Integer gender; // 0表示男性专属，1表示女性专属，2表示通用
}
