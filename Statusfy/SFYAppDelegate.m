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
    NSAppleScript *trackNameScript = [[NSAppleScript alloc] initWithSource:@"if application \"Spotify\" is running then tell application \"Spotify\" to get name of current track"];
    NSDictionary *trackNameError;
    NSString *trackName = [[trackNameScript executeAndReturnError:&trackNameError] stringValue];
    
    NSAppleScript *artistNameScript = [[NSAppleScript alloc] initWithSource:@"if application \"Spotify\" is running then tell application \"Spotify\" to get artist of current track"];
    NSDictionary *artistNameError;
    NSString *artistName = [[artistNameScript executeAndReturnError:&artistNameError] stringValue];
    
    NSString *titleText = NSLocalizedString(@"Statusfy", nil);
    
    if (trackName && artistName) {
        titleText = [NSString stringWithFormat:@"%@ - %@", trackName, artistName];
    }
    
    self.statusItem.title = titleText;
}

- (void)quit
{
    [[NSApplication sharedApplication] terminate:self];
}

@end
