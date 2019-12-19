//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.domain.example;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.linlinjava.litemall.db.domain.Charge.Column;
import org.linlinjava.litemall.db.domain.Charge.Deleted;

public class ChargeExample {
    protected String orderByClause;
    protected boolean distinct;
    protected List<ChargeExample.Criteria> oredCriteria = new ArrayList();

    public ChargeExample() {
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

    public List<ChargeExample.Criteria> getOredCriteria() {
        return this.oredCriteria;
    }

    public void or(ChargeExample.Criteria criteria) {
        this.oredCriteria.add(criteria);
    }

    public ChargeExample.Criteria or() {
        ChargeExample.Criteria criteria = this.createCriteriaInternal();
        this.oredCriteria.add(criteria);
        return criteria;
    }

    public ChargeExample orderBy(String orderByClause) {
        this.setOrderByClause(orderByClause);
        return this;
    }

    public ChargeExample orderBy(String... orderByClauses) {
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

    public ChargeExample.Criteria createCriteria() {
        ChargeExample.Criteria criteria = this.createCriteriaInternal();
        if (this.oredCriteria.size() == 0) {
            this.oredCriteria.add(criteria);
        }

        return criteria;
    }

    protected ChargeExample.Criteria createCriteriaInternal() {
        ChargeExample.Criteria criteria = new ChargeExample.Criteria(this);
        return criteria;
    }

    public void clear() {
        this.oredCriteria.clear();
        this.orderByClause = null;
        this.distinct = false;
    }

    public static ChargeExample.Criteria newAndCreateCriteria() {
        ChargeExample example = new ChargeExample();
        return example.createCriteria();
    }

    public ChargeExample when(boolean condition, ChargeExample.IExampleWhen then) {
        if (condition) {
            then.example(this);
        }

        return this;
    }

    public ChargeExample when(boolean condition, ChargeExample.IExampleWhen then, ChargeExample.IExampleWhen otherwise) {
        if (condition) {
            then.example(this);
        } else {
            otherwise.example(this);
        }

        return this;
    }

    public interface IExampleWhen {
        void example(ChargeExample example);
    }

    public interface ICriteriaWhen {
        void criteria(ChargeExample.Criteria criteria);
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

    public static class Criteria extends ChargeExample.GeneratedCriteria {
        private ChargeExample example;

        protected Criteria(ChargeExample example) {
            this.example = example;
        }

        public ChargeExample example() {
            return this.example;
        }

        /** @deprecated */
        @Deprecated
        public ChargeExample.Criteria andIf(boolean ifAdd, ChargeExample.Criteria.ICriteriaAdd add) {
            if (ifAdd) {
                add.add(this);
            }

            return this;
        }

        public ChargeExample.Criteria when(boolean condition, ChargeExample.ICriteriaWhen then) {
            if (condition) {
                then.criteria(this);
            }

            return this;
        }

        public ChargeExample.Criteria when(boolean condition, ChargeExample.ICriteriaWhen then, ChargeExample.ICriteriaWhen otherwise) {
            if (condition) {
                then.criteria(this);
            } else {
                otherwise.criteria(this);
            }

            return this;
        }

        public ChargeExample.Criteria andLogicalDeleted(boolean deleted) {
            return deleted ? this.andDeletedEqualTo(Deleted.IS_DELETED.value()) : this.andDeletedNotEqualTo(Deleted.IS_DELETED.value());
        }

        /** @deprecated */
        @Deprecated
        public interface ICriteriaAdd {
            ChargeExample.Criteria add(ChargeExample.Criteria add);
        }
    }

    protected abstract static class GeneratedCriteria {
        protected List<ChargeExample.Criterion> criteria = new ArrayList();

        protected GeneratedCriteria() {
        }

        public boolean isValid() {
            return this.criteria.size() > 0;
        }

        public List<ChargeExample.Criterion> getAllCriteria() {
            return this.criteria;
        }

        public List<ChargeExample.Criterion> getCriteria() {
            return this.criteria;
        }

        protected void addCriterion(String condition) {
            if (condition == null) {
                throw new RuntimeException("Value for condition cannot be null");
            } else {
                this.criteria.add(new ChargeExample.Criterion(condition));
            }
        }

        protected void addCriterion(String condition, Object value, String property) {
            if (value == null) {
                throw new RuntimeException("Value for " + property + " cannot be null");
            } else {
                this.criteria.add(new ChargeExample.Criterion(condition, value));
            }
        }

        protected void addCriterion(String condition, Object value1, Object value2, String property) {
            if (value1 != null && value2 != null) {
                this.criteria.add(new ChargeExample.Criterion(condition, value1, value2));
            } else {
                throw new RuntimeException("Between values for " + property + " cannot be null");
            }
        }

        public ChargeExample.Criteria andIdIsNull() {
            this.addCriterion("id is null");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andIdIsNotNull() {
            this.addCriterion("id is not null");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andIdEqualTo(Integer value) {
            this.addCriterion("id =", value, "id");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andIdEqualToColumn(Column column) {
            this.addCriterion("id = " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andIdNotEqualTo(Integer value) {
            this.addCriterion("id <>", value, "id");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andIdNotEqualToColumn(Column column) {
            this.addCriterion("id <> " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andIdGreaterThan(Integer value) {
            this.addCriterion("id >", value, "id");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andIdGreaterThanColumn(Column column) {
            this.addCriterion("id > " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andIdGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("id >=", value, "id");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andIdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("id >= " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andIdLessThan(Integer value) {
            this.addCriterion("id <", value, "id");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andIdLessThanColumn(Column column) {
            this.addCriterion("id < " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andIdLessThanOrEqualTo(Integer value) {
            this.addCriterion("id <=", value, "id");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andIdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("id <= " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andIdIn(List<Integer> values) {
            this.addCriterion("id in", values, "id");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andIdNotIn(List<Integer> values) {
            this.addCriterion("id not in", values, "id");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andIdBetween(Integer value1, Integer value2) {
            this.addCriterion("id between", value1, value2, "id");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andIdNotBetween(Integer value1, Integer value2) {
            this.addCriterion("id not between", value1, value2, "id");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andAccountnameIsNull() {
            this.addCriterion("accountname is null");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andAccountnameIsNotNull() {
            this.addCriterion("accountname is not null");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andAccountnameEqualTo(String value) {
            this.addCriterion("accountname =", value, "accountname");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andAccountnameEqualToColumn(Column column) {
            this.addCriterion("accountname = " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andAccountnameNotEqualTo(String value) {
            this.addCriterion("accountname <>", value, "accountname");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andAccountnameNotEqualToColumn(Column column) {
            this.addCriterion("accountname <> " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andAccountnameGreaterThan(String value) {
            this.addCriterion("accountname >", value, "accountname");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andAccountnameGreaterThanColumn(Column column) {
            this.addCriterion("accountname > " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andAccountnameGreaterThanOrEqualTo(String value) {
            this.addCriterion("accountname >=", value, "accountname");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andAccountnameGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("accountname >= " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andAccountnameLessThan(String value) {
            this.addCriterion("accountname <", value, "accountname");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andAccountnameLessThanColumn(Column column) {
            this.addCriterion("accountname < " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andAccountnameLessThanOrEqualTo(String value) {
            this.addCriterion("accountname <=", value, "accountname");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andAccountnameLessThanOrEqualToColumn(Column column) {
            this.addCriterion("accountname <= " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andAccountnameLike(String value) {
            this.addCriterion("accountname like", value, "accountname");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andAccountnameNotLike(String value) {
            this.addCriterion("accountname not like", value, "accountname");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andAccountnameIn(List<String> values) {
            this.addCriterion("accountname in", values, "accountname");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andAccountnameNotIn(List<String> values) {
            this.addCriterion("accountname not in", values, "accountname");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andAccountnameBetween(String value1, String value2) {
            this.addCriterion("accountname between", value1, value2, "accountname");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andAccountnameNotBetween(String value1, String value2) {
            this.addCriterion("accountname not between", value1, value2, "accountname");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andCoinIsNull() {
            this.addCriterion("coin is null");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andCoinIsNotNull() {
            this.addCriterion("coin is not null");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andCoinEqualTo(Integer value) {
            this.addCriterion("coin =", value, "coin");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andCoinEqualToColumn(Column column) {
            this.addCriterion("coin = " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andCoinNotEqualTo(Integer value) {
            this.addCriterion("coin <>", value, "coin");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andCoinNotEqualToColumn(Column column) {
            this.addCriterion("coin <> " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andCoinGreaterThan(Integer value) {
            this.addCriterion("coin >", value, "coin");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andCoinGreaterThanColumn(Column column) {
            this.addCriterion("coin > " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andCoinGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("coin >=", value, "coin");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andCoinGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("coin >= " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andCoinLessThan(Integer value) {
            this.addCriterion("coin <", value, "coin");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andCoinLessThanColumn(Column column) {
            this.addCriterion("coin < " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andCoinLessThanOrEqualTo(Integer value) {
            this.addCriterion("coin <=", value, "coin");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andCoinLessThanOrEqualToColumn(Column column) {
            this.addCriterion("coin <= " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andCoinIn(List<Integer> values) {
            this.addCriterion("coin in", values, "coin");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andCoinNotIn(List<Integer> values) {
            this.addCriterion("coin not in", values, "coin");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andCoinBetween(Integer value1, Integer value2) {
            this.addCriterion("coin between", value1, value2, "coin");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andCoinNotBetween(Integer value1, Integer value2) {
            this.addCriterion("coin not between", value1, value2, "coin");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andStateIsNull() {
            this.addCriterion("`state` is null");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andStateIsNotNull() {
            this.addCriterion("`state` is not null");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andStateEqualTo(Integer value) {
            this.addCriterion("`state` =", value, "state");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andStateEqualToColumn(Column column) {
            this.addCriterion("`state` = " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andStateNotEqualTo(Integer value) {
            this.addCriterion("`state` <>", value, "state");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andStateNotEqualToColumn(Column column) {
            this.addCriterion("`state` <> " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andStateGreaterThan(Integer value) {
            this.addCriterion("`state` >", value, "state");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andStateGreaterThanColumn(Column column) {
            this.addCriterion("`state` > " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andStateGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("`state` >=", value, "state");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andStateGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`state` >= " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andStateLessThan(Integer value) {
            this.addCriterion("`state` <", value, "state");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andStateLessThanColumn(Column column) {
            this.addCriterion("`state` < " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andStateLessThanOrEqualTo(Integer value) {
            this.addCriterion("`state` <=", value, "state");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andStateLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`state` <= " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andStateIn(List<Integer> values) {
            this.addCriterion("`state` in", values, "state");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andStateNotIn(List<Integer> values) {
            this.addCriterion("`state` not in", values, "state");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andStateBetween(Integer value1, Integer value2) {
            this.addCriterion("`state` between", value1, value2, "state");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andStateNotBetween(Integer value1, Integer value2) {
            this.addCriterion("`state` not between", value1, value2, "state");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andAddTimeIsNull() {
            this.addCriterion("add_time is null");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andAddTimeIsNotNull() {
            this.addCriterion("add_time is not null");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andAddTimeEqualTo(LocalDateTime value) {
            this.addCriterion("add_time =", value, "addTime");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andAddTimeEqualToColumn(Column column) {
            this.addCriterion("add_time = " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andAddTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <>", value, "addTime");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andAddTimeNotEqualToColumn(Column column) {
            this.addCriterion("add_time <> " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andAddTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("add_time >", value, "addTime");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andAddTimeGreaterThanColumn(Column column) {
            this.addCriterion("add_time > " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andAddTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time >=", value, "addTime");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andAddTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time >= " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andAddTimeLessThan(LocalDateTime value) {
            this.addCriterion("add_time <", value, "addTime");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andAddTimeLessThanColumn(Column column) {
            this.addCriterion("add_time < " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andAddTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <=", value, "addTime");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andAddTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time <= " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andAddTimeIn(List<LocalDateTime> values) {
            this.addCriterion("add_time in", values, "addTime");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andAddTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("add_time not in", values, "addTime");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andAddTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time between", value1, value2, "addTime");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andAddTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time not between", value1, value2, "addTime");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andUpdateTimeIsNull() {
            this.addCriterion("update_time is null");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andUpdateTimeIsNotNull() {
            this.addCriterion("update_time is not null");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andUpdateTimeEqualTo(LocalDateTime value) {
            this.addCriterion("update_time =", value, "updateTime");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andUpdateTimeEqualToColumn(Column column) {
            this.addCriterion("update_time = " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andUpdateTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <>", value, "updateTime");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andUpdateTimeNotEqualToColumn(Column column) {
            this.addCriterion("update_time <> " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andUpdateTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("update_time >", value, "updateTime");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andUpdateTimeGreaterThanColumn(Column column) {
            this.addCriterion("update_time > " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andUpdateTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time >=", value, "updateTime");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andUpdateTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time >= " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andUpdateTimeLessThan(LocalDateTime value) {
            this.addCriterion("update_time <", value, "updateTime");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andUpdateTimeLessThanColumn(Column column) {
            this.addCriterion("update_time < " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andUpdateTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <=", value, "updateTime");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andUpdateTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time <= " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andUpdateTimeIn(List<LocalDateTime> values) {
            this.addCriterion("update_time in", values, "updateTime");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andUpdateTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("update_time not in", values, "updateTime");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andUpdateTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time between", value1, value2, "updateTime");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andUpdateTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time not between", value1, value2, "updateTime");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andDeletedIsNull() {
            this.addCriterion("deleted is null");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andDeletedIsNotNull() {
            this.addCriterion("deleted is not null");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andDeletedEqualTo(Boolean value) {
            this.addCriterion("deleted =", value, "deleted");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andDeletedEqualToColumn(Column column) {
            this.addCriterion("deleted = " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andDeletedNotEqualTo(Boolean value) {
            this.addCriterion("deleted <>", value, "deleted");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andDeletedNotEqualToColumn(Column column) {
            this.addCriterion("deleted <> " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andDeletedGreaterThan(Boolean value) {
            this.addCriterion("deleted >", value, "deleted");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andDeletedGreaterThanColumn(Column column) {
            this.addCriterion("deleted > " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andDeletedGreaterThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted >=", value, "deleted");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andDeletedGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted >= " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andDeletedLessThan(Boolean value) {
            this.addCriterion("deleted <", value, "deleted");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andDeletedLessThanColumn(Column column) {
            this.addCriterion("deleted < " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andDeletedLessThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted <=", value, "deleted");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andDeletedLessThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted <= " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andDeletedIn(List<Boolean> values) {
            this.addCriterion("deleted in", values, "deleted");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andDeletedNotIn(List<Boolean> values) {
            this.addCriterion("deleted not in", values, "deleted");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andDeletedBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted between", value1, value2, "deleted");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andDeletedNotBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted not between", value1, value2, "deleted");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andMoneyIsNull() {
            this.addCriterion("money is null");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andMoneyIsNotNull() {
            this.addCriterion("money is not null");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andMoneyEqualTo(Integer value) {
            this.addCriterion("money =", value, "money");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andMoneyEqualToColumn(Column column) {
            this.addCriterion("money = " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andMoneyNotEqualTo(Integer value) {
            this.addCriterion("money <>", value, "money");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andMoneyNotEqualToColumn(Column column) {
            this.addCriterion("money <> " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andMoneyGreaterThan(Integer value) {
            this.addCriterion("money >", value, "money");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andMoneyGreaterThanColumn(Column column) {
            this.addCriterion("money > " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andMoneyGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("money >=", value, "money");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andMoneyGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("money >= " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andMoneyLessThan(Integer value) {
            this.addCriterion("money <", value, "money");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andMoneyLessThanColumn(Column column) {
            this.addCriterion("money < " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andMoneyLessThanOrEqualTo(Integer value) {
            this.addCriterion("money <=", value, "money");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andMoneyLessThanOrEqualToColumn(Column column) {
            this.addCriterion("money <= " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andMoneyIn(List<Integer> values) {
            this.addCriterion("money in", values, "money");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andMoneyNotIn(List<Integer> values) {
            this.addCriterion("money not in", values, "money");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andMoneyBetween(Integer value1, Integer value2) {
            this.addCriterion("money between", value1, value2, "money");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andMoneyNotBetween(Integer value1, Integer value2) {
            this.addCriterion("money not between", value1, value2, "money");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andCodeIsNull() {
            this.addCriterion("code is null");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andCodeIsNotNull() {
            this.addCriterion("code is not null");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andCodeEqualTo(String value) {
            this.addCriterion("code =", value, "code");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andCodeEqualToColumn(Column column) {
            this.addCriterion("code = " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andCodeNotEqualTo(String value) {
            this.addCriterion("code <>", value, "code");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andCodeNotEqualToColumn(Column column) {
            this.addCriterion("code <> " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andCodeGreaterThan(String value) {
            this.addCriterion("code >", value, "code");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andCodeGreaterThanColumn(Column column) {
            this.addCriterion("code > " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andCodeGreaterThanOrEqualTo(String value) {
            this.addCriterion("code >=", value, "code");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andCodeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("code >= " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andCodeLessThan(String value) {
            this.addCriterion("code <", value, "code");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andCodeLessThanColumn(Column column) {
            this.addCriterion("code < " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andCodeLessThanOrEqualTo(String value) {
            this.addCriterion("code <=", value, "code");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andCodeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("code <= " + column.getEscapedColumnName());
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andCodeLike(String value) {
            this.addCriterion("code like", value, "code");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andCodeNotLike(String value) {
            this.addCriterion("code not like", value, "code");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andCodeIn(List<String> values) {
            this.addCriterion("code in", values, "code");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andCodeNotIn(List<String> values) {
            this.addCriterion("code not in", values, "code");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andCodeBetween(String value1, String value2) {
            this.addCriterion("code between", value1, value2, "code");
            return (ChargeExample.Criteria)this;
        }

        public ChargeExample.Criteria andCodeNotBetween(String value1, String value2) {
            this.addCriterion("code not between", value1, value2, "code");
            return (ChargeExample.Criteria)this;
        }
    }
}
