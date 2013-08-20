//
//  LTTimerEntry.m
//  LoLTimer
//
//  Created by Istvan Fehervari on 8/14/13.
//
//

#import "LTTimerEntry.h"

@implementation LTTimerEntry {
    
}

@synthesize _warningLength, _name, _type, _sendCompletionMessageToTeamChat, _sendWarningMessageToTeamChat, isTimerRunning, _parentView, _globalHotKey;

NSString *const STATEKEY_TIMERLENGTH = @"timerLength";
NSString *const STATEKEY_WARNINGLENGTH = @"warningLength";
NSString *const STATEKEY_NAME = @"name";
NSString *const STATEKEY_TYPE = @"type";
NSString *const STATEKEY_HOTKEYFLAG = @"hotkeyFlags";
NSString *const STATEKEY_HOTKEYCODE = @"hotkeyCode";
NSString *const STATEKEY_COMPLETIONTOCHAT = @"sendCompletionMessageToTeamChat";
NSString *const STATEKEY_WARNINGTOCHAT = @"sendWarningMessageToTeamChat";

- (id)init
{
    self = [super init];
    if (self) {
        
        _name = @"Unnamed";
        _warningLength = 20;
        _type = 0;// blue
        _sendCompletionMessageToTeamChat = YES;
        _sendWarningMessageToTeamChat = YES;
        isTimerRunning = NO;
        
        _globalHotKey.flags = 0;
        _globalHotKey.code = -1;
        
        [self initTimerLengths];
    }
    
    return self;
}

-(void) initTimerLengths {
    timerLengths[LT_BLUE] = 5 * 60;//blue
    timerLengths[LT_RED] = 5 * 60;//red
    timerLengths[LT_DRAGON] = 6 * 60;//dragon
    timerLengths[LT_BARON] = 7 * 60;//baron
    timerLengths[LT_WARD] = 3 * 60;//ward
    timerLengths[LT_SMALLCAMP] = 60;//small
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self._name forKey:STATEKEY_NAME];
    [coder encodeObject:[NSNumber numberWithInteger: self._warningLength] forKey:STATEKEY_WARNINGLENGTH];
    [coder encodeObject:[NSNumber numberWithInteger: self._type] forKey:STATEKEY_TYPE];
    [coder encodeObject:[NSNumber numberWithBool: self._sendCompletionMessageToTeamChat] forKey:STATEKEY_COMPLETIONTOCHAT];
    [coder encodeObject:[NSNumber numberWithBool: self._sendWarningMessageToTeamChat] forKey:STATEKEY_WARNINGTOCHAT];
    [coder encodeObject:[NSNumber numberWithInteger: self._globalHotKey.flags] forKey:STATEKEY_HOTKEYFLAG];
    [coder encodeObject:[NSNumber numberWithInteger: self._globalHotKey.code] forKey:STATEKEY_HOTKEYCODE];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        
        _name = [coder decodeObjectForKey:STATEKEY_NAME];
        _warningLength = [[coder decodeObjectForKey:STATEKEY_WARNINGLENGTH] intValue];
        _type = [[coder decodeObjectForKey:STATEKEY_TYPE] intValue];
        _sendCompletionMessageToTeamChat = [[coder decodeObjectForKey:STATEKEY_COMPLETIONTOCHAT] boolValue];
        _sendWarningMessageToTeamChat = [[coder decodeObjectForKey:STATEKEY_WARNINGTOCHAT] boolValue];
        isTimerRunning = NO;
        
        _globalHotKey.flags = [[coder decodeObjectForKey:STATEKEY_HOTKEYFLAG] intValue];
        _globalHotKey.code = [[coder decodeObjectForKey:STATEKEY_HOTKEYCODE] intValue];
        
        [self initTimerLengths];
    }
    
    
    return self;
}

-(NSTimeInterval) getTimerLength {
    return timerLengths[_type];
}

-(void)startTimer {
    // start main timer
    NSTimeInterval timerLength = [self getTimerLength];
    mainTimer = [NSTimer scheduledTimerWithTimeInterval:timerLength target:_parentView selector:@selector(mainTimerFinished) userInfo:nil repeats:NO];
    
    // start warning
    
    if ((_warningLength < timerLength) && (_warningLength > MINIMUM_WARNING_LENGTH)) {
        NSTimeInterval warning = timerLength-_warningLength;
        warningTimer = [NSTimer scheduledTimerWithTimeInterval:(warning) target:_parentView selector:@selector(warningTimerFinished) userInfo:nil repeats:NO];
    }
    
    // indicate that this timer is running
    isTimerRunning = YES;
}

-(NSTimeInterval) getRemainingTime {
    return -[[NSDate date] timeIntervalSinceDate:mainTimer.fireDate];
}

-(void)stopTimer {
    [mainTimer invalidate];
    [warningTimer invalidate];
    
    isTimerRunning = NO;
}

@end
