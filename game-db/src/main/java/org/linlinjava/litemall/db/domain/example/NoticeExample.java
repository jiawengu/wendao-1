//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.domain.example;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.linlinjava.litemall.db.domain.Notice.Column;
import org.linlinjava.litemall.db.domain.Notice.Deleted;

public class NoticeExample {
    protected String orderByClause;
    protected boolean distinct;
    protected List<NoticeExample.Criteria> oredCriteria = new ArrayList();

    public NoticeExample() {
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

    public List<NoticeExample.Criteria> getOredCriteria() {
        return this.oredCriteria;
    }

    public void or(NoticeExample.Criteria criteria) {
        this.oredCriteria.add(criteria);
    }

    public NoticeExample.Criteria or() {
        NoticeExample.Criteria criteria = this.createCriteriaInternal();
        this.oredCriteria.add(criteria);
        return criteria;
    }

    public NoticeExample orderBy(String orderByClause) {
        this.setOrderByClause(orderByClause);
        return this;
    }

    public NoticeExample orderBy(String... orderByClauses) {
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

    public NoticeExample.Criteria createCriteria() {
        NoticeExample.Criteria criteria = this.createCriteriaInternal();
        if (this.oredCriteria.size() == 0) {
            this.oredCriteria.add(criteria);
        }

        return criteria;
    }

    protected NoticeExample.Criteria createCriteriaInternal() {
        NoticeExample.Criteria criteria = new NoticeExample.Criteria(this);
        return criteria;
    }

    public void clear() {
        this.oredCriteria.clear();
        this.orderByClause = null;
        this.distinct = false;
    }

    public static NoticeExample.Criteria newAndCreateCriteria() {
        NoticeExample example = new NoticeExample();
        return example.createCriteria();
    }

    public NoticeExample when(boolean condition, NoticeExample.IExampleWhen then) {
        if (condition) {
            then.example(this);
        }

        return this;
    }

    public NoticeExample when(boolean condition, NoticeExample.IExampleWhen then, NoticeExample.IExampleWhen otherwise) {
        if (condition) {
            then.example(this);
        } else {
            otherwise.example(this);
        }

        return this;
    }

    public interface IExampleWhen {
        void example(NoticeExample example);
    }

    public interface ICriteriaWhen {
        void criteria(NoticeExample.Criteria criteria);
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

    public static class Criteria extends NoticeExample.GeneratedCriteria {
        private NoticeExample example;

        protected Criteria(NoticeExample example) {
            this.example = example;
        }

        public NoticeExample example() {
            return this.example;
        }

        /** @deprecated */
        @Deprecated
        public NoticeExample.Criteria andIf(boolean ifAdd, NoticeExample.Criteria.ICriteriaAdd add) {
            if (ifAdd) {
                add.add(this);
            }

            return this;
        }

        public NoticeExample.Criteria when(boolean condition, NoticeExample.ICriteriaWhen then) {
            if (condition) {
                then.criteria(this);
            }

            return this;
        }

        public NoticeExample.Criteria when(boolean condition, NoticeExample.ICriteriaWhen then, NoticeExample.ICriteriaWhen otherwise) {
            if (condition) {
                then.criteria(this);
            } else {
                otherwise.criteria(this);
            }

            return this;
        }

        public NoticeExample.Criteria andLogicalDeleted(boolean deleted) {
            return deleted ? this.andDeletedEqualTo(Deleted.IS_DELETED.value()) : this.andDeletedNotEqualTo(Deleted.IS_DELETED.value());
        }

        /** @deprecated */
        @Deprecated
        public interface ICriteriaAdd {
            NoticeExample.Criteria add(NoticeExample.Criteria add);
        }
    }

    protected abstract static class GeneratedCriteria {
        protected List<NoticeExample.Criterion> criteria = new ArrayList();

        protected GeneratedCriteria() {
        }

        public boolean isValid() {
            return this.criteria.size() > 0;
        }

        public List<NoticeExample.Criterion> getAllCriteria() {
            return this.criteria;
        }

        public List<NoticeExample.Criterion> getCriteria() {
            return this.criteria;
        }

        protected void addCriterion(String condition) {
            if (condition == null) {
                throw new RuntimeException("Value for condition cannot be null");
            } else {
                this.criteria.add(new NoticeExample.Criterion(condition));
            }
        }

        protected void addCriterion(String condition, Object value, String property) {
            if (value == null) {
                throw new RuntimeException("Value for " + property + " cannot be null");
            } else {
                this.criteria.add(new NoticeExample.Criterion(condition, value));
            }
        }

        protected void addCriterion(String condition, Object value1, Object value2, String property) {
            if (value1 != null && value2 != null) {
                this.criteria.add(new NoticeExample.Criterion(condition, value1, value2));
            } else {
                throw new RuntimeException("Between values for " + property + " cannot be null");
            }
        }

        public NoticeExample.Criteria andIdIsNull() {
            this.addCriterion("id is null");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andIdIsNotNull() {
            this.addCriterion("id is not null");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andIdEqualTo(Integer value) {
            this.addCriterion("id =", value, "id");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andIdEqualToColumn(Column column) {
            this.addCriterion("id = " + column.getEscapedColumnName());
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andIdNotEqualTo(Integer value) {
            this.addCriterion("id <>", value, "id");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andIdNotEqualToColumn(Column column) {
            this.addCriterion("id <> " + column.getEscapedColumnName());
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andIdGreaterThan(Integer value) {
            this.addCriterion("id >", value, "id");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andIdGreaterThanColumn(Column column) {
            this.addCriterion("id > " + column.getEscapedColumnName());
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andIdGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("id >=", value, "id");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andIdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("id >= " + column.getEscapedColumnName());
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andIdLessThan(Integer value) {
            this.addCriterion("id <", value, "id");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andIdLessThanColumn(Column column) {
            this.addCriterion("id < " + column.getEscapedColumnName());
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andIdLessThanOrEqualTo(Integer value) {
            this.addCriterion("id <=", value, "id");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andIdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("id <= " + column.getEscapedColumnName());
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andIdIn(List<Integer> values) {
            this.addCriterion("id in", values, "id");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andIdNotIn(List<Integer> values) {
            this.addCriterion("id not in", values, "id");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andIdBetween(Integer value1, Integer value2) {
            this.addCriterion("id between", value1, value2, "id");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andIdNotBetween(Integer value1, Integer value2) {
            this.addCriterion("id not between", value1, value2, "id");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andMessageIsNull() {
            this.addCriterion("message is null");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andMessageIsNotNull() {
            this.addCriterion("message is not null");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andMessageEqualTo(String value) {
            this.addCriterion("message =", value, "message");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andMessageEqualToColumn(Column column) {
            this.addCriterion("message = " + column.getEscapedColumnName());
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andMessageNotEqualTo(String value) {
            this.addCriterion("message <>", value, "message");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andMessageNotEqualToColumn(Column column) {
            this.addCriterion("message <> " + column.getEscapedColumnName());
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andMessageGreaterThan(String value) {
            this.addCriterion("message >", value, "message");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andMessageGreaterThanColumn(Column column) {
            this.addCriterion("message > " + column.getEscapedColumnName());
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andMessageGreaterThanOrEqualTo(String value) {
            this.addCriterion("message >=", value, "message");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andMessageGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("message >= " + column.getEscapedColumnName());
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andMessageLessThan(String value) {
            this.addCriterion("message <", value, "message");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andMessageLessThanColumn(Column column) {
            this.addCriterion("message < " + column.getEscapedColumnName());
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andMessageLessThanOrEqualTo(String value) {
            this.addCriterion("message <=", value, "message");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andMessageLessThanOrEqualToColumn(Column column) {
            this.addCriterion("message <= " + column.getEscapedColumnName());
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andMessageLike(String value) {
            this.addCriterion("message like", value, "message");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andMessageNotLike(String value) {
            this.addCriterion("message not like", value, "message");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andMessageIn(List<String> values) {
            this.addCriterion("message in", values, "message");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andMessageNotIn(List<String> values) {
            this.addCriterion("message not in", values, "message");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andMessageBetween(String value1, String value2) {
            this.addCriterion("message between", value1, value2, "message");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andMessageNotBetween(String value1, String value2) {
            this.addCriterion("message not between", value1, value2, "message");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andTimeIsNull() {
            this.addCriterion("`time` is null");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andTimeIsNotNull() {
            this.addCriterion("`time` is not null");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andTimeEqualTo(Integer value) {
            this.addCriterion("`time` =", value, "time");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andTimeEqualToColumn(Column column) {
            this.addCriterion("`time` = " + column.getEscapedColumnName());
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andTimeNotEqualTo(Integer value) {
            this.addCriterion("`time` <>", value, "time");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andTimeNotEqualToColumn(Column column) {
            this.addCriterion("`time` <> " + column.getEscapedColumnName());
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andTimeGreaterThan(Integer value) {
            this.addCriterion("`time` >", value, "time");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andTimeGreaterThanColumn(Column column) {
            this.addCriterion("`time` > " + column.getEscapedColumnName());
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andTimeGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("`time` >=", value, "time");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`time` >= " + column.getEscapedColumnName());
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andTimeLessThan(Integer value) {
            this.addCriterion("`time` <", value, "time");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andTimeLessThanColumn(Column column) {
            this.addCriterion("`time` < " + column.getEscapedColumnName());
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andTimeLessThanOrEqualTo(Integer value) {
            this.addCriterion("`time` <=", value, "time");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`time` <= " + column.getEscapedColumnName());
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andTimeIn(List<Integer> values) {
            this.addCriterion("`time` in", values, "time");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andTimeNotIn(List<Integer> values) {
            this.addCriterion("`time` not in", values, "time");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andTimeBetween(Integer value1, Integer value2) {
            this.addCriterion("`time` between", value1, value2, "time");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andTimeNotBetween(Integer value1, Integer value2) {
            this.addCriterion("`time` not between", value1, value2, "time");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andAddTimeIsNull() {
            this.addCriterion("add_time is null");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andAddTimeIsNotNull() {
            this.addCriterion("add_time is not null");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andAddTimeEqualTo(LocalDateTime value) {
            this.addCriterion("add_time =", value, "addTime");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andAddTimeEqualToColumn(Column column) {
            this.addCriterion("add_time = " + column.getEscapedColumnName());
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andAddTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <>", value, "addTime");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andAddTimeNotEqualToColumn(Column column) {
            this.addCriterion("add_time <> " + column.getEscapedColumnName());
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andAddTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("add_time >", value, "addTime");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andAddTimeGreaterThanColumn(Column column) {
            this.addCriterion("add_time > " + column.getEscapedColumnName());
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andAddTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time >=", value, "addTime");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andAddTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time >= " + column.getEscapedColumnName());
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andAddTimeLessThan(LocalDateTime value) {
            this.addCriterion("add_time <", value, "addTime");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andAddTimeLessThanColumn(Column column) {
            this.addCriterion("add_time < " + column.getEscapedColumnName());
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andAddTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <=", value, "addTime");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andAddTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time <= " + column.getEscapedColumnName());
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andAddTimeIn(List<LocalDateTime> values) {
            this.addCriterion("add_time in", values, "addTime");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andAddTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("add_time not in", values, "addTime");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andAddTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time between", value1, value2, "addTime");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andAddTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time not between", value1, value2, "addTime");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andUpdateTimeIsNull() {
            this.addCriterion("update_time is null");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andUpdateTimeIsNotNull() {
            this.addCriterion("update_time is not null");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andUpdateTimeEqualTo(LocalDateTime value) {
            this.addCriterion("update_time =", value, "updateTime");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andUpdateTimeEqualToColumn(Column column) {
            this.addCriterion("update_time = " + column.getEscapedColumnName());
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andUpdateTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <>", value, "updateTime");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andUpdateTimeNotEqualToColumn(Column column) {
            this.addCriterion("update_time <> " + column.getEscapedColumnName());
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andUpdateTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("update_time >", value, "updateTime");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andUpdateTimeGreaterThanColumn(Column column) {
            this.addCriterion("update_time > " + column.getEscapedColumnName());
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andUpdateTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time >=", value, "updateTime");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andUpdateTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time >= " + column.getEscapedColumnName());
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andUpdateTimeLessThan(LocalDateTime value) {
            this.addCriterion("update_time <", value, "updateTime");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andUpdateTimeLessThanColumn(Column column) {
            this.addCriterion("update_time < " + column.getEscapedColumnName());
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andUpdateTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <=", value, "updateTime");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andUpdateTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time <= " + column.getEscapedColumnName());
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andUpdateTimeIn(List<LocalDateTime> values) {
            this.addCriterion("update_time in", values, "updateTime");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andUpdateTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("update_time not in", values, "updateTime");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andUpdateTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time between", value1, value2, "updateTime");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andUpdateTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time not between", value1, value2, "updateTime");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andDeletedIsNull() {
            this.addCriterion("deleted is null");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andDeletedIsNotNull() {
            this.addCriterion("deleted is not null");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andDeletedEqualTo(Boolean value) {
            this.addCriterion("deleted =", value, "deleted");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andDeletedEqualToColumn(Column column) {
            this.addCriterion("deleted = " + column.getEscapedColumnName());
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andDeletedNotEqualTo(Boolean value) {
            this.addCriterion("deleted <>", value, "deleted");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andDeletedNotEqualToColumn(Column column) {
            this.addCriterion("deleted <> " + column.getEscapedColumnName());
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andDeletedGreaterThan(Boolean value) {
            this.addCriterion("deleted >", value, "deleted");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andDeletedGreaterThanColumn(Column column) {
            this.addCriterion("deleted > " + column.getEscapedColumnName());
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andDeletedGreaterThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted >=", value, "deleted");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andDeletedGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted >= " + column.getEscapedColumnName());
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andDeletedLessThan(Boolean value) {
            this.addCriterion("deleted <", value, "deleted");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andDeletedLessThanColumn(Column column) {
            this.addCriterion("deleted < " + column.getEscapedColumnName());
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andDeletedLessThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted <=", value, "deleted");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andDeletedLessThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted <= " + column.getEscapedColumnName());
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andDeletedIn(List<Boolean> values) {
            this.addCriterion("deleted in", values, "deleted");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andDeletedNotIn(List<Boolean> values) {
            this.addCriterion("deleted not in", values, "deleted");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andDeletedBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted between", value1, value2, "deleted");
            return (NoticeExample.Criteria)this;
        }

        public NoticeExample.Criteria andDeletedNotBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted not between", value1, value2, "deleted");
            return (NoticeExample.Criteria)this;
        }
    }
}
