//
//  PlayDisplayLayer.m
//  TheGame
//
//  Created by kcy1860 on 12/11/12.
//
//

#import "PlayDisplayLayer.h"
#import "Germ.h"

@interface PlayDisplayLayer(){
    
    CCLabelTTF* clockLabel;
    CCLabelTTF* scoreLabel;
    CCLabelTTF* passScoreLabel;
    
    CCSprite* pause;
    
    CCSprite* restart;
    
    /*UserTools*/
    CCSprite* hint;
    CCSprite* heal;
    CCSprite* reload;
    
    int timeRemain;
    GameType type;
}

@end
@implementation PlayDisplayLayer

@synthesize score,levelScore,time,star,life;

static PlayDisplayLayer* thisLayer;

+(PlayDisplayLayer*) sharedInstance:(BOOL) refresh
{
    if(thisLayer!=nil&&refresh)
    {
        [thisLayer release];
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
        CGSize winSize = [CCDirector sharedDirector].winSize;
        // 设置倒计时的位置
        clockLabel = [CCLabelTTF labelWithString:[self generateString] fontName:@"Arial" fontSize:15];
        clockLabel.position = ccp(winSize.width*0.33, winSize.height*0.92);
        clockLabel.color = ccc3(0,0,0);
        [self addChild:clockLabel];
        
        
        // 设置计分板
        score=0;
        scoreLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Arial" fontSize:15];
        scoreLabel.position = ccp(winSize.width*0.33, winSize.height*0.97);
        scoreLabel.color = ccc3(0,0,0);
        [self addChild:scoreLabel];
        
        
        
        self.isTouchEnabled = YES;
        
    }
    return self;
}

-(void) onEnterTransitionDidFinish
{
    if(self.time!=0)
    {
        [self schedule:@selector(changeClock) interval:1];
    }
}

-(void) setType:(GameType)atype
{
    type=atype;
}

-(void) resetLevelScore:(int)alevelScore
{
    self.levelScore=alevelScore;
    if(type==Classic)
    {
        if(passScoreLabel!=nil)
        {
            [passScoreLabel setString:[NSString stringWithFormat:@"%d",levelScore]];
            return;
        }
        
        //如果是第一次设置，调用方法初始化label
        CGSize winSize = [CCDirector sharedDirector].winSize;
        // 设置计分板
        passScoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",levelScore] fontName:@"Arial" fontSize:15];
        passScoreLabel.position = ccp(winSize.width*0.55, winSize.height*0.97);
        passScoreLabel.color = ccc3(0,0,0);
        [self addChild:passScoreLabel];
    }
}
-(void) resetTime:(int)atime
{
    self.time=atime;
    timeRemain=atime;
}

-(void) changeClock
{
    if(timeRemain<=0)
    {
        timeRemain =0;
        return;
    }else{
        timeRemain--;
        [clockLabel setString:[self generateString]];
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
                            //炸弹爆炸 扣一格血
                        }
                    }
                    
                }
            }
        }
    }
}

-(void) setScore:(int) value
{
    if(score>=levelScore&&levelScore!=0)
    {
        if(type==Classic) //经典玩法中累计星星
        {
            if(star<3) //还没有拿到三颗星
            {
                star++;
                [self resetLevelScore:levelScore*getStarSpan];
            }else{  //拿到三颗星
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
    
    score=value;
    [scoreLabel setString:[NSString stringWithFormat:@"%d",score]];
}

-(void) removeLabel: (id) sender{
    [self removeChild:sender cleanup:YES];
    
}

-(void) pauseGame{
    
    [self pauseSchedulerAndActions];
    [[PlayLayer sharedInstance:NO]  pauseGame];
}

-(void) resumeGame
{
    [self resumeSchedulerAndActions];
    [[PlayLayer sharedInstance:NO]  resumeGame];
}

-(NSString*) generateString
{
    int minutes = timeRemain/60;
    int seconds = timeRemain%60;
    return [NSString stringWithFormat:@"%d:%d",minutes,seconds];
}

-(void) showMultiHit:(int)hit{
    int randomx = arc4random()%90-45;
    int randomy = arc4random()%90-45;
    
    CCLabelTTF* tempLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d连击！！！",hit] fontName:@"Arial" fontSize:30];
    tempLabel.position = ccp(kStartX+kTileSize*kBoxWidth/2+randomx, kStartY+kTileSize*kBoxHeight/2+randomy);
    tempLabel.color = ccc3(0,0,0);
    [self addChild:tempLabel];
    
    CCAction *action = [CCSequence actions:[CCSpawn actions:
                                            [CCMoveBy actionWithDuration:0.5f position:ccp(0,20)],
                                            [CCScaleBy actionWithDuration:0.5f scale:1.3],nil],
                        [CCCallFuncN actionWithTarget: self selector:@selector(removeLabel:)],
                        nil];
    
    [tempLabel runAction:action];
}


@end
