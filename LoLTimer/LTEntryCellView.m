//
//  LTEntryCellView.m
//  LoLTimer
//
//  Created by Istvan Fehervari on 8/15/13.
//
//

#import "LTEntryCellView.h"
#import "AppDelegate.h"

@implementation LTEntryCellView {
}

@synthesize _timerEntry;


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here. 
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Filling background based on type
  
    if (_timerEntry == nil)
        return;

    NSColor* fillcolor;
    
    if (_timerEntry._type == 0) //blue
        fillcolor = [NSColor colorWithCalibratedRed:60.0/255.0 green:82.0/255.0 blue:254.0/255 alpha:1];
    
    else if (_timerEntry._type == 1) //red
        fillcolor = [NSColor colorWithCalibratedRed:198.0/255.0 green:43.0/255.0 blue:16.0/255 alpha:1];
    
    else if (_timerEntry._type == 2) //dragon
        fillcolor = [NSColor colorWithCalibratedRed:218.0/255.0 green:199.0/255.0 blue:72.0/255 alpha:1];

    else if (_timerEntry._type == 3) //baron
        fillcolor = [NSColor colorWithCalibratedRed:162.0/255.0 green:82.0/255.0 blue:215.0/255 alpha:1];
    
    else if (_timerEntry._type == 4) //ward
        fillcolor = [NSColor colorWithCalibratedRed:171.0/255.0 green:93.0/255.0 blue:0 alpha:1];
    
    else //rest
        fillcolor = [NSColor colorWithCalibratedRed:89.0/255.0 green:181.0/255.0 blue:60.0/255 alpha:1];
    
    //NSLog(@"%fx%f",dirtyRect.size.width,dirtyRect.size.height);
    
    [fillcolor setFill];
    NSRectFill(dirtyRect);
    [super drawRect:dirtyRect];
}

- (void) awakeFromNib {
    
    // change stop button's image
    NSImage* stopImage = [NSImage imageNamed:@"stopButtonImage.png"];
    [stopImage setTemplate:YES];
    [stopButton setImage:stopImage];
    
    [shortcutRecorder setCanCaptureGlobalHotKeys:YES];
    
    pasteBoard = [NSPasteboard generalPasteboard];
}

// sets the display according to the provided source object
-(void) setTimerEntry:(LTTimerEntry *)timerEntry {
    _timerEntry = timerEntry;
    
    // set timer name
    timerNameField.stringValue = _timerEntry._name;
    
    // set type
    [typePopUp selectItemAtIndex:_timerEntry._type];
    
    // set shortcut
    [shortcutRecorder setKeyCombo:_timerEntry._globalHotKey];
    
    // set warning text
    warningTextField.stringValue = [NSString stringWithFormat:@"%ld",_timerEntry._warningLength];
    
    // set checkbox
    if (_timerEntry._sendCompletionMessageToTeamChat) {
        sendCompletionMessageToTeamChatCheckBox.state = NSOnState;
    } else {
        sendCompletionMessageToTeamChatCheckBox.state = NSOffState;
    }
    
    if (_timerEntry._sendWarningMessageToTeamChat) {
        sendWarningMessageToTeamChatCheckBox.state = NSOnState;
    } else {
        sendWarningMessageToTeamChatCheckBox.state = NSOffState;
    }
    
    // redraw background based on type
    [self setNeedsDisplay:YES];
    
}

-(void)controlTextDidChange:(NSNotification *)obj {
    NSTextField* textField = obj.object;
    
    if (textField == timerNameField) {
        _timerEntry._name = textField.stringValue;
    } else if (textField == warningTextField) {
        _timerEntry._warningLength = [textField.stringValue integerValue];
    }
}

-(IBAction)typeHasChanged:(id)sender {
    // save type to data source
    _timerEntry._type = [typePopUp selectedTag];
    
    // redraw background based on type
    [self setNeedsDisplay:YES];
}

-(IBAction)teamChatOptionModified:(id)sender {
    if (sender == sendCompletionMessageToTeamChatCheckBox) {
        if (sendCompletionMessageToTeamChatCheckBox.state == NSOnState)
            _timerEntry._sendCompletionMessageToTeamChat = YES;
        else
            _timerEntry._sendCompletionMessageToTeamChat = NO;
    } else if (sender == sendWarningMessageToTeamChatCheckBox) {
        if (sendWarningMessageToTeamChatCheckBox.state == NSOnState)
            _timerEntry._sendWarningMessageToTeamChat = YES;
        else
            _timerEntry._sendWarningMessageToTeamChat = NO;
    }
}

- (void)shortcutRecorder:(SRRecorderControl *)aRecorder keyComboDidChange:(KeyCombo)newKeyCombo
{
	if (aRecorder == shortcutRecorder)
	{
        // unregister old hotkey
        if ((_timerEntry._globalHotKey.code != -1) && (_timerEntry._globalHotKey.flags != 0))
        {
            // unregister
            [NSEvent removeMonitor:timerWatcherGlobal];
            [NSEvent removeMonitor:timerWatcherLocal];
        }
		// register new global hotkey
        _timerEntry._globalHotKey = newKeyCombo;
        
        timerWatcherGlobal = [NSEvent addGlobalMonitorForEventsMatchingMask:NSKeyDownMask handler: ^(NSEvent *event) {
                NSUInteger flags = [event modifierFlags] & NSDeviceIndependentModifierFlagsMask;
            if (([event keyCode] == _timerEntry._globalHotKey.code) && (flags == _timerEntry._globalHotKey.flags)) {
                [self timerPressed];
            }
        }];
        
        //same for local
        timerWatcherLocal = [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask handler: ^(NSEvent *event) {
            NSUInteger flags = [event modifierFlags] & NSDeviceIndependentModifierFlagsMask;
            if (([event keyCode] == _timerEntry._globalHotKey.code) && (flags == _timerEntry._globalHotKey.flags)) {
                [self timerPressed];
            }
            return event;
        }];
        
	}
}

-(void)timerPressed {
    if (!_timerEntry.isTimerRunning) {
        // start timer
        [_timerEntry startTimer];
        
        // tell the user that the timer has started
        [self say:[NSString stringWithFormat:@"Timer started for %@",_timerEntry._name]];
        
        AppDelegate* adelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
        [adelegate timerStarted:_timerEntry];
        
    } else {
        NSTimeInterval remaining = [_timerEntry getRemainingTime];
        [self say:[NSString stringWithFormat:@"%ld seconds remaining for %@",(long)remaining,_timerEntry._name]];
    }
}

-(void)mainTimerFinished {
    _timerEntry.isTimerRunning = NO;
    if (_timerEntry._type == LT_WARD)
        [self say:[NSString stringWithFormat:@"%@ has expired",_timerEntry._name]];
    else
        [self say:[NSString stringWithFormat:@"%@ has respawned",_timerEntry._name]];
    
    // send keystrokes
    if (_timerEntry._sendCompletionMessageToTeamChat) {
        if (_timerEntry._type == LT_WARD)
            [self sendKeystrokes:[NSString stringWithFormat:@"%@ has expired!",_timerEntry._name]];
        else
            [self sendKeystrokes:[NSString stringWithFormat:@"%@ has respawned!",_timerEntry._name]];
        
    }
    
    AppDelegate* adelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    [adelegate timerStopped:_timerEntry];
}

-(void)warningTimerFinished {
    if (_timerEntry._type == LT_WARD)
        [self say:[NSString stringWithFormat:@"%@ will expire in %ld seconds!",_timerEntry._name,(long)_timerEntry._warningLength]];
    else
        [self say:[NSString stringWithFormat:@"%@ will respawn in %ld seconds!",_timerEntry._name,(long)_timerEntry._warningLength]];
    
    // send keystrokes
    if (_timerEntry._sendWarningMessageToTeamChat) {
        if (_timerEntry._type == LT_WARD)
            [self sendKeystrokes:[NSString stringWithFormat:@"%@ will expire in %ld seconds!",_timerEntry._name,(long)_timerEntry._warningLength]];
        else
            [self sendKeystrokes:[NSString stringWithFormat:@"%@ will respawn in %ld seconds!",_timerEntry._name,(long)_timerEntry._warningLength]];
        
    }
}

-(void) say:(NSString*)text {
    // get app delegate
    AppDelegate* adelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    [adelegate say:text];
}

-(void) sendKeystrokes:(NSString*)text {
    // send keystrokes
    NSString* textToWrite = [NSString stringWithFormat:@"\
                             if application \"League Of Legends\" is running then\n\
                             tell application \"System Events\"\n\
                             tell process \"League Of Legends\"\n\
                             keystroke return\n\
                             keystroke \"%@\"\n\
                             keystroke return\n\
                             end tell\n\
                             end tell\n\
                             end if",text];
    NSAppleScript* scriptObject = [[NSAppleScript alloc] initWithSource:textToWrite];
    NSDictionary *error = nil;
    [scriptObject executeAndReturnError:&error];
}

-(IBAction)stopTimer:(id)sender {
    // stops the current timer
    [_timerEntry stopTimer];
    
    AppDelegate* adelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    [adelegate timerStopped:_timerEntry];
}

-(void)setTimeForTextField:(NSString*)time {
    timerTextField.stringValue = time;
}

@end
