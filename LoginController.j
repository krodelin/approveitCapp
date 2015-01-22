/*
 * AppController.j
 * approveitCapp
 *
 * Created by Udo Schneider on December 10, 2013.
 * Copyright 2013, Krodelin Software Solutions All rights reserved.
 */

@import <AppKit/AppKit.j>
@import "EKShakeAnimation.j"

var DefaultLoginDialogController    = nil,
    GenericErrorMessage             = @"Something went wrong. Check your internet connection and try again.";

LoginSucceeded = 0;
LoginFailed = 1;


@implementation LoginController : CPWindowController
{
    unsigned        _dialogReturnCode;
    CPString        _username                   @accessors(readonly, property=username);
    CPString        _authenticationToken        @accessors(readonly, property=authenticationToken);
    id              _delegate                   @accessors(property=delegate);
    SEL             _callback;
    id               _connectionClass;
    CPURLConnection _loginConnection;
    CPInteger       _loginConnectionResponseCode;
    CPString          _loginConnectionData;

    @outlet CPTextField     _userField                  @accessors(property=userField);
    @outlet CPTextField     _passwordField              @accessors(property=passwordField);
    @outlet CPButton        _loginButton                @accessors(property=loginButton);
    @outlet CPProgressIndicator     _progressSpinner            @accessors(property=progressSpinner);
    @outlet CPTextField     _errorMessage               @accessors(property=errorMessage);
}

- (void)awakeFromCib
{
    _connectionClass = CPURLConnection;

    [_window setDefaultButton:_loginButton];
    if (_window._windowView && _window._windowView._closeButton)
        [_window._windowView._closeButton setHidden:YES];

    [_progressSpinner stopAnimation:self];

    [[CPNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(_loginDialogClosed:)
               name:CPWindowWillCloseNotification
             object:_window];
}

- (void)_loginDialogClosed:(CPNotification)aNotification
{
    [CPApp stopModalWithCode:CPRunStoppedResponse];
    if (_delegate && [_delegate respondsToSelector:_callback])
        [_delegate performSelector:_callback withObject:_dialogReturnCode];
}

- (@action)cancel:(id)sender
{
    _dialogReturnCode = LoginFailed;
    [_window close];
}

- (@action)login:(id)sender
{
    [self _loginUser:[_userField stringValue] password:[_passwordField stringValue]];
    [_progressSpinner startAnimation:self];
    [_loginButton setEnabled:NO];
    [_errorMessage setStringValue:@""];
}


- (void)_loginUser:(CPString)username password:(CPString)password
{
    var loginObject     = {'username' : username, 'password' : password},
        request         = [CPURLRequest requestWithURL:[[CPBundle mainBundle] objectForInfoDictionaryKey:@"AuthLoginURL"] || @"/session/"];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[CPString JSONFromObject:loginObject]];

    _loginConnection = [_connectionClass connectionWithRequest:request delegate:self];
    _loginConnection.username = username;
}

- (void)loginWithDelegate:(id)aDelegate callback:(SEL)aCallback
{
    [_progressSpinner stopAnimation:self];
    [_loginButton setEnabled:YES];
    [_errorMessage setStringValue:@""];
    [CPApp runModalForWindow:[self window]];
    _username = nil;
    _delegate = aDelegate;
    _callback = aCallback;
    _dialogReturnCode = LoginFailed;
    [_passwordField setStringValue:""];
}

+ (LoginController)newLoginDialogController
{
    return [[self alloc] initWithWindowCibName:@"LoginWindow"];
}

+ (LoginController)defaultController
{
    if (!DefaultLoginDialogController)
        DefaultLoginDialogController = [self newLoginDialogController];
    return DefaultLoginDialogController;
}

- (void)_loginSucceededWithData:(JSObject)data
{
    _dialogReturnCode = LoginSucceeded;
    _username = data["username"];
    _authenticationToken = data["token"];
    [_window close];
}

- (void)_loginFailedWithData:(JSObject)data
{
    var errorMessageText = data[@"message"];
    if (!errorMessageText)
        errorMessageText = GenericErrorMessage;

    [[EKShakeAnimation alloc] initWithView:[self window]];
    [_progressSpinner stopAnimation:self];
    [_loginButton setEnabled:YES];
    [_errorMessage setHidden:NO];
    [_errorMessage setStringValue:errorMessageText];
    [_window makeFirstResponder:_passwordField];
    [_passwordField selectText:self];
}

- (void)connection:(CPURLConnection)aConnection didReceiveResponse:(CPURLResponse)aResponse
{
    if (aConnection === _loginConnection)
        _loginConnectionResponseCode = [aResponse statusCode];
}

- (void)connection:(CPURLConnection)aConnection didReceiveData:(CPString)data
{
    if (aConnection === _loginConnection)
    {
        if (!_loginConnectionData)
            _loginConnectionData = [CPString string];

        _loginConnectionData = [_loginConnectionData stringByAppendingString:data];
    }
}

- (void)connectionDidFinishLoading:(CPURLConnection)aConnection
{
    if (aConnection === _loginConnection)
    {
        try
        {
            var data = [_loginConnectionData objectFromJSON];
        }
        catch (e)
        {
            var data = {};
        }
        if (_loginConnectionResponseCode == 200)
            [self _loginSucceededWithData:data];
        if ((_loginConnectionResponseCode >= 400) && (_loginConnectionResponseCode < 500))
        {
            [self _loginFailedWithData:data];
        }
        [aConnection cancel];
        _loginConnection = nil;
        _loginConnectionResponseCode = nil;
        _loginConnectionData = nil;
    }
}

- (void)connection:(CPURLConnection)aConnection didFailWithError:(CPException)anException
{
    if (aConnection === _loginConnection)
    {
        [self _loginFailedWithData:GenericErrorMessage];
        [aConnection cancel];
        _loginConnection = nil;
        _loginConnectionResponseCode = nil;
        _loginConnectionData = nil;
    }
}

@end
