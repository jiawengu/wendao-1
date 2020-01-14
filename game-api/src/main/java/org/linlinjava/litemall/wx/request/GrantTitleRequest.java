package org.linlinjava.litemall.wx.request;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class GrantTitleRequest {
    private int uid;

    private String source;

    private String title;

    public int getUid() {
        return uid;
    }

    public String getSource() {
        return source;
    }

    public String getTitle() {
        return title;
    }
}
