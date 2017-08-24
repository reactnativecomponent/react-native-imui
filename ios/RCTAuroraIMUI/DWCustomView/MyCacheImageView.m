//
//  MyCacheImageView.m
//  CacheImage
//
//

#import "MyCacheImageView.h"
#import "UIImageView+WebCache.h"

@implementation MyCacheImageView


- (void)setImageURL:(NSString *)URL{
    [self sd_setImageWithURL:[NSURL URLWithString:URL]];
}

- (void)setImageURL:(NSString *)URL placeholderImage:(NSString *)imageName{
    
    [self sd_setImageWithURL:[NSURL URLWithString:URL] placeholderImage:[UIImage imageNamed:imageName]];
}


@end
