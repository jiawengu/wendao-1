package org.linlinjava.litemall.db.domain;

public class ShangGuYaoWangInfo {
    /**
     *
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column shang_gu_yao_wang_info.id
     *
     * @mbg.generated Fri Jan 17 20:29:23 CST 2020
     */
    private Integer id;

    /**
     *
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column shang_gu_yao_wang_info.npcID
     *
     * @mbg.generated Fri Jan 17 20:29:23 CST 2020
     */
    private Integer npcid;

    /**
     *
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column shang_gu_yao_wang_info.level
     *
     * @mbg.generated Fri Jan 17 20:29:23 CST 2020
     */
    private Integer level;

    /**
     *
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column shang_gu_yao_wang_info.state
     *
     * @mbg.generated Fri Jan 17 20:29:23 CST 2020
     */
    private Boolean state;

    /**
     *
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column shang_gu_yao_wang_info.reward
     *
     * @mbg.generated Fri Jan 17 20:29:23 CST 2020
     */
    private String reward;

    /**
     *
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column shang_gu_yao_wang_info.wa_chu_account_id
     *
     * @mbg.generated Fri Jan 17 20:29:23 CST 2020
     */
    private Integer waChuAccountId;

    /**
     *
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column shang_gu_yao_wang_info.wa_chu_reward
     *
     * @mbg.generated Fri Jan 17 20:29:23 CST 2020
     */
    private String waChuReward;

    /**
     *
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column shang_gu_yao_wang_info.xiao_guai
     *
     * @mbg.generated Fri Jan 17 20:29:23 CST 2020
     */
    private String xiaoGuai;

    /**
     *
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column shang_gu_yao_wang_info.chufa
     *
     * @mbg.generated Fri Jan 17 20:29:23 CST 2020
     */
    private String chufa;

    /**
     *
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column shang_gu_yao_wang_info.map_id
     *
     * @mbg.generated Fri Jan 17 20:29:23 CST 2020
     */
    private Integer mapId;

    /**
     *
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column shang_gu_yao_wang_info.x
     *
     * @mbg.generated Fri Jan 17 20:29:23 CST 2020
     */
    private Integer x;

    /**
     *
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column shang_gu_yao_wang_info.y
     *
     * @mbg.generated Fri Jan 17 20:29:23 CST 2020
     */
    private Integer y;

    /**
     *
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column shang_gu_yao_wang_info.name
     *
     * @mbg.generated Fri Jan 17 20:29:23 CST 2020
     */
    private String name;

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table shang_gu_yao_wang_info
     *
     * @mbg.generated Fri Jan 17 20:29:23 CST 2020
     */
    public ShangGuYaoWangInfo(Integer id, Integer npcid, Integer level, Boolean state, String reward, Integer waChuAccountId, String waChuReward, String xiaoGuai, String chufa, Integer mapId, Integer x, Integer y, String name) {
        this.id = id;
        this.npcid = npcid;
        this.level = level;
        this.state = state;
        this.reward = reward;
        this.waChuAccountId = waChuAccountId;
        this.waChuReward = waChuReward;
        this.xiaoGuai = xiaoGuai;
        this.chufa = chufa;
        this.mapId = mapId;
        this.x = x;
        this.y = y;
        this.name = name;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table shang_gu_yao_wang_info
     *
     * @mbg.generated Fri Jan 17 20:29:23 CST 2020
     */
    public ShangGuYaoWangInfo() {
        super();
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column shang_gu_yao_wang_info.id
     *
     * @return the value of shang_gu_yao_wang_info.id
     *
     * @mbg.generated Fri Jan 17 20:29:23 CST 2020
     */
    public Integer getId() {
        return id;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column shang_gu_yao_wang_info.id
     *
     * @param id the value for shang_gu_yao_wang_info.id
     *
     * @mbg.generated Fri Jan 17 20:29:23 CST 2020
     */
    public void setId(Integer id) {
        this.id = id;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column shang_gu_yao_wang_info.npcID
     *
     * @return the value of shang_gu_yao_wang_info.npcID
     *
     * @mbg.generated Fri Jan 17 20:29:23 CST 2020
     */
    public Integer getNpcid() {
        return npcid;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column shang_gu_yao_wang_info.npcID
     *
     * @param npcid the value for shang_gu_yao_wang_info.npcID
     *
     * @mbg.generated Fri Jan 17 20:29:23 CST 2020
     */
    public void setNpcid(Integer npcid) {
        this.npcid = npcid;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column shang_gu_yao_wang_info.level
     *
     * @return the value of shang_gu_yao_wang_info.level
     *
     * @mbg.generated Fri Jan 17 20:29:23 CST 2020
     */
    public Integer getLevel() {
        return level;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column shang_gu_yao_wang_info.level
     *
     * @param level the value for shang_gu_yao_wang_info.level
     *
     * @mbg.generated Fri Jan 17 20:29:23 CST 2020
     */
    public void setLevel(Integer level) {
        this.level = level;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column shang_gu_yao_wang_info.state
     *
     * @return the value of shang_gu_yao_wang_info.state
     *
     * @mbg.generated Fri Jan 17 20:29:23 CST 2020
     */
    public Boolean getState() {
        return state;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column shang_gu_yao_wang_info.state
     *
     * @param state the value for shang_gu_yao_wang_info.state
     *
     * @mbg.generated Fri Jan 17 20:29:23 CST 2020
     */
    public void setState(Boolean state) {
        this.state = state;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column shang_gu_yao_wang_info.reward
     *
     * @return the value of shang_gu_yao_wang_info.reward
     *
     * @mbg.generated Fri Jan 17 20:29:23 CST 2020
     */
    public String getReward() {
        return reward;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column shang_gu_yao_wang_info.reward
     *
     * @param reward the value for shang_gu_yao_wang_info.reward
     *
     * @mbg.generated Fri Jan 17 20:29:23 CST 2020
     */
    public void setReward(String reward) {
        this.reward = reward == null ? null : reward.trim();
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column shang_gu_yao_wang_info.wa_chu_account_id
     *
     * @return the value of shang_gu_yao_wang_info.wa_chu_account_id
     *
     * @mbg.generated Fri Jan 17 20:29:23 CST 2020
     */
    public Integer getWaChuAccountId() {
        return waChuAccountId;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column shang_gu_yao_wang_info.wa_chu_account_id
     *
     * @param waChuAccountId the value for shang_gu_yao_wang_info.wa_chu_account_id
     *
     * @mbg.generated Fri Jan 17 20:29:23 CST 2020
     */
    public void setWaChuAccountId(Integer waChuAccountId) {
        this.waChuAccountId = waChuAccountId;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column shang_gu_yao_wang_info.wa_chu_reward
     *
     * @return the value of shang_gu_yao_wang_info.wa_chu_reward
     *
     * @mbg.generated Fri Jan 17 20:29:23 CST 2020
     */
    public String getWaChuReward() {
        return waChuReward;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column shang_gu_yao_wang_info.wa_chu_reward
     *
     * @param waChuReward the value for shang_gu_yao_wang_info.wa_chu_reward
     *
     * @mbg.generated Fri Jan 17 20:29:23 CST 2020
     */
    public void setWaChuReward(String waChuReward) {
        this.waChuReward = waChuReward == null ? null : waChuReward.trim();
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column shang_gu_yao_wang_info.xiao_guai
     *
     * @return the value of shang_gu_yao_wang_info.xiao_guai
     *
     * @mbg.generated Fri Jan 17 20:29:23 CST 2020
     */
    public String getXiaoGuai() {
        return xiaoGuai;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column shang_gu_yao_wang_info.xiao_guai
     *
     * @param xiaoGuai the value for shang_gu_yao_wang_info.xiao_guai
     *
     * @mbg.generated Fri Jan 17 20:29:23 CST 2020
     */
    public void setXiaoGuai(String xiaoGuai) {
        this.xiaoGuai = xiaoGuai == null ? null : xiaoGuai.trim();
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column shang_gu_yao_wang_info.chufa
     *
     * @return the value of shang_gu_yao_wang_info.chufa
     *
     * @mbg.generated Fri Jan 17 20:29:23 CST 2020
     */
    public String getChufa() {
        return chufa;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column shang_gu_yao_wang_info.chufa
     *
     * @param chufa the value for shang_gu_yao_wang_info.chufa
     *
     * @mbg.generated Fri Jan 17 20:29:23 CST 2020
     */
    public void setChufa(String chufa) {
        this.chufa = chufa == null ? null : chufa.trim();
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column shang_gu_yao_wang_info.map_id
     *
     * @return the value of shang_gu_yao_wang_info.map_id
     *
     * @mbg.generated Fri Jan 17 20:29:23 CST 2020
     */
    public Integer getMapId() {
        return mapId;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column shang_gu_yao_wang_info.map_id
     *
     * @param mapId the value for shang_gu_yao_wang_info.map_id
     *
     * @mbg.generated Fri Jan 17 20:29:23 CST 2020
     */
    public void setMapId(Integer mapId) {
        this.mapId = mapId;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column shang_gu_yao_wang_info.x
     *
     * @return the value of shang_gu_yao_wang_info.x
     *
     * @mbg.generated Fri Jan 17 20:29:23 CST 2020
     */
    public Integer getX() {
        return x;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column shang_gu_yao_wang_info.x
     *
     * @param x the value for shang_gu_yao_wang_info.x
     *
     * @mbg.generated Fri Jan 17 20:29:23 CST 2020
     */
    public void setX(Integer x) {
        this.x = x;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column shang_gu_yao_wang_info.y
     *
     * @return the value of shang_gu_yao_wang_info.y
     *
     * @mbg.generated Fri Jan 17 20:29:23 CST 2020
     */
    public Integer getY() {
        return y;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column shang_gu_yao_wang_info.y
     *
     * @param y the value for shang_gu_yao_wang_info.y
     *
     * @mbg.generated Fri Jan 17 20:29:23 CST 2020
     */
    public void setY(Integer y) {
        this.y = y;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column shang_gu_yao_wang_info.name
     *
     * @return the value of shang_gu_yao_wang_info.name
     *
     * @mbg.generated Fri Jan 17 20:29:23 CST 2020
     */
    public String getName() {
        return name;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column shang_gu_yao_wang_info.name
     *
     * @param name the value for shang_gu_yao_wang_info.name
     *
     * @mbg.generated Fri Jan 17 20:29:23 CST 2020
     */
    public void setName(String name) {
        this.name = name == null ? null : name.trim();
    }
}