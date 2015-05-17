//
//  EGORefreshTableFooterView.h

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "EGOViewCommon.h"

@interface EGORefreshTableFooterView : UIView {
	
	id _delegate;
	EGOPullRefreshState _state;

	UILabel *_lastUpdatedLabel;
	UILabel *_statusLabel;
	CALayer *_arrowImage;
	UIActivityIndicatorView *_activityView;
	

}

@property(nonatomic,assign) id <EGORefreshTableDelegate> delegate;

- (id)initWithFrame:(CGRect)frame arrowImageName:(NSString *)arrow textColor:(UIColor *)textColor;

- (void)refreshLastUpdatedDate;
- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;

@end

