# iOSJSInteraction

### oc js交互
##### WKScriptMessageHandler 处理交互
##### WKUIDelegate 处理弹框 关闭webview
##### WKNavigationDelegate 处理加载相关



```
  //结束时需要移除
  [self.webview.configuration.userContentController removeScriptMessageHandlerForName:@"customName"];
```

#### 温馨提示：不要在根控制器中测试内存泄露 不然你会怀疑Instruments和dealloc  哈哈
        
#### JSCore参考链接：https://www.qcloud.com/community/article/873202?fromSource=gwzcw.93410.93410.93410
        
