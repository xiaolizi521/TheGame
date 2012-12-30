//
//  RewardLayer.m
//  TheGame
//
//  Created by kcy1860 on 12/24/12.
//
//

#import "RewardLayer.h"
#import "SceneManager.h"
@implementation RewardLayer

+(id) node:(int) num{
    return [[[RewardLayer alloc] init:num] autorelease];
}

-(id) init:(int) num{
    self = [super init];
    CGSize winSize = [CCDirector sharedDirector].winSize;
    UserProfile *pro =[UserProfile sharedInstance];

    int heal=0;
    int rotate=0;
    int hint=0;
    
    CCSprite *back;
    CCLabelTTF *l1=[CCLabelTTF labelWithString:@"0" fontName:@"Arial-BoldMT" fontSize:20];
    CCLabelTTF *l2=[CCLabelTTF labelWithString:@"0" fontName:@"Arial-BoldMT" fontSize:20];
    CCLabelTTF *l3=[CCLabelTTF labelWithString:@"0" fontName:@"Arial-BoldMT" fontSize:20];
    
    if (num==1) { // level的情况
        PlayDisplayLayer* display= [PlayDisplayLayer sharedInstance:NO];
        GameContext *context = [[PlayLayer sharedInstance:NO] context];
        back = [CCSprite spriteWithFile:@"scoreboard_bg.png"];
        
        int score = [display score];
        [[pro userRecord] setValue:[NSNumber numberWithInt:score] forKey:[CommonUtils getKeyStringByGameTypeAndLevel:Classic level:context.level]];
        CCSprite *star1 = [CCSprite spriteWithFile:@"star1.png"];
        CCSprite *star2 = [CCSprite spriteWithFile:@"star2.png"];
        CCSprite *star3 = [CCSprite spriteWithFile:@"star3.png"];
        star1.position = ccp(winSize.width*0.38,winSize.height*0.8);
        star2.position = ccp(winSize.width*0.505,winSize.height*0.822);
        star3.position = ccp(winSize.width*0.622,winSize.height*0.805);

        CCLabelTTF *sc=[CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",score] fontName:@"Arial-BoldMT" fontSize:22];
        sc.color = ccc3(200, 200, 0);
        sc.position=ccp(winSize.width*0.55,winSize.height*0.74);
        int star = display.star;
        
        CCSprite* hw = [CCSprite spriteWithFile:@"remaid_wd.png"];
        CCSprite* rw = [CCSprite spriteWithFile:@"rotate_wd.png"];
        if(star==3)
        {
            // 三颗星给一个提示两个轮换
            hint=2;
            rotate=1;

            hw.position = ccp(winSize.width*0.5,winSize.height*0.53);
            rw.position = ccp(winSize.width*0.5,winSize.height*0.6);
            CCLabelTTF *hl=[CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",hint] fontName:@"Arial-BoldMT" fontSize:18];
            hl.color = ccc3(200, 200, 200);
            hl.position = ccp(winSize.width*0.57,winSize.height*0.53);
            CCLabelTTF *rl=[CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",rotate] fontName:@"Arial-BoldMT" fontSize:18];
            rl.color = ccc3(200, 200, 200);
            rl.position = ccp(winSize.width*0.57,winSize.height*0.6);
            [self addChild:hw z:1];
            [self addChild:rw z:1];
            [self addChild:hl z:1];
            [self addChild:rl z:1];
        }else if(star ==2)
        {
            // 两颗星给两个提示
            star3.visible=NO;
            hint=2;
            
            hw.position = ccp(winSize.width*0.5,winSize.height*0.56);
            CCLabelTTF *hl=[CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",hint] fontName:@"Arial-BoldMT" fontSize:18];
            hl.color = ccc3(200, 200, 200);
            hl.position = ccp(winSize.width*0.57,winSize.height*0.56);
            [self addChild:hw z:1];
            [self addChild:hl z:1];
        }else if(star ==1 )
        {
            // 一颗星给一个提示
            star3.visible=NO;
            star2.visible=NO;
            hint=1;
            
            hw.position = ccp(winSize.width*0.5,winSize.height*0.56);
            CCLabelTTF *hl=[CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",hint] fontName:@"Arial-BoldMT" fontSize:16];
            hl.color = ccc3(200, 200, 200);
            hl.position = ccp(winSize.width*0.57,winSize.height*0.56);
            [self addChild:hw z:1];
            [self addChild:hl z:1];
        }else{
            star3.visible=NO;
            star2.visible=NO;
            star1.visible=NO;
            // hint=1;

            CCLabelTTF *hl=[CCLabelTTF labelWithString: @"真遗憾，这次没有获得奖励，要再接再厉哦!" fontName:@"Arial-BoldMT" fontSize:18];
            [hl setDimensions:CGSizeMake(winSize.width*0.4, winSize.height*0.2)];
            hl.color = ccc3(200, 200, 0);
            hl.position = ccp(winSize.width*0.5,winSize.height*0.52);
            [self addChild:hl z:1];
            
        }
        
        CCSprite* ct = [CCSprite spriteWithFile:@"goon_bt.png"];
        ct.position = ccp(winSize.width*0.5,winSize.height*0.41);
        
        CCSprite* mt = [CCSprite spriteWithFile:@"menu_bt.png"];
        mt.position = ccp(winSize.width*0.35,winSize.height*0.41);
        
        CCSprite* lt = [CCSprite spriteWithFile:@"likeus_bt.png"];
        lt.position = ccp(winSize.width*0.65,winSize.height*0.41);
        
        [self addChild:ct z:1 tag:continueTag];
        [self addChild:mt z:1 tag:backtomenuTag];
        [self addChild:lt z:1 tag:likeusTag];
        
        if(!isRetina)
        {
            back.scale=0.5f;
            star1.scale=0.5f;
            star2.scale=0.5f;
            star3.scale=0.5f;
            hw.scale=0.5f;
            rw.scale=0.5f;
            ct.scale=0.5f;
            mt.scale=0.5f;
            lt.scale=0.5f;
        }
        [self addChild:star1 z:1];
        [self addChild:star2 z:1];
        [self addChild:star3 z:1];
        [self addChild:sc z:1];
        
    }
    else if(num==2) //无尽的情况
    {
        PlayDisplayLayer* display= [PlayDisplayLayer sharedInstance:NO];
        GameContext *context = [[PlayLayer sharedInstance:NO] context];
        
        back = [CCSprite spriteWithFile:@"endlessreward_bg.png"];
        int score = [display score];
        int record = [[[pro userRecord] valueForKey:[CommonUtils getKeyStringByGameTypeAndLevel:context.type level:1]] integerValue];
        if(score>record)
        {
            CCSprite *stamp = [CCSprite spriteWithFile:@"stamp.png"];
            if(!isRetina)
            {
                stamp.scale=0.5f;
            }
            stamp.position=ccp(winSize.width*0.57,winSize.height*0.72);
            [self addChild:stamp z:1];
            [[pro userRecord] setValue:[NSNumber numberWithInt:score] forKey:[CommonUtils getKeyStringByGameTypeAndLevel:context.type level:1]];
        }
        
        CCLabelTTF *sc=[CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",score] fontName:@"Arial-BoldMT" fontSize:22];
        sc.color = ccc3(200, 200, 0);
        sc.position=ccp(winSize.width*0.55,winSize.height*0.74);
        CCSprite* ct = [CCSprite spriteWithFile:@"redo_bt.png"];
        ct.position = ccp(winSize.width*0.5,winSize.height*0.41);
        
        CCSprite* mt = [CCSprite spriteWithFile:@"menu_bt.png"];
        mt.position = ccp(winSize.width*0.35,winSize.height*0.41);
        
        CCSprite* lt = [CCSprite spriteWithFile:@"likeus_bt.png"];
        lt.position = ccp(winSize.width*0.65,winSize.height*0.41);
        
        [self addChild:ct z:1 tag:redoTag];
        [self addChild:mt z:1 tag:backtomenuTag];
        [self addChild:lt z:1 tag:likeusTag];
        
        CCSprite* hw = [CCSprite spriteWithFile:@"remaid_wd.png"];
        CCSprite* rw = [CCSprite spriteWithFile:@"rotate_wd.png"];
        CCSprite* lw = [CCSprite spriteWithFile:@"rebirth_wd.png"];
        
        
        hint = score/2000;
        rotate = score/3000;
        heal = score/4000;
        
        if(heal>0) // 三种奖励都拿到了
        {
            lw.position = ccp(winSize.width*0.5,winSize.height*0.50);
            hw.position = ccp(winSize.width*0.5,winSize.height*0.57);
            rw.position = ccp(winSize.width*0.5,winSize.height*0.64);
            
            CCLabelTTF *ll=[CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",heal] fontName:@"Arial-BoldMT" fontSize:18];
            ll.color = ccc3(200, 200, 200);
            ll.position = ccp(winSize.width*0.57,winSize.height*0.50);
            CCLabelTTF *hl=[CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",hint] fontName:@"Arial-BoldMT" fontSize:18];
            hl.color = ccc3(200, 200, 200);
            hl.position = ccp(winSize.width*0.57,winSize.height*0.57);
            CCLabelTTF *rl=[CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",rotate] fontName:@"Arial-BoldMT" fontSize:18];
            rl.color = ccc3(200, 200, 200);
            rl.position = ccp(winSize.width*0.57,winSize.height*0.64);
            [self addChild:hw z:1];
            [self addChild:rw z:1];
            [self addChild:lw z:1];
            [self addChild:ll z:1];
            [self addChild:hl z:1];
            [self addChild:rl z:1];
        }else if(rotate>0){ //拿到了两种奖励
            hw.position = ccp(winSize.width*0.5,winSize.height*0.53);
            rw.position = ccp(winSize.width*0.5,winSize.height*0.6);
            CCLabelTTF *hl=[CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",hint] fontName:@"Arial-BoldMT" fontSize:18];
            hl.color = ccc3(200, 200, 200);
            hl.position = ccp(winSize.width*0.57,winSize.height*0.53);
            CCLabelTTF *rl=[CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",rotate] fontName:@"Arial-BoldMT" fontSize:18];
            rl.color = ccc3(200, 200, 200);
            rl.position = ccp(winSize.width*0.57,winSize.height*0.6);
            [self addChild:hw z:1];
            [self addChild:rw z:1];
            [self addChild:hl z:1];
            [self addChild:rl z:1];
        }else if(hint>0) // 只拿到了一种奖励
        {
            hw.position = ccp(winSize.width*0.5,winSize.height*0.56);
            CCLabelTTF *hl=[CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",hint] fontName:@"Arial-BoldMT" fontSize:16];
            hl.color = ccc3(200, 200, 200);
            hl.position = ccp(winSize.width*0.57,winSize.height*0.56);
            [self addChild:hw z:1];
            [self addChild:hl z:1];
        }else{ // 没有拿到奖励
            CCLabelTTF *hl=[CCLabelTTF labelWithString:  @"真遗憾，这次没有获得奖励，要再接再厉哦!" fontName:@"Arial-BoldMT" fontSize:18];
            [hl setDimensions:CGSizeMake(winSize.width*0.4, winSize.height*0.2)];
            hl.color = ccc3(200, 200, 0);
            hl.position = ccp(winSize.width*0.5,winSize.height*0.52);
            [self addChild:hl z:1];
        }
        
        if(!isRetina)
        {
            back.scale=0.5f;

            hw.scale=0.5f;
            rw.scale=0.5f;
            ct.scale=0.5f;
            mt.scale=0.5f;
            lt.scale=0.5f;
            lw.scale=0.5f;
        }
        [self addChild:sc z:1];
    }
    else //连续登陆奖励的情况
    {
        back = [CCSprite spriteWithFile:@"continue_bg.png"];
        int count = [pro count];
        if(count>=5)
        {
            hint=1;
            rotate=1;
            heal=1;
        }else if(count>=3){
            hint=1;
            rotate=1;
        }else if(count>=2){
            hint=1;
        }
        [l1 setString:[NSString stringWithFormat:@"%d",heal]];
        [l2 setString:[NSString stringWithFormat:@"%d",rotate]];
        [l3 setString:[NSString stringWithFormat:@"%d",hint]];
        
        CCLabelTTF *c = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",count] fontName:@"Arial-BoldMT" fontSize:22];
        c.color = ccc3(200, 200, 0);
        c.position=ccp(winSize.width*0.575,winSize.height*0.75);
        [self addChild:c z:1];
        
        CCSprite *sprite = [CCSprite spriteWithFile:@"gift_bt.png"];
        sprite.position = ccp(winSize.width*0.5,winSize.height*0.41);
        [self addChild:sprite z:1 tag:giftTag];
        if(!isRetina)
        {
            sprite.scale=0.5f;
            back.scale=0.5f;
        }
        l1.position = ccp(winSize.width*0.58,winSize.height*0.69);
        l2.position = ccp(winSize.width*0.58,winSize.height*0.625);
        l3.position = ccp(winSize.width*0.58,winSize.height*0.56);
        
        [self addChild:l1 z:1];
        [self addChild:l2 z:1];
        [self addChild:l3 z:1];
    }
    
    back.position = ccp(winSize.width*0.5,winSize.height*0.6);
    
    [self addChild:back];
    
    
    [pro addHint:hint];
    [pro addLife:heal];
    [pro addRefill:rotate];
    
    
    self.isTouchEnabled=YES;
    return self;
}

-(void) onEnterTransitionDidFinish{
    //[self scheduleOnce:@selector(doTransmit) delay:1];
}

-(void) doTransmit{
    [SceneManager goGameModeChoose];
}

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	UITouch* touch = [touches anyObject];
	CGPoint location = [touch locationInView: touch.view];
	location = [[CCDirector sharedDirector] convertToGL: location];
    
    CCNode* sprite = [self getChildByTag:giftTag];
    if(sprite!=nil && CGRectContainsPoint([sprite boundingBox], location)){
        MainMenuLayer* l = (MainMenuLayer*)[[[CCDirector sharedDirector] runningScene] getChildByTag:menuLayerTag];
        [l enableMenu:YES];
        [SceneManager removeRewardLayer];
    }
    
    sprite = [self getChildByTag:continueTag];
    if(sprite!=nil && CGRectContainsPoint([sprite boundingBox], location)){
        int level = [[[PlayLayer sharedInstance:NO] context] level];
        if(level==9)
        {
            [SceneManager goLevelChoose];
        }else{
            [SceneManager goPlay:Classic level:level+1];
        }
    }
    
    sprite = [self getChildByTag:redoTag];
    if(sprite!=nil && CGRectContainsPoint([sprite boundingBox], location)){
        GameType type= [[[PlayLayer sharedInstance:NO] context] type];
        [SceneManager goPlay:type level:1];
    }
    
    sprite = [self getChildByTag:backtomenuTag];
    if(sprite!=nil && CGRectContainsPoint([sprite boundingBox], location)){
        [SceneManager goMainMenu];
    }
    
    sprite = [self getChildByTag:likeusTag];
    if(sprite!=nil && CGRectContainsPoint([sprite boundingBox], location)){
        [SceneManager goMainMenu];
    }
}

@end
