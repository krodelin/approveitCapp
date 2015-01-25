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
    @outlet     CPWindow              _predicateEditorPanel;
                CPPredicate         _filterPredicate @accessors(property=filterPredicate);
}

+ (class)objectClass
{
    return User;
}

- (void)awakeFromCib
{
    [super awakeFromCib];

    var addButton = [self buttonWithImage:@"plus.png" action:@selector(addObject:)],
        minusButton = [self buttonWithImage:@"minus.png" action:@selector(removeObject:)],
        searchButton = [self buttonWithImage:@"funnel--pencil.png" action:@selector(showPredicateEditor:)],
        resetButton = [self buttonWithImage:@"funnel--minus.png" action:@selector(resetPredicate:)];

    [_buttonBar setButtons:[addButton, minusButton, searchButton, resetButton]];
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

- (@action)showPredicateEditor:(id)sender
{
    if (!_filterPredicate)
        [self setFilterPredicate:[self defaultPredicate]];

    [CPApp beginSheet:_predicateEditorPanel
       modalForWindow:[CPApp mainWindow]
        modalDelegate:self
       didEndSelector:nil
          contextInfo:nil];
}

- (@action)resetPredicate:(id)sender
{
    [self setFilterPredicate:nil];
}

- (@action)closePredicateEditor:(id)sender
{
    [CPApp endSheet:_predicateEditorPanel];
    [_predicateEditorPanel orderOut:sender];
}

- (CPPredicate)defaultPredicate
{
    return [CPPredicate predicateWithFormat:@"email CONTAINS \"domain\""]
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

- (void)debug
{
    console.log([_arrayController selectedObjects]);
}

@end
