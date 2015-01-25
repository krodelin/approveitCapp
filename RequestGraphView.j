/*
 * RequestGraphView.j
 * approveitCapp
 *
 * Created by Udo Schneider on January 21, 2015.
 * Copyright 2015, Krodelin Software Solutions All rights reserved.
 */

@import <AppKit/AppKit.j>
@import "RequestStyleKit.j"

@implementation RequestGraphView : CPView
{
    CPString status;
}

- (void)setStatus:(CPString)newStatus
{
    if (![newStatus isEqual: status])
    {
        status = newStatus;
        [self setNeedsDisplay:YES];
    }
}

- (void)drawRect:(CGRect)dirtyRect
{
    [RequestStyleKit drawGraphWithStatus:status]
}

@end



