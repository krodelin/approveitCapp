/*
 * ProjectController.j
 * approveitCapp
 *
 * Created by Udo Schneider on January 21, 2015.
 * Copyright 2015, Krodelin Software Solutions All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

// @import "WLArray.j"
@import "USViewController.j"
@import "Project.j"
@import "UIIcon.j"
@import "UserList.j"
@import "RequestGraphView.j"


@implementation ProjectController : USViewController
{
    @outlet CPButtonBar _projectButtonBar;
    @outlet CPButtonBar _requestButtonBar;
    @outlet CPArrayController _requestArrayController;
    @outlet CPArrayController _usersController;
    @outlet CPSplitView _projectsSplitView;
    @outlet CPSplitView _requestsSplitView;
    @outlet RequestGraphView _requestGraphView;
    @outlet     CPWindow              _projectPredicateEditorPanel;
                CPPredicate         _projectFilterPredicate @accessors(property=projectFilterPredicate);
    @outlet     CPWindow              _requestPredicateEditorPanel;
                CPPredicate         _requestFilterPredicate @accessors(property=requestFilterPredicate);
}

+ (class)objectClass
{
    return Project;
}

- (void)awakeFromCib
{
    [super awakeFromCib];

    [[[UserList alloc] init] fetchAll:self]

    var addButton = [self buttonWithImage:@"plus.png" action:@selector(addProject:)],
        minusButton = [self buttonWithImage:@"minus.png" action:@selector(removeProject:)],
        searchButton = [self buttonWithImage:@"funnel--pencil.png" action:@selector(showProjectPredicateEditor:)],
        resetButton = [self buttonWithImage:@"funnel--minus.png" action:@selector(resetProjectPredicate:)],
        historyButton = [self buttonWithImage:@"history.png" action:@selector(showProjectHistory:)];

    [_projectButtonBar setButtons:[addButton, minusButton, searchButton, resetButton, historyButton]];
    [_projectButtonBar setHasResizeControl:NO];

    var addButton = [self buttonWithImage:@"plus.png" action:@selector(addRequest:)],
        minusButton = [self buttonWithImage:@"minus.png" action:@selector(removeRequest:)],
        searchButton = [self buttonWithImage:@"funnel--pencil.png" action:@selector(showRequestPredicateEditor:)],
        resetButton = [self buttonWithImage:@"funnel--minus.png" action:@selector(resetRequestPredicate:)],
        historyButton = [self buttonWithImage:@"history.png" action:@selector(showRequestHistory:)];

    [_requestButtonBar setButtons:[addButton, minusButton, searchButton, resetButton, historyButton]];
    [_requestButtonBar setHasResizeControl:NO];


    [_requestGraphView bind:@"status" toObject:_requestArrayController withKeyPath:@"selection.status" options:nil];
}


- (CPImage)sourceListImage
{
    return UIIcon(@"project", 16, 16);
}

- (CPString)sourceListDescription
{
    return @"Projects";
}

- (@action)addProject:(id)sender
{
    var project = [[Project alloc] init];
    [_arrayController addObject:project];
    [project create];
}

- (@action)removeProject:(id)sender
{
    var project = [[_arrayController selectedObjects] objectAtIndex:0];
    [project delete];
    [_arrayController removeObject:project];
}

- (@action)addRequest:(id)sender
{
    var request = [[Request alloc] init],
        project = [[_arrayController selectedObjects] objectAtIndex:0];
    [request setProject: project];

    [_requestArrayController addObject:request];
    [request create];
}

- (@action)removeRequest:(id)sender
{
    var request = [[_requestArrayController selectedObjects] objectAtIndex:0];
    [request delete];
    [_requestArrayController removeObject:request];
}

- (@action)showProjectHistory:(id)sender
{

}




- (@action)showProjectPredicateEditor:(id)sender
{
    if (!_projectFilterPredicate)
        [self setProjectFilterPredicate:[self defaultProjectPredicate]];

    [CPApp beginSheet:_projectPredicateEditorPanel
       modalForWindow:[CPApp mainWindow]
        modalDelegate:self
       didEndSelector:nil
          contextInfo:nil];
}

- (@action)resetProjectPredicate:(id)sender
{
    [self setProjectFilterPredicate:nil];
}

- (@action)closeProjectPredicateEditor:(id)sender
{
    [CPApp endSheet:_projectPredicateEditorPanel];
    [_projectPredicateEditorPanel orderOut:sender];
}

- (CPPredicate)defaultProjectPredicate
{
    return [CPPredicate predicateWithFormat:@"title CONTAINS \"Project\""]
}


- (@action)showRequestPredicateEditor:(id)sender
{
    if (!_requestFilterPredicate)
        [self setRequestFilterPredicate:[self defaultRequestPredicate]];

    [CPApp beginSheet:_requestPredicateEditorPanel
       modalForWindow:[CPApp mainWindow]
        modalDelegate:self
       didEndSelector:nil
          contextInfo:nil];
}

- (@action)resetRequestPredicate:(id)sender
{
    [self setRequestFilterPredicate:nil];
}

- (@action)closeRequestPredicateEditor:(id)sender
{
    [CPApp endSheet:_requestPredicateEditorPanel];
    [_requestPredicateEditorPanel orderOut:sender];
}

- (CPPredicate)defaultRequestPredicate
{
    return [CPPredicate predicateWithFormat:@"title CONTAINS \"Request\""]
}

- (@action)showRequestHistory:(id)sender
{

}

#pragma mark -
#pragma mark UserList delegate

- (void)userListRecievedUsers:users
{
    [_usersController addObjects:users];
}

#pragma mark -
#pragma mark CPSplitView delegate

- (float)splitView:(CPSplitView)aSplitView constrainMinCoordinate:(float)proposedMin ofSubviewAt:(int)dividerIndex
{
    return proposedMin + 256;
}

- (float)splitView:(CPSplitView)aSplitView constrainMaxCoordinate:(float)proposedMax ofSubviewAt:(int)dividerIndex
{
    return proposedMax - 256;
}

@end
