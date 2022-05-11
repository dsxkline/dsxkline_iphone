//
//  DsxKlineView.h
//  dsxkline_iphone
//
//  Created by ming feng on 2022/4/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^OnLoading)(void);
typedef void (^FinishLoaded)(void);
typedef void (^ScrollLeftCallBack)(void);
typedef void (^ShowTipCallback)(void);
typedef void (^ScrollLeftCallBack)(void);

// 图表类型
typedef enum {
    DsxkKineChartType_timeSharing,    // 分时图
    DsxkKineChartType_timeSharing5,   // 五日分时图
    DsxkKineChartType_candle,         // K线图
} DsxkKineChartType;

// 蜡烛图实心空心
typedef enum {
    DsxKlineCandleType_hollow, // 空心
    DsxKlineCandleType_solid   // 实心
} DsxKlineCandleType;
// 缩放K线锁定类型
typedef enum {
    DsxKlineZoomLockType_left=1,       // 锁定左边进行缩放
    DsxKlineZoomLockType_middle=2,     // 锁定中间进行缩放
    DsxKlineZoomLockType_right=3,      // 锁定右边进行缩放
    DsxKlineZoomLockType_follow=4,     // 跟随鼠标位置进行缩放，web版效果比较好
} DsxKlineZoomLockType;


@interface DsxKlineView : UIView
// K线数据
@property (nonatomic,strong) NSMutableArray *datas;
// 主题 white dark 等
@property (nonatomic,strong) NSString *theme;
// 图表类型 1=分时图 2=k线图
@property (nonatomic,assign) DsxkKineChartType chartType;
// 蜡烛图k线样式 1=空心 2=实心
@property (nonatomic,assign) DsxKlineCandleType candleType;
// 缩放类型 1=左 2=中 3=右 4=跟随
@property (nonatomic,assign) DsxKlineZoomLockType zoomLockType;
// 每次缩放大小
@property (nonatomic,assign) double zoomStep;
// k线默认宽度
@property (nonatomic,assign) double klineWidth;
// 是否显示默认k线提示
@property (nonatomic,assign) bool isShowKlineTipPannel;
// 副图高度
@property (nonatomic,assign) double sideHeight;
// 高度
@property (nonatomic,assign) double height;
// 宽度
@property (nonatomic,assign) double width;
// 默认主图指标
@property (nonatomic,strong) NSArray *main;
// 默认副图指标 副图数组代表副图数量
@property (nonatomic,strong) NSArray *sides;
// 昨日收盘价
@property (nonatomic,assign) double lastClose;
// 首次加载回调
@property (nonatomic,copy) OnLoading onLoading;
// 完成加载回调
@property (nonatomic,copy) FinishLoaded finishLoaded;
// 滚动到左边尽头回调 通常用来加载下一页数据
@property (nonatomic,copy) ScrollLeftCallBack scrollLeftCallBack;
// 提示数据返回
@property (nonatomic,copy) ShowTipCallback showTipCallback;
// 右边空出k线数量
@property (nonatomic,assign) int rightEmptyKlineAmount;
// 当前页码
@property (nonatomic,assign) int page;
// 开启调试
@property (nonatomic,assign) bool debug;

// 请求数据之前执行
-(void)startLoading;
// 更新K线图
-(void)updateKline:(NSArray *)data;
// 滚动到尽头，没数据了
-(void)scrollTheend;
// 加载完成
-(void)finishLoading;
@end

NS_ASSUME_NONNULL_END
