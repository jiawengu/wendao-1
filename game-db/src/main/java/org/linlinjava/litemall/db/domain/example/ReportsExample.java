//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.domain.example;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.linlinjava.litemall.db.domain.Reports.Column;
import org.linlinjava.litemall.db.domain.Reports.Deleted;

public class ReportsExample {
    protected String orderByClause;
    protected boolean distinct;
    protected List<ReportsExample.Criteria> oredCriteria = new ArrayList();

    public ReportsExample() {
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

    public List<ReportsExample.Criteria> getOredCriteria() {
        return this.oredCriteria;
    }

    public void or(ReportsExample.Criteria criteria) {
        this.oredCriteria.add(criteria);
    }

    public ReportsExample.Criteria or() {
        ReportsExample.Criteria criteria = this.createCriteriaInternal();
        this.oredCriteria.add(criteria);
        return criteria;
    }

    public ReportsExample orderBy(String orderByClause) {
        this.setOrderByClause(orderByClause);
        return this;
    }

    public ReportsExample orderBy(String... orderByClauses) {
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

    public ReportsExample.Criteria createCriteria() {
        ReportsExample.Criteria criteria = this.createCriteriaInternal();
        if (this.oredCriteria.size() == 0) {
            this.oredCriteria.add(criteria);
        }

        return criteria;
    }

    protected ReportsExample.Criteria createCriteriaInternal() {
        ReportsExample.Criteria criteria = new ReportsExample.Criteria(this);
        return criteria;
    }

    public void clear() {
        this.oredCriteria.clear();
        this.orderByClause = null;
        this.distinct = false;
    }

    public static ReportsExample.Criteria newAndCreateCriteria() {
        ReportsExample example = new ReportsExample();
        return example.createCriteria();
    }

    public ReportsExample when(boolean condition, ReportsExample.IExampleWhen then) {
        if (condition) {
            then.example(this);
        }

        return this;
    }

    public ReportsExample when(boolean condition, ReportsExample.IExampleWhen then, ReportsExample.IExampleWhen otherwise) {
        if (condition) {
            then.example(this);
        } else {
            otherwise.example(this);
        }

        return this;
    }

    public interface IExampleWhen {
        void example(ReportsExample example);
    }

    public interface ICriteriaWhen {
        void criteria(ReportsExample.Criteria criteria);
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

    public static class Criteria extends ReportsExample.GeneratedCriteria {
        private ReportsExample example;

        protected Criteria(ReportsExample example) {
            this.example = example;
        }

        public ReportsExample example() {
            return this.example;
        }

        /** @deprecated */
        @Deprecated
        public ReportsExample.Criteria andIf(boolean ifAdd, ReportsExample.Criteria.ICriteriaAdd add) {
            if (ifAdd) {
                add.add(this);
            }

            return this;
        }

        public ReportsExample.Criteria when(boolean condition, ReportsExample.ICriteriaWhen then) {
            if (condition) {
                then.criteria(this);
            }

            return this;
        }

        public ReportsExample.Criteria when(boolean condition, ReportsExample.ICriteriaWhen then, ReportsExample.ICriteriaWhen otherwise) {
            if (condition) {
                then.criteria(this);
            } else {
                otherwise.criteria(this);
            }

            return this;
        }

        public ReportsExample.Criteria andLogicalDeleted(boolean deleted) {
            return deleted ? this.andDeletedEqualTo(Deleted.IS_DELETED.value()) : this.andDeletedNotEqualTo(Deleted.IS_DELETED.value());
        }

        /** @deprecated */
        @Deprecated
        public interface ICriteriaAdd {
            ReportsExample.Criteria add(ReportsExample.Criteria add);
        }
    }

    protected abstract static class GeneratedCriteria {
        protected List<ReportsExample.Criterion> criteria = new ArrayList();

        protected GeneratedCriteria() {
        }

        public boolean isValid() {
            return this.criteria.size() > 0;
        }

        public List<ReportsExample.Criterion> getAllCriteria() {
            return this.criteria;
        }

        public List<ReportsExample.Criterion> getCriteria() {
            return this.criteria;
        }

        protected void addCriterion(String condition) {
            if (condition == null) {
                throw new RuntimeException("Value for condition cannot be null");
            } else {
                this.criteria.add(new ReportsExample.Criterion(condition));
            }
        }

        protected void addCriterion(String condition, Object value, String property) {
            if (value == null) {
                throw new RuntimeException("Value for " + property + " cannot be null");
            } else {
                this.criteria.add(new ReportsExample.Criterion(condition, value));
            }
        }

        protected void addCriterion(String condition, Object value1, Object value2, String property) {
            if (value1 != null && value2 != null) {
                this.criteria.add(new ReportsExample.Criterion(condition, value1, value2));
            } else {
                throw new RuntimeException("Between values for " + property + " cannot be null");
            }
        }

        public ReportsExample.Criteria andIdIsNull() {
            this.addCriterion("id is null");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andIdIsNotNull() {
            this.addCriterion("id is not null");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andIdEqualTo(Integer value) {
            this.addCriterion("id =", value, "id");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andIdEqualToColumn(Column column) {
            this.addCriterion("id = " + column.getEscapedColumnName());
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andIdNotEqualTo(Integer value) {
            this.addCriterion("id <>", value, "id");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andIdNotEqualToColumn(Column column) {
            this.addCriterion("id <> " + column.getEscapedColumnName());
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andIdGreaterThan(Integer value) {
            this.addCriterion("id >", value, "id");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andIdGreaterThanColumn(Column column) {
            this.addCriterion("id > " + column.getEscapedColumnName());
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andIdGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("id >=", value, "id");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andIdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("id >= " + column.getEscapedColumnName());
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andIdLessThan(Integer value) {
            this.addCriterion("id <", value, "id");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andIdLessThanColumn(Column column) {
            this.addCriterion("id < " + column.getEscapedColumnName());
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andIdLessThanOrEqualTo(Integer value) {
            this.addCriterion("id <=", value, "id");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andIdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("id <= " + column.getEscapedColumnName());
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andIdIn(List<Integer> values) {
            this.addCriterion("id in", values, "id");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andIdNotIn(List<Integer> values) {
            this.addCriterion("id not in", values, "id");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andIdBetween(Integer value1, Integer value2) {
            this.addCriterion("id between", value1, value2, "id");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andIdNotBetween(Integer value1, Integer value2) {
            this.addCriterion("id not between", value1, value2, "id");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andZhanghaoIsNull() {
            this.addCriterion("zhanghao is null");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andZhanghaoIsNotNull() {
            this.addCriterion("zhanghao is not null");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andZhanghaoEqualTo(String value) {
            this.addCriterion("zhanghao =", value, "zhanghao");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andZhanghaoEqualToColumn(Column column) {
            this.addCriterion("zhanghao = " + column.getEscapedColumnName());
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andZhanghaoNotEqualTo(String value) {
            this.addCriterion("zhanghao <>", value, "zhanghao");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andZhanghaoNotEqualToColumn(Column column) {
            this.addCriterion("zhanghao <> " + column.getEscapedColumnName());
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andZhanghaoGreaterThan(String value) {
            this.addCriterion("zhanghao >", value, "zhanghao");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andZhanghaoGreaterThanColumn(Column column) {
            this.addCriterion("zhanghao > " + column.getEscapedColumnName());
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andZhanghaoGreaterThanOrEqualTo(String value) {
            this.addCriterion("zhanghao >=", value, "zhanghao");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andZhanghaoGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("zhanghao >= " + column.getEscapedColumnName());
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andZhanghaoLessThan(String value) {
            this.addCriterion("zhanghao <", value, "zhanghao");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andZhanghaoLessThanColumn(Column column) {
            this.addCriterion("zhanghao < " + column.getEscapedColumnName());
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andZhanghaoLessThanOrEqualTo(String value) {
            this.addCriterion("zhanghao <=", value, "zhanghao");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andZhanghaoLessThanOrEqualToColumn(Column column) {
            this.addCriterion("zhanghao <= " + column.getEscapedColumnName());
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andZhanghaoLike(String value) {
            this.addCriterion("zhanghao like", value, "zhanghao");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andZhanghaoNotLike(String value) {
            this.addCriterion("zhanghao not like", value, "zhanghao");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andZhanghaoIn(List<String> values) {
            this.addCriterion("zhanghao in", values, "zhanghao");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andZhanghaoNotIn(List<String> values) {
            this.addCriterion("zhanghao not in", values, "zhanghao");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andZhanghaoBetween(String value1, String value2) {
            this.addCriterion("zhanghao between", value1, value2, "zhanghao");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andZhanghaoNotBetween(String value1, String value2) {
            this.addCriterion("zhanghao not between", value1, value2, "zhanghao");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andYuanbaoshuIsNull() {
            this.addCriterion("yuanbaoshu is null");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andYuanbaoshuIsNotNull() {
            this.addCriterion("yuanbaoshu is not null");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andYuanbaoshuEqualTo(Integer value) {
            this.addCriterion("yuanbaoshu =", value, "yuanbaoshu");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andYuanbaoshuEqualToColumn(Column column) {
            this.addCriterion("yuanbaoshu = " + column.getEscapedColumnName());
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andYuanbaoshuNotEqualTo(Integer value) {
            this.addCriterion("yuanbaoshu <>", value, "yuanbaoshu");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andYuanbaoshuNotEqualToColumn(Column column) {
            this.addCriterion("yuanbaoshu <> " + column.getEscapedColumnName());
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andYuanbaoshuGreaterThan(Integer value) {
            this.addCriterion("yuanbaoshu >", value, "yuanbaoshu");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andYuanbaoshuGreaterThanColumn(Column column) {
            this.addCriterion("yuanbaoshu > " + column.getEscapedColumnName());
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andYuanbaoshuGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("yuanbaoshu >=", value, "yuanbaoshu");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andYuanbaoshuGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("yuanbaoshu >= " + column.getEscapedColumnName());
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andYuanbaoshuLessThan(Integer value) {
            this.addCriterion("yuanbaoshu <", value, "yuanbaoshu");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andYuanbaoshuLessThanColumn(Column column) {
            this.addCriterion("yuanbaoshu < " + column.getEscapedColumnName());
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andYuanbaoshuLessThanOrEqualTo(Integer value) {
            this.addCriterion("yuanbaoshu <=", value, "yuanbaoshu");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andYuanbaoshuLessThanOrEqualToColumn(Column column) {
            this.addCriterion("yuanbaoshu <= " + column.getEscapedColumnName());
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andYuanbaoshuIn(List<Integer> values) {
            this.addCriterion("yuanbaoshu in", values, "yuanbaoshu");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andYuanbaoshuNotIn(List<Integer> values) {
            this.addCriterion("yuanbaoshu not in", values, "yuanbaoshu");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andYuanbaoshuBetween(Integer value1, Integer value2) {
            this.addCriterion("yuanbaoshu between", value1, value2, "yuanbaoshu");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andYuanbaoshuNotBetween(Integer value1, Integer value2) {
            this.addCriterion("yuanbaoshu not between", value1, value2, "yuanbaoshu");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andShifouchongzhiIsNull() {
            this.addCriterion("shifouchongzhi is null");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andShifouchongzhiIsNotNull() {
            this.addCriterion("shifouchongzhi is not null");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andShifouchongzhiEqualTo(String value) {
            this.addCriterion("shifouchongzhi =", value, "shifouchongzhi");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andShifouchongzhiEqualToColumn(Column column) {
            this.addCriterion("shifouchongzhi = " + column.getEscapedColumnName());
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andShifouchongzhiNotEqualTo(String value) {
            this.addCriterion("shifouchongzhi <>", value, "shifouchongzhi");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andShifouchongzhiNotEqualToColumn(Column column) {
            this.addCriterion("shifouchongzhi <> " + column.getEscapedColumnName());
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andShifouchongzhiGreaterThan(String value) {
            this.addCriterion("shifouchongzhi >", value, "shifouchongzhi");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andShifouchongzhiGreaterThanColumn(Column column) {
            this.addCriterion("shifouchongzhi > " + column.getEscapedColumnName());
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andShifouchongzhiGreaterThanOrEqualTo(String value) {
            this.addCriterion("shifouchongzhi >=", value, "shifouchongzhi");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andShifouchongzhiGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("shifouchongzhi >= " + column.getEscapedColumnName());
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andShifouchongzhiLessThan(String value) {
            this.addCriterion("shifouchongzhi <", value, "shifouchongzhi");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andShifouchongzhiLessThanColumn(Column column) {
            this.addCriterion("shifouchongzhi < " + column.getEscapedColumnName());
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andShifouchongzhiLessThanOrEqualTo(String value) {
            this.addCriterion("shifouchongzhi <=", value, "shifouchongzhi");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andShifouchongzhiLessThanOrEqualToColumn(Column column) {
            this.addCriterion("shifouchongzhi <= " + column.getEscapedColumnName());
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andShifouchongzhiLike(String value) {
            this.addCriterion("shifouchongzhi like", value, "shifouchongzhi");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andShifouchongzhiNotLike(String value) {
            this.addCriterion("shifouchongzhi not like", value, "shifouchongzhi");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andShifouchongzhiIn(List<String> values) {
            this.addCriterion("shifouchongzhi in", values, "shifouchongzhi");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andShifouchongzhiNotIn(List<String> values) {
            this.addCriterion("shifouchongzhi not in", values, "shifouchongzhi");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andShifouchongzhiBetween(String value1, String value2) {
            this.addCriterion("shifouchongzhi between", value1, value2, "shifouchongzhi");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andShifouchongzhiNotBetween(String value1, String value2) {
            this.addCriterion("shifouchongzhi not between", value1, value2, "shifouchongzhi");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andAddTimeIsNull() {
            this.addCriterion("add_time is null");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andAddTimeIsNotNull() {
            this.addCriterion("add_time is not null");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andAddTimeEqualTo(LocalDateTime value) {
            this.addCriterion("add_time =", value, "addTime");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andAddTimeEqualToColumn(Column column) {
            this.addCriterion("add_time = " + column.getEscapedColumnName());
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andAddTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <>", value, "addTime");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andAddTimeNotEqualToColumn(Column column) {
            this.addCriterion("add_time <> " + column.getEscapedColumnName());
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andAddTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("add_time >", value, "addTime");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andAddTimeGreaterThanColumn(Column column) {
            this.addCriterion("add_time > " + column.getEscapedColumnName());
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andAddTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time >=", value, "addTime");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andAddTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time >= " + column.getEscapedColumnName());
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andAddTimeLessThan(LocalDateTime value) {
            this.addCriterion("add_time <", value, "addTime");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andAddTimeLessThanColumn(Column column) {
            this.addCriterion("add_time < " + column.getEscapedColumnName());
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andAddTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <=", value, "addTime");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andAddTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time <= " + column.getEscapedColumnName());
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andAddTimeIn(List<LocalDateTime> values) {
            this.addCriterion("add_time in", values, "addTime");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andAddTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("add_time not in", values, "addTime");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andAddTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time between", value1, value2, "addTime");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andAddTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time not between", value1, value2, "addTime");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andUpdateTimeIsNull() {
            this.addCriterion("update_time is null");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andUpdateTimeIsNotNull() {
            this.addCriterion("update_time is not null");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andUpdateTimeEqualTo(LocalDateTime value) {
            this.addCriterion("update_time =", value, "updateTime");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andUpdateTimeEqualToColumn(Column column) {
            this.addCriterion("update_time = " + column.getEscapedColumnName());
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andUpdateTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <>", value, "updateTime");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andUpdateTimeNotEqualToColumn(Column column) {
            this.addCriterion("update_time <> " + column.getEscapedColumnName());
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andUpdateTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("update_time >", value, "updateTime");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andUpdateTimeGreaterThanColumn(Column column) {
            this.addCriterion("update_time > " + column.getEscapedColumnName());
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andUpdateTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time >=", value, "updateTime");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andUpdateTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time >= " + column.getEscapedColumnName());
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andUpdateTimeLessThan(LocalDateTime value) {
            this.addCriterion("update_time <", value, "updateTime");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andUpdateTimeLessThanColumn(Column column) {
            this.addCriterion("update_time < " + column.getEscapedColumnName());
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andUpdateTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <=", value, "updateTime");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andUpdateTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time <= " + column.getEscapedColumnName());
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andUpdateTimeIn(List<LocalDateTime> values) {
            this.addCriterion("update_time in", values, "updateTime");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andUpdateTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("update_time not in", values, "updateTime");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andUpdateTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time between", value1, value2, "updateTime");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andUpdateTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time not between", value1, value2, "updateTime");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andDeletedIsNull() {
            this.addCriterion("deleted is null");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andDeletedIsNotNull() {
            this.addCriterion("deleted is not null");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andDeletedEqualTo(Boolean value) {
            this.addCriterion("deleted =", value, "deleted");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andDeletedEqualToColumn(Column column) {
            this.addCriterion("deleted = " + column.getEscapedColumnName());
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andDeletedNotEqualTo(Boolean value) {
            this.addCriterion("deleted <>", value, "deleted");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andDeletedNotEqualToColumn(Column column) {
            this.addCriterion("deleted <> " + column.getEscapedColumnName());
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andDeletedGreaterThan(Boolean value) {
            this.addCriterion("deleted >", value, "deleted");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andDeletedGreaterThanColumn(Column column) {
            this.addCriterion("deleted > " + column.getEscapedColumnName());
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andDeletedGreaterThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted >=", value, "deleted");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andDeletedGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted >= " + column.getEscapedColumnName());
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andDeletedLessThan(Boolean value) {
            this.addCriterion("deleted <", value, "deleted");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andDeletedLessThanColumn(Column column) {
            this.addCriterion("deleted < " + column.getEscapedColumnName());
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andDeletedLessThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted <=", value, "deleted");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andDeletedLessThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted <= " + column.getEscapedColumnName());
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andDeletedIn(List<Boolean> values) {
            this.addCriterion("deleted in", values, "deleted");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andDeletedNotIn(List<Boolean> values) {
            this.addCriterion("deleted not in", values, "deleted");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andDeletedBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted between", value1, value2, "deleted");
            return (ReportsExample.Criteria)this;
        }

        public ReportsExample.Criteria andDeletedNotBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted not between", value1, value2, "deleted");
            return (ReportsExample.Criteria)this;
        }
    }
}
