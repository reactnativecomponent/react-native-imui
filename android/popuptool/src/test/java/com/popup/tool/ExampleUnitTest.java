package com.popup.tool;

import org.junit.Test;

/**
 * Example local unit test, which will execute on the development machine (host).
 *
 * @see <a href="http://d.android.com/tools/testing">Testing documentation</a>
 */
public class ExampleUnitTest {
    @Test
    public void addition_isCorrect() throws Exception {

        int totalMoneny = (int) (100.00F * 100);
        int num = 10;
        int maxMoney = totalMoneny * 2 / num;
        int minMoney = 1;
        for (int i = 1; i <= num; i++) {
            float money = 0;
            if (i == num) {
                money = totalMoneny;
                totalMoneny = 0;
            } else {
                maxMoney = totalMoneny / (num - i);
                money = (float) (Math.random() * maxMoney) + minMoney;
                totalMoneny -= money;
            }
            System.out.println(String.format("第%s个红包的数值为%s元, 余额为: %s元\\n", i + "", (money * 1.0F) / 100 + "", (totalMoneny * 1.0F) / 100 + ""));
        }
    }
}