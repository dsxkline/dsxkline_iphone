//
//  ViewController.m
//  dsxkline_iphone
//
//  Created by ming feng on 2022/4/20.
//

#import "ViewController.h"
#import "DsxKlineView.h"
#import "QQhq.h"

@interface ViewController ()
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) DsxKlineView *dsxKlineView;
@property (nonatomic,strong) NSMutableArray *datas;
@property (nonatomic,strong) NSString *code;
@property (nonatomic,assign) int cycle;

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self) __weakSelf = self;
    _code = @"sh000001";
    _datas = [NSMutableArray new];
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.alwaysBounceVertical = true;
    _scrollView.delaysContentTouches = true;
    [self.view addSubview:_scrollView];
    [self createTabbar];
    double height = 3*50 + 5*50;
    _dsxKlineView = [[DsxKlineView alloc] initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, height)];
    _dsxKlineView.sides = @[@"VOL",@"MACD",@"RSI"];
    _dsxKlineView.sideHeight = 50;
    _dsxKlineView.height = height;
//    _dsxKlineView.debug = TRUE;
    [_scrollView addSubview:_dsxKlineView];
    // 初始化加载数据
    _dsxKlineView.onLoading = ^{
        __weakSelf.dsxKlineView.page = 1;
        [__weakSelf.datas removeAllObjects];
        //NSLog(@"onloading");
        [__weakSelf getStockDatas];
    };
    
    _dsxKlineView.scrollLeftCallBack = ^{
        [__weakSelf getStockDatas];
    };
    
}

-(void)getStockDatas{
    if(self.dsxKlineView.chartType == DsxkKineChartType_candle)[self getDay:self.code];
    if(self.dsxKlineView.chartType <= DsxkKineChartType_timeSharing5)[self getQuotes:self.code];
}

-(void)createTabbar{
    double w = self.view.frame.size.width / 6;
    [_scrollView addSubview:[self button:@"分时" tag:0 x:0]];
    [_scrollView addSubview:[self button:@"五日" tag:1 x:w]];
    [_scrollView addSubview:[self button:@"日K" tag:2 x:2*w]];
    [_scrollView addSubview:[self button:@"周K" tag:3 x:3*w]];
    [_scrollView addSubview:[self button:@"月K" tag:4 x:4*w]];
    [_scrollView addSubview:[self button:@"分钟" tag:5 x:5*w]];
}

-(UIButton*)button:(NSString*)title tag:(int)tag x:(double)x{
    double w = self.view.frame.size.width / 6;
    double h = 44;
    UIButton *bt = [[UIButton alloc] initWithFrame:CGRectMake(x, 0, w, h)];
    [bt setTitle:title forState:UIControlStateNormal];
    [bt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    bt.backgroundColor = [UIColor grayColor];
    bt.tag = tag;
    [bt addTarget:self action:@selector(clickTabbar:) forControlEvents:UIControlEventTouchUpInside];
    return bt;
}

-(void)clickTabbar:(UIButton *)bt{
    int tag = (int)bt.tag;
    _cycle = tag;
    _dsxKlineView.chartType = tag<=2?tag:2;
    if (tag>=2) {
        // 蜡烛图指标
        _dsxKlineView.sides = @[@"VOL",@"KDJ",@"MACD",@"RSI",@"WR",@"CCI",@"BIAS",@"PSY"];
    }else{
        // 分时图指标
        _dsxKlineView.sides = @[@"VOL",@"MACD",@"RSI"];
    }
    double height = _dsxKlineView.sides.count*_dsxKlineView.sideHeight + 5*_dsxKlineView.sideHeight;
    [_dsxKlineView setFrame:CGRectMake(0, 44, self.view.frame.size.width, height)];
    _dsxKlineView.height = height;
    [_dsxKlineView startLoading];
    NSLog(@"%d",tag);
    
}

-(void)getTimeline:(NSString*)code{
    __weak typeof(self) __weakSelf = self;
    [QQhq getTimeLineWithCode:code success:^(NSMutableArray* data){
        [__weakSelf.dsxKlineView updateKline:data];
    } fail:^(NSError * _Nullable error) {
        
    }];
}
-(void)getTimeline5:(NSString*)code{
    __weak typeof(self) __weakSelf = self;
    [QQhq getFdayLineWithCode:code success:^(NSMutableDictionary* data){
        // 取第一个数据为昨日收盘价
        NSArray *d = data[@"data"];
        double lastClose = [data[@"lastClose"] doubleValue];
        __weakSelf.dsxKlineView.lastClose = lastClose;
        __weakSelf.datas = [NSMutableArray arrayWithArray:d];
        [__weakSelf.datas removeObjectAtIndex:0];
        [__weakSelf.dsxKlineView updateKline:__weakSelf.datas];
    } fail:^(NSError * _Nullable error) {
        
    }];
}

-(void)getDay:(NSString*)code{
    NSString *cycle = @"day";
    if(_cycle==2) cycle = @"day";
    if(_cycle==3) cycle = @"week";
    if(_cycle==4) cycle = @"month";
    if(_cycle==5) cycle = @"m1";
    __weak typeof(self) __weakSelf = self;
    // 分钟
    if(_cycle==5){
        
        [QQhq getMinLine:code cycle:cycle pageSize:320 fqType:@"qfq" success:^(NSMutableArray * _Nonnull data) {
            NSArray *d = data;
            if(d.count>0){
                if(__weakSelf.dsxKlineView.page==1){
                    [__weakSelf.datas removeAllObjects];
                }
                __weakSelf.datas = [NSMutableArray arrayWithArray:[d arrayByAddingObjectsFromArray:__weakSelf.datas]];
                [__weakSelf.dsxKlineView updateKline:__weakSelf.datas];
                __weakSelf.dsxKlineView.page ++;
            }else{
                // 到尽头了
                [__weakSelf.dsxKlineView scrollTheend];
            }
            
            [__weakSelf.dsxKlineView finishLoading];
        } fail:^(NSError * _Nullable error) {
            [__weakSelf.dsxKlineView finishLoading];
        }];
        return;
    }
   
   
    [QQhq getKLine:code cycle:cycle startDate:@"" endDate:@"" pageSize:320 fqType:@"qfq" success:^(NSMutableArray* data){
        NSArray *d = data;
        if(d.count>0){
            if(__weakSelf.dsxKlineView.page==1){
                [__weakSelf.datas removeAllObjects];
            }
            __weakSelf.datas = [NSMutableArray arrayWithArray:[d arrayByAddingObjectsFromArray:__weakSelf.datas]];
            [__weakSelf.dsxKlineView updateKline:__weakSelf.datas];
            __weakSelf.dsxKlineView.page ++;
        }else{
            // 到尽头了
            [__weakSelf.dsxKlineView scrollTheend];
        }
        
        [__weakSelf.dsxKlineView finishLoading];
    } fail:^(NSError * _Nullable error) {
        [__weakSelf.dsxKlineView finishLoading];
    }];
}


-(void)getQuotes:(NSString*)code{
   
    __weak typeof(self) __weakSelf = self;
    [QQhq getQuoteWithCode:code success:^(NSMutableArray* data){
        if(data==nil) return;
        HqModel *d = data[0];
        if(!d) return;
        //console.log(d);
        __weakSelf.dsxKlineView.lastClose = [d.lastClose floatValue];
        if(__weakSelf.cycle==0)[__weakSelf getTimeline:code];
        if(__weakSelf.cycle==1)[__weakSelf getTimeline5:code];
        [__weakSelf.dsxKlineView finishLoading];
    } fail:^(NSError * _Nullable error) {
        [__weakSelf.dsxKlineView finishLoading];
    }];
}


@end
