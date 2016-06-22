//
//  DetailViewController.h
//  PhotoGalDemo
//
//  Created by Smit Shah on 5/8/16.
//  Copyright © 2016 Smit Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Photos;
@import PhotosUI;

@interface DetailViewController : UIViewController

@property (strong, nonatomic) PHAsset *asset;

@end
