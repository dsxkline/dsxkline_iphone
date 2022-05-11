//
//  HqModel.h
//  dsxkline_iphone
//
//  Created by ming feng on 2022/5/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HqModel : NSObject
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString* code;
@property (nonatomic,strong) NSString* price;
@property (nonatomic,strong) NSString* lastClose;// 昨收
@property (nonatomic,strong) NSString* open;
@property (nonatomic,strong) NSString* high;
@property (nonatomic,strong) NSString* low;
@property (nonatomic,strong) NSString* vol;
@property (nonatomic,strong) NSString* volAmount;
@property (nonatomic,strong) NSString* date;
@property (nonatomic,strong) NSString* time;
@property (nonatomic,strong) NSString* change;
@property (nonatomic,strong) NSString* changeRatio;
@end

NS_ASSUME_NONNULL_END
