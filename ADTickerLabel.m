#import "ADTickerLabel.h"

#import <QuartzCore/QuartzCore.h>

@interface ADTickerCharacterLabel : UILabel

@property (nonatomic, strong) NSArray *charactersArray;

@property (nonatomic, assign) NSTimeInterval changeTextAnimationDuration;
@property (nonatomic, assign) ADTickerLabelScrollDirection scrollDirection;
@property (nonatomic, assign) NSInteger selectedCharacterIndex;

@end

@implementation ADTickerCharacterLabel

- (id)initWithFrame:(CGRect)frame
{
   if (self = [super initWithFrame: frame])
   {
      self.clipsToBounds = YES;
      self.lineBreakMode = NSLineBreakByCharWrapping;
      self.textAlignment = NSTextAlignmentCenter;
      self.numberOfLines = 0;
      self.backgroundColor = [UIColor clearColor];
   }
   return self;
}

- (CGFloat)positionYForCharacterAtIndex:(NSInteger)index
{
   CGFloat characterHeight = self.frame.size.height / [self.charactersArray count];
   CGFloat position = -index * characterHeight;
   return position;
}

- (void)moveToPosition:(CGFloat)positionY
              animated:(BOOL)animated
            completion:(void(^)(void))completion
{
   CGRect newFrame = self.frame;
   newFrame.origin.y = positionY;

   if (animated)
   {
      [UIView animateWithDuration: self.changeTextAnimationDuration
                       animations:
       ^{
          self.frame = newFrame;
       }
                       completion:
       ^(BOOL finished)
       {
          completion();
       }];
   }
   else
   {
      self.frame = newFrame;
      completion();
   }
}

- (void)selectCharacter:(NSString *)selectedCharacter
               animated:(BOOL)animated
{
   if (self.scrollDirection == ADTickerLabelScrollDirectionUp)
   {
      NSInteger selectedCharacterIndex = [selectedCharacter integerValue];
      
      if (![selectedCharacter isEqualToString: @"."])
      {
         selectedCharacterIndex++;
      }

      if (selectedCharacterIndex < self.selectedCharacterIndex)
      {
         [self moveToPosition: [self positionYForCharacterAtIndex: selectedCharacterIndex]
                     animated: animated
                   completion:
          ^{
             self.selectedCharacterIndex = selectedCharacterIndex;
          }];
      }
      else if(selectedCharacterIndex > self.selectedCharacterIndex)
      {
         //We try to find the character in second part of array
         NSUInteger searchLocation = [self.charactersArray count] / 2;
         selectedCharacterIndex = [ self.charactersArray indexOfObject: selectedCharacter
                                                               inRange: NSMakeRange(searchLocation, [self.charactersArray count] - searchLocation)];

         [self moveToPosition: [self positionYForCharacterAtIndex: selectedCharacterIndex]
                     animated: animated
                   completion:
          ^{
             self.selectedCharacterIndex = [self.charactersArray indexOfObject: selectedCharacter];
             
             CGRect newFrame = self.frame;
             newFrame.origin.y = [self positionYForCharacterAtIndex: self.selectedCharacterIndex];
             self.frame = newFrame;
          }];
      }
   }
   else
   {
      NSInteger selectedCharacterIndex = [self.charactersArray count] - 1 - [selectedCharacter integerValue];

      if (![selectedCharacter isEqualToString: @"."])
      {
         selectedCharacterIndex--;
      }

      if (selectedCharacterIndex < self.selectedCharacterIndex)
      {
         [self moveToPosition: [self positionYForCharacterAtIndex: selectedCharacterIndex]
                     animated: animated
                   completion:
          ^{
             self.selectedCharacterIndex = selectedCharacterIndex;
          }];
      }
      else if(selectedCharacterIndex > self.selectedCharacterIndex){
         
         //We try to find the character in second part of array
         NSUInteger searchLocation = [self.charactersArray count] / 2;
         selectedCharacterIndex = [self.charactersArray indexOfObject: selectedCharacter
                                                              inRange: NSMakeRange(searchLocation, [self.charactersArray count] - searchLocation)];

         [self moveToPosition: [self positionYForCharacterAtIndex: selectedCharacterIndex]
                     animated: animated
                   completion:
          ^{
             self.selectedCharacterIndex = [self.charactersArray indexOfObject: selectedCharacter];
             
             CGRect newFrame = self.frame;
             newFrame.origin.y = [self positionYForCharacterAtIndex: self.selectedCharacterIndex];
             self.frame = newFrame;
          }];
      }
   }
}

@end

@interface ADTickerLabel ()

@property (nonatomic, readonly) NSArray *characterViewsArray;
@property (nonatomic) NSArray *charactersArray;
@property (nonatomic) CGFloat characterWidth;

@property (nonatomic) UIView* charactersView;

@end

@implementation ADTickerLabel

+ (NSArray*)charactersArray
{
   return @[@".", @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9"
            , @".", @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9"];
}

- (void)initializeLabel
{
   self.charactersView = [[UIView alloc] initWithFrame: self.bounds];
   self.charactersView.clipsToBounds = YES;
   self.charactersView.backgroundColor = [UIColor clearColor];
   [self addSubview: self.charactersView];

   self.charactersArray = [[self class] charactersArray];
   self.font = [UIFont systemFontOfSize: 12.];
   self.textColor = [UIColor blackColor];
   self.changeTextAnimationDuration = 1.0;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder: aDecoder];
   if (self) {
      [self initializeLabel];
   }
   return self;
}

- (id)initWithFrame:(CGRect)frame
{
   self = [super initWithFrame: frame];
   if (self) {
      [self initializeLabel];
   }
   return self;
}

- (NSArray*)characterViewsArray
{
   return self.charactersView.subviews;
}

- (void)insertNewCharacterLabel
{
   CGRect characterFrame = CGRectZero;

   NSString *characters = [self.charactersArray componentsJoinedByString: @""];
   characterFrame.size = [characters boundingRectWithSize:CGSizeMake(self.characterWidth, MAXFLOAT)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName: self.font}
                                                  context:0].size;

   if (self.scrollDirection == ADTickerLabelScrollDirectionDown)
   {
      CGFloat characterHeight = characterFrame.size.height / [self.charactersArray count];
      characterFrame.origin.y = characterHeight - characterFrame.size.height;
   }

   ADTickerCharacterLabel *characterLabel = [[ADTickerCharacterLabel alloc] initWithFrame: characterFrame];
   characterLabel.text = characters;
   characterLabel.charactersArray = self.charactersArray;
   characterLabel.font = self.font;
   characterLabel.textColor = self.textColor;
   characterLabel.shadowColor = self.shadowColor;
   characterLabel.shadowOffset = self.shadowOffset;

   characterLabel.scrollDirection = self.scrollDirection;
   characterLabel.changeTextAnimationDuration = self.changeTextAnimationDuration;

   [self.charactersView addSubview: characterLabel];
}

- (void)removeLastCharacterLabel
{
   ADTickerCharacterLabel *numericView = [self.characterViewsArray lastObject];
   [numericView removeFromSuperview];
}

#pragma mark Interface

- (void)setScrollDirection:(ADTickerLabelScrollDirection)direction
{
   if (direction != _scrollDirection)
   {
      _scrollDirection = direction;
      
      NSArray* charactersArray = [[self class] charactersArray];

      if (direction == ADTickerLabelScrollDirectionDown)
      {
         charactersArray = [charactersArray reverseObjectEnumerator].allObjects;
      }
      self.charactersArray = charactersArray;

      [self.characterViewsArray enumerateObjectsUsingBlock:
       ^(ADTickerCharacterLabel* label, NSUInteger idx, BOOL *stop)
       {
          [label setScrollDirection: direction];
       }];
   }
}

- (void)setChangeTextAnimationDuration:(NSTimeInterval)duration
{
   if (_changeTextAnimationDuration != duration)
   {
      _changeTextAnimationDuration = duration;

      [self.characterViewsArray enumerateObjectsUsingBlock:
       ^(ADTickerCharacterLabel *label, NSUInteger idx, BOOL *stop)
       {
          label.changeTextAnimationDuration = duration;
       }];
   }
}

- (void)setShadowOffset:(CGSize)shadowOffset
{
   _shadowOffset = shadowOffset;
   [self.characterViewsArray enumerateObjectsUsingBlock:
    ^(UILabel *label, NSUInteger idx, BOOL *stop)
    {
       label.shadowOffset = shadowOffset;
    }];
}

- (void)setShadowColor:(UIColor *)shadowColor
{
   _shadowColor = shadowColor;
   [self.characterViewsArray enumerateObjectsUsingBlock:
    ^(UILabel *label, NSUInteger idx, BOOL *stop)
    {
       label.shadowColor = shadowColor;
    }];
}

- (void)setTextColor:(UIColor *)textColor
{
   if (![_textColor isEqual: textColor])
   {
      _textColor = textColor;
      [self.characterViewsArray enumerateObjectsUsingBlock:
       ^(UILabel *label, NSUInteger idx, BOOL *stop)
       {
          label.textColor = textColor;
       }];
   }
}

- (void)setFont:(UIFont *)font
{
   if (![_font isEqual: font])
   {
      _font = font;
      self.characterWidth = [@"8" sizeWithAttributes:@{NSFontAttributeName: font}].width;

      [self.characterViewsArray enumerateObjectsUsingBlock:
       ^(UILabel *label, NSUInteger idx, BOOL *stop)
       {
          label.font = self.font;
       }];

      [self setNeedsLayout];
      [self invalidateIntrinsicContentSize];
   }
}

- (void)setText:(NSString *)text
{
   [self setText:text animated:YES];
}

- (void)layoutCharacterLabels
{
   CGRect characterFrame = CGRectZero;
   for (ADTickerCharacterLabel* label in self.characterViewsArray)
   {
      characterFrame.size.height = label.frame.size.height;
      if (self.scrollDirection == ADTickerLabelScrollDirectionDown)
      {
         CGFloat characterHeight = characterFrame.size.height / [self.charactersArray count];
         characterFrame.origin.y = characterHeight - characterFrame.size.height;
      }
      characterFrame.size.width = self.characterWidth;
      label.frame = characterFrame;
      label.selectedCharacterIndex = 0;

      characterFrame.origin.x += self.characterWidth;
   }
}

- (void)setText:(NSString *)text
       animated:(BOOL)animated
{
   if ([_text isEqualToString: text])
   {
      return;
   }

   NSInteger oldTextLength = [_text length];
   NSInteger newTextLength = [text length];

   if (newTextLength > oldTextLength)
   {
      NSInteger textLengthDelta = newTextLength - oldTextLength;
      for (NSInteger i = 0 ; i < textLengthDelta; ++i)
      {
         [self insertNewCharacterLabel];
      }
      [self invalidateIntrinsicContentSize];
      [self setNeedsLayout];
      [self layoutCharacterLabels];
   }
   else if (newTextLength < oldTextLength)
   {
      NSInteger textLengthDelta = oldTextLength - newTextLength;
      for (NSInteger i = 0 ; i < textLengthDelta; ++i)
      {
         [self removeLastCharacterLabel];
      }
      [self invalidateIntrinsicContentSize];
      [self setNeedsLayout];
      [self layoutCharacterLabels];
   }

   [self.characterViewsArray enumerateObjectsUsingBlock:
    ^(ADTickerCharacterLabel *label, NSUInteger idx, BOOL *stop)
    {
       [label selectCharacter: [text substringWithRange:NSMakeRange(idx, 1)]
                     animated: animated];
    }];

   _text = text;
}

- (void)setTextAlignment:(UITextAlignment)textAlignment
{
   _textAlignment = textAlignment;
   [self setNeedsLayout];
}

- (CGSize)intrinsicContentSize
{
   return CGSizeMake(self.characterWidth * self.text.length, UIViewNoIntrinsicMetric);
}

- (CGRect)characterViewFrameWithContentBounds:(CGRect)frame
{
   CGFloat charactersWidth = [self.characterViewsArray count] * self.characterWidth;
   frame.size.width = charactersWidth;

   switch (self.textAlignment)
   {
      case NSTextAlignmentRight:
         frame.origin.x = self.frame.size.width - charactersWidth;
         break;
      case NSTextAlignmentCenter:
         frame.origin.x = (self.frame.size.width - charactersWidth) / 2;
         break;
      case NSTextAlignmentLeft:
      default:
         frame.origin.x = 0.0;
         break;
   }
   
   return frame;
}

- (void)layoutSubviews
{
   [super layoutSubviews];

   if ([self.characterViewsArray count] > 0)
   {
      self.charactersView.frame = [self characterViewFrameWithContentBounds: self.bounds];
   }
}

@end
