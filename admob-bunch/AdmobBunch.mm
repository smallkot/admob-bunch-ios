#import "AdmobBunch.h"
#import "ProcessorEngine.h"
#import "GADBannerView.h"
#import "GADAdSize.h"
#import "GADInterstitial.h"
#include <vector>

enum{
    aGADAdSizeBanner,
    
    /// Taller version of kGADAdSizeBanner. Typically 320x100.
    aGADAdSizeLargeBanner,
    
    /// Medium Rectangle size for the iPad (especially in a UISplitView's left pane). Typically 300x250.
    aGADAdSizeMediumRectangle,
    
    /// Full Banner size for the iPad (especially in a UIPopoverController or in
    /// UIModalPresentationFormSheet). Typically 468x60.
    aGADAdSizeFullBanner,
    
    /// Leaderboard size for the iPad. Typically 728x90.
    aGADAdSizeLeaderboard,
    
    /// Skyscraper size for the iPad. Mediation only. AdMob/Google does not offer this size. Typically
    /// 120x600.
    aGADAdSizeSkyscraper,
    
    /// An ad size that spans the full width of the application in portrait orientation. The height is
    /// typically 50 pixels on an iPhone/iPod UI, and 90 pixels tall on an iPad UI.
    aGADAdSizeSmartBannerPortrait,
    
    /// An ad size that spans the full width of the application in landscape orientation. The height is
    /// typically 32 pixels on an iPhone/iPod UI, and 90 pixels tall on an iPad UI.
    aGADAdSizeSmartBannerLandscape
};

enum
{
    kBannerGravityNone = -1,
    kBannerGravityTopLeft = 0,
    kBannerGravityCenterLeft,
    kBannerGravityBottomLeft,
    kBannerGravityTopCenter,
    kBannerGravityCenter,
    kBannerGravityBottomCenter,
    kBannerGravityTopRight,
    kBannerGravityCenterRight,
    kBannerGravityBottomRight
};

@interface AdmobBunch ()
@end

@implementation AdmobBunch {
    GADBannerView *bannerView_;
    // Объявление его переменной экземпляра.
    std::vector<GADInterstitial*> interstitial_;
}

+ (id)sharedInstance {
    static AdmobBunch *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self alloc];
    });
    return sharedInstance;
}

+ (void)initialize {
    [super initialize];
    [self initGlue];
}

+ (void)registerProcessorForKey:(NSString *)key withBlock:(void (^)(NSDictionary *parameters, NSMutableDictionary *retParameters))callHandler {
    [[ProcessorEngine sharedInstance] registerProcessorForBunch:@"AdmobBunch" andKey:key withBlock:callHandler];
}

+ (void)initGlue {

    [self registerProcessorForKey:@"createBanner" withBlock:^(NSDictionary *parameters, NSMutableDictionary *retParameters) {
        NSString *adUnitID = parameters[@"adUnitID"];
        NSNumber *sizeBanner = parameters[@"adSizeBanner"];
        GADAdSize adSizeBanner = kGADAdSizeBanner;
        if ([sizeBanner intValue] == aGADAdSizeBanner) {
            adSizeBanner = kGADAdSizeBanner;
        }
        else if ([sizeBanner intValue] == aGADAdSizeLargeBanner) {
            adSizeBanner = kGADAdSizeLargeBanner;
        }
        else if ([sizeBanner intValue] == aGADAdSizeMediumRectangle) {
            adSizeBanner = kGADAdSizeMediumRectangle;
        }
        else if ([sizeBanner intValue] == aGADAdSizeFullBanner) {
            adSizeBanner = kGADAdSizeFullBanner;
        }
        else if ([sizeBanner intValue] == aGADAdSizeLeaderboard) {
            adSizeBanner = kGADAdSizeLeaderboard;
        }
        else if ([sizeBanner intValue] == aGADAdSizeSkyscraper) {
            adSizeBanner = kGADAdSizeSkyscraper;
        }
        else if ([sizeBanner intValue] == aGADAdSizeSmartBannerPortrait) {
            adSizeBanner = kGADAdSizeSmartBannerPortrait;
        }
        else if ([sizeBanner intValue] == aGADAdSizeSmartBannerLandscape) {
            adSizeBanner = kGADAdSizeSmartBannerLandscape;
        }
        [[AdmobBunch sharedInstance] createBanner:adUnitID :adSizeBanner];
    }];
    
    [self registerProcessorForKey:@"showBanner" withBlock:^(NSDictionary *parameters, NSMutableDictionary *retParameters) {
        NSNumber *mX = parameters[@"mX"];
        NSNumber *mY = parameters[@"mY"];
        NSNumber *mWidth = parameters[@"mWidth"];
        NSNumber *mHeight = parameters[@"mHeight"];
        NSNumber *mGravity = parameters[@"mGravity"];
        [[AdmobBunch sharedInstance] showBanner:[mX doubleValue] :[mY doubleValue] : [mWidth doubleValue] : [mHeight doubleValue] : [mGravity intValue]];
    }];
    
    [self registerProcessorForKey:@"hideBanner" withBlock:^(NSDictionary *parameters, NSMutableDictionary *retParameters) {
        [[AdmobBunch sharedInstance] hideBanner];
    }];
    
    [self registerProcessorForKey:@"createInterstitial" withBlock:^(NSDictionary *parameters, NSMutableDictionary *retParameters) {
        NSString *adUnitID = parameters[@"adUnitID"];
        [[AdmobBunch sharedInstance] createInterstitial:adUnitID];
    }];
    
    [self registerProcessorForKey:@"showInterstitial" withBlock:^(NSDictionary *parameters, NSMutableDictionary *retParameters) {
        [[AdmobBunch sharedInstance] showInterstitial];
    }];
}

- (void)createBanner:(NSString*) adUnitID :(GADAdSize) adSizeBanner{
    
    CGPoint origin = CGPointMake(0, 0);
    bannerView_ = [[GADBannerView alloc] initWithAdSize:adSizeBanner origin:origin];
    bannerView_.adUnitID = adUnitID;
    bannerView_.rootViewController = [[UIApplication sharedApplication] keyWindow].rootViewController;
    [bannerView_ loadRequest:[GADRequest request]];
    bannerView_.hidden = true;
    //[[[UIApplication sharedApplication] keyWindow].rootViewController.view addSubview:bannerView_];
}

- (void)hideBanner
{
    [bannerView_ removeFromSuperview];
    bannerView_.hidden = true;
}

//============================================================================

-(void) showBanner:(int) x: (int) y: (int) width: (int) height: (int) gravity
{
    if (!bannerView_.hidden) {
        return;
    }
    NSLog(@"====== showBanner ==========");
    bannerView_.hidden = false;
    CGRect rect = CGRectMake(x, y, width, height);
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES) {
        float scale = [[UIScreen mainScreen] scale];
        rect.origin.x /= scale;
        rect.origin.y /= scale;
        rect.size.width /= scale;
        rect.size.height /= scale;
        NSLog(@"====== scale ====== %f", scale);
    }
    
    if(gravity==kBannerGravityNone)
    {
        bannerView_.layer.anchorPoint = CGPointMake(0, 0);
        CGRect bounds = [UIApplication sharedApplication].keyWindow.rootViewController.view.bounds;
        rect.origin.y = rect.origin.y;//bounds.size.height - rect.size.height - rect.origin.y;
        NSLog(@"======= rect.origin.y = %f", rect.origin.y);
        bannerView_.center = rect.origin;
    }
    
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:bannerView_];
    
    //CGRect bounds = [UIApplication sharedApplication].keyWindow.rootViewController.view.bounds;
    
    //float xScale = 1.0f;
    //float yScale = 1.0f;
    /*
    switch (scaleType) {
        case BannerScaleType::Fill:
            xScale = bounds.size.width / bannerView_.bounds.size.width;
            yScale = bounds.size.height / bannerView_.bounds.size.height;
            break;
            
        case BannerScaleType::Proportional:
            xScale = bounds.size.width / bannerView_.bounds.size.width;
            yScale = bounds.size.height / bannerView_.bounds.size.height;
            xScale = std::min(xScale, yScale);
            yScale = xScale;
            break;
            
        default:
            break;
    }
     */
    
    //bannerView_.transform = CGAffineTransformScale(CGAffineTransformIdentity, xScale, yScale);
    
    switch (gravity) {
        case kBannerGravityTopLeft:
            NSLog(@"kBannerGravityTopLeft");
            bannerView_.layer.anchorPoint = CGPointMake(0, 0);
            bannerView_.center = CGPointMake(rect.origin.x, rect.origin.y);
            break;
        case kBannerGravityCenterLeft:
            NSLog(@"kBannerGravityCenterLeft");
            bannerView_.layer.anchorPoint = CGPointMake(0, 0.5);
            bannerView_.center = CGPointMake(rect.origin.x, (rect.origin.y + rect.size.height)/2);
            break;
        case kBannerGravityBottomLeft:
            NSLog(@"kBannerGravityBottomLeft");
            bannerView_.layer.anchorPoint = CGPointMake(0, 1.0);
            bannerView_.center = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height);
            break;
        case kBannerGravityTopCenter:
            NSLog(@"kBannerGravityTopCenter");
            bannerView_.layer.anchorPoint = CGPointMake(0.5, 0);
            bannerView_.center = CGPointMake((rect.origin.x + rect.size.width)/2, rect.origin.y);
            break;
        case kBannerGravityCenter:
            NSLog(@"kBannerGravityCenter");
            bannerView_.layer.anchorPoint = CGPointMake(0.5, 0.5);
            bannerView_.center = CGPointMake((rect.origin.x + rect.size.width)/2, (rect.origin.y + rect.size.height)/2);
            break;
        case kBannerGravityBottomCenter:
            NSLog(@"kBannerGravityBottomCenter");
            bannerView_.layer.anchorPoint = CGPointMake(0.5, 1.0);
            bannerView_.center = CGPointMake((rect.origin.x + rect.size.width)/2, rect.origin.y + rect.size.height);
            break;
        case kBannerGravityTopRight:
            NSLog(@"kBannerGravityTopRight");
            bannerView_.layer.anchorPoint = CGPointMake(1.0, 0);
            bannerView_.center = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y );
            break;
        case kBannerGravityCenterRight:
            NSLog(@"kBannerGravityCenterRight");
            bannerView_.layer.anchorPoint = CGPointMake(1.0, 0.5);
            bannerView_.center = CGPointMake(rect.origin.x + rect.size.width, (rect.origin.y + rect.size.height)/2);;
            break;
        case kBannerGravityBottomRight:
            NSLog(@"kBannerGravityBottomRight");
            bannerView_.layer.anchorPoint = CGPointMake(1.0, 1.0);
            bannerView_.center = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);;
            break;
            
        default:
            break;
    }
    NSLog(@"== %f, %f, %f, %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}

//============================================================================

- (void)createInterstitial:(NSString*) adUnitID {
    interstitial_.push_back([[GADInterstitial alloc] init]);
    interstitial_.back().adUnitID = adUnitID;
    interstitial_.back().delegate = self;
}

- (void)showInterstitial
{
    
    if (interstitial_.size()>0)
    {
        NSLog(@"showInterstitial");
        [interstitial_.at(0) loadRequest:[GADRequest request]];
        //
    }
}

- (void)interstitial:(GADInterstitial *)interstitial didFailToReceiveAdWithError:(GADRequestError *)error {
    // Alert the error.
    NSLog(@"didFailToReceiveAdWithError");
    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"GADRequestError" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Drat" otherButtonTitles:nil];
    //[alert show];
    
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial {
    NSLog(@"interstitialDidReceiveAd");
    [interstitial presentFromRootViewController:[[UIApplication sharedApplication] keyWindow].rootViewController];
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)interstitial
{
    interstitial_.erase(interstitial_.begin());
}

@end
