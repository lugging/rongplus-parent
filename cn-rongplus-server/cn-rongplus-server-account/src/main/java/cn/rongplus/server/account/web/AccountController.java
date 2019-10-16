package cn.rongplus.server.account.web;

import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * @ClassName AccountController
 * @Description 账号服务接口
 * @Author liugang
 * @Date 2019/10/16 10:13
 * @Version
 */
@Slf4j
@RestController
public class AccountController {

    /**
      * @author liugang
      * @Description 测试类
      * @Date 2019/10/16 10:19
      * @Param [request, response]
      * @return void
      *
      **/
    @PostMapping(value = "say")
    public void say(HttpServletRequest request, HttpServletResponse response){
        
    }


}
