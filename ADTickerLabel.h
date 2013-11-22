//
//  ADTickerLabel.h
//  ADTickerLabel
//
//  Created by Anton Domashnev on 28.05.13.
//  Copyright (c) 2013 Anton Domashnev. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    ADTickerLabelScrollDirectionUp = 1,
    ADTickerLabelScrollDirectionDown = 2
}ADTickerLabelScrollDirection;

@interface ADTickerLabel : UIView

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;

/*
 Default 8 px
 */
@property (nonatomic, unsafe_unretained) float characterWidth;

/*
 Frame may have been changed after setting new text
 */
@property (nonatomic, strong) NSString *text;

/*
 Change text animation duration in seconds
 Default 1 seconds
 */
@property (nonatomic, unsafe_unretained) float changeTextAnimationDuration;

/*
 Default ADTickerLabelScrollDirectionUp
 */
@property (nonatomic, unsafe_unretained) ADTickerLabelScrollDirection scrollDirection;

/*
 Default nil
 */
@property (nonatomic, strong) UIColor *shadowColor;

/*
 Default CGSizeMake(0, 0)
 */
@property (nonatomic, unsafe_unretained) CGSize shadowOffset;

@end
