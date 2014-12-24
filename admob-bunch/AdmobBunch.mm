#import "AdmobBunch.h"
#import "ProcessorEngine.h"
#import "GADBannerView.h"
#import "GADAdSize.h"
#import "GADInterstitial.h"

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

@interface AdmobBunch ()
@end

@implementation AdmobBunch {
    GADBannerView *bannerView_;
    // Объявление его переменной экземпляра.
    GADInterstitial *interstitial_;
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
        NSNumber *mX = parameters[@"mX"];
        NSNumber *mY = parameters[@"mY"];
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
        [[AdmobBunch sharedInstance] createBanner:adUnitID :adSizeBanner :[mX doubleValue] :[mY doubleValue]];
    }];
    
    [self registerProcessorForKey:@"showBanner" withBlock:^(NSDictionary *parameters, NSMutableDictionary *retParameters) {
        [[AdmobBunch sharedInstance] showBanner];
    }];
    
    [self registerProcessorForKey:@"createInterstitial" withBlock:^(NSDictionary *parameters, NSMutableDictionary *retParameters) {
        NSString *adUnitID = parameters[@"adUnitID"];
        [[AdmobBunch sharedInstance] createInterstitial:adUnitID];
    }];
    
    [self registerProcessorForKey:@"showInterstitial" withBlock:^(NSDictionary *parameters, NSMutableDictionary *retParameters) {
        [[AdmobBunch sharedInstance] showInterstitial];
    }];
}

- (void)createBanner:(NSString*) adUnitID :(GADAdSize) adSizeBanner:(double)mX :(double)mY {
    
    CGPoint origin = CGPointMake(mX, mY);
    bannerView_ = [[GADBannerView alloc] initWithAdSize:adSizeBanner origin:origin];
    bannerView_.adUnitID = adUnitID;
    bannerView_.rootViewController = [[UIApplication sharedApplication] keyWindow].rootViewController;
    [[[UIApplication sharedApplication] keyWindow].rootViewController.view addSubview:bannerView_];
}

- (void)showBanner
{
    [bannerView_ loadRequest:[GADRequest request]];
}

- (void)createInterstitial:(NSString*) adUnitID {
    interstitial_ = [[GADInterstitial alloc] init];
    interstitial_.adUnitID = adUnitID;
    interstitial_.delegate = self;
}

- (void)showInterstitial
{
    NSLog(@"showInterstitial");
    [interstitial_ loadRequest:[GADRequest request]];
}

- (void)interstitial:(GADInterstitial *)interstitial didFailToReceiveAdWithError:(GADRequestError *)error {
    // Alert the error.
    NSLog(@"didFailToReceiveAdWithError");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"GADRequestError" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Drat" otherButtonTitles:nil];
    [alert show];
    
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial {
    NSLog(@"interstitialDidReceiveAd");
    [interstitial presentFromRootViewController:[[UIApplication sharedApplication] keyWindow].rootViewController];
}

@end
