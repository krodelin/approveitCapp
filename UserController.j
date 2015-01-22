/*
 * UserController.j
 * approveitCapp
 *
 * Created by Udo Schneider on January 21, 2015.
 * Copyright 2015, Krodelin Software Solutions All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

// @import "WLArray.j"
@import "USViewController.j"
@import "User.j"
@import "UIIcon.j"

@import "PasswordChangeController.j"

@implementation UserController : USViewController
{
    @outlet CPButtonBar _buttonBar;
}

+ (class)objectClass
{
    return User;
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
    return UIIcon(@"user", 16, 16);
}

- (CPString)sourceListDescription
{
    return @"Users";
}

- (CPPredicate)defaultPredicate
{
    return [CPPredicate predicateWithFormat:@"fullName CONTAINS \"\""]
}

- (@action)changeUserPassword:(id)sender
{
    var passwordChangeController = [[PasswordChangeController alloc] initWithWindowCibName:@"PasswordChangePanel"];
    [passwordChangeController setUser:[_arrayController selection]];
    [CPApp beginSheet:[passwordChangeController window]
       modalForWindow:[CPApp mainWindow]
        modalDelegate:self
       didEndSelector:nil
          contextInfo:nil];
}

@end
