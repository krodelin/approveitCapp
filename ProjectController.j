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

@import "PasswordChangeController.j"

@implementation ProjectController : USViewController
{
    @outlet CPButtonBar _buttonBar;
}

+ (class)objectClass
{
    return Project;
}

- (void)awakeFromCib
{
    [super awakeFromCib];
    var addButton = [CPButtonBar plusButton];
    [addButton setAction:@selector(addObject:)];
    [addButton setTarget:self];
    [addButton setEnabled:YES];

    var minusButton = [CPButtonBar minusButton];
    [minusButton setAction:@selector(removeObject:)];
    [minusButton setTarget:self];
    [minusButton setEnabled:YES];

    [_buttonBar setButtons:[addButton, minusButton]];
    [_buttonBar setHasResizeControl:NO];
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
    return [CPPredicate predicateWithFormat:@"fullName CONTAINS \"\""]
}

@end
