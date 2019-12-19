//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.domain.example;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.linlinjava.litemall.db.domain.Friends.Column;
import org.linlinjava.litemall.db.domain.Friends.Deleted;

public class FriendsExample {
    protected String orderByClause;
    protected boolean distinct;
    protected List<FriendsExample.Criteria> oredCriteria = new ArrayList();

    public FriendsExample() {
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

    public List<FriendsExample.Criteria> getOredCriteria() {
        return this.oredCriteria;
    }

    public void or(FriendsExample.Criteria criteria) {
        this.oredCriteria.add(criteria);
    }

    public FriendsExample.Criteria or() {
        FriendsExample.Criteria criteria = this.createCriteriaInternal();
        this.oredCriteria.add(criteria);
        return criteria;
    }

    public FriendsExample orderBy(String orderByClause) {
        this.setOrderByClause(orderByClause);
        return this;
    }

    public FriendsExample orderBy(String... orderByClauses) {
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

    public FriendsExample.Criteria createCriteria() {
        FriendsExample.Criteria criteria = this.createCriteriaInternal();
        if (this.oredCriteria.size() == 0) {
            this.oredCriteria.add(criteria);
        }

        return criteria;
    }

    protected FriendsExample.Criteria createCriteriaInternal() {
        FriendsExample.Criteria criteria = new FriendsExample.Criteria(this);
        return criteria;
    }

    public void clear() {
        this.oredCriteria.clear();
        this.orderByClause = null;
        this.distinct = false;
    }

    public static FriendsExample.Criteria newAndCreateCriteria() {
        FriendsExample example = new FriendsExample();
        return example.createCriteria();
    }

    public FriendsExample when(boolean condition, FriendsExample.IExampleWhen then) {
        if (condition) {
            then.example(this);
        }

        return this;
    }

    public FriendsExample when(boolean condition, FriendsExample.IExampleWhen then, FriendsExample.IExampleWhen otherwise) {
        if (condition) {
            then.example(this);
        } else {
            otherwise.example(this);
        }

        return this;
    }

    public interface IExampleWhen {
        void example(FriendsExample example);
    }

    public interface ICriteriaWhen {
        void criteria(FriendsExample.Criteria criteria);
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

    public static class Criteria extends FriendsExample.GeneratedCriteria {
        private FriendsExample example;

        protected Criteria(FriendsExample example) {
            this.example = example;
        }

        public FriendsExample example() {
            return this.example;
        }

        /** @deprecated */
        @Deprecated
        public FriendsExample.Criteria andIf(boolean ifAdd, FriendsExample.Criteria.ICriteriaAdd add) {
            if (ifAdd) {
                add.add(this);
            }

            return this;
        }

        public FriendsExample.Criteria when(boolean condition, FriendsExample.ICriteriaWhen then) {
            if (condition) {
                then.criteria(this);
            }

            return this;
        }

        public FriendsExample.Criteria when(boolean condition, FriendsExample.ICriteriaWhen then, FriendsExample.ICriteriaWhen otherwise) {
            if (condition) {
                then.criteria(this);
            } else {
                otherwise.criteria(this);
            }

            return this;
        }

        public FriendsExample.Criteria andLogicalDeleted(boolean deleted) {
            return deleted ? this.andDeletedEqualTo(Deleted.IS_DELETED.value()) : this.andDeletedNotEqualTo(Deleted.IS_DELETED.value());
        }

        /** @deprecated */
        @Deprecated
        public interface ICriteriaAdd {
            FriendsExample.Criteria add(FriendsExample.Criteria add);
        }
    }

    protected abstract static class GeneratedCriteria {
        protected List<FriendsExample.Criterion> criteria = new ArrayList();

        protected GeneratedCriteria() {
        }

        public boolean isValid() {
            return this.criteria.size() > 0;
        }

        public List<FriendsExample.Criterion> getAllCriteria() {
            return this.criteria;
        }

        public List<FriendsExample.Criterion> getCriteria() {
            return this.criteria;
        }

        protected void addCriterion(String condition) {
            if (condition == null) {
                throw new RuntimeException("Value for condition cannot be null");
            } else {
                this.criteria.add(new FriendsExample.Criterion(condition));
            }
        }

        protected void addCriterion(String condition, Object value, String property) {
            if (value == null) {
                throw new RuntimeException("Value for " + property + " cannot be null");
            } else {
                this.criteria.add(new FriendsExample.Criterion(condition, value));
            }
        }

        protected void addCriterion(String condition, Object value1, Object value2, String property) {
            if (value1 != null && value2 != null) {
                this.criteria.add(new FriendsExample.Criterion(condition, value1, value2));
            } else {
                throw new RuntimeException("Between values for " + property + " cannot be null");
            }
        }

        public FriendsExample.Criteria andIdIsNull() {
            this.addCriterion("id is null");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andIdIsNotNull() {
            this.addCriterion("id is not null");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andIdEqualTo(Integer value) {
            this.addCriterion("id =", value, "id");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andIdEqualToColumn(Column column) {
            this.addCriterion("id = " + column.getEscapedColumnName());
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andIdNotEqualTo(Integer value) {
            this.addCriterion("id <>", value, "id");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andIdNotEqualToColumn(Column column) {
            this.addCriterion("id <> " + column.getEscapedColumnName());
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andIdGreaterThan(Integer value) {
            this.addCriterion("id >", value, "id");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andIdGreaterThanColumn(Column column) {
            this.addCriterion("id > " + column.getEscapedColumnName());
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andIdGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("id >=", value, "id");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andIdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("id >= " + column.getEscapedColumnName());
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andIdLessThan(Integer value) {
            this.addCriterion("id <", value, "id");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andIdLessThanColumn(Column column) {
            this.addCriterion("id < " + column.getEscapedColumnName());
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andIdLessThanOrEqualTo(Integer value) {
            this.addCriterion("id <=", value, "id");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andIdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("id <= " + column.getEscapedColumnName());
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andIdIn(List<Integer> values) {
            this.addCriterion("id in", values, "id");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andIdNotIn(List<Integer> values) {
            this.addCriterion("id not in", values, "id");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andIdBetween(Integer value1, Integer value2) {
            this.addCriterion("id between", value1, value2, "id");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andIdNotBetween(Integer value1, Integer value2) {
            this.addCriterion("id not between", value1, value2, "id");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andPidIsNull() {
            this.addCriterion("pid is null");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andPidIsNotNull() {
            this.addCriterion("pid is not null");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andPidEqualTo(String value) {
            this.addCriterion("pid =", value, "pid");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andPidEqualToColumn(Column column) {
            this.addCriterion("pid = " + column.getEscapedColumnName());
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andPidNotEqualTo(String value) {
            this.addCriterion("pid <>", value, "pid");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andPidNotEqualToColumn(Column column) {
            this.addCriterion("pid <> " + column.getEscapedColumnName());
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andPidGreaterThan(String value) {
            this.addCriterion("pid >", value, "pid");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andPidGreaterThanColumn(Column column) {
            this.addCriterion("pid > " + column.getEscapedColumnName());
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andPidGreaterThanOrEqualTo(String value) {
            this.addCriterion("pid >=", value, "pid");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andPidGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("pid >= " + column.getEscapedColumnName());
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andPidLessThan(String value) {
            this.addCriterion("pid <", value, "pid");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andPidLessThanColumn(Column column) {
            this.addCriterion("pid < " + column.getEscapedColumnName());
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andPidLessThanOrEqualTo(String value) {
            this.addCriterion("pid <=", value, "pid");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andPidLessThanOrEqualToColumn(Column column) {
            this.addCriterion("pid <= " + column.getEscapedColumnName());
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andPidLike(String value) {
            this.addCriterion("pid like", value, "pid");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andPidNotLike(String value) {
            this.addCriterion("pid not like", value, "pid");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andPidIn(List<String> values) {
            this.addCriterion("pid in", values, "pid");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andPidNotIn(List<String> values) {
            this.addCriterion("pid not in", values, "pid");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andPidBetween(String value1, String value2) {
            this.addCriterion("pid between", value1, value2, "pid");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andPidNotBetween(String value1, String value2) {
            this.addCriterion("pid not between", value1, value2, "pid");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andHy1IsNull() {
            this.addCriterion("hy1 is null");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andHy1IsNotNull() {
            this.addCriterion("hy1 is not null");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andHy1EqualTo(String value) {
            this.addCriterion("hy1 =", value, "hy1");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andHy1EqualToColumn(Column column) {
            this.addCriterion("hy1 = " + column.getEscapedColumnName());
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andHy1NotEqualTo(String value) {
            this.addCriterion("hy1 <>", value, "hy1");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andHy1NotEqualToColumn(Column column) {
            this.addCriterion("hy1 <> " + column.getEscapedColumnName());
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andHy1GreaterThan(String value) {
            this.addCriterion("hy1 >", value, "hy1");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andHy1GreaterThanColumn(Column column) {
            this.addCriterion("hy1 > " + column.getEscapedColumnName());
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andHy1GreaterThanOrEqualTo(String value) {
            this.addCriterion("hy1 >=", value, "hy1");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andHy1GreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("hy1 >= " + column.getEscapedColumnName());
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andHy1LessThan(String value) {
            this.addCriterion("hy1 <", value, "hy1");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andHy1LessThanColumn(Column column) {
            this.addCriterion("hy1 < " + column.getEscapedColumnName());
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andHy1LessThanOrEqualTo(String value) {
            this.addCriterion("hy1 <=", value, "hy1");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andHy1LessThanOrEqualToColumn(Column column) {
            this.addCriterion("hy1 <= " + column.getEscapedColumnName());
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andHy1Like(String value) {
            this.addCriterion("hy1 like", value, "hy1");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andHy1NotLike(String value) {
            this.addCriterion("hy1 not like", value, "hy1");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andHy1In(List<String> values) {
            this.addCriterion("hy1 in", values, "hy1");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andHy1NotIn(List<String> values) {
            this.addCriterion("hy1 not in", values, "hy1");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andHy1Between(String value1, String value2) {
            this.addCriterion("hy1 between", value1, value2, "hy1");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andHy1NotBetween(String value1, String value2) {
            this.addCriterion("hy1 not between", value1, value2, "hy1");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andAddTimeIsNull() {
            this.addCriterion("add_time is null");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andAddTimeIsNotNull() {
            this.addCriterion("add_time is not null");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andAddTimeEqualTo(LocalDateTime value) {
            this.addCriterion("add_time =", value, "addTime");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andAddTimeEqualToColumn(Column column) {
            this.addCriterion("add_time = " + column.getEscapedColumnName());
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andAddTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <>", value, "addTime");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andAddTimeNotEqualToColumn(Column column) {
            this.addCriterion("add_time <> " + column.getEscapedColumnName());
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andAddTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("add_time >", value, "addTime");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andAddTimeGreaterThanColumn(Column column) {
            this.addCriterion("add_time > " + column.getEscapedColumnName());
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andAddTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time >=", value, "addTime");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andAddTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time >= " + column.getEscapedColumnName());
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andAddTimeLessThan(LocalDateTime value) {
            this.addCriterion("add_time <", value, "addTime");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andAddTimeLessThanColumn(Column column) {
            this.addCriterion("add_time < " + column.getEscapedColumnName());
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andAddTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <=", value, "addTime");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andAddTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time <= " + column.getEscapedColumnName());
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andAddTimeIn(List<LocalDateTime> values) {
            this.addCriterion("add_time in", values, "addTime");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andAddTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("add_time not in", values, "addTime");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andAddTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time between", value1, value2, "addTime");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andAddTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time not between", value1, value2, "addTime");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andUpdateTimeIsNull() {
            this.addCriterion("update_time is null");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andUpdateTimeIsNotNull() {
            this.addCriterion("update_time is not null");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andUpdateTimeEqualTo(LocalDateTime value) {
            this.addCriterion("update_time =", value, "updateTime");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andUpdateTimeEqualToColumn(Column column) {
            this.addCriterion("update_time = " + column.getEscapedColumnName());
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andUpdateTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <>", value, "updateTime");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andUpdateTimeNotEqualToColumn(Column column) {
            this.addCriterion("update_time <> " + column.getEscapedColumnName());
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andUpdateTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("update_time >", value, "updateTime");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andUpdateTimeGreaterThanColumn(Column column) {
            this.addCriterion("update_time > " + column.getEscapedColumnName());
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andUpdateTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time >=", value, "updateTime");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andUpdateTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time >= " + column.getEscapedColumnName());
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andUpdateTimeLessThan(LocalDateTime value) {
            this.addCriterion("update_time <", value, "updateTime");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andUpdateTimeLessThanColumn(Column column) {
            this.addCriterion("update_time < " + column.getEscapedColumnName());
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andUpdateTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <=", value, "updateTime");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andUpdateTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time <= " + column.getEscapedColumnName());
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andUpdateTimeIn(List<LocalDateTime> values) {
            this.addCriterion("update_time in", values, "updateTime");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andUpdateTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("update_time not in", values, "updateTime");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andUpdateTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time between", value1, value2, "updateTime");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andUpdateTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time not between", value1, value2, "updateTime");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andDeletedIsNull() {
            this.addCriterion("deleted is null");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andDeletedIsNotNull() {
            this.addCriterion("deleted is not null");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andDeletedEqualTo(Boolean value) {
            this.addCriterion("deleted =", value, "deleted");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andDeletedEqualToColumn(Column column) {
            this.addCriterion("deleted = " + column.getEscapedColumnName());
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andDeletedNotEqualTo(Boolean value) {
            this.addCriterion("deleted <>", value, "deleted");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andDeletedNotEqualToColumn(Column column) {
            this.addCriterion("deleted <> " + column.getEscapedColumnName());
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andDeletedGreaterThan(Boolean value) {
            this.addCriterion("deleted >", value, "deleted");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andDeletedGreaterThanColumn(Column column) {
            this.addCriterion("deleted > " + column.getEscapedColumnName());
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andDeletedGreaterThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted >=", value, "deleted");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andDeletedGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted >= " + column.getEscapedColumnName());
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andDeletedLessThan(Boolean value) {
            this.addCriterion("deleted <", value, "deleted");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andDeletedLessThanColumn(Column column) {
            this.addCriterion("deleted < " + column.getEscapedColumnName());
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andDeletedLessThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted <=", value, "deleted");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andDeletedLessThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted <= " + column.getEscapedColumnName());
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andDeletedIn(List<Boolean> values) {
            this.addCriterion("deleted in", values, "deleted");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andDeletedNotIn(List<Boolean> values) {
            this.addCriterion("deleted not in", values, "deleted");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andDeletedBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted between", value1, value2, "deleted");
            return (FriendsExample.Criteria)this;
        }

        public FriendsExample.Criteria andDeletedNotBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted not between", value1, value2, "deleted");
            return (FriendsExample.Criteria)this;
        }
    }
}
