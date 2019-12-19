//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.domain.example;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.linlinjava.litemall.db.domain.Skilljineng.Column;
import org.linlinjava.litemall.db.domain.Skilljineng.Deleted;

public class SkilljinengExample {
    protected String orderByClause;
    protected boolean distinct;
    protected List<SkilljinengExample.Criteria> oredCriteria = new ArrayList();

    public SkilljinengExample() {
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

    public List<SkilljinengExample.Criteria> getOredCriteria() {
        return this.oredCriteria;
    }

    public void or(SkilljinengExample.Criteria criteria) {
        this.oredCriteria.add(criteria);
    }

    public SkilljinengExample.Criteria or() {
        SkilljinengExample.Criteria criteria = this.createCriteriaInternal();
        this.oredCriteria.add(criteria);
        return criteria;
    }

    public SkilljinengExample orderBy(String orderByClause) {
        this.setOrderByClause(orderByClause);
        return this;
    }

    public SkilljinengExample orderBy(String... orderByClauses) {
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

    public SkilljinengExample.Criteria createCriteria() {
        SkilljinengExample.Criteria criteria = this.createCriteriaInternal();
        if (this.oredCriteria.size() == 0) {
            this.oredCriteria.add(criteria);
        }

        return criteria;
    }

    protected SkilljinengExample.Criteria createCriteriaInternal() {
        SkilljinengExample.Criteria criteria = new SkilljinengExample.Criteria(this);
        return criteria;
    }

    public void clear() {
        this.oredCriteria.clear();
        this.orderByClause = null;
        this.distinct = false;
    }

    public static SkilljinengExample.Criteria newAndCreateCriteria() {
        SkilljinengExample example = new SkilljinengExample();
        return example.createCriteria();
    }

    public SkilljinengExample when(boolean condition, SkilljinengExample.IExampleWhen then) {
        if (condition) {
            then.example(this);
        }

        return this;
    }

    public SkilljinengExample when(boolean condition, SkilljinengExample.IExampleWhen then, SkilljinengExample.IExampleWhen otherwise) {
        if (condition) {
            then.example(this);
        } else {
            otherwise.example(this);
        }

        return this;
    }

    public interface IExampleWhen {
        void example(SkilljinengExample example);
    }

    public interface ICriteriaWhen {
        void criteria(SkilljinengExample.Criteria criteria);
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

    public static class Criteria extends SkilljinengExample.GeneratedCriteria {
        private SkilljinengExample example;

        protected Criteria(SkilljinengExample example) {
            this.example = example;
        }

        public SkilljinengExample example() {
            return this.example;
        }

        /** @deprecated */
        @Deprecated
        public SkilljinengExample.Criteria andIf(boolean ifAdd, SkilljinengExample.Criteria.ICriteriaAdd add) {
            if (ifAdd) {
                add.add(this);
            }

            return this;
        }

        public SkilljinengExample.Criteria when(boolean condition, SkilljinengExample.ICriteriaWhen then) {
            if (condition) {
                then.criteria(this);
            }

            return this;
        }

        public SkilljinengExample.Criteria when(boolean condition, SkilljinengExample.ICriteriaWhen then, SkilljinengExample.ICriteriaWhen otherwise) {
            if (condition) {
                then.criteria(this);
            } else {
                otherwise.criteria(this);
            }

            return this;
        }

        public SkilljinengExample.Criteria andLogicalDeleted(boolean deleted) {
            return deleted ? this.andDeletedEqualTo(Deleted.IS_DELETED.value()) : this.andDeletedNotEqualTo(Deleted.IS_DELETED.value());
        }

        /** @deprecated */
        @Deprecated
        public interface ICriteriaAdd {
            SkilljinengExample.Criteria add(SkilljinengExample.Criteria add);
        }
    }

    protected abstract static class GeneratedCriteria {
        protected List<SkilljinengExample.Criterion> criteria = new ArrayList();

        protected GeneratedCriteria() {
        }

        public boolean isValid() {
            return this.criteria.size() > 0;
        }

        public List<SkilljinengExample.Criterion> getAllCriteria() {
            return this.criteria;
        }

        public List<SkilljinengExample.Criterion> getCriteria() {
            return this.criteria;
        }

        protected void addCriterion(String condition) {
            if (condition == null) {
                throw new RuntimeException("Value for condition cannot be null");
            } else {
                this.criteria.add(new SkilljinengExample.Criterion(condition));
            }
        }

        protected void addCriterion(String condition, Object value, String property) {
            if (value == null) {
                throw new RuntimeException("Value for " + property + " cannot be null");
            } else {
                this.criteria.add(new SkilljinengExample.Criterion(condition, value));
            }
        }

        protected void addCriterion(String condition, Object value1, Object value2, String property) {
            if (value1 != null && value2 != null) {
                this.criteria.add(new SkilljinengExample.Criterion(condition, value1, value2));
            } else {
                throw new RuntimeException("Between values for " + property + " cannot be null");
            }
        }

        public SkilljinengExample.Criteria andIdIsNull() {
            this.addCriterion("id is null");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andIdIsNotNull() {
            this.addCriterion("id is not null");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andIdEqualTo(Integer value) {
            this.addCriterion("id =", value, "id");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andIdEqualToColumn(Column column) {
            this.addCriterion("id = " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andIdNotEqualTo(Integer value) {
            this.addCriterion("id <>", value, "id");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andIdNotEqualToColumn(Column column) {
            this.addCriterion("id <> " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andIdGreaterThan(Integer value) {
            this.addCriterion("id >", value, "id");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andIdGreaterThanColumn(Column column) {
            this.addCriterion("id > " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andIdGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("id >=", value, "id");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andIdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("id >= " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andIdLessThan(Integer value) {
            this.addCriterion("id <", value, "id");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andIdLessThanColumn(Column column) {
            this.addCriterion("id < " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andIdLessThanOrEqualTo(Integer value) {
            this.addCriterion("id <=", value, "id");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andIdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("id <= " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andIdIn(List<Integer> values) {
            this.addCriterion("id in", values, "id");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andIdNotIn(List<Integer> values) {
            this.addCriterion("id not in", values, "id");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andIdBetween(Integer value1, Integer value2) {
            this.addCriterion("id between", value1, value2, "id");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andIdNotBetween(Integer value1, Integer value2) {
            this.addCriterion("id not between", value1, value2, "id");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andRidIsNull() {
            this.addCriterion("rid is null");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andRidIsNotNull() {
            this.addCriterion("rid is not null");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andRidEqualTo(Integer value) {
            this.addCriterion("rid =", value, "rid");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andRidEqualToColumn(Column column) {
            this.addCriterion("rid = " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andRidNotEqualTo(Integer value) {
            this.addCriterion("rid <>", value, "rid");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andRidNotEqualToColumn(Column column) {
            this.addCriterion("rid <> " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andRidGreaterThan(Integer value) {
            this.addCriterion("rid >", value, "rid");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andRidGreaterThanColumn(Column column) {
            this.addCriterion("rid > " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andRidGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("rid >=", value, "rid");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andRidGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("rid >= " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andRidLessThan(Integer value) {
            this.addCriterion("rid <", value, "rid");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andRidLessThanColumn(Column column) {
            this.addCriterion("rid < " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andRidLessThanOrEqualTo(Integer value) {
            this.addCriterion("rid <=", value, "rid");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andRidLessThanOrEqualToColumn(Column column) {
            this.addCriterion("rid <= " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andRidIn(List<Integer> values) {
            this.addCriterion("rid in", values, "rid");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andRidNotIn(List<Integer> values) {
            this.addCriterion("rid not in", values, "rid");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andRidBetween(Integer value1, Integer value2) {
            this.addCriterion("rid between", value1, value2, "rid");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andRidNotBetween(Integer value1, Integer value2) {
            this.addCriterion("rid not between", value1, value2, "rid");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andPidIsNull() {
            this.addCriterion("pid is null");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andPidIsNotNull() {
            this.addCriterion("pid is not null");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andPidEqualTo(String value) {
            this.addCriterion("pid =", value, "pid");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andPidEqualToColumn(Column column) {
            this.addCriterion("pid = " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andPidNotEqualTo(String value) {
            this.addCriterion("pid <>", value, "pid");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andPidNotEqualToColumn(Column column) {
            this.addCriterion("pid <> " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andPidGreaterThan(String value) {
            this.addCriterion("pid >", value, "pid");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andPidGreaterThanColumn(Column column) {
            this.addCriterion("pid > " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andPidGreaterThanOrEqualTo(String value) {
            this.addCriterion("pid >=", value, "pid");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andPidGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("pid >= " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andPidLessThan(String value) {
            this.addCriterion("pid <", value, "pid");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andPidLessThanColumn(Column column) {
            this.addCriterion("pid < " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andPidLessThanOrEqualTo(String value) {
            this.addCriterion("pid <=", value, "pid");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andPidLessThanOrEqualToColumn(Column column) {
            this.addCriterion("pid <= " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andPidLike(String value) {
            this.addCriterion("pid like", value, "pid");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andPidNotLike(String value) {
            this.addCriterion("pid not like", value, "pid");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andPidIn(List<String> values) {
            this.addCriterion("pid in", values, "pid");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andPidNotIn(List<String> values) {
            this.addCriterion("pid not in", values, "pid");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andPidBetween(String value1, String value2) {
            this.addCriterion("pid between", value1, value2, "pid");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andPidNotBetween(String value1, String value2) {
            this.addCriterion("pid not between", value1, value2, "pid");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillNameIsNull() {
            this.addCriterion("skill_name is null");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillNameIsNotNull() {
            this.addCriterion("skill_name is not null");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillNameEqualTo(String value) {
            this.addCriterion("skill_name =", value, "skillName");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillNameEqualToColumn(Column column) {
            this.addCriterion("skill_name = " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillNameNotEqualTo(String value) {
            this.addCriterion("skill_name <>", value, "skillName");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillNameNotEqualToColumn(Column column) {
            this.addCriterion("skill_name <> " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillNameGreaterThan(String value) {
            this.addCriterion("skill_name >", value, "skillName");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillNameGreaterThanColumn(Column column) {
            this.addCriterion("skill_name > " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillNameGreaterThanOrEqualTo(String value) {
            this.addCriterion("skill_name >=", value, "skillName");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillNameGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_name >= " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillNameLessThan(String value) {
            this.addCriterion("skill_name <", value, "skillName");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillNameLessThanColumn(Column column) {
            this.addCriterion("skill_name < " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillNameLessThanOrEqualTo(String value) {
            this.addCriterion("skill_name <=", value, "skillName");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillNameLessThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_name <= " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillNameLike(String value) {
            this.addCriterion("skill_name like", value, "skillName");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillNameNotLike(String value) {
            this.addCriterion("skill_name not like", value, "skillName");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillNameIn(List<String> values) {
            this.addCriterion("skill_name in", values, "skillName");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillNameNotIn(List<String> values) {
            this.addCriterion("skill_name not in", values, "skillName");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillNameBetween(String value1, String value2) {
            this.addCriterion("skill_name between", value1, value2, "skillName");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillNameNotBetween(String value1, String value2) {
            this.addCriterion("skill_name not between", value1, value2, "skillName");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillLevelIsNull() {
            this.addCriterion("skill_level is null");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillLevelIsNotNull() {
            this.addCriterion("skill_level is not null");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillLevelEqualTo(Integer value) {
            this.addCriterion("skill_level =", value, "skillLevel");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillLevelEqualToColumn(Column column) {
            this.addCriterion("skill_level = " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillLevelNotEqualTo(Integer value) {
            this.addCriterion("skill_level <>", value, "skillLevel");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillLevelNotEqualToColumn(Column column) {
            this.addCriterion("skill_level <> " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillLevelGreaterThan(Integer value) {
            this.addCriterion("skill_level >", value, "skillLevel");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillLevelGreaterThanColumn(Column column) {
            this.addCriterion("skill_level > " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillLevelGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("skill_level >=", value, "skillLevel");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillLevelGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_level >= " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillLevelLessThan(Integer value) {
            this.addCriterion("skill_level <", value, "skillLevel");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillLevelLessThanColumn(Column column) {
            this.addCriterion("skill_level < " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillLevelLessThanOrEqualTo(Integer value) {
            this.addCriterion("skill_level <=", value, "skillLevel");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillLevelLessThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_level <= " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillLevelIn(List<Integer> values) {
            this.addCriterion("skill_level in", values, "skillLevel");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillLevelNotIn(List<Integer> values) {
            this.addCriterion("skill_level not in", values, "skillLevel");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillLevelBetween(Integer value1, Integer value2) {
            this.addCriterion("skill_level between", value1, value2, "skillLevel");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillLevelNotBetween(Integer value1, Integer value2) {
            this.addCriterion("skill_level not between", value1, value2, "skillLevel");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillMubiaoIsNull() {
            this.addCriterion("skill_mubiao is null");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillMubiaoIsNotNull() {
            this.addCriterion("skill_mubiao is not null");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillMubiaoEqualTo(Integer value) {
            this.addCriterion("skill_mubiao =", value, "skillMubiao");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillMubiaoEqualToColumn(Column column) {
            this.addCriterion("skill_mubiao = " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillMubiaoNotEqualTo(Integer value) {
            this.addCriterion("skill_mubiao <>", value, "skillMubiao");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillMubiaoNotEqualToColumn(Column column) {
            this.addCriterion("skill_mubiao <> " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillMubiaoGreaterThan(Integer value) {
            this.addCriterion("skill_mubiao >", value, "skillMubiao");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillMubiaoGreaterThanColumn(Column column) {
            this.addCriterion("skill_mubiao > " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillMubiaoGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("skill_mubiao >=", value, "skillMubiao");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillMubiaoGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_mubiao >= " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillMubiaoLessThan(Integer value) {
            this.addCriterion("skill_mubiao <", value, "skillMubiao");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillMubiaoLessThanColumn(Column column) {
            this.addCriterion("skill_mubiao < " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillMubiaoLessThanOrEqualTo(Integer value) {
            this.addCriterion("skill_mubiao <=", value, "skillMubiao");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillMubiaoLessThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_mubiao <= " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillMubiaoIn(List<Integer> values) {
            this.addCriterion("skill_mubiao in", values, "skillMubiao");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillMubiaoNotIn(List<Integer> values) {
            this.addCriterion("skill_mubiao not in", values, "skillMubiao");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillMubiaoBetween(Integer value1, Integer value2) {
            this.addCriterion("skill_mubiao between", value1, value2, "skillMubiao");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillMubiaoNotBetween(Integer value1, Integer value2) {
            this.addCriterion("skill_mubiao not between", value1, value2, "skillMubiao");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillMpIsNull() {
            this.addCriterion("skill_mp is null");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillMpIsNotNull() {
            this.addCriterion("skill_mp is not null");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillMpEqualTo(Integer value) {
            this.addCriterion("skill_mp =", value, "skillMp");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillMpEqualToColumn(Column column) {
            this.addCriterion("skill_mp = " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillMpNotEqualTo(Integer value) {
            this.addCriterion("skill_mp <>", value, "skillMp");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillMpNotEqualToColumn(Column column) {
            this.addCriterion("skill_mp <> " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillMpGreaterThan(Integer value) {
            this.addCriterion("skill_mp >", value, "skillMp");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillMpGreaterThanColumn(Column column) {
            this.addCriterion("skill_mp > " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillMpGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("skill_mp >=", value, "skillMp");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillMpGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_mp >= " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillMpLessThan(Integer value) {
            this.addCriterion("skill_mp <", value, "skillMp");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillMpLessThanColumn(Column column) {
            this.addCriterion("skill_mp < " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillMpLessThanOrEqualTo(Integer value) {
            this.addCriterion("skill_mp <=", value, "skillMp");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillMpLessThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_mp <= " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillMpIn(List<Integer> values) {
            this.addCriterion("skill_mp in", values, "skillMp");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillMpNotIn(List<Integer> values) {
            this.addCriterion("skill_mp not in", values, "skillMp");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillMpBetween(Integer value1, Integer value2) {
            this.addCriterion("skill_mp between", value1, value2, "skillMp");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andSkillMpNotBetween(Integer value1, Integer value2) {
            this.addCriterion("skill_mp not between", value1, value2, "skillMp");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andAddTimeIsNull() {
            this.addCriterion("add_time is null");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andAddTimeIsNotNull() {
            this.addCriterion("add_time is not null");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andAddTimeEqualTo(LocalDateTime value) {
            this.addCriterion("add_time =", value, "addTime");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andAddTimeEqualToColumn(Column column) {
            this.addCriterion("add_time = " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andAddTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <>", value, "addTime");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andAddTimeNotEqualToColumn(Column column) {
            this.addCriterion("add_time <> " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andAddTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("add_time >", value, "addTime");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andAddTimeGreaterThanColumn(Column column) {
            this.addCriterion("add_time > " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andAddTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time >=", value, "addTime");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andAddTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time >= " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andAddTimeLessThan(LocalDateTime value) {
            this.addCriterion("add_time <", value, "addTime");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andAddTimeLessThanColumn(Column column) {
            this.addCriterion("add_time < " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andAddTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <=", value, "addTime");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andAddTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time <= " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andAddTimeIn(List<LocalDateTime> values) {
            this.addCriterion("add_time in", values, "addTime");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andAddTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("add_time not in", values, "addTime");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andAddTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time between", value1, value2, "addTime");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andAddTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time not between", value1, value2, "addTime");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andUpdateTimeIsNull() {
            this.addCriterion("update_time is null");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andUpdateTimeIsNotNull() {
            this.addCriterion("update_time is not null");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andUpdateTimeEqualTo(LocalDateTime value) {
            this.addCriterion("update_time =", value, "updateTime");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andUpdateTimeEqualToColumn(Column column) {
            this.addCriterion("update_time = " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andUpdateTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <>", value, "updateTime");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andUpdateTimeNotEqualToColumn(Column column) {
            this.addCriterion("update_time <> " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andUpdateTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("update_time >", value, "updateTime");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andUpdateTimeGreaterThanColumn(Column column) {
            this.addCriterion("update_time > " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andUpdateTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time >=", value, "updateTime");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andUpdateTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time >= " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andUpdateTimeLessThan(LocalDateTime value) {
            this.addCriterion("update_time <", value, "updateTime");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andUpdateTimeLessThanColumn(Column column) {
            this.addCriterion("update_time < " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andUpdateTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <=", value, "updateTime");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andUpdateTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time <= " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andUpdateTimeIn(List<LocalDateTime> values) {
            this.addCriterion("update_time in", values, "updateTime");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andUpdateTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("update_time not in", values, "updateTime");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andUpdateTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time between", value1, value2, "updateTime");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andUpdateTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time not between", value1, value2, "updateTime");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andDeletedIsNull() {
            this.addCriterion("deleted is null");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andDeletedIsNotNull() {
            this.addCriterion("deleted is not null");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andDeletedEqualTo(Boolean value) {
            this.addCriterion("deleted =", value, "deleted");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andDeletedEqualToColumn(Column column) {
            this.addCriterion("deleted = " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andDeletedNotEqualTo(Boolean value) {
            this.addCriterion("deleted <>", value, "deleted");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andDeletedNotEqualToColumn(Column column) {
            this.addCriterion("deleted <> " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andDeletedGreaterThan(Boolean value) {
            this.addCriterion("deleted >", value, "deleted");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andDeletedGreaterThanColumn(Column column) {
            this.addCriterion("deleted > " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andDeletedGreaterThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted >=", value, "deleted");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andDeletedGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted >= " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andDeletedLessThan(Boolean value) {
            this.addCriterion("deleted <", value, "deleted");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andDeletedLessThanColumn(Column column) {
            this.addCriterion("deleted < " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andDeletedLessThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted <=", value, "deleted");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andDeletedLessThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted <= " + column.getEscapedColumnName());
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andDeletedIn(List<Boolean> values) {
            this.addCriterion("deleted in", values, "deleted");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andDeletedNotIn(List<Boolean> values) {
            this.addCriterion("deleted not in", values, "deleted");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andDeletedBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted between", value1, value2, "deleted");
            return (SkilljinengExample.Criteria)this;
        }

        public SkilljinengExample.Criteria andDeletedNotBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted not between", value1, value2, "deleted");
            return (SkilljinengExample.Criteria)this;
        }
    }
}
