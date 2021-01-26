import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

import static java.lang.Thread.sleep;

public class Executors_Test {
    private static boolean flag =false;
    public static void main(String[] args) throws InterruptedException {
        System.out.println("主线程开始执行----------------------------");
        ExecutorService executorService = Executors.newFixedThreadPool(2);
        executorService.execute(new Runnable() {
            @Override
            public void run() {
                System.out.println("开始执行子线程1----------------------------start");
                try {
                    Thread.sleep(10000);
                }catch (Exception e){
                    System.out.println("线程1出错----------------------------"+e.getMessage());
                }
                System.out.println("开始执行子线程1----------------------------end");
                flag=true;
            }
        });
        /*executorService.execute(new Runnable() {
            @Override
            public void run() {
                System.out.println("开始执行子线程2----------------------------start");
                try {
                    Thread.sleep(15000);
                }catch (Exception e){
                    System.out.println("线程2出错----------------------------"+e.getMessage());
                }
                System.out.println("开始执行子线程2----------------------------end");
            }
        });*/
        executorService.shutdown();
        executorService.awaitTermination(60, TimeUnit.SECONDS);
        if(flag){



        }



        System.out.println("主线程----------------------------end");

    }

    public void ttt(){

    }
}
