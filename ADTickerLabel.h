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

@property (nonatomic) UIFont *font;
@property (nonatomic) UIColor *textColor;

/*
 Default ADTickerLabelScrollDirectionUp
 */
@property (nonatomic) ADTickerLabelScrollDirection scrollDirection;

/*
 Default nil
 */
@property (nonatomic) UIColor *shadowColor;

/*
 Default CGSizeMake(0, 0)
 */
@property (nonatomic) CGSize shadowOffset;

/*
 Default UITextAlignmentLeft
 */
@property (nonatomic) UITextAlignment textAlignment;

@property (nonatomic) NSString *text;

-(void)setText:(NSString *)text animated:(BOOL)animated;

@end
