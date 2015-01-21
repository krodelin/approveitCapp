/*
 * USViewController.j
 * approveitCapp
 *
 * Created by Udo Schneider on January 21, 2015.
 * Copyright 2015, Krodelin Software Solutions All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@import "User.j"

// @import "WLArray.j"

@implementation USViewController : CPViewController
{
    // WLObjectController   _objectController;
    @outlet     CPArrayController   _arrayController;
    @outlet     CPView              _mainContentView;
    @outlet     CPView              _tableView;
    @outlet     CPView              _predicateEditorView;
                CPPredicate         _filterPredicate @accessors(property=filterPredicate);
    @outlet     CPWindow            _inspectorWindow;
}

+ (class)objectClass
{
    debugger;
}

- (void)awakeFromCib
{
    // This is called when the cib is done loading.
    // You can implement this method on any object instantiated from a Cib.
    // It's a useful hook for setting up current UI values, and other things.
    [_predicateEditorView setHidden:YES];
    [self layoutViews];

    [_arrayController addObserver:self forKeyPath:@"arrangedObjects" options:(CPKeyValueObservingOptionNew | CPKeyValueObservingOptionOld | CPKeyValueObservingOptionPrior) context:NULL];
    [_tableView setTarget:self];
    [_tableView setDoubleAction:@selector(showInspector:)];

    var remoteName = [[[self class] objectClass] remoteName];
    [WLRemoteAction schedule:WLRemoteActionGetType path:remoteName delegate:self message:"Loading all IDs"]
}

- (void)observeValueForKeyPath:(CPString)keyPath ofObject:(id)object change:(CPDictionary)change context:(void)context
{
    if ([[object isEqual:_arrayController]] && [keyPath isEqual:@"arrangedObjects"])
        if ([[change objectForKey:CPKeyValueChangeNotificationIsPriorKey] isEqual:[CPNumber numberWithBool:YES]])
        {
            [self willChangeValueForKey:@"status"];
        }
        else
        {
            [_tableView deselectColumn:[_tableView selectedColumn]];
            [self didChangeValueForKey:@"status"];
        }
}

- (CPString)status
{
    if (!_arrayController || ![_arrayController arrangedObjects] || [[_arrayController arrangedObjects] count] == 0)
    {
        return @"No entries";
    }

    return [CPString stringWithFormat:@"%@ Entries", [[_arrayController arrangedObjects] count]];
}

- (BOOL)inspectorIsVisible
{
    return [_inspectorWindow isVisible];
}

- (@action)toggleInspector:(id)sender
{
    if ([self inspectorIsVisible])
        [self hideInspector:self];
    else
        [self showInspector:self];
}

- (@action)hideInspector:(id)sender
{
    if ([self inspectorIsVisible])
        [_inspectorWindow orderOut:self];
}

- (@action)showInspector:(id)sender
{
    if (![self inspectorIsVisible])
        [_inspectorWindow orderFront:self];
}

- (BOOL)predicateEditorIsVisible
{
    return ![_predicateEditorView isHidden];
}

- (@action)togglePredicateEditor:(id)sender
{
    if ([self predicateEditorIsVisible])
        [self hidePredicateEditor:self];
    else
        [self showPredicateEditor:self];
}

- (@action)hidePredicateEditor:(id)sender
{
    // CPLog.debug(@"Hide Editor");
    if ([self predicateEditorIsVisible])
    {
        [_predicateEditorView setHidden:YES];
        [self layoutViews];
    }
}

- (@action)showPredicateEditor:(id)sender
{
    // CPLog.debug(@"Show Editor");
    if (!_filterPredicate)
        [self setFilterPredicate:[self defaultPredicate]];

    if (![self predicateEditorIsVisible])
    {
        [_predicateEditorView setHidden:NO];
        [self layoutViews];
    }
}

- (void)ruleEditorRowsDidChange:(CPNotification)notification
{
    [self layoutViews];
}

- (void)layoutViews
{
    var view = [self view],
        bounds = [view bounds],
        tableScrollView = [[_tableView superview] superview];
    if (_predicateEditorView)
    {
        var predicateHeight = [self predicateEditorIsVisible] ? [_predicateEditorView bounds].size.height : 0,
            predicateScrollView = [[_predicateEditorView superview] superview];

        var tableFrame = CGRectMake(bounds.origin.x, predicateHeight, bounds.size.width, bounds.size.height - predicateHeight);
        [_mainContentView setFrame:tableFrame];

        var predicateEditorFrame = CGRectMake(0, 0, bounds.size.width, predicateHeight);
        [predicateScrollView setFrame:predicateEditorFrame];
    }
    else
    {
        [tableScrollView setFrame:bounds];
    }
}

- (void)reload
{
    [_arrayController reload];
}

#pragma mark - WLAction delegate

- (void)remoteActionDidFinish:(WLRemoteAction)anAction
{
    var objectClass = [[self class] objectClass],
        objects = [objectClass objectsFromJson:[anAction result]];

    [_arrayController addObjects:objects];
}

@end
