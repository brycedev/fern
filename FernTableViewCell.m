#import "FernTableViewCell.h"

@implementation FernTableViewCell

- (void)layoutSubviews{
   [super layoutSubviews];
   CGRect bounds = self.contentView.bounds;
   self.contentView.frame = CGRectMake(0,0, bounds.size.width, bounds.size.height);
   CGRect imageViewFrame = self.imageView.frame;
   imageViewFrame.origin.x = bounds.size.width - imageViewFrame.size.width;
   self.imageView.frame = imageViewFrame;
   CGRect labelFrame = self.textLabel.frame;
   labelFrame = CGRectMake(0,0, labelFrame.size.width, labelFrame.size.height);
   self.textLabel.frame = labelFrame;
   [self.textLabel setTextColor: [UIColor whiteColor]];
   [self.textLabel setBackgroundColor: [UIColor clearColor]];
   [self.textLabel setFont: [UIFont systemFontOfSize: 26]];
   [self.textLabel setTextAlignment: NSTextAlignmentLeft];
}

@end
