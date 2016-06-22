//
//  MasterCollectionViewController.m
//  PhotoGalDemo
//
//  Created by Smit Shah on 5/8/16.
//  Copyright © 2016 Smit Shah. All rights reserved.
//

#import "MasterCollectionViewController.h"
#import "DetailViewController.h"
#import "CollectionViewCell.h"
#import "AssetController.h"
#import "CodeConstants.h"
@import Photos;

#pragma mark -

@interface MasterCollectionViewController ()

#pragma mark - Properties

@property (strong, nonatomic) PHFetchResult *phFetchResult;
@property (strong, nonatomic) PHImageManager *phImageManager;
@property (assign, nonatomic) CGSize phAssetGridThumbnailSize;

@property (assign, nonatomic) BOOL isAscending;

@end


#pragma mark -

@implementation MasterCollectionViewController

#pragma mark - Life Cycle

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize cellSize = ((UICollectionViewFlowLayout *)self.collectionViewLayout).itemSize;
    self.phAssetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.isAscending = NO;
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusAuthorized) {
        [self loadAsset];
    }
}

-(void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusNotDetermined) {
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:kPhotoAccessProblemTitle
                                                                       message:kPhotoAccessProblemMessage
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:kFeedbackConfirmButton
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  
                                                                  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                                                  
                                                              }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    if (status == PHAuthorizationStatusAuthorized && self.phFetchResult.count < 1) {
        [self loadAsset];
    }
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.destinationViewController isKindOfClass:[DetailViewController class]]) {
        DetailViewController *detailViewController = segue.destinationViewController;
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
        detailViewController.asset = self.phFetchResult[indexPath.item];
    }
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    return YES;
}


#pragma mark - Collection View

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.phFetchResult.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PHAsset *asset = self.phFetchResult[indexPath.item];
    
    CollectionViewCell *collectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:kGridCellReuseIdentifier
                                                                                       forIndexPath:indexPath];

    if (asset.mediaSubtypes & PHAssetMediaSubtypePhotoLive) {
        collectionViewCell.badgeImage = [PHLivePhotoView livePhotoBadgeImageWithOptions:PHLivePhotoBadgeOptionsOverContent];
    }
    else if (asset.mediaType == PHAssetMediaTypeVideo) {
        collectionViewCell.badgeImage = [UIImage imageNamed:kBadgeImageVideo];
    }
    
    [self.phImageManager requestImageForAsset:asset
                                   targetSize:self.phAssetGridThumbnailSize
                                  contentMode:PHImageContentModeDefault
                                      options:nil
                                resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                    
                                    collectionViewCell.thumbnailImage = result;
                                }];
    
    return collectionViewCell;
}

#pragma mark - Load Asset

- (void)loadAsset {
    
    self.phImageManager = [[PHImageManager alloc] init];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kReuseIdentifier];
    
    self.phFetchResult = [AssetController fetchAllAssetsFromDeviceByAscendingOrderOfCreationDate:NO];
}

#pragma mark - Sort

- (IBAction)sortAsset:(id)sender {
    
    if (self.isAscending) {
        self.isAscending = NO;
        self.phFetchResult = [AssetController fetchAllAssetsFromDeviceByAscendingOrderOfCreationDate:self.isAscending];
    }
    else {
        self.isAscending = YES;
        self.phFetchResult = [AssetController fetchAllAssetsFromDeviceByAscendingOrderOfCreationDate:self.isAscending];
    }
    
    [self.collectionView reloadData];
}


@end
