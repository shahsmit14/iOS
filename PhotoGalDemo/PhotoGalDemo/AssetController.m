//
//  AssetController.m
//  PhotoGalDemo
//
//  Created by Smit Shah on 5/10/16.
//  Copyright © 2016 Smit Shah. All rights reserved.
//

#import "AssetController.h"
#import "CodeConstants.h"
@import Photos;

@implementation AssetController

+ (PHFetchResult *)fetchAllAssetsFromDeviceByAscendingOrderOfCreationDate:(BOOL) ascendingOrder {
    
    PHFetchOptions *phFetchOptions = [PHFetchOptions new];
    phFetchOptions.sortDescriptors = @[
                                       [NSSortDescriptor sortDescriptorWithKey:kSortAssetByCreationDate ascending:ascendingOrder]
                                       ];
    
    return [PHAsset fetchAssetsWithOptions:phFetchOptions];
}

@end
