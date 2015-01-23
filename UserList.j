/*
 * UserList.j
 * approveitCapp
 *
 * Created by Udo Schneider on January 21, 2015.
 * Copyright 2015, Krodelin Software Solutions All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "User.j"

@implementation UserList : CPObject
{
    id _delegate;
}

- (void)fetchAll:(id)aDelegate
{
    _delegate = aDelegate;
    [User fetchAll:self];
}

#pragma mark - WLAction delegate

- (void)remoteActionDidFinish:(WLRemoteAction)anAction
{
    var users = [User objectsFromJson:[anAction result]];
    [_delegate userListRecievedUsers:users];
}

@end
