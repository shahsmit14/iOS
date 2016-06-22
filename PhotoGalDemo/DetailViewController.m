//
//  DetailViewController.m
//  PhotoGalDemo
//
//  Created by Smit Shah on 5/8/16.
//  Copyright © 2016 Smit Shah. All rights reserved.
//

#import "DetailViewController.h"
#import "CodeConstants.h"
#import "Asset.h"

@import PhotosUI;
@import AVFoundation;
@import AVKit;

#pragma mark -

@interface DetailViewController () <PHLivePhotoViewDelegate, AVPlayerViewControllerDelegate>

#pragma mark - Properties

@property (weak, nonatomic) IBOutlet UIImageView *detailedImageView;
@property (weak, nonatomic) IBOutlet UILabel *dateLbl;
@property (weak, nonatomic) IBOutlet UILabel *imageNameLbl;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet PHLivePhotoView *livePhotoView;
@property (weak, nonatomic) IBOutlet UIView *playerView;

@property (weak, nonatomic) NSString *detailedImageName;

@property (strong, nonatomic) UITapGestureRecognizer *tapGestureOnVideo;

@property (assign, nonatomic) BOOL isBackgroundBlack;
@property (assign, nonatomic) BOOL playingHint;

@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) AVPlayer *mainPlayer;

@property (strong, nonatomic) PHLivePhotoView *photoView;
@property (strong, nonatomic) PHAssetCollection *assetCollection;

@property (strong, nonatomic) Asset *assetObj;

@end


#pragma mark -

@implementation DetailViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.detailedImageView.userInteractionEnabled = YES;
    self.livePhotoView.userInteractionEnabled = YES;
    self.playerView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapGestureOnImage = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(tapped)];
    UITapGestureRecognizer *tapGestureOnLivePhoto = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(tapped)];
    self.tapGestureOnVideo = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                action:@selector(tapped)];
    [self.detailedImageView addGestureRecognizer:tapGestureOnImage];
    [self.livePhotoView addGestureRecognizer:tapGestureOnLivePhoto];
    [self.playerView addGestureRecognizer:self.tapGestureOnVideo];
}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    self.detailedImageView.hidden = YES;
    self.livePhotoView.hidden = YES;
    self.playerView.hidden = YES;
    self.isBackgroundBlack = NO;
 
    [self loadAssetDetails];
    [self showViews];
    
    if (self.asset.mediaSubtypes & PHAssetMediaSubtypePhotoLive) {
        
        self.livePhotoView.hidden = NO;
        self.detailedImageView.hidden = YES;
        self.playerView.hidden = YES;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [self loadLiveImage];
    }
    else if (self.asset.mediaType == PHAssetMediaTypeVideo) {
        
        self.livePhotoView.hidden = YES;
        self.detailedImageView.hidden = YES;
        self.playerView.hidden = NO;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [self loadVideo];
    }
    else {
        
        self.livePhotoView.hidden = YES;
        self.detailedImageView.hidden = NO;
        self.playerView.hidden = YES;
        [self loadImage];
    }
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}


#pragma mark - Load Asset

-(void) loadAssetDetails {
    
    self.assetObj = [[Asset alloc] init];
    
    NSArray *resources = [PHAssetResource assetResourcesForAsset:self.asset];
    self.assetObj.assetName = ((PHAssetResource*)resources[0]).originalFilename;
    self.assetObj.assetCreationDate = [NSDateFormatter localizedStringFromDate:self.asset.creationDate
                                                                     dateStyle:NSDateFormatterMediumStyle
                                                                     timeStyle:NSDateFormatterMediumStyle];
}


#pragma mark - Display Asset

-(void)loadLiveImage {
    
    self.photoView = [[PHLivePhotoView alloc] init];
    self.photoView = (PHLivePhotoView *)[self.view viewWithTag:kLiveImageView];
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize targetSize = CGSizeMake(CGRectGetWidth([self.view viewWithTag:kLiveImageView].bounds) * scale, CGRectGetHeight([self.view viewWithTag:kLiveImageView].bounds) * scale);
    
    PHLivePhotoRequestOptions *livePhotoOptions = [[PHLivePhotoRequestOptions alloc] init];
    livePhotoOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    livePhotoOptions.networkAccessAllowed = YES;
    
    [[PHImageManager defaultManager] requestLivePhotoForAsset:self.asset
                                                   targetSize:targetSize
                                                  contentMode:PHImageContentModeDefault
                                                      options:livePhotoOptions
                                                resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
        
                                                    if (!livePhoto) {
                                                        return;
                                                    }
                                                    
                                                    self.photoView.livePhoto = livePhoto;
                                                    self.photoView.contentMode = UIViewContentModeScaleAspectFit;
                                                    [self.photoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
                                                    
                                                    [self displayAssetDetails];
                                                    
                                                }];
}

- (void)loadImage {
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize targetSize = CGSizeMake(CGRectGetWidth(self.detailedImageView.bounds) * scale, CGRectGetHeight(self.detailedImageView.bounds) * scale);
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.networkAccessAllowed = YES;
    
    [[PHImageManager defaultManager] requestImageForAsset:self.asset
                                               targetSize:targetSize
                                              contentMode:PHImageContentModeDefault
                                                  options:options
                                            resultHandler:^(UIImage *result, NSDictionary *info) {
        
                                                if (!result) {
                                                    return;
                                                }
        
                                                self.detailedImageView.image = result;
                                                [self displayAssetDetails];
                                            }];
   }

-(void) loadVideo {
    
    [[PHImageManager defaultManager] requestAVAssetForVideo:self.asset options:nil resultHandler:^(AVAsset *avAsset, AVAudioMix *audioMix, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!self.playerLayer) {
                
                AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:avAsset];
                playerItem.audioMix = audioMix;
                
                AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
                
                AVPlayerViewController *playerController = [[AVPlayerViewController alloc] init];
                playerController.player = player;
                playerController.view.frame = self.playerView.frame;
                [playerController.view addGestureRecognizer:self.tapGestureOnVideo];
                
                [self.playerView addSubview:playerController.view];
                [player play];
                
                [self displayAssetDetails];
            }
        });
    }];
}

-(void) displayAssetDetails {
    
    self.imageNameLbl.text = self.assetObj.assetName;
    self.dateLbl.text = self.assetObj.assetCreationDate;
}


#pragma mark - Background Views

-(void) tapped {
    
    if (self.isBackgroundBlack) {
        self.isBackgroundBlack = NO;
        [self showViews];
    }
    else {
        self.isBackgroundBlack = YES;
        [self hideViews];
    }
}

-(void) hideViews {
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.detailedImageView.backgroundColor = [UIColor blackColor];
    self.livePhotoView.backgroundColor = [UIColor blackColor];
    self.toolBar.hidden = YES;
    self.imageNameLbl.hidden = YES;
    self.dateLbl.hidden = YES;
}

-(void) showViews {
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.detailedImageView.backgroundColor = [UIColor clearColor];
    self.toolBar.hidden = NO;
    self.imageNameLbl.hidden = NO;
    self.dateLbl.hidden = NO;
}

@end
