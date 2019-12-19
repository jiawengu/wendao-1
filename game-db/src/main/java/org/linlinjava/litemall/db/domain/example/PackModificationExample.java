//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.domain.example;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.linlinjava.litemall.db.domain.PackModification.Column;
import org.linlinjava.litemall.db.domain.PackModification.Deleted;

public class PackModificationExample {
    protected String orderByClause;
    protected boolean distinct;
    protected List<PackModificationExample.Criteria> oredCriteria = new ArrayList();

    public PackModificationExample() {
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

    public List<PackModificationExample.Criteria> getOredCriteria() {
        return this.oredCriteria;
    }

    public void or(PackModificationExample.Criteria criteria) {
        this.oredCriteria.add(criteria);
    }

    public PackModificationExample.Criteria or() {
        PackModificationExample.Criteria criteria = this.createCriteriaInternal();
        this.oredCriteria.add(criteria);
        return criteria;
    }

    public PackModificationExample orderBy(String orderByClause) {
        this.setOrderByClause(orderByClause);
        return this;
    }

    public PackModificationExample orderBy(String... orderByClauses) {
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

    public PackModificationExample.Criteria createCriteria() {
        PackModificationExample.Criteria criteria = this.createCriteriaInternal();
        if (this.oredCriteria.size() == 0) {
            this.oredCriteria.add(criteria);
        }

        return criteria;
    }

    protected PackModificationExample.Criteria createCriteriaInternal() {
        PackModificationExample.Criteria criteria = new PackModificationExample.Criteria(this);
        return criteria;
    }

    public void clear() {
        this.oredCriteria.clear();
        this.orderByClause = null;
        this.distinct = false;
    }

    public static PackModificationExample.Criteria newAndCreateCriteria() {
        PackModificationExample example = new PackModificationExample();
        return example.createCriteria();
    }

    public PackModificationExample when(boolean condition, PackModificationExample.IExampleWhen then) {
        if (condition) {
            then.example(this);
        }

        return this;
    }

    public PackModificationExample when(boolean condition, PackModificationExample.IExampleWhen then, PackModificationExample.IExampleWhen otherwise) {
        if (condition) {
            then.example(this);
        } else {
            otherwise.example(this);
        }

        return this;
    }

    public interface IExampleWhen {
        void example(PackModificationExample example);
    }

    public interface ICriteriaWhen {
        void criteria(PackModificationExample.Criteria criteria);
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

    public static class Criteria extends PackModificationExample.GeneratedCriteria {
        private PackModificationExample example;

        protected Criteria(PackModificationExample example) {
            this.example = example;
        }

        public PackModificationExample example() {
            return this.example;
        }

        /** @deprecated */
        @Deprecated
        public PackModificationExample.Criteria andIf(boolean ifAdd, PackModificationExample.Criteria.ICriteriaAdd add) {
            if (ifAdd) {
                add.add(this);
            }

            return this;
        }

        public PackModificationExample.Criteria when(boolean condition, PackModificationExample.ICriteriaWhen then) {
            if (condition) {
                then.criteria(this);
            }

            return this;
        }

        public PackModificationExample.Criteria when(boolean condition, PackModificationExample.ICriteriaWhen then, PackModificationExample.ICriteriaWhen otherwise) {
            if (condition) {
                then.criteria(this);
            } else {
                otherwise.criteria(this);
            }

            return this;
        }

        public PackModificationExample.Criteria andLogicalDeleted(boolean deleted) {
            return deleted ? this.andDeletedEqualTo(Deleted.IS_DELETED.value()) : this.andDeletedNotEqualTo(Deleted.IS_DELETED.value());
        }

        /** @deprecated */
        @Deprecated
        public interface ICriteriaAdd {
            PackModificationExample.Criteria add(PackModificationExample.Criteria add);
        }
    }

    protected abstract static class GeneratedCriteria {
        protected List<PackModificationExample.Criterion> criteria = new ArrayList();

        protected GeneratedCriteria() {
        }

        public boolean isValid() {
            return this.criteria.size() > 0;
        }

        public List<PackModificationExample.Criterion> getAllCriteria() {
            return this.criteria;
        }

        public List<PackModificationExample.Criterion> getCriteria() {
            return this.criteria;
        }

        protected void addCriterion(String condition) {
            if (condition == null) {
                throw new RuntimeException("Value for condition cannot be null");
            } else {
                this.criteria.add(new PackModificationExample.Criterion(condition));
            }
        }

        protected void addCriterion(String condition, Object value, String property) {
            if (value == null) {
                throw new RuntimeException("Value for " + property + " cannot be null");
            } else {
                this.criteria.add(new PackModificationExample.Criterion(condition, value));
            }
        }

        protected void addCriterion(String condition, Object value1, Object value2, String property) {
            if (value1 != null && value2 != null) {
                this.criteria.add(new PackModificationExample.Criterion(condition, value1, value2));
            } else {
                throw new RuntimeException("Between values for " + property + " cannot be null");
            }
        }

        public PackModificationExample.Criteria andIdIsNull() {
            this.addCriterion("id is null");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andIdIsNotNull() {
            this.addCriterion("id is not null");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andIdEqualTo(Integer value) {
            this.addCriterion("id =", value, "id");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andIdEqualToColumn(Column column) {
            this.addCriterion("id = " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andIdNotEqualTo(Integer value) {
            this.addCriterion("id <>", value, "id");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andIdNotEqualToColumn(Column column) {
            this.addCriterion("id <> " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andIdGreaterThan(Integer value) {
            this.addCriterion("id >", value, "id");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andIdGreaterThanColumn(Column column) {
            this.addCriterion("id > " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andIdGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("id >=", value, "id");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andIdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("id >= " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andIdLessThan(Integer value) {
            this.addCriterion("id <", value, "id");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andIdLessThanColumn(Column column) {
            this.addCriterion("id < " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andIdLessThanOrEqualTo(Integer value) {
            this.addCriterion("id <=", value, "id");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andIdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("id <= " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andIdIn(List<Integer> values) {
            this.addCriterion("id in", values, "id");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andIdNotIn(List<Integer> values) {
            this.addCriterion("id not in", values, "id");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andIdBetween(Integer value1, Integer value2) {
            this.addCriterion("id between", value1, value2, "id");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andIdNotBetween(Integer value1, Integer value2) {
            this.addCriterion("id not between", value1, value2, "id");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andAliasIsNull() {
            this.addCriterion("`alias` is null");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andAliasIsNotNull() {
            this.addCriterion("`alias` is not null");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andAliasEqualTo(String value) {
            this.addCriterion("`alias` =", value, "alias");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andAliasEqualToColumn(Column column) {
            this.addCriterion("`alias` = " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andAliasNotEqualTo(String value) {
            this.addCriterion("`alias` <>", value, "alias");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andAliasNotEqualToColumn(Column column) {
            this.addCriterion("`alias` <> " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andAliasGreaterThan(String value) {
            this.addCriterion("`alias` >", value, "alias");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andAliasGreaterThanColumn(Column column) {
            this.addCriterion("`alias` > " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andAliasGreaterThanOrEqualTo(String value) {
            this.addCriterion("`alias` >=", value, "alias");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andAliasGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`alias` >= " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andAliasLessThan(String value) {
            this.addCriterion("`alias` <", value, "alias");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andAliasLessThanColumn(Column column) {
            this.addCriterion("`alias` < " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andAliasLessThanOrEqualTo(String value) {
            this.addCriterion("`alias` <=", value, "alias");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andAliasLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`alias` <= " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andAliasLike(String value) {
            this.addCriterion("`alias` like", value, "alias");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andAliasNotLike(String value) {
            this.addCriterion("`alias` not like", value, "alias");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andAliasIn(List<String> values) {
            this.addCriterion("`alias` in", values, "alias");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andAliasNotIn(List<String> values) {
            this.addCriterion("`alias` not in", values, "alias");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andAliasBetween(String value1, String value2) {
            this.addCriterion("`alias` between", value1, value2, "alias");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andAliasNotBetween(String value1, String value2) {
            this.addCriterion("`alias` not between", value1, value2, "alias");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andFasionTypeIsNull() {
            this.addCriterion("fasion_type is null");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andFasionTypeIsNotNull() {
            this.addCriterion("fasion_type is not null");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andFasionTypeEqualTo(String value) {
            this.addCriterion("fasion_type =", value, "fasionType");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andFasionTypeEqualToColumn(Column column) {
            this.addCriterion("fasion_type = " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andFasionTypeNotEqualTo(String value) {
            this.addCriterion("fasion_type <>", value, "fasionType");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andFasionTypeNotEqualToColumn(Column column) {
            this.addCriterion("fasion_type <> " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andFasionTypeGreaterThan(String value) {
            this.addCriterion("fasion_type >", value, "fasionType");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andFasionTypeGreaterThanColumn(Column column) {
            this.addCriterion("fasion_type > " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andFasionTypeGreaterThanOrEqualTo(String value) {
            this.addCriterion("fasion_type >=", value, "fasionType");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andFasionTypeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("fasion_type >= " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andFasionTypeLessThan(String value) {
            this.addCriterion("fasion_type <", value, "fasionType");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andFasionTypeLessThanColumn(Column column) {
            this.addCriterion("fasion_type < " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andFasionTypeLessThanOrEqualTo(String value) {
            this.addCriterion("fasion_type <=", value, "fasionType");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andFasionTypeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("fasion_type <= " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andFasionTypeLike(String value) {
            this.addCriterion("fasion_type like", value, "fasionType");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andFasionTypeNotLike(String value) {
            this.addCriterion("fasion_type not like", value, "fasionType");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andFasionTypeIn(List<String> values) {
            this.addCriterion("fasion_type in", values, "fasionType");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andFasionTypeNotIn(List<String> values) {
            this.addCriterion("fasion_type not in", values, "fasionType");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andFasionTypeBetween(String value1, String value2) {
            this.addCriterion("fasion_type between", value1, value2, "fasionType");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andFasionTypeNotBetween(String value1, String value2) {
            this.addCriterion("fasion_type not between", value1, value2, "fasionType");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andStrIsNull() {
            this.addCriterion("str is null");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andStrIsNotNull() {
            this.addCriterion("str is not null");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andStrEqualTo(String value) {
            this.addCriterion("str =", value, "str");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andStrEqualToColumn(Column column) {
            this.addCriterion("str = " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andStrNotEqualTo(String value) {
            this.addCriterion("str <>", value, "str");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andStrNotEqualToColumn(Column column) {
            this.addCriterion("str <> " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andStrGreaterThan(String value) {
            this.addCriterion("str >", value, "str");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andStrGreaterThanColumn(Column column) {
            this.addCriterion("str > " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andStrGreaterThanOrEqualTo(String value) {
            this.addCriterion("str >=", value, "str");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andStrGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("str >= " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andStrLessThan(String value) {
            this.addCriterion("str <", value, "str");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andStrLessThanColumn(Column column) {
            this.addCriterion("str < " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andStrLessThanOrEqualTo(String value) {
            this.addCriterion("str <=", value, "str");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andStrLessThanOrEqualToColumn(Column column) {
            this.addCriterion("str <= " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andStrLike(String value) {
            this.addCriterion("str like", value, "str");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andStrNotLike(String value) {
            this.addCriterion("str not like", value, "str");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andStrIn(List<String> values) {
            this.addCriterion("str in", values, "str");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andStrNotIn(List<String> values) {
            this.addCriterion("str not in", values, "str");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andStrBetween(String value1, String value2) {
            this.addCriterion("str between", value1, value2, "str");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andStrNotBetween(String value1, String value2) {
            this.addCriterion("str not between", value1, value2, "str");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andTypeIsNull() {
            this.addCriterion("`type` is null");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andTypeIsNotNull() {
            this.addCriterion("`type` is not null");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andTypeEqualTo(String value) {
            this.addCriterion("`type` =", value, "type");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andTypeEqualToColumn(Column column) {
            this.addCriterion("`type` = " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andTypeNotEqualTo(String value) {
            this.addCriterion("`type` <>", value, "type");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andTypeNotEqualToColumn(Column column) {
            this.addCriterion("`type` <> " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andTypeGreaterThan(String value) {
            this.addCriterion("`type` >", value, "type");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andTypeGreaterThanColumn(Column column) {
            this.addCriterion("`type` > " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andTypeGreaterThanOrEqualTo(String value) {
            this.addCriterion("`type` >=", value, "type");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andTypeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`type` >= " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andTypeLessThan(String value) {
            this.addCriterion("`type` <", value, "type");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andTypeLessThanColumn(Column column) {
            this.addCriterion("`type` < " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andTypeLessThanOrEqualTo(String value) {
            this.addCriterion("`type` <=", value, "type");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andTypeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`type` <= " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andTypeLike(String value) {
            this.addCriterion("`type` like", value, "type");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andTypeNotLike(String value) {
            this.addCriterion("`type` not like", value, "type");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andTypeIn(List<String> values) {
            this.addCriterion("`type` in", values, "type");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andTypeNotIn(List<String> values) {
            this.addCriterion("`type` not in", values, "type");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andTypeBetween(String value1, String value2) {
            this.addCriterion("`type` between", value1, value2, "type");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andTypeNotBetween(String value1, String value2) {
            this.addCriterion("`type` not between", value1, value2, "type");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andFoodNumIsNull() {
            this.addCriterion("food_num is null");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andFoodNumIsNotNull() {
            this.addCriterion("food_num is not null");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andFoodNumEqualTo(Integer value) {
            this.addCriterion("food_num =", value, "foodNum");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andFoodNumEqualToColumn(Column column) {
            this.addCriterion("food_num = " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andFoodNumNotEqualTo(Integer value) {
            this.addCriterion("food_num <>", value, "foodNum");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andFoodNumNotEqualToColumn(Column column) {
            this.addCriterion("food_num <> " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andFoodNumGreaterThan(Integer value) {
            this.addCriterion("food_num >", value, "foodNum");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andFoodNumGreaterThanColumn(Column column) {
            this.addCriterion("food_num > " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andFoodNumGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("food_num >=", value, "foodNum");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andFoodNumGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("food_num >= " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andFoodNumLessThan(Integer value) {
            this.addCriterion("food_num <", value, "foodNum");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andFoodNumLessThanColumn(Column column) {
            this.addCriterion("food_num < " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andFoodNumLessThanOrEqualTo(Integer value) {
            this.addCriterion("food_num <=", value, "foodNum");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andFoodNumLessThanOrEqualToColumn(Column column) {
            this.addCriterion("food_num <= " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andFoodNumIn(List<Integer> values) {
            this.addCriterion("food_num in", values, "foodNum");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andFoodNumNotIn(List<Integer> values) {
            this.addCriterion("food_num not in", values, "foodNum");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andFoodNumBetween(Integer value1, Integer value2) {
            this.addCriterion("food_num between", value1, value2, "foodNum");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andFoodNumNotBetween(Integer value1, Integer value2) {
            this.addCriterion("food_num not between", value1, value2, "foodNum");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andGoodsPriceIsNull() {
            this.addCriterion("goods_price is null");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andGoodsPriceIsNotNull() {
            this.addCriterion("goods_price is not null");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andGoodsPriceEqualTo(Integer value) {
            this.addCriterion("goods_price =", value, "goodsPrice");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andGoodsPriceEqualToColumn(Column column) {
            this.addCriterion("goods_price = " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andGoodsPriceNotEqualTo(Integer value) {
            this.addCriterion("goods_price <>", value, "goodsPrice");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andGoodsPriceNotEqualToColumn(Column column) {
            this.addCriterion("goods_price <> " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andGoodsPriceGreaterThan(Integer value) {
            this.addCriterion("goods_price >", value, "goodsPrice");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andGoodsPriceGreaterThanColumn(Column column) {
            this.addCriterion("goods_price > " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andGoodsPriceGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("goods_price >=", value, "goodsPrice");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andGoodsPriceGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("goods_price >= " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andGoodsPriceLessThan(Integer value) {
            this.addCriterion("goods_price <", value, "goodsPrice");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andGoodsPriceLessThanColumn(Column column) {
            this.addCriterion("goods_price < " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andGoodsPriceLessThanOrEqualTo(Integer value) {
            this.addCriterion("goods_price <=", value, "goodsPrice");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andGoodsPriceLessThanOrEqualToColumn(Column column) {
            this.addCriterion("goods_price <= " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andGoodsPriceIn(List<Integer> values) {
            this.addCriterion("goods_price in", values, "goodsPrice");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andGoodsPriceNotIn(List<Integer> values) {
            this.addCriterion("goods_price not in", values, "goodsPrice");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andGoodsPriceBetween(Integer value1, Integer value2) {
            this.addCriterion("goods_price between", value1, value2, "goodsPrice");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andGoodsPriceNotBetween(Integer value1, Integer value2) {
            this.addCriterion("goods_price not between", value1, value2, "goodsPrice");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andSexIsNull() {
            this.addCriterion("sex is null");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andSexIsNotNull() {
            this.addCriterion("sex is not null");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andSexEqualTo(Integer value) {
            this.addCriterion("sex =", value, "sex");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andSexEqualToColumn(Column column) {
            this.addCriterion("sex = " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andSexNotEqualTo(Integer value) {
            this.addCriterion("sex <>", value, "sex");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andSexNotEqualToColumn(Column column) {
            this.addCriterion("sex <> " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andSexGreaterThan(Integer value) {
            this.addCriterion("sex >", value, "sex");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andSexGreaterThanColumn(Column column) {
            this.addCriterion("sex > " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andSexGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("sex >=", value, "sex");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andSexGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("sex >= " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andSexLessThan(Integer value) {
            this.addCriterion("sex <", value, "sex");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andSexLessThanColumn(Column column) {
            this.addCriterion("sex < " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andSexLessThanOrEqualTo(Integer value) {
            this.addCriterion("sex <=", value, "sex");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andSexLessThanOrEqualToColumn(Column column) {
            this.addCriterion("sex <= " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andSexIn(List<Integer> values) {
            this.addCriterion("sex in", values, "sex");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andSexNotIn(List<Integer> values) {
            this.addCriterion("sex not in", values, "sex");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andSexBetween(Integer value1, Integer value2) {
            this.addCriterion("sex between", value1, value2, "sex");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andSexNotBetween(Integer value1, Integer value2) {
            this.addCriterion("sex not between", value1, value2, "sex");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andPositionIsNull() {
            this.addCriterion("`position` is null");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andPositionIsNotNull() {
            this.addCriterion("`position` is not null");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andPositionEqualTo(Integer value) {
            this.addCriterion("`position` =", value, "position");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andPositionEqualToColumn(Column column) {
            this.addCriterion("`position` = " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andPositionNotEqualTo(Integer value) {
            this.addCriterion("`position` <>", value, "position");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andPositionNotEqualToColumn(Column column) {
            this.addCriterion("`position` <> " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andPositionGreaterThan(Integer value) {
            this.addCriterion("`position` >", value, "position");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andPositionGreaterThanColumn(Column column) {
            this.addCriterion("`position` > " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andPositionGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("`position` >=", value, "position");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andPositionGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`position` >= " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andPositionLessThan(Integer value) {
            this.addCriterion("`position` <", value, "position");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andPositionLessThanColumn(Column column) {
            this.addCriterion("`position` < " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andPositionLessThanOrEqualTo(Integer value) {
            this.addCriterion("`position` <=", value, "position");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andPositionLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`position` <= " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andPositionIn(List<Integer> values) {
            this.addCriterion("`position` in", values, "position");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andPositionNotIn(List<Integer> values) {
            this.addCriterion("`position` not in", values, "position");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andPositionBetween(Integer value1, Integer value2) {
            this.addCriterion("`position` between", value1, value2, "position");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andPositionNotBetween(Integer value1, Integer value2) {
            this.addCriterion("`position` not between", value1, value2, "position");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andCategoryIsNull() {
            this.addCriterion("category is null");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andCategoryIsNotNull() {
            this.addCriterion("category is not null");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andCategoryEqualTo(Integer value) {
            this.addCriterion("category =", value, "category");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andCategoryEqualToColumn(Column column) {
            this.addCriterion("category = " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andCategoryNotEqualTo(Integer value) {
            this.addCriterion("category <>", value, "category");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andCategoryNotEqualToColumn(Column column) {
            this.addCriterion("category <> " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andCategoryGreaterThan(Integer value) {
            this.addCriterion("category >", value, "category");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andCategoryGreaterThanColumn(Column column) {
            this.addCriterion("category > " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andCategoryGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("category >=", value, "category");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andCategoryGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("category >= " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andCategoryLessThan(Integer value) {
            this.addCriterion("category <", value, "category");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andCategoryLessThanColumn(Column column) {
            this.addCriterion("category < " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andCategoryLessThanOrEqualTo(Integer value) {
            this.addCriterion("category <=", value, "category");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andCategoryLessThanOrEqualToColumn(Column column) {
            this.addCriterion("category <= " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andCategoryIn(List<Integer> values) {
            this.addCriterion("category in", values, "category");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andCategoryNotIn(List<Integer> values) {
            this.addCriterion("category not in", values, "category");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andCategoryBetween(Integer value1, Integer value2) {
            this.addCriterion("category between", value1, value2, "category");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andCategoryNotBetween(Integer value1, Integer value2) {
            this.addCriterion("category not between", value1, value2, "category");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andAddTimeIsNull() {
            this.addCriterion("add_time is null");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andAddTimeIsNotNull() {
            this.addCriterion("add_time is not null");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andAddTimeEqualTo(LocalDateTime value) {
            this.addCriterion("add_time =", value, "addTime");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andAddTimeEqualToColumn(Column column) {
            this.addCriterion("add_time = " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andAddTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <>", value, "addTime");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andAddTimeNotEqualToColumn(Column column) {
            this.addCriterion("add_time <> " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andAddTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("add_time >", value, "addTime");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andAddTimeGreaterThanColumn(Column column) {
            this.addCriterion("add_time > " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andAddTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time >=", value, "addTime");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andAddTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time >= " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andAddTimeLessThan(LocalDateTime value) {
            this.addCriterion("add_time <", value, "addTime");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andAddTimeLessThanColumn(Column column) {
            this.addCriterion("add_time < " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andAddTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <=", value, "addTime");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andAddTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time <= " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andAddTimeIn(List<LocalDateTime> values) {
            this.addCriterion("add_time in", values, "addTime");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andAddTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("add_time not in", values, "addTime");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andAddTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time between", value1, value2, "addTime");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andAddTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time not between", value1, value2, "addTime");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andUpdateTimeIsNull() {
            this.addCriterion("update_time is null");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andUpdateTimeIsNotNull() {
            this.addCriterion("update_time is not null");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andUpdateTimeEqualTo(LocalDateTime value) {
            this.addCriterion("update_time =", value, "updateTime");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andUpdateTimeEqualToColumn(Column column) {
            this.addCriterion("update_time = " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andUpdateTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <>", value, "updateTime");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andUpdateTimeNotEqualToColumn(Column column) {
            this.addCriterion("update_time <> " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andUpdateTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("update_time >", value, "updateTime");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andUpdateTimeGreaterThanColumn(Column column) {
            this.addCriterion("update_time > " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andUpdateTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time >=", value, "updateTime");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andUpdateTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time >= " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andUpdateTimeLessThan(LocalDateTime value) {
            this.addCriterion("update_time <", value, "updateTime");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andUpdateTimeLessThanColumn(Column column) {
            this.addCriterion("update_time < " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andUpdateTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <=", value, "updateTime");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andUpdateTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time <= " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andUpdateTimeIn(List<LocalDateTime> values) {
            this.addCriterion("update_time in", values, "updateTime");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andUpdateTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("update_time not in", values, "updateTime");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andUpdateTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time between", value1, value2, "updateTime");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andUpdateTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time not between", value1, value2, "updateTime");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andDeletedIsNull() {
            this.addCriterion("deleted is null");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andDeletedIsNotNull() {
            this.addCriterion("deleted is not null");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andDeletedEqualTo(Boolean value) {
            this.addCriterion("deleted =", value, "deleted");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andDeletedEqualToColumn(Column column) {
            this.addCriterion("deleted = " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andDeletedNotEqualTo(Boolean value) {
            this.addCriterion("deleted <>", value, "deleted");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andDeletedNotEqualToColumn(Column column) {
            this.addCriterion("deleted <> " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andDeletedGreaterThan(Boolean value) {
            this.addCriterion("deleted >", value, "deleted");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andDeletedGreaterThanColumn(Column column) {
            this.addCriterion("deleted > " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andDeletedGreaterThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted >=", value, "deleted");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andDeletedGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted >= " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andDeletedLessThan(Boolean value) {
            this.addCriterion("deleted <", value, "deleted");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andDeletedLessThanColumn(Column column) {
            this.addCriterion("deleted < " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andDeletedLessThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted <=", value, "deleted");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andDeletedLessThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted <= " + column.getEscapedColumnName());
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andDeletedIn(List<Boolean> values) {
            this.addCriterion("deleted in", values, "deleted");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andDeletedNotIn(List<Boolean> values) {
            this.addCriterion("deleted not in", values, "deleted");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andDeletedBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted between", value1, value2, "deleted");
            return (PackModificationExample.Criteria)this;
        }

        public PackModificationExample.Criteria andDeletedNotBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted not between", value1, value2, "deleted");
            return (PackModificationExample.Criteria)this;
        }
    }
}
