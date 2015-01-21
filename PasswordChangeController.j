/*
 * PasswordChangeController.j
 * approveitCapp
 *
 * Created by Udo Schneider on January 21, 2015.
 * Copyright 2015, Krodelin Software Solutions All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@import "User.j"

@implementation PasswordChangeController : CPWindowController
{
    User    _user   @accessors(property=user);
    CPString    _password   @accessors(property=password);
    CPString    _confirm    @accessors(property=confirm);
    @outlet CPButton    _changeButton;
    @outlet CPButton    _cancelButton;
}

+ (CPSet)keyPathsForValuesAffectingCanChange
{
    return [CPSet setWithObjects:@"password", @"confirm", nil];
}

- (void)awakeFromCib
{
    [_window setDefaultButton:_changeButton];
}

- (@action)changePassword:(id)sender
{
    [_user setValue:_password forKeyPath:@"password"];
    [self closeSheet:self];
}

- (@action)cancel:(id)sender
{
    [self closeSheet:self];
}

- (@action)closeSheet:(id)sender
{
    [CPApp endSheet:[self window]];
    [[self window] orderOut:sender];
}

- (BOOL)canChange
{
    if ([_password length] == 0)
        return NO;
    return ([_password isEqualToString:_confirm]);
}

@end
