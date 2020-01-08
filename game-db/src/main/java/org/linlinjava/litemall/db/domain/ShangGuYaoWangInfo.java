package org.linlinjava.litemall.db.domain;

public class ShangGuYaoWangInfo {
    private Integer id;

    private Integer npcid;

    private Integer level;

    private Boolean state;

    private String reward;

    private Integer waChuAccountId;

    private String waChuReward;

    private String xiaoGuai;

    public ShangGuYaoWangInfo(Integer id, Integer npcid, Integer level, Boolean state, String reward, Integer waChuAccountId, String waChuReward, String xiaoGuai) {
        this.id = id;
        this.npcid = npcid;
        this.level = level;
        this.state = state;
        this.reward = reward;
        this.waChuAccountId = waChuAccountId;
        this.waChuReward = waChuReward;
        this.xiaoGuai = xiaoGuai;
    }

    public ShangGuYaoWangInfo() {
        super();
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getNpcid() {
        return npcid;
    }

    public void setNpcid(Integer npcid) {
        this.npcid = npcid;
    }

    public Integer getLevel() {
        return level;
    }

    public void setLevel(Integer level) {
        this.level = level;
    }

    public Boolean getState() {
        return state;
    }

    public void setState(Boolean state) {
        this.state = state;
    }

    public String getReward() {
        return reward;
    }

    public void setReward(String reward) {
        this.reward = reward == null ? null : reward.trim();
    }

    public Integer getWaChuAccountId() {
        return waChuAccountId;
    }

    public void setWaChuAccountId(Integer waChuAccountId) {
        this.waChuAccountId = waChuAccountId;
    }

    public String getWaChuReward() {
        return waChuReward;
    }

    public void setWaChuReward(String waChuReward) {
        this.waChuReward = waChuReward == null ? null : waChuReward.trim();
    }

    public String getXiaoGuai() {
        return xiaoGuai;
    }

    public void setXiaoGuai(String xiaoGuai) {
        this.xiaoGuai = xiaoGuai == null ? null : xiaoGuai.trim();
    }
}