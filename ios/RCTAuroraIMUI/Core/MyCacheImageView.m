//
//  MyCacheImageView.m
//  CacheImage
//
//

#import "MyCacheImageView.h"
#import "UIImageView+WebCache.h"
#import "UIImage+NIM.h"
@implementation MyCacheImageView


- (void)setImageURL:(NSString *)URL{
    [self sd_setImageWithURL:[NSURL URLWithString:URL]];
}

- (void)setImageURL:(NSString *)URL placeholderImage:(NSString *)imageName{
    
    [self sd_setImageWithURL:[NSURL URLWithString:URL] placeholderImage:[UIImage nim_fetchView:[NSString stringWithFormat:@"/viewImgs/%@",imageName]]];
}

- (void)setImageURL:(NSString *)URL placeImage:(UIImage *)image{
    
    [self sd_setImageWithURL:[NSURL URLWithString:URL] placeholderImage:image];
}

@end
