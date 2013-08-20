//
//  LTTimerEntry.h
//  LoLTimer
//
//  Created by Istvan Fehervari on 8/14/13.
//
//

#import <Foundation/Foundation.h>
#import <ShortcutRecorder/ShortcutRecorder.h>

@class PTKeyCombo;

#define MINIMUM_WARNING_LENGTH 5

#define LT_BLUE 0
#define LT_RED 1
#define LT_DRAGON 2
#define LT_BARON 3
#define LT_WARD 4
#define LT_SMALLCAMP 5

// state keys
FOUNDATION_EXPORT NSString *const STATEKEY_TIMERLENGTH;
FOUNDATION_EXPORT NSString *const STATEKEY_WARNINGLENGTH;
FOUNDATION_EXPORT NSString *const STATEKEY_NAME;
FOUNDATION_EXPORT NSString *const STATEKEY_TYPE;
FOUNDATION_EXPORT NSString *const STATEKEY_HOTKEYFLAG;
FOUNDATION_EXPORT NSString *const STATEKEY_HOTKEYCODE;
FOUNDATION_EXPORT NSString *const STATEKEY_COMPLETIONTOCHAT;
FOUNDATION_EXPORT NSString *const STATEKEY_WARNINGTOCHAT;

@interface LTTimerEntry : NSObject {
    NSInteger _warningLength;
    NSString* _name;
    NSInteger _type;
    // the hotkey
    KeyCombo _globalHotKey;
    
    bool _sendCompletionMessageToTeamChat;
    bool _sendWarningMessageToTeamChat;
    
    NSTimeInterval timerLengths[6];
    
    // timers
    NSTimer* mainTimer;
    NSTimer* warningTimer;
    
    // indictes if the timer is running
    bool isTimerRunning;
    
    // parent view
    __weak NSView* _parentView;
}

@property (nonatomic) NSInteger _warningLength;
@property (nonatomic, strong) NSString* _name;
@property (nonatomic) NSInteger _type;
@property (nonatomic) KeyCombo _globalHotKey;
@property (nonatomic) bool _sendCompletionMessageToTeamChat;
@property (nonatomic) bool _sendWarningMessageToTeamChat;
@property (nonatomic) bool isTimerRunning;
@property (nonatomic, weak) NSView* _parentView;

-(NSTimeInterval) getTimerLength;

-(void)startTimer;
-(void)stopTimer;
-(NSTimeInterval) getRemainingTime;

@end
