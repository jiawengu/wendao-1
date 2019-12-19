//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.domain.example;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.linlinjava.litemall.db.domain.ZhuangbeiInfo.Column;
import org.linlinjava.litemall.db.domain.ZhuangbeiInfo.Deleted;

public class ZhuangbeiInfoExample {
    protected String orderByClause;
    protected boolean distinct;
    protected List<ZhuangbeiInfoExample.Criteria> oredCriteria = new ArrayList();

    public ZhuangbeiInfoExample() {
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

    public List<ZhuangbeiInfoExample.Criteria> getOredCriteria() {
        return this.oredCriteria;
    }

    public void or(ZhuangbeiInfoExample.Criteria criteria) {
        this.oredCriteria.add(criteria);
    }

    public ZhuangbeiInfoExample.Criteria or() {
        ZhuangbeiInfoExample.Criteria criteria = this.createCriteriaInternal();
        this.oredCriteria.add(criteria);
        return criteria;
    }

    public ZhuangbeiInfoExample orderBy(String orderByClause) {
        this.setOrderByClause(orderByClause);
        return this;
    }

    public ZhuangbeiInfoExample orderBy(String... orderByClauses) {
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

    public ZhuangbeiInfoExample.Criteria createCriteria() {
        ZhuangbeiInfoExample.Criteria criteria = this.createCriteriaInternal();
        if (this.oredCriteria.size() == 0) {
            this.oredCriteria.add(criteria);
        }

        return criteria;
    }

    protected ZhuangbeiInfoExample.Criteria createCriteriaInternal() {
        ZhuangbeiInfoExample.Criteria criteria = new ZhuangbeiInfoExample.Criteria(this);
        return criteria;
    }

    public void clear() {
        this.oredCriteria.clear();
        this.orderByClause = null;
        this.distinct = false;
    }

    public static ZhuangbeiInfoExample.Criteria newAndCreateCriteria() {
        ZhuangbeiInfoExample example = new ZhuangbeiInfoExample();
        return example.createCriteria();
    }

    public ZhuangbeiInfoExample when(boolean condition, ZhuangbeiInfoExample.IExampleWhen then) {
        if (condition) {
            then.example(this);
        }

        return this;
    }

    public ZhuangbeiInfoExample when(boolean condition, ZhuangbeiInfoExample.IExampleWhen then, ZhuangbeiInfoExample.IExampleWhen otherwise) {
        if (condition) {
            then.example(this);
        } else {
            otherwise.example(this);
        }

        return this;
    }

    public interface IExampleWhen {
        void example(ZhuangbeiInfoExample example);
    }

    public interface ICriteriaWhen {
        void criteria(ZhuangbeiInfoExample.Criteria criteria);
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

    public static class Criteria extends ZhuangbeiInfoExample.GeneratedCriteria {
        private ZhuangbeiInfoExample example;

        protected Criteria(ZhuangbeiInfoExample example) {
            this.example = example;
        }

        public ZhuangbeiInfoExample example() {
            return this.example;
        }

        /** @deprecated */
        @Deprecated
        public ZhuangbeiInfoExample.Criteria andIf(boolean ifAdd, ZhuangbeiInfoExample.Criteria.ICriteriaAdd add) {
            if (ifAdd) {
                add.add(this);
            }

            return this;
        }

        public ZhuangbeiInfoExample.Criteria when(boolean condition, ZhuangbeiInfoExample.ICriteriaWhen then) {
            if (condition) {
                then.criteria(this);
            }

            return this;
        }

        public ZhuangbeiInfoExample.Criteria when(boolean condition, ZhuangbeiInfoExample.ICriteriaWhen then, ZhuangbeiInfoExample.ICriteriaWhen otherwise) {
            if (condition) {
                then.criteria(this);
            } else {
                otherwise.criteria(this);
            }

            return this;
        }

        public ZhuangbeiInfoExample.Criteria andLogicalDeleted(boolean deleted) {
            return deleted ? this.andDeletedEqualTo(Deleted.IS_DELETED.value()) : this.andDeletedNotEqualTo(Deleted.IS_DELETED.value());
        }

        /** @deprecated */
        @Deprecated
        public interface ICriteriaAdd {
            ZhuangbeiInfoExample.Criteria add(ZhuangbeiInfoExample.Criteria add);
        }
    }

    protected abstract static class GeneratedCriteria {
        protected List<ZhuangbeiInfoExample.Criterion> criteria = new ArrayList();

        protected GeneratedCriteria() {
        }

        public boolean isValid() {
            return this.criteria.size() > 0;
        }

        public List<ZhuangbeiInfoExample.Criterion> getAllCriteria() {
            return this.criteria;
        }

        public List<ZhuangbeiInfoExample.Criterion> getCriteria() {
            return this.criteria;
        }

        protected void addCriterion(String condition) {
            if (condition == null) {
                throw new RuntimeException("Value for condition cannot be null");
            } else {
                this.criteria.add(new ZhuangbeiInfoExample.Criterion(condition));
            }
        }

        protected void addCriterion(String condition, Object value, String property) {
            if (value == null) {
                throw new RuntimeException("Value for " + property + " cannot be null");
            } else {
                this.criteria.add(new ZhuangbeiInfoExample.Criterion(condition, value));
            }
        }

        protected void addCriterion(String condition, Object value1, Object value2, String property) {
            if (value1 != null && value2 != null) {
                this.criteria.add(new ZhuangbeiInfoExample.Criterion(condition, value1, value2));
            } else {
                throw new RuntimeException("Between values for " + property + " cannot be null");
            }
        }

        public ZhuangbeiInfoExample.Criteria andIdIsNull() {
            this.addCriterion("id is null");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andIdIsNotNull() {
            this.addCriterion("id is not null");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andIdEqualTo(Integer value) {
            this.addCriterion("id =", value, "id");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andIdEqualToColumn(Column column) {
            this.addCriterion("id = " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andIdNotEqualTo(Integer value) {
            this.addCriterion("id <>", value, "id");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andIdNotEqualToColumn(Column column) {
            this.addCriterion("id <> " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andIdGreaterThan(Integer value) {
            this.addCriterion("id >", value, "id");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andIdGreaterThanColumn(Column column) {
            this.addCriterion("id > " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andIdGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("id >=", value, "id");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andIdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("id >= " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andIdLessThan(Integer value) {
            this.addCriterion("id <", value, "id");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andIdLessThanColumn(Column column) {
            this.addCriterion("id < " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andIdLessThanOrEqualTo(Integer value) {
            this.addCriterion("id <=", value, "id");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andIdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("id <= " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andIdIn(List<Integer> values) {
            this.addCriterion("id in", values, "id");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andIdNotIn(List<Integer> values) {
            this.addCriterion("id not in", values, "id");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andIdBetween(Integer value1, Integer value2) {
            this.addCriterion("id between", value1, value2, "id");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andIdNotBetween(Integer value1, Integer value2) {
            this.addCriterion("id not between", value1, value2, "id");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAttribIsNull() {
            this.addCriterion("attrib is null");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAttribIsNotNull() {
            this.addCriterion("attrib is not null");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAttribEqualTo(Integer value) {
            this.addCriterion("attrib =", value, "attrib");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAttribEqualToColumn(Column column) {
            this.addCriterion("attrib = " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAttribNotEqualTo(Integer value) {
            this.addCriterion("attrib <>", value, "attrib");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAttribNotEqualToColumn(Column column) {
            this.addCriterion("attrib <> " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAttribGreaterThan(Integer value) {
            this.addCriterion("attrib >", value, "attrib");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAttribGreaterThanColumn(Column column) {
            this.addCriterion("attrib > " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAttribGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("attrib >=", value, "attrib");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAttribGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("attrib >= " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAttribLessThan(Integer value) {
            this.addCriterion("attrib <", value, "attrib");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAttribLessThanColumn(Column column) {
            this.addCriterion("attrib < " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAttribLessThanOrEqualTo(Integer value) {
            this.addCriterion("attrib <=", value, "attrib");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAttribLessThanOrEqualToColumn(Column column) {
            this.addCriterion("attrib <= " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAttribIn(List<Integer> values) {
            this.addCriterion("attrib in", values, "attrib");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAttribNotIn(List<Integer> values) {
            this.addCriterion("attrib not in", values, "attrib");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAttribBetween(Integer value1, Integer value2) {
            this.addCriterion("attrib between", value1, value2, "attrib");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAttribNotBetween(Integer value1, Integer value2) {
            this.addCriterion("attrib not between", value1, value2, "attrib");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAmountIsNull() {
            this.addCriterion("amount is null");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAmountIsNotNull() {
            this.addCriterion("amount is not null");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAmountEqualTo(Integer value) {
            this.addCriterion("amount =", value, "amount");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAmountEqualToColumn(Column column) {
            this.addCriterion("amount = " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAmountNotEqualTo(Integer value) {
            this.addCriterion("amount <>", value, "amount");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAmountNotEqualToColumn(Column column) {
            this.addCriterion("amount <> " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAmountGreaterThan(Integer value) {
            this.addCriterion("amount >", value, "amount");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAmountGreaterThanColumn(Column column) {
            this.addCriterion("amount > " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAmountGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("amount >=", value, "amount");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAmountGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("amount >= " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAmountLessThan(Integer value) {
            this.addCriterion("amount <", value, "amount");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAmountLessThanColumn(Column column) {
            this.addCriterion("amount < " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAmountLessThanOrEqualTo(Integer value) {
            this.addCriterion("amount <=", value, "amount");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAmountLessThanOrEqualToColumn(Column column) {
            this.addCriterion("amount <= " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAmountIn(List<Integer> values) {
            this.addCriterion("amount in", values, "amount");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAmountNotIn(List<Integer> values) {
            this.addCriterion("amount not in", values, "amount");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAmountBetween(Integer value1, Integer value2) {
            this.addCriterion("amount between", value1, value2, "amount");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAmountNotBetween(Integer value1, Integer value2) {
            this.addCriterion("amount not between", value1, value2, "amount");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andTypeIsNull() {
            this.addCriterion("`type` is null");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andTypeIsNotNull() {
            this.addCriterion("`type` is not null");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andTypeEqualTo(Integer value) {
            this.addCriterion("`type` =", value, "type");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andTypeEqualToColumn(Column column) {
            this.addCriterion("`type` = " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andTypeNotEqualTo(Integer value) {
            this.addCriterion("`type` <>", value, "type");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andTypeNotEqualToColumn(Column column) {
            this.addCriterion("`type` <> " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andTypeGreaterThan(Integer value) {
            this.addCriterion("`type` >", value, "type");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andTypeGreaterThanColumn(Column column) {
            this.addCriterion("`type` > " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andTypeGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("`type` >=", value, "type");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andTypeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`type` >= " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andTypeLessThan(Integer value) {
            this.addCriterion("`type` <", value, "type");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andTypeLessThanColumn(Column column) {
            this.addCriterion("`type` < " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andTypeLessThanOrEqualTo(Integer value) {
            this.addCriterion("`type` <=", value, "type");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andTypeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`type` <= " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andTypeIn(List<Integer> values) {
            this.addCriterion("`type` in", values, "type");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andTypeNotIn(List<Integer> values) {
            this.addCriterion("`type` not in", values, "type");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andTypeBetween(Integer value1, Integer value2) {
            this.addCriterion("`type` between", value1, value2, "type");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andTypeNotBetween(Integer value1, Integer value2) {
            this.addCriterion("`type` not between", value1, value2, "type");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andStrIsNull() {
            this.addCriterion("str is null");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andStrIsNotNull() {
            this.addCriterion("str is not null");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andStrEqualTo(String value) {
            this.addCriterion("str =", value, "str");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andStrEqualToColumn(Column column) {
            this.addCriterion("str = " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andStrNotEqualTo(String value) {
            this.addCriterion("str <>", value, "str");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andStrNotEqualToColumn(Column column) {
            this.addCriterion("str <> " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andStrGreaterThan(String value) {
            this.addCriterion("str >", value, "str");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andStrGreaterThanColumn(Column column) {
            this.addCriterion("str > " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andStrGreaterThanOrEqualTo(String value) {
            this.addCriterion("str >=", value, "str");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andStrGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("str >= " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andStrLessThan(String value) {
            this.addCriterion("str <", value, "str");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andStrLessThanColumn(Column column) {
            this.addCriterion("str < " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andStrLessThanOrEqualTo(String value) {
            this.addCriterion("str <=", value, "str");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andStrLessThanOrEqualToColumn(Column column) {
            this.addCriterion("str <= " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andStrLike(String value) {
            this.addCriterion("str like", value, "str");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andStrNotLike(String value) {
            this.addCriterion("str not like", value, "str");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andStrIn(List<String> values) {
            this.addCriterion("str in", values, "str");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andStrNotIn(List<String> values) {
            this.addCriterion("str not in", values, "str");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andStrBetween(String value1, String value2) {
            this.addCriterion("str between", value1, value2, "str");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andStrNotBetween(String value1, String value2) {
            this.addCriterion("str not between", value1, value2, "str");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andQualityIsNull() {
            this.addCriterion("quality is null");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andQualityIsNotNull() {
            this.addCriterion("quality is not null");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andQualityEqualTo(String value) {
            this.addCriterion("quality =", value, "quality");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andQualityEqualToColumn(Column column) {
            this.addCriterion("quality = " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andQualityNotEqualTo(String value) {
            this.addCriterion("quality <>", value, "quality");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andQualityNotEqualToColumn(Column column) {
            this.addCriterion("quality <> " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andQualityGreaterThan(String value) {
            this.addCriterion("quality >", value, "quality");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andQualityGreaterThanColumn(Column column) {
            this.addCriterion("quality > " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andQualityGreaterThanOrEqualTo(String value) {
            this.addCriterion("quality >=", value, "quality");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andQualityGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("quality >= " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andQualityLessThan(String value) {
            this.addCriterion("quality <", value, "quality");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andQualityLessThanColumn(Column column) {
            this.addCriterion("quality < " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andQualityLessThanOrEqualTo(String value) {
            this.addCriterion("quality <=", value, "quality");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andQualityLessThanOrEqualToColumn(Column column) {
            this.addCriterion("quality <= " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andQualityLike(String value) {
            this.addCriterion("quality like", value, "quality");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andQualityNotLike(String value) {
            this.addCriterion("quality not like", value, "quality");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andQualityIn(List<String> values) {
            this.addCriterion("quality in", values, "quality");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andQualityNotIn(List<String> values) {
            this.addCriterion("quality not in", values, "quality");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andQualityBetween(String value1, String value2) {
            this.addCriterion("quality between", value1, value2, "quality");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andQualityNotBetween(String value1, String value2) {
            this.addCriterion("quality not between", value1, value2, "quality");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andMasterIsNull() {
            this.addCriterion("master is null");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andMasterIsNotNull() {
            this.addCriterion("master is not null");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andMasterEqualTo(Integer value) {
            this.addCriterion("master =", value, "master");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andMasterEqualToColumn(Column column) {
            this.addCriterion("master = " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andMasterNotEqualTo(Integer value) {
            this.addCriterion("master <>", value, "master");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andMasterNotEqualToColumn(Column column) {
            this.addCriterion("master <> " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andMasterGreaterThan(Integer value) {
            this.addCriterion("master >", value, "master");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andMasterGreaterThanColumn(Column column) {
            this.addCriterion("master > " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andMasterGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("master >=", value, "master");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andMasterGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("master >= " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andMasterLessThan(Integer value) {
            this.addCriterion("master <", value, "master");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andMasterLessThanColumn(Column column) {
            this.addCriterion("master < " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andMasterLessThanOrEqualTo(Integer value) {
            this.addCriterion("master <=", value, "master");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andMasterLessThanOrEqualToColumn(Column column) {
            this.addCriterion("master <= " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andMasterIn(List<Integer> values) {
            this.addCriterion("master in", values, "master");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andMasterNotIn(List<Integer> values) {
            this.addCriterion("master not in", values, "master");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andMasterBetween(Integer value1, Integer value2) {
            this.addCriterion("master between", value1, value2, "master");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andMasterNotBetween(Integer value1, Integer value2) {
            this.addCriterion("master not between", value1, value2, "master");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andMetalIsNull() {
            this.addCriterion("metal is null");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andMetalIsNotNull() {
            this.addCriterion("metal is not null");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andMetalEqualTo(Integer value) {
            this.addCriterion("metal =", value, "metal");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andMetalEqualToColumn(Column column) {
            this.addCriterion("metal = " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andMetalNotEqualTo(Integer value) {
            this.addCriterion("metal <>", value, "metal");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andMetalNotEqualToColumn(Column column) {
            this.addCriterion("metal <> " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andMetalGreaterThan(Integer value) {
            this.addCriterion("metal >", value, "metal");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andMetalGreaterThanColumn(Column column) {
            this.addCriterion("metal > " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andMetalGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("metal >=", value, "metal");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andMetalGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("metal >= " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andMetalLessThan(Integer value) {
            this.addCriterion("metal <", value, "metal");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andMetalLessThanColumn(Column column) {
            this.addCriterion("metal < " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andMetalLessThanOrEqualTo(Integer value) {
            this.addCriterion("metal <=", value, "metal");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andMetalLessThanOrEqualToColumn(Column column) {
            this.addCriterion("metal <= " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andMetalIn(List<Integer> values) {
            this.addCriterion("metal in", values, "metal");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andMetalNotIn(List<Integer> values) {
            this.addCriterion("metal not in", values, "metal");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andMetalBetween(Integer value1, Integer value2) {
            this.addCriterion("metal between", value1, value2, "metal");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andMetalNotBetween(Integer value1, Integer value2) {
            this.addCriterion("metal not between", value1, value2, "metal");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andManaIsNull() {
            this.addCriterion("mana is null");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andManaIsNotNull() {
            this.addCriterion("mana is not null");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andManaEqualTo(Integer value) {
            this.addCriterion("mana =", value, "mana");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andManaEqualToColumn(Column column) {
            this.addCriterion("mana = " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andManaNotEqualTo(Integer value) {
            this.addCriterion("mana <>", value, "mana");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andManaNotEqualToColumn(Column column) {
            this.addCriterion("mana <> " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andManaGreaterThan(Integer value) {
            this.addCriterion("mana >", value, "mana");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andManaGreaterThanColumn(Column column) {
            this.addCriterion("mana > " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andManaGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("mana >=", value, "mana");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andManaGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("mana >= " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andManaLessThan(Integer value) {
            this.addCriterion("mana <", value, "mana");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andManaLessThanColumn(Column column) {
            this.addCriterion("mana < " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andManaLessThanOrEqualTo(Integer value) {
            this.addCriterion("mana <=", value, "mana");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andManaLessThanOrEqualToColumn(Column column) {
            this.addCriterion("mana <= " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andManaIn(List<Integer> values) {
            this.addCriterion("mana in", values, "mana");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andManaNotIn(List<Integer> values) {
            this.addCriterion("mana not in", values, "mana");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andManaBetween(Integer value1, Integer value2) {
            this.addCriterion("mana between", value1, value2, "mana");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andManaNotBetween(Integer value1, Integer value2) {
            this.addCriterion("mana not between", value1, value2, "mana");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAccurateIsNull() {
            this.addCriterion("accurate is null");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAccurateIsNotNull() {
            this.addCriterion("accurate is not null");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAccurateEqualTo(Integer value) {
            this.addCriterion("accurate =", value, "accurate");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAccurateEqualToColumn(Column column) {
            this.addCriterion("accurate = " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAccurateNotEqualTo(Integer value) {
            this.addCriterion("accurate <>", value, "accurate");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAccurateNotEqualToColumn(Column column) {
            this.addCriterion("accurate <> " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAccurateGreaterThan(Integer value) {
            this.addCriterion("accurate >", value, "accurate");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAccurateGreaterThanColumn(Column column) {
            this.addCriterion("accurate > " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAccurateGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("accurate >=", value, "accurate");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAccurateGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("accurate >= " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAccurateLessThan(Integer value) {
            this.addCriterion("accurate <", value, "accurate");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAccurateLessThanColumn(Column column) {
            this.addCriterion("accurate < " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAccurateLessThanOrEqualTo(Integer value) {
            this.addCriterion("accurate <=", value, "accurate");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAccurateLessThanOrEqualToColumn(Column column) {
            this.addCriterion("accurate <= " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAccurateIn(List<Integer> values) {
            this.addCriterion("accurate in", values, "accurate");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAccurateNotIn(List<Integer> values) {
            this.addCriterion("accurate not in", values, "accurate");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAccurateBetween(Integer value1, Integer value2) {
            this.addCriterion("accurate between", value1, value2, "accurate");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAccurateNotBetween(Integer value1, Integer value2) {
            this.addCriterion("accurate not between", value1, value2, "accurate");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDefIsNull() {
            this.addCriterion("def is null");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDefIsNotNull() {
            this.addCriterion("def is not null");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDefEqualTo(Integer value) {
            this.addCriterion("def =", value, "def");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDefEqualToColumn(Column column) {
            this.addCriterion("def = " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDefNotEqualTo(Integer value) {
            this.addCriterion("def <>", value, "def");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDefNotEqualToColumn(Column column) {
            this.addCriterion("def <> " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDefGreaterThan(Integer value) {
            this.addCriterion("def >", value, "def");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDefGreaterThanColumn(Column column) {
            this.addCriterion("def > " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDefGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("def >=", value, "def");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDefGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("def >= " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDefLessThan(Integer value) {
            this.addCriterion("def <", value, "def");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDefLessThanColumn(Column column) {
            this.addCriterion("def < " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDefLessThanOrEqualTo(Integer value) {
            this.addCriterion("def <=", value, "def");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDefLessThanOrEqualToColumn(Column column) {
            this.addCriterion("def <= " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDefIn(List<Integer> values) {
            this.addCriterion("def in", values, "def");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDefNotIn(List<Integer> values) {
            this.addCriterion("def not in", values, "def");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDefBetween(Integer value1, Integer value2) {
            this.addCriterion("def between", value1, value2, "def");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDefNotBetween(Integer value1, Integer value2) {
            this.addCriterion("def not between", value1, value2, "def");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDexIsNull() {
            this.addCriterion("dex is null");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDexIsNotNull() {
            this.addCriterion("dex is not null");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDexEqualTo(Integer value) {
            this.addCriterion("dex =", value, "dex");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDexEqualToColumn(Column column) {
            this.addCriterion("dex = " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDexNotEqualTo(Integer value) {
            this.addCriterion("dex <>", value, "dex");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDexNotEqualToColumn(Column column) {
            this.addCriterion("dex <> " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDexGreaterThan(Integer value) {
            this.addCriterion("dex >", value, "dex");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDexGreaterThanColumn(Column column) {
            this.addCriterion("dex > " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDexGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("dex >=", value, "dex");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDexGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("dex >= " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDexLessThan(Integer value) {
            this.addCriterion("dex <", value, "dex");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDexLessThanColumn(Column column) {
            this.addCriterion("dex < " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDexLessThanOrEqualTo(Integer value) {
            this.addCriterion("dex <=", value, "dex");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDexLessThanOrEqualToColumn(Column column) {
            this.addCriterion("dex <= " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDexIn(List<Integer> values) {
            this.addCriterion("dex in", values, "dex");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDexNotIn(List<Integer> values) {
            this.addCriterion("dex not in", values, "dex");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDexBetween(Integer value1, Integer value2) {
            this.addCriterion("dex between", value1, value2, "dex");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDexNotBetween(Integer value1, Integer value2) {
            this.addCriterion("dex not between", value1, value2, "dex");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andWizIsNull() {
            this.addCriterion("wiz is null");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andWizIsNotNull() {
            this.addCriterion("wiz is not null");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andWizEqualTo(Integer value) {
            this.addCriterion("wiz =", value, "wiz");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andWizEqualToColumn(Column column) {
            this.addCriterion("wiz = " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andWizNotEqualTo(Integer value) {
            this.addCriterion("wiz <>", value, "wiz");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andWizNotEqualToColumn(Column column) {
            this.addCriterion("wiz <> " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andWizGreaterThan(Integer value) {
            this.addCriterion("wiz >", value, "wiz");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andWizGreaterThanColumn(Column column) {
            this.addCriterion("wiz > " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andWizGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("wiz >=", value, "wiz");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andWizGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("wiz >= " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andWizLessThan(Integer value) {
            this.addCriterion("wiz <", value, "wiz");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andWizLessThanColumn(Column column) {
            this.addCriterion("wiz < " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andWizLessThanOrEqualTo(Integer value) {
            this.addCriterion("wiz <=", value, "wiz");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andWizLessThanOrEqualToColumn(Column column) {
            this.addCriterion("wiz <= " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andWizIn(List<Integer> values) {
            this.addCriterion("wiz in", values, "wiz");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andWizNotIn(List<Integer> values) {
            this.addCriterion("wiz not in", values, "wiz");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andWizBetween(Integer value1, Integer value2) {
            this.addCriterion("wiz between", value1, value2, "wiz");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andWizNotBetween(Integer value1, Integer value2) {
            this.addCriterion("wiz not between", value1, value2, "wiz");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andParryIsNull() {
            this.addCriterion("parry is null");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andParryIsNotNull() {
            this.addCriterion("parry is not null");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andParryEqualTo(Integer value) {
            this.addCriterion("parry =", value, "parry");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andParryEqualToColumn(Column column) {
            this.addCriterion("parry = " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andParryNotEqualTo(Integer value) {
            this.addCriterion("parry <>", value, "parry");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andParryNotEqualToColumn(Column column) {
            this.addCriterion("parry <> " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andParryGreaterThan(Integer value) {
            this.addCriterion("parry >", value, "parry");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andParryGreaterThanColumn(Column column) {
            this.addCriterion("parry > " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andParryGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("parry >=", value, "parry");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andParryGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("parry >= " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andParryLessThan(Integer value) {
            this.addCriterion("parry <", value, "parry");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andParryLessThanColumn(Column column) {
            this.addCriterion("parry < " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andParryLessThanOrEqualTo(Integer value) {
            this.addCriterion("parry <=", value, "parry");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andParryLessThanOrEqualToColumn(Column column) {
            this.addCriterion("parry <= " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andParryIn(List<Integer> values) {
            this.addCriterion("parry in", values, "parry");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andParryNotIn(List<Integer> values) {
            this.addCriterion("parry not in", values, "parry");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andParryBetween(Integer value1, Integer value2) {
            this.addCriterion("parry between", value1, value2, "parry");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andParryNotBetween(Integer value1, Integer value2) {
            this.addCriterion("parry not between", value1, value2, "parry");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAddTimeIsNull() {
            this.addCriterion("add_time is null");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAddTimeIsNotNull() {
            this.addCriterion("add_time is not null");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAddTimeEqualTo(LocalDateTime value) {
            this.addCriterion("add_time =", value, "addTime");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAddTimeEqualToColumn(Column column) {
            this.addCriterion("add_time = " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAddTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <>", value, "addTime");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAddTimeNotEqualToColumn(Column column) {
            this.addCriterion("add_time <> " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAddTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("add_time >", value, "addTime");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAddTimeGreaterThanColumn(Column column) {
            this.addCriterion("add_time > " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAddTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time >=", value, "addTime");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAddTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time >= " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAddTimeLessThan(LocalDateTime value) {
            this.addCriterion("add_time <", value, "addTime");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAddTimeLessThanColumn(Column column) {
            this.addCriterion("add_time < " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAddTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <=", value, "addTime");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAddTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time <= " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAddTimeIn(List<LocalDateTime> values) {
            this.addCriterion("add_time in", values, "addTime");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAddTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("add_time not in", values, "addTime");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAddTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time between", value1, value2, "addTime");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andAddTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time not between", value1, value2, "addTime");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andUpdateTimeIsNull() {
            this.addCriterion("update_time is null");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andUpdateTimeIsNotNull() {
            this.addCriterion("update_time is not null");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andUpdateTimeEqualTo(LocalDateTime value) {
            this.addCriterion("update_time =", value, "updateTime");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andUpdateTimeEqualToColumn(Column column) {
            this.addCriterion("update_time = " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andUpdateTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <>", value, "updateTime");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andUpdateTimeNotEqualToColumn(Column column) {
            this.addCriterion("update_time <> " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andUpdateTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("update_time >", value, "updateTime");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andUpdateTimeGreaterThanColumn(Column column) {
            this.addCriterion("update_time > " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andUpdateTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time >=", value, "updateTime");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andUpdateTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time >= " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andUpdateTimeLessThan(LocalDateTime value) {
            this.addCriterion("update_time <", value, "updateTime");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andUpdateTimeLessThanColumn(Column column) {
            this.addCriterion("update_time < " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andUpdateTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <=", value, "updateTime");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andUpdateTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time <= " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andUpdateTimeIn(List<LocalDateTime> values) {
            this.addCriterion("update_time in", values, "updateTime");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andUpdateTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("update_time not in", values, "updateTime");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andUpdateTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time between", value1, value2, "updateTime");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andUpdateTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time not between", value1, value2, "updateTime");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDeletedIsNull() {
            this.addCriterion("deleted is null");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDeletedIsNotNull() {
            this.addCriterion("deleted is not null");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDeletedEqualTo(Boolean value) {
            this.addCriterion("deleted =", value, "deleted");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDeletedEqualToColumn(Column column) {
            this.addCriterion("deleted = " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDeletedNotEqualTo(Boolean value) {
            this.addCriterion("deleted <>", value, "deleted");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDeletedNotEqualToColumn(Column column) {
            this.addCriterion("deleted <> " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDeletedGreaterThan(Boolean value) {
            this.addCriterion("deleted >", value, "deleted");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDeletedGreaterThanColumn(Column column) {
            this.addCriterion("deleted > " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDeletedGreaterThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted >=", value, "deleted");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDeletedGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted >= " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDeletedLessThan(Boolean value) {
            this.addCriterion("deleted <", value, "deleted");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDeletedLessThanColumn(Column column) {
            this.addCriterion("deleted < " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDeletedLessThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted <=", value, "deleted");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDeletedLessThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted <= " + column.getEscapedColumnName());
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDeletedIn(List<Boolean> values) {
            this.addCriterion("deleted in", values, "deleted");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDeletedNotIn(List<Boolean> values) {
            this.addCriterion("deleted not in", values, "deleted");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDeletedBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted between", value1, value2, "deleted");
            return (ZhuangbeiInfoExample.Criteria)this;
        }

        public ZhuangbeiInfoExample.Criteria andDeletedNotBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted not between", value1, value2, "deleted");
            return (ZhuangbeiInfoExample.Criteria)this;
        }
    }
}
