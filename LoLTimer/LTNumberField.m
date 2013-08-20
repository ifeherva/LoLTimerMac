//
//  LTNumberField.m
//  LoLTimer
//
//  NSTextField that only allows numbers
//  Created by Istvan Fehervari on 8/15/13.
//
//

#import "LTNumberField.h"

@implementation LTNumberField

-(void) textDidEndEditing:(NSNotification *)aNotification {
	// replace content with its intValue
	[self setIntValue:[self intValue]];
	// make sure the notification is sent back to any delegate
	//[super controlTextDidEndEditing:aNotification];
}

@end
