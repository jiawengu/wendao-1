//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.gameserver.data.game;

public class SuitEffectUtils {
    public SuitEffectUtils() {
    }

    public static int[] suit(int sex, int attrib, int polar, int eq_polar) {
        int[] suit_light_effects = new int[]{7001, 7002, 7003, 7004, 7005};
        int[] effect_suit = new int[]{0, suit_light_effects[eq_polar - 1]};
        int[][] suit_icons;
        if (attrib <= 79) {
            suit_icons = new int[][]{{860701, 870702, 870703, 860704, 860705}, {870701, 860702, 860703, 870704, 870705}};
            effect_suit[0] = suit_icons[sex][polar - 1];
        } else if (attrib <= 89) {
            suit_icons = new int[][]{{860801, 870802, 870803, 860804, 860805}, {870801, 860802, 870803, 860804, 860805}};
            effect_suit[0] = suit_icons[sex][polar - 1];
        } else if (attrib < 99) {
            suit_icons = new int[][]{{860901, 870902, 870903, 860904, 860905}, {870901, 860902, 860903, 870904, 870905}};
            effect_suit[0] = suit_icons[sex][polar - 1];
        } else if (attrib < 109) {
            suit_icons = new int[][]{{861001, 871002, 871003, 861004, 861005}, {871001, 861002, 861003, 871004, 871005}};
            effect_suit[0] = suit_icons[sex][polar - 1];
        } else if (attrib < 119) {
            suit_icons = new int[][]{{861101, 871102, 871103, 861104, 861105}, {871101, 861102, 861103, 871104, 871105}};
            effect_suit[0] = suit_icons[sex][polar - 1];
        } else if (attrib < 129) {
            suit_icons = new int[][]{{861201, 871202, 871203, 861204, 861205}, {871201, 861202, 861203, 871204, 871205}};
            effect_suit[0] = suit_icons[sex][polar - 1];
        } else {
            suit_icons = new int[][]{{861301, 871302, 871303, 861304, 861305}, {871301, 861302, 861303, 871304, 871305}};
            effect_suit[0] = suit_icons[sex][polar - 1];
        }

        return effect_suit;
    }
}
