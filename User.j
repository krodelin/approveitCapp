/*
 * User.j
 * approveitCapp
 *
 * Created by Udo Schneider on January 21, 2015.
 * Copyright 2015, Krodelin Software Solutions All rights reserved.
 */

@import "Ratatosk/Ratatosk.j"
@import "RemoteObject.j"

@implementation User : RemoteObject
{
    CPString username @accessors;
    CPString email @accessors;
    CPString manager @accessors;
    CPString password @accessors;
    User manager @accessors;
}

+ (CPArray)remoteProperties
{
    return [
        ['pk', 'url'],
        ['username', 'username'],
        ['email', 'email'],
        ['password', 'password'],
        ['manager', 'manager', [WLForeignObjectByIdTransformer forObjectClass:User]]
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

- (id)init
{
    if (self = [super init])
    {
        [self setUsername:@"user"];
        [self setPassword:@"password"];
        [self setEmail:@"user@domain.net"];
    }
    return self;
}

- (CPString)usernameAndEmail
{
    return [self username] + @" <" + [self email] + @">"
}

#pragma mark -
#pragma mark WLRemoteLink delegates

- (void)remoteActionDidFail:(WLRemoteAction)action
{
    debugger;
}

@end
