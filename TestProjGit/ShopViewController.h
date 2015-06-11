#import <UIKit/UIKit.h>
#import "Turn.h"

@protocol YourTurnDelegate;

@interface ShopViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic)id<YourTurnDelegate> yourTurnDelegate;


@end

@protocol YourTurnDelegate <NSObject>

-(void)notifyYourTurn:(Turn*)turn;

@end

