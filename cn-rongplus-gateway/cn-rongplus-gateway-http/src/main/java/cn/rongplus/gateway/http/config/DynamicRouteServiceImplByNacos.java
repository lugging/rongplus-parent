package cn.rongplus.gateway.http.config;

import com.alibaba.nacos.api.NacosFactory;
import com.alibaba.nacos.api.config.ConfigService;
import com.alibaba.nacos.api.config.listener.Listener;
import com.alibaba.nacos.api.exception.NacosException;

import cn.rongplus.common.util.JsonUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.cloud.gateway.route.RouteDefinition;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.concurrent.Executor;

/*/**
  * @author liugang
  * @Description 使用配置中心Nacos 动态变更路由信息
  * @Date 2019/10/14 15:20
  * @Param 
  * @return 
  *
  **/
@Component
public class DynamicRouteServiceImplByNacos implements CommandLineRunner {

	@Autowired
    private DynamicRouteServiceImpl dynamicRouteService;

	@Autowired
    private NacosGatewayProperties nacosGatewayProperties;

	private static final Logger logger = LoggerFactory.getLogger(DynamicRouteServiceImplByNacos.class);

    /**
     * 监听Nacos Server下发的动态路由配置
     */
    public void dynamicRouteByNacosListener (){
        try {
            ConfigService configService= NacosFactory.createConfigService(nacosGatewayProperties.getAddress());
            String content = configService.getConfig(nacosGatewayProperties.getDataId(), nacosGatewayProperties.getGroupId(), nacosGatewayProperties.getTimeout());
            logger.info("init remote config {}",content);
            // 程序启动后，拉取配置信息，初始化
            updateRouteConfig(content);
            // 配置变更
            configService.addListener(nacosGatewayProperties.getDataId(), nacosGatewayProperties.getGroupId(), new Listener()  {
                @Override
                public void receiveConfigInfo(String configInfo) {
                    updateRouteConfig(configInfo);
                }
                @Override
                public Executor getExecutor() {
                    return null;
                }
            });
        } catch (NacosException e) {
            logger.error(e.getMessage(), e);
        }
    }

    /**
     *
     * 维护 RouteDefinition 配置信息
     * @param configInfo
     */
    private void updateRouteConfig(String configInfo){
        List<RouteDefinition> list = JsonUtils.toList(configInfo, RouteDefinition.class);
        list.forEach(definition-> dynamicRouteService.update(definition));
    }

	@Override
	public void run(String... args) throws Exception {
        dynamicRouteByNacosListener();
	}
}
