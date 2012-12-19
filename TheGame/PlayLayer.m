#import "PlayLayer.h"

@interface PlayLayer()
-(void)afterOneShineTrun: (id) node;

@end

@implementation PlayLayer
@synthesize context = _context;
@synthesize stepCount=_stepCount;

int lastHit;
int clickcount;
bool paused;

static PlayLayer* thisLayer;

+(PlayLayer*) sharedInstance:(BOOL) refresh
{
    if(thisLayer!=nil&&refresh)
    {
        [thisLayer release];
        thisLayer =nil;
    }
    if(thisLayer==nil)
    {
        thisLayer = [PlayLayer node];
    }
    
    return thisLayer;
}


-(id) init{
	self = [super init];
	box = [[Box alloc] initWithSize:CGSizeMake(kBoxWidth,kBoxHeight) factor:6];
	box.holder = self;
	box.lock = YES;
    _stepCount=0;
    self.isTouchEnabled = YES;
    lastHit = 0;
    clickcount=0;
    paused=NO;
	return self;
}



-(void) pauseGame{
    paused=YES;
    [self pauseSchedulerAndActions];
    [box setPaused:YES];
}

-(void) resumeGame{
    paused=NO;
    [self resumeSchedulerAndActions];
    [box setPaused:NO];
}

-(void) onEnterTransitionDidFinish{
    [self checkPosition];
}

-(void) checkPosition
{
    NSMutableArray *content = [box content];
    for (int i=0; i<[content count]; i++) {
        NSMutableArray *array = [content objectAtIndex:i];
        for(int j =0;j<[array count];j++)
        {
            Germ *g= [array objectAtIndex:j];
            [g.sprite setPosition:g.pixPosition];
            [g.sprite recorrectLabelPosition];
        }
    }
}


-(void) resetWithContext:(GameContext *)context refresh:(BOOL) fresh
{
    _context = context;
    PlayDisplayLayer *dis = [PlayDisplayLayer sharedInstance:NO];
    [dis resetTime:[context time]];
    [dis resetLevelScore:[context levelScore]];
    [dis setType:[context type]];
    
    [box setKind:context.kindCount];
    if(fresh)
    {
        [box fill];
        [box check];
        [box unlock];
    }
    
}
-(void) hint
{
    CGPoint point = [box haveMore];
    Germ *tile = [box objectAtX:point.x Y:point.y];
    if(selected == tile)
    {
        return;
    }
    selected = tile;
    [self afterOneShineTrun:tile.sprite];
}

-(void) reload
{
    [box fill];
    [box check];
    [box unlock];
}

- (void)ccTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event{
	if ([box lock]) {
		return;
	}
	
	UITouch* touch = [touches anyObject];
	CGPoint location = [touch locationInView: touch.view];
	location = [[CCDirector sharedDirector] convertToGL: location];
	
    int difX = location.x -kStartX;
    int difY = location.y -kStartY;
    if(difY<0)
    {
        if(difX>150)
        {
            [self hint];
        }else{
            [self reload];
        }
        return;
    }
    if(difY>kTileSize*7)
    {
        if(difX>150)
        {
            [[PlayDisplayLayer sharedInstance:NO] pauseGame];
            [SceneManager goPauseMenu];
        }
        return;
    }
    
    if(paused)//如果被暂定 就直接返回
    {
        return;
    }
	int x = difX / kTileSize;
	int y = difY / kTileSize;
    
	
	//如果两次选到的是同一个 直接返回
	if (selected && selected.x ==x && selected.y == y) {
        clickcount++;
        if(clickcount==2)
        {
            clickcount=0;
            [selected.sprite removeFromParentAndCleanup:YES];
            [selected transform:PoisonousGerm];
            [self addChild:selected.sprite];
            //[self addChild:selected.sprite.label];
            [self afterOneShineTrun:selected.sprite];
            [box check];
        }
		return;
	}
	clickcount=0;
    
	Germ *tile = [box objectAtX:x Y:y];
    
	if (selected && [selected isNeighbor:tile]) {
		[box setLock:YES];
		[self changeWithTileA: selected TileB: tile sel: @selector(check:data:)];
		selected = nil;
        firstOne = nil;
	}else {
        //如果选择到的不是neighbor 相当于重新选择
		selected = tile;
        firstOne = tile;
		[self afterOneShineTrun:tile.sprite];
	}
}

-(void) changeWithTileA: (Germ *) a TileB: (Germ *) b sel : (SEL) sel{
	CGPoint pa = a.pixPosition;
    CGPoint pb = b.pixPosition;
    int difx = pa.x-pb.x;
    int dify = pa.y-pb.y;
    CCAction *actionA = [CCSequence actions:
						 [CCMoveBy actionWithDuration:kMoveTileTime position:ccp(-difx,-dify)],
						 [CCCallFuncND actionWithTarget:self selector:sel data: a],
						 nil
						 ];
	
	CCAction *actionB = [CCSequence actions:
						 [CCMoveBy actionWithDuration:kMoveTileTime position:ccp(difx,dify)],
						 [CCCallFuncND actionWithTarget:self selector:sel data: b],
						 nil
						 ];
    [a.sprite runAction:actionA];
	[b.sprite runAction:actionB];
	[a trade:b];
}

-(void) backCheck: (id) sender data: (id) data{
	if(nil == firstOne){
		firstOne = data;
		return;
	}
	firstOne = nil;
}
// 检查转换是否有效，如果无效则换回来
-(void) check: (id) sender data: (id) data{
	if(nil == firstOne||firstOne==data){
		firstOne = data;
		return;
	}
	BOOL result = [box check];
	if (result) {
        //[self nextStep];
		//[box setLock:NO];
	}else {
		[self changeWithTileA:(Germ *)data TileB:firstOne sel:@selector(backCheck:data:)];
		[self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:kMoveTileTime + 0.03f],
						 [CCCallFunc actionWithTarget:box selector:@selector(unlock)],
						 nil]];
	}
    
	firstOne = nil;
}

-(void) nextStep{
    _stepCount++;
    if(_stepCount==1000) //到达某个数目的时候重置，避免溢出
    {
        _stepCount=1;
    }

    NSMutableArray *content = [box content];
    for (int i=[content count]-1; i>=0; i--) {
        NSMutableArray *array = [content objectAtIndex:i];
        for(int j =0;j<[array count];j++)
        {
            Germ *g= [array objectAtIndex:j];
            if( g.type ==PoisonousGerm )
            {
                if(i==6)
                {
                    // 游戏结束
                }else{
                    [self changeWithTileA:[box objectAtX:j Y:(i+1)] TileB:g sel:@selector(backCheck:data:)];
                    CCAction *action = [CCSequence actions:[CCDelayTime actionWithDuration:kMoveTileTime+0.3f],
                                        [CCCallFunc actionWithTarget:self selector:@selector(checkPosition)],
                                        nil];
                    [self runAction:action];
                    [box check];
                }
            }
            else if(g.type == BombGerm)
            {
                int i=[g.sprite nextValue];
                if(i==0)
                {
                    //扣一格血
                }
            }
            
        }
    }
    if(_context.type!=Classic && _context.interval!=0)
    {
        if(_stepCount%_context.interval==0)
        {
            // 刷新孢子
            [self changeOneGermByType:_context.type];
        }
    }
    //[self checkPosition];
}

-(void) changeOneGermByType:(GameType) type
{
    int x = arc4random()%7;
    int y = arc4random()%7;
    
    GermType t = TimeBombGerm;
    switch (type) {
        case Bomb:
            t=BombGerm;
            break;
        case Poisonous:
            t =PoisonousGerm;
            y=0;
            break;
        default:
            break;
    }
    
    Germ* g = [box objectAtX:x Y:y];
    [g.sprite removeFromParentAndCleanup:YES];
    [g transform:t];
    [self addChild:g.sprite];
    if(t==TimeBombGerm||t==BombGerm)
    {
        [self addChild:g.sprite.label];
    }

}


-(void)afterOneShineTrun: (id) node{
	if (selected && node == selected.sprite) {
		GermFigure *sprite = (GermFigure *)node;
		CCSequence *someAction = [CCSequence actions:
								  [CCScaleBy actionWithDuration:kShineFreq scale:0.5f],
								  [CCScaleBy actionWithDuration:kShineFreq scale:2.0f],
                                  
								  [CCCallFuncN actionWithTarget:self selector:@selector(afterOneShineTrun:)],//重新调用 持续闪烁
                                  
								  nil];
        
		[sprite runAction:someAction];
	}
    
}

-(void) toNextLevel:(BOOL) refresh{
    GameContext *context = [[self context] getNextLevel];
    [self resetWithContext:context refresh:refresh];
}

-(Box*) getBox{
    return box;
}
@end
