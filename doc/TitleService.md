# 普通称谓
直接调用`grantTitle`接口
# 可抢夺称谓
调用`robTitle`接口
# event, title
去`TitleConst.java`找对应的常量

# Debug
向`ip:81/debug/grant-title`发送post请求,body为
```json
{
	"uid": 10048,
	"source": "英雄会挑战",
	"title": "新入道途"
}
```