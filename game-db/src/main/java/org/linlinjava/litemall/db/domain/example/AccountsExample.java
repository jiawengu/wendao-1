//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.domain.example;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.linlinjava.litemall.db.domain.Accounts.Column;
import org.linlinjava.litemall.db.domain.Accounts.Deleted;

public class AccountsExample {
    protected String orderByClause;
    protected boolean distinct;
    protected List<AccountsExample.Criteria> oredCriteria = new ArrayList();

    public AccountsExample() {
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

    public List<AccountsExample.Criteria> getOredCriteria() {
        return this.oredCriteria;
    }

    public void or(AccountsExample.Criteria criteria) {
        this.oredCriteria.add(criteria);
    }

    public AccountsExample.Criteria or() {
        AccountsExample.Criteria criteria = this.createCriteriaInternal();
        this.oredCriteria.add(criteria);
        return criteria;
    }

    public AccountsExample orderBy(String orderByClause) {
        this.setOrderByClause(orderByClause);
        return this;
    }

    public AccountsExample orderBy(String... orderByClauses) {
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

    public AccountsExample.Criteria createCriteria() {
        AccountsExample.Criteria criteria = this.createCriteriaInternal();
        if (this.oredCriteria.size() == 0) {
            this.oredCriteria.add(criteria);
        }

        return criteria;
    }

    protected AccountsExample.Criteria createCriteriaInternal() {
        AccountsExample.Criteria criteria = new AccountsExample.Criteria(this);
        return criteria;
    }

    public void clear() {
        this.oredCriteria.clear();
        this.orderByClause = null;
        this.distinct = false;
    }

    public static AccountsExample.Criteria newAndCreateCriteria() {
        AccountsExample example = new AccountsExample();
        return example.createCriteria();
    }

    public AccountsExample when(boolean condition, AccountsExample.IExampleWhen then) {
        if (condition) {
            then.example(this);
        }

        return this;
    }

    public AccountsExample when(boolean condition, AccountsExample.IExampleWhen then, AccountsExample.IExampleWhen otherwise) {
        if (condition) {
            then.example(this);
        } else {
            otherwise.example(this);
        }

        return this;
    }

    public interface IExampleWhen {
        void example(AccountsExample example);
    }

    public interface ICriteriaWhen {
        void criteria(AccountsExample.Criteria criteria);
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

    public static class Criteria extends AccountsExample.GeneratedCriteria {
        private AccountsExample example;

        protected Criteria(AccountsExample example) {
            this.example = example;
        }

        public AccountsExample example() {
            return this.example;
        }

        /** @deprecated */
        @Deprecated
        public AccountsExample.Criteria andIf(boolean ifAdd, AccountsExample.Criteria.ICriteriaAdd add) {
            if (ifAdd) {
                add.add(this);
            }

            return this;
        }

        public AccountsExample.Criteria when(boolean condition, AccountsExample.ICriteriaWhen then) {
            if (condition) {
                then.criteria(this);
            }

            return this;
        }

        public AccountsExample.Criteria when(boolean condition, AccountsExample.ICriteriaWhen then, AccountsExample.ICriteriaWhen otherwise) {
            if (condition) {
                then.criteria(this);
            } else {
                otherwise.criteria(this);
            }

            return this;
        }

        public AccountsExample.Criteria andLogicalDeleted(boolean deleted) {
            return deleted ? this.andDeletedEqualTo(Deleted.IS_DELETED.value()) : this.andDeletedNotEqualTo(Deleted.IS_DELETED.value());
        }

        /** @deprecated */
        @Deprecated
        public interface ICriteriaAdd {
            AccountsExample.Criteria add(AccountsExample.Criteria add);
        }
    }

    protected abstract static class GeneratedCriteria {
        protected List<AccountsExample.Criterion> criteria = new ArrayList();

        protected GeneratedCriteria() {
        }

        public boolean isValid() {
            return this.criteria.size() > 0;
        }

        public List<AccountsExample.Criterion> getAllCriteria() {
            return this.criteria;
        }

        public List<AccountsExample.Criterion> getCriteria() {
            return this.criteria;
        }

        protected void addCriterion(String condition) {
            if (condition == null) {
                throw new RuntimeException("Value for condition cannot be null");
            } else {
                this.criteria.add(new AccountsExample.Criterion(condition));
            }
        }

        protected void addCriterion(String condition, Object value, String property) {
            if (value == null) {
                throw new RuntimeException("Value for " + property + " cannot be null");
            } else {
                this.criteria.add(new AccountsExample.Criterion(condition, value));
            }
        }

        protected void addCriterion(String condition, Object value1, Object value2, String property) {
            if (value1 != null && value2 != null) {
                this.criteria.add(new AccountsExample.Criterion(condition, value1, value2));
            } else {
                throw new RuntimeException("Between values for " + property + " cannot be null");
            }
        }

        public AccountsExample.Criteria andIdIsNull() {
            this.addCriterion("id is null");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andIdIsNotNull() {
            this.addCriterion("id is not null");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andIdEqualTo(Integer value) {
            this.addCriterion("id =", value, "id");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andIdEqualToColumn(Column column) {
            this.addCriterion("id = " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andIdNotEqualTo(Integer value) {
            this.addCriterion("id <>", value, "id");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andIdNotEqualToColumn(Column column) {
            this.addCriterion("id <> " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andIdGreaterThan(Integer value) {
            this.addCriterion("id >", value, "id");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andIdGreaterThanColumn(Column column) {
            this.addCriterion("id > " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andIdGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("id >=", value, "id");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andIdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("id >= " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andIdLessThan(Integer value) {
            this.addCriterion("id <", value, "id");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andIdLessThanColumn(Column column) {
            this.addCriterion("id < " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andIdLessThanOrEqualTo(Integer value) {
            this.addCriterion("id <=", value, "id");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andIdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("id <= " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andIdIn(List<Integer> values) {
            this.addCriterion("id in", values, "id");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andIdNotIn(List<Integer> values) {
            this.addCriterion("id not in", values, "id");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andIdBetween(Integer value1, Integer value2) {
            this.addCriterion("id between", value1, value2, "id");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andIdNotBetween(Integer value1, Integer value2) {
            this.addCriterion("id not between", value1, value2, "id");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andNameIsNull() {
            this.addCriterion("`name` is null");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andNameIsNotNull() {
            this.addCriterion("`name` is not null");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andNameEqualTo(String value) {
            this.addCriterion("`name` =", value, "name");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andNameEqualToColumn(Column column) {
            this.addCriterion("`name` = " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andNameNotEqualTo(String value) {
            this.addCriterion("`name` <>", value, "name");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andNameNotEqualToColumn(Column column) {
            this.addCriterion("`name` <> " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andNameGreaterThan(String value) {
            this.addCriterion("`name` >", value, "name");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andNameGreaterThanColumn(Column column) {
            this.addCriterion("`name` > " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andNameGreaterThanOrEqualTo(String value) {
            this.addCriterion("`name` >=", value, "name");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andNameGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`name` >= " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andNameLessThan(String value) {
            this.addCriterion("`name` <", value, "name");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andNameLessThanColumn(Column column) {
            this.addCriterion("`name` < " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andNameLessThanOrEqualTo(String value) {
            this.addCriterion("`name` <=", value, "name");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andNameLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`name` <= " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andNameLike(String value) {
            this.addCriterion("`name` like", value, "name");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andNameNotLike(String value) {
            this.addCriterion("`name` not like", value, "name");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andNameIn(List<String> values) {
            this.addCriterion("`name` in", values, "name");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andNameNotIn(List<String> values) {
            this.addCriterion("`name` not in", values, "name");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andNameBetween(String value1, String value2) {
            this.addCriterion("`name` between", value1, value2, "name");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andNameNotBetween(String value1, String value2) {
            this.addCriterion("`name` not between", value1, value2, "name");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andKeywordIsNull() {
            this.addCriterion("keyword is null");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andKeywordIsNotNull() {
            this.addCriterion("keyword is not null");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andKeywordEqualTo(String value) {
            this.addCriterion("keyword =", value, "keyword");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andKeywordEqualToColumn(Column column) {
            this.addCriterion("keyword = " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andKeywordNotEqualTo(String value) {
            this.addCriterion("keyword <>", value, "keyword");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andKeywordNotEqualToColumn(Column column) {
            this.addCriterion("keyword <> " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andKeywordGreaterThan(String value) {
            this.addCriterion("keyword >", value, "keyword");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andKeywordGreaterThanColumn(Column column) {
            this.addCriterion("keyword > " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andKeywordGreaterThanOrEqualTo(String value) {
            this.addCriterion("keyword >=", value, "keyword");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andKeywordGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("keyword >= " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andKeywordLessThan(String value) {
            this.addCriterion("keyword <", value, "keyword");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andKeywordLessThanColumn(Column column) {
            this.addCriterion("keyword < " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andKeywordLessThanOrEqualTo(String value) {
            this.addCriterion("keyword <=", value, "keyword");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andKeywordLessThanOrEqualToColumn(Column column) {
            this.addCriterion("keyword <= " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andKeywordLike(String value) {
            this.addCriterion("keyword like", value, "keyword");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andKeywordNotLike(String value) {
            this.addCriterion("keyword not like", value, "keyword");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andKeywordIn(List<String> values) {
            this.addCriterion("keyword in", values, "keyword");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andKeywordNotIn(List<String> values) {
            this.addCriterion("keyword not in", values, "keyword");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andKeywordBetween(String value1, String value2) {
            this.addCriterion("keyword between", value1, value2, "keyword");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andKeywordNotBetween(String value1, String value2) {
            this.addCriterion("keyword not between", value1, value2, "keyword");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andPasswordIsNull() {
            this.addCriterion("`password` is null");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andPasswordIsNotNull() {
            this.addCriterion("`password` is not null");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andPasswordEqualTo(String value) {
            this.addCriterion("`password` =", value, "password");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andPasswordEqualToColumn(Column column) {
            this.addCriterion("`password` = " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andPasswordNotEqualTo(String value) {
            this.addCriterion("`password` <>", value, "password");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andPasswordNotEqualToColumn(Column column) {
            this.addCriterion("`password` <> " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andPasswordGreaterThan(String value) {
            this.addCriterion("`password` >", value, "password");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andPasswordGreaterThanColumn(Column column) {
            this.addCriterion("`password` > " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andPasswordGreaterThanOrEqualTo(String value) {
            this.addCriterion("`password` >=", value, "password");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andPasswordGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`password` >= " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andPasswordLessThan(String value) {
            this.addCriterion("`password` <", value, "password");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andPasswordLessThanColumn(Column column) {
            this.addCriterion("`password` < " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andPasswordLessThanOrEqualTo(String value) {
            this.addCriterion("`password` <=", value, "password");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andPasswordLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`password` <= " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andPasswordLike(String value) {
            this.addCriterion("`password` like", value, "password");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andPasswordNotLike(String value) {
            this.addCriterion("`password` not like", value, "password");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andPasswordIn(List<String> values) {
            this.addCriterion("`password` in", values, "password");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andPasswordNotIn(List<String> values) {
            this.addCriterion("`password` not in", values, "password");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andPasswordBetween(String value1, String value2) {
            this.addCriterion("`password` between", value1, value2, "password");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andPasswordNotBetween(String value1, String value2) {
            this.addCriterion("`password` not between", value1, value2, "password");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andTokenIsNull() {
            this.addCriterion("token is null");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andTokenIsNotNull() {
            this.addCriterion("token is not null");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andTokenEqualTo(String value) {
            this.addCriterion("token =", value, "token");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andTokenEqualToColumn(Column column) {
            this.addCriterion("token = " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andTokenNotEqualTo(String value) {
            this.addCriterion("token <>", value, "token");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andTokenNotEqualToColumn(Column column) {
            this.addCriterion("token <> " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andTokenGreaterThan(String value) {
            this.addCriterion("token >", value, "token");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andTokenGreaterThanColumn(Column column) {
            this.addCriterion("token > " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andTokenGreaterThanOrEqualTo(String value) {
            this.addCriterion("token >=", value, "token");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andTokenGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("token >= " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andTokenLessThan(String value) {
            this.addCriterion("token <", value, "token");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andTokenLessThanColumn(Column column) {
            this.addCriterion("token < " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andTokenLessThanOrEqualTo(String value) {
            this.addCriterion("token <=", value, "token");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andTokenLessThanOrEqualToColumn(Column column) {
            this.addCriterion("token <= " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andTokenLike(String value) {
            this.addCriterion("token like", value, "token");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andTokenNotLike(String value) {
            this.addCriterion("token not like", value, "token");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andTokenIn(List<String> values) {
            this.addCriterion("token in", values, "token");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andTokenNotIn(List<String> values) {
            this.addCriterion("token not in", values, "token");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andTokenBetween(String value1, String value2) {
            this.addCriterion("token between", value1, value2, "token");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andTokenNotBetween(String value1, String value2) {
            this.addCriterion("token not between", value1, value2, "token");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andAddTimeIsNull() {
            this.addCriterion("add_time is null");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andAddTimeIsNotNull() {
            this.addCriterion("add_time is not null");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andAddTimeEqualTo(LocalDateTime value) {
            this.addCriterion("add_time =", value, "addTime");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andAddTimeEqualToColumn(Column column) {
            this.addCriterion("add_time = " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andAddTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <>", value, "addTime");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andAddTimeNotEqualToColumn(Column column) {
            this.addCriterion("add_time <> " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andAddTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("add_time >", value, "addTime");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andAddTimeGreaterThanColumn(Column column) {
            this.addCriterion("add_time > " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andAddTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time >=", value, "addTime");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andAddTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time >= " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andAddTimeLessThan(LocalDateTime value) {
            this.addCriterion("add_time <", value, "addTime");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andAddTimeLessThanColumn(Column column) {
            this.addCriterion("add_time < " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andAddTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <=", value, "addTime");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andAddTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time <= " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andAddTimeIn(List<LocalDateTime> values) {
            this.addCriterion("add_time in", values, "addTime");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andAddTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("add_time not in", values, "addTime");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andAddTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time between", value1, value2, "addTime");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andAddTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time not between", value1, value2, "addTime");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andUpdateTimeIsNull() {
            this.addCriterion("update_time is null");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andUpdateTimeIsNotNull() {
            this.addCriterion("update_time is not null");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andUpdateTimeEqualTo(LocalDateTime value) {
            this.addCriterion("update_time =", value, "updateTime");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andUpdateTimeEqualToColumn(Column column) {
            this.addCriterion("update_time = " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andUpdateTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <>", value, "updateTime");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andUpdateTimeNotEqualToColumn(Column column) {
            this.addCriterion("update_time <> " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andUpdateTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("update_time >", value, "updateTime");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andUpdateTimeGreaterThanColumn(Column column) {
            this.addCriterion("update_time > " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andUpdateTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time >=", value, "updateTime");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andUpdateTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time >= " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andUpdateTimeLessThan(LocalDateTime value) {
            this.addCriterion("update_time <", value, "updateTime");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andUpdateTimeLessThanColumn(Column column) {
            this.addCriterion("update_time < " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andUpdateTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <=", value, "updateTime");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andUpdateTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time <= " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andUpdateTimeIn(List<LocalDateTime> values) {
            this.addCriterion("update_time in", values, "updateTime");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andUpdateTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("update_time not in", values, "updateTime");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andUpdateTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time between", value1, value2, "updateTime");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andUpdateTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time not between", value1, value2, "updateTime");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andDeletedIsNull() {
            this.addCriterion("deleted is null");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andDeletedIsNotNull() {
            this.addCriterion("deleted is not null");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andDeletedEqualTo(Boolean value) {
            this.addCriterion("deleted =", value, "deleted");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andDeletedEqualToColumn(Column column) {
            this.addCriterion("deleted = " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andDeletedNotEqualTo(Boolean value) {
            this.addCriterion("deleted <>", value, "deleted");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andDeletedNotEqualToColumn(Column column) {
            this.addCriterion("deleted <> " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andDeletedGreaterThan(Boolean value) {
            this.addCriterion("deleted >", value, "deleted");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andDeletedGreaterThanColumn(Column column) {
            this.addCriterion("deleted > " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andDeletedGreaterThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted >=", value, "deleted");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andDeletedGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted >= " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andDeletedLessThan(Boolean value) {
            this.addCriterion("deleted <", value, "deleted");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andDeletedLessThanColumn(Column column) {
            this.addCriterion("deleted < " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andDeletedLessThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted <=", value, "deleted");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andDeletedLessThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted <= " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andDeletedIn(List<Boolean> values) {
            this.addCriterion("deleted in", values, "deleted");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andDeletedNotIn(List<Boolean> values) {
            this.addCriterion("deleted not in", values, "deleted");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andDeletedBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted between", value1, value2, "deleted");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andDeletedNotBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted not between", value1, value2, "deleted");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andChongzhijifenIsNull() {
            this.addCriterion("chongzhijifen is null");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andChongzhijifenIsNotNull() {
            this.addCriterion("chongzhijifen is not null");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andChongzhijifenEqualTo(Integer value) {
            this.addCriterion("chongzhijifen =", value, "chongzhijifen");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andChongzhijifenEqualToColumn(Column column) {
            this.addCriterion("chongzhijifen = " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andChongzhijifenNotEqualTo(Integer value) {
            this.addCriterion("chongzhijifen <>", value, "chongzhijifen");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andChongzhijifenNotEqualToColumn(Column column) {
            this.addCriterion("chongzhijifen <> " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andChongzhijifenGreaterThan(Integer value) {
            this.addCriterion("chongzhijifen >", value, "chongzhijifen");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andChongzhijifenGreaterThanColumn(Column column) {
            this.addCriterion("chongzhijifen > " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andChongzhijifenGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("chongzhijifen >=", value, "chongzhijifen");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andChongzhijifenGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("chongzhijifen >= " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andChongzhijifenLessThan(Integer value) {
            this.addCriterion("chongzhijifen <", value, "chongzhijifen");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andChongzhijifenLessThanColumn(Column column) {
            this.addCriterion("chongzhijifen < " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andChongzhijifenLessThanOrEqualTo(Integer value) {
            this.addCriterion("chongzhijifen <=", value, "chongzhijifen");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andChongzhijifenLessThanOrEqualToColumn(Column column) {
            this.addCriterion("chongzhijifen <= " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andChongzhijifenIn(List<Integer> values) {
            this.addCriterion("chongzhijifen in", values, "chongzhijifen");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andChongzhijifenNotIn(List<Integer> values) {
            this.addCriterion("chongzhijifen not in", values, "chongzhijifen");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andChongzhijifenBetween(Integer value1, Integer value2) {
            this.addCriterion("chongzhijifen between", value1, value2, "chongzhijifen");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andChongzhijifenNotBetween(Integer value1, Integer value2) {
            this.addCriterion("chongzhijifen not between", value1, value2, "chongzhijifen");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andChongzhiyuanbaoIsNull() {
            this.addCriterion("chongzhiyuanbao is null");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andChongzhiyuanbaoIsNotNull() {
            this.addCriterion("chongzhiyuanbao is not null");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andChongzhiyuanbaoEqualTo(Integer value) {
            this.addCriterion("chongzhiyuanbao =", value, "chongzhiyuanbao");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andChongzhiyuanbaoEqualToColumn(Column column) {
            this.addCriterion("chongzhiyuanbao = " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andChongzhiyuanbaoNotEqualTo(Integer value) {
            this.addCriterion("chongzhiyuanbao <>", value, "chongzhiyuanbao");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andChongzhiyuanbaoNotEqualToColumn(Column column) {
            this.addCriterion("chongzhiyuanbao <> " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andChongzhiyuanbaoGreaterThan(Integer value) {
            this.addCriterion("chongzhiyuanbao >", value, "chongzhiyuanbao");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andChongzhiyuanbaoGreaterThanColumn(Column column) {
            this.addCriterion("chongzhiyuanbao > " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andChongzhiyuanbaoGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("chongzhiyuanbao >=", value, "chongzhiyuanbao");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andChongzhiyuanbaoGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("chongzhiyuanbao >= " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andChongzhiyuanbaoLessThan(Integer value) {
            this.addCriterion("chongzhiyuanbao <", value, "chongzhiyuanbao");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andChongzhiyuanbaoLessThanColumn(Column column) {
            this.addCriterion("chongzhiyuanbao < " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andChongzhiyuanbaoLessThanOrEqualTo(Integer value) {
            this.addCriterion("chongzhiyuanbao <=", value, "chongzhiyuanbao");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andChongzhiyuanbaoLessThanOrEqualToColumn(Column column) {
            this.addCriterion("chongzhiyuanbao <= " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andChongzhiyuanbaoIn(List<Integer> values) {
            this.addCriterion("chongzhiyuanbao in", values, "chongzhiyuanbao");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andChongzhiyuanbaoNotIn(List<Integer> values) {
            this.addCriterion("chongzhiyuanbao not in", values, "chongzhiyuanbao");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andChongzhiyuanbaoBetween(Integer value1, Integer value2) {
            this.addCriterion("chongzhiyuanbao between", value1, value2, "chongzhiyuanbao");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andChongzhiyuanbaoNotBetween(Integer value1, Integer value2) {
            this.addCriterion("chongzhiyuanbao not between", value1, value2, "chongzhiyuanbao");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andYaoqingmaIsNull() {
            this.addCriterion("yaoqingma is null");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andYaoqingmaIsNotNull() {
            this.addCriterion("yaoqingma is not null");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andYaoqingmaEqualTo(String value) {
            this.addCriterion("yaoqingma =", value, "yaoqingma");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andYaoqingmaEqualToColumn(Column column) {
            this.addCriterion("yaoqingma = " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andYaoqingmaNotEqualTo(String value) {
            this.addCriterion("yaoqingma <>", value, "yaoqingma");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andYaoqingmaNotEqualToColumn(Column column) {
            this.addCriterion("yaoqingma <> " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andYaoqingmaGreaterThan(String value) {
            this.addCriterion("yaoqingma >", value, "yaoqingma");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andYaoqingmaGreaterThanColumn(Column column) {
            this.addCriterion("yaoqingma > " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andYaoqingmaGreaterThanOrEqualTo(String value) {
            this.addCriterion("yaoqingma >=", value, "yaoqingma");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andYaoqingmaGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("yaoqingma >= " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andYaoqingmaLessThan(String value) {
            this.addCriterion("yaoqingma <", value, "yaoqingma");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andYaoqingmaLessThanColumn(Column column) {
            this.addCriterion("yaoqingma < " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andYaoqingmaLessThanOrEqualTo(String value) {
            this.addCriterion("yaoqingma <=", value, "yaoqingma");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andYaoqingmaLessThanOrEqualToColumn(Column column) {
            this.addCriterion("yaoqingma <= " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andYaoqingmaLike(String value) {
            this.addCriterion("yaoqingma like", value, "yaoqingma");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andYaoqingmaNotLike(String value) {
            this.addCriterion("yaoqingma not like", value, "yaoqingma");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andYaoqingmaIn(List<String> values) {
            this.addCriterion("yaoqingma in", values, "yaoqingma");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andYaoqingmaNotIn(List<String> values) {
            this.addCriterion("yaoqingma not in", values, "yaoqingma");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andYaoqingmaBetween(String value1, String value2) {
            this.addCriterion("yaoqingma between", value1, value2, "yaoqingma");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andYaoqingmaNotBetween(String value1, String value2) {
            this.addCriterion("yaoqingma not between", value1, value2, "yaoqingma");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andBlockIsNull() {
            this.addCriterion("block is null");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andBlockIsNotNull() {
            this.addCriterion("block is not null");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andBlockEqualTo(Integer value) {
            this.addCriterion("block =", value, "block");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andBlockEqualToColumn(Column column) {
            this.addCriterion("block = " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andBlockNotEqualTo(Integer value) {
            this.addCriterion("block <>", value, "block");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andBlockNotEqualToColumn(Column column) {
            this.addCriterion("block <> " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andBlockGreaterThan(Integer value) {
            this.addCriterion("block >", value, "block");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andBlockGreaterThanColumn(Column column) {
            this.addCriterion("block > " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andBlockGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("block >=", value, "block");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andBlockGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("block >= " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andBlockLessThan(Integer value) {
            this.addCriterion("block <", value, "block");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andBlockLessThanColumn(Column column) {
            this.addCriterion("block < " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andBlockLessThanOrEqualTo(Integer value) {
            this.addCriterion("block <=", value, "block");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andBlockLessThanOrEqualToColumn(Column column) {
            this.addCriterion("block <= " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andBlockIn(List<Integer> values) {
            this.addCriterion("block in", values, "block");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andBlockNotIn(List<Integer> values) {
            this.addCriterion("block not in", values, "block");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andBlockBetween(Integer value1, Integer value2) {
            this.addCriterion("block between", value1, value2, "block");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andBlockNotBetween(Integer value1, Integer value2) {
            this.addCriterion("block not between", value1, value2, "block");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andCodeIsNull() {
            this.addCriterion("code is null");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andCodeIsNotNull() {
            this.addCriterion("code is not null");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andCodeEqualTo(String value) {
            this.addCriterion("code =", value, "code");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andCodeEqualToColumn(Column column) {
            this.addCriterion("code = " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andCodeNotEqualTo(String value) {
            this.addCriterion("code <>", value, "code");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andCodeNotEqualToColumn(Column column) {
            this.addCriterion("code <> " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andCodeGreaterThan(String value) {
            this.addCriterion("code >", value, "code");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andCodeGreaterThanColumn(Column column) {
            this.addCriterion("code > " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andCodeGreaterThanOrEqualTo(String value) {
            this.addCriterion("code >=", value, "code");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andCodeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("code >= " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andCodeLessThan(String value) {
            this.addCriterion("code <", value, "code");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andCodeLessThanColumn(Column column) {
            this.addCriterion("code < " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andCodeLessThanOrEqualTo(String value) {
            this.addCriterion("code <=", value, "code");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andCodeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("code <= " + column.getEscapedColumnName());
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andCodeLike(String value) {
            this.addCriterion("code like", value, "code");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andCodeNotLike(String value) {
            this.addCriterion("code not like", value, "code");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andCodeIn(List<String> values) {
            this.addCriterion("code in", values, "code");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andCodeNotIn(List<String> values) {
            this.addCriterion("code not in", values, "code");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andCodeBetween(String value1, String value2) {
            this.addCriterion("code between", value1, value2, "code");
            return (AccountsExample.Criteria)this;
        }

        public AccountsExample.Criteria andCodeNotBetween(String value1, String value2) {
            this.addCriterion("code not between", value1, value2, "code");
            return (AccountsExample.Criteria)this;
        }
    }
}
