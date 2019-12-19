//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.domain;

import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.datatype.jsr310.deser.LocalDateTimeDeserializer;
import com.fasterxml.jackson.datatype.jsr310.ser.LocalDateTimeSerializer;
import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import org.springframework.format.annotation.DateTimeFormat;

public class Charge implements Cloneable, Serializable {
    public static final Boolean IS_DELETED;
    public static final Boolean NOT_DELETED;
    private Integer id;
    private String accountname;
    private Integer coin;
    private Integer state;
    @JsonDeserialize(
            using = LocalDateTimeDeserializer.class
    )
    @JsonSerialize(
            using = LocalDateTimeSerializer.class
    )
    @DateTimeFormat(
            pattern = "yyyy-MM-dd HH:mm:ss"
    )
    private LocalDateTime addTime;
    @JsonDeserialize(
            using = LocalDateTimeDeserializer.class
    )
    @JsonSerialize(
            using = LocalDateTimeSerializer.class
    )
    @DateTimeFormat(
            pattern = "yyyy-MM-dd HH:mm:ss"
    )
    private LocalDateTime updateTime;
    private Boolean deleted;
    private Integer money;
    private String code;
    private static final long serialVersionUID = 1L;

    public Charge() {
    }

    public Integer getId() {
        return this.id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getAccountname() {
        return this.accountname;
    }

    public void setAccountname(String accountname) {
        this.accountname = accountname;
    }

    public Integer getCoin() {
        return this.coin;
    }

    public void setCoin(Integer coin) {
        this.coin = coin;
    }

    public Integer getState() {
        return this.state;
    }

    public void setState(Integer state) {
        this.state = state;
    }

    public LocalDateTime getAddTime() {
        return this.addTime;
    }

    public void setAddTime(LocalDateTime addTime) {
        this.addTime = addTime;
    }

    public LocalDateTime getUpdateTime() {
        return this.updateTime;
    }

    public void setUpdateTime(LocalDateTime updateTime) {
        this.updateTime = updateTime;
    }

    public void andLogicalDeleted(boolean deleted) {
        this.setDeleted(deleted ? Charge.Deleted.IS_DELETED.value() : Charge.Deleted.NOT_DELETED.value());
    }

    public Boolean getDeleted() {
        return this.deleted;
    }

    public void setDeleted(Boolean deleted) {
        this.deleted = deleted;
    }

    public Integer getMoney() {
        return this.money;
    }

    public void setMoney(Integer money) {
        this.money = money;
    }

    public String getCode() {
        return this.code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(this.getClass().getSimpleName());
        sb.append(" [");
        sb.append("Hash = ").append(this.hashCode());
        sb.append(", IS_DELETED=").append(IS_DELETED);
        sb.append(", NOT_DELETED=").append(NOT_DELETED);
        sb.append(", id=").append(this.id);
        sb.append(", accountname=").append(this.accountname);
        sb.append(", coin=").append(this.coin);
        sb.append(", state=").append(this.state);
        sb.append(", addTime=").append(this.addTime);
        sb.append(", updateTime=").append(this.updateTime);
        sb.append(", deleted=").append(this.deleted);
        sb.append(", money=").append(this.money);
        sb.append(", code=").append(this.code);
        sb.append("]");
        return sb.toString();
    }

    public boolean equals(Object that) {
        if (this == that) {
            return true;
        } else if (that == null) {
            return false;
        } else if (this.getClass() != that.getClass()) {
            return false;
        } else {
            boolean var10000;
            label105: {
                label97: {
                    Charge other = (Charge)that;
                    if (this.getId() == null) {
                        if (other.getId() != null) {
                            break label97;
                        }
                    } else if (!this.getId().equals(other.getId())) {
                        break label97;
                    }

                    if (this.getAccountname() == null) {
                        if (other.getAccountname() != null) {
                            break label97;
                        }
                    } else if (!this.getAccountname().equals(other.getAccountname())) {
                        break label97;
                    }

                    if (this.getCoin() == null) {
                        if (other.getCoin() != null) {
                            break label97;
                        }
                    } else if (!this.getCoin().equals(other.getCoin())) {
                        break label97;
                    }

                    if (this.getState() == null) {
                        if (other.getState() != null) {
                            break label97;
                        }
                    } else if (!this.getState().equals(other.getState())) {
                        break label97;
                    }

                    if (this.getAddTime() == null) {
                        if (other.getAddTime() != null) {
                            break label97;
                        }
                    } else if (!this.getAddTime().equals(other.getAddTime())) {
                        break label97;
                    }

                    if (this.getUpdateTime() == null) {
                        if (other.getUpdateTime() != null) {
                            break label97;
                        }
                    } else if (!this.getUpdateTime().equals(other.getUpdateTime())) {
                        break label97;
                    }

                    if (this.getDeleted() == null) {
                        if (other.getDeleted() != null) {
                            break label97;
                        }
                    } else if (!this.getDeleted().equals(other.getDeleted())) {
                        break label97;
                    }

                    if (this.getMoney() == null) {
                        if (other.getMoney() != null) {
                            break label97;
                        }
                    } else if (!this.getMoney().equals(other.getMoney())) {
                        break label97;
                    }

                    if (this.getCode() == null) {
                        if (other.getCode() == null) {
                            break label105;
                        }
                    } else if (this.getCode().equals(other.getCode())) {
                        break label105;
                    }
                }

                var10000 = false;
                return var10000;
            }

            var10000 = true;
            return var10000;
        }
    }

    public int hashCode() {

        int result = 1;
         result = 31 * result + (this.getId() == null ? 0 : this.getId().hashCode());
        result = 31 * result + (this.getAccountname() == null ? 0 : this.getAccountname().hashCode());
        result = 31 * result + (this.getCoin() == null ? 0 : this.getCoin().hashCode());
        result = 31 * result + (this.getState() == null ? 0 : this.getState().hashCode());
        result = 31 * result + (this.getAddTime() == null ? 0 : this.getAddTime().hashCode());
        result = 31 * result + (this.getUpdateTime() == null ? 0 : this.getUpdateTime().hashCode());
        result = 31 * result + (this.getDeleted() == null ? 0 : this.getDeleted().hashCode());
        result = 31 * result + (this.getMoney() == null ? 0 : this.getMoney().hashCode());
        result = 31 * result + (this.getCode() == null ? 0 : this.getCode().hashCode());
        return result;
    }

    public Charge clone() throws CloneNotSupportedException {
        return (Charge)super.clone();
    }

    static {
        IS_DELETED = Charge.Deleted.IS_DELETED.value();
        NOT_DELETED = Charge.Deleted.NOT_DELETED.value();
    }

    public static enum Column {
        id("id", "id", "INTEGER", false),
        accountname("accountname", "accountname", "VARCHAR", false),
        coin("coin", "coin", "INTEGER", false),
        state("state", "state", "INTEGER", true),
        addTime("add_time", "addTime", "TIMESTAMP", false),
        updateTime("update_time", "updateTime", "TIMESTAMP", false),
        deleted("deleted", "deleted", "BIT", false),
        money("money", "money", "INTEGER", false),
        code("code", "code", "VARCHAR", false);

        private static final String BEGINNING_DELIMITER = "`";
        private static final String ENDING_DELIMITER = "`";
        private final String column;
        private final boolean isColumnNameDelimited;
        private final String javaProperty;
        private final String jdbcType;

        public String value() {
            return this.column;
        }

        public String getValue() {
            return this.column;
        }

        public String getJavaProperty() {
            return this.javaProperty;
        }

        public String getJdbcType() {
            return this.jdbcType;
        }

        private Column(String column, String javaProperty, String jdbcType, boolean isColumnNameDelimited) {
            this.column = column;
            this.javaProperty = javaProperty;
            this.jdbcType = jdbcType;
            this.isColumnNameDelimited = isColumnNameDelimited;
        }

        public String desc() {
            return this.getEscapedColumnName() + " DESC";
        }

        public String asc() {
            return this.getEscapedColumnName() + " ASC";
        }

        public static Charge.Column[] excludes(Charge.Column... excludes) {
            ArrayList<Charge.Column> columns = new ArrayList(Arrays.asList(values()));
            if (excludes != null && excludes.length > 0) {
                columns.removeAll(new ArrayList(Arrays.asList(excludes)));
            }

            return (Charge.Column[])columns.toArray(new Charge.Column[0]);
        }

        public String getEscapedColumnName() {
            return this.isColumnNameDelimited ? "`" + this.column + "`" : this.column;
        }
    }

    public static enum Deleted {
        NOT_DELETED(new Boolean("0"), "未删除"),
        IS_DELETED(new Boolean("1"), "已删除");

        private final Boolean value;
        private final String name;

        private Deleted(Boolean value, String name) {
            this.value = value;
            this.name = name;
        }

        public Boolean getValue() {
            return this.value;
        }

        public Boolean value() {
            return this.value;
        }

        public String getName() {
            return this.name;
        }
    }
}
