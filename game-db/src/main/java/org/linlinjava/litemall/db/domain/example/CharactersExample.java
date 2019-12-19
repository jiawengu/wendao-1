//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.domain.example;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.linlinjava.litemall.db.domain.Characters.Column;
import org.linlinjava.litemall.db.domain.Characters.Deleted;

public class CharactersExample {
    protected String orderByClause;
    protected boolean distinct;
    protected List<CharactersExample.Criteria> oredCriteria = new ArrayList();

    public CharactersExample() {
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

    public List<CharactersExample.Criteria> getOredCriteria() {
        return this.oredCriteria;
    }

    public void or(CharactersExample.Criteria criteria) {
        this.oredCriteria.add(criteria);
    }

    public CharactersExample.Criteria or() {
        CharactersExample.Criteria criteria = this.createCriteriaInternal();
        this.oredCriteria.add(criteria);
        return criteria;
    }

    public CharactersExample orderBy(String orderByClause) {
        this.setOrderByClause(orderByClause);
        return this;
    }

    public CharactersExample orderBy(String... orderByClauses) {
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

    public CharactersExample.Criteria createCriteria() {
        CharactersExample.Criteria criteria = this.createCriteriaInternal();
        if (this.oredCriteria.size() == 0) {
            this.oredCriteria.add(criteria);
        }

        return criteria;
    }

    protected CharactersExample.Criteria createCriteriaInternal() {
        CharactersExample.Criteria criteria = new CharactersExample.Criteria(this);
        return criteria;
    }

    public void clear() {
        this.oredCriteria.clear();
        this.orderByClause = null;
        this.distinct = false;
    }

    public static CharactersExample.Criteria newAndCreateCriteria() {
        CharactersExample example = new CharactersExample();
        return example.createCriteria();
    }

    public CharactersExample when(boolean condition, CharactersExample.IExampleWhen then) {
        if (condition) {
            then.example(this);
        }

        return this;
    }

    public CharactersExample when(boolean condition, CharactersExample.IExampleWhen then, CharactersExample.IExampleWhen otherwise) {
        if (condition) {
            then.example(this);
        } else {
            otherwise.example(this);
        }

        return this;
    }

    public interface IExampleWhen {
        void example(CharactersExample example);
    }

    public interface ICriteriaWhen {
        void criteria(CharactersExample.Criteria criteria);
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

    public static class Criteria extends CharactersExample.GeneratedCriteria {
        private CharactersExample example;

        protected Criteria(CharactersExample example) {
            this.example = example;
        }

        public CharactersExample example() {
            return this.example;
        }

        /** @deprecated */
        @Deprecated
        public CharactersExample.Criteria andIf(boolean ifAdd, CharactersExample.Criteria.ICriteriaAdd add) {
            if (ifAdd) {
                add.add(this);
            }

            return this;
        }

        public CharactersExample.Criteria when(boolean condition, CharactersExample.ICriteriaWhen then) {
            if (condition) {
                then.criteria(this);
            }

            return this;
        }

        public CharactersExample.Criteria when(boolean condition, CharactersExample.ICriteriaWhen then, CharactersExample.ICriteriaWhen otherwise) {
            if (condition) {
                then.criteria(this);
            } else {
                otherwise.criteria(this);
            }

            return this;
        }

        public CharactersExample.Criteria andLogicalDeleted(boolean deleted) {
            return deleted ? this.andDeletedEqualTo(Deleted.IS_DELETED.value()) : this.andDeletedNotEqualTo(Deleted.IS_DELETED.value());
        }

        /** @deprecated */
        @Deprecated
        public interface ICriteriaAdd {
            CharactersExample.Criteria add(CharactersExample.Criteria add);
        }
    }

    protected abstract static class GeneratedCriteria {
        protected List<CharactersExample.Criterion> criteria = new ArrayList();

        protected GeneratedCriteria() {
        }

        public boolean isValid() {
            return this.criteria.size() > 0;
        }

        public List<CharactersExample.Criterion> getAllCriteria() {
            return this.criteria;
        }

        public List<CharactersExample.Criterion> getCriteria() {
            return this.criteria;
        }

        protected void addCriterion(String condition) {
            if (condition == null) {
                throw new RuntimeException("Value for condition cannot be null");
            } else {
                this.criteria.add(new CharactersExample.Criterion(condition));
            }
        }

        protected void addCriterion(String condition, Object value, String property) {
            if (value == null) {
                throw new RuntimeException("Value for " + property + " cannot be null");
            } else {
                this.criteria.add(new CharactersExample.Criterion(condition, value));
            }
        }

        protected void addCriterion(String condition, Object value1, Object value2, String property) {
            if (value1 != null && value2 != null) {
                this.criteria.add(new CharactersExample.Criterion(condition, value1, value2));
            } else {
                throw new RuntimeException("Between values for " + property + " cannot be null");
            }
        }

        public CharactersExample.Criteria andIdIsNull() {
            this.addCriterion("id is null");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andIdIsNotNull() {
            this.addCriterion("id is not null");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andIdEqualTo(Integer value) {
            this.addCriterion("id =", value, "id");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andIdEqualToColumn(Column column) {
            this.addCriterion("id = " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andIdNotEqualTo(Integer value) {
            this.addCriterion("id <>", value, "id");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andIdNotEqualToColumn(Column column) {
            this.addCriterion("id <> " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andIdGreaterThan(Integer value) {
            this.addCriterion("id >", value, "id");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andIdGreaterThanColumn(Column column) {
            this.addCriterion("id > " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andIdGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("id >=", value, "id");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andIdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("id >= " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andIdLessThan(Integer value) {
            this.addCriterion("id <", value, "id");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andIdLessThanColumn(Column column) {
            this.addCriterion("id < " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andIdLessThanOrEqualTo(Integer value) {
            this.addCriterion("id <=", value, "id");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andIdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("id <= " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andIdIn(List<Integer> values) {
            this.addCriterion("id in", values, "id");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andIdNotIn(List<Integer> values) {
            this.addCriterion("id not in", values, "id");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andIdBetween(Integer value1, Integer value2) {
            this.addCriterion("id between", value1, value2, "id");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andIdNotBetween(Integer value1, Integer value2) {
            this.addCriterion("id not between", value1, value2, "id");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andMenpaiIsNull() {
            this.addCriterion("menpai is null");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andMenpaiIsNotNull() {
            this.addCriterion("menpai is not null");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andMenpaiEqualTo(Integer value) {
            this.addCriterion("menpai =", value, "menpai");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andMenpaiEqualToColumn(Column column) {
            this.addCriterion("menpai = " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andMenpaiNotEqualTo(Integer value) {
            this.addCriterion("menpai <>", value, "menpai");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andMenpaiNotEqualToColumn(Column column) {
            this.addCriterion("menpai <> " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andMenpaiGreaterThan(Integer value) {
            this.addCriterion("menpai >", value, "menpai");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andMenpaiGreaterThanColumn(Column column) {
            this.addCriterion("menpai > " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andMenpaiGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("menpai >=", value, "menpai");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andMenpaiGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("menpai >= " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andMenpaiLessThan(Integer value) {
            this.addCriterion("menpai <", value, "menpai");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andMenpaiLessThanColumn(Column column) {
            this.addCriterion("menpai < " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andMenpaiLessThanOrEqualTo(Integer value) {
            this.addCriterion("menpai <=", value, "menpai");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andMenpaiLessThanOrEqualToColumn(Column column) {
            this.addCriterion("menpai <= " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andMenpaiIn(List<Integer> values) {
            this.addCriterion("menpai in", values, "menpai");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andMenpaiNotIn(List<Integer> values) {
            this.addCriterion("menpai not in", values, "menpai");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andMenpaiBetween(Integer value1, Integer value2) {
            this.addCriterion("menpai between", value1, value2, "menpai");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andMenpaiNotBetween(Integer value1, Integer value2) {
            this.addCriterion("menpai not between", value1, value2, "menpai");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andNameIsNull() {
            this.addCriterion("`name` is null");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andNameIsNotNull() {
            this.addCriterion("`name` is not null");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andNameEqualTo(String value) {
            this.addCriterion("`name` =", value, "name");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andNameEqualToColumn(Column column) {
            this.addCriterion("`name` = " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andNameNotEqualTo(String value) {
            this.addCriterion("`name` <>", value, "name");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andNameNotEqualToColumn(Column column) {
            this.addCriterion("`name` <> " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andNameGreaterThan(String value) {
            this.addCriterion("`name` >", value, "name");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andNameGreaterThanColumn(Column column) {
            this.addCriterion("`name` > " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andNameGreaterThanOrEqualTo(String value) {
            this.addCriterion("`name` >=", value, "name");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andNameGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`name` >= " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andNameLessThan(String value) {
            this.addCriterion("`name` <", value, "name");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andNameLessThanColumn(Column column) {
            this.addCriterion("`name` < " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andNameLessThanOrEqualTo(String value) {
            this.addCriterion("`name` <=", value, "name");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andNameLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`name` <= " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andNameLike(String value) {
            this.addCriterion("`name` like", value, "name");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andNameNotLike(String value) {
            this.addCriterion("`name` not like", value, "name");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andNameIn(List<String> values) {
            this.addCriterion("`name` in", values, "name");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andNameNotIn(List<String> values) {
            this.addCriterion("`name` not in", values, "name");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andNameBetween(String value1, String value2) {
            this.addCriterion("`name` between", value1, value2, "name");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andNameNotBetween(String value1, String value2) {
            this.addCriterion("`name` not between", value1, value2, "name");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andAccountIdIsNull() {
            this.addCriterion("account_id is null");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andAccountIdIsNotNull() {
            this.addCriterion("account_id is not null");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andAccountIdEqualTo(Integer value) {
            this.addCriterion("account_id =", value, "accountId");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andAccountIdEqualToColumn(Column column) {
            this.addCriterion("account_id = " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andAccountIdNotEqualTo(Integer value) {
            this.addCriterion("account_id <>", value, "accountId");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andAccountIdNotEqualToColumn(Column column) {
            this.addCriterion("account_id <> " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andAccountIdGreaterThan(Integer value) {
            this.addCriterion("account_id >", value, "accountId");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andAccountIdGreaterThanColumn(Column column) {
            this.addCriterion("account_id > " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andAccountIdGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("account_id >=", value, "accountId");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andAccountIdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("account_id >= " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andAccountIdLessThan(Integer value) {
            this.addCriterion("account_id <", value, "accountId");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andAccountIdLessThanColumn(Column column) {
            this.addCriterion("account_id < " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andAccountIdLessThanOrEqualTo(Integer value) {
            this.addCriterion("account_id <=", value, "accountId");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andAccountIdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("account_id <= " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andAccountIdIn(List<Integer> values) {
            this.addCriterion("account_id in", values, "accountId");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andAccountIdNotIn(List<Integer> values) {
            this.addCriterion("account_id not in", values, "accountId");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andAccountIdBetween(Integer value1, Integer value2) {
            this.addCriterion("account_id between", value1, value2, "accountId");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andAccountIdNotBetween(Integer value1, Integer value2) {
            this.addCriterion("account_id not between", value1, value2, "accountId");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andAddTimeIsNull() {
            this.addCriterion("add_time is null");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andAddTimeIsNotNull() {
            this.addCriterion("add_time is not null");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andAddTimeEqualTo(LocalDateTime value) {
            this.addCriterion("add_time =", value, "addTime");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andAddTimeEqualToColumn(Column column) {
            this.addCriterion("add_time = " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andAddTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <>", value, "addTime");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andAddTimeNotEqualToColumn(Column column) {
            this.addCriterion("add_time <> " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andAddTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("add_time >", value, "addTime");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andAddTimeGreaterThanColumn(Column column) {
            this.addCriterion("add_time > " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andAddTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time >=", value, "addTime");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andAddTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time >= " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andAddTimeLessThan(LocalDateTime value) {
            this.addCriterion("add_time <", value, "addTime");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andAddTimeLessThanColumn(Column column) {
            this.addCriterion("add_time < " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andAddTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <=", value, "addTime");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andAddTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time <= " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andAddTimeIn(List<LocalDateTime> values) {
            this.addCriterion("add_time in", values, "addTime");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andAddTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("add_time not in", values, "addTime");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andAddTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time between", value1, value2, "addTime");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andAddTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time not between", value1, value2, "addTime");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andUpdateTimeIsNull() {
            this.addCriterion("update_time is null");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andUpdateTimeIsNotNull() {
            this.addCriterion("update_time is not null");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andUpdateTimeEqualTo(LocalDateTime value) {
            this.addCriterion("update_time =", value, "updateTime");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andUpdateTimeEqualToColumn(Column column) {
            this.addCriterion("update_time = " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andUpdateTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <>", value, "updateTime");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andUpdateTimeNotEqualToColumn(Column column) {
            this.addCriterion("update_time <> " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andUpdateTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("update_time >", value, "updateTime");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andUpdateTimeGreaterThanColumn(Column column) {
            this.addCriterion("update_time > " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andUpdateTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time >=", value, "updateTime");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andUpdateTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time >= " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andUpdateTimeLessThan(LocalDateTime value) {
            this.addCriterion("update_time <", value, "updateTime");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andUpdateTimeLessThanColumn(Column column) {
            this.addCriterion("update_time < " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andUpdateTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <=", value, "updateTime");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andUpdateTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time <= " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andUpdateTimeIn(List<LocalDateTime> values) {
            this.addCriterion("update_time in", values, "updateTime");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andUpdateTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("update_time not in", values, "updateTime");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andUpdateTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time between", value1, value2, "updateTime");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andUpdateTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time not between", value1, value2, "updateTime");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andDeletedIsNull() {
            this.addCriterion("deleted is null");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andDeletedIsNotNull() {
            this.addCriterion("deleted is not null");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andDeletedEqualTo(Boolean value) {
            this.addCriterion("deleted =", value, "deleted");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andDeletedEqualToColumn(Column column) {
            this.addCriterion("deleted = " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andDeletedNotEqualTo(Boolean value) {
            this.addCriterion("deleted <>", value, "deleted");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andDeletedNotEqualToColumn(Column column) {
            this.addCriterion("deleted <> " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andDeletedGreaterThan(Boolean value) {
            this.addCriterion("deleted >", value, "deleted");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andDeletedGreaterThanColumn(Column column) {
            this.addCriterion("deleted > " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andDeletedGreaterThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted >=", value, "deleted");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andDeletedGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted >= " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andDeletedLessThan(Boolean value) {
            this.addCriterion("deleted <", value, "deleted");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andDeletedLessThanColumn(Column column) {
            this.addCriterion("deleted < " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andDeletedLessThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted <=", value, "deleted");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andDeletedLessThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted <= " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andDeletedIn(List<Boolean> values) {
            this.addCriterion("deleted in", values, "deleted");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andDeletedNotIn(List<Boolean> values) {
            this.addCriterion("deleted not in", values, "deleted");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andDeletedBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted between", value1, value2, "deleted");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andDeletedNotBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted not between", value1, value2, "deleted");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andGidIsNull() {
            this.addCriterion("gid is null");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andGidIsNotNull() {
            this.addCriterion("gid is not null");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andGidEqualTo(String value) {
            this.addCriterion("gid =", value, "gid");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andGidEqualToColumn(Column column) {
            this.addCriterion("gid = " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andGidNotEqualTo(String value) {
            this.addCriterion("gid <>", value, "gid");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andGidNotEqualToColumn(Column column) {
            this.addCriterion("gid <> " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andGidGreaterThan(String value) {
            this.addCriterion("gid >", value, "gid");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andGidGreaterThanColumn(Column column) {
            this.addCriterion("gid > " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andGidGreaterThanOrEqualTo(String value) {
            this.addCriterion("gid >=", value, "gid");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andGidGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("gid >= " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andGidLessThan(String value) {
            this.addCriterion("gid <", value, "gid");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andGidLessThanColumn(Column column) {
            this.addCriterion("gid < " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andGidLessThanOrEqualTo(String value) {
            this.addCriterion("gid <=", value, "gid");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andGidLessThanOrEqualToColumn(Column column) {
            this.addCriterion("gid <= " + column.getEscapedColumnName());
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andGidLike(String value) {
            this.addCriterion("gid like", value, "gid");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andGidNotLike(String value) {
            this.addCriterion("gid not like", value, "gid");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andGidIn(List<String> values) {
            this.addCriterion("gid in", values, "gid");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andGidNotIn(List<String> values) {
            this.addCriterion("gid not in", values, "gid");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andGidBetween(String value1, String value2) {
            this.addCriterion("gid between", value1, value2, "gid");
            return (CharactersExample.Criteria)this;
        }

        public CharactersExample.Criteria andGidNotBetween(String value1, String value2) {
            this.addCriterion("gid not between", value1, value2, "gid");
            return (CharactersExample.Criteria)this;
        }
    }
}
