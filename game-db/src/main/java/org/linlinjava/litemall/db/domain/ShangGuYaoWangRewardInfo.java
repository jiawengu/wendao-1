package org.linlinjava.litemall.db.domain;

public class ShangGuYaoWangRewardInfo {
    private Integer id;

    private Integer accountId;

    private Integer charactersId;

    private String reward;

    private String dateTime;

    private String date;

    private Integer yaoWangId;

    public ShangGuYaoWangRewardInfo(Integer id, Integer accountId, Integer charactersId, String reward, String dateTime, String date, Integer yaoWangId) {
        this.id = id;
        this.accountId = accountId;
        this.charactersId = charactersId;
        this.reward = reward;
        this.dateTime = dateTime;
        this.date = date;
        this.yaoWangId = yaoWangId;
    }

    public ShangGuYaoWangRewardInfo() {
        super();
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getAccountId() {
        return accountId;
    }

    public void setAccountId(Integer accountId) {
        this.accountId = accountId;
    }

    public Integer getCharactersId() {
        return charactersId;
    }

    public void setCharactersId(Integer charactersId) {
        this.charactersId = charactersId;
    }

    public String getReward() {
        return reward;
    }

    public void setReward(String reward) {
        this.reward = reward == null ? null : reward.trim();
    }

    public String getDateTime() {
        return dateTime;
    }

    public void setDateTime(String dateTime) {
        this.dateTime = dateTime == null ? null : dateTime.trim();
    }

    public String getDate() {
        return date;
    }

    public void setDate(String date) {
        this.date = date == null ? null : date.trim();
    }

    public Integer getYaoWangId() {
        return yaoWangId;
    }

    public void setYaoWangId(Integer yaoWangId) {
        this.yaoWangId = yaoWangId;
    }
}