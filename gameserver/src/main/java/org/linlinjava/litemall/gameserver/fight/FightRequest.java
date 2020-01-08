//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.gameserver.fight;

public class FightRequest {
  /**
   * 攻击者id
   */
  public int id;
  /**
   * 受害者id
   */
  public int vid;
  /**
   * 2:
   * 3:使用技能
   * 4:使用背包物品
   * 7:
   */
  public int action;
  /**
   * 参数
   * 2:
   */
  public int para;
  public String para1;
  public String para2;
  public String para3;
  public String skill_talk;
  /**
   * 9050:血玲珑
   */
  public int item_type;

  public FightRequest() {
  }

  public void normalSkill(int id){
      this.id = id;
      this.action = 2;
      this.para = 2;
  }
}
