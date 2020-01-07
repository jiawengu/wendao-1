package org.linlinjava.litemall.db.domain;

import java.util.Date;

public class TTTPet {
    private Integer id;

    private Integer levelReq;

    private Integer life;

    private Integer mana;

    private Integer speed;

    private Integer phyAttack;

    private Integer magAttack;

    private String polar;

    private Integer icon;

    private Date addTime;

    private Date updateTime;

    private Boolean deleted;

    private String name;

    public TTTPet(Integer id, Integer levelReq, Integer life, Integer mana, Integer speed, Integer phyAttack, Integer magAttack, String polar, Integer icon, Date addTime, Date updateTime, Boolean deleted, String name) {
        this.id = id;
        this.levelReq = levelReq;
        this.life = life;
        this.mana = mana;
        this.speed = speed;
        this.phyAttack = phyAttack;
        this.magAttack = magAttack;
        this.polar = polar;
        this.icon = icon;
        this.addTime = addTime;
        this.updateTime = updateTime;
        this.deleted = deleted;
        this.name = name;
    }

    public TTTPet() {
        super();
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getLevelReq() {
        return levelReq;
    }

    public void setLevelReq(Integer levelReq) {
        this.levelReq = levelReq;
    }

    public Integer getLife() {
        return life;
    }

    public void setLife(Integer life) {
        this.life = life;
    }

    public Integer getMana() {
        return mana;
    }

    public void setMana(Integer mana) {
        this.mana = mana;
    }

    public Integer getSpeed() {
        return speed;
    }

    public void setSpeed(Integer speed) {
        this.speed = speed;
    }

    public Integer getPhyAttack() {
        return phyAttack;
    }

    public void setPhyAttack(Integer phyAttack) {
        this.phyAttack = phyAttack;
    }

    public Integer getMagAttack() {
        return magAttack;
    }

    public void setMagAttack(Integer magAttack) {
        this.magAttack = magAttack;
    }

    public String getPolar() {
        return polar;
    }

    public void setPolar(String polar) {
        this.polar = polar == null ? null : polar.trim();
    }

    public Integer getIcon() {
        return icon;
    }

    public void setIcon(Integer icon) {
        this.icon = icon;
    }

    public Date getAddTime() {
        return addTime;
    }

    public void setAddTime(Date addTime) {
        this.addTime = addTime;
    }

    public Date getUpdateTime() {
        return updateTime;
    }

    public void setUpdateTime(Date updateTime) {
        this.updateTime = updateTime;
    }

    public Boolean getDeleted() {
        return deleted;
    }

    public void setDeleted(Boolean deleted) {
        this.deleted = deleted;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name == null ? null : name.trim();
    }
}