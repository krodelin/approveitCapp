/*
 * AppController.j
 * approveitCapp
 *
 * Created by Udo Schneider on January 21, 2015.
 * Copyright 2015, Krodelin Software Solutions All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@import "UserSessionManager.j"

@import "UserController.j"
@import "ProjectController.j"

var LogoutTimeout = 10,
    LogoutCountdownMessage = @"If you do nothing, you will be logged out automatically in %@ seconds.";


@implementation AppController : CPObject
{
    @outlet CPWindow    theWindow;
    @outlet CPOutlineView   _outlineView;
    @outlet CPView  _contentView;
    CPViewController _activeController;
    CPDictionary    _sources    @accessors(property=sources);
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _sources = @{@"GENERAL":@[
                // [[StatusController alloc] initWithCibName:@"StatusView" bundle:nil],
                [[ProjectController alloc] initWithCibName:@"ProjectsView" bundle:nil]
            ], @"ADMIN":@[
                [[UserController alloc] initWithCibName:@"UsersView" bundle:nil]
            ]};
    }
    return self;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    // This is called when the application is done loading.
    // [self setPlatformTitle:@""];
    [self selectItem:[[_sources objectForKey:@"GENERAL"] objectAtIndex:0]];
    // [[SCUserSessionManager defaultManager] setLoginProvider:[LoginController defaultController]]
}

- (void)awakeFromCib
{
    // This is called when the cib is done loading.
    // You can implement this method on any object instantiated from a Cib.
    // It's a useful hook for setting up current UI values, and other things.

    // In this case, we want the window from Cib to become our full browser window
    [theWindow setFullPlatformWindow:YES];
    [WLRemoteLink setDefaultBaseURL:@"/"];
    var sharedRemoteLink = [WLRemoteLink sharedRemoteLink];
    [sharedRemoteLink setSaveActionType:WLRemoteActionPutType];
    [sharedRemoteLink setDelegate:self];
    // [[WLRemoteLink sharedRemoteLink] setSaveActionType:WLRemoteActionPatchType];

    [_outlineView expandItem:nil expandChildren:YES];
}

- (void)selectItem:(id)item
{
    var itemIndex = [_outlineView rowForItem:item];
    if (itemIndex < 0)
    {
        [_outlineView expandParentsOfItem: item];
        itemIndex = [_outlineView rowForItem:item];
        if (itemIndex < 0)
            return;
    }

    [_outlineView selectRowIndexes: [CPIndexSet indexSetWithIndex: itemIndex] byExtendingSelection: NO];
}


- (@action)debug:(id)sender
{
    [_activeController debug];
}

#pragma mark - Outline view Data source

- (id)outlineView:(CPOutlineView)outlineView child:(CPInteger)index ofItem:(id)item
{
    if (item == nil)
    {
        return [[_sources allKeys] objectAtIndex:index];
    }
    return [[_sources objectForKey:item] objectAtIndex:index];
}
- (BOOL)outlineView:(CPOutlineView)outlineView isItemExpandable:(id)item
{
    return [self outlineView:outlineView numberOfChildrenOfItem:item] > 0 ? YES : NO;
}
- (int)outlineView:(CPOutlineView)outlineView numberOfChildrenOfItem:(id)item
{
    if (item == nil)
    {
        return [[_sources allKeys] count];
    }
    return [_sources objectForKey:item] == nil ? 0 : [[_sources objectForKey:item] count];
}

- (id)outlineView:(CPOutlineView)outlineView objectValueForTableColumn:(CPTableColumn)tableColumn byItem:(id)item
{
    return item;
}

#pragma mark - Outline view Delegate

- (id)outlineView:(id)outlineView viewForTableColumn:(id)tableColumn item:(id)item
{
    var tableCellView;
    if ([_sources objectForKey:item] == nil)
    {
        tableCellView = [outlineView makeViewWithIdentifier:@"DataCell" owner:self];
        [[tableCellView textField] setStringValue:[item sourceListDescription]];
        [[tableCellView imageView] setImage:[item sourceListImage]];
    } else {
        tableCellView = [outlineView makeViewWithIdentifier:@"HeaderCell" owner:self];
        [[tableCellView textField] setStringValue:item];
    }
    return tableCellView;
}

- (BOOL)outlineView:(CPOutlineView)outlineView shouldSelectItem:(id)item
{
    return ([_sources objectForKey:item] == nil);
}

- (BOOL)outlineView:(CPOutlineView)outlineView shouldCollapseItem:(id)item
{
    return NO;
}

- (void)outlineViewSelectionDidChange:(CPNotification)notification
{
    var newController = [_outlineView itemAtRow:[_outlineView selectedRow]];

    if (!newController)
        return;

    if ([newController isEqual:_activeController])
        return;

    [self willChangeValueForKey:@"mainContentController"];
    [[_activeController view] setHidden:YES];

    [[newController view] setFrame:[_contentView bounds]];
    [_contentView addSubview:[newController view]];
    [[newController view] setHidden:NO];
    [self setPlatformTitle:[newController sourceListDescription]];
    // debugger;
    // [_searchField setStringValue:@""];
    // [_searchField performCLick:self];
    // [_searchField setNeedsDisplay:YES];
    _activeController = newController;
    [self didChangeValueForKey:@"mainContentController"];
}

#pragma mark -
#pragma mark WLRemoteLink delegates

- (void)remoteLink:(WLRemoteLink)remoteLink willSendRequest:(CPURLRequest)aRequest withDelegate:(id)aDelegate context:(id)aContext
{
    var cookie = [[CPCookie alloc] initWithName: @"csrftoken"],
        csrfToken = [cookie value],
        authenticationToken = [[UserSessionManager defaultManager] authenticationToken];

    CPLog.debug("CSRF-Token: " + csrfToken);
    CPLog.debug("Auth-Token: "  + authenticationToken);
    [aRequest setValue:csrfToken forHTTPHeaderField:@"X-CSRFToken"];
    if (authenticationToken)
        [aRequest setValue:"Token " + authenticationToken forHTTPHeaderField:@"Authorization"];
}

#pragma mark -
#pragma mark Helper methods

- (CPViewController)mainContentController
{
    return _activeController;
}

- (void)setPlatformTitle:(CPString)title
{
    if (![title isEqualToString:@""])
    {
        document.title = "Approve It!";
        // return;
    }

    document.title = "Approve It! - " + title;
}

- (@action)logout:(id)sender
{
    var alert = [[CPAlert alloc] init];
    [alert addButtonWithTitle:@"Logout"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText: @"Are you sure you want to logout?"];
    [alert setInformativeText:[CPString stringWithFormat:LogoutCountdownMessage,LogoutTimeout]];
    [alert setIcon:CPImageInBundle(@"lock_24x24.png")];

    var myTimer = [CPTimer timerWithTimeInterval: 1 target:self selector: @selector(killLogoutAlert:) userInfo:@{@"count":0,@"alert":alert} repeats:YES];

    [[CPRunLoop currentRunLoop] addTimer:myTimer forMode:CPDefaultRunLoopMode];

     [alert runModalWithDidEndBlock:(function(/*CPAlert*/alert, /*CPInteger*/returnCode){
        [myTimer invalidate];
        [self logoutAlert:alert didReturn:returnCode];
    })];
}

- (void)killLogoutAlert:(CPTimer)theTimer
{
    var alert = [[theTimer userInfo] objectForKey:@"alert"],
        count = [[theTimer userInfo] objectForKey:@"count"];
    [[theTimer userInfo] setObject:(count + 1) forKey:@"count"];
   [alert setInformativeText:[CPString stringWithFormat:LogoutCountdownMessage,(LogoutTimeout - count)]];
    if (count > LogoutTimeout)
    {
        [theTimer invalidate];
        [alert _takeReturnCodeFrom:[[alert buttons] objectAtIndex:1]];
    }
}

- (void)logoutAlert:(CPAlert)alert didReturn:(CPInteger)returnCode
{
    switch (returnCode)
    {
        case 0:
            [[UserSessionManager defaultManager] logout:self];
            break;
        case 1:
            break;
    }
}

#pragma mark - UserSessionManager delegates

- (void)logoutDidSucceed:(UserManager)userManager
{
    window.location.href = ([[CPBundle mainBundle] objectForInfoDictionaryKey:@"LogoutURL"] || @"http://www.google.com/");
}

- (void)logoutDidFail:(UserManager)userManager
{
}

#pragma mark -
#pragma mark CPSplitView delegate

- (float)splitView:(CPSplitView)aSplitView constrainMinCoordinate:(float)proposedMin ofSubviewAt:(int)dividerIndex
{
    return 160;
}

- (float)splitView:(CPSplitView)aSplitView constrainMaxCoordinate:(float)proposedMax ofSubviewAt:(int)dividerIndex
{
    return 200;
}

- (BOOL)splitView:(CPSplitView)aSplitView canCollapseSubview:(CPView)aSubview
{
    return YES;
    // return [aSubview isEqual:[_outlineView superView]];
}

- (BOOL)splitView:(CPSplitView)aSplitView shouldCollapseSubview:(CPView)aSubview forDoubleClickOnDividerAtIndex:(int)indexOfDivider
{
    return [_outlineView isDescendantOf:aSubview];
}

@end
