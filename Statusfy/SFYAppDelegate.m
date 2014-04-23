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
        NSAppleScript *trackNameScript = [[NSAppleScript alloc] initWithSource:@"if application \"Spotify\" is running then tell application \"Spotify\" to get name of current track"];
        NSDictionary *trackNameError;
        NSString *trackName = [[trackNameScript executeAndReturnError:&trackNameError] stringValue];
        
        NSAppleScript *artistNameScript = [[NSAppleScript alloc] initWithSource:@"if application \"Spotify\" is running then tell application \"Spotify\" to get artist of current track"];
        NSDictionary *artistNameError;
        NSString *artistName = [[artistNameScript executeAndReturnError:&artistNameError] stringValue];
        
        NSAppleScript *playerStateScript = [[NSAppleScript alloc] initWithSource:@"if application \"Spotify\" is running then tell application \"Spotify\" to get player state"];
        NSDictionary *playerStateError;
        NSString *playerStateConstant = [[playerStateScript executeAndReturnError:&playerStateError] stringValue];
        
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

- (void)quit
{
    [[NSApplication sharedApplication] terminate:self];
}

@end
