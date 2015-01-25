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
    CPString status @accessors;
    CPArray possibleActions @accessors(readonly);
    CPArray allowedActions @accessors(readonly);
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

- (void)action:(CPString)actionName
{
    [WLRemoteAction schedule:WLRemoteActionPostType path:[self remotePath] + actionName + @"/" delegate:self message:actionName + @"Action"];
}

- (bool)allowed:(CPString)actionName
{
    return [allowedActions containsObject:actionName]
}

- (bool)possible:(CPString)actionName
{
    return [allowedActions containsObject:actionName]
}

- (void)approve
{
    [self action:@'approve'];
}

- (bool)isApproveAllowed
{
    return [self allowed:@'approve'];
}

- (bool)isApprovePossible
{
    return [self possible:@'approve'];
}

- (void)reject
{
    [self action:@'reject'];
}

- (bool)isRejectAllowed
{
    return [self allowed:@'reject'];
}

- (bool)isRejectPossible
{
    return [self possible:@'reject'];
}

- (void)request
{
    [self action:@'request'];
}

- (bool)isRequestAllowed
{
    return [self allowed:@'request'];
}

- (bool)isRequestPossible
{
    return [self possible:@'request'];
}

- (void)provide
{
    [self action:@'provide'];
}

- (bool)isProvideAllowed
{
    return [self allowed:@'provide'];
}

- (bool)isProvidePossible
{
    return [self possible:@'provide'];
}

- (void)finish
{
    [self action:@'finish'];
}

- (bool)isFinishAllowed
{
    return [self allowed:@'finish'];
}

- (bool)isFinishPossible
{
    return [self possible:@'finish'];
}

- (void)reopen
{
    [self action:@'reopen'];
}

- (bool)isReopenAllowed
{
    return [self allowed:@'reopen'];
}

- (bool)isReopenPossible
{
    return [self possible:@'reopen'];
}

+ (CPSet)keyPathsForValuesAffectingValueForKey:(CPString)key
{
    // CPLog.debug(@"keyPathsForValuesAffectingValueForKey:" + key);
    var keyPaths = [CPSet setWithSet:[super keyPathsForValuesAffectingValueForKey:key]];
    if ([key hasPrefix:@"is"] && [key hasSuffix:@"Allowed"])
    {
        [keyPaths addObjectsFromArray:[@"status", @"requester", @"requestee"]];
    }
    // CPLog.debug(keyPaths);
    return keyPaths;
}

#pragma mark -
#pragma mark WLAction delegate

- (void)remoteActionDidFinish:(WLRemoteAction)anAction
{
    [self willChangeValueForKey:@"status"];
    [self willChangeValueForKey:@"isApproveAllowed"];
    [self willChangeValueForKey:@"isRejectAllowed"];
    [self willChangeValueForKey:@"isRequestAllowed"];
    [self willChangeValueForKey:@"isProvideAllowed"];
    [self willChangeValueForKey:@"isFinishAllowed"];
    [self willChangeValueForKey:@"isReopenAllowed"];

    [super remoteActionDidFinish:anAction];
    var type = [anAction type];
    if (type == WLRemoteActionPostType || type == WLRemoteActionPutType || type == WLRemoteActionPatchType)
    {
        if ([[anAction message] hasSuffix:@"Action"])
        {
            [self updateFromJson:[anAction result]];
        }
    }
    [self didChangeValueForKey:@"status"];
    [self didChangeValueForKey:@"isApproveAllowed"];
    [self didChangeValueForKey:@"isRejectAllowed"];
    [self didChangeValueForKey:@"isRequestAllowed"];
    [self didChangeValueForKey:@"isProvideAllowed"];
    [self didChangeValueForKey:@"isFinishAllowed"];
    [self didChangeValueForKey:@"isReopenAllowed"];
}

- (bool)validateUserInterfaceItem:(id)item
{
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
        ['requester', 'requester', [WLForeignObjectByIdTransformer forObjectClass:User]],
        ['requestee', 'requestee', [WLForeignObjectByIdTransformer forObjectClass:User]],
        ['status', 'status'],
        ['possibleActions', 'possible_actions'],
        ['allowedActions', 'allowed_actions']
    ];
}

@end



