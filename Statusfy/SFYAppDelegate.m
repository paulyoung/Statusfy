//
//  SFYAppDelegate.m
//  Statusfy
//
//  Created by Paul Young on 4/16/14.
//  Copyright (c) 2014 Paul Young. All rights reserved.
//

#import "SFYAppDelegate.h"


static NSString * const SFYPlayerStatePreferenceKey = @"ShowPlayerState";
static NSString * const SFYHideIfStoppedPreferenceKey = @"HideIfStopped";


@interface SFYAppDelegate ()

@property (nonatomic, strong) NSMenuItem *playerStateMenuItem;
@property (nonatomic, strong) NSMenuItem *hideIfStoppedMenuItem;
@property (nonatomic, strong) NSStatusItem *statusItem;

@end


@implementation SFYAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification * __unused)aNotification
{
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.highlightMode = YES;
    
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@""];
    
    self.playerStateMenuItem = [[NSMenuItem alloc] initWithTitle:@"Hide player state" action:@selector(togglePlayerStateVisibility) keyEquivalent:@""];
    self.hideIfStoppedMenuItem = [[NSMenuItem alloc] initWithTitle:@"Hide if stopped" action:@selector(toggleHideIfStoppedVisibility) keyEquivalent:@""];
    [self setMenuItemCheck:self.playerStateMenuItem withValue:![self getPlayerStateVisibility]];
    [self setMenuItemCheck:self.hideIfStoppedMenuItem withValue:[self getHideIfStopped]];
    
    [menu addItem:self.playerStateMenuItem];
    [menu addItem:self.hideIfStoppedMenuItem];
    [menu addItemWithTitle:NSLocalizedString(@"Quit", nil) action:@selector(quit) keyEquivalent:@"q"];

    [self.statusItem setMenu:menu];
    
    [self setStatusItemTitle];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(setStatusItemTitle) userInfo:nil repeats:YES];
}


#pragma mark - Setting title text

- (void)setStatusItemTitle
{
    NSString *trackName = [[self executeAppleScript:@"get name of current track"] stringValue];
    NSString *artistName = [[self executeAppleScript:@"get artist of current track"] stringValue];
    NSString *playerState = [self determinePlayerStateText];
    BOOL shouldHide = [self getHideIfStopped] && ![playerState isEqualToString:@"Playing"];
    
    if (trackName && artistName && !shouldHide) {
        NSString *titleText = [NSString stringWithFormat:@"%@ - %@", trackName, artistName];
        
        if ([self getPlayerStateVisibility]) {
            titleText = [NSString stringWithFormat:@"%@ (%@)", titleText, playerState];
        }
        
        self.statusItem.image = nil;
        self.statusItem.title = titleText;
    }
    else {
        self.statusItem.image = [NSImage imageNamed:@"status_icon"];
        self.statusItem.title = nil;
    }
}


#pragma mark - Executing AppleScript

- (NSAppleEventDescriptor *)executeAppleScript:(NSString *)command
{
    command = [NSString stringWithFormat:@"if application \"Spotify\" is running then tell application \"Spotify\" to %@", command];
    NSAppleScript *appleScript = [[NSAppleScript alloc] initWithSource:command];
    NSAppleEventDescriptor *eventDescriptor = [appleScript executeAndReturnError:NULL];
    return eventDescriptor;
}


#pragma mark - Player state

- (BOOL)getPlayerStateVisibility
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:SFYPlayerStatePreferenceKey];
}

- (void)setPlayerStateVisibility:(BOOL)visible
{
    [[NSUserDefaults standardUserDefaults] setBool:visible forKey:SFYPlayerStatePreferenceKey];
}

- (void)togglePlayerStateVisibility
{
    [self setPlayerStateVisibility:![self getPlayerStateVisibility]];
    [self setMenuItemCheck:self.playerStateMenuItem withValue:![self getPlayerStateVisibility]];
}

- (NSString *)determinePlayerStateText
{
    NSString *playerStateText = nil;
    NSString *playerStateConstant = [[self executeAppleScript:@"get player state"] stringValue];
    
    if ([playerStateConstant isEqualToString:@"kPSP"]) {
        playerStateText = NSLocalizedString(@"Playing", nil);
    }
    else if ([playerStateConstant isEqualToString:@"kPSp"]) {
        playerStateText = NSLocalizedString(@"Paused", nil);
    }
    else {
        playerStateText = NSLocalizedString(@"Stopped", nil);
    }
    
    return playerStateText;
}

#pragma mark - Hide if stopped
- (BOOL)getHideIfStopped
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:SFYHideIfStoppedPreferenceKey];
}

- (void)setHideIfStopped:(BOOL)hide
{
    [[NSUserDefaults standardUserDefaults] setBool:hide forKey:SFYHideIfStoppedPreferenceKey];
}

- (void)toggleHideIfStoppedVisibility
{
    [self setHideIfStopped:![self getHideIfStopped]];
    [self setMenuItemCheck:self.hideIfStoppedMenuItem withValue:[self getHideIfStopped]];
}

- (void)setMenuItemCheck:(NSMenuItem *)item withValue: (BOOL)value
{
    if(value) {
        [item setState:NSOnState];
    } else {
        [item setState:NSOffState];
    }
}

#pragma mark - Quit

- (void)quit
{
    [[NSApplication sharedApplication] terminate:self];
}

@end
