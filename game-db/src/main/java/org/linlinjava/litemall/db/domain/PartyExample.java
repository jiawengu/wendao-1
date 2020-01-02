package org.linlinjava.litemall.db.domain;

import java.util.ArrayList;
import java.util.List;

public class PartyExample {
    protected String orderByClause;

    protected boolean distinct;

    protected List<Criteria> oredCriteria;

    public PartyExample() {
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

        public Criteria andAnnounceIsNull() {
            addCriterion("announce is null");
            return (Criteria) this;
        }

        public Criteria andAnnounceIsNotNull() {
            addCriterion("announce is not null");
            return (Criteria) this;
        }

        public Criteria andAnnounceEqualTo(String value) {
            addCriterion("announce =", value, "announce");
            return (Criteria) this;
        }

        public Criteria andAnnounceNotEqualTo(String value) {
            addCriterion("announce <>", value, "announce");
            return (Criteria) this;
        }

        public Criteria andAnnounceGreaterThan(String value) {
            addCriterion("announce >", value, "announce");
            return (Criteria) this;
        }

        public Criteria andAnnounceGreaterThanOrEqualTo(String value) {
            addCriterion("announce >=", value, "announce");
            return (Criteria) this;
        }

        public Criteria andAnnounceLessThan(String value) {
            addCriterion("announce <", value, "announce");
            return (Criteria) this;
        }

        public Criteria andAnnounceLessThanOrEqualTo(String value) {
            addCriterion("announce <=", value, "announce");
            return (Criteria) this;
        }

        public Criteria andAnnounceLike(String value) {
            addCriterion("announce like", value, "announce");
            return (Criteria) this;
        }

        public Criteria andAnnounceNotLike(String value) {
            addCriterion("announce not like", value, "announce");
            return (Criteria) this;
        }

        public Criteria andAnnounceIn(List<String> values) {
            addCriterion("announce in", values, "announce");
            return (Criteria) this;
        }

        public Criteria andAnnounceNotIn(List<String> values) {
            addCriterion("announce not in", values, "announce");
            return (Criteria) this;
        }

        public Criteria andAnnounceBetween(String value1, String value2) {
            addCriterion("announce between", value1, value2, "announce");
            return (Criteria) this;
        }

        public Criteria andAnnounceNotBetween(String value1, String value2) {
            addCriterion("announce not between", value1, value2, "announce");
            return (Criteria) this;
        }

        public Criteria andMemberIsNull() {
            addCriterion("member is null");
            return (Criteria) this;
        }

        public Criteria andMemberIsNotNull() {
            addCriterion("member is not null");
            return (Criteria) this;
        }

        public Criteria andMemberEqualTo(String value) {
            addCriterion("member =", value, "member");
            return (Criteria) this;
        }

        public Criteria andMemberNotEqualTo(String value) {
            addCriterion("member <>", value, "member");
            return (Criteria) this;
        }

        public Criteria andMemberGreaterThan(String value) {
            addCriterion("member >", value, "member");
            return (Criteria) this;
        }

        public Criteria andMemberGreaterThanOrEqualTo(String value) {
            addCriterion("member >=", value, "member");
            return (Criteria) this;
        }

        public Criteria andMemberLessThan(String value) {
            addCriterion("member <", value, "member");
            return (Criteria) this;
        }

        public Criteria andMemberLessThanOrEqualTo(String value) {
            addCriterion("member <=", value, "member");
            return (Criteria) this;
        }

        public Criteria andMemberLike(String value) {
            addCriterion("member like", value, "member");
            return (Criteria) this;
        }

        public Criteria andMemberNotLike(String value) {
            addCriterion("member not like", value, "member");
            return (Criteria) this;
        }

        public Criteria andMemberIn(List<String> values) {
            addCriterion("member in", values, "member");
            return (Criteria) this;
        }

        public Criteria andMemberNotIn(List<String> values) {
            addCriterion("member not in", values, "member");
            return (Criteria) this;
        }

        public Criteria andMemberBetween(String value1, String value2) {
            addCriterion("member between", value1, value2, "member");
            return (Criteria) this;
        }

        public Criteria andMemberNotBetween(String value1, String value2) {
            addCriterion("member not between", value1, value2, "member");
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

        public Criteria andConstructionIsNull() {
            addCriterion("construction is null");
            return (Criteria) this;
        }

        public Criteria andConstructionIsNotNull() {
            addCriterion("construction is not null");
            return (Criteria) this;
        }

        public Criteria andConstructionEqualTo(Integer value) {
            addCriterion("construction =", value, "construction");
            return (Criteria) this;
        }

        public Criteria andConstructionNotEqualTo(Integer value) {
            addCriterion("construction <>", value, "construction");
            return (Criteria) this;
        }

        public Criteria andConstructionGreaterThan(Integer value) {
            addCriterion("construction >", value, "construction");
            return (Criteria) this;
        }

        public Criteria andConstructionGreaterThanOrEqualTo(Integer value) {
            addCriterion("construction >=", value, "construction");
            return (Criteria) this;
        }

        public Criteria andConstructionLessThan(Integer value) {
            addCriterion("construction <", value, "construction");
            return (Criteria) this;
        }

        public Criteria andConstructionLessThanOrEqualTo(Integer value) {
            addCriterion("construction <=", value, "construction");
            return (Criteria) this;
        }

        public Criteria andConstructionIn(List<Integer> values) {
            addCriterion("construction in", values, "construction");
            return (Criteria) this;
        }

        public Criteria andConstructionNotIn(List<Integer> values) {
            addCriterion("construction not in", values, "construction");
            return (Criteria) this;
        }

        public Criteria andConstructionBetween(Integer value1, Integer value2) {
            addCriterion("construction between", value1, value2, "construction");
            return (Criteria) this;
        }

        public Criteria andConstructionNotBetween(Integer value1, Integer value2) {
            addCriterion("construction not between", value1, value2, "construction");
            return (Criteria) this;
        }

        public Criteria andCreatorIsNull() {
            addCriterion("creator is null");
            return (Criteria) this;
        }

        public Criteria andCreatorIsNotNull() {
            addCriterion("creator is not null");
            return (Criteria) this;
        }

        public Criteria andCreatorEqualTo(String value) {
            addCriterion("creator =", value, "creator");
            return (Criteria) this;
        }

        public Criteria andCreatorNotEqualTo(String value) {
            addCriterion("creator <>", value, "creator");
            return (Criteria) this;
        }

        public Criteria andCreatorGreaterThan(String value) {
            addCriterion("creator >", value, "creator");
            return (Criteria) this;
        }

        public Criteria andCreatorGreaterThanOrEqualTo(String value) {
            addCriterion("creator >=", value, "creator");
            return (Criteria) this;
        }

        public Criteria andCreatorLessThan(String value) {
            addCriterion("creator <", value, "creator");
            return (Criteria) this;
        }

        public Criteria andCreatorLessThanOrEqualTo(String value) {
            addCriterion("creator <=", value, "creator");
            return (Criteria) this;
        }

        public Criteria andCreatorLike(String value) {
            addCriterion("creator like", value, "creator");
            return (Criteria) this;
        }

        public Criteria andCreatorNotLike(String value) {
            addCriterion("creator not like", value, "creator");
            return (Criteria) this;
        }

        public Criteria andCreatorIn(List<String> values) {
            addCriterion("creator in", values, "creator");
            return (Criteria) this;
        }

        public Criteria andCreatorNotIn(List<String> values) {
            addCriterion("creator not in", values, "creator");
            return (Criteria) this;
        }

        public Criteria andCreatorBetween(String value1, String value2) {
            addCriterion("creator between", value1, value2, "creator");
            return (Criteria) this;
        }

        public Criteria andCreatorNotBetween(String value1, String value2) {
            addCriterion("creator not between", value1, value2, "creator");
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