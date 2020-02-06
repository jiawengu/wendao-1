package org.linlinjava.litemall.db.domain;

public class LaoFang {
    /**
     *
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column lao_fang.id
     *
     * @mbg.generated Wed Feb 05 22:20:54 CST 2020
     */
    private Integer id;

    /**
     *
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column lao_fang.chara_id
     *
     * @mbg.generated Wed Feb 05 22:20:54 CST 2020
     */
    private Integer charaId;

    /**
     *
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column lao_fang.itime
     *
     * @mbg.generated Wed Feb 05 22:20:54 CST 2020
     */
    private Integer itime;

    /**
     *
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column lao_fang.add_time
     *
     * @mbg.generated Wed Feb 05 22:20:54 CST 2020
     */
    private String addTime;

    /**
     *
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column lao_fang.pk_record_id
     *
     * @mbg.generated Wed Feb 05 22:20:54 CST 2020
     */
    private Integer pkRecordId;

    /**
     *
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column lao_fang.deleted
     *
     * @mbg.generated Wed Feb 05 22:20:54 CST 2020
     */
    private Boolean deleted;

    /**
     *
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column lao_fang.update_time
     *
     * @mbg.generated Wed Feb 05 22:20:54 CST 2020
     */
    private String updateTime;

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table lao_fang
     *
     * @mbg.generated Wed Feb 05 22:20:54 CST 2020
     */
    public LaoFang(Integer id, Integer charaId, Integer itime, String addTime, Integer pkRecordId, Boolean deleted, String updateTime) {
        this.id = id;
        this.charaId = charaId;
        this.itime = itime;
        this.addTime = addTime;
        this.pkRecordId = pkRecordId;
        this.deleted = deleted;
        this.updateTime = updateTime;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table lao_fang
     *
     * @mbg.generated Wed Feb 05 22:20:54 CST 2020
     */
    public LaoFang() {
        super();
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column lao_fang.id
     *
     * @return the value of lao_fang.id
     *
     * @mbg.generated Wed Feb 05 22:20:54 CST 2020
     */
    public Integer getId() {
        return id;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column lao_fang.id
     *
     * @param id the value for lao_fang.id
     *
     * @mbg.generated Wed Feb 05 22:20:54 CST 2020
     */
    public void setId(Integer id) {
        this.id = id;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column lao_fang.chara_id
     *
     * @return the value of lao_fang.chara_id
     *
     * @mbg.generated Wed Feb 05 22:20:54 CST 2020
     */
    public Integer getCharaId() {
        return charaId;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column lao_fang.chara_id
     *
     * @param charaId the value for lao_fang.chara_id
     *
     * @mbg.generated Wed Feb 05 22:20:54 CST 2020
     */
    public void setCharaId(Integer charaId) {
        this.charaId = charaId;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column lao_fang.itime
     *
     * @return the value of lao_fang.itime
     *
     * @mbg.generated Wed Feb 05 22:20:54 CST 2020
     */
    public Integer getItime() {
        return itime;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column lao_fang.itime
     *
     * @param itime the value for lao_fang.itime
     *
     * @mbg.generated Wed Feb 05 22:20:54 CST 2020
     */
    public void setItime(Integer itime) {
        this.itime = itime;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column lao_fang.add_time
     *
     * @return the value of lao_fang.add_time
     *
     * @mbg.generated Wed Feb 05 22:20:54 CST 2020
     */
    public String getAddTime() {
        return addTime;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column lao_fang.add_time
     *
     * @param addTime the value for lao_fang.add_time
     *
     * @mbg.generated Wed Feb 05 22:20:54 CST 2020
     */
    public void setAddTime(String addTime) {
        this.addTime = addTime == null ? null : addTime.trim();
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column lao_fang.pk_record_id
     *
     * @return the value of lao_fang.pk_record_id
     *
     * @mbg.generated Wed Feb 05 22:20:54 CST 2020
     */
    public Integer getPkRecordId() {
        return pkRecordId;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column lao_fang.pk_record_id
     *
     * @param pkRecordId the value for lao_fang.pk_record_id
     *
     * @mbg.generated Wed Feb 05 22:20:54 CST 2020
     */
    public void setPkRecordId(Integer pkRecordId) {
        this.pkRecordId = pkRecordId;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column lao_fang.deleted
     *
     * @return the value of lao_fang.deleted
     *
     * @mbg.generated Wed Feb 05 22:20:54 CST 2020
     */
    public Boolean getDeleted() {
        return deleted;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column lao_fang.deleted
     *
     * @param deleted the value for lao_fang.deleted
     *
     * @mbg.generated Wed Feb 05 22:20:54 CST 2020
     */
    public void setDeleted(Boolean deleted) {
        this.deleted = deleted;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column lao_fang.update_time
     *
     * @return the value of lao_fang.update_time
     *
     * @mbg.generated Wed Feb 05 22:20:54 CST 2020
     */
    public String getUpdateTime() {
        return updateTime;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column lao_fang.update_time
     *
     * @param updateTime the value for lao_fang.update_time
     *
     * @mbg.generated Wed Feb 05 22:20:54 CST 2020
     */
    public void setUpdateTime(String updateTime) {
        this.updateTime = updateTime == null ? null : updateTime.trim();
    }
}