package org.linlinjava.litemall.db.domain;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class TTTPetExample {
    protected String orderByClause;

    protected boolean distinct;

    protected List<Criteria> oredCriteria;

    public TTTPetExample() {
        oredCriteria = new ArrayList<Criteria>();
    }

    public void setOrderByClause(String orderByClause) {
        this.orderByClause = orderByClause;
    }

    public String getOrderByClause() {
        return orderByClause;
    }

    public void setDistinct(boolean distinct) {
        this.distinct = distinct;
    }

    public boolean isDistinct() {
        return distinct;
    }

    public List<Criteria> getOredCriteria() {
        return oredCriteria;
    }

    public void or(Criteria criteria) {
        oredCriteria.add(criteria);
    }

    public Criteria or() {
        Criteria criteria = createCriteriaInternal();
        oredCriteria.add(criteria);
        return criteria;
    }

    public Criteria createCriteria() {
        Criteria criteria = createCriteriaInternal();
        if (oredCriteria.size() == 0) {
            oredCriteria.add(criteria);
        }
        return criteria;
    }

    protected Criteria createCriteriaInternal() {
        Criteria criteria = new Criteria();
        return criteria;
    }

    public void clear() {
        oredCriteria.clear();
        orderByClause = null;
        distinct = false;
    }

    protected abstract static class GeneratedCriteria {
        protected List<Criterion> criteria;

        protected GeneratedCriteria() {
            super();
            criteria = new ArrayList<Criterion>();
        }

        public boolean isValid() {
            return criteria.size() > 0;
        }

        public List<Criterion> getAllCriteria() {
            return criteria;
        }

        public List<Criterion> getCriteria() {
            return criteria;
        }

        protected void addCriterion(String condition) {
            if (condition == null) {
                throw new RuntimeException("Value for condition cannot be null");
            }
            criteria.add(new Criterion(condition));
        }

        protected void addCriterion(String condition, Object value, String property) {
            if (value == null) {
                throw new RuntimeException("Value for " + property + " cannot be null");
            }
            criteria.add(new Criterion(condition, value));
        }

        protected void addCriterion(String condition, Object value1, Object value2, String property) {
            if (value1 == null || value2 == null) {
                throw new RuntimeException("Between values for " + property + " cannot be null");
            }
            criteria.add(new Criterion(condition, value1, value2));
        }

        public Criteria andIdIsNull() {
            addCriterion("id is null");
            return (Criteria) this;
        }

        public Criteria andIdIsNotNull() {
            addCriterion("id is not null");
            return (Criteria) this;
        }

        public Criteria andIdEqualTo(Integer value) {
            addCriterion("id =", value, "id");
            return (Criteria) this;
        }

        public Criteria andIdNotEqualTo(Integer value) {
            addCriterion("id <>", value, "id");
            return (Criteria) this;
        }

        public Criteria andIdGreaterThan(Integer value) {
            addCriterion("id >", value, "id");
            return (Criteria) this;
        }

        public Criteria andIdGreaterThanOrEqualTo(Integer value) {
            addCriterion("id >=", value, "id");
            return (Criteria) this;
        }

        public Criteria andIdLessThan(Integer value) {
            addCriterion("id <", value, "id");
            return (Criteria) this;
        }

        public Criteria andIdLessThanOrEqualTo(Integer value) {
            addCriterion("id <=", value, "id");
            return (Criteria) this;
        }

        public Criteria andIdIn(List<Integer> values) {
            addCriterion("id in", values, "id");
            return (Criteria) this;
        }

        public Criteria andIdNotIn(List<Integer> values) {
            addCriterion("id not in", values, "id");
            return (Criteria) this;
        }

        public Criteria andIdBetween(Integer value1, Integer value2) {
            addCriterion("id between", value1, value2, "id");
            return (Criteria) this;
        }

        public Criteria andIdNotBetween(Integer value1, Integer value2) {
            addCriterion("id not between", value1, value2, "id");
            return (Criteria) this;
        }

        public Criteria andLevelReqIsNull() {
            addCriterion("level_req is null");
            return (Criteria) this;
        }

        public Criteria andLevelReqIsNotNull() {
            addCriterion("level_req is not null");
            return (Criteria) this;
        }

        public Criteria andLevelReqEqualTo(Integer value) {
            addCriterion("level_req =", value, "levelReq");
            return (Criteria) this;
        }

        public Criteria andLevelReqNotEqualTo(Integer value) {
            addCriterion("level_req <>", value, "levelReq");
            return (Criteria) this;
        }

        public Criteria andLevelReqGreaterThan(Integer value) {
            addCriterion("level_req >", value, "levelReq");
            return (Criteria) this;
        }

        public Criteria andLevelReqGreaterThanOrEqualTo(Integer value) {
            addCriterion("level_req >=", value, "levelReq");
            return (Criteria) this;
        }

        public Criteria andLevelReqLessThan(Integer value) {
            addCriterion("level_req <", value, "levelReq");
            return (Criteria) this;
        }

        public Criteria andLevelReqLessThanOrEqualTo(Integer value) {
            addCriterion("level_req <=", value, "levelReq");
            return (Criteria) this;
        }

        public Criteria andLevelReqIn(List<Integer> values) {
            addCriterion("level_req in", values, "levelReq");
            return (Criteria) this;
        }

        public Criteria andLevelReqNotIn(List<Integer> values) {
            addCriterion("level_req not in", values, "levelReq");
            return (Criteria) this;
        }

        public Criteria andLevelReqBetween(Integer value1, Integer value2) {
            addCriterion("level_req between", value1, value2, "levelReq");
            return (Criteria) this;
        }

        public Criteria andLevelReqNotBetween(Integer value1, Integer value2) {
            addCriterion("level_req not between", value1, value2, "levelReq");
            return (Criteria) this;
        }

        public Criteria andLifeIsNull() {
            addCriterion("life is null");
            return (Criteria) this;
        }

        public Criteria andLifeIsNotNull() {
            addCriterion("life is not null");
            return (Criteria) this;
        }

        public Criteria andLifeEqualTo(Integer value) {
            addCriterion("life =", value, "life");
            return (Criteria) this;
        }

        public Criteria andLifeNotEqualTo(Integer value) {
            addCriterion("life <>", value, "life");
            return (Criteria) this;
        }

        public Criteria andLifeGreaterThan(Integer value) {
            addCriterion("life >", value, "life");
            return (Criteria) this;
        }

        public Criteria andLifeGreaterThanOrEqualTo(Integer value) {
            addCriterion("life >=", value, "life");
            return (Criteria) this;
        }

        public Criteria andLifeLessThan(Integer value) {
            addCriterion("life <", value, "life");
            return (Criteria) this;
        }

        public Criteria andLifeLessThanOrEqualTo(Integer value) {
            addCriterion("life <=", value, "life");
            return (Criteria) this;
        }

        public Criteria andLifeIn(List<Integer> values) {
            addCriterion("life in", values, "life");
            return (Criteria) this;
        }

        public Criteria andLifeNotIn(List<Integer> values) {
            addCriterion("life not in", values, "life");
            return (Criteria) this;
        }

        public Criteria andLifeBetween(Integer value1, Integer value2) {
            addCriterion("life between", value1, value2, "life");
            return (Criteria) this;
        }

        public Criteria andLifeNotBetween(Integer value1, Integer value2) {
            addCriterion("life not between", value1, value2, "life");
            return (Criteria) this;
        }

        public Criteria andManaIsNull() {
            addCriterion("mana is null");
            return (Criteria) this;
        }

        public Criteria andManaIsNotNull() {
            addCriterion("mana is not null");
            return (Criteria) this;
        }

        public Criteria andManaEqualTo(Integer value) {
            addCriterion("mana =", value, "mana");
            return (Criteria) this;
        }

        public Criteria andManaNotEqualTo(Integer value) {
            addCriterion("mana <>", value, "mana");
            return (Criteria) this;
        }

        public Criteria andManaGreaterThan(Integer value) {
            addCriterion("mana >", value, "mana");
            return (Criteria) this;
        }

        public Criteria andManaGreaterThanOrEqualTo(Integer value) {
            addCriterion("mana >=", value, "mana");
            return (Criteria) this;
        }

        public Criteria andManaLessThan(Integer value) {
            addCriterion("mana <", value, "mana");
            return (Criteria) this;
        }

        public Criteria andManaLessThanOrEqualTo(Integer value) {
            addCriterion("mana <=", value, "mana");
            return (Criteria) this;
        }

        public Criteria andManaIn(List<Integer> values) {
            addCriterion("mana in", values, "mana");
            return (Criteria) this;
        }

        public Criteria andManaNotIn(List<Integer> values) {
            addCriterion("mana not in", values, "mana");
            return (Criteria) this;
        }

        public Criteria andManaBetween(Integer value1, Integer value2) {
            addCriterion("mana between", value1, value2, "mana");
            return (Criteria) this;
        }

        public Criteria andManaNotBetween(Integer value1, Integer value2) {
            addCriterion("mana not between", value1, value2, "mana");
            return (Criteria) this;
        }

        public Criteria andSpeedIsNull() {
            addCriterion("speed is null");
            return (Criteria) this;
        }

        public Criteria andSpeedIsNotNull() {
            addCriterion("speed is not null");
            return (Criteria) this;
        }

        public Criteria andSpeedEqualTo(Integer value) {
            addCriterion("speed =", value, "speed");
            return (Criteria) this;
        }

        public Criteria andSpeedNotEqualTo(Integer value) {
            addCriterion("speed <>", value, "speed");
            return (Criteria) this;
        }

        public Criteria andSpeedGreaterThan(Integer value) {
            addCriterion("speed >", value, "speed");
            return (Criteria) this;
        }

        public Criteria andSpeedGreaterThanOrEqualTo(Integer value) {
            addCriterion("speed >=", value, "speed");
            return (Criteria) this;
        }

        public Criteria andSpeedLessThan(Integer value) {
            addCriterion("speed <", value, "speed");
            return (Criteria) this;
        }

        public Criteria andSpeedLessThanOrEqualTo(Integer value) {
            addCriterion("speed <=", value, "speed");
            return (Criteria) this;
        }

        public Criteria andSpeedIn(List<Integer> values) {
            addCriterion("speed in", values, "speed");
            return (Criteria) this;
        }

        public Criteria andSpeedNotIn(List<Integer> values) {
            addCriterion("speed not in", values, "speed");
            return (Criteria) this;
        }

        public Criteria andSpeedBetween(Integer value1, Integer value2) {
            addCriterion("speed between", value1, value2, "speed");
            return (Criteria) this;
        }

        public Criteria andSpeedNotBetween(Integer value1, Integer value2) {
            addCriterion("speed not between", value1, value2, "speed");
            return (Criteria) this;
        }

        public Criteria andPhyAttackIsNull() {
            addCriterion("phy_attack is null");
            return (Criteria) this;
        }

        public Criteria andPhyAttackIsNotNull() {
            addCriterion("phy_attack is not null");
            return (Criteria) this;
        }

        public Criteria andPhyAttackEqualTo(Integer value) {
            addCriterion("phy_attack =", value, "phyAttack");
            return (Criteria) this;
        }

        public Criteria andPhyAttackNotEqualTo(Integer value) {
            addCriterion("phy_attack <>", value, "phyAttack");
            return (Criteria) this;
        }

        public Criteria andPhyAttackGreaterThan(Integer value) {
            addCriterion("phy_attack >", value, "phyAttack");
            return (Criteria) this;
        }

        public Criteria andPhyAttackGreaterThanOrEqualTo(Integer value) {
            addCriterion("phy_attack >=", value, "phyAttack");
            return (Criteria) this;
        }

        public Criteria andPhyAttackLessThan(Integer value) {
            addCriterion("phy_attack <", value, "phyAttack");
            return (Criteria) this;
        }

        public Criteria andPhyAttackLessThanOrEqualTo(Integer value) {
            addCriterion("phy_attack <=", value, "phyAttack");
            return (Criteria) this;
        }

        public Criteria andPhyAttackIn(List<Integer> values) {
            addCriterion("phy_attack in", values, "phyAttack");
            return (Criteria) this;
        }

        public Criteria andPhyAttackNotIn(List<Integer> values) {
            addCriterion("phy_attack not in", values, "phyAttack");
            return (Criteria) this;
        }

        public Criteria andPhyAttackBetween(Integer value1, Integer value2) {
            addCriterion("phy_attack between", value1, value2, "phyAttack");
            return (Criteria) this;
        }

        public Criteria andPhyAttackNotBetween(Integer value1, Integer value2) {
            addCriterion("phy_attack not between", value1, value2, "phyAttack");
            return (Criteria) this;
        }

        public Criteria andMagAttackIsNull() {
            addCriterion("mag_attack is null");
            return (Criteria) this;
        }

        public Criteria andMagAttackIsNotNull() {
            addCriterion("mag_attack is not null");
            return (Criteria) this;
        }

        public Criteria andMagAttackEqualTo(Integer value) {
            addCriterion("mag_attack =", value, "magAttack");
            return (Criteria) this;
        }

        public Criteria andMagAttackNotEqualTo(Integer value) {
            addCriterion("mag_attack <>", value, "magAttack");
            return (Criteria) this;
        }

        public Criteria andMagAttackGreaterThan(Integer value) {
            addCriterion("mag_attack >", value, "magAttack");
            return (Criteria) this;
        }

        public Criteria andMagAttackGreaterThanOrEqualTo(Integer value) {
            addCriterion("mag_attack >=", value, "magAttack");
            return (Criteria) this;
        }

        public Criteria andMagAttackLessThan(Integer value) {
            addCriterion("mag_attack <", value, "magAttack");
            return (Criteria) this;
        }

        public Criteria andMagAttackLessThanOrEqualTo(Integer value) {
            addCriterion("mag_attack <=", value, "magAttack");
            return (Criteria) this;
        }

        public Criteria andMagAttackIn(List<Integer> values) {
            addCriterion("mag_attack in", values, "magAttack");
            return (Criteria) this;
        }

        public Criteria andMagAttackNotIn(List<Integer> values) {
            addCriterion("mag_attack not in", values, "magAttack");
            return (Criteria) this;
        }

        public Criteria andMagAttackBetween(Integer value1, Integer value2) {
            addCriterion("mag_attack between", value1, value2, "magAttack");
            return (Criteria) this;
        }

        public Criteria andMagAttackNotBetween(Integer value1, Integer value2) {
            addCriterion("mag_attack not between", value1, value2, "magAttack");
            return (Criteria) this;
        }

        public Criteria andPolarIsNull() {
            addCriterion("polar is null");
            return (Criteria) this;
        }

        public Criteria andPolarIsNotNull() {
            addCriterion("polar is not null");
            return (Criteria) this;
        }

        public Criteria andPolarEqualTo(String value) {
            addCriterion("polar =", value, "polar");
            return (Criteria) this;
        }

        public Criteria andPolarNotEqualTo(String value) {
            addCriterion("polar <>", value, "polar");
            return (Criteria) this;
        }

        public Criteria andPolarGreaterThan(String value) {
            addCriterion("polar >", value, "polar");
            return (Criteria) this;
        }

        public Criteria andPolarGreaterThanOrEqualTo(String value) {
            addCriterion("polar >=", value, "polar");
            return (Criteria) this;
        }

        public Criteria andPolarLessThan(String value) {
            addCriterion("polar <", value, "polar");
            return (Criteria) this;
        }

        public Criteria andPolarLessThanOrEqualTo(String value) {
            addCriterion("polar <=", value, "polar");
            return (Criteria) this;
        }

        public Criteria andPolarLike(String value) {
            addCriterion("polar like", value, "polar");
            return (Criteria) this;
        }

        public Criteria andPolarNotLike(String value) {
            addCriterion("polar not like", value, "polar");
            return (Criteria) this;
        }

        public Criteria andPolarIn(List<String> values) {
            addCriterion("polar in", values, "polar");
            return (Criteria) this;
        }

        public Criteria andPolarNotIn(List<String> values) {
            addCriterion("polar not in", values, "polar");
            return (Criteria) this;
        }

        public Criteria andPolarBetween(String value1, String value2) {
            addCriterion("polar between", value1, value2, "polar");
            return (Criteria) this;
        }

        public Criteria andPolarNotBetween(String value1, String value2) {
            addCriterion("polar not between", value1, value2, "polar");
            return (Criteria) this;
        }

        public Criteria andIconIsNull() {
            addCriterion("icon is null");
            return (Criteria) this;
        }

        public Criteria andIconIsNotNull() {
            addCriterion("icon is not null");
            return (Criteria) this;
        }

        public Criteria andIconEqualTo(Integer value) {
            addCriterion("icon =", value, "icon");
            return (Criteria) this;
        }

        public Criteria andIconNotEqualTo(Integer value) {
            addCriterion("icon <>", value, "icon");
            return (Criteria) this;
        }

        public Criteria andIconGreaterThan(Integer value) {
            addCriterion("icon >", value, "icon");
            return (Criteria) this;
        }

        public Criteria andIconGreaterThanOrEqualTo(Integer value) {
            addCriterion("icon >=", value, "icon");
            return (Criteria) this;
        }

        public Criteria andIconLessThan(Integer value) {
            addCriterion("icon <", value, "icon");
            return (Criteria) this;
        }

        public Criteria andIconLessThanOrEqualTo(Integer value) {
            addCriterion("icon <=", value, "icon");
            return (Criteria) this;
        }

        public Criteria andIconIn(List<Integer> values) {
            addCriterion("icon in", values, "icon");
            return (Criteria) this;
        }

        public Criteria andIconNotIn(List<Integer> values) {
            addCriterion("icon not in", values, "icon");
            return (Criteria) this;
        }

        public Criteria andIconBetween(Integer value1, Integer value2) {
            addCriterion("icon between", value1, value2, "icon");
            return (Criteria) this;
        }

        public Criteria andIconNotBetween(Integer value1, Integer value2) {
            addCriterion("icon not between", value1, value2, "icon");
            return (Criteria) this;
        }

        public Criteria andAddTimeIsNull() {
            addCriterion("add_time is null");
            return (Criteria) this;
        }

        public Criteria andAddTimeIsNotNull() {
            addCriterion("add_time is not null");
            return (Criteria) this;
        }

        public Criteria andAddTimeEqualTo(Date value) {
            addCriterion("add_time =", value, "addTime");
            return (Criteria) this;
        }

        public Criteria andAddTimeNotEqualTo(Date value) {
            addCriterion("add_time <>", value, "addTime");
            return (Criteria) this;
        }

        public Criteria andAddTimeGreaterThan(Date value) {
            addCriterion("add_time >", value, "addTime");
            return (Criteria) this;
        }

        public Criteria andAddTimeGreaterThanOrEqualTo(Date value) {
            addCriterion("add_time >=", value, "addTime");
            return (Criteria) this;
        }

        public Criteria andAddTimeLessThan(Date value) {
            addCriterion("add_time <", value, "addTime");
            return (Criteria) this;
        }

        public Criteria andAddTimeLessThanOrEqualTo(Date value) {
            addCriterion("add_time <=", value, "addTime");
            return (Criteria) this;
        }

        public Criteria andAddTimeIn(List<Date> values) {
            addCriterion("add_time in", values, "addTime");
            return (Criteria) this;
        }

        public Criteria andAddTimeNotIn(List<Date> values) {
            addCriterion("add_time not in", values, "addTime");
            return (Criteria) this;
        }

        public Criteria andAddTimeBetween(Date value1, Date value2) {
            addCriterion("add_time between", value1, value2, "addTime");
            return (Criteria) this;
        }

        public Criteria andAddTimeNotBetween(Date value1, Date value2) {
            addCriterion("add_time not between", value1, value2, "addTime");
            return (Criteria) this;
        }

        public Criteria andUpdateTimeIsNull() {
            addCriterion("update_time is null");
            return (Criteria) this;
        }

        public Criteria andUpdateTimeIsNotNull() {
            addCriterion("update_time is not null");
            return (Criteria) this;
        }

        public Criteria andUpdateTimeEqualTo(Date value) {
            addCriterion("update_time =", value, "updateTime");
            return (Criteria) this;
        }

        public Criteria andUpdateTimeNotEqualTo(Date value) {
            addCriterion("update_time <>", value, "updateTime");
            return (Criteria) this;
        }

        public Criteria andUpdateTimeGreaterThan(Date value) {
            addCriterion("update_time >", value, "updateTime");
            return (Criteria) this;
        }

        public Criteria andUpdateTimeGreaterThanOrEqualTo(Date value) {
            addCriterion("update_time >=", value, "updateTime");
            return (Criteria) this;
        }

        public Criteria andUpdateTimeLessThan(Date value) {
            addCriterion("update_time <", value, "updateTime");
            return (Criteria) this;
        }

        public Criteria andUpdateTimeLessThanOrEqualTo(Date value) {
            addCriterion("update_time <=", value, "updateTime");
            return (Criteria) this;
        }

        public Criteria andUpdateTimeIn(List<Date> values) {
            addCriterion("update_time in", values, "updateTime");
            return (Criteria) this;
        }

        public Criteria andUpdateTimeNotIn(List<Date> values) {
            addCriterion("update_time not in", values, "updateTime");
            return (Criteria) this;
        }

        public Criteria andUpdateTimeBetween(Date value1, Date value2) {
            addCriterion("update_time between", value1, value2, "updateTime");
            return (Criteria) this;
        }

        public Criteria andUpdateTimeNotBetween(Date value1, Date value2) {
            addCriterion("update_time not between", value1, value2, "updateTime");
            return (Criteria) this;
        }

        public Criteria andDeletedIsNull() {
            addCriterion("deleted is null");
            return (Criteria) this;
        }

        public Criteria andDeletedIsNotNull() {
            addCriterion("deleted is not null");
            return (Criteria) this;
        }

        public Criteria andDeletedEqualTo(Boolean value) {
            addCriterion("deleted =", value, "deleted");
            return (Criteria) this;
        }

        public Criteria andDeletedNotEqualTo(Boolean value) {
            addCriterion("deleted <>", value, "deleted");
            return (Criteria) this;
        }

        public Criteria andDeletedGreaterThan(Boolean value) {
            addCriterion("deleted >", value, "deleted");
            return (Criteria) this;
        }

        public Criteria andDeletedGreaterThanOrEqualTo(Boolean value) {
            addCriterion("deleted >=", value, "deleted");
            return (Criteria) this;
        }

        public Criteria andDeletedLessThan(Boolean value) {
            addCriterion("deleted <", value, "deleted");
            return (Criteria) this;
        }

        public Criteria andDeletedLessThanOrEqualTo(Boolean value) {
            addCriterion("deleted <=", value, "deleted");
            return (Criteria) this;
        }

        public Criteria andDeletedIn(List<Boolean> values) {
            addCriterion("deleted in", values, "deleted");
            return (Criteria) this;
        }

        public Criteria andDeletedNotIn(List<Boolean> values) {
            addCriterion("deleted not in", values, "deleted");
            return (Criteria) this;
        }

        public Criteria andDeletedBetween(Boolean value1, Boolean value2) {
            addCriterion("deleted between", value1, value2, "deleted");
            return (Criteria) this;
        }

        public Criteria andDeletedNotBetween(Boolean value1, Boolean value2) {
            addCriterion("deleted not between", value1, value2, "deleted");
            return (Criteria) this;
        }

        public Criteria andNameIsNull() {
            addCriterion("name is null");
            return (Criteria) this;
        }

        public Criteria andNameIsNotNull() {
            addCriterion("name is not null");
            return (Criteria) this;
        }

        public Criteria andNameEqualTo(String value) {
            addCriterion("name =", value, "name");
            return (Criteria) this;
        }

        public Criteria andNameNotEqualTo(String value) {
            addCriterion("name <>", value, "name");
            return (Criteria) this;
        }

        public Criteria andNameGreaterThan(String value) {
            addCriterion("name >", value, "name");
            return (Criteria) this;
        }

        public Criteria andNameGreaterThanOrEqualTo(String value) {
            addCriterion("name >=", value, "name");
            return (Criteria) this;
        }

        public Criteria andNameLessThan(String value) {
            addCriterion("name <", value, "name");
            return (Criteria) this;
        }

        public Criteria andNameLessThanOrEqualTo(String value) {
            addCriterion("name <=", value, "name");
            return (Criteria) this;
        }

        public Criteria andNameLike(String value) {
            addCriterion("name like", value, "name");
            return (Criteria) this;
        }

        public Criteria andNameNotLike(String value) {
            addCriterion("name not like", value, "name");
            return (Criteria) this;
        }

        public Criteria andNameIn(List<String> values) {
            addCriterion("name in", values, "name");
            return (Criteria) this;
        }

        public Criteria andNameNotIn(List<String> values) {
            addCriterion("name not in", values, "name");
            return (Criteria) this;
        }

        public Criteria andNameBetween(String value1, String value2) {
            addCriterion("name between", value1, value2, "name");
            return (Criteria) this;
        }

        public Criteria andNameNotBetween(String value1, String value2) {
            addCriterion("name not between", value1, value2, "name");
            return (Criteria) this;
        }
    }

    public static class Criteria extends GeneratedCriteria {

        protected Criteria() {
            super();
        }
    }

    public static class Criterion {
        private String condition;

        private Object value;

        private Object secondValue;

        private boolean noValue;

        private boolean singleValue;

        private boolean betweenValue;

        private boolean listValue;

        private String typeHandler;

        public String getCondition() {
            return condition;
        }

        public Object getValue() {
            return value;
        }

        public Object getSecondValue() {
            return secondValue;
        }

        public boolean isNoValue() {
            return noValue;
        }

        public boolean isSingleValue() {
            return singleValue;
        }

        public boolean isBetweenValue() {
            return betweenValue;
        }

        public boolean isListValue() {
            return listValue;
        }

        public String getTypeHandler() {
            return typeHandler;
        }

        protected Criterion(String condition) {
            super();
            this.condition = condition;
            this.typeHandler = null;
            this.noValue = true;
        }

        protected Criterion(String condition, Object value, String typeHandler) {
            super();
            this.condition = condition;
            this.value = value;
            this.typeHandler = typeHandler;
            if (value instanceof List<?>) {
                this.listValue = true;
            } else {
                this.singleValue = true;
            }
        }

        protected Criterion(String condition, Object value) {
            this(condition, value, null);
        }

        protected Criterion(String condition, Object value, Object secondValue, String typeHandler) {
            super();
            this.condition = condition;
            this.value = value;
            this.secondValue = secondValue;
            this.typeHandler = typeHandler;
            this.betweenValue = true;
        }

        protected Criterion(String condition, Object value, Object secondValue) {
            this(condition, value, secondValue, null);
        }
    }
}