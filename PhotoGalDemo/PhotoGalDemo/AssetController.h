//
//  AssetController.h
//  PhotoGalDemo
//
//  Created by Smit Shah on 5/10/16.
//  Copyright © 2016 Smit Shah. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Photos;

@interface AssetController : NSObject

+ (PHFetchResult *)fetchAllAssetsFromDeviceByAscendingOrderOfCreationDate:(BOOL) ascendingOrder;

@end
