/*
 * ZxcvbnTransformer.j
 * approveitCapp
 *
 * Created by Udo Schneider on January 21, 2015.
 * Copyright 2015, Krodelin Software Solutions All rights reserved.
 */

@import <Foundation/Foundation.j>
@import "zxcvbn.js"

@implementation ZxcvbnTransformer : CPValueTransformer

+ (BOOL)allowsReverseTransformation
{
    return no;
}

+ (Class)transformedValueClass
{
    return [CPNumber class];
}

@end

@implementation ZxcvbnEntropyTransformer : ZxcvbnTransformer

- (id)transformedValue:(id)password
{
    if (password)
    {
        return zxcvbn(password).entropy; // in bits
    }
    else
    {
        return 0;
    }
}

@end

@implementation ZxcvbnCrackTimeTransformer : ZxcvbnTransformer

- (id)transformedValue:(id)password
{
    if (password)
    {
        return zxcvbn(password).crack_time; // estimation of actual crack time, in seconds.
    }
    else
    {
        return 0;
    }
}

@end

@implementation ZxcvbnCrackTimeStringTransformer : ZxcvbnTransformer

+ (Class)transformedValueClass
{
    return [CPString class];
}

- (id)transformedValue:(id)password
{
    if (password)
    {
        return zxcvbn(password).crack_time_display; // same crack time, as a friendlier string: "instant", "6 minutes", "centuries", etc.
    }
    else
    {
        return @"";
    }
}

@end

@implementation ZxcvbnScoreTransformer : ZxcvbnTransformer

- (id)transformedValue:(id)password
{
    if (password)
    {
        return zxcvbn(password).score //[0,1,2,3,4] if crack time is less than [10**2, 10**4, 10**6, 10**8, Infinity]. (useful for implementing a strength bar.)
    }
    else
    {
        return 0;
    }
}

@end

@implementation ZxcvbnMatchTransformer : ZxcvbnTransformer

+ (Class)transformedValueClass
{
    return [CPString class];
}

- (id)transformedValue:(id)password
{
    if (password)
    {
        return zxcvbn(password).match_sequence // the list of patterns that zxcvbn based the entropy calculation on.
    }
    else
    {
        return @"";
    }
}

@end

