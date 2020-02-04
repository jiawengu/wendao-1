package org.linlinjava.litemall.gameserver.domain;

import java.util.Date;

public class Rank {

    private int id;

    private String uuid; //角色ID

    private String name; //名字

    private int level; //角色等级

    private int petId; //宠物ID

    private int petName; //宠物名称

    private int petLevel; //宠物等级

    private String type; //排行榜类型

    private int sortIdx; //排行

    private int value; //排行值

    private int menpai; //门派

    private int partyName; //帮派名称

    private Date createTime; //创建日期

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getUuid() {
        return uuid;
    }

    public void setUuid(String uuid) {
        this.uuid = uuid;
    }

    public int getLevel() {
        return level;
    }

    public void setLevel(int level) {
        this.level = level;
    }

    public int getPetId() {
        return petId;
    }

    public void setPetId(int petId) {
        this.petId = petId;
    }

    public int getPetLevel() {
        return petLevel;
    }

    public void setPetLevel(int petLevel) {
        this.petLevel = petLevel;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public int getSortIdx() {
        return sortIdx;
    }

    public void setSortIdx(int sortIdx) {
        this.sortIdx = sortIdx;
    }

    public Date getCreateTime() {
        return createTime;
    }

    public void setCreateTime(Date createTime) {
        this.createTime = createTime;
    }

    public int getValue() {
        return value;
    }

    public void setValue(int value) {
        this.value = value;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getPetName() {
        return petName;
    }

    public void setPetName(int petName) {
        this.petName = petName;
    }

    public int getMenpai() {
        return menpai;
    }

    public void setMenpai(int menpai) {
        this.menpai = menpai;
    }

    public int getPartyName() {
        return partyName;
    }

    public void setPartyName(int partyName) {
        this.partyName = partyName;
    }
}
