package org.linlinjava.litemall.db.domain;

import java.util.Date;

public class T_FightObject {
    private Integer id;

    private Integer type;

    private String name;

    private Integer life;

    private Integer mana;

    private Integer phyAttack;

    private Integer magAttack;

    private String polar;

    private Integer speed;

    private Integer def;

    private Integer icon;

    private Integer daohang;

    private Integer petMartial;

    private String skill;

    private String petTianshu;

    private Date addTime;

    private Date updateTime;

    private Boolean deleted;

    public T_FightObject(Integer id, Integer type, String name, Integer life, Integer mana, Integer phyAttack, Integer magAttack, String polar, Integer speed, Integer def, Integer icon, Integer daohang, Integer petMartial, String skill, String petTianshu, Date addTime, Date updateTime, Boolean deleted) {
        this.id = id;
        this.type = type;
        this.name = name;
        this.life = life;
        this.mana = mana;
        this.phyAttack = phyAttack;
        this.magAttack = magAttack;
        this.polar = polar;
        this.speed = speed;
        this.def = def;
        this.icon = icon;
        this.daohang = daohang;
        this.petMartial = petMartial;
        this.skill = skill;
        this.petTianshu = petTianshu;
        this.addTime = addTime;
        this.updateTime = updateTime;
        this.deleted = deleted;
    }

    public T_FightObject() {
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

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name == null ? null : name.trim();
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

    public Integer getSpeed() {
        return speed;
    }

    public void setSpeed(Integer speed) {
        this.speed = speed;
    }

    public Integer getDef() {
        return def;
    }

    public void setDef(Integer def) {
        this.def = def;
    }

    public Integer getIcon() {
        return icon;
    }

    public void setIcon(Integer icon) {
        this.icon = icon;
    }

    public Integer getDaohang() {
        return daohang;
    }

    public void setDaohang(Integer daohang) {
        this.daohang = daohang;
    }

    public Integer getPetMartial() {
        return petMartial;
    }

    public void setPetMartial(Integer petMartial) {
        this.petMartial = petMartial;
    }

    public String getSkill() {
        return skill;
    }

    public void setSkill(String skill) {
        this.skill = skill == null ? null : skill.trim();
    }

    public String getPetTianshu() {
        return petTianshu;
    }

    public void setPetTianshu(String petTianshu) {
        this.petTianshu = petTianshu == null ? null : petTianshu.trim();
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
}