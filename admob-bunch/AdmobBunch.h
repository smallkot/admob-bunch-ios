#import <Foundation/Foundation.h>
#import "GADInterstitialDelegate.h"

@interface AdmobBunch : NSObject<GADInterstitialDelegate>
+ (id)sharedInstance;
@end