//
//  MobCoreCell.h
//  CoreTech_MobCore_MobCTableViewController+NetworkingFeatures_iOS
//
//  Created by Raj Wilhoit on 12/17/13.
//  Copyright (c) 2013 UF.rajwilhoit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MobCoreCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userAvatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *itemImageView;
@property (weak, nonatomic) IBOutlet UILabel *datePostedLabel;
@property (strong, nonatomic) IBOutlet UILabel *likesLabel;

@end
