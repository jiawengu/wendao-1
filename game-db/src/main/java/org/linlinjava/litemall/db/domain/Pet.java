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

public class Pet implements Cloneable, Serializable {
    public static final Boolean IS_DELETED;
    public static final Boolean NOT_DELETED;
    private Integer id;
    /**
     * 对应图鉴的位置
     */
    private Integer index;
    /**
     * 携带等级
     */
    private Integer levelReq;
    /**
     * 血气成长
     */
    private Integer life;
    /**
     * 法力成长
     */
    private Integer mana;
    /**
     * 速度成长
     */
    private Integer speed;
    /**
     * 物攻成长
     */
    private Integer phyAttack;
    /**
     * 法攻成长
     */
    private Integer magAttack;
    /**
     * 金木水火土
     */
    private String polar;
    /**
     * 拥有天生技能
     */
    private String skiils;
    /**
     * 所在地图
     */
    private String zoon;
    /**
     * 外观
     */
    private Integer icon;
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
    /**
     * 名字
     */
    private String name;
    private static final long serialVersionUID = 1L;

    public Pet() {
    }

    public Integer getId() {
        return this.id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getIndex() {
        return this.index;
    }

    public void setIndex(Integer index) {
        this.index = index;
    }

    public Integer getLevelReq() {
        return this.levelReq;
    }

    public void setLevelReq(Integer levelReq) {
        this.levelReq = levelReq;
    }

    public Integer getLife() {
        return this.life;
    }

    public void setLife(Integer life) {
        this.life = life;
    }

    public Integer getMana() {
        return this.mana;
    }

    public void setMana(Integer mana) {
        this.mana = mana;
    }

    public Integer getSpeed() {
        return this.speed;
    }

    public void setSpeed(Integer speed) {
        this.speed = speed;
    }

    public Integer getPhyAttack() {
        return this.phyAttack;
    }

    public void setPhyAttack(Integer phyAttack) {
        this.phyAttack = phyAttack;
    }

    public Integer getMagAttack() {
        return this.magAttack;
    }

    public void setMagAttack(Integer magAttack) {
        this.magAttack = magAttack;
    }

    public String getPolar() {
        return this.polar;
    }

    public void setPolar(String polar) {
        this.polar = polar;
    }

    public String getSkiils() {
        return this.skiils;
    }

    public void setSkiils(String skiils) {
        this.skiils = skiils;
    }

    public String getZoon() {
        return this.zoon;
    }

    public void setZoon(String zoon) {
        this.zoon = zoon;
    }

    public Integer getIcon() {
        return this.icon;
    }

    public void setIcon(Integer icon) {
        this.icon = icon;
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
        this.setDeleted(deleted ? Pet.Deleted.IS_DELETED.value() : Pet.Deleted.NOT_DELETED.value());
    }

    public Boolean getDeleted() {
        return this.deleted;
    }

    public void setDeleted(Boolean deleted) {
        this.deleted = deleted;
    }

    public String getName() {
        return this.name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(this.getClass().getSimpleName());
        sb.append(" [");
        sb.append("Hash = ").append(this.hashCode());
        sb.append(", IS_DELETED=").append(IS_DELETED);
        sb.append(", NOT_DELETED=").append(NOT_DELETED);
        sb.append(", id=").append(this.id);
        sb.append(", index=").append(this.index);
        sb.append(", levelReq=").append(this.levelReq);
        sb.append(", life=").append(this.life);
        sb.append(", mana=").append(this.mana);
        sb.append(", speed=").append(this.speed);
        sb.append(", phyAttack=").append(this.phyAttack);
        sb.append(", magAttack=").append(this.magAttack);
        sb.append(", polar=").append(this.polar);
        sb.append(", skiils=").append(this.skiils);
        sb.append(", zoon=").append(this.zoon);
        sb.append(", icon=").append(this.icon);
        sb.append(", addTime=").append(this.addTime);
        sb.append(", updateTime=").append(this.updateTime);
        sb.append(", deleted=").append(this.deleted);
        sb.append(", name=").append(this.name);
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
            label161: {
                label153: {
                    Pet other = (Pet)that;
                    if (this.getId() == null) {
                        if (other.getId() != null) {
                            break label153;
                        }
                    } else if (!this.getId().equals(other.getId())) {
                        break label153;
                    }

                    if (this.getIndex() == null) {
                        if (other.getIndex() != null) {
                            break label153;
                        }
                    } else if (!this.getIndex().equals(other.getIndex())) {
                        break label153;
                    }

                    if (this.getLevelReq() == null) {
                        if (other.getLevelReq() != null) {
                            break label153;
                        }
                    } else if (!this.getLevelReq().equals(other.getLevelReq())) {
                        break label153;
                    }

                    if (this.getLife() == null) {
                        if (other.getLife() != null) {
                            break label153;
                        }
                    } else if (!this.getLife().equals(other.getLife())) {
                        break label153;
                    }

                    if (this.getMana() == null) {
                        if (other.getMana() != null) {
                            break label153;
                        }
                    } else if (!this.getMana().equals(other.getMana())) {
                        break label153;
                    }

                    if (this.getSpeed() == null) {
                        if (other.getSpeed() != null) {
                            break label153;
                        }
                    } else if (!this.getSpeed().equals(other.getSpeed())) {
                        break label153;
                    }

                    if (this.getPhyAttack() == null) {
                        if (other.getPhyAttack() != null) {
                            break label153;
                        }
                    } else if (!this.getPhyAttack().equals(other.getPhyAttack())) {
                        break label153;
                    }

                    if (this.getMagAttack() == null) {
                        if (other.getMagAttack() != null) {
                            break label153;
                        }
                    } else if (!this.getMagAttack().equals(other.getMagAttack())) {
                        break label153;
                    }

                    if (this.getPolar() == null) {
                        if (other.getPolar() != null) {
                            break label153;
                        }
                    } else if (!this.getPolar().equals(other.getPolar())) {
                        break label153;
                    }

                    if (this.getSkiils() == null) {
                        if (other.getSkiils() != null) {
                            break label153;
                        }
                    } else if (!this.getSkiils().equals(other.getSkiils())) {
                        break label153;
                    }

                    if (this.getZoon() == null) {
                        if (other.getZoon() != null) {
                            break label153;
                        }
                    } else if (!this.getZoon().equals(other.getZoon())) {
                        break label153;
                    }

                    if (this.getIcon() == null) {
                        if (other.getIcon() != null) {
                            break label153;
                        }
                    } else if (!this.getIcon().equals(other.getIcon())) {
                        break label153;
                    }

                    if (this.getAddTime() == null) {
                        if (other.getAddTime() != null) {
                            break label153;
                        }
                    } else if (!this.getAddTime().equals(other.getAddTime())) {
                        break label153;
                    }

                    if (this.getUpdateTime() == null) {
                        if (other.getUpdateTime() != null) {
                            break label153;
                        }
                    } else if (!this.getUpdateTime().equals(other.getUpdateTime())) {
                        break label153;
                    }

                    if (this.getDeleted() == null) {
                        if (other.getDeleted() != null) {
                            break label153;
                        }
                    } else if (!this.getDeleted().equals(other.getDeleted())) {
                        break label153;
                    }

                    if (this.getName() == null) {
                        if (other.getName() == null) {
                            break label161;
                        }
                    } else if (this.getName().equals(other.getName())) {
                        break label161;
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
        result = 31 * result + (this.getIndex() == null ? 0 : this.getIndex().hashCode());
        result = 31 * result + (this.getLevelReq() == null ? 0 : this.getLevelReq().hashCode());
        result = 31 * result + (this.getLife() == null ? 0 : this.getLife().hashCode());
        result = 31 * result + (this.getMana() == null ? 0 : this.getMana().hashCode());
        result = 31 * result + (this.getSpeed() == null ? 0 : this.getSpeed().hashCode());
        result = 31 * result + (this.getPhyAttack() == null ? 0 : this.getPhyAttack().hashCode());
        result = 31 * result + (this.getMagAttack() == null ? 0 : this.getMagAttack().hashCode());
        result = 31 * result + (this.getPolar() == null ? 0 : this.getPolar().hashCode());
        result = 31 * result + (this.getSkiils() == null ? 0 : this.getSkiils().hashCode());
        result = 31 * result + (this.getZoon() == null ? 0 : this.getZoon().hashCode());
        result = 31 * result + (this.getIcon() == null ? 0 : this.getIcon().hashCode());
        result = 31 * result + (this.getAddTime() == null ? 0 : this.getAddTime().hashCode());
        result = 31 * result + (this.getUpdateTime() == null ? 0 : this.getUpdateTime().hashCode());
        result = 31 * result + (this.getDeleted() == null ? 0 : this.getDeleted().hashCode());
        result = 31 * result + (this.getName() == null ? 0 : this.getName().hashCode());
        return result;
    }

    public Pet clone() throws CloneNotSupportedException {
        return (Pet)super.clone();
    }

    static {
        IS_DELETED = Pet.Deleted.IS_DELETED.value();
        NOT_DELETED = Pet.Deleted.NOT_DELETED.value();
    }

    public static enum Column {
        id("id", "id", "INTEGER", false),
        index("index", "index", "INTEGER", true),
        levelReq("level_req", "levelReq", "INTEGER", false),
        life("life", "life", "INTEGER", false),
        mana("mana", "mana", "INTEGER", false),
        speed("speed", "speed", "INTEGER", false),
        phyAttack("phy_attack", "phyAttack", "INTEGER", false),
        magAttack("mag_attack", "magAttack", "INTEGER", false),
        polar("polar", "polar", "VARCHAR", false),
        skiils("skiils", "skiils", "VARCHAR", false),
        zoon("zoon", "zoon", "VARCHAR", false),
        icon("icon", "icon", "INTEGER", false),
        addTime("add_time", "addTime", "TIMESTAMP", false),
        updateTime("update_time", "updateTime", "TIMESTAMP", false),
        deleted("deleted", "deleted", "BIT", false),
        name("name", "name", "VARCHAR", true);

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

        public static Pet.Column[] excludes(Pet.Column... excludes) {
            ArrayList<Pet.Column> columns = new ArrayList(Arrays.asList(values()));
            if (excludes != null && excludes.length > 0) {
                columns.removeAll(new ArrayList(Arrays.asList(excludes)));
            }

            return (Pet.Column[])columns.toArray(new Pet.Column[0]);
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
