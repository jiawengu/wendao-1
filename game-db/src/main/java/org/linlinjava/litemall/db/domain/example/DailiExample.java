//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.domain.example;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.linlinjava.litemall.db.domain.Daili.Column;
import org.linlinjava.litemall.db.domain.Daili.Deleted;

public class DailiExample {
    protected String orderByClause;
    protected boolean distinct;
    protected List<DailiExample.Criteria> oredCriteria = new ArrayList();

    public DailiExample() {
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

    public List<DailiExample.Criteria> getOredCriteria() {
        return this.oredCriteria;
    }

    public void or(DailiExample.Criteria criteria) {
        this.oredCriteria.add(criteria);
    }

    public DailiExample.Criteria or() {
        DailiExample.Criteria criteria = this.createCriteriaInternal();
        this.oredCriteria.add(criteria);
        return criteria;
    }

    public DailiExample orderBy(String orderByClause) {
        this.setOrderByClause(orderByClause);
        return this;
    }

    public DailiExample orderBy(String... orderByClauses) {
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

    public DailiExample.Criteria createCriteria() {
        DailiExample.Criteria criteria = this.createCriteriaInternal();
        if (this.oredCriteria.size() == 0) {
            this.oredCriteria.add(criteria);
        }

        return criteria;
    }

    protected DailiExample.Criteria createCriteriaInternal() {
        DailiExample.Criteria criteria = new DailiExample.Criteria(this);
        return criteria;
    }

    public void clear() {
        this.oredCriteria.clear();
        this.orderByClause = null;
        this.distinct = false;
    }

    public static DailiExample.Criteria newAndCreateCriteria() {
        DailiExample example = new DailiExample();
        return example.createCriteria();
    }

    public DailiExample when(boolean condition, DailiExample.IExampleWhen then) {
        if (condition) {
            then.example(this);
        }

        return this;
    }

    public DailiExample when(boolean condition, DailiExample.IExampleWhen then, DailiExample.IExampleWhen otherwise) {
        if (condition) {
            then.example(this);
        } else {
            otherwise.example(this);
        }

        return this;
    }

    public interface IExampleWhen {
        void example(DailiExample example);
    }

    public interface ICriteriaWhen {
        void criteria(DailiExample.Criteria criteria);
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

    public static class Criteria extends DailiExample.GeneratedCriteria {
        private DailiExample example;

        protected Criteria(DailiExample example) {
            this.example = example;
        }

        public DailiExample example() {
            return this.example;
        }

        /** @deprecated */
        @Deprecated
        public DailiExample.Criteria andIf(boolean ifAdd, DailiExample.Criteria.ICriteriaAdd add) {
            if (ifAdd) {
                add.add(this);
            }

            return this;
        }

        public DailiExample.Criteria when(boolean condition, DailiExample.ICriteriaWhen then) {
            if (condition) {
                then.criteria(this);
            }

            return this;
        }

        public DailiExample.Criteria when(boolean condition, DailiExample.ICriteriaWhen then, DailiExample.ICriteriaWhen otherwise) {
            if (condition) {
                then.criteria(this);
            } else {
                otherwise.criteria(this);
            }

            return this;
        }

        public DailiExample.Criteria andLogicalDeleted(boolean deleted) {
            return deleted ? this.andDeletedEqualTo(Deleted.IS_DELETED.value()) : this.andDeletedNotEqualTo(Deleted.IS_DELETED.value());
        }

        /** @deprecated */
        @Deprecated
        public interface ICriteriaAdd {
            DailiExample.Criteria add(DailiExample.Criteria add);
        }
    }

    protected abstract static class GeneratedCriteria {
        protected List<DailiExample.Criterion> criteria = new ArrayList();

        protected GeneratedCriteria() {
        }

        public boolean isValid() {
            return this.criteria.size() > 0;
        }

        public List<DailiExample.Criterion> getAllCriteria() {
            return this.criteria;
        }

        public List<DailiExample.Criterion> getCriteria() {
            return this.criteria;
        }

        protected void addCriterion(String condition) {
            if (condition == null) {
                throw new RuntimeException("Value for condition cannot be null");
            } else {
                this.criteria.add(new DailiExample.Criterion(condition));
            }
        }

        protected void addCriterion(String condition, Object value, String property) {
            if (value == null) {
                throw new RuntimeException("Value for " + property + " cannot be null");
            } else {
                this.criteria.add(new DailiExample.Criterion(condition, value));
            }
        }

        protected void addCriterion(String condition, Object value1, Object value2, String property) {
            if (value1 != null && value2 != null) {
                this.criteria.add(new DailiExample.Criterion(condition, value1, value2));
            } else {
                throw new RuntimeException("Between values for " + property + " cannot be null");
            }
        }

        public DailiExample.Criteria andIdIsNull() {
            this.addCriterion("id is null");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andIdIsNotNull() {
            this.addCriterion("id is not null");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andIdEqualTo(Integer value) {
            this.addCriterion("id =", value, "id");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andIdEqualToColumn(Column column) {
            this.addCriterion("id = " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andIdNotEqualTo(Integer value) {
            this.addCriterion("id <>", value, "id");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andIdNotEqualToColumn(Column column) {
            this.addCriterion("id <> " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andIdGreaterThan(Integer value) {
            this.addCriterion("id >", value, "id");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andIdGreaterThanColumn(Column column) {
            this.addCriterion("id > " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andIdGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("id >=", value, "id");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andIdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("id >= " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andIdLessThan(Integer value) {
            this.addCriterion("id <", value, "id");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andIdLessThanColumn(Column column) {
            this.addCriterion("id < " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andIdLessThanOrEqualTo(Integer value) {
            this.addCriterion("id <=", value, "id");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andIdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("id <= " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andIdIn(List<Integer> values) {
            this.addCriterion("id in", values, "id");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andIdNotIn(List<Integer> values) {
            this.addCriterion("id not in", values, "id");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andIdBetween(Integer value1, Integer value2) {
            this.addCriterion("id between", value1, value2, "id");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andIdNotBetween(Integer value1, Integer value2) {
            this.addCriterion("id not between", value1, value2, "id");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andAccountIsNull() {
            this.addCriterion("account is null");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andAccountIsNotNull() {
            this.addCriterion("account is not null");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andAccountEqualTo(String value) {
            this.addCriterion("account =", value, "account");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andAccountEqualToColumn(Column column) {
            this.addCriterion("account = " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andAccountNotEqualTo(String value) {
            this.addCriterion("account <>", value, "account");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andAccountNotEqualToColumn(Column column) {
            this.addCriterion("account <> " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andAccountGreaterThan(String value) {
            this.addCriterion("account >", value, "account");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andAccountGreaterThanColumn(Column column) {
            this.addCriterion("account > " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andAccountGreaterThanOrEqualTo(String value) {
            this.addCriterion("account >=", value, "account");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andAccountGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("account >= " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andAccountLessThan(String value) {
            this.addCriterion("account <", value, "account");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andAccountLessThanColumn(Column column) {
            this.addCriterion("account < " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andAccountLessThanOrEqualTo(String value) {
            this.addCriterion("account <=", value, "account");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andAccountLessThanOrEqualToColumn(Column column) {
            this.addCriterion("account <= " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andAccountLike(String value) {
            this.addCriterion("account like", value, "account");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andAccountNotLike(String value) {
            this.addCriterion("account not like", value, "account");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andAccountIn(List<String> values) {
            this.addCriterion("account in", values, "account");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andAccountNotIn(List<String> values) {
            this.addCriterion("account not in", values, "account");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andAccountBetween(String value1, String value2) {
            this.addCriterion("account between", value1, value2, "account");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andAccountNotBetween(String value1, String value2) {
            this.addCriterion("account not between", value1, value2, "account");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andPasswdIsNull() {
            this.addCriterion("passwd is null");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andPasswdIsNotNull() {
            this.addCriterion("passwd is not null");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andPasswdEqualTo(String value) {
            this.addCriterion("passwd =", value, "passwd");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andPasswdEqualToColumn(Column column) {
            this.addCriterion("passwd = " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andPasswdNotEqualTo(String value) {
            this.addCriterion("passwd <>", value, "passwd");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andPasswdNotEqualToColumn(Column column) {
            this.addCriterion("passwd <> " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andPasswdGreaterThan(String value) {
            this.addCriterion("passwd >", value, "passwd");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andPasswdGreaterThanColumn(Column column) {
            this.addCriterion("passwd > " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andPasswdGreaterThanOrEqualTo(String value) {
            this.addCriterion("passwd >=", value, "passwd");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andPasswdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("passwd >= " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andPasswdLessThan(String value) {
            this.addCriterion("passwd <", value, "passwd");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andPasswdLessThanColumn(Column column) {
            this.addCriterion("passwd < " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andPasswdLessThanOrEqualTo(String value) {
            this.addCriterion("passwd <=", value, "passwd");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andPasswdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("passwd <= " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andPasswdLike(String value) {
            this.addCriterion("passwd like", value, "passwd");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andPasswdNotLike(String value) {
            this.addCriterion("passwd not like", value, "passwd");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andPasswdIn(List<String> values) {
            this.addCriterion("passwd in", values, "passwd");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andPasswdNotIn(List<String> values) {
            this.addCriterion("passwd not in", values, "passwd");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andPasswdBetween(String value1, String value2) {
            this.addCriterion("passwd between", value1, value2, "passwd");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andPasswdNotBetween(String value1, String value2) {
            this.addCriterion("passwd not between", value1, value2, "passwd");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andCodeIsNull() {
            this.addCriterion("code is null");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andCodeIsNotNull() {
            this.addCriterion("code is not null");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andCodeEqualTo(String value) {
            this.addCriterion("code =", value, "code");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andCodeEqualToColumn(Column column) {
            this.addCriterion("code = " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andCodeNotEqualTo(String value) {
            this.addCriterion("code <>", value, "code");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andCodeNotEqualToColumn(Column column) {
            this.addCriterion("code <> " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andCodeGreaterThan(String value) {
            this.addCriterion("code >", value, "code");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andCodeGreaterThanColumn(Column column) {
            this.addCriterion("code > " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andCodeGreaterThanOrEqualTo(String value) {
            this.addCriterion("code >=", value, "code");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andCodeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("code >= " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andCodeLessThan(String value) {
            this.addCriterion("code <", value, "code");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andCodeLessThanColumn(Column column) {
            this.addCriterion("code < " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andCodeLessThanOrEqualTo(String value) {
            this.addCriterion("code <=", value, "code");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andCodeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("code <= " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andCodeLike(String value) {
            this.addCriterion("code like", value, "code");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andCodeNotLike(String value) {
            this.addCriterion("code not like", value, "code");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andCodeIn(List<String> values) {
            this.addCriterion("code in", values, "code");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andCodeNotIn(List<String> values) {
            this.addCriterion("code not in", values, "code");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andCodeBetween(String value1, String value2) {
            this.addCriterion("code between", value1, value2, "code");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andCodeNotBetween(String value1, String value2) {
            this.addCriterion("code not between", value1, value2, "code");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andTokenIsNull() {
            this.addCriterion("token is null");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andTokenIsNotNull() {
            this.addCriterion("token is not null");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andTokenEqualTo(String value) {
            this.addCriterion("token =", value, "token");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andTokenEqualToColumn(Column column) {
            this.addCriterion("token = " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andTokenNotEqualTo(String value) {
            this.addCriterion("token <>", value, "token");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andTokenNotEqualToColumn(Column column) {
            this.addCriterion("token <> " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andTokenGreaterThan(String value) {
            this.addCriterion("token >", value, "token");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andTokenGreaterThanColumn(Column column) {
            this.addCriterion("token > " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andTokenGreaterThanOrEqualTo(String value) {
            this.addCriterion("token >=", value, "token");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andTokenGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("token >= " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andTokenLessThan(String value) {
            this.addCriterion("token <", value, "token");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andTokenLessThanColumn(Column column) {
            this.addCriterion("token < " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andTokenLessThanOrEqualTo(String value) {
            this.addCriterion("token <=", value, "token");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andTokenLessThanOrEqualToColumn(Column column) {
            this.addCriterion("token <= " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andTokenLike(String value) {
            this.addCriterion("token like", value, "token");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andTokenNotLike(String value) {
            this.addCriterion("token not like", value, "token");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andTokenIn(List<String> values) {
            this.addCriterion("token in", values, "token");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andTokenNotIn(List<String> values) {
            this.addCriterion("token not in", values, "token");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andTokenBetween(String value1, String value2) {
            this.addCriterion("token between", value1, value2, "token");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andTokenNotBetween(String value1, String value2) {
            this.addCriterion("token not between", value1, value2, "token");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andAddTimeIsNull() {
            this.addCriterion("add_time is null");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andAddTimeIsNotNull() {
            this.addCriterion("add_time is not null");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andAddTimeEqualTo(LocalDateTime value) {
            this.addCriterion("add_time =", value, "addTime");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andAddTimeEqualToColumn(Column column) {
            this.addCriterion("add_time = " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andAddTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <>", value, "addTime");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andAddTimeNotEqualToColumn(Column column) {
            this.addCriterion("add_time <> " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andAddTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("add_time >", value, "addTime");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andAddTimeGreaterThanColumn(Column column) {
            this.addCriterion("add_time > " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andAddTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time >=", value, "addTime");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andAddTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time >= " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andAddTimeLessThan(LocalDateTime value) {
            this.addCriterion("add_time <", value, "addTime");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andAddTimeLessThanColumn(Column column) {
            this.addCriterion("add_time < " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andAddTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <=", value, "addTime");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andAddTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time <= " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andAddTimeIn(List<LocalDateTime> values) {
            this.addCriterion("add_time in", values, "addTime");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andAddTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("add_time not in", values, "addTime");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andAddTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time between", value1, value2, "addTime");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andAddTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time not between", value1, value2, "addTime");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andUpdateTimeIsNull() {
            this.addCriterion("update_time is null");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andUpdateTimeIsNotNull() {
            this.addCriterion("update_time is not null");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andUpdateTimeEqualTo(LocalDateTime value) {
            this.addCriterion("update_time =", value, "updateTime");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andUpdateTimeEqualToColumn(Column column) {
            this.addCriterion("update_time = " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andUpdateTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <>", value, "updateTime");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andUpdateTimeNotEqualToColumn(Column column) {
            this.addCriterion("update_time <> " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andUpdateTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("update_time >", value, "updateTime");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andUpdateTimeGreaterThanColumn(Column column) {
            this.addCriterion("update_time > " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andUpdateTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time >=", value, "updateTime");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andUpdateTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time >= " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andUpdateTimeLessThan(LocalDateTime value) {
            this.addCriterion("update_time <", value, "updateTime");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andUpdateTimeLessThanColumn(Column column) {
            this.addCriterion("update_time < " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andUpdateTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <=", value, "updateTime");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andUpdateTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time <= " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andUpdateTimeIn(List<LocalDateTime> values) {
            this.addCriterion("update_time in", values, "updateTime");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andUpdateTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("update_time not in", values, "updateTime");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andUpdateTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time between", value1, value2, "updateTime");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andUpdateTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time not between", value1, value2, "updateTime");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andDeletedIsNull() {
            this.addCriterion("deleted is null");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andDeletedIsNotNull() {
            this.addCriterion("deleted is not null");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andDeletedEqualTo(Boolean value) {
            this.addCriterion("deleted =", value, "deleted");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andDeletedEqualToColumn(Column column) {
            this.addCriterion("deleted = " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andDeletedNotEqualTo(Boolean value) {
            this.addCriterion("deleted <>", value, "deleted");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andDeletedNotEqualToColumn(Column column) {
            this.addCriterion("deleted <> " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andDeletedGreaterThan(Boolean value) {
            this.addCriterion("deleted >", value, "deleted");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andDeletedGreaterThanColumn(Column column) {
            this.addCriterion("deleted > " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andDeletedGreaterThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted >=", value, "deleted");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andDeletedGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted >= " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andDeletedLessThan(Boolean value) {
            this.addCriterion("deleted <", value, "deleted");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andDeletedLessThanColumn(Column column) {
            this.addCriterion("deleted < " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andDeletedLessThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted <=", value, "deleted");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andDeletedLessThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted <= " + column.getEscapedColumnName());
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andDeletedIn(List<Boolean> values) {
            this.addCriterion("deleted in", values, "deleted");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andDeletedNotIn(List<Boolean> values) {
            this.addCriterion("deleted not in", values, "deleted");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andDeletedBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted between", value1, value2, "deleted");
            return (DailiExample.Criteria)this;
        }

        public DailiExample.Criteria andDeletedNotBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted not between", value1, value2, "deleted");
            return (DailiExample.Criteria)this;
        }
    }
}
