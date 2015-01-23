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


@implementation ProjectController : USViewController
{
    @outlet CPButtonBar _projectButtonBar;
    @outlet CPButtonBar _requestButtonBar;
    @outlet CPArrayController _requestArrayController;
    @outlet CPArrayController _usersController;
}

+ (class)objectClass
{
    return Project;
}

- (void)awakeFromCib
{
    [super awakeFromCib];

    [[[UserList alloc] init] fetchAll:self]

    var addButton = [CPButtonBar plusButton];
    [addButton setAction:@selector(addProject:)];
    [addButton setTarget:self];
    [addButton setEnabled:YES];

    var minusButton = [CPButtonBar minusButton];
    [minusButton setAction:@selector(removeProject:)];
    [minusButton setTarget:self];
    [minusButton setEnabled:YES];

    [_projectButtonBar setButtons:[addButton, minusButton]];
    [_projectButtonBar setHasResizeControl:NO];

    addButton = [CPButtonBar plusButton];
    [addButton setAction:@selector(addRequest:)];
    [addButton setTarget:self];
    [addButton setEnabled:YES];

    minusButton = [CPButtonBar minusButton];
    [minusButton setAction:@selector(removeRequest:)];
    [minusButton setTarget:self];
    [minusButton setEnabled:YES];

    [_requestButtonBar setButtons:[addButton, minusButton]];
    [_requestButtonBar setHasResizeControl:NO];
}


- (CPImage)sourceListImage
{
    return UIIcon(@"project", 16, 16);
}

- (CPString)sourceListDescription
{
    return @"Projects";
}

- (CPPredicate)defaultPredicate
{
    return [CPPredicate predicateWithFormat:@"title CONTAINS \"\""]
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

#pragma mark -
#pragma mark UserList delegate

- (void)userListRecievedUsers:users
{
    [_usersController addObjects:users];
}

@end
