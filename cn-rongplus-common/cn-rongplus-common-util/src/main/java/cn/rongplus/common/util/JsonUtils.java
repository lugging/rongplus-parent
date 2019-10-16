
package cn.rongplus.common.util;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JavaType;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;

/*/**
  * @author liugang
  * @Description JSON 工具类
  * @Date 2019/10/14 15:30
  * @Param 
  * @return 
  *
  **/
public class JsonUtils {

    private static final ObjectMapper MAPPER = new ObjectMapper();

    private static final Logger logger = LoggerFactory.getLogger(JsonUtils.class);

    /**
     * pojo转换成json
     * <p>Title: pojoToJson</p>
     * <p>Description: </p>
     * @param data
     * @return
     */
    public static String objectToJson(Object data) {
        try {
            String string = MAPPER.writeValueAsString(data);
            return string;
        } catch (JsonProcessingException e) {
            logger.error(e.getMessage());
        }
        return null;
    }
    
    /**
     * json转换成pojo
     * 
     * @param jsonData json鏁版嵁
     * @param beanType 瀵硅薄涓殑object绫诲瀷
     * @return
     */
    public static <T> T jsonToPojo(String jsonData, Class<T> beanType) {
        try {
            T t = MAPPER.readValue(jsonData, beanType);
            return t;
        } catch (Exception e) {
            logger.error(e.getMessage());
        }
        return null;
    }
    
    /**
     * json转换成list
     * <p>Title: jsonToList</p>
     * <p>Description: </p>
     * @param jsonData
     * @param beanType
     * @return
     */
    public static <T>List<T> toList(String jsonData, Class<T> beanType) {
        JavaType javaType = MAPPER.getTypeFactory().constructParametricType(List.class, beanType);
        try {
            List<T> list = MAPPER.readValue(jsonData, javaType);
            return list;
        } catch (Exception e) {
            logger.error(e.getMessage());
        }
        return null;
    }
}