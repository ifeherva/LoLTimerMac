//
//  AppDelegate.m
//  LoLTimer
//
//  Created by Istvan Fehervari on 8/14/13.
//
//

#import "AppDelegate.h"
#import "LTTimerEntry.h"
#import "LTEntryCellView.h"

@implementation AppDelegate {
}


- (id)init
{
    self = [super init];
    if (self) {
        // array of running timers
        _runningTimers = [[NSMutableArray alloc] init];
        
        // the update timer state indicator
        _isUpdateTimerRunning = NO;
        
        // read from saved state
        @try {
            _tableContent = [NSKeyedUnarchiver unarchiveObjectWithFile:[self pathForDataFile]];
        }
        @catch (NSException* e) {
            // initialize array of timers
            _tableContent = [[NSMutableArray alloc] init];
        }
    }
    
    return self;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // tooltip defaults
    [[NSUserDefaults standardUserDefaults] setObject:@"Add new timer" forKey:@"addButtonToolTip"];
    [[NSUserDefaults standardUserDefaults] setObject:@"Stop the timer" forKey:@"stopTimerToolTip"];
    [[NSUserDefaults standardUserDefaults] setObject:@"Stop all timers" forKey:@"stopAllTimersToolTip"];
    [[NSUserDefaults standardUserDefaults] setObject:@"Remove this timer" forKey:@"removeTimerToolTip"];
}

- (void) awakeFromNib {

    if (_tableContent == nil)
        _tableContent = [[NSMutableArray alloc] init];
    
    synth = [[NSSpeechSynthesizer alloc] init];
    [synth setVoice:@"com.apple.speech.synthesis.voice.jill.premium"];
}

// before termination
- (void)applicationWillTerminate:(NSApplication *)application {   
    // save app state
    [NSKeyedArchiver archiveRootObject:_tableContent toFile:[self pathForDataFile]];
}

- (NSString *) pathForDataFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *folder = @"~/Library/Application Support/LoLTimerMac/";
    folder = [folder stringByExpandingTildeInPath];
    
    if ([fileManager fileExistsAtPath: folder] == NO)
    {
        [fileManager createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *fileName = @"LoLTimerMac.statefile";
    return [folder stringByAppendingPathComponent: fileName];
}

// Returns the number of rows in the table
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [_tableContent count];
}

// should return a filled-out view for the table for each row, read from the array
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    LTTimerEntry *entry = _tableContent[row];
    NSString *identifier = [tableColumn identifier];//identifier of the column (we dont need)
    if ([identifier isEqualToString:@"MainCell"]) { //check for the right column
        // create cell
        LTEntryCellView *cellView = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
        cellView.timerEntry = entry;
        entry._parentView = cellView;
        return cellView;
    }
    return nil;
}

// adds a new action
-(IBAction)addNewTimer:(id)sender {
    LTTimerEntry* newentry = [[LTTimerEntry alloc] init];
    [_tableContent addObject:newentry];
    [timerList reloadData];    
}

// stops resizing horizontally
- (NSSize)windowWillResize:(NSWindow *)window toSize:(NSSize)proposedFrameSize {
    proposedFrameSize.width = window.frame.size.width;
    return proposedFrameSize;
}

-(IBAction)removeTimer:(id)sender {
    
    NSButton* button = sender;
    
    // get parent (cell) view
    LTEntryCellView* cellView = (LTEntryCellView*)(button.superview);
    
    // stop timer
    [cellView._timerEntry stopTimer];
    
    [_tableContent removeObject:cellView._timerEntry];
    [timerList reloadData];
}

-(IBAction)stopAllTimers:(id)sender {
    // stop all timers
    for (LTTimerEntry* entry in _tableContent) {
        [entry stopTimer];
    }
    
    [_runningTimers removeAllObjects];
    [updateTimer invalidate];
    _isUpdateTimerRunning = NO;
    
}

// informs the delegate that a timer has started
-(void)timerStarted:(LTTimerEntry*) timer {
    if (![_runningTimers containsObject:timer]) {
        [_runningTimers addObject:timer];
    }
    
    if (!_isUpdateTimerRunning) {
        _isUpdateTimerRunning = YES;
        // start timer
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateTimers) userInfo:nil repeats:YES];
    }
}

-(void)timerStopped:(LTTimerEntry*) timer {
    [_runningTimers removeObject:timer];
    
    if ([_runningTimers count] == 0) {
        [updateTimer invalidate];
        _isUpdateTimerRunning = NO;
    }
}

-(void)updateTimers {
    for (LTTimerEntry* entry in _runningTimers) {
        LTEntryCellView* cellview = (LTEntryCellView*)entry._parentView;
        NSTimeInterval remaining = [entry getRemainingTime];
        int r = (int) remaining;
        int min = r / 60;
        int sec = r % 60;
        
        [cellview setTimeForTextField:[NSString stringWithFormat:@"%0d:%02d",min,sec]];
    }
}

-(void) say:(NSString*)text {
    //NSLog(text);
    [synth startSpeakingString:text];
}

@end
