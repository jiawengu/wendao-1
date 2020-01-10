package org.linlinjava.litemall.db.dao;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import org.linlinjava.litemall.db.domain.UserPartyDailyTask;
import org.linlinjava.litemall.db.domain.UserPartyDailyTaskExample;

public interface UserPartyDailyTaskMapper {
    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table user_party_daily_task
     *
     * @mbg.generated Thu Jan 09 22:55:27 CST 2020
     */
    long countByExample(UserPartyDailyTaskExample example);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table user_party_daily_task
     *
     * @mbg.generated Thu Jan 09 22:55:27 CST 2020
     */
    int deleteByExample(UserPartyDailyTaskExample example);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table user_party_daily_task
     *
     * @mbg.generated Thu Jan 09 22:55:27 CST 2020
     */
    int deleteByPrimaryKey(Integer id);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table user_party_daily_task
     *
     * @mbg.generated Thu Jan 09 22:55:27 CST 2020
     */
    int insert(UserPartyDailyTask record);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table user_party_daily_task
     *
     * @mbg.generated Thu Jan 09 22:55:27 CST 2020
     */
    int insertSelective(UserPartyDailyTask record);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table user_party_daily_task
     *
     * @mbg.generated Thu Jan 09 22:55:27 CST 2020
     */
    List<UserPartyDailyTask> selectByExample(UserPartyDailyTaskExample example);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table user_party_daily_task
     *
     * @mbg.generated Thu Jan 09 22:55:27 CST 2020
     */
    UserPartyDailyTask selectByPrimaryKey(Integer id);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table user_party_daily_task
     *
     * @mbg.generated Thu Jan 09 22:55:27 CST 2020
     */
    int updateByExampleSelective(@Param("record") UserPartyDailyTask record, @Param("example") UserPartyDailyTaskExample example);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table user_party_daily_task
     *
     * @mbg.generated Thu Jan 09 22:55:27 CST 2020
     */
    int updateByExample(@Param("record") UserPartyDailyTask record, @Param("example") UserPartyDailyTaskExample example);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table user_party_daily_task
     *
     * @mbg.generated Thu Jan 09 22:55:27 CST 2020
     */
    int updateByPrimaryKeySelective(UserPartyDailyTask record);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table user_party_daily_task
     *
     * @mbg.generated Thu Jan 09 22:55:27 CST 2020
     */
    int updateByPrimaryKey(UserPartyDailyTask record);
}