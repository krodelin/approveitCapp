/*
 * UIIcon.j
 * approveitCapp
 *
 * Created by Udo Schneider on January 21, 2015.
 * Copyright 2015, Krodelin Software Solutions All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "UIIconMapping.j"


var CachedIcons = [CPMutableDictionary dictionary];

function UIIcon(name, width, height)
{
    var iconName = UIIconMapping[name];
    if (!iconName)
        iconName = name;
    iconName = iconName+"_"+width+"x"+height+".png";
    var icon = [CachedIcons objectForKey:iconName];
    if (!icon)
    {
        // CPLog.debug(@"Cache Miss for %@",iconName);
        icon = CPImageInBundle(iconName);
        [CachedIcons setObject:icon forKey:iconName];
    } else {
        // CPLog.debug(@"Cache Hit for %@",iconName);
    }
    return icon;
}
