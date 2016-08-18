//
//  SFYAppDelegate.m
//  Statusfy
//
//  Created by Paul Young on 4/16/14.
//  Copyright (c) 2014 Paul Young. All rights reserved.
//

#import "SFYAppDelegate.h"


static NSString * const SFYPlayerStatePreferenceKey = @"ShowPlayerState";
static NSString * const SFYPlayerDockIconPreferenceKey = @"YES";

@interface SFYAppDelegate ()

@property (nonatomic, strong) NSMenuItem *playerStateMenuItem;
@property (nonatomic, strong) NSMenuItem *dockIconMenuItem;
@property (nonatomic, strong) NSMenuItem *lastTenStatuses;
@property (nonatomic, strong) NSStatusItem *statusItem;
@property (nonatomic, strong) NSMutableArray *statuses;

@end

@implementation SFYAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification * __unused)aNotification
{
    //Initialize the variable the getDockIconVisibility method checks
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SFYPlayerDockIconPreferenceKey];

    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.highlightMode = YES;
    self.statuses = [NSMutableArray array];

    NSMenu *menu = [[NSMenu alloc] initWithTitle:@""];

    self.playerStateMenuItem = [[NSMenuItem alloc] initWithTitle:[self determinePlayerStateMenuItemTitle] action:@selector(togglePlayerStateVisibility) keyEquivalent:@""];

    self.dockIconMenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Hide Dock Icon", nil) action:@selector(toggleDockIconVisibility) keyEquivalent:@""];

    self.lastTenStatuses = [[NSMenuItem alloc]
                             initWithTitle: NSLocalizedString(@"Last 10 Tracks", nil)
                             action: nil
                             keyEquivalent:@""];

    [menu addItem:self.playerStateMenuItem];
    [menu addItem:self.dockIconMenuItem];
    [menu addItem:self.lastTenStatuses];
    [menu addItemWithTitle:NSLocalizedString(@"Quit", nil) action:@selector(quit) keyEquivalent:@"q"];

    [self.statusItem setMenu:menu];

    [self updateStatuses];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateStatuses) userInfo:nil repeats:YES];
}

#pragma mark - Setting title text

- (void)updateStatuses
{
    NSString *trackName = [[self executeAppleScript:@"get name of current track"] stringValue];
    NSString *artistName = [[self executeAppleScript:@"get artist of current track"] stringValue];

    if (trackName && artistName) {
        NSString *titleText = [NSString stringWithFormat:@"%@ - %@", trackName, artistName];

        if ([self getPlayerStateVisibility]) {
            NSString *playerState = [self determinePlayerStateText];
            titleText = [NSString stringWithFormat:@"%@ (%@)", titleText, playerState];
        }

        self.statusItem.image = nil;
        self.statusItem.title = titleText;

        // Add if first run
        if (self.statuses.count == 0) {
            [self.statuses addObject:titleText];
        }

        // If later rounds, skip if duplicate
        if (![[self.statuses lastObject] isEqualToString: titleText]) {
            [self.statuses addObject:titleText];
        }

        // Clean up if over 10
        if (self.statuses.count > 10) {
            [self.statuses removeObjectAtIndex: 0];
        }

        // Populate submenu
        NSMenu *lastTenSubmenu = [[NSMenu alloc] init];

        for (id statuss in [[self.statuses reverseObjectEnumerator] allObjects]) {
            [lastTenSubmenu addItemWithTitle:statuss action:@selector(self) keyEquivalent:@""];
        }

        [self.lastTenStatuses setSubmenu:lastTenSubmenu];
    } else {
        NSImage *image = [NSImage imageNamed:@"status_icon"];
        [image setTemplate:true];
        self.statusItem.image = image;
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
    self.playerStateMenuItem.title = [self determinePlayerStateMenuItemTitle];
}

- (NSString *)determinePlayerStateMenuItemTitle
{
    return [self getPlayerStateVisibility] ? NSLocalizedString(@"Hide Player State", nil) : NSLocalizedString(@"Show Player State", nil);
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

#pragma mark - Toggle Dock Icon

- (BOOL)getDockIconVisibility
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:SFYPlayerDockIconPreferenceKey];
}

- (void)setDockIconVisibility:(BOOL)visible
{
   [[NSUserDefaults standardUserDefaults] setBool:visible forKey:SFYPlayerDockIconPreferenceKey];
}

- (void)toggleDockIconVisibility
{
    [self setDockIconVisibility:![self getDockIconVisibility]];
    self.dockIconMenuItem.title = [self determineDockIconMenuItemTitle];

    if(![self getDockIconVisibility])
    {
        //Apple recommended method to show and hide dock icon
        //hide icon
        [NSApp setActivationPolicy: NSApplicationActivationPolicyAccessory];
    }
    else
    {
        //show icon
        [NSApp setActivationPolicy: NSApplicationActivationPolicyRegular];
    }
}

- (NSString *)determineDockIconMenuItemTitle
{
    return [self getDockIconVisibility] ? NSLocalizedString(@"Hide Dock Icon", nil) : NSLocalizedString(@"Show Dock Icon", nil);
}

#pragma mark - Quit

- (void)quit
{
    [[NSApplication sharedApplication] terminate:self];
}

@end
