import java.text.DecimalFormat;
import java.util.Scanner;

public class Main {

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        DecimalFormat decimalFormat = new DecimalFormat("#.##");
        System.out.println("");
        System.out.print("Введите размер диска: ");
        double all = scanner.nextDouble();
        System.out.print("Введите процент свободного места (запятая): ");
        double free = scanner.nextDouble();
        //Находим 1% и получаем кол-во свободного/занятого места
        double procent1 = all / 100;
        double zn = procent1 * (100 - free);
        System.out.println("Количество занятого места: " + zn);
        double fr = procent1 * free;
        String fr1 = decimalFormat.format(fr);
        System.out.println("Количество свободного места: " + fr1);
        //Расчет рекомендуемого пространства
        System.out.println("Рекомендации:");
        double procent10 = (all / 100) * 10;
        if (fr > procent10) {
            System.out.print("Все в порядке, свободного места достаточно");
        } else {
            String zn1 = decimalFormat.format(procent10 - fr);
            System.out.print("Необходимо добавить " + zn1);
        }

        System.out.println();
    }
}