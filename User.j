/*
 * User.j
 * approveitCapp
 *
 * Created by Udo Schneider on January 21, 2015.
 * Copyright 2015, Krodelin Software Solutions All rights reserved.
 */

@import "Ratatosk/Ratatosk.j"

@implementation User : WLRemoteObject
{
    CPString username @accessors;
    CPString email @accessors;
    CPString manager @accessors;
}

+ (CPArray)remoteProperties
{
    return [
        ['pk', 'url'],
        ['username', 'username'],
        ['email', 'email'],
        ['manager', 'manager']
    ];
}

+ (BOOL)automaticallyLoadsRemoteObjectsForUser
{
    return YES;
}

+ (CPString)remoteName
{
    return @"users"
}

@end
