//
//  LTEntryCellView.h
//  LoLTimer
//
//  Created by Istvan Fehervari on 8/15/13.
//
//

#import <Cocoa/Cocoa.h>
#import "LTTimerEntry.h"
#import "LTNumberField.h"
#import <ShortcutRecorder/ShortcutRecorder.h>

@interface LTEntryCellView : NSTableCellView {
    IBOutlet NSTextField* timerTextField;// field that display the remaining time
    IBOutlet NSTextField* timerNameField;// field for timer name
    IBOutlet NSPopUpButton* typePopUp;
    IBOutlet LTNumberField* warningTextField;
    
    IBOutlet NSButton* sendCompletionMessageToTeamChatCheckBox;
    IBOutlet NSButton* sendWarningMessageToTeamChatCheckBox;
    
    IBOutlet NSButton* stopButton;
    
    IBOutlet SRRecorderControl* shortcutRecorder;
    
    // data source
    LTTimerEntry* _timerEntry;
    
    // keyboard bindings
    id timerWatcherLocal;
    id timerWatcherGlobal;
    
    NSPasteboard* pasteBoard;
    
}

@property (nonatomic, strong) LTTimerEntry* _timerEntry;

-(void) setTimerEntry:(LTTimerEntry *)timerEntry;
-(IBAction)typeHasChanged:(id)sender;
-(IBAction)teamChatOptionModified:(id)sender;
-(IBAction)stopTimer:(id)sender;
-(void)timerPressed;
-(void)mainTimerFinished;
-(void)warningTimerFinished;
-(void)setTimeForTextField:(NSString*)time;

@end
