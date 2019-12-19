//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.domain.example;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.linlinjava.litemall.db.domain.SkillsChongw.Column;
import org.linlinjava.litemall.db.domain.SkillsChongw.Deleted;

public class SkillsChongwExample {
    protected String orderByClause;
    protected boolean distinct;
    protected List<SkillsChongwExample.Criteria> oredCriteria = new ArrayList();

    public SkillsChongwExample() {
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

    public List<SkillsChongwExample.Criteria> getOredCriteria() {
        return this.oredCriteria;
    }

    public void or(SkillsChongwExample.Criteria criteria) {
        this.oredCriteria.add(criteria);
    }

    public SkillsChongwExample.Criteria or() {
        SkillsChongwExample.Criteria criteria = this.createCriteriaInternal();
        this.oredCriteria.add(criteria);
        return criteria;
    }

    public SkillsChongwExample orderBy(String orderByClause) {
        this.setOrderByClause(orderByClause);
        return this;
    }

    public SkillsChongwExample orderBy(String... orderByClauses) {
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

    public SkillsChongwExample.Criteria createCriteria() {
        SkillsChongwExample.Criteria criteria = this.createCriteriaInternal();
        if (this.oredCriteria.size() == 0) {
            this.oredCriteria.add(criteria);
        }

        return criteria;
    }

    protected SkillsChongwExample.Criteria createCriteriaInternal() {
        SkillsChongwExample.Criteria criteria = new SkillsChongwExample.Criteria(this);
        return criteria;
    }

    public void clear() {
        this.oredCriteria.clear();
        this.orderByClause = null;
        this.distinct = false;
    }

    public static SkillsChongwExample.Criteria newAndCreateCriteria() {
        SkillsChongwExample example = new SkillsChongwExample();
        return example.createCriteria();
    }

    public SkillsChongwExample when(boolean condition, SkillsChongwExample.IExampleWhen then) {
        if (condition) {
            then.example(this);
        }

        return this;
    }

    public SkillsChongwExample when(boolean condition, SkillsChongwExample.IExampleWhen then, SkillsChongwExample.IExampleWhen otherwise) {
        if (condition) {
            then.example(this);
        } else {
            otherwise.example(this);
        }

        return this;
    }

    public interface IExampleWhen {
        void example(SkillsChongwExample example);
    }

    public interface ICriteriaWhen {
        void criteria(SkillsChongwExample.Criteria criteria);
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

    public static class Criteria extends SkillsChongwExample.GeneratedCriteria {
        private SkillsChongwExample example;

        protected Criteria(SkillsChongwExample example) {
            this.example = example;
        }

        public SkillsChongwExample example() {
            return this.example;
        }

        /** @deprecated */
        @Deprecated
        public SkillsChongwExample.Criteria andIf(boolean ifAdd, SkillsChongwExample.Criteria.ICriteriaAdd add) {
            if (ifAdd) {
                add.add(this);
            }

            return this;
        }

        public SkillsChongwExample.Criteria when(boolean condition, SkillsChongwExample.ICriteriaWhen then) {
            if (condition) {
                then.criteria(this);
            }

            return this;
        }

        public SkillsChongwExample.Criteria when(boolean condition, SkillsChongwExample.ICriteriaWhen then, SkillsChongwExample.ICriteriaWhen otherwise) {
            if (condition) {
                then.criteria(this);
            } else {
                otherwise.criteria(this);
            }

            return this;
        }

        public SkillsChongwExample.Criteria andLogicalDeleted(boolean deleted) {
            return deleted ? this.andDeletedEqualTo(Deleted.IS_DELETED.value()) : this.andDeletedNotEqualTo(Deleted.IS_DELETED.value());
        }

        /** @deprecated */
        @Deprecated
        public interface ICriteriaAdd {
            SkillsChongwExample.Criteria add(SkillsChongwExample.Criteria add);
        }
    }

    protected abstract static class GeneratedCriteria {
        protected List<SkillsChongwExample.Criterion> criteria = new ArrayList();

        protected GeneratedCriteria() {
        }

        public boolean isValid() {
            return this.criteria.size() > 0;
        }

        public List<SkillsChongwExample.Criterion> getAllCriteria() {
            return this.criteria;
        }

        public List<SkillsChongwExample.Criterion> getCriteria() {
            return this.criteria;
        }

        protected void addCriterion(String condition) {
            if (condition == null) {
                throw new RuntimeException("Value for condition cannot be null");
            } else {
                this.criteria.add(new SkillsChongwExample.Criterion(condition));
            }
        }

        protected void addCriterion(String condition, Object value, String property) {
            if (value == null) {
                throw new RuntimeException("Value for " + property + " cannot be null");
            } else {
                this.criteria.add(new SkillsChongwExample.Criterion(condition, value));
            }
        }

        protected void addCriterion(String condition, Object value1, Object value2, String property) {
            if (value1 != null && value2 != null) {
                this.criteria.add(new SkillsChongwExample.Criterion(condition, value1, value2));
            } else {
                throw new RuntimeException("Between values for " + property + " cannot be null");
            }
        }

        public SkillsChongwExample.Criteria andIdIsNull() {
            this.addCriterion("id is null");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andIdIsNotNull() {
            this.addCriterion("id is not null");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andIdEqualTo(Integer value) {
            this.addCriterion("id =", value, "id");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andIdEqualToColumn(Column column) {
            this.addCriterion("id = " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andIdNotEqualTo(Integer value) {
            this.addCriterion("id <>", value, "id");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andIdNotEqualToColumn(Column column) {
            this.addCriterion("id <> " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andIdGreaterThan(Integer value) {
            this.addCriterion("id >", value, "id");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andIdGreaterThanColumn(Column column) {
            this.addCriterion("id > " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andIdGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("id >=", value, "id");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andIdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("id >= " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andIdLessThan(Integer value) {
            this.addCriterion("id <", value, "id");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andIdLessThanColumn(Column column) {
            this.addCriterion("id < " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andIdLessThanOrEqualTo(Integer value) {
            this.addCriterion("id <=", value, "id");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andIdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("id <= " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andIdIn(List<Integer> values) {
            this.addCriterion("id in", values, "id");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andIdNotIn(List<Integer> values) {
            this.addCriterion("id not in", values, "id");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andIdBetween(Integer value1, Integer value2) {
            this.addCriterion("id between", value1, value2, "id");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andIdNotBetween(Integer value1, Integer value2) {
            this.addCriterion("id not between", value1, value2, "id");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andOwneridIsNull() {
            this.addCriterion("ownerid is null");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andOwneridIsNotNull() {
            this.addCriterion("ownerid is not null");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andOwneridEqualTo(String value) {
            this.addCriterion("ownerid =", value, "ownerid");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andOwneridEqualToColumn(Column column) {
            this.addCriterion("ownerid = " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andOwneridNotEqualTo(String value) {
            this.addCriterion("ownerid <>", value, "ownerid");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andOwneridNotEqualToColumn(Column column) {
            this.addCriterion("ownerid <> " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andOwneridGreaterThan(String value) {
            this.addCriterion("ownerid >", value, "ownerid");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andOwneridGreaterThanColumn(Column column) {
            this.addCriterion("ownerid > " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andOwneridGreaterThanOrEqualTo(String value) {
            this.addCriterion("ownerid >=", value, "ownerid");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andOwneridGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("ownerid >= " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andOwneridLessThan(String value) {
            this.addCriterion("ownerid <", value, "ownerid");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andOwneridLessThanColumn(Column column) {
            this.addCriterion("ownerid < " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andOwneridLessThanOrEqualTo(String value) {
            this.addCriterion("ownerid <=", value, "ownerid");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andOwneridLessThanOrEqualToColumn(Column column) {
            this.addCriterion("ownerid <= " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andOwneridLike(String value) {
            this.addCriterion("ownerid like", value, "ownerid");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andOwneridNotLike(String value) {
            this.addCriterion("ownerid not like", value, "ownerid");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andOwneridIn(List<String> values) {
            this.addCriterion("ownerid in", values, "ownerid");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andOwneridNotIn(List<String> values) {
            this.addCriterion("ownerid not in", values, "ownerid");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andOwneridBetween(String value1, String value2) {
            this.addCriterion("ownerid between", value1, value2, "ownerid");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andOwneridNotBetween(String value1, String value2) {
            this.addCriterion("ownerid not between", value1, value2, "ownerid");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkllCwidIsNull() {
            this.addCriterion("skll_cwid is null");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkllCwidIsNotNull() {
            this.addCriterion("skll_cwid is not null");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkllCwidEqualTo(String value) {
            this.addCriterion("skll_cwid =", value, "skllCwid");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkllCwidEqualToColumn(Column column) {
            this.addCriterion("skll_cwid = " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkllCwidNotEqualTo(String value) {
            this.addCriterion("skll_cwid <>", value, "skllCwid");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkllCwidNotEqualToColumn(Column column) {
            this.addCriterion("skll_cwid <> " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkllCwidGreaterThan(String value) {
            this.addCriterion("skll_cwid >", value, "skllCwid");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkllCwidGreaterThanColumn(Column column) {
            this.addCriterion("skll_cwid > " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkllCwidGreaterThanOrEqualTo(String value) {
            this.addCriterion("skll_cwid >=", value, "skllCwid");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkllCwidGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("skll_cwid >= " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkllCwidLessThan(String value) {
            this.addCriterion("skll_cwid <", value, "skllCwid");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkllCwidLessThanColumn(Column column) {
            this.addCriterion("skll_cwid < " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkllCwidLessThanOrEqualTo(String value) {
            this.addCriterion("skll_cwid <=", value, "skllCwid");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkllCwidLessThanOrEqualToColumn(Column column) {
            this.addCriterion("skll_cwid <= " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkllCwidLike(String value) {
            this.addCriterion("skll_cwid like", value, "skllCwid");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkllCwidNotLike(String value) {
            this.addCriterion("skll_cwid not like", value, "skllCwid");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkllCwidIn(List<String> values) {
            this.addCriterion("skll_cwid in", values, "skllCwid");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkllCwidNotIn(List<String> values) {
            this.addCriterion("skll_cwid not in", values, "skllCwid");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkllCwidBetween(String value1, String value2) {
            this.addCriterion("skll_cwid between", value1, value2, "skllCwid");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkllCwidNotBetween(String value1, String value2) {
            this.addCriterion("skll_cwid not between", value1, value2, "skllCwid");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillIdHexIsNull() {
            this.addCriterion("skill_id_hex is null");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillIdHexIsNotNull() {
            this.addCriterion("skill_id_hex is not null");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillIdHexEqualTo(String value) {
            this.addCriterion("skill_id_hex =", value, "skillIdHex");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillIdHexEqualToColumn(Column column) {
            this.addCriterion("skill_id_hex = " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillIdHexNotEqualTo(String value) {
            this.addCriterion("skill_id_hex <>", value, "skillIdHex");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillIdHexNotEqualToColumn(Column column) {
            this.addCriterion("skill_id_hex <> " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillIdHexGreaterThan(String value) {
            this.addCriterion("skill_id_hex >", value, "skillIdHex");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillIdHexGreaterThanColumn(Column column) {
            this.addCriterion("skill_id_hex > " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillIdHexGreaterThanOrEqualTo(String value) {
            this.addCriterion("skill_id_hex >=", value, "skillIdHex");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillIdHexGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_id_hex >= " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillIdHexLessThan(String value) {
            this.addCriterion("skill_id_hex <", value, "skillIdHex");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillIdHexLessThanColumn(Column column) {
            this.addCriterion("skill_id_hex < " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillIdHexLessThanOrEqualTo(String value) {
            this.addCriterion("skill_id_hex <=", value, "skillIdHex");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillIdHexLessThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_id_hex <= " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillIdHexLike(String value) {
            this.addCriterion("skill_id_hex like", value, "skillIdHex");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillIdHexNotLike(String value) {
            this.addCriterion("skill_id_hex not like", value, "skillIdHex");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillIdHexIn(List<String> values) {
            this.addCriterion("skill_id_hex in", values, "skillIdHex");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillIdHexNotIn(List<String> values) {
            this.addCriterion("skill_id_hex not in", values, "skillIdHex");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillIdHexBetween(String value1, String value2) {
            this.addCriterion("skill_id_hex between", value1, value2, "skillIdHex");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillIdHexNotBetween(String value1, String value2) {
            this.addCriterion("skill_id_hex not between", value1, value2, "skillIdHex");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillNameIsNull() {
            this.addCriterion("skill_name is null");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillNameIsNotNull() {
            this.addCriterion("skill_name is not null");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillNameEqualTo(String value) {
            this.addCriterion("skill_name =", value, "skillName");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillNameEqualToColumn(Column column) {
            this.addCriterion("skill_name = " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillNameNotEqualTo(String value) {
            this.addCriterion("skill_name <>", value, "skillName");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillNameNotEqualToColumn(Column column) {
            this.addCriterion("skill_name <> " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillNameGreaterThan(String value) {
            this.addCriterion("skill_name >", value, "skillName");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillNameGreaterThanColumn(Column column) {
            this.addCriterion("skill_name > " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillNameGreaterThanOrEqualTo(String value) {
            this.addCriterion("skill_name >=", value, "skillName");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillNameGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_name >= " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillNameLessThan(String value) {
            this.addCriterion("skill_name <", value, "skillName");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillNameLessThanColumn(Column column) {
            this.addCriterion("skill_name < " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillNameLessThanOrEqualTo(String value) {
            this.addCriterion("skill_name <=", value, "skillName");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillNameLessThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_name <= " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillNameLike(String value) {
            this.addCriterion("skill_name like", value, "skillName");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillNameNotLike(String value) {
            this.addCriterion("skill_name not like", value, "skillName");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillNameIn(List<String> values) {
            this.addCriterion("skill_name in", values, "skillName");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillNameNotIn(List<String> values) {
            this.addCriterion("skill_name not in", values, "skillName");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillNameBetween(String value1, String value2) {
            this.addCriterion("skill_name between", value1, value2, "skillName");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillNameNotBetween(String value1, String value2) {
            this.addCriterion("skill_name not between", value1, value2, "skillName");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillReqMenpaiIsNull() {
            this.addCriterion("skill_req_menpai is null");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillReqMenpaiIsNotNull() {
            this.addCriterion("skill_req_menpai is not null");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillReqMenpaiEqualTo(Integer value) {
            this.addCriterion("skill_req_menpai =", value, "skillReqMenpai");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillReqMenpaiEqualToColumn(Column column) {
            this.addCriterion("skill_req_menpai = " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillReqMenpaiNotEqualTo(Integer value) {
            this.addCriterion("skill_req_menpai <>", value, "skillReqMenpai");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillReqMenpaiNotEqualToColumn(Column column) {
            this.addCriterion("skill_req_menpai <> " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillReqMenpaiGreaterThan(Integer value) {
            this.addCriterion("skill_req_menpai >", value, "skillReqMenpai");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillReqMenpaiGreaterThanColumn(Column column) {
            this.addCriterion("skill_req_menpai > " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillReqMenpaiGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("skill_req_menpai >=", value, "skillReqMenpai");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillReqMenpaiGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_req_menpai >= " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillReqMenpaiLessThan(Integer value) {
            this.addCriterion("skill_req_menpai <", value, "skillReqMenpai");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillReqMenpaiLessThanColumn(Column column) {
            this.addCriterion("skill_req_menpai < " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillReqMenpaiLessThanOrEqualTo(Integer value) {
            this.addCriterion("skill_req_menpai <=", value, "skillReqMenpai");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillReqMenpaiLessThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_req_menpai <= " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillReqMenpaiIn(List<Integer> values) {
            this.addCriterion("skill_req_menpai in", values, "skillReqMenpai");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillReqMenpaiNotIn(List<Integer> values) {
            this.addCriterion("skill_req_menpai not in", values, "skillReqMenpai");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillReqMenpaiBetween(Integer value1, Integer value2) {
            this.addCriterion("skill_req_menpai between", value1, value2, "skillReqMenpai");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillReqMenpaiNotBetween(Integer value1, Integer value2) {
            this.addCriterion("skill_req_menpai not between", value1, value2, "skillReqMenpai");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillLevelIsNull() {
            this.addCriterion("skill_level is null");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillLevelIsNotNull() {
            this.addCriterion("skill_level is not null");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillLevelEqualTo(Integer value) {
            this.addCriterion("skill_level =", value, "skillLevel");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillLevelEqualToColumn(Column column) {
            this.addCriterion("skill_level = " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillLevelNotEqualTo(Integer value) {
            this.addCriterion("skill_level <>", value, "skillLevel");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillLevelNotEqualToColumn(Column column) {
            this.addCriterion("skill_level <> " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillLevelGreaterThan(Integer value) {
            this.addCriterion("skill_level >", value, "skillLevel");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillLevelGreaterThanColumn(Column column) {
            this.addCriterion("skill_level > " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillLevelGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("skill_level >=", value, "skillLevel");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillLevelGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_level >= " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillLevelLessThan(Integer value) {
            this.addCriterion("skill_level <", value, "skillLevel");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillLevelLessThanColumn(Column column) {
            this.addCriterion("skill_level < " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillLevelLessThanOrEqualTo(Integer value) {
            this.addCriterion("skill_level <=", value, "skillLevel");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillLevelLessThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_level <= " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillLevelIn(List<Integer> values) {
            this.addCriterion("skill_level in", values, "skillLevel");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillLevelNotIn(List<Integer> values) {
            this.addCriterion("skill_level not in", values, "skillLevel");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillLevelBetween(Integer value1, Integer value2) {
            this.addCriterion("skill_level between", value1, value2, "skillLevel");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillLevelNotBetween(Integer value1, Integer value2) {
            this.addCriterion("skill_level not between", value1, value2, "skillLevel");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillMubiaoIsNull() {
            this.addCriterion("skill_mubiao is null");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillMubiaoIsNotNull() {
            this.addCriterion("skill_mubiao is not null");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillMubiaoEqualTo(Integer value) {
            this.addCriterion("skill_mubiao =", value, "skillMubiao");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillMubiaoEqualToColumn(Column column) {
            this.addCriterion("skill_mubiao = " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillMubiaoNotEqualTo(Integer value) {
            this.addCriterion("skill_mubiao <>", value, "skillMubiao");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillMubiaoNotEqualToColumn(Column column) {
            this.addCriterion("skill_mubiao <> " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillMubiaoGreaterThan(Integer value) {
            this.addCriterion("skill_mubiao >", value, "skillMubiao");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillMubiaoGreaterThanColumn(Column column) {
            this.addCriterion("skill_mubiao > " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillMubiaoGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("skill_mubiao >=", value, "skillMubiao");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillMubiaoGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_mubiao >= " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillMubiaoLessThan(Integer value) {
            this.addCriterion("skill_mubiao <", value, "skillMubiao");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillMubiaoLessThanColumn(Column column) {
            this.addCriterion("skill_mubiao < " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillMubiaoLessThanOrEqualTo(Integer value) {
            this.addCriterion("skill_mubiao <=", value, "skillMubiao");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillMubiaoLessThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_mubiao <= " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillMubiaoIn(List<Integer> values) {
            this.addCriterion("skill_mubiao in", values, "skillMubiao");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillMubiaoNotIn(List<Integer> values) {
            this.addCriterion("skill_mubiao not in", values, "skillMubiao");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillMubiaoBetween(Integer value1, Integer value2) {
            this.addCriterion("skill_mubiao between", value1, value2, "skillMubiao");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andSkillMubiaoNotBetween(Integer value1, Integer value2) {
            this.addCriterion("skill_mubiao not between", value1, value2, "skillMubiao");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andTianshuIdIsNull() {
            this.addCriterion("tianshu_id is null");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andTianshuIdIsNotNull() {
            this.addCriterion("tianshu_id is not null");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andTianshuIdEqualTo(String value) {
            this.addCriterion("tianshu_id =", value, "tianshuId");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andTianshuIdEqualToColumn(Column column) {
            this.addCriterion("tianshu_id = " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andTianshuIdNotEqualTo(String value) {
            this.addCriterion("tianshu_id <>", value, "tianshuId");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andTianshuIdNotEqualToColumn(Column column) {
            this.addCriterion("tianshu_id <> " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andTianshuIdGreaterThan(String value) {
            this.addCriterion("tianshu_id >", value, "tianshuId");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andTianshuIdGreaterThanColumn(Column column) {
            this.addCriterion("tianshu_id > " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andTianshuIdGreaterThanOrEqualTo(String value) {
            this.addCriterion("tianshu_id >=", value, "tianshuId");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andTianshuIdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("tianshu_id >= " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andTianshuIdLessThan(String value) {
            this.addCriterion("tianshu_id <", value, "tianshuId");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andTianshuIdLessThanColumn(Column column) {
            this.addCriterion("tianshu_id < " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andTianshuIdLessThanOrEqualTo(String value) {
            this.addCriterion("tianshu_id <=", value, "tianshuId");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andTianshuIdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("tianshu_id <= " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andTianshuIdLike(String value) {
            this.addCriterion("tianshu_id like", value, "tianshuId");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andTianshuIdNotLike(String value) {
            this.addCriterion("tianshu_id not like", value, "tianshuId");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andTianshuIdIn(List<String> values) {
            this.addCriterion("tianshu_id in", values, "tianshuId");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andTianshuIdNotIn(List<String> values) {
            this.addCriterion("tianshu_id not in", values, "tianshuId");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andTianshuIdBetween(String value1, String value2) {
            this.addCriterion("tianshu_id between", value1, value2, "tianshuId");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andTianshuIdNotBetween(String value1, String value2) {
            this.addCriterion("tianshu_id not between", value1, value2, "tianshuId");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andTianshuNameIsNull() {
            this.addCriterion("tianshu_name is null");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andTianshuNameIsNotNull() {
            this.addCriterion("tianshu_name is not null");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andTianshuNameEqualTo(String value) {
            this.addCriterion("tianshu_name =", value, "tianshuName");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andTianshuNameEqualToColumn(Column column) {
            this.addCriterion("tianshu_name = " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andTianshuNameNotEqualTo(String value) {
            this.addCriterion("tianshu_name <>", value, "tianshuName");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andTianshuNameNotEqualToColumn(Column column) {
            this.addCriterion("tianshu_name <> " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andTianshuNameGreaterThan(String value) {
            this.addCriterion("tianshu_name >", value, "tianshuName");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andTianshuNameGreaterThanColumn(Column column) {
            this.addCriterion("tianshu_name > " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andTianshuNameGreaterThanOrEqualTo(String value) {
            this.addCriterion("tianshu_name >=", value, "tianshuName");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andTianshuNameGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("tianshu_name >= " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andTianshuNameLessThan(String value) {
            this.addCriterion("tianshu_name <", value, "tianshuName");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andTianshuNameLessThanColumn(Column column) {
            this.addCriterion("tianshu_name < " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andTianshuNameLessThanOrEqualTo(String value) {
            this.addCriterion("tianshu_name <=", value, "tianshuName");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andTianshuNameLessThanOrEqualToColumn(Column column) {
            this.addCriterion("tianshu_name <= " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andTianshuNameLike(String value) {
            this.addCriterion("tianshu_name like", value, "tianshuName");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andTianshuNameNotLike(String value) {
            this.addCriterion("tianshu_name not like", value, "tianshuName");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andTianshuNameIn(List<String> values) {
            this.addCriterion("tianshu_name in", values, "tianshuName");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andTianshuNameNotIn(List<String> values) {
            this.addCriterion("tianshu_name not in", values, "tianshuName");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andTianshuNameBetween(String value1, String value2) {
            this.addCriterion("tianshu_name between", value1, value2, "tianshuName");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andTianshuNameNotBetween(String value1, String value2) {
            this.addCriterion("tianshu_name not between", value1, value2, "tianshuName");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andAddTimeIsNull() {
            this.addCriterion("add_time is null");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andAddTimeIsNotNull() {
            this.addCriterion("add_time is not null");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andAddTimeEqualTo(LocalDateTime value) {
            this.addCriterion("add_time =", value, "addTime");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andAddTimeEqualToColumn(Column column) {
            this.addCriterion("add_time = " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andAddTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <>", value, "addTime");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andAddTimeNotEqualToColumn(Column column) {
            this.addCriterion("add_time <> " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andAddTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("add_time >", value, "addTime");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andAddTimeGreaterThanColumn(Column column) {
            this.addCriterion("add_time > " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andAddTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time >=", value, "addTime");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andAddTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time >= " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andAddTimeLessThan(LocalDateTime value) {
            this.addCriterion("add_time <", value, "addTime");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andAddTimeLessThanColumn(Column column) {
            this.addCriterion("add_time < " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andAddTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <=", value, "addTime");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andAddTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time <= " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andAddTimeIn(List<LocalDateTime> values) {
            this.addCriterion("add_time in", values, "addTime");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andAddTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("add_time not in", values, "addTime");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andAddTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time between", value1, value2, "addTime");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andAddTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time not between", value1, value2, "addTime");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andUpdateTimeIsNull() {
            this.addCriterion("update_time is null");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andUpdateTimeIsNotNull() {
            this.addCriterion("update_time is not null");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andUpdateTimeEqualTo(LocalDateTime value) {
            this.addCriterion("update_time =", value, "updateTime");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andUpdateTimeEqualToColumn(Column column) {
            this.addCriterion("update_time = " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andUpdateTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <>", value, "updateTime");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andUpdateTimeNotEqualToColumn(Column column) {
            this.addCriterion("update_time <> " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andUpdateTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("update_time >", value, "updateTime");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andUpdateTimeGreaterThanColumn(Column column) {
            this.addCriterion("update_time > " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andUpdateTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time >=", value, "updateTime");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andUpdateTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time >= " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andUpdateTimeLessThan(LocalDateTime value) {
            this.addCriterion("update_time <", value, "updateTime");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andUpdateTimeLessThanColumn(Column column) {
            this.addCriterion("update_time < " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andUpdateTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <=", value, "updateTime");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andUpdateTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time <= " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andUpdateTimeIn(List<LocalDateTime> values) {
            this.addCriterion("update_time in", values, "updateTime");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andUpdateTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("update_time not in", values, "updateTime");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andUpdateTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time between", value1, value2, "updateTime");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andUpdateTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time not between", value1, value2, "updateTime");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andDeletedIsNull() {
            this.addCriterion("deleted is null");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andDeletedIsNotNull() {
            this.addCriterion("deleted is not null");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andDeletedEqualTo(Boolean value) {
            this.addCriterion("deleted =", value, "deleted");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andDeletedEqualToColumn(Column column) {
            this.addCriterion("deleted = " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andDeletedNotEqualTo(Boolean value) {
            this.addCriterion("deleted <>", value, "deleted");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andDeletedNotEqualToColumn(Column column) {
            this.addCriterion("deleted <> " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andDeletedGreaterThan(Boolean value) {
            this.addCriterion("deleted >", value, "deleted");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andDeletedGreaterThanColumn(Column column) {
            this.addCriterion("deleted > " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andDeletedGreaterThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted >=", value, "deleted");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andDeletedGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted >= " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andDeletedLessThan(Boolean value) {
            this.addCriterion("deleted <", value, "deleted");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andDeletedLessThanColumn(Column column) {
            this.addCriterion("deleted < " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andDeletedLessThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted <=", value, "deleted");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andDeletedLessThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted <= " + column.getEscapedColumnName());
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andDeletedIn(List<Boolean> values) {
            this.addCriterion("deleted in", values, "deleted");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andDeletedNotIn(List<Boolean> values) {
            this.addCriterion("deleted not in", values, "deleted");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andDeletedBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted between", value1, value2, "deleted");
            return (SkillsChongwExample.Criteria)this;
        }

        public SkillsChongwExample.Criteria andDeletedNotBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted not between", value1, value2, "deleted");
            return (SkillsChongwExample.Criteria)this;
        }
    }
}
