/*
 * RemoteObject.j
 * approveitCapp
 *
 * Created by Udo Schneider on January 21, 2015.
 * Copyright 2015, Krodelin Software Solutions All rights reserved.
 */

@import "Ratatosk/Ratatosk.j"

@implementation RemoteObject : WLRemoteObject
{
}

- (CPString)remotePath
{
    if ([self pk])
    {
        return [self pk];
    }
    else
    {
        return [self remoteName] + @"/";
    }
}

+ (void)fetchAll:(id)delegate
{
    var remoteName = [self remoteName];
    [WLRemoteAction schedule:WLRemoteActionGetType path:remoteName delegate:delegate message:(@"Loading all " + remoteName)];
}

@end
