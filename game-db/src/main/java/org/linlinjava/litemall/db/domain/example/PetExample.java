//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.domain.example;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.linlinjava.litemall.db.domain.Pet.Column;
import org.linlinjava.litemall.db.domain.Pet.Deleted;

public class PetExample {
    protected String orderByClause;
    protected boolean distinct;
    protected List<PetExample.Criteria> oredCriteria = new ArrayList();

    public PetExample() {
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

    public List<PetExample.Criteria> getOredCriteria() {
        return this.oredCriteria;
    }

    public void or(PetExample.Criteria criteria) {
        this.oredCriteria.add(criteria);
    }

    public PetExample.Criteria or() {
        PetExample.Criteria criteria = this.createCriteriaInternal();
        this.oredCriteria.add(criteria);
        return criteria;
    }

    public PetExample orderBy(String orderByClause) {
        this.setOrderByClause(orderByClause);
        return this;
    }

    public PetExample orderBy(String... orderByClauses) {
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

    public PetExample.Criteria createCriteria() {
        PetExample.Criteria criteria = this.createCriteriaInternal();
        if (this.oredCriteria.size() == 0) {
            this.oredCriteria.add(criteria);
        }

        return criteria;
    }

    protected PetExample.Criteria createCriteriaInternal() {
        PetExample.Criteria criteria = new PetExample.Criteria(this);
        return criteria;
    }

    public void clear() {
        this.oredCriteria.clear();
        this.orderByClause = null;
        this.distinct = false;
    }

    public static PetExample.Criteria newAndCreateCriteria() {
        PetExample example = new PetExample();
        return example.createCriteria();
    }

    public PetExample when(boolean condition, PetExample.IExampleWhen then) {
        if (condition) {
            then.example(this);
        }

        return this;
    }

    public PetExample when(boolean condition, PetExample.IExampleWhen then, PetExample.IExampleWhen otherwise) {
        if (condition) {
            then.example(this);
        } else {
            otherwise.example(this);
        }

        return this;
    }

    public interface IExampleWhen {
        void example(PetExample example);
    }

    public interface ICriteriaWhen {
        void criteria(PetExample.Criteria criteria);
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

    public static class Criteria extends PetExample.GeneratedCriteria {
        private PetExample example;

        protected Criteria(PetExample example) {
            this.example = example;
        }

        public PetExample example() {
            return this.example;
        }

        /** @deprecated */
        @Deprecated
        public PetExample.Criteria andIf(boolean ifAdd, PetExample.Criteria.ICriteriaAdd add) {
            if (ifAdd) {
                add.add(this);
            }

            return this;
        }

        public PetExample.Criteria when(boolean condition, PetExample.ICriteriaWhen then) {
            if (condition) {
                then.criteria(this);
            }

            return this;
        }

        public PetExample.Criteria when(boolean condition, PetExample.ICriteriaWhen then, PetExample.ICriteriaWhen otherwise) {
            if (condition) {
                then.criteria(this);
            } else {
                otherwise.criteria(this);
            }

            return this;
        }

        public PetExample.Criteria andLogicalDeleted(boolean deleted) {
            return deleted ? this.andDeletedEqualTo(Deleted.IS_DELETED.value()) : this.andDeletedNotEqualTo(Deleted.IS_DELETED.value());
        }

        /** @deprecated */
        @Deprecated
        public interface ICriteriaAdd {
            PetExample.Criteria add(PetExample.Criteria add);
        }
    }

    protected abstract static class GeneratedCriteria {
        protected List<PetExample.Criterion> criteria = new ArrayList();

        protected GeneratedCriteria() {
        }

        public boolean isValid() {
            return this.criteria.size() > 0;
        }

        public List<PetExample.Criterion> getAllCriteria() {
            return this.criteria;
        }

        public List<PetExample.Criterion> getCriteria() {
            return this.criteria;
        }

        protected void addCriterion(String condition) {
            if (condition == null) {
                throw new RuntimeException("Value for condition cannot be null");
            } else {
                this.criteria.add(new PetExample.Criterion(condition));
            }
        }

        protected void addCriterion(String condition, Object value, String property) {
            if (value == null) {
                throw new RuntimeException("Value for " + property + " cannot be null");
            } else {
                this.criteria.add(new PetExample.Criterion(condition, value));
            }
        }

        protected void addCriterion(String condition, Object value1, Object value2, String property) {
            if (value1 != null && value2 != null) {
                this.criteria.add(new PetExample.Criterion(condition, value1, value2));
            } else {
                throw new RuntimeException("Between values for " + property + " cannot be null");
            }
        }

        public PetExample.Criteria andIdIsNull() {
            this.addCriterion("id is null");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIdIsNotNull() {
            this.addCriterion("id is not null");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIdEqualTo(Integer value) {
            this.addCriterion("id =", value, "id");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIdEqualToColumn(Column column) {
            this.addCriterion("id = " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIdNotEqualTo(Integer value) {
            this.addCriterion("id <>", value, "id");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIdNotEqualToColumn(Column column) {
            this.addCriterion("id <> " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIdGreaterThan(Integer value) {
            this.addCriterion("id >", value, "id");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIdGreaterThanColumn(Column column) {
            this.addCriterion("id > " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIdGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("id >=", value, "id");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("id >= " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIdLessThan(Integer value) {
            this.addCriterion("id <", value, "id");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIdLessThanColumn(Column column) {
            this.addCriterion("id < " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIdLessThanOrEqualTo(Integer value) {
            this.addCriterion("id <=", value, "id");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("id <= " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIdIn(List<Integer> values) {
            this.addCriterion("id in", values, "id");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIdNotIn(List<Integer> values) {
            this.addCriterion("id not in", values, "id");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIdBetween(Integer value1, Integer value2) {
            this.addCriterion("id between", value1, value2, "id");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIdNotBetween(Integer value1, Integer value2) {
            this.addCriterion("id not between", value1, value2, "id");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIndexIsNull() {
            this.addCriterion("`index` is null");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIndexIsNotNull() {
            this.addCriterion("`index` is not null");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIndexEqualTo(Integer value) {
            this.addCriterion("`index` =", value, "index");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIndexEqualToColumn(Column column) {
            this.addCriterion("`index` = " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIndexNotEqualTo(Integer value) {
            this.addCriterion("`index` <>", value, "index");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIndexNotEqualToColumn(Column column) {
            this.addCriterion("`index` <> " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIndexGreaterThan(Integer value) {
            this.addCriterion("`index` >", value, "index");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIndexGreaterThanColumn(Column column) {
            this.addCriterion("`index` > " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIndexGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("`index` >=", value, "index");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIndexGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`index` >= " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIndexLessThan(Integer value) {
            this.addCriterion("`index` <", value, "index");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIndexLessThanColumn(Column column) {
            this.addCriterion("`index` < " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIndexLessThanOrEqualTo(Integer value) {
            this.addCriterion("`index` <=", value, "index");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIndexLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`index` <= " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIndexIn(List<Integer> values) {
            this.addCriterion("`index` in", values, "index");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIndexNotIn(List<Integer> values) {
            this.addCriterion("`index` not in", values, "index");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIndexBetween(Integer value1, Integer value2) {
            this.addCriterion("`index` between", value1, value2, "index");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIndexNotBetween(Integer value1, Integer value2) {
            this.addCriterion("`index` not between", value1, value2, "index");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andLevelReqIsNull() {
            this.addCriterion("level_req is null");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andLevelReqIsNotNull() {
            this.addCriterion("level_req is not null");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andLevelReqEqualTo(Integer value) {
            this.addCriterion("level_req =", value, "levelReq");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andLevelReqEqualToColumn(Column column) {
            this.addCriterion("level_req = " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andLevelReqNotEqualTo(Integer value) {
            this.addCriterion("level_req <>", value, "levelReq");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andLevelReqNotEqualToColumn(Column column) {
            this.addCriterion("level_req <> " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andLevelReqGreaterThan(Integer value) {
            this.addCriterion("level_req >", value, "levelReq");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andLevelReqGreaterThanColumn(Column column) {
            this.addCriterion("level_req > " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andLevelReqGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("level_req >=", value, "levelReq");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andLevelReqGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("level_req >= " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andLevelReqLessThan(Integer value) {
            this.addCriterion("level_req <", value, "levelReq");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andLevelReqLessThanColumn(Column column) {
            this.addCriterion("level_req < " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andLevelReqLessThanOrEqualTo(Integer value) {
            this.addCriterion("level_req <=", value, "levelReq");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andLevelReqLessThanOrEqualToColumn(Column column) {
            this.addCriterion("level_req <= " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andLevelReqIn(List<Integer> values) {
            this.addCriterion("level_req in", values, "levelReq");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andLevelReqNotIn(List<Integer> values) {
            this.addCriterion("level_req not in", values, "levelReq");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andLevelReqBetween(Integer value1, Integer value2) {
            this.addCriterion("level_req between", value1, value2, "levelReq");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andLevelReqNotBetween(Integer value1, Integer value2) {
            this.addCriterion("level_req not between", value1, value2, "levelReq");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andLifeIsNull() {
            this.addCriterion("life is null");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andLifeIsNotNull() {
            this.addCriterion("life is not null");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andLifeEqualTo(Integer value) {
            this.addCriterion("life =", value, "life");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andLifeEqualToColumn(Column column) {
            this.addCriterion("life = " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andLifeNotEqualTo(Integer value) {
            this.addCriterion("life <>", value, "life");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andLifeNotEqualToColumn(Column column) {
            this.addCriterion("life <> " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andLifeGreaterThan(Integer value) {
            this.addCriterion("life >", value, "life");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andLifeGreaterThanColumn(Column column) {
            this.addCriterion("life > " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andLifeGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("life >=", value, "life");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andLifeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("life >= " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andLifeLessThan(Integer value) {
            this.addCriterion("life <", value, "life");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andLifeLessThanColumn(Column column) {
            this.addCriterion("life < " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andLifeLessThanOrEqualTo(Integer value) {
            this.addCriterion("life <=", value, "life");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andLifeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("life <= " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andLifeIn(List<Integer> values) {
            this.addCriterion("life in", values, "life");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andLifeNotIn(List<Integer> values) {
            this.addCriterion("life not in", values, "life");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andLifeBetween(Integer value1, Integer value2) {
            this.addCriterion("life between", value1, value2, "life");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andLifeNotBetween(Integer value1, Integer value2) {
            this.addCriterion("life not between", value1, value2, "life");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andManaIsNull() {
            this.addCriterion("mana is null");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andManaIsNotNull() {
            this.addCriterion("mana is not null");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andManaEqualTo(Integer value) {
            this.addCriterion("mana =", value, "mana");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andManaEqualToColumn(Column column) {
            this.addCriterion("mana = " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andManaNotEqualTo(Integer value) {
            this.addCriterion("mana <>", value, "mana");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andManaNotEqualToColumn(Column column) {
            this.addCriterion("mana <> " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andManaGreaterThan(Integer value) {
            this.addCriterion("mana >", value, "mana");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andManaGreaterThanColumn(Column column) {
            this.addCriterion("mana > " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andManaGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("mana >=", value, "mana");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andManaGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("mana >= " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andManaLessThan(Integer value) {
            this.addCriterion("mana <", value, "mana");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andManaLessThanColumn(Column column) {
            this.addCriterion("mana < " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andManaLessThanOrEqualTo(Integer value) {
            this.addCriterion("mana <=", value, "mana");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andManaLessThanOrEqualToColumn(Column column) {
            this.addCriterion("mana <= " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andManaIn(List<Integer> values) {
            this.addCriterion("mana in", values, "mana");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andManaNotIn(List<Integer> values) {
            this.addCriterion("mana not in", values, "mana");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andManaBetween(Integer value1, Integer value2) {
            this.addCriterion("mana between", value1, value2, "mana");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andManaNotBetween(Integer value1, Integer value2) {
            this.addCriterion("mana not between", value1, value2, "mana");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andSpeedIsNull() {
            this.addCriterion("speed is null");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andSpeedIsNotNull() {
            this.addCriterion("speed is not null");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andSpeedEqualTo(Integer value) {
            this.addCriterion("speed =", value, "speed");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andSpeedEqualToColumn(Column column) {
            this.addCriterion("speed = " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andSpeedNotEqualTo(Integer value) {
            this.addCriterion("speed <>", value, "speed");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andSpeedNotEqualToColumn(Column column) {
            this.addCriterion("speed <> " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andSpeedGreaterThan(Integer value) {
            this.addCriterion("speed >", value, "speed");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andSpeedGreaterThanColumn(Column column) {
            this.addCriterion("speed > " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andSpeedGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("speed >=", value, "speed");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andSpeedGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("speed >= " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andSpeedLessThan(Integer value) {
            this.addCriterion("speed <", value, "speed");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andSpeedLessThanColumn(Column column) {
            this.addCriterion("speed < " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andSpeedLessThanOrEqualTo(Integer value) {
            this.addCriterion("speed <=", value, "speed");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andSpeedLessThanOrEqualToColumn(Column column) {
            this.addCriterion("speed <= " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andSpeedIn(List<Integer> values) {
            this.addCriterion("speed in", values, "speed");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andSpeedNotIn(List<Integer> values) {
            this.addCriterion("speed not in", values, "speed");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andSpeedBetween(Integer value1, Integer value2) {
            this.addCriterion("speed between", value1, value2, "speed");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andSpeedNotBetween(Integer value1, Integer value2) {
            this.addCriterion("speed not between", value1, value2, "speed");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andPhyAttackIsNull() {
            this.addCriterion("phy_attack is null");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andPhyAttackIsNotNull() {
            this.addCriterion("phy_attack is not null");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andPhyAttackEqualTo(Integer value) {
            this.addCriterion("phy_attack =", value, "phyAttack");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andPhyAttackEqualToColumn(Column column) {
            this.addCriterion("phy_attack = " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andPhyAttackNotEqualTo(Integer value) {
            this.addCriterion("phy_attack <>", value, "phyAttack");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andPhyAttackNotEqualToColumn(Column column) {
            this.addCriterion("phy_attack <> " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andPhyAttackGreaterThan(Integer value) {
            this.addCriterion("phy_attack >", value, "phyAttack");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andPhyAttackGreaterThanColumn(Column column) {
            this.addCriterion("phy_attack > " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andPhyAttackGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("phy_attack >=", value, "phyAttack");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andPhyAttackGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("phy_attack >= " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andPhyAttackLessThan(Integer value) {
            this.addCriterion("phy_attack <", value, "phyAttack");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andPhyAttackLessThanColumn(Column column) {
            this.addCriterion("phy_attack < " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andPhyAttackLessThanOrEqualTo(Integer value) {
            this.addCriterion("phy_attack <=", value, "phyAttack");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andPhyAttackLessThanOrEqualToColumn(Column column) {
            this.addCriterion("phy_attack <= " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andPhyAttackIn(List<Integer> values) {
            this.addCriterion("phy_attack in", values, "phyAttack");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andPhyAttackNotIn(List<Integer> values) {
            this.addCriterion("phy_attack not in", values, "phyAttack");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andPhyAttackBetween(Integer value1, Integer value2) {
            this.addCriterion("phy_attack between", value1, value2, "phyAttack");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andPhyAttackNotBetween(Integer value1, Integer value2) {
            this.addCriterion("phy_attack not between", value1, value2, "phyAttack");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andMagAttackIsNull() {
            this.addCriterion("mag_attack is null");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andMagAttackIsNotNull() {
            this.addCriterion("mag_attack is not null");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andMagAttackEqualTo(Integer value) {
            this.addCriterion("mag_attack =", value, "magAttack");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andMagAttackEqualToColumn(Column column) {
            this.addCriterion("mag_attack = " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andMagAttackNotEqualTo(Integer value) {
            this.addCriterion("mag_attack <>", value, "magAttack");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andMagAttackNotEqualToColumn(Column column) {
            this.addCriterion("mag_attack <> " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andMagAttackGreaterThan(Integer value) {
            this.addCriterion("mag_attack >", value, "magAttack");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andMagAttackGreaterThanColumn(Column column) {
            this.addCriterion("mag_attack > " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andMagAttackGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("mag_attack >=", value, "magAttack");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andMagAttackGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("mag_attack >= " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andMagAttackLessThan(Integer value) {
            this.addCriterion("mag_attack <", value, "magAttack");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andMagAttackLessThanColumn(Column column) {
            this.addCriterion("mag_attack < " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andMagAttackLessThanOrEqualTo(Integer value) {
            this.addCriterion("mag_attack <=", value, "magAttack");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andMagAttackLessThanOrEqualToColumn(Column column) {
            this.addCriterion("mag_attack <= " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andMagAttackIn(List<Integer> values) {
            this.addCriterion("mag_attack in", values, "magAttack");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andMagAttackNotIn(List<Integer> values) {
            this.addCriterion("mag_attack not in", values, "magAttack");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andMagAttackBetween(Integer value1, Integer value2) {
            this.addCriterion("mag_attack between", value1, value2, "magAttack");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andMagAttackNotBetween(Integer value1, Integer value2) {
            this.addCriterion("mag_attack not between", value1, value2, "magAttack");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andPolarIsNull() {
            this.addCriterion("polar is null");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andPolarIsNotNull() {
            this.addCriterion("polar is not null");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andPolarEqualTo(String value) {
            this.addCriterion("polar =", value, "polar");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andPolarEqualToColumn(Column column) {
            this.addCriterion("polar = " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andPolarNotEqualTo(String value) {
            this.addCriterion("polar <>", value, "polar");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andPolarNotEqualToColumn(Column column) {
            this.addCriterion("polar <> " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andPolarGreaterThan(String value) {
            this.addCriterion("polar >", value, "polar");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andPolarGreaterThanColumn(Column column) {
            this.addCriterion("polar > " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andPolarGreaterThanOrEqualTo(String value) {
            this.addCriterion("polar >=", value, "polar");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andPolarGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("polar >= " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andPolarLessThan(String value) {
            this.addCriterion("polar <", value, "polar");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andPolarLessThanColumn(Column column) {
            this.addCriterion("polar < " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andPolarLessThanOrEqualTo(String value) {
            this.addCriterion("polar <=", value, "polar");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andPolarLessThanOrEqualToColumn(Column column) {
            this.addCriterion("polar <= " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andPolarLike(String value) {
            this.addCriterion("polar like", value, "polar");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andPolarNotLike(String value) {
            this.addCriterion("polar not like", value, "polar");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andPolarIn(List<String> values) {
            this.addCriterion("polar in", values, "polar");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andPolarNotIn(List<String> values) {
            this.addCriterion("polar not in", values, "polar");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andPolarBetween(String value1, String value2) {
            this.addCriterion("polar between", value1, value2, "polar");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andPolarNotBetween(String value1, String value2) {
            this.addCriterion("polar not between", value1, value2, "polar");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andSkiilsIsNull() {
            this.addCriterion("skiils is null");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andSkiilsIsNotNull() {
            this.addCriterion("skiils is not null");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andSkiilsEqualTo(String value) {
            this.addCriterion("skiils =", value, "skiils");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andSkiilsEqualToColumn(Column column) {
            this.addCriterion("skiils = " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andSkiilsNotEqualTo(String value) {
            this.addCriterion("skiils <>", value, "skiils");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andSkiilsNotEqualToColumn(Column column) {
            this.addCriterion("skiils <> " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andSkiilsGreaterThan(String value) {
            this.addCriterion("skiils >", value, "skiils");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andSkiilsGreaterThanColumn(Column column) {
            this.addCriterion("skiils > " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andSkiilsGreaterThanOrEqualTo(String value) {
            this.addCriterion("skiils >=", value, "skiils");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andSkiilsGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("skiils >= " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andSkiilsLessThan(String value) {
            this.addCriterion("skiils <", value, "skiils");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andSkiilsLessThanColumn(Column column) {
            this.addCriterion("skiils < " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andSkiilsLessThanOrEqualTo(String value) {
            this.addCriterion("skiils <=", value, "skiils");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andSkiilsLessThanOrEqualToColumn(Column column) {
            this.addCriterion("skiils <= " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andSkiilsLike(String value) {
            this.addCriterion("skiils like", value, "skiils");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andSkiilsNotLike(String value) {
            this.addCriterion("skiils not like", value, "skiils");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andSkiilsIn(List<String> values) {
            this.addCriterion("skiils in", values, "skiils");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andSkiilsNotIn(List<String> values) {
            this.addCriterion("skiils not in", values, "skiils");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andSkiilsBetween(String value1, String value2) {
            this.addCriterion("skiils between", value1, value2, "skiils");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andSkiilsNotBetween(String value1, String value2) {
            this.addCriterion("skiils not between", value1, value2, "skiils");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andZoonIsNull() {
            this.addCriterion("zoon is null");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andZoonIsNotNull() {
            this.addCriterion("zoon is not null");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andZoonEqualTo(String value) {
            this.addCriterion("zoon =", value, "zoon");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andZoonEqualToColumn(Column column) {
            this.addCriterion("zoon = " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andZoonNotEqualTo(String value) {
            this.addCriterion("zoon <>", value, "zoon");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andZoonNotEqualToColumn(Column column) {
            this.addCriterion("zoon <> " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andZoonGreaterThan(String value) {
            this.addCriterion("zoon >", value, "zoon");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andZoonGreaterThanColumn(Column column) {
            this.addCriterion("zoon > " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andZoonGreaterThanOrEqualTo(String value) {
            this.addCriterion("zoon >=", value, "zoon");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andZoonGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("zoon >= " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andZoonLessThan(String value) {
            this.addCriterion("zoon <", value, "zoon");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andZoonLessThanColumn(Column column) {
            this.addCriterion("zoon < " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andZoonLessThanOrEqualTo(String value) {
            this.addCriterion("zoon <=", value, "zoon");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andZoonLessThanOrEqualToColumn(Column column) {
            this.addCriterion("zoon <= " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andZoonLike(String value) {
            this.addCriterion("zoon like", value, "zoon");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andZoonNotLike(String value) {
            this.addCriterion("zoon not like", value, "zoon");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andZoonIn(List<String> values) {
            this.addCriterion("zoon in", values, "zoon");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andZoonNotIn(List<String> values) {
            this.addCriterion("zoon not in", values, "zoon");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andZoonBetween(String value1, String value2) {
            this.addCriterion("zoon between", value1, value2, "zoon");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andZoonNotBetween(String value1, String value2) {
            this.addCriterion("zoon not between", value1, value2, "zoon");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIconIsNull() {
            this.addCriterion("icon is null");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIconIsNotNull() {
            this.addCriterion("icon is not null");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIconEqualTo(Integer value) {
            this.addCriterion("icon =", value, "icon");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIconEqualToColumn(Column column) {
            this.addCriterion("icon = " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIconNotEqualTo(Integer value) {
            this.addCriterion("icon <>", value, "icon");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIconNotEqualToColumn(Column column) {
            this.addCriterion("icon <> " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIconGreaterThan(Integer value) {
            this.addCriterion("icon >", value, "icon");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIconGreaterThanColumn(Column column) {
            this.addCriterion("icon > " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIconGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("icon >=", value, "icon");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIconGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("icon >= " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIconLessThan(Integer value) {
            this.addCriterion("icon <", value, "icon");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIconLessThanColumn(Column column) {
            this.addCriterion("icon < " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIconLessThanOrEqualTo(Integer value) {
            this.addCriterion("icon <=", value, "icon");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIconLessThanOrEqualToColumn(Column column) {
            this.addCriterion("icon <= " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIconIn(List<Integer> values) {
            this.addCriterion("icon in", values, "icon");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIconNotIn(List<Integer> values) {
            this.addCriterion("icon not in", values, "icon");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIconBetween(Integer value1, Integer value2) {
            this.addCriterion("icon between", value1, value2, "icon");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andIconNotBetween(Integer value1, Integer value2) {
            this.addCriterion("icon not between", value1, value2, "icon");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andAddTimeIsNull() {
            this.addCriterion("add_time is null");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andAddTimeIsNotNull() {
            this.addCriterion("add_time is not null");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andAddTimeEqualTo(LocalDateTime value) {
            this.addCriterion("add_time =", value, "addTime");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andAddTimeEqualToColumn(Column column) {
            this.addCriterion("add_time = " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andAddTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <>", value, "addTime");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andAddTimeNotEqualToColumn(Column column) {
            this.addCriterion("add_time <> " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andAddTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("add_time >", value, "addTime");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andAddTimeGreaterThanColumn(Column column) {
            this.addCriterion("add_time > " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andAddTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time >=", value, "addTime");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andAddTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time >= " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andAddTimeLessThan(LocalDateTime value) {
            this.addCriterion("add_time <", value, "addTime");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andAddTimeLessThanColumn(Column column) {
            this.addCriterion("add_time < " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andAddTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <=", value, "addTime");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andAddTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time <= " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andAddTimeIn(List<LocalDateTime> values) {
            this.addCriterion("add_time in", values, "addTime");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andAddTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("add_time not in", values, "addTime");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andAddTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time between", value1, value2, "addTime");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andAddTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time not between", value1, value2, "addTime");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andUpdateTimeIsNull() {
            this.addCriterion("update_time is null");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andUpdateTimeIsNotNull() {
            this.addCriterion("update_time is not null");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andUpdateTimeEqualTo(LocalDateTime value) {
            this.addCriterion("update_time =", value, "updateTime");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andUpdateTimeEqualToColumn(Column column) {
            this.addCriterion("update_time = " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andUpdateTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <>", value, "updateTime");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andUpdateTimeNotEqualToColumn(Column column) {
            this.addCriterion("update_time <> " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andUpdateTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("update_time >", value, "updateTime");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andUpdateTimeGreaterThanColumn(Column column) {
            this.addCriterion("update_time > " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andUpdateTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time >=", value, "updateTime");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andUpdateTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time >= " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andUpdateTimeLessThan(LocalDateTime value) {
            this.addCriterion("update_time <", value, "updateTime");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andUpdateTimeLessThanColumn(Column column) {
            this.addCriterion("update_time < " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andUpdateTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <=", value, "updateTime");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andUpdateTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time <= " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andUpdateTimeIn(List<LocalDateTime> values) {
            this.addCriterion("update_time in", values, "updateTime");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andUpdateTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("update_time not in", values, "updateTime");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andUpdateTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time between", value1, value2, "updateTime");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andUpdateTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time not between", value1, value2, "updateTime");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andDeletedIsNull() {
            this.addCriterion("deleted is null");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andDeletedIsNotNull() {
            this.addCriterion("deleted is not null");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andDeletedEqualTo(Boolean value) {
            this.addCriterion("deleted =", value, "deleted");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andDeletedEqualToColumn(Column column) {
            this.addCriterion("deleted = " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andDeletedNotEqualTo(Boolean value) {
            this.addCriterion("deleted <>", value, "deleted");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andDeletedNotEqualToColumn(Column column) {
            this.addCriterion("deleted <> " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andDeletedGreaterThan(Boolean value) {
            this.addCriterion("deleted >", value, "deleted");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andDeletedGreaterThanColumn(Column column) {
            this.addCriterion("deleted > " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andDeletedGreaterThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted >=", value, "deleted");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andDeletedGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted >= " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andDeletedLessThan(Boolean value) {
            this.addCriterion("deleted <", value, "deleted");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andDeletedLessThanColumn(Column column) {
            this.addCriterion("deleted < " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andDeletedLessThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted <=", value, "deleted");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andDeletedLessThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted <= " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andDeletedIn(List<Boolean> values) {
            this.addCriterion("deleted in", values, "deleted");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andDeletedNotIn(List<Boolean> values) {
            this.addCriterion("deleted not in", values, "deleted");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andDeletedBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted between", value1, value2, "deleted");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andDeletedNotBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted not between", value1, value2, "deleted");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andNameIsNull() {
            this.addCriterion("`name` is null");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andNameIsNotNull() {
            this.addCriterion("`name` is not null");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andNameEqualTo(String value) {
            this.addCriterion("`name` =", value, "name");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andNameEqualToColumn(Column column) {
            this.addCriterion("`name` = " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andNameNotEqualTo(String value) {
            this.addCriterion("`name` <>", value, "name");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andNameNotEqualToColumn(Column column) {
            this.addCriterion("`name` <> " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andNameGreaterThan(String value) {
            this.addCriterion("`name` >", value, "name");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andNameGreaterThanColumn(Column column) {
            this.addCriterion("`name` > " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andNameGreaterThanOrEqualTo(String value) {
            this.addCriterion("`name` >=", value, "name");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andNameGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`name` >= " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andNameLessThan(String value) {
            this.addCriterion("`name` <", value, "name");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andNameLessThanColumn(Column column) {
            this.addCriterion("`name` < " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andNameLessThanOrEqualTo(String value) {
            this.addCriterion("`name` <=", value, "name");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andNameLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`name` <= " + column.getEscapedColumnName());
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andNameLike(String value) {
            this.addCriterion("`name` like", value, "name");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andNameNotLike(String value) {
            this.addCriterion("`name` not like", value, "name");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andNameIn(List<String> values) {
            this.addCriterion("`name` in", values, "name");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andNameNotIn(List<String> values) {
            this.addCriterion("`name` not in", values, "name");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andNameBetween(String value1, String value2) {
            this.addCriterion("`name` between", value1, value2, "name");
            return (PetExample.Criteria)this;
        }

        public PetExample.Criteria andNameNotBetween(String value1, String value2) {
            this.addCriterion("`name` not between", value1, value2, "name");
            return (PetExample.Criteria)this;
        }
    }
}
