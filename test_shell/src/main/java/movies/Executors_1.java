import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.FutureTask;

public class Executors_1 {

    public static void main(String[] args) {
        ExecutorService executorService = Executors.newFixedThreadPool(1);
        executorService.execute(new Runnable() {
            @Override
            public void run() {
                System.out.println("开始1执行------------------------");
                FutureTask futureTask = new FutureTask(new Callable() {
                    @Override
                    public Object call() throws Exception {
                        Thread.sleep(3000);
                        return "success";
                    }
                });
                Thread thread = new Thread(futureTask);
                thread.start();
                System.out.println("执行主线程------------------------");
                if (!futureTask.isDone()) {
                    System.out.println("task has not finished!");
                }
               // Object o= futureTask.get();
                System.out.println("获取到值------------------------");
                System.out.println("主线程阻塞中------------------------");
            }
        });
        executorService.execute(new Runnable() {
            @Override
            public void run() {
                System.out.println("开始执行2------------------------");
                FutureTask futureTask = new FutureTask(new Callable() {
                    @Override
                    public Object call() throws Exception {
                        Thread.sleep(3000);
                        return "success";
                    }
                });
                Thread thread = new Thread(futureTask);
                thread.start();
                System.out.println("执行主线程------------------------");
                if (!futureTask.isDone()) {
                    System.out.println("task has not finished!");
                }
                //Object o= futureTask.get();
                System.out.println("获取到值------------------------");
                System.out.println("主线程阻塞中------------------------");
            }
        });



    }

}
