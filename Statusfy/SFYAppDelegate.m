//
//  SFYAppDelegate.m
//  Statusfy
//
//  Created by Paul Young on 4/16/14.
//  Copyright (c) 2014 Paul Young. All rights reserved.
//

#import "SFYAppDelegate.h"


@interface SFYAppDelegate ()

@property (nonatomic, strong) NSStatusItem *statusItem;

@end


@implementation SFYAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification * __unused)aNotification
{
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.highlightMode = YES;
    
    [self setStatusItemTitle];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(setStatusItemTitle) userInfo:nil repeats:YES];
    
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@""];
    [menu addItemWithTitle:NSLocalizedString(@"Quit", nil) action:@selector(quit) keyEquivalent:@"q"];
    [self.statusItem setMenu:menu];
}

- (void)setStatusItemTitle
{
    NSString *titleText = NSLocalizedString(@"Statusfy (Spotify not running)", nil);
    
    NSAppleScript *runningScript = [[NSAppleScript alloc] initWithSource:@"get running of application \"Spotify\""];
    NSDictionary *runningError;
    BOOL running = [[runningScript executeAndReturnError:&runningError] booleanValue];
    
    if (running) {
        NSString *trackName = [[self executeApplescript:@"get name of current track"] stringValue];
        NSString *artistName = [[self executeApplescript:@"get artist of current track"] stringValue];
        
        NSString *playerStateConstant = [[self executeApplescript:@"get player state"] stringValue];
        NSString *playerState = nil;
        
        if ([playerStateConstant isEqualToString:@"kPSP"]) {
            playerState = NSLocalizedString(@"Playing", nil);
        }
        else if ([playerStateConstant isEqualToString:@"kPSp"]) {
            playerState = NSLocalizedString(@"Paused", nil);
        }
        else {
            playerState = NSLocalizedString(@"Stopped", nil);
        }
        
        if (trackName && artistName) {
            titleText = [NSString stringWithFormat:@"%@ - %@ (%@)", trackName, artistName, playerState];
        }
    }
    
    self.statusItem.title = titleText;
}

- (NSAppleEventDescriptor *)executeApplescript:(NSString *)command
{
    command = [NSString stringWithFormat:@"if application \"Spotify\" is running then tell application \"Spotify\" to %@", command];
    NSAppleScript *applescript = [[NSAppleScript alloc] initWithSource:command];
    NSAppleEventDescriptor *eventDescriptor = [applescript executeAndReturnError:NULL];
    return eventDescriptor;
}

- (void)quit
{
    [[NSApplication sharedApplication] terminate:self];
}

@end
