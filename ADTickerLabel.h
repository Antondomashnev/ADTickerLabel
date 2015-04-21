//
//  ADTickerLabel.h
//  ADTickerLabel
//
//  Created by Anton Domashnev on 28.05.13.
//  Copyright (c) 2013 Anton Domashnev. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    ADTickerLabelScrollDirectionUp,
    ADTickerLabelScrollDirectionDown
}ADTickerLabelScrollDirection;

@interface ADTickerLabel : UIView

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;

/*
 Default ADTickerLabelScrollDirectionUp
 */
@property (nonatomic, assign) ADTickerLabelScrollDirection scrollDirection;

/*
 Default nil
 */
@property (nonatomic, strong) UIColor *shadowColor;

/*
 Default CGSizeMake(0, 0)
 */
@property (nonatomic, assign) CGSize shadowOffset;

/*
 Default UITextAlignmentLeft
 */
@property (nonatomic, assign) UITextAlignment textAlignment;

/*
 Default 1.0
 */
@property (nonatomic, assign) NSTimeInterval changeTextAnimationDuration;

@property (nonatomic, copy) NSString *text;

-(void)setText:(NSString *)text animated:(BOOL)animated;

@end
