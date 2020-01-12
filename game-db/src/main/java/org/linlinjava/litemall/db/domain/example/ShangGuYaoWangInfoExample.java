package org.linlinjava.litemall.db.domain.example;

import java.util.ArrayList;
import java.util.List;

public class ShangGuYaoWangInfoExample {
    protected String orderByClause;

    protected boolean distinct;

    protected List<Criteria> oredCriteria;

    public ShangGuYaoWangInfoExample() {
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

        public Criteria andNpcidIsNull() {
            addCriterion("npcID is null");
            return (Criteria) this;
        }

        public Criteria andNpcidIsNotNull() {
            addCriterion("npcID is not null");
            return (Criteria) this;
        }

        public Criteria andNpcidEqualTo(Integer value) {
            addCriterion("npcID =", value, "npcid");
            return (Criteria) this;
        }

        public Criteria andNpcidNotEqualTo(Integer value) {
            addCriterion("npcID <>", value, "npcid");
            return (Criteria) this;
        }

        public Criteria andNpcidGreaterThan(Integer value) {
            addCriterion("npcID >", value, "npcid");
            return (Criteria) this;
        }

        public Criteria andNpcidGreaterThanOrEqualTo(Integer value) {
            addCriterion("npcID >=", value, "npcid");
            return (Criteria) this;
        }

        public Criteria andNpcidLessThan(Integer value) {
            addCriterion("npcID <", value, "npcid");
            return (Criteria) this;
        }

        public Criteria andNpcidLessThanOrEqualTo(Integer value) {
            addCriterion("npcID <=", value, "npcid");
            return (Criteria) this;
        }

        public Criteria andNpcidIn(List<Integer> values) {
            addCriterion("npcID in", values, "npcid");
            return (Criteria) this;
        }

        public Criteria andNpcidNotIn(List<Integer> values) {
            addCriterion("npcID not in", values, "npcid");
            return (Criteria) this;
        }

        public Criteria andNpcidBetween(Integer value1, Integer value2) {
            addCriterion("npcID between", value1, value2, "npcid");
            return (Criteria) this;
        }

        public Criteria andNpcidNotBetween(Integer value1, Integer value2) {
            addCriterion("npcID not between", value1, value2, "npcid");
            return (Criteria) this;
        }

        public Criteria andLevelIsNull() {
            addCriterion("level is null");
            return (Criteria) this;
        }

        public Criteria andLevelIsNotNull() {
            addCriterion("level is not null");
            return (Criteria) this;
        }

        public Criteria andLevelEqualTo(Integer value) {
            addCriterion("level =", value, "level");
            return (Criteria) this;
        }

        public Criteria andLevelNotEqualTo(Integer value) {
            addCriterion("level <>", value, "level");
            return (Criteria) this;
        }

        public Criteria andLevelGreaterThan(Integer value) {
            addCriterion("level >", value, "level");
            return (Criteria) this;
        }

        public Criteria andLevelGreaterThanOrEqualTo(Integer value) {
            addCriterion("level >=", value, "level");
            return (Criteria) this;
        }

        public Criteria andLevelLessThan(Integer value) {
            addCriterion("level <", value, "level");
            return (Criteria) this;
        }

        public Criteria andLevelLessThanOrEqualTo(Integer value) {
            addCriterion("level <=", value, "level");
            return (Criteria) this;
        }

        public Criteria andLevelIn(List<Integer> values) {
            addCriterion("level in", values, "level");
            return (Criteria) this;
        }

        public Criteria andLevelNotIn(List<Integer> values) {
            addCriterion("level not in", values, "level");
            return (Criteria) this;
        }

        public Criteria andLevelBetween(Integer value1, Integer value2) {
            addCriterion("level between", value1, value2, "level");
            return (Criteria) this;
        }

        public Criteria andLevelNotBetween(Integer value1, Integer value2) {
            addCriterion("level not between", value1, value2, "level");
            return (Criteria) this;
        }

        public Criteria andStateIsNull() {
            addCriterion("state is null");
            return (Criteria) this;
        }

        public Criteria andStateIsNotNull() {
            addCriterion("state is not null");
            return (Criteria) this;
        }

        public Criteria andStateEqualTo(Boolean value) {
            addCriterion("state =", value, "state");
            return (Criteria) this;
        }

        public Criteria andStateNotEqualTo(Boolean value) {
            addCriterion("state <>", value, "state");
            return (Criteria) this;
        }

        public Criteria andStateGreaterThan(Boolean value) {
            addCriterion("state >", value, "state");
            return (Criteria) this;
        }

        public Criteria andStateGreaterThanOrEqualTo(Boolean value) {
            addCriterion("state >=", value, "state");
            return (Criteria) this;
        }

        public Criteria andStateLessThan(Boolean value) {
            addCriterion("state <", value, "state");
            return (Criteria) this;
        }

        public Criteria andStateLessThanOrEqualTo(Boolean value) {
            addCriterion("state <=", value, "state");
            return (Criteria) this;
        }

        public Criteria andStateIn(List<Boolean> values) {
            addCriterion("state in", values, "state");
            return (Criteria) this;
        }

        public Criteria andStateNotIn(List<Boolean> values) {
            addCriterion("state not in", values, "state");
            return (Criteria) this;
        }

        public Criteria andStateBetween(Boolean value1, Boolean value2) {
            addCriterion("state between", value1, value2, "state");
            return (Criteria) this;
        }

        public Criteria andStateNotBetween(Boolean value1, Boolean value2) {
            addCriterion("state not between", value1, value2, "state");
            return (Criteria) this;
        }

        public Criteria andRewardIsNull() {
            addCriterion("reward is null");
            return (Criteria) this;
        }

        public Criteria andRewardIsNotNull() {
            addCriterion("reward is not null");
            return (Criteria) this;
        }

        public Criteria andRewardEqualTo(String value) {
            addCriterion("reward =", value, "reward");
            return (Criteria) this;
        }

        public Criteria andRewardNotEqualTo(String value) {
            addCriterion("reward <>", value, "reward");
            return (Criteria) this;
        }

        public Criteria andRewardGreaterThan(String value) {
            addCriterion("reward >", value, "reward");
            return (Criteria) this;
        }

        public Criteria andRewardGreaterThanOrEqualTo(String value) {
            addCriterion("reward >=", value, "reward");
            return (Criteria) this;
        }

        public Criteria andRewardLessThan(String value) {
            addCriterion("reward <", value, "reward");
            return (Criteria) this;
        }

        public Criteria andRewardLessThanOrEqualTo(String value) {
            addCriterion("reward <=", value, "reward");
            return (Criteria) this;
        }

        public Criteria andRewardLike(String value) {
            addCriterion("reward like", value, "reward");
            return (Criteria) this;
        }

        public Criteria andRewardNotLike(String value) {
            addCriterion("reward not like", value, "reward");
            return (Criteria) this;
        }

        public Criteria andRewardIn(List<String> values) {
            addCriterion("reward in", values, "reward");
            return (Criteria) this;
        }

        public Criteria andRewardNotIn(List<String> values) {
            addCriterion("reward not in", values, "reward");
            return (Criteria) this;
        }

        public Criteria andRewardBetween(String value1, String value2) {
            addCriterion("reward between", value1, value2, "reward");
            return (Criteria) this;
        }

        public Criteria andRewardNotBetween(String value1, String value2) {
            addCriterion("reward not between", value1, value2, "reward");
            return (Criteria) this;
        }

        public Criteria andWaChuAccountIdIsNull() {
            addCriterion("wa_chu_account_id is null");
            return (Criteria) this;
        }

        public Criteria andWaChuAccountIdIsNotNull() {
            addCriterion("wa_chu_account_id is not null");
            return (Criteria) this;
        }

        public Criteria andWaChuAccountIdEqualTo(Integer value) {
            addCriterion("wa_chu_account_id =", value, "waChuAccountId");
            return (Criteria) this;
        }

        public Criteria andWaChuAccountIdNotEqualTo(Integer value) {
            addCriterion("wa_chu_account_id <>", value, "waChuAccountId");
            return (Criteria) this;
        }

        public Criteria andWaChuAccountIdGreaterThan(Integer value) {
            addCriterion("wa_chu_account_id >", value, "waChuAccountId");
            return (Criteria) this;
        }

        public Criteria andWaChuAccountIdGreaterThanOrEqualTo(Integer value) {
            addCriterion("wa_chu_account_id >=", value, "waChuAccountId");
            return (Criteria) this;
        }

        public Criteria andWaChuAccountIdLessThan(Integer value) {
            addCriterion("wa_chu_account_id <", value, "waChuAccountId");
            return (Criteria) this;
        }

        public Criteria andWaChuAccountIdLessThanOrEqualTo(Integer value) {
            addCriterion("wa_chu_account_id <=", value, "waChuAccountId");
            return (Criteria) this;
        }

        public Criteria andWaChuAccountIdIn(List<Integer> values) {
            addCriterion("wa_chu_account_id in", values, "waChuAccountId");
            return (Criteria) this;
        }

        public Criteria andWaChuAccountIdNotIn(List<Integer> values) {
            addCriterion("wa_chu_account_id not in", values, "waChuAccountId");
            return (Criteria) this;
        }

        public Criteria andWaChuAccountIdBetween(Integer value1, Integer value2) {
            addCriterion("wa_chu_account_id between", value1, value2, "waChuAccountId");
            return (Criteria) this;
        }

        public Criteria andWaChuAccountIdNotBetween(Integer value1, Integer value2) {
            addCriterion("wa_chu_account_id not between", value1, value2, "waChuAccountId");
            return (Criteria) this;
        }

        public Criteria andWaChuRewardIsNull() {
            addCriterion("wa_chu_reward is null");
            return (Criteria) this;
        }

        public Criteria andWaChuRewardIsNotNull() {
            addCriterion("wa_chu_reward is not null");
            return (Criteria) this;
        }

        public Criteria andWaChuRewardEqualTo(String value) {
            addCriterion("wa_chu_reward =", value, "waChuReward");
            return (Criteria) this;
        }

        public Criteria andWaChuRewardNotEqualTo(String value) {
            addCriterion("wa_chu_reward <>", value, "waChuReward");
            return (Criteria) this;
        }

        public Criteria andWaChuRewardGreaterThan(String value) {
            addCriterion("wa_chu_reward >", value, "waChuReward");
            return (Criteria) this;
        }

        public Criteria andWaChuRewardGreaterThanOrEqualTo(String value) {
            addCriterion("wa_chu_reward >=", value, "waChuReward");
            return (Criteria) this;
        }

        public Criteria andWaChuRewardLessThan(String value) {
            addCriterion("wa_chu_reward <", value, "waChuReward");
            return (Criteria) this;
        }

        public Criteria andWaChuRewardLessThanOrEqualTo(String value) {
            addCriterion("wa_chu_reward <=", value, "waChuReward");
            return (Criteria) this;
        }

        public Criteria andWaChuRewardLike(String value) {
            addCriterion("wa_chu_reward like", value, "waChuReward");
            return (Criteria) this;
        }

        public Criteria andWaChuRewardNotLike(String value) {
            addCriterion("wa_chu_reward not like", value, "waChuReward");
            return (Criteria) this;
        }

        public Criteria andWaChuRewardIn(List<String> values) {
            addCriterion("wa_chu_reward in", values, "waChuReward");
            return (Criteria) this;
        }

        public Criteria andWaChuRewardNotIn(List<String> values) {
            addCriterion("wa_chu_reward not in", values, "waChuReward");
            return (Criteria) this;
        }

        public Criteria andWaChuRewardBetween(String value1, String value2) {
            addCriterion("wa_chu_reward between", value1, value2, "waChuReward");
            return (Criteria) this;
        }

        public Criteria andWaChuRewardNotBetween(String value1, String value2) {
            addCriterion("wa_chu_reward not between", value1, value2, "waChuReward");
            return (Criteria) this;
        }

        public Criteria andXiaoGuaiIsNull() {
            addCriterion("xiao_guai is null");
            return (Criteria) this;
        }

        public Criteria andXiaoGuaiIsNotNull() {
            addCriterion("xiao_guai is not null");
            return (Criteria) this;
        }

        public Criteria andXiaoGuaiEqualTo(String value) {
            addCriterion("xiao_guai =", value, "xiaoGuai");
            return (Criteria) this;
        }

        public Criteria andXiaoGuaiNotEqualTo(String value) {
            addCriterion("xiao_guai <>", value, "xiaoGuai");
            return (Criteria) this;
        }

        public Criteria andXiaoGuaiGreaterThan(String value) {
            addCriterion("xiao_guai >", value, "xiaoGuai");
            return (Criteria) this;
        }

        public Criteria andXiaoGuaiGreaterThanOrEqualTo(String value) {
            addCriterion("xiao_guai >=", value, "xiaoGuai");
            return (Criteria) this;
        }

        public Criteria andXiaoGuaiLessThan(String value) {
            addCriterion("xiao_guai <", value, "xiaoGuai");
            return (Criteria) this;
        }

        public Criteria andXiaoGuaiLessThanOrEqualTo(String value) {
            addCriterion("xiao_guai <=", value, "xiaoGuai");
            return (Criteria) this;
        }

        public Criteria andXiaoGuaiLike(String value) {
            addCriterion("xiao_guai like", value, "xiaoGuai");
            return (Criteria) this;
        }

        public Criteria andXiaoGuaiNotLike(String value) {
            addCriterion("xiao_guai not like", value, "xiaoGuai");
            return (Criteria) this;
        }

        public Criteria andXiaoGuaiIn(List<String> values) {
            addCriterion("xiao_guai in", values, "xiaoGuai");
            return (Criteria) this;
        }

        public Criteria andXiaoGuaiNotIn(List<String> values) {
            addCriterion("xiao_guai not in", values, "xiaoGuai");
            return (Criteria) this;
        }

        public Criteria andXiaoGuaiBetween(String value1, String value2) {
            addCriterion("xiao_guai between", value1, value2, "xiaoGuai");
            return (Criteria) this;
        }

        public Criteria andXiaoGuaiNotBetween(String value1, String value2) {
            addCriterion("xiao_guai not between", value1, value2, "xiaoGuai");
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