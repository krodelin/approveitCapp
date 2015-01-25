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
@import "ZxcvbnTransformer.j"

// @import "WLArray.j"

@implementation USViewController : CPViewController
{
    // WLObjectController   _objectController;
    @outlet     CPArrayController   _arrayController;
    @outlet     CPView              _mainContentView;
}

- (void)awakeFromCib
{
    // This is called when the cib is done loading.
    // You can implement this method on any object instantiated from a Cib.
    // It's a useful hook for setting up current UI values, and other things.
    [self fetchAll];
}


- (void)fetchAll
{
    [[_arrayController mutableArrayValueForKey:@"content"] removeAllObjects]
    [[[self class] objectClass] fetchAll:self];
}

- (@action)addObject:(id)sender
{
    var object = [[[[self class] objectClass] alloc] init];
    [_arrayController addObject:object];
    [object create];
}

- (@action)removeObject:(id)sender
{
    var object = [[_arrayController selectedObjects] objectAtIndex:0];
    [object delete];
    [_arrayController removeObject:object];
}

- (CPButton)buttonWithImage:(CPString)imageName action:(SEL)selector
{
    var button = [[CPButton alloc] initWithFrame:CGRectMake(0, 0, 35, 25)],
        image = CPImageInBundle(imageName);
    [button setBordered:NO];
    [button setImage:image];
    [button setImagePosition:CPImageOnly];
    [button setAction:selector];
    [button setTarget:self];
    [button setEnabled:YES];
    return button;
}

#pragma mark - WLAction delegate

- (void)remoteActionDidFinish:(WLRemoteAction)anAction
{
    var objectClass = [[self class] objectClass],
        objects = [objectClass objectsFromJson:[anAction result]];


    if ([objects count] > 0)
    {
        [_arrayController addObjects:objects];
        [_arrayController setSelectedObjects:[CPArray arrayWithObject:[[_arrayController arrangedObjects] objectAtIndex:0]]];
    }

}

@end
