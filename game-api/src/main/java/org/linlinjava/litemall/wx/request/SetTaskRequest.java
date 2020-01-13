package org.linlinjava.litemall.wx.request;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SetTaskRequest {
    private Integer uid;

    private Integer chainId;

    private Integer taskId;
}
