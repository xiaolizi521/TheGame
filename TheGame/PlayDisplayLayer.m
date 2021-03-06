//
//  PlayDisplayLayer.m
//  TheGame
//
//  Created by kcy1860 on 12/11/12.
//
//

#import "PlayDisplayLayer.h"
#import "Germ.h"
#import "GameDef.h"
#import "CommonUtils.h"
@interface PlayDisplayLayer(){
    
    CCLabelTTF* scoreLabel;
    CCLabelTTF* passScoreLabel;
    
    CCSprite* pause;
    
    CCSprite *title;
    
    CCSprite *clockLine;
    CCProgressTimer* timer;
    
    
    /*UserTools*/
    GermFigure* hint;
    GermFigure* heal;
    GermFigure* reload;
    
    
    CCSprite *clock;
    NSMutableArray *starPictures;
    
    int timeRemain;
    GameType type;
    int life;
    
    
    CCSpriteBatchNode *explodeSheet;
    int starSpan;
    
    BOOL tools_enable;
}

@end
@implementation PlayDisplayLayer

@synthesize score,levelScore,time,star,life;

static PlayDisplayLayer* thisLayer;

+(PlayDisplayLayer*) sharedInstance:(BOOL) refresh
{
    if(thisLayer!=nil&&refresh)
    {
        //[thisLayer release];
        thisLayer =nil;
    }
    if(thisLayer==nil)
    {
        thisLayer = [PlayDisplayLayer node];
    }
    
    return thisLayer;
}


-(id)init{
    self = [super init];
    if(self)
    {
        star = 0;
        life = 3;
        score=0;
        self.isTouchEnabled = YES;
        CGSize winSize = [CCDirector sharedDirector].winSize;
        UserProfile *profile = [UserProfile sharedInstance];
        
        pause = [CCSprite spriteWithFile:@"stop_bt.png"];
        pause.position = ccp(winSize.width*0.91,winSize.height*0.93);
        
        
        //设置道具
        hint = [GermFigure spriteWithFile:@"t_hint.png"];
        hint.position = ccp(winSize.width*0.2,winSize.height*0.17);
        [hint setShiftValue:1];
        [hint setLabelValue:[profile tools_hint]];
        
        heal = [GermFigure spriteWithFile:@"t_reset.png"];
        heal.position = ccp(winSize.width*0.5,winSize.height*0.17);
        [heal setShiftValue:1];
        [heal setLabelValue:[profile tools_life]];
        
        reload =[GermFigure spriteWithFile:@"t_rotate.png"];
        reload.position = ccp(winSize.width*0.8,winSize.height*0.17);
        [reload setShiftValue:1];
        [reload setLabelValue:[profile tools_refill]];
        

        tools_enable = true;
        if(!isRetina)
        {
            hint.scale=0.5f;
            heal.scale=0.5f;
            reload.scale=0.5f;
            pause.scale=0.5f;
        }
        starPictures=[[NSMutableArray alloc] initWithCapacity:3];        
        
        [self addChild:hint];
        [self addChild:heal];
        [self addChild:reload];
        [self addChild:[hint label]];
        [self addChild:[heal label]];
        [self addChild:[reload label]];
        
        explodeSheet = [CCSpriteBatchNode batchNodeWithFile:@"fire.png"];
        [self addChild:explodeSheet];

    }
    return self;
}

-(void) showExplosion:(CGPoint) pos{

    NSMutableArray *frames = [NSMutableArray array];
    for(int i = 1; i <= 8; ++i) {
        [frames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"fire%d.png", i]]];
    }
    
    CCAnimation *anim = [CCAnimation
                         animationWithSpriteFrames:frames delay:0.1f];

    CCSprite *bomb = [CCSprite spriteWithSpriteFrameName:@"fire1.png"];
    bomb.position = pos;
    CCAction *action = [CCSequence actions:[CCAnimate actionWithAnimation:anim],
                        [CCCallFuncN actionWithTarget:self selector:@selector(removeExplosion:)],
                        nil];
    [bomb runAction:action];
    [explodeSheet addChild:bomb];

}

-(void) removeExplosion:(id) sender{
    [sender removeFromParentAndCleanup:YES];
}
-(void) setWithContext:(GameContext*) context{
    CGSize winSize = [CCDirector sharedDirector].winSize;
    type = context.type;
    if(type==Classic)
    {        
        CGPoint pos = heal.position;
        [heal removeFromParentAndCleanup:YES];
        heal = [GermFigure spriteWithFile:@"grayreset_bt.png"];
        heal.position = pos;
        [self addChild:heal];
        
        for(int i=1;i<=3;i++)
        {
            [starPictures addObject:[CCSprite spriteWithFile: [NSString stringWithFormat:@"star%d.png",i]]];
        }
        
        if(title==nil)
        {
            title = [CCSprite spriteWithFile:@"leveltitle.png"];
            title.position = ccp(winSize.width*0.5f,winSize.height-32);
            [self addChild:title];
            
            
            passScoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",levelScore] fontName:@"Arial-BoldMT" fontSize:15];
            passScoreLabel.position = ccp(winSize.width*0.63, winSize.height*0.97);
            passScoreLabel.anchorPoint=ccp(0,0.5);
            passScoreLabel.color = ccc3(250,250,250);
            [self addChild:passScoreLabel];
            
            
            clockLine = [CCSprite spriteWithFile:@"clock_line.png"];
            
            //[self addChild:clockLine];
            timer=[CCProgressTimer progressWithSprite:clockLine];
            [timer setPosition:ccp(winSize.width*0.26f,winSize.height*0.912f)];
            [timer setType:kCCProgressTimerTypeBar];
            [timer setMidpoint:ccp(0,0)];
            [timer setBarChangeRate:ccp(1,0)];
            [self addChild:timer];
            
            clock = [CCSprite spriteWithFile:@"clock.png"];
            clock.position = ccp(winSize.width*0.24f,winSize.height*0.915f);
            [self addChild:clock];
            
            
            if(!isRetina)
            {
                title.scale=0.5f;
                [timer setScale:0.51f];
                clock.scale=0.5f;
                heal.scale = 0.5f;
            }
        }
        
        starSpan = context.interval;
    }else{
        
        if(title==nil)
        {
            title = [CCSprite spriteWithFile:@"endlesstitle.png"];
            if(!isRetina)
            {
                title.scale=0.5f;
            }
            title.position = ccp(winSize.width*0.5f,winSize.height-32);
            [self addChild:title];
            
            for(int i=0;i<3;i++)
            {
                CCSprite *astar = [CCSprite spriteWithFile: [NSString stringWithFormat:@"heart.png"]];
                if(!isRetina)
                {
                    astar.scale=0.5f;
                }
                astar.position = ccp(winSize.width*(0.544+i*0.1) ,winSize.height*0.916f);
                [starPictures addObject:astar];
                [self addChild:astar];
            }
            
            int r = [[[[UserProfile sharedInstance] userRecord] objectForKey:[CommonUtils getKeyStringByGameTypeAndLevel:context.type level:1]] integerValue];
            if(r<0)
            {
                r=0;
            }
            CCLabelTTF *record = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",r] fontName:@"Arial-BoldMT" fontSize:15];
            record.color=ccc3(255,255,0);
            [record setAnchorPoint:ccp(0,0.5)];
            record.position = ccp(winSize.width*0.33 ,winSize.height*0.9635f);
            
            [self addChild:record];
        }
    }
    if(pause.parent==nil)
    {
        [self addChild:pause];
    }
    // 设置计分板
    if(scoreLabel==nil)
    {
        scoreLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Arial-BoldMT" fontSize:15];
        scoreLabel.anchorPoint = ccp(0,0.5);
        if(context.type==Classic)
        {
            scoreLabel.position = ccp(winSize.width*0.21, winSize.height*0.97);
        }else{
            scoreLabel.position = ccp(winSize.width*0.23, winSize.height*0.91);
        }
        scoreLabel.color = ccc3(250,250,250);
        [self addChild:scoreLabel];
    }
    
    [self resetTime:[context time]];
    [self resetLevelScore:[context levelScore]];
    [self setType:[context type]];
}
-(void) onEnterTransitionDidFinish
{
    [self schedule:@selector(changeClock) interval:1];
    if(self.time!=0)
    {
        CCProgressTo* to = [CCProgressTo actionWithDuration:self.time+0.5f percent:100];
        [timer runAction:to];
    }
}

-(void) setType:(GameType)atype
{
    type=atype;
}

-(void) resetLevelScore:(int)alevelScore
{
    //如果是第一次设置，调用方法初始化label
    self.levelScore=alevelScore;
    if(type==Classic)
    {
        if(passScoreLabel!=nil)
        {
            [passScoreLabel setString:[NSString stringWithFormat:@"%d",levelScore]];
            return;
        }
        
    }
    
    
}
-(void) resetTime:(int)atime
{
    self.time=atime;
    timeRemain=atime;
}

-(void) changeClock
{
    if(type == TimeBomb)
    {
        NSMutableArray *content = [[[PlayLayer sharedInstance:NO] getBox] content];
        for (int i=[content count]-1; i>=0; i--) {
            NSMutableArray *array = [content objectAtIndex:i];
            for(int j =0;j<[array count];j++)
            {
                Germ *g= [array objectAtIndex:j];
                if(g.type==TimeBombGerm)
                {
                    GermFigure *sprite = g.sprite;
                    int i=[sprite nextValue];
                    if(i==0)
                    {
                        CGPoint pos = [[[g sprite] bomb] position];
                        [g transform:NormalGerm];
                        [[PlayDisplayLayer sharedInstance:NO] showExplosion:pos];
                        [MusicHandler playEffect:@"explosion.mp3"];
                        if([self subLife])
                        {
                            [self gameOver];
                        }
                    }
                }
                
            }
        }
    }
    
    if(timeRemain<=0&&type==Classic)
    {
        timeRemain =0;
        // 游戏结束
        [self gameOver];
        
        return;
    }else{
        if(type==Classic)
        {
            timeRemain--;
        }
    }
}

-(void) setScore:(int) value
{
    score=value;
    [scoreLabel setString:[NSString stringWithFormat:@"%d",score]];
    
    if(score>=levelScore&&levelScore!=0)
    {
        if(type==Classic) //经典玩法中累计星星
        {
            [self addAStar];
            while(star<3) //还没有拿到三颗星
            {
                [self resetLevelScore:levelScore+starSpan];
                if(value<levelScore)
                {
                    break;
                }
                [self addAStar];
            }
            if(star == 3)
            {  //拿到三颗星
                // 胜利
                // 跳到中间页面
                //[[PlayLayer sharedInstance:NO] toNextLevel:YES];
            }
        }
        
        else{ // 无限模式中直接增加级别
            PlayLayer* l = [PlayLayer sharedInstance:NO];
            GameContext* c = [[l context] getNextLevel];
            [l resetWithContext:c refresh:NO];
        }
    }
}

-(void) addAStar{
    if(star==3)
    {
        return;
    }
    CGSize winSize = [CCDirector sharedDirector].winSize;
    float offset = 0.105f;
    
    CCSprite *astar = [starPictures objectAtIndex:star];
    astar.scale=0.0f;
    //astar.position = ccp(winSize.width*0.795f,winSize.height*0.92f);
    astar.position = ccp(winSize.width*(0.47+star*offset) ,winSize.height*0.67f);
    
    star++;
    CCAction *action;
    [MusicHandler playEffect:@"star.mp3"];
    
    if(star==1)
    {
        action = [CCSequence actions:[CCSpawn actions:[CCScaleTo actionWithDuration:apearspeed scale:openScale],
                                      [CCMoveBy actionWithDuration:apearspeed position:ccp(-10,20)],
                                      nil],
                  [CCSpawn actions:[CCScaleTo actionWithDuration:fixspeed scale:isRetina?1:0.5f],
                   [CCMoveTo actionWithDuration:fixspeed position:ccp(winSize.width*0.540f,winSize.height*0.915f)],
                   nil],
                  nil];
    }else if(star==2)
    {
        action = [CCSequence actions:[CCSpawn actions:[CCScaleTo actionWithDuration:apearspeed scale:openScale],
                                      [CCMoveBy actionWithDuration:apearspeed position:ccp(-10,20)],
                                      nil],
                  [CCSpawn actions:[CCScaleTo actionWithDuration:fixspeed scale:isRetina?1:0.5f],
                   [CCMoveTo actionWithDuration:fixspeed position:ccp(winSize.width*0.641f,winSize.height*0.915f)],
                   nil],
                  nil];
        
        
    }else{
        action = [CCSequence actions:[CCSpawn actions:[CCScaleTo actionWithDuration:apearspeed scale:openScale],
                                      [CCMoveBy actionWithDuration:apearspeed position:ccp(-10,20)],
                                      nil],
                  [CCSpawn actions:[CCScaleTo actionWithDuration:fixspeed scale:isRetina?1:0.5f],
                   [CCMoveTo actionWithDuration:fixspeed position:ccp(winSize.width*0.741f,winSize.height*0.915f)],
                   nil],
                  nil];
        
    }
    [self addChild:astar];
    [astar runAction:action];
    
}

-(void) removeLabel: (id) sender{
    [self removeChild:sender cleanup:YES];
    
}


-(void) showMultiHit:(int)hit{
    int randomx = arc4random()%90-45;
    int randomy = arc4random()%90-45;
    
    CCLabelTTF* tempLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d连击！！！",hit] fontName:@"AmericanTypewriter-Bold" fontSize:28];
    tempLabel.position = ccp(kStartX+kTileSize*kBoxWidth/2+randomx, kStartY+kTileSize*kBoxHeight/2+randomy);
    tempLabel.color = ccc3(253,217,71);
    [self addChild:tempLabel];
    
    CCAction *action = [CCSequence actions:[CCSpawn actions:
                                            [CCMoveBy actionWithDuration:1 position:ccp(0,20)],
                                            [CCScaleBy actionWithDuration:1 scale:1.3],nil],
                        [CCCallFuncN actionWithTarget: self selector:@selector(removeLabel:)],
                        nil];
    
    [tempLabel runAction:action];
}

- (void)ccTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event{
	UITouch* touch = [touches anyObject];
	CGPoint location = [touch locationInView: touch.view];
	location = [[CCDirector sharedDirector] convertToGL: location];
    UserProfile *pro = [UserProfile sharedInstance];
    
    if(CGRectContainsPoint([hint boundingBox], location))
    {
        int num = [pro tools_hint];
        if(num<=0)
        {
            return;
        }
        
        BOOL flag = [[PlayLayer sharedInstance:NO] hint];
        if(flag)
        { 
            [MusicHandler playEffect:@"hint.mp3"];
            [pro addHint:-1];
            //[UserProfile writeBackToFile];
            int value = [hint nextValue];
            [MobClick event:@"useHint" label:[NSString stringWithFormat:@"%d",value]];
        }else{
            [[PlayLayer sharedInstance:NO] reload];
            [MusicHandler playEffect:@"disabled.mp3"];
        }
        return;
    }
    
    if(CGRectContainsPoint([heal boundingBox], location))
    {
        int num = [pro tools_life];
        if(num<=0)
        {
            return;
        }
        if([self addLife]){
            while([self addLife]){
            }
            [pro addLife:-1];
            //[UserProfile writeBackToFile];
            int value = [heal nextValue];
            [MobClick event:@"useRebirth" label:[NSString stringWithFormat:@"%d",value]];
            [MusicHandler playEffect:@"addlife.mp3"];
        }
    }
    
    if(CGRectContainsPoint([reload boundingBox], location))
    {
        if(tools_enable==NO)
        {
            return;
        }
        int num = [pro tools_refill];
        if(num<=0)
        {
            //return;
        }
        tools_enable = NO;
        [self scheduleOnce:@selector(enableTools) delay:2];
        [pro addRefill:-1];
        int value = [reload nextValue];
        [MobClick event:@"useRefill" label:[NSString stringWithFormat:@"%d",value]];
        [[PlayLayer sharedInstance:NO] reload];
        return;
    }
    
    
    if(CGRectContainsPoint([pause boundingBox], location))
    {
        [self pauseGame];
        [SceneManager goPauseLayer];
        return;
    }
    
}

-(void) pauseGame{
    [timer pauseSchedulerAndActions];
    [self pauseSchedulerAndActions];
    self.isTouchEnabled = NO;
    [[PlayLayer sharedInstance:NO]  pauseGame];
}

-(void) resumeGame
{
    self.isTouchEnabled = YES;
    [timer resumeSchedulerAndActions];
    [self resumeSchedulerAndActions];
    [[PlayLayer sharedInstance:NO]  resumeGame];
}

-(BOOL) addLife{
    if(life<3)
    {
        life++;
    }else{
        return NO;
    }
    [[starPictures objectAtIndex:3-life] setVisible:YES];

    return YES;
}

-(BOOL) subLife{
    if(life == 0)
    {
        return YES;
    }
    CCSprite *heart = [starPictures objectAtIndex:3-life];
    heart.visible = NO;
    life--;
    if(life==0)
    {
        return YES;
    }
    return NO;
}
-(void) enableTools{
    tools_enable=YES;
}

-(void) gameOver{
    [self pauseGame];
    [MusicHandler stopBackground];
    [SceneManager goRewardLayer:type==Classic?1:2];
}
@end
