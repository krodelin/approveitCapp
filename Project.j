/*
 * Project.j
 * approveitCapp
 *
 * Created by Udo Schneider on January 21, 2015.
 * Copyright 2015, Krodelin Software Solutions All rights reserved.
 */

@import "Ratatosk/Ratatosk.j"
@import "RemoteObject.j"
@import "User.j"

@implementation Project : RemoteObject
{
    CPString title @accessors;
    CPString notes @accessors;
    CPArray requests @accessors;
}

+ (BOOL)automaticallyLoadsRemoteObjectsForRequests
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
        title = @"New Project";
        notes = @"Notes";
    }
    return self;
}

@end

@implementation Request : RemoteObject
{
    CPString title @accessors;
    CPString notes @accessors;
    Project project @accessors;
    User requester @accessors;
    User requestee @accessors;
}



+ (BOOL)automaticallyLoadsRemoteObjectsForProject
{
    return YES;
}

+ (CPString)remoteName
{
    return @"requests"
}

- (id)init
{
    if (self = [super init])
    {
        title = @"New Request";
        notes = @"Notes";
        requester = [User current];
        requestee = [User current];
    }
    return self;
}

@end

@implementation Project (RemoteProperties)

+ (CPArray)remoteProperties
{
    return [
        ['pk', 'url'],
        ['title', 'title'],
        ['notes', 'notes'],
        ['requests', 'requests', [WLForeignObjectsByIdsTransformer forObjectClass:Request]]
    ];
}

@end

@implementation Request (RemoteProperties)

+ (CPArray)remoteProperties
{
    return [
        ['pk', 'url'],
        ['title', 'title'],
        ['notes', 'notes'],
        ['project', 'project', [WLForeignObjectByIdTransformer forObjectClass:Project]],
        ['requester', 'requester', [WLForeignObjectByIdTransformer forObjectClass:Request]],
        ['requestee', 'requestee', [WLForeignObjectByIdTransformer forObjectClass:Request]]
    ];
}

@end



