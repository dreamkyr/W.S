//
//  FeedCollectionViewCell.h
//  Pook
//
//  Created by han on 1/15/15.
//  Copyright (c) 2015 iWorld. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PookFeed.h"

@protocol FeedCollectionViewCellDelegate <NSObject>

- (void) likeFeed:(PookFeed *)feed index:(NSInteger)index;
- (void) commentFeed:(PookFeed *)feed index:(NSInteger)index;
- (void) shareFeed:(PookFeed *)feed image:(UIImage *)image index:(NSInteger)index;

@end

@interface FeedCollectionViewCell : UICollectionViewCell

@property (nonatomic, assign) id<FeedCollectionViewCellDelegate> delegate;

@property (nonatomic, retain) PookFeed *feed;
@property (nonatomic, assign) NSInteger index;

- (void) setPostInfo:(PookFeed *)post index:(NSInteger)index;

- (void) increaseLikeCount;

+ (float) getPostCellHeight:(PookFeed *)post width:(float)width;

@end
