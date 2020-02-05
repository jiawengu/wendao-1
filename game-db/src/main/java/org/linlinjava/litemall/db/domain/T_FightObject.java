package org.linlinjava.litemall.db.domain;

import java.util.Date;

public class T_FightObject {
    /**
     *
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column t_fight_object.id
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    private Integer id;

    /**
     *
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column t_fight_object.type
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    private Integer type;

    /**
     *
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column t_fight_object.name
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    private String name;

    /**
     *
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column t_fight_object.life
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    private Integer life;

    /**
     *
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column t_fight_object.mana
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    private Integer mana;

    /**
     *
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column t_fight_object.phy_attack
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    private Integer phyAttack;

    /**
     *
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column t_fight_object.mag_attack
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    private Integer magAttack;

    /**
     *
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column t_fight_object.polar
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    private String polar;

    /**
     *
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column t_fight_object.speed
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    private Integer speed;

    /**
     *
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column t_fight_object.def
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    private Integer def;

    /**
     *
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column t_fight_object.icon
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    private Integer icon;

    /**
     *
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column t_fight_object.daohang
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    private Integer daohang;

    /**
     *
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column t_fight_object.pet_martial
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    private Integer petMartial;

    /**
     *
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column t_fight_object.skill
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    private String skill;

    /**
     *
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column t_fight_object.pet_tianshu
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    private String petTianshu;

    /**
     *
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column t_fight_object.add_time
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    private Date addTime;

    /**
     *
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column t_fight_object.update_time
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    private Date updateTime;

    /**
     *
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column t_fight_object.deleted
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    private Boolean deleted;

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table t_fight_object
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
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

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table t_fight_object
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    public T_FightObject() {
        super();
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column t_fight_object.id
     *
     * @return the value of t_fight_object.id
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    public Integer getId() {
        return id;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column t_fight_object.id
     *
     * @param id the value for t_fight_object.id
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    public void setId(Integer id) {
        this.id = id;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column t_fight_object.type
     *
     * @return the value of t_fight_object.type
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    public Integer getType() {
        return type;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column t_fight_object.type
     *
     * @param type the value for t_fight_object.type
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    public void setType(Integer type) {
        this.type = type;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column t_fight_object.name
     *
     * @return the value of t_fight_object.name
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    public String getName() {
        return name;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column t_fight_object.name
     *
     * @param name the value for t_fight_object.name
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    public void setName(String name) {
        this.name = name == null ? null : name.trim();
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column t_fight_object.life
     *
     * @return the value of t_fight_object.life
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    public Integer getLife() {
        return life;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column t_fight_object.life
     *
     * @param life the value for t_fight_object.life
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    public void setLife(Integer life) {
        this.life = life;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column t_fight_object.mana
     *
     * @return the value of t_fight_object.mana
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    public Integer getMana() {
        return mana;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column t_fight_object.mana
     *
     * @param mana the value for t_fight_object.mana
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    public void setMana(Integer mana) {
        this.mana = mana;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column t_fight_object.phy_attack
     *
     * @return the value of t_fight_object.phy_attack
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    public Integer getPhyAttack() {
        return phyAttack;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column t_fight_object.phy_attack
     *
     * @param phyAttack the value for t_fight_object.phy_attack
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    public void setPhyAttack(Integer phyAttack) {
        this.phyAttack = phyAttack;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column t_fight_object.mag_attack
     *
     * @return the value of t_fight_object.mag_attack
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    public Integer getMagAttack() {
        return magAttack;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column t_fight_object.mag_attack
     *
     * @param magAttack the value for t_fight_object.mag_attack
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    public void setMagAttack(Integer magAttack) {
        this.magAttack = magAttack;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column t_fight_object.polar
     *
     * @return the value of t_fight_object.polar
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    public String getPolar() {
        return polar;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column t_fight_object.polar
     *
     * @param polar the value for t_fight_object.polar
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    public void setPolar(String polar) {
        this.polar = polar == null ? null : polar.trim();
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column t_fight_object.speed
     *
     * @return the value of t_fight_object.speed
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    public Integer getSpeed() {
        return speed;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column t_fight_object.speed
     *
     * @param speed the value for t_fight_object.speed
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    public void setSpeed(Integer speed) {
        this.speed = speed;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column t_fight_object.def
     *
     * @return the value of t_fight_object.def
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    public Integer getDef() {
        return def;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column t_fight_object.def
     *
     * @param def the value for t_fight_object.def
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    public void setDef(Integer def) {
        this.def = def;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column t_fight_object.icon
     *
     * @return the value of t_fight_object.icon
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    public Integer getIcon() {
        return icon;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column t_fight_object.icon
     *
     * @param icon the value for t_fight_object.icon
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    public void setIcon(Integer icon) {
        this.icon = icon;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column t_fight_object.daohang
     *
     * @return the value of t_fight_object.daohang
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    public Integer getDaohang() {
        return daohang;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column t_fight_object.daohang
     *
     * @param daohang the value for t_fight_object.daohang
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    public void setDaohang(Integer daohang) {
        this.daohang = daohang;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column t_fight_object.pet_martial
     *
     * @return the value of t_fight_object.pet_martial
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    public Integer getPetMartial() {
        return petMartial;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column t_fight_object.pet_martial
     *
     * @param petMartial the value for t_fight_object.pet_martial
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    public void setPetMartial(Integer petMartial) {
        this.petMartial = petMartial;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column t_fight_object.skill
     *
     * @return the value of t_fight_object.skill
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    public String getSkill() {
        return skill;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column t_fight_object.skill
     *
     * @param skill the value for t_fight_object.skill
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    public void setSkill(String skill) {
        this.skill = skill == null ? null : skill.trim();
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column t_fight_object.pet_tianshu
     *
     * @return the value of t_fight_object.pet_tianshu
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    public String getPetTianshu() {
        return petTianshu;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column t_fight_object.pet_tianshu
     *
     * @param petTianshu the value for t_fight_object.pet_tianshu
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    public void setPetTianshu(String petTianshu) {
        this.petTianshu = petTianshu == null ? null : petTianshu.trim();
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column t_fight_object.add_time
     *
     * @return the value of t_fight_object.add_time
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    public Date getAddTime() {
        return addTime;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column t_fight_object.add_time
     *
     * @param addTime the value for t_fight_object.add_time
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    public void setAddTime(Date addTime) {
        this.addTime = addTime;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column t_fight_object.update_time
     *
     * @return the value of t_fight_object.update_time
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    public Date getUpdateTime() {
        return updateTime;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column t_fight_object.update_time
     *
     * @param updateTime the value for t_fight_object.update_time
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    public void setUpdateTime(Date updateTime) {
        this.updateTime = updateTime;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column t_fight_object.deleted
     *
     * @return the value of t_fight_object.deleted
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    public Boolean getDeleted() {
        return deleted;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column t_fight_object.deleted
     *
     * @param deleted the value for t_fight_object.deleted
     *
     * @mbg.generated Tue Jan 21 16:59:54 CST 2020
     */
    public void setDeleted(Boolean deleted) {
        this.deleted = deleted;
    }
}