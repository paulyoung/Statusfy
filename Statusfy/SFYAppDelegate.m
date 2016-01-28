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
static NSString * const SFYPlayerTrackTitlePreferenceKey = @"YES";

@interface SFYAppDelegate ()

@property (nonatomic, strong) NSMenuItem *playerStateMenuItem;
@property (nonatomic, strong) NSMenuItem *dockIconMenuItem;
@property (nonatomic, strong) NSMenuItem *trackTitleMenuItem;       // TOGGLE
@property (nonatomic, strong) NSMenuItem *trackInformationMenuItem; // SONG INFORMATION
@property (nonatomic, strong) NSStatusItem *statusItem;

@end

@implementation SFYAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification * __unused)aNotification
{
    //Initialize the variable the getDockIconVisibility method checks
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SFYPlayerDockIconPreferenceKey];
    
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.highlightMode = YES;
    
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@""];
    
    self.playerStateMenuItem = [[NSMenuItem alloc] initWithTitle:[self determinePlayerStateMenuItemTitle] action:@selector(togglePlayerStateVisibility) keyEquivalent:@""];
    
    self.dockIconMenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Hide Dock Icon", nil) action:@selector(toggleDockIconVisibility) keyEquivalent:@""];
    
    self.trackTitleMenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Hide Track Info in Bar", nil) action:@selector(toggleTrackTitleVisibility) keyEquivalent:@""];
    
    //[menu addItem:self.trackInformationMenuItem];
    [menu addItem:self.playerStateMenuItem];
    [menu addItem:self.dockIconMenuItem];
    [menu addItem:self.trackTitleMenuItem];
    [menu addItemWithTitle:NSLocalizedString(@"Quit", nil) action:@selector(quit) keyEquivalent:@"q"];

    [self.statusItem setMenu:menu];
    
    [self setStatusItemIcon];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(setStatusItemTitle) userInfo:nil repeats:YES];
}

#pragma mark - Setting statusItem icon
- (void)setStatusItemIcon
{
    NSImage *image = [NSImage imageNamed:@"status_icon"];
    [image setTemplate:true];
    self.statusItem.image = image;
    self.statusItem.title = nil;
}

#pragma mark - Setting statusItem title
- (void)setStatusItemTitle
{
    NSString *titleText = [self determineTrackTitle];
    if (titleText) {
        
        if ([self getPlayerStateVisibility]) {
            NSString *playerState = [self determinePlayerStateText];
            titleText = [NSString stringWithFormat:@"%@ (%@)", titleText, playerState];
        }
        if ([self getTrackTitleVisibility]){
            self.statusItem.image = nil;
            self.statusItem.title = titleText;
        }
        else {
            [self setStatusItemIcon];
            // here you could add a new cell with the track title information
            // if you wished (future)
        }
    }
    else {
        [self setStatusItemIcon];
    }

}

#pragma mark - Display title in menu bar BOOL
- (BOOL)getTrackTitleVisibility
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:SFYPlayerTrackTitlePreferenceKey];
}

- (NSString *)determineTrackTitle
{
    NSString *trackName = [[self executeAppleScript:@"get name of current track"] stringValue];
    NSString *artistName = [[self executeAppleScript:@"get artist of current track"] stringValue];
    if (trackName && artistName) {
        NSString *titleText = [NSString stringWithFormat:@"%@ - %@", trackName, artistName];
        return titleText;
    }
    return nil;
}

- (void)setTrackTitleVisibility:(BOOL)visible
{
    [[NSUserDefaults standardUserDefaults] setBool:visible forKey:SFYPlayerTrackTitlePreferenceKey];
}

- (void)toggleTrackTitleVisibility
{
    [self setTrackTitleVisibility:![self getTrackTitleVisibility]];
    self.trackTitleMenuItem.title = [self determineTrackTitleMenuItemTitle];
}

- (NSString *)determineTrackTitleMenuItemTitle
{
    return [self getTrackTitleVisibility] ? NSLocalizedString(@"Hide Track Info in Bar", nil) : NSLocalizedString(@"Show Track Info in Bar", nil);
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
