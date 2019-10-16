package cn.rongplus.gateway.http;


import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

/**
 * @ClassName Bootstrap
 * @Description TODO
 * @Author liugang
 * @Date 2019/10/10 10:31
 * @Version
 */
@EnableDiscoveryClient
@SpringBootApplication
public class Bootstrap {

    public static void main(String[] args) {
        SpringApplication.run(Bootstrap.class, args);
    }
}
