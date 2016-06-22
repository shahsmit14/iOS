//
//  CollectionViewCell.m
//  PhotoGalDemo
//
//  Created by Smit Shah on 5/10/16.
//  Copyright © 2016 Smit Shah. All rights reserved.
//

#import "CollectionViewCell.h"

@interface CollectionViewCell ()

#pragma mark - Properties

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UIImageView *badgeImageView;

@end

#pragma mark - 

@implementation CollectionViewCell

#pragma mark - Image

- (void)prepareForReuse {
    
    [super prepareForReuse];
    self.thumbnailImageView.image = nil;
    self.badgeImageView.image = nil;
}

- (void)setThumbnailImage:(UIImage *)thumbnailImage {
    _thumbnailImage = thumbnailImage;
    self.thumbnailImageView.image = _thumbnailImage;
}

- (void)setBadgeImage:(UIImage *)badgeImage {
    _badgeImage = badgeImage;
    self.badgeImageView.image = _badgeImage;
}


@end
