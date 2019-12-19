//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.domain.example;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.linlinjava.litemall.db.domain.Skills.Column;
import org.linlinjava.litemall.db.domain.Skills.Deleted;

public class SkillsExample {
    protected String orderByClause;
    protected boolean distinct;
    protected List<SkillsExample.Criteria> oredCriteria = new ArrayList();

    public SkillsExample() {
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

    public List<SkillsExample.Criteria> getOredCriteria() {
        return this.oredCriteria;
    }

    public void or(SkillsExample.Criteria criteria) {
        this.oredCriteria.add(criteria);
    }

    public SkillsExample.Criteria or() {
        SkillsExample.Criteria criteria = this.createCriteriaInternal();
        this.oredCriteria.add(criteria);
        return criteria;
    }

    public SkillsExample orderBy(String orderByClause) {
        this.setOrderByClause(orderByClause);
        return this;
    }

    public SkillsExample orderBy(String... orderByClauses) {
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

    public SkillsExample.Criteria createCriteria() {
        SkillsExample.Criteria criteria = this.createCriteriaInternal();
        if (this.oredCriteria.size() == 0) {
            this.oredCriteria.add(criteria);
        }

        return criteria;
    }

    protected SkillsExample.Criteria createCriteriaInternal() {
        SkillsExample.Criteria criteria = new SkillsExample.Criteria(this);
        return criteria;
    }

    public void clear() {
        this.oredCriteria.clear();
        this.orderByClause = null;
        this.distinct = false;
    }

    public static SkillsExample.Criteria newAndCreateCriteria() {
        SkillsExample example = new SkillsExample();
        return example.createCriteria();
    }

    public SkillsExample when(boolean condition, SkillsExample.IExampleWhen then) {
        if (condition) {
            then.example(this);
        }

        return this;
    }

    public SkillsExample when(boolean condition, SkillsExample.IExampleWhen then, SkillsExample.IExampleWhen otherwise) {
        if (condition) {
            then.example(this);
        } else {
            otherwise.example(this);
        }

        return this;
    }

    public interface IExampleWhen {
        void example(SkillsExample example);
    }

    public interface ICriteriaWhen {
        void criteria(SkillsExample.Criteria criteria);
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

    public static class Criteria extends SkillsExample.GeneratedCriteria {
        private SkillsExample example;

        protected Criteria(SkillsExample example) {
            this.example = example;
        }

        public SkillsExample example() {
            return this.example;
        }

        /** @deprecated */
        @Deprecated
        public SkillsExample.Criteria andIf(boolean ifAdd, SkillsExample.Criteria.ICriteriaAdd add) {
            if (ifAdd) {
                add.add(this);
            }

            return this;
        }

        public SkillsExample.Criteria when(boolean condition, SkillsExample.ICriteriaWhen then) {
            if (condition) {
                then.criteria(this);
            }

            return this;
        }

        public SkillsExample.Criteria when(boolean condition, SkillsExample.ICriteriaWhen then, SkillsExample.ICriteriaWhen otherwise) {
            if (condition) {
                then.criteria(this);
            } else {
                otherwise.criteria(this);
            }

            return this;
        }

        public SkillsExample.Criteria andLogicalDeleted(boolean deleted) {
            return deleted ? this.andDeletedEqualTo(Deleted.IS_DELETED.value()) : this.andDeletedNotEqualTo(Deleted.IS_DELETED.value());
        }

        /** @deprecated */
        @Deprecated
        public interface ICriteriaAdd {
            SkillsExample.Criteria add(SkillsExample.Criteria add);
        }
    }

    protected abstract static class GeneratedCriteria {
        protected List<SkillsExample.Criterion> criteria = new ArrayList();

        protected GeneratedCriteria() {
        }

        public boolean isValid() {
            return this.criteria.size() > 0;
        }

        public List<SkillsExample.Criterion> getAllCriteria() {
            return this.criteria;
        }

        public List<SkillsExample.Criterion> getCriteria() {
            return this.criteria;
        }

        protected void addCriterion(String condition) {
            if (condition == null) {
                throw new RuntimeException("Value for condition cannot be null");
            } else {
                this.criteria.add(new SkillsExample.Criterion(condition));
            }
        }

        protected void addCriterion(String condition, Object value, String property) {
            if (value == null) {
                throw new RuntimeException("Value for " + property + " cannot be null");
            } else {
                this.criteria.add(new SkillsExample.Criterion(condition, value));
            }
        }

        protected void addCriterion(String condition, Object value1, Object value2, String property) {
            if (value1 != null && value2 != null) {
                this.criteria.add(new SkillsExample.Criterion(condition, value1, value2));
            } else {
                throw new RuntimeException("Between values for " + property + " cannot be null");
            }
        }

        public SkillsExample.Criteria andIdIsNull() {
            this.addCriterion("id is null");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andIdIsNotNull() {
            this.addCriterion("id is not null");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andIdEqualTo(Integer value) {
            this.addCriterion("id =", value, "id");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andIdEqualToColumn(Column column) {
            this.addCriterion("id = " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andIdNotEqualTo(Integer value) {
            this.addCriterion("id <>", value, "id");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andIdNotEqualToColumn(Column column) {
            this.addCriterion("id <> " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andIdGreaterThan(Integer value) {
            this.addCriterion("id >", value, "id");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andIdGreaterThanColumn(Column column) {
            this.addCriterion("id > " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andIdGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("id >=", value, "id");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andIdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("id >= " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andIdLessThan(Integer value) {
            this.addCriterion("id <", value, "id");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andIdLessThanColumn(Column column) {
            this.addCriterion("id < " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andIdLessThanOrEqualTo(Integer value) {
            this.addCriterion("id <=", value, "id");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andIdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("id <= " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andIdIn(List<Integer> values) {
            this.addCriterion("id in", values, "id");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andIdNotIn(List<Integer> values) {
            this.addCriterion("id not in", values, "id");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andIdBetween(Integer value1, Integer value2) {
            this.addCriterion("id between", value1, value2, "id");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andIdNotBetween(Integer value1, Integer value2) {
            this.addCriterion("id not between", value1, value2, "id");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillIdHexIsNull() {
            this.addCriterion("skill_id_hex is null");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillIdHexIsNotNull() {
            this.addCriterion("skill_id_hex is not null");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillIdHexEqualTo(String value) {
            this.addCriterion("skill_id_hex =", value, "skillIdHex");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillIdHexEqualToColumn(Column column) {
            this.addCriterion("skill_id_hex = " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillIdHexNotEqualTo(String value) {
            this.addCriterion("skill_id_hex <>", value, "skillIdHex");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillIdHexNotEqualToColumn(Column column) {
            this.addCriterion("skill_id_hex <> " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillIdHexGreaterThan(String value) {
            this.addCriterion("skill_id_hex >", value, "skillIdHex");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillIdHexGreaterThanColumn(Column column) {
            this.addCriterion("skill_id_hex > " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillIdHexGreaterThanOrEqualTo(String value) {
            this.addCriterion("skill_id_hex >=", value, "skillIdHex");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillIdHexGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_id_hex >= " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillIdHexLessThan(String value) {
            this.addCriterion("skill_id_hex <", value, "skillIdHex");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillIdHexLessThanColumn(Column column) {
            this.addCriterion("skill_id_hex < " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillIdHexLessThanOrEqualTo(String value) {
            this.addCriterion("skill_id_hex <=", value, "skillIdHex");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillIdHexLessThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_id_hex <= " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillIdHexLike(String value) {
            this.addCriterion("skill_id_hex like", value, "skillIdHex");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillIdHexNotLike(String value) {
            this.addCriterion("skill_id_hex not like", value, "skillIdHex");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillIdHexIn(List<String> values) {
            this.addCriterion("skill_id_hex in", values, "skillIdHex");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillIdHexNotIn(List<String> values) {
            this.addCriterion("skill_id_hex not in", values, "skillIdHex");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillIdHexBetween(String value1, String value2) {
            this.addCriterion("skill_id_hex between", value1, value2, "skillIdHex");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillIdHexNotBetween(String value1, String value2) {
            this.addCriterion("skill_id_hex not between", value1, value2, "skillIdHex");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillNameIsNull() {
            this.addCriterion("skill_name is null");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillNameIsNotNull() {
            this.addCriterion("skill_name is not null");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillNameEqualTo(String value) {
            this.addCriterion("skill_name =", value, "skillName");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillNameEqualToColumn(Column column) {
            this.addCriterion("skill_name = " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillNameNotEqualTo(String value) {
            this.addCriterion("skill_name <>", value, "skillName");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillNameNotEqualToColumn(Column column) {
            this.addCriterion("skill_name <> " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillNameGreaterThan(String value) {
            this.addCriterion("skill_name >", value, "skillName");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillNameGreaterThanColumn(Column column) {
            this.addCriterion("skill_name > " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillNameGreaterThanOrEqualTo(String value) {
            this.addCriterion("skill_name >=", value, "skillName");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillNameGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_name >= " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillNameLessThan(String value) {
            this.addCriterion("skill_name <", value, "skillName");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillNameLessThanColumn(Column column) {
            this.addCriterion("skill_name < " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillNameLessThanOrEqualTo(String value) {
            this.addCriterion("skill_name <=", value, "skillName");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillNameLessThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_name <= " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillNameLike(String value) {
            this.addCriterion("skill_name like", value, "skillName");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillNameNotLike(String value) {
            this.addCriterion("skill_name not like", value, "skillName");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillNameIn(List<String> values) {
            this.addCriterion("skill_name in", values, "skillName");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillNameNotIn(List<String> values) {
            this.addCriterion("skill_name not in", values, "skillName");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillNameBetween(String value1, String value2) {
            this.addCriterion("skill_name between", value1, value2, "skillName");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillNameNotBetween(String value1, String value2) {
            this.addCriterion("skill_name not between", value1, value2, "skillName");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillReqMenpaiIsNull() {
            this.addCriterion("skill_req_menpai is null");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillReqMenpaiIsNotNull() {
            this.addCriterion("skill_req_menpai is not null");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillReqMenpaiEqualTo(Integer value) {
            this.addCriterion("skill_req_menpai =", value, "skillReqMenpai");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillReqMenpaiEqualToColumn(Column column) {
            this.addCriterion("skill_req_menpai = " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillReqMenpaiNotEqualTo(Integer value) {
            this.addCriterion("skill_req_menpai <>", value, "skillReqMenpai");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillReqMenpaiNotEqualToColumn(Column column) {
            this.addCriterion("skill_req_menpai <> " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillReqMenpaiGreaterThan(Integer value) {
            this.addCriterion("skill_req_menpai >", value, "skillReqMenpai");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillReqMenpaiGreaterThanColumn(Column column) {
            this.addCriterion("skill_req_menpai > " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillReqMenpaiGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("skill_req_menpai >=", value, "skillReqMenpai");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillReqMenpaiGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_req_menpai >= " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillReqMenpaiLessThan(Integer value) {
            this.addCriterion("skill_req_menpai <", value, "skillReqMenpai");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillReqMenpaiLessThanColumn(Column column) {
            this.addCriterion("skill_req_menpai < " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillReqMenpaiLessThanOrEqualTo(Integer value) {
            this.addCriterion("skill_req_menpai <=", value, "skillReqMenpai");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillReqMenpaiLessThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_req_menpai <= " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillReqMenpaiIn(List<Integer> values) {
            this.addCriterion("skill_req_menpai in", values, "skillReqMenpai");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillReqMenpaiNotIn(List<Integer> values) {
            this.addCriterion("skill_req_menpai not in", values, "skillReqMenpai");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillReqMenpaiBetween(Integer value1, Integer value2) {
            this.addCriterion("skill_req_menpai between", value1, value2, "skillReqMenpai");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillReqMenpaiNotBetween(Integer value1, Integer value2) {
            this.addCriterion("skill_req_menpai not between", value1, value2, "skillReqMenpai");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillTypeIsNull() {
            this.addCriterion("skill_type is null");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillTypeIsNotNull() {
            this.addCriterion("skill_type is not null");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillTypeEqualTo(Integer value) {
            this.addCriterion("skill_type =", value, "skillType");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillTypeEqualToColumn(Column column) {
            this.addCriterion("skill_type = " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillTypeNotEqualTo(Integer value) {
            this.addCriterion("skill_type <>", value, "skillType");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillTypeNotEqualToColumn(Column column) {
            this.addCriterion("skill_type <> " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillTypeGreaterThan(Integer value) {
            this.addCriterion("skill_type >", value, "skillType");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillTypeGreaterThanColumn(Column column) {
            this.addCriterion("skill_type > " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillTypeGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("skill_type >=", value, "skillType");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillTypeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_type >= " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillTypeLessThan(Integer value) {
            this.addCriterion("skill_type <", value, "skillType");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillTypeLessThanColumn(Column column) {
            this.addCriterion("skill_type < " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillTypeLessThanOrEqualTo(Integer value) {
            this.addCriterion("skill_type <=", value, "skillType");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillTypeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_type <= " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillTypeIn(List<Integer> values) {
            this.addCriterion("skill_type in", values, "skillType");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillTypeNotIn(List<Integer> values) {
            this.addCriterion("skill_type not in", values, "skillType");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillTypeBetween(Integer value1, Integer value2) {
            this.addCriterion("skill_type between", value1, value2, "skillType");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillTypeNotBetween(Integer value1, Integer value2) {
            this.addCriterion("skill_type not between", value1, value2, "skillType");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillTypeLevelIsNull() {
            this.addCriterion("skill_type_level is null");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillTypeLevelIsNotNull() {
            this.addCriterion("skill_type_level is not null");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillTypeLevelEqualTo(Integer value) {
            this.addCriterion("skill_type_level =", value, "skillTypeLevel");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillTypeLevelEqualToColumn(Column column) {
            this.addCriterion("skill_type_level = " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillTypeLevelNotEqualTo(Integer value) {
            this.addCriterion("skill_type_level <>", value, "skillTypeLevel");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillTypeLevelNotEqualToColumn(Column column) {
            this.addCriterion("skill_type_level <> " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillTypeLevelGreaterThan(Integer value) {
            this.addCriterion("skill_type_level >", value, "skillTypeLevel");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillTypeLevelGreaterThanColumn(Column column) {
            this.addCriterion("skill_type_level > " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillTypeLevelGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("skill_type_level >=", value, "skillTypeLevel");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillTypeLevelGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_type_level >= " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillTypeLevelLessThan(Integer value) {
            this.addCriterion("skill_type_level <", value, "skillTypeLevel");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillTypeLevelLessThanColumn(Column column) {
            this.addCriterion("skill_type_level < " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillTypeLevelLessThanOrEqualTo(Integer value) {
            this.addCriterion("skill_type_level <=", value, "skillTypeLevel");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillTypeLevelLessThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_type_level <= " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillTypeLevelIn(List<Integer> values) {
            this.addCriterion("skill_type_level in", values, "skillTypeLevel");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillTypeLevelNotIn(List<Integer> values) {
            this.addCriterion("skill_type_level not in", values, "skillTypeLevel");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillTypeLevelBetween(Integer value1, Integer value2) {
            this.addCriterion("skill_type_level between", value1, value2, "skillTypeLevel");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillTypeLevelNotBetween(Integer value1, Integer value2) {
            this.addCriterion("skill_type_level not between", value1, value2, "skillTypeLevel");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillMagicIsNull() {
            this.addCriterion("skill_magic is null");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillMagicIsNotNull() {
            this.addCriterion("skill_magic is not null");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillMagicEqualTo(Integer value) {
            this.addCriterion("skill_magic =", value, "skillMagic");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillMagicEqualToColumn(Column column) {
            this.addCriterion("skill_magic = " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillMagicNotEqualTo(Integer value) {
            this.addCriterion("skill_magic <>", value, "skillMagic");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillMagicNotEqualToColumn(Column column) {
            this.addCriterion("skill_magic <> " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillMagicGreaterThan(Integer value) {
            this.addCriterion("skill_magic >", value, "skillMagic");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillMagicGreaterThanColumn(Column column) {
            this.addCriterion("skill_magic > " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillMagicGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("skill_magic >=", value, "skillMagic");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillMagicGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_magic >= " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillMagicLessThan(Integer value) {
            this.addCriterion("skill_magic <", value, "skillMagic");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillMagicLessThanColumn(Column column) {
            this.addCriterion("skill_magic < " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillMagicLessThanOrEqualTo(Integer value) {
            this.addCriterion("skill_magic <=", value, "skillMagic");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillMagicLessThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_magic <= " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillMagicIn(List<Integer> values) {
            this.addCriterion("skill_magic in", values, "skillMagic");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillMagicNotIn(List<Integer> values) {
            this.addCriterion("skill_magic not in", values, "skillMagic");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillMagicBetween(Integer value1, Integer value2) {
            this.addCriterion("skill_magic between", value1, value2, "skillMagic");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillMagicNotBetween(Integer value1, Integer value2) {
            this.addCriterion("skill_magic not between", value1, value2, "skillMagic");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillReqLevelIsNull() {
            this.addCriterion("skill_req_level is null");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillReqLevelIsNotNull() {
            this.addCriterion("skill_req_level is not null");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillReqLevelEqualTo(Integer value) {
            this.addCriterion("skill_req_level =", value, "skillReqLevel");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillReqLevelEqualToColumn(Column column) {
            this.addCriterion("skill_req_level = " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillReqLevelNotEqualTo(Integer value) {
            this.addCriterion("skill_req_level <>", value, "skillReqLevel");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillReqLevelNotEqualToColumn(Column column) {
            this.addCriterion("skill_req_level <> " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillReqLevelGreaterThan(Integer value) {
            this.addCriterion("skill_req_level >", value, "skillReqLevel");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillReqLevelGreaterThanColumn(Column column) {
            this.addCriterion("skill_req_level > " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillReqLevelGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("skill_req_level >=", value, "skillReqLevel");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillReqLevelGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_req_level >= " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillReqLevelLessThan(Integer value) {
            this.addCriterion("skill_req_level <", value, "skillReqLevel");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillReqLevelLessThanColumn(Column column) {
            this.addCriterion("skill_req_level < " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillReqLevelLessThanOrEqualTo(Integer value) {
            this.addCriterion("skill_req_level <=", value, "skillReqLevel");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillReqLevelLessThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_req_level <= " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillReqLevelIn(List<Integer> values) {
            this.addCriterion("skill_req_level in", values, "skillReqLevel");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillReqLevelNotIn(List<Integer> values) {
            this.addCriterion("skill_req_level not in", values, "skillReqLevel");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillReqLevelBetween(Integer value1, Integer value2) {
            this.addCriterion("skill_req_level between", value1, value2, "skillReqLevel");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillReqLevelNotBetween(Integer value1, Integer value2) {
            this.addCriterion("skill_req_level not between", value1, value2, "skillReqLevel");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillContextIsNull() {
            this.addCriterion("skill_context is null");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillContextIsNotNull() {
            this.addCriterion("skill_context is not null");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillContextEqualTo(String value) {
            this.addCriterion("skill_context =", value, "skillContext");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillContextEqualToColumn(Column column) {
            this.addCriterion("skill_context = " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillContextNotEqualTo(String value) {
            this.addCriterion("skill_context <>", value, "skillContext");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillContextNotEqualToColumn(Column column) {
            this.addCriterion("skill_context <> " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillContextGreaterThan(String value) {
            this.addCriterion("skill_context >", value, "skillContext");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillContextGreaterThanColumn(Column column) {
            this.addCriterion("skill_context > " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillContextGreaterThanOrEqualTo(String value) {
            this.addCriterion("skill_context >=", value, "skillContext");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillContextGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_context >= " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillContextLessThan(String value) {
            this.addCriterion("skill_context <", value, "skillContext");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillContextLessThanColumn(Column column) {
            this.addCriterion("skill_context < " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillContextLessThanOrEqualTo(String value) {
            this.addCriterion("skill_context <=", value, "skillContext");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillContextLessThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_context <= " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillContextLike(String value) {
            this.addCriterion("skill_context like", value, "skillContext");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillContextNotLike(String value) {
            this.addCriterion("skill_context not like", value, "skillContext");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillContextIn(List<String> values) {
            this.addCriterion("skill_context in", values, "skillContext");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillContextNotIn(List<String> values) {
            this.addCriterion("skill_context not in", values, "skillContext");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillContextBetween(String value1, String value2) {
            this.addCriterion("skill_context between", value1, value2, "skillContext");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andSkillContextNotBetween(String value1, String value2) {
            this.addCriterion("skill_context not between", value1, value2, "skillContext");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andAddTimeIsNull() {
            this.addCriterion("add_time is null");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andAddTimeIsNotNull() {
            this.addCriterion("add_time is not null");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andAddTimeEqualTo(LocalDateTime value) {
            this.addCriterion("add_time =", value, "addTime");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andAddTimeEqualToColumn(Column column) {
            this.addCriterion("add_time = " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andAddTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <>", value, "addTime");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andAddTimeNotEqualToColumn(Column column) {
            this.addCriterion("add_time <> " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andAddTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("add_time >", value, "addTime");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andAddTimeGreaterThanColumn(Column column) {
            this.addCriterion("add_time > " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andAddTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time >=", value, "addTime");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andAddTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time >= " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andAddTimeLessThan(LocalDateTime value) {
            this.addCriterion("add_time <", value, "addTime");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andAddTimeLessThanColumn(Column column) {
            this.addCriterion("add_time < " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andAddTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <=", value, "addTime");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andAddTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time <= " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andAddTimeIn(List<LocalDateTime> values) {
            this.addCriterion("add_time in", values, "addTime");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andAddTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("add_time not in", values, "addTime");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andAddTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time between", value1, value2, "addTime");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andAddTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time not between", value1, value2, "addTime");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andUpdateTimeIsNull() {
            this.addCriterion("update_time is null");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andUpdateTimeIsNotNull() {
            this.addCriterion("update_time is not null");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andUpdateTimeEqualTo(LocalDateTime value) {
            this.addCriterion("update_time =", value, "updateTime");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andUpdateTimeEqualToColumn(Column column) {
            this.addCriterion("update_time = " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andUpdateTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <>", value, "updateTime");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andUpdateTimeNotEqualToColumn(Column column) {
            this.addCriterion("update_time <> " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andUpdateTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("update_time >", value, "updateTime");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andUpdateTimeGreaterThanColumn(Column column) {
            this.addCriterion("update_time > " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andUpdateTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time >=", value, "updateTime");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andUpdateTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time >= " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andUpdateTimeLessThan(LocalDateTime value) {
            this.addCriterion("update_time <", value, "updateTime");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andUpdateTimeLessThanColumn(Column column) {
            this.addCriterion("update_time < " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andUpdateTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <=", value, "updateTime");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andUpdateTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time <= " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andUpdateTimeIn(List<LocalDateTime> values) {
            this.addCriterion("update_time in", values, "updateTime");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andUpdateTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("update_time not in", values, "updateTime");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andUpdateTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time between", value1, value2, "updateTime");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andUpdateTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time not between", value1, value2, "updateTime");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andDeletedIsNull() {
            this.addCriterion("deleted is null");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andDeletedIsNotNull() {
            this.addCriterion("deleted is not null");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andDeletedEqualTo(Boolean value) {
            this.addCriterion("deleted =", value, "deleted");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andDeletedEqualToColumn(Column column) {
            this.addCriterion("deleted = " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andDeletedNotEqualTo(Boolean value) {
            this.addCriterion("deleted <>", value, "deleted");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andDeletedNotEqualToColumn(Column column) {
            this.addCriterion("deleted <> " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andDeletedGreaterThan(Boolean value) {
            this.addCriterion("deleted >", value, "deleted");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andDeletedGreaterThanColumn(Column column) {
            this.addCriterion("deleted > " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andDeletedGreaterThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted >=", value, "deleted");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andDeletedGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted >= " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andDeletedLessThan(Boolean value) {
            this.addCriterion("deleted <", value, "deleted");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andDeletedLessThanColumn(Column column) {
            this.addCriterion("deleted < " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andDeletedLessThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted <=", value, "deleted");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andDeletedLessThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted <= " + column.getEscapedColumnName());
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andDeletedIn(List<Boolean> values) {
            this.addCriterion("deleted in", values, "deleted");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andDeletedNotIn(List<Boolean> values) {
            this.addCriterion("deleted not in", values, "deleted");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andDeletedBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted between", value1, value2, "deleted");
            return (SkillsExample.Criteria)this;
        }

        public SkillsExample.Criteria andDeletedNotBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted not between", value1, value2, "deleted");
            return (SkillsExample.Criteria)this;
        }
    }
}
