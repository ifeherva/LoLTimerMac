//
//  AppDelegate.h
//  LoLTimer
//
//  Created by Istvan Fehervari on 8/14/13.
//
//

#import <Cocoa/Cocoa.h>
#import "LTTimerEntry.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate> {
    IBOutlet NSTableView* timerList;
    IBOutlet NSView* mainView;
    IBOutlet NSScrollView* scrollView;
    
    // sound synthetizer
    NSSpeechSynthesizer* synth;
    
    NSMutableArray *_tableContent;
    
    NSTimer* updateTimer;
    bool _isUpdateTimerRunning;
    
    // timers that are currently running (LTTimerEntry entries)
    NSMutableArray *_runningTimers;
}

@property (assign) IBOutlet NSWindow *window;

-(IBAction)addNewTimer:(id)sender;

-(IBAction)removeTimer:(id)sender;

-(IBAction)stopAllTimers:(id)sender;

-(void) say:(NSString*)text;

-(void)timerStarted:(LTTimerEntry*) timer;

-(void)timerStopped:(LTTimerEntry*) timer;

@end
