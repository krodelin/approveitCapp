/*
 * UserSessionManager.j
 * approveitCapp
 *
 * Created by Udo Schneider on December 10, 2013.
 * Copyright 2013, Krodelin Software Solutions All rights reserved.
 */

@import <Foundation/CPObject.j>
@import <Foundation/CPURLConnection.j>
@import <Foundation/CPUserSessionManager.j>
@import "LoginController.j"

@import "User.j"

var DefaultSessionManager = nil;


@implementation UserSessionManager : CPUserSessionManager
{
    id              _loginDelegate;
    id              _loginProvider          @accessors(property=loginProvider);
    CPURLConnection _loginConnection;
    CPURLConnection _logoutConnection;
    CPString        _authenticationToken    @accessors(readonly,property=authenticationToken);
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [self setLoginProvider:[LoginController defaultController]];
    }
    return self;
}

+ (UserSessionManager)defaultManager
{
    if (!DefaultSessionManager)
        DefaultSessionManager = [[UserSessionManager alloc] init];
    return DefaultSessionManager;
}


- (void)logout:(id)delegate
{
    var request = [CPURLRequest requestWithURL:[[CPBundle mainBundle] objectForInfoDictionaryKey:@"AuthLogoutURL"] || @"/session/"];
    [request setHTTPMethod:@"DELETE"];

    _logoutConnection = [CPURLConnection connectionWithRequest:request delegate:self];
    _logoutConnection.delegate = delegate
}

- (void)login:(id)delegate
{
    // Login is already in progress
    if (_loginDelegate)
        return;

    _loginDelegate = delegate;
    [_loginProvider loginWithDelegate:self callback:@selector(_loginFinishedWithCode:)];
}

- (CPString)userDisplayName
{
    return [self userIdentifier];
}

- (void)_loginFinishedWithCode:(unsigned)returnCode
{
    var selectorToPerform;
    if (returnCode === LoginSucceeded)
    {
        _authenticationToken = [_loginProvider authenticationToken];
        selectorToPerform = @selector(loginDidSucceed:);
    }
    else
        selectorToPerform = @selector(loginDidFail:);

    if (selectorToPerform && _loginDelegate && [_loginDelegate respondsToSelector:selectorToPerform])
        [_loginDelegate performSelector:selectorToPerform withObject:self];

    _loginDelegate = nil;
}

- (void)connection:(CPURLConnection)aConnection didFailWithError:(CPException)anException
{
    var delegate = aConnection.delegate;
    if (aConnection === _logoutConnection)
        if (delegate && [delegate respondsToSelector:@selector(logoutDidFail:)])
            [delegate logoutDidFail:self];
}

- (void)connection:(CPURLConnection)aConnection didReceiveResponse:(CPURLResponse)aResponse
{
    var delegate = aConnection.delegate;
    if (![aResponse isKindOfClass:[CPHTTPURLResponse class]])
    {
        [aConnection cancel];
        if (aConnection === _logoutConnection)
            if (delegate && [delegate respondsToSelector:@selector(logoutDidFail:)])
                [delegate logoutDidFail:self];
        return;
    }

    var statusCode = [aResponse statusCode];

    if (statusCode !== 200)
        [aConnection cancel];

    if (aConnection === _logoutConnection)
    {
        [aConnection cancel];
        if (statusCode === 200)
        {
            [self setStatus:CPUserSessionLoggedInStatus];
            if (delegate && [delegate respondsToSelector:@selector(logoutDidSucceed:)])
                [delegate logoutDidSucceed:self];
        }
        else
            if (delegate && [delegate respondsToSelector:@selector(logoutDidFail:)])
                [delegate logoutDidFail:self];
    }
}

- (void)connection:(CPURLConnection)aConnection didReceiveData:(CPString)data
{
    if (!data)
        return;

    var responseBody = [data objectFromJSON],
        delegate = aConnection.delegate;

    if (delegate && [delegate respondsToSelector:@selector(sessionSyncDidSucceed:)])
        [delegate sessionSyncDidSucceed:self];
}

- (void)connectionDidReceiveAuthenticationChallenge:(CPURLConnection)aConnection
{
    _loginConnection = aConnection;
    [_loginConnection cancel];
    [self setStatus:CPUserSessionLoggedInStatus];
    [self login:self];
    if ([[_loginConnection delegate] respondsToSelector:@selector(sessionManagerDidInterceptAuthenticationChallenge:forConnection:)])
        [[_loginConnection delegate] sessionManagerDidInterceptAuthenticationChallenge:self forConnection:aConnection];

}

- (void)loginDidFail:(id)sender
{
    if ([[_loginConnection delegate] respondsToSelector:@selector(connectionDidFailAuthentication:)])
        [[_loginConnection delegate] connectionDidFailAuthentication:_loginConnection];
    _loginConnection = nil;
}

- (void)loginDidSucceed:(id)sender
{
    [_loginConnection._request._HTTPHeaderFields setObject:@"Token " + _authenticationToken forKey:@"Authorization"];
    [_loginConnection start];
    _loginConnection = nil;
    [User fetchCurrent];
}

@end

[CPURLConnection setClassDelegate:[UserSessionManager defaultManager]];
