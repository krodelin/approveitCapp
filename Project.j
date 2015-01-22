/*
 * Project.j
 * approveitCapp
 *
 * Created by Udo Schneider on January 21, 2015.
 * Copyright 2015, Krodelin Software Solutions All rights reserved.
 */

@import "Ratatosk/Ratatosk.j"
@import "RemoteObject.j"

@implementation Project : RemoteObject
{
    CPString title @accessors;
    CPString notes @accessors;
}

+ (CPArray)remoteProperties
{
    return [
        ['pk', 'url'],
        ['title', 'title'],
        ['notes', 'notes']
    ];
}

+ (BOOL)automaticallyLoadsRemoteObjectsForUser
{
    return YES;
}

+ (CPString)remoteName
{
    return @"projects"
}

- (id)init
{
    if (self = [super init])
    {
        [self setTitle:@"New Project"];
        [self setNotes:@"Notes"];
    }
    return self;
}

@end
