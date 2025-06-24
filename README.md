# go语言简化的集成WebKitGtk应用框架(Simplified WebKitGtk program in Go language)
这个包可以和我的另一个功能包`gitee.com/rocket049/websocketrpc`结合使用实现类似`electron`的功能。
后端用go语言实现一个集成了websocket和静态文件服务的服务端。
前端用这个包方便的调用GTK4和WebKitGtk-6.0实现一个简单的浏览器。
前端调用后端的时候用`fetch`调用普通的`web api`。
后端调用前端的时候，用运行在`websocket`上的`RPC`调用。

## 功能扩展：

* 前端可以用`react`等框架制作复杂界面，后端调用前端只需要仿照`static/main.js`的代码改变扩展功能。
* 后端可以用`httpserver.HandleFunc`增加各种`API`。
* 已支持打开本地“文件选择对话框”、“目录选择对话框”、“文件保存对话框”。
