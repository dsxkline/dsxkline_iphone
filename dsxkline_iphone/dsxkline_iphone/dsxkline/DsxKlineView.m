//
//  DsxKlineView.m
//  dsxkline_iphone
//
//  Created by ming feng on 2022/4/20.
//

#import "DsxKlineView.h"
#import <WebKit/WebKit.h>

@interface DsxKlineView()<WKNavigationDelegate,WKScriptMessageHandler>

@property (nonatomic,strong) WKWebView *webView;
@property (nonatomic,strong) NSString *code;

@end

@implementation DsxKlineView

-(instancetype)init
{
    if (self==[super init]) {
        [self createViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self createViews];
    }
    return self;
}

-(void)initParams{
    _chartType = DsxkKineChartType_timeSharing;
    _candleType = DsxKlineCandleType_hollow;
    _zoomLockType = DsxKlineZoomLockType_right;
    _isShowKlineTipPannel = true;
    _theme = @"white";
    _width = self.frame.size.width;
    _height = self.frame.size.height;
    _sideHeight = _height / 6;
    _main = @[@"MA"];
    _sides = @[@"VOL"];
    _klineWidth = 5;
    _page = 1;
    _datas = [NSMutableArray arrayWithArray:@[]];
}

-(void)createViews
{
    [self setBackgroundColor:[UIColor redColor]];
    [self initParams];
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    WKUserContentController *userController = [[WKUserContentController alloc] init];
    configuration.userContentController = userController;
    _webView = [[WKWebView alloc] initWithFrame:self.bounds configuration:configuration];
    [self addSubview:_webView];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"index.html" ofType:nil];
    NSString *htmlStr = [[NSString alloc]initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [_webView loadHTMLString:htmlStr baseURL:[[NSBundle mainBundle] bundleURL]];
    _webView.navigationDelegate = self;
    
    // 注册js方法
    [userController addScriptMessageHandler:self name:@"onLoading"];
    [userController addScriptMessageHandler:self name:@"scrollLeftCallBack"];
    
}

-(void)executeJs:(NSString*)js{
    [_webView evaluateJavaScript:js completionHandler:^(id _Nullable name, NSError * _Nullable error) {
//        NSLog(@"执行js：%@",name);
        if(error){
            NSLog(@"执行js出错：%@",error);
            NSLog(@"%@",js);
        }
    }];
}

-(void)createKline{
    NSString *js = @"var page = 1; \
    var c=document.getElementById(\"kline\"); \
    var kline = new dsxKline({  \
        element:c,  \
        chartType:%d,  \
        theme:\"%@\",  \
        candleType:%d,  \
        zoomLockType:%d,  \
        isShowKlineTipPannel:%@,  \
        lastClose:%f,  \
        sideHeight:%f, \
        paddingBottom:0,  \
        rightEmptyKlineAmount:1,\
        autoSize:true,  \
        debug:%@,  \
        main:%@, \
        sides:%@, \
        onLoading:function(o){  \
            window.webkit.messageHandlers.onLoading.postMessage([]); \
        },  \
        finishLoaded:function(o){  \
        },  \
        scrollLeftCallBack:function(data,index){  \
            window.webkit.messageHandlers.scrollLeftCallBack.postMessage([]); \
        },  \
        showTipCallback:function(data,index){  \
        },  \
        touchend:function(){  \
        }  \
    }); ";
    
    if (@available(iOS 11.0, *)) {
        NSString *main = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:_main options:NSJSONWritingSortedKeys error:nil] encoding:NSUTF8StringEncoding];
        NSString *sides = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:_sides options:NSJSONWritingSortedKeys error:nil] encoding:NSUTF8StringEncoding];
        
        NSString *script = [NSString stringWithFormat:js,_chartType,_theme,_candleType,_zoomLockType,_isShowKlineTipPannel?@"true":@"false",_lastClose,_sideHeight,_debug?@"true":@"false",main,sides];
        [self executeJs:script];
    } else {
        // Fallback on earlier versions
    }
    
    
}
-(void)startLoading{
    NSString *js = @"kline.chartType=%d;kline.startLoading();";
    NSString *script = [NSString stringWithFormat:js,_chartType];
    [self executeJs:script];
}
-(void)updateKline:(NSArray *)data{
    NSLog(@"第几页：%d,数据长度：%ld",_page,data.count);
    NSString *js = @"var data = %@;\
    if(data!=null){\
      if(kline!=null){\
          kline.update({\
            chartType:%d,  \
            theme:\"%@\",\
            candleType:%d,\
            zoomLockType:%d,\
            isShowKlineTipPannel:%@,\
            lastClose:%f,\
            sides:%@,\
            page:%d,\
            sideHeight:%f,\
            datas:data\
          });\
      }\
    };kline.finishLoading();";
    
    NSString *sides = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:_sides options:NSJSONWritingSortedKeys error:nil] encoding:NSUTF8StringEncoding];
    
    NSString *d = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingSortedKeys error:nil] encoding:NSUTF8StringEncoding];
    
    NSString *script = [NSString stringWithFormat:js,d,_chartType,_theme,_candleType,_zoomLockType,_isShowKlineTipPannel?@"true":@"false",_lastClose,sides,_page,_sideHeight];
    //NSLog(@"%@",script);
    [self executeJs:script];
}

-(void)scrollTheend {
    NSString *js = @"kline.scrollThenend();";
    [self executeJs:js];
}

-(void)finishLoading{
    
    NSString *js = @"kline.finishLoading();";
    [self executeJs:js];
}

// js 调用 oc
-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    //NSLog(@"js：%@",message);
    if ([message.name isEqualToString:@"onLoading"]) {
        if(_onLoading) _onLoading();
    }
    if ([message.name isEqualToString:@"scrollLeftCallBack"]) {
        if(_scrollLeftCallBack) _scrollLeftCallBack();
    }
}

//开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"didStartProvisionalNavigation");
}

//正在加载
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    NSLog(@"didCommitNavigation");
}

//加载完成
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    NSLog(@"didFinishNavigation");
    
    [self createKline];

}




@end
