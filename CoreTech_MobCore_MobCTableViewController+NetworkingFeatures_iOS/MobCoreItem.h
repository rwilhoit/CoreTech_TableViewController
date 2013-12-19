//
//  MobCoreItem.h
//  CoreTech_MobCore_MobCTableViewController+NetworkingFeatures_iOS
//
//  Created by Raj Wilhoit on 12/17/13.
//  Copyright (c) 2013 UF.rajwilhoit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MobCoreItem : NSObject

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *photoTitle;
@property (nonatomic, strong) NSString *dateCreated;
@property (nonatomic, strong) NSString *photoDescription;
@property (nonatomic, strong) UIImage *photoImage;
@property (nonatomic, strong) NSURL *userAvatarUrl;
@property (nonatomic, strong) NSURL *photoImageUrl;
@property (nonatomic, strong) NSURL *photoImagePreviewUrl;
@property (nonatomic) int commentsCount;
@property (nonatomic) int likesCount;
@property (nonatomic) int viewsCount;

@end
