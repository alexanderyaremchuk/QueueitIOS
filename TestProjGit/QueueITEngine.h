#import <Foundation/Foundation.h>
#import "Turn.h"

@protocol QueuePassedDelegate;

@interface QueueITEngine : NSObject
@property (nonatomic)id<QueuePassedDelegate> queuePassedDelegate;
-(instancetype)initWithHost:(UIViewController *)host;
@end

@protocol QueuePassedDelegate <NSObject>

-(void)notifyYourTurn:(Turn*)turn;

@end






