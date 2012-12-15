#import "SceneManager.h"
#import "PlayBackgroundLayer.h"
#import "PlayLayer.h"

//#import "AdSageView.h"

@interface SceneManager ()

@end


@implementation SceneManager
static MobiSageAdBanner* banner;

+(void) goMainMenu{
    CCDirector *director = [CCDirector sharedDirector];
    CCScene *newScene = [CCScene node];
    
    [newScene addChild:[MainMenuLayer node] z:0];
    [newScene addChild:[ActiveBackgroundLayer node] z:-1];
    [SceneManager addAdBanner];
    if ([director runningScene]) {
        [director replaceScene:[CCTransitionCrossFade transitionWithDuration: 0.5f scene: newScene]];
	}else {
		[director runWithScene:newScene];
	}
}

+(void) goPlay:(GameType)type level:(int)level{
    CCDirector *director = [CCDirector sharedDirector];
    CCScene *newScene = [CCScene node];
    PlayDisplayLayer *display = [PlayDisplayLayer sharedInstance:YES];
    
    GameContext *context = [[[GameDef sharedInstance] settings] valueForKey:[CommonUtils getKeyStringByGameTypeAndLevel:type level:level]];
    PlayLayer *play = [PlayLayer sharedInstance:YES];
    [play resetWithContext:context];
    
    [newScene addChild:[PlayBackgroundLayer node] z:0];
    [newScene addChild:display z:2];
    [newScene addChild:play z:1];
    
    [SceneManager addAdBanner];
    
    
    if ([director runningScene]) {
        [director replaceScene:[CCTransitionPageTurn transitionWithDuration: 0.3f scene: newScene]];
	}else {
		[director runWithScene:newScene];
	}
}

+(void) addAdBanner
{
    CCDirector *director = [CCDirector sharedDirector];
    [[MobiSageManager getInstance] setPublisherID:@"ea1b5c3fa4b6434fa38b2e3d689b6169"];
    [director.view addSubview:[SceneManager getBanner]];
}

+(void) removeAdBanner
{
    [[SceneManager getBanner] removeFromSuperview];
}


+(MobiSageAdBanner*) getBanner
{
    if(banner == nil)
    {
        banner = [[MobiSageAdBanner alloc] initWithAdSize:Ad_320X50];
        [banner setInterval:Ad_Refresh_15];
        [banner setFrame:CGRectMake(0,430, 320, 50)];
    }
    return banner;
}
@end
