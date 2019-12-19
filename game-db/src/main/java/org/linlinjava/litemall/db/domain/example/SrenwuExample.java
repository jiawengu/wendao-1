//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.domain.example;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.linlinjava.litemall.db.domain.Srenwu.Column;
import org.linlinjava.litemall.db.domain.Srenwu.Deleted;

public class SrenwuExample {
    protected String orderByClause;
    protected boolean distinct;
    protected List<SrenwuExample.Criteria> oredCriteria = new ArrayList();

    public SrenwuExample() {
    }

    public void setOrderByClause(String orderByClause) {
        this.orderByClause = orderByClause;
    }

    public String getOrderByClause() {
        return this.orderByClause;
    }

    public void setDistinct(boolean distinct) {
        this.distinct = distinct;
    }

    public boolean isDistinct() {
        return this.distinct;
    }

    public List<SrenwuExample.Criteria> getOredCriteria() {
        return this.oredCriteria;
    }

    public void or(SrenwuExample.Criteria criteria) {
        this.oredCriteria.add(criteria);
    }

    public SrenwuExample.Criteria or() {
        SrenwuExample.Criteria criteria = this.createCriteriaInternal();
        this.oredCriteria.add(criteria);
        return criteria;
    }

    public SrenwuExample orderBy(String orderByClause) {
        this.setOrderByClause(orderByClause);
        return this;
    }

    public SrenwuExample orderBy(String... orderByClauses) {
        StringBuffer sb = new StringBuffer();

        for(int i = 0; i < orderByClauses.length; ++i) {
            sb.append(orderByClauses[i]);
            if (i < orderByClauses.length - 1) {
                sb.append(" , ");
            }
        }

        this.setOrderByClause(sb.toString());
        return this;
    }

    public SrenwuExample.Criteria createCriteria() {
        SrenwuExample.Criteria criteria = this.createCriteriaInternal();
        if (this.oredCriteria.size() == 0) {
            this.oredCriteria.add(criteria);
        }

        return criteria;
    }

    protected SrenwuExample.Criteria createCriteriaInternal() {
        SrenwuExample.Criteria criteria = new SrenwuExample.Criteria(this);
        return criteria;
    }

    public void clear() {
        this.oredCriteria.clear();
        this.orderByClause = null;
        this.distinct = false;
    }

    public static SrenwuExample.Criteria newAndCreateCriteria() {
        SrenwuExample example = new SrenwuExample();
        return example.createCriteria();
    }

    public SrenwuExample when(boolean condition, SrenwuExample.IExampleWhen then) {
        if (condition) {
            then.example(this);
        }

        return this;
    }

    public SrenwuExample when(boolean condition, SrenwuExample.IExampleWhen then, SrenwuExample.IExampleWhen otherwise) {
        if (condition) {
            then.example(this);
        } else {
            otherwise.example(this);
        }

        return this;
    }

    public interface IExampleWhen {
        void example(SrenwuExample example);
    }

    public interface ICriteriaWhen {
        void criteria(SrenwuExample.Criteria criteria);
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
            return this.condition;
        }

        public Object getValue() {
            return this.value;
        }

        public Object getSecondValue() {
            return this.secondValue;
        }

        public boolean isNoValue() {
            return this.noValue;
        }

        public boolean isSingleValue() {
            return this.singleValue;
        }

        public boolean isBetweenValue() {
            return this.betweenValue;
        }

        public boolean isListValue() {
            return this.listValue;
        }

        public String getTypeHandler() {
            return this.typeHandler;
        }

        protected Criterion(String condition) {
            this.condition = condition;
            this.typeHandler = null;
            this.noValue = true;
        }

        protected Criterion(String condition, Object value, String typeHandler) {
            this.condition = condition;
            this.value = value;
            this.typeHandler = typeHandler;
            if (value instanceof List) {
                this.listValue = true;
            } else {
                this.singleValue = true;
            }

        }

        protected Criterion(String condition, Object value) {
            this(condition, value, (String)null);
        }

        protected Criterion(String condition, Object value, Object secondValue, String typeHandler) {
            this.condition = condition;
            this.value = value;
            this.secondValue = secondValue;
            this.typeHandler = typeHandler;
            this.betweenValue = true;
        }

        protected Criterion(String condition, Object value, Object secondValue) {
            this(condition, value, secondValue, (String)null);
        }
    }

    public static class Criteria extends SrenwuExample.GeneratedCriteria {
        private SrenwuExample example;

        protected Criteria(SrenwuExample example) {
            this.example = example;
        }

        public SrenwuExample example() {
            return this.example;
        }

        /** @deprecated */
        @Deprecated
        public SrenwuExample.Criteria andIf(boolean ifAdd, SrenwuExample.Criteria.ICriteriaAdd add) {
            if (ifAdd) {
                add.add(this);
            }

            return this;
        }

        public SrenwuExample.Criteria when(boolean condition, SrenwuExample.ICriteriaWhen then) {
            if (condition) {
                then.criteria(this);
            }

            return this;
        }

        public SrenwuExample.Criteria when(boolean condition, SrenwuExample.ICriteriaWhen then, SrenwuExample.ICriteriaWhen otherwise) {
            if (condition) {
                then.criteria(this);
            } else {
                otherwise.criteria(this);
            }

            return this;
        }

        public SrenwuExample.Criteria andLogicalDeleted(boolean deleted) {
            return deleted ? this.andDeletedEqualTo(Deleted.IS_DELETED.value()) : this.andDeletedNotEqualTo(Deleted.IS_DELETED.value());
        }

        /** @deprecated */
        @Deprecated
        public interface ICriteriaAdd {
            SrenwuExample.Criteria add(SrenwuExample.Criteria add);
        }
    }

    protected abstract static class GeneratedCriteria {
        protected List<SrenwuExample.Criterion> criteria = new ArrayList();

        protected GeneratedCriteria() {
        }

        public boolean isValid() {
            return this.criteria.size() > 0;
        }

        public List<SrenwuExample.Criterion> getAllCriteria() {
            return this.criteria;
        }

        public List<SrenwuExample.Criterion> getCriteria() {
            return this.criteria;
        }

        protected void addCriterion(String condition) {
            if (condition == null) {
                throw new RuntimeException("Value for condition cannot be null");
            } else {
                this.criteria.add(new SrenwuExample.Criterion(condition));
            }
        }

        protected void addCriterion(String condition, Object value, String property) {
            if (value == null) {
                throw new RuntimeException("Value for " + property + " cannot be null");
            } else {
                this.criteria.add(new SrenwuExample.Criterion(condition, value));
            }
        }

        protected void addCriterion(String condition, Object value1, Object value2, String property) {
            if (value1 != null && value2 != null) {
                this.criteria.add(new SrenwuExample.Criterion(condition, value1, value2));
            } else {
                throw new RuntimeException("Between values for " + property + " cannot be null");
            }
        }

        public SrenwuExample.Criteria andIdIsNull() {
            this.addCriterion("id is null");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andIdIsNotNull() {
            this.addCriterion("id is not null");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andIdEqualTo(Integer value) {
            this.addCriterion("id =", value, "id");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andIdEqualToColumn(Column column) {
            this.addCriterion("id = " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andIdNotEqualTo(Integer value) {
            this.addCriterion("id <>", value, "id");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andIdNotEqualToColumn(Column column) {
            this.addCriterion("id <> " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andIdGreaterThan(Integer value) {
            this.addCriterion("id >", value, "id");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andIdGreaterThanColumn(Column column) {
            this.addCriterion("id > " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andIdGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("id >=", value, "id");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andIdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("id >= " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andIdLessThan(Integer value) {
            this.addCriterion("id <", value, "id");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andIdLessThanColumn(Column column) {
            this.addCriterion("id < " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andIdLessThanOrEqualTo(Integer value) {
            this.addCriterion("id <=", value, "id");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andIdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("id <= " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andIdIn(List<Integer> values) {
            this.addCriterion("id in", values, "id");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andIdNotIn(List<Integer> values) {
            this.addCriterion("id not in", values, "id");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andIdBetween(Integer value1, Integer value2) {
            this.addCriterion("id between", value1, value2, "id");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andIdNotBetween(Integer value1, Integer value2) {
            this.addCriterion("id not between", value1, value2, "id");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andPidIsNull() {
            this.addCriterion("pid is null");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andPidIsNotNull() {
            this.addCriterion("pid is not null");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andPidEqualTo(String value) {
            this.addCriterion("pid =", value, "pid");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andPidEqualToColumn(Column column) {
            this.addCriterion("pid = " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andPidNotEqualTo(String value) {
            this.addCriterion("pid <>", value, "pid");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andPidNotEqualToColumn(Column column) {
            this.addCriterion("pid <> " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andPidGreaterThan(String value) {
            this.addCriterion("pid >", value, "pid");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andPidGreaterThanColumn(Column column) {
            this.addCriterion("pid > " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andPidGreaterThanOrEqualTo(String value) {
            this.addCriterion("pid >=", value, "pid");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andPidGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("pid >= " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andPidLessThan(String value) {
            this.addCriterion("pid <", value, "pid");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andPidLessThanColumn(Column column) {
            this.addCriterion("pid < " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andPidLessThanOrEqualTo(String value) {
            this.addCriterion("pid <=", value, "pid");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andPidLessThanOrEqualToColumn(Column column) {
            this.addCriterion("pid <= " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andPidLike(String value) {
            this.addCriterion("pid like", value, "pid");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andPidNotLike(String value) {
            this.addCriterion("pid not like", value, "pid");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andPidIn(List<String> values) {
            this.addCriterion("pid in", values, "pid");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andPidNotIn(List<String> values) {
            this.addCriterion("pid not in", values, "pid");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andPidBetween(String value1, String value2) {
            this.addCriterion("pid between", value1, value2, "pid");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andPidNotBetween(String value1, String value2) {
            this.addCriterion("pid not between", value1, value2, "pid");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andRidIsNull() {
            this.addCriterion("rid is null");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andRidIsNotNull() {
            this.addCriterion("rid is not null");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andRidEqualTo(Integer value) {
            this.addCriterion("rid =", value, "rid");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andRidEqualToColumn(Column column) {
            this.addCriterion("rid = " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andRidNotEqualTo(Integer value) {
            this.addCriterion("rid <>", value, "rid");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andRidNotEqualToColumn(Column column) {
            this.addCriterion("rid <> " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andRidGreaterThan(Integer value) {
            this.addCriterion("rid >", value, "rid");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andRidGreaterThanColumn(Column column) {
            this.addCriterion("rid > " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andRidGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("rid >=", value, "rid");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andRidGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("rid >= " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andRidLessThan(Integer value) {
            this.addCriterion("rid <", value, "rid");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andRidLessThanColumn(Column column) {
            this.addCriterion("rid < " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andRidLessThanOrEqualTo(Integer value) {
            this.addCriterion("rid <=", value, "rid");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andRidLessThanOrEqualToColumn(Column column) {
            this.addCriterion("rid <= " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andRidIn(List<Integer> values) {
            this.addCriterion("rid in", values, "rid");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andRidNotIn(List<Integer> values) {
            this.addCriterion("rid not in", values, "rid");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andRidBetween(Integer value1, Integer value2) {
            this.addCriterion("rid between", value1, value2, "rid");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andRidNotBetween(Integer value1, Integer value2) {
            this.addCriterion("rid not between", value1, value2, "rid");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillNameIsNull() {
            this.addCriterion("skill_name is null");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillNameIsNotNull() {
            this.addCriterion("skill_name is not null");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillNameEqualTo(String value) {
            this.addCriterion("skill_name =", value, "skillName");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillNameEqualToColumn(Column column) {
            this.addCriterion("skill_name = " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillNameNotEqualTo(String value) {
            this.addCriterion("skill_name <>", value, "skillName");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillNameNotEqualToColumn(Column column) {
            this.addCriterion("skill_name <> " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillNameGreaterThan(String value) {
            this.addCriterion("skill_name >", value, "skillName");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillNameGreaterThanColumn(Column column) {
            this.addCriterion("skill_name > " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillNameGreaterThanOrEqualTo(String value) {
            this.addCriterion("skill_name >=", value, "skillName");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillNameGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_name >= " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillNameLessThan(String value) {
            this.addCriterion("skill_name <", value, "skillName");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillNameLessThanColumn(Column column) {
            this.addCriterion("skill_name < " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillNameLessThanOrEqualTo(String value) {
            this.addCriterion("skill_name <=", value, "skillName");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillNameLessThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_name <= " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillNameLike(String value) {
            this.addCriterion("skill_name like", value, "skillName");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillNameNotLike(String value) {
            this.addCriterion("skill_name not like", value, "skillName");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillNameIn(List<String> values) {
            this.addCriterion("skill_name in", values, "skillName");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillNameNotIn(List<String> values) {
            this.addCriterion("skill_name not in", values, "skillName");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillNameBetween(String value1, String value2) {
            this.addCriterion("skill_name between", value1, value2, "skillName");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillNameNotBetween(String value1, String value2) {
            this.addCriterion("skill_name not between", value1, value2, "skillName");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillJieshaoIsNull() {
            this.addCriterion("skill_jieshao is null");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillJieshaoIsNotNull() {
            this.addCriterion("skill_jieshao is not null");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillJieshaoEqualTo(String value) {
            this.addCriterion("skill_jieshao =", value, "skillJieshao");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillJieshaoEqualToColumn(Column column) {
            this.addCriterion("skill_jieshao = " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillJieshaoNotEqualTo(String value) {
            this.addCriterion("skill_jieshao <>", value, "skillJieshao");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillJieshaoNotEqualToColumn(Column column) {
            this.addCriterion("skill_jieshao <> " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillJieshaoGreaterThan(String value) {
            this.addCriterion("skill_jieshao >", value, "skillJieshao");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillJieshaoGreaterThanColumn(Column column) {
            this.addCriterion("skill_jieshao > " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillJieshaoGreaterThanOrEqualTo(String value) {
            this.addCriterion("skill_jieshao >=", value, "skillJieshao");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillJieshaoGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_jieshao >= " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillJieshaoLessThan(String value) {
            this.addCriterion("skill_jieshao <", value, "skillJieshao");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillJieshaoLessThanColumn(Column column) {
            this.addCriterion("skill_jieshao < " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillJieshaoLessThanOrEqualTo(String value) {
            this.addCriterion("skill_jieshao <=", value, "skillJieshao");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillJieshaoLessThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_jieshao <= " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillJieshaoLike(String value) {
            this.addCriterion("skill_jieshao like", value, "skillJieshao");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillJieshaoNotLike(String value) {
            this.addCriterion("skill_jieshao not like", value, "skillJieshao");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillJieshaoIn(List<String> values) {
            this.addCriterion("skill_jieshao in", values, "skillJieshao");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillJieshaoNotIn(List<String> values) {
            this.addCriterion("skill_jieshao not in", values, "skillJieshao");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillJieshaoBetween(String value1, String value2) {
            this.addCriterion("skill_jieshao between", value1, value2, "skillJieshao");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillJieshaoNotBetween(String value1, String value2) {
            this.addCriterion("skill_jieshao not between", value1, value2, "skillJieshao");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillDqtiIsNull() {
            this.addCriterion("skill_dqti is null");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillDqtiIsNotNull() {
            this.addCriterion("skill_dqti is not null");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillDqtiEqualTo(String value) {
            this.addCriterion("skill_dqti =", value, "skillDqti");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillDqtiEqualToColumn(Column column) {
            this.addCriterion("skill_dqti = " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillDqtiNotEqualTo(String value) {
            this.addCriterion("skill_dqti <>", value, "skillDqti");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillDqtiNotEqualToColumn(Column column) {
            this.addCriterion("skill_dqti <> " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillDqtiGreaterThan(String value) {
            this.addCriterion("skill_dqti >", value, "skillDqti");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillDqtiGreaterThanColumn(Column column) {
            this.addCriterion("skill_dqti > " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillDqtiGreaterThanOrEqualTo(String value) {
            this.addCriterion("skill_dqti >=", value, "skillDqti");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillDqtiGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_dqti >= " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillDqtiLessThan(String value) {
            this.addCriterion("skill_dqti <", value, "skillDqti");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillDqtiLessThanColumn(Column column) {
            this.addCriterion("skill_dqti < " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillDqtiLessThanOrEqualTo(String value) {
            this.addCriterion("skill_dqti <=", value, "skillDqti");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillDqtiLessThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_dqti <= " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillDqtiLike(String value) {
            this.addCriterion("skill_dqti like", value, "skillDqti");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillDqtiNotLike(String value) {
            this.addCriterion("skill_dqti not like", value, "skillDqti");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillDqtiIn(List<String> values) {
            this.addCriterion("skill_dqti in", values, "skillDqti");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillDqtiNotIn(List<String> values) {
            this.addCriterion("skill_dqti not in", values, "skillDqti");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillDqtiBetween(String value1, String value2) {
            this.addCriterion("skill_dqti between", value1, value2, "skillDqti");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillDqtiNotBetween(String value1, String value2) {
            this.addCriterion("skill_dqti not between", value1, value2, "skillDqti");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillXckIsNull() {
            this.addCriterion("skill_xck is null");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillXckIsNotNull() {
            this.addCriterion("skill_xck is not null");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillXckEqualTo(String value) {
            this.addCriterion("skill_xck =", value, "skillXck");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillXckEqualToColumn(Column column) {
            this.addCriterion("skill_xck = " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillXckNotEqualTo(String value) {
            this.addCriterion("skill_xck <>", value, "skillXck");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillXckNotEqualToColumn(Column column) {
            this.addCriterion("skill_xck <> " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillXckGreaterThan(String value) {
            this.addCriterion("skill_xck >", value, "skillXck");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillXckGreaterThanColumn(Column column) {
            this.addCriterion("skill_xck > " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillXckGreaterThanOrEqualTo(String value) {
            this.addCriterion("skill_xck >=", value, "skillXck");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillXckGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_xck >= " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillXckLessThan(String value) {
            this.addCriterion("skill_xck <", value, "skillXck");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillXckLessThanColumn(Column column) {
            this.addCriterion("skill_xck < " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillXckLessThanOrEqualTo(String value) {
            this.addCriterion("skill_xck <=", value, "skillXck");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillXckLessThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_xck <= " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillXckLike(String value) {
            this.addCriterion("skill_xck like", value, "skillXck");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillXckNotLike(String value) {
            this.addCriterion("skill_xck not like", value, "skillXck");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillXckIn(List<String> values) {
            this.addCriterion("skill_xck in", values, "skillXck");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillXckNotIn(List<String> values) {
            this.addCriterion("skill_xck not in", values, "skillXck");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillXckBetween(String value1, String value2) {
            this.addCriterion("skill_xck between", value1, value2, "skillXck");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andSkillXckNotBetween(String value1, String value2) {
            this.addCriterion("skill_xck not between", value1, value2, "skillXck");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andAddTimeIsNull() {
            this.addCriterion("add_time is null");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andAddTimeIsNotNull() {
            this.addCriterion("add_time is not null");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andAddTimeEqualTo(LocalDateTime value) {
            this.addCriterion("add_time =", value, "addTime");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andAddTimeEqualToColumn(Column column) {
            this.addCriterion("add_time = " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andAddTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <>", value, "addTime");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andAddTimeNotEqualToColumn(Column column) {
            this.addCriterion("add_time <> " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andAddTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("add_time >", value, "addTime");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andAddTimeGreaterThanColumn(Column column) {
            this.addCriterion("add_time > " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andAddTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time >=", value, "addTime");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andAddTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time >= " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andAddTimeLessThan(LocalDateTime value) {
            this.addCriterion("add_time <", value, "addTime");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andAddTimeLessThanColumn(Column column) {
            this.addCriterion("add_time < " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andAddTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <=", value, "addTime");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andAddTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time <= " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andAddTimeIn(List<LocalDateTime> values) {
            this.addCriterion("add_time in", values, "addTime");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andAddTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("add_time not in", values, "addTime");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andAddTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time between", value1, value2, "addTime");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andAddTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time not between", value1, value2, "addTime");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andUpdateTimeIsNull() {
            this.addCriterion("update_time is null");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andUpdateTimeIsNotNull() {
            this.addCriterion("update_time is not null");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andUpdateTimeEqualTo(LocalDateTime value) {
            this.addCriterion("update_time =", value, "updateTime");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andUpdateTimeEqualToColumn(Column column) {
            this.addCriterion("update_time = " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andUpdateTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <>", value, "updateTime");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andUpdateTimeNotEqualToColumn(Column column) {
            this.addCriterion("update_time <> " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andUpdateTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("update_time >", value, "updateTime");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andUpdateTimeGreaterThanColumn(Column column) {
            this.addCriterion("update_time > " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andUpdateTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time >=", value, "updateTime");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andUpdateTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time >= " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andUpdateTimeLessThan(LocalDateTime value) {
            this.addCriterion("update_time <", value, "updateTime");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andUpdateTimeLessThanColumn(Column column) {
            this.addCriterion("update_time < " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andUpdateTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <=", value, "updateTime");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andUpdateTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time <= " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andUpdateTimeIn(List<LocalDateTime> values) {
            this.addCriterion("update_time in", values, "updateTime");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andUpdateTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("update_time not in", values, "updateTime");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andUpdateTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time between", value1, value2, "updateTime");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andUpdateTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time not between", value1, value2, "updateTime");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andDeletedIsNull() {
            this.addCriterion("deleted is null");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andDeletedIsNotNull() {
            this.addCriterion("deleted is not null");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andDeletedEqualTo(Boolean value) {
            this.addCriterion("deleted =", value, "deleted");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andDeletedEqualToColumn(Column column) {
            this.addCriterion("deleted = " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andDeletedNotEqualTo(Boolean value) {
            this.addCriterion("deleted <>", value, "deleted");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andDeletedNotEqualToColumn(Column column) {
            this.addCriterion("deleted <> " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andDeletedGreaterThan(Boolean value) {
            this.addCriterion("deleted >", value, "deleted");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andDeletedGreaterThanColumn(Column column) {
            this.addCriterion("deleted > " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andDeletedGreaterThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted >=", value, "deleted");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andDeletedGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted >= " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andDeletedLessThan(Boolean value) {
            this.addCriterion("deleted <", value, "deleted");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andDeletedLessThanColumn(Column column) {
            this.addCriterion("deleted < " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andDeletedLessThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted <=", value, "deleted");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andDeletedLessThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted <= " + column.getEscapedColumnName());
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andDeletedIn(List<Boolean> values) {
            this.addCriterion("deleted in", values, "deleted");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andDeletedNotIn(List<Boolean> values) {
            this.addCriterion("deleted not in", values, "deleted");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andDeletedBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted between", value1, value2, "deleted");
            return (SrenwuExample.Criteria)this;
        }

        public SrenwuExample.Criteria andDeletedNotBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted not between", value1, value2, "deleted");
            return (SrenwuExample.Criteria)this;
        }
    }
}
