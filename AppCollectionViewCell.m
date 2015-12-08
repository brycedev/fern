#import "AppCollectionViewCell.h"

CGRect imageFrame;
CGRect labelFrame;

@implementation AppCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        CGFloat maxWidth = self.contentView.bounds.size.width;

        CGFloat imageX = (maxWidth - (.8 * maxWidth)) / 2;
        CGFloat imageY = 0;
        CGFloat width = .8 * maxWidth;
        CGFloat height = maxWidth - .2 * maxWidth + 10;

        imageFrame = CGRectMake(imageX, imageY, width, height - 10);
        labelFrame = CGRectMake(0, height, maxWidth, .2 * maxWidth);

        _imageView = [[UIImageView alloc] initWithFrame: imageFrame];

        _appLabel = [[UILabel alloc] initWithFrame : labelFrame];
        [_appLabel setTextColor: [UIColor whiteColor]];
        [_appLabel setFont: [UIFont systemFontOfSize: 13]];
        [_appLabel setTextAlignment: NSTextAlignmentCenter];


        [self.contentView addSubview: _imageView];
        [self.contentView addSubview: _appLabel];

    }
    return self;
}


- (void)prepareForReuse{
    [super prepareForReuse];
    self.imageView.image = nil;
    self.imageView.frame = imageFrame;
    self.appLabel.text = nil;
    self.appLabel.frame = labelFrame;
}


@end
