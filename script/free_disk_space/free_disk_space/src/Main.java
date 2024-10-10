import java.util.Scanner;

public class Main {
    public static void main() {
        Scanner scanner = new Scanner(System.in);
        System.out.println("");
        System.out.println("Введите размер диска:");
        double all = scanner.nextDouble();
        System.out.println("Введите процент свободного места:");
        double free = scanner.nextDouble();
        //Находим 1% и получаем кол-во свободного/занятого места
        double procent = all / 100;
        double fr = procent * free;
        System.out.println("Количество свободного места: " + fr);
        double zn = procent * (100 - free);
        System.out.println("Количество занятого места: " + zn);
    }
}