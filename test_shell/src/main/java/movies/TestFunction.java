import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.FutureTask;

public class TestFunction {
      /* public void  geta(int i){
           final int a=i;
           //开启异步
           new Thread(){
              @Override
               public  void run(){
                  try {
                      Thread.sleep(2000);
                  } catch (InterruptedException e) {
                      e.printStackTrace();
                  }

              }
           }.start();


       }*/

    public static void main(String[] args) throws InterruptedException, ExecutionException {
        System.out.println("开始执行------------------------");
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
        Object o= futureTask.get();
        System.out.println("获取到值------------------------"+o.toString());
        System.out.println("主线程阻塞中------------------------");
       // Thread.sleep(10000);

    }


}
