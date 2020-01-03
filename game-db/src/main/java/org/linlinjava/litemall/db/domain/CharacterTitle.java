package org.linlinjava.litemall.db.domain;

import java.util.Date;

public class CharacterTitle {
    private Integer id;

    private Integer type;

    private Integer ownerUid;

    private Date addTime;

    private Boolean deleted;

    public CharacterTitle(Integer id, Integer type, Integer ownerUid, Date addTime, Boolean deleted) {
        this.id = id;
        this.type = type;
        this.ownerUid = ownerUid;
        this.addTime = addTime;
        this.deleted = deleted;
    }

    public CharacterTitle() {
        super();
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getType() {
        return type;
    }

    public void setType(Integer type) {
        this.type = type;
    }

    public Integer getOwnerUid() {
        return ownerUid;
    }

    public void setOwnerUid(Integer ownerUid) {
        this.ownerUid = ownerUid;
    }

    public Date getAddTime() {
        return addTime;
    }

    public void setAddTime(Date addTime) {
        this.addTime = addTime;
    }

    public Boolean getDeleted() {
        return deleted;
    }

    public void setDeleted(Boolean deleted) {
        this.deleted = deleted;
    }
}