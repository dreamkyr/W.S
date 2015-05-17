//

//
//  ARC Helper
#ifndef ah_retain
#if __has_feature(objc_arc)
#define ah_retain self
#define ah_dealloc self
#define release self
#define autorelease self
#else
#define ah_retain retain
#define ah_dealloc dealloc
#define __bridge
#endif
#endif

//  ARC Helper ends

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>
#import "PookPost.h"

@protocol YCameraViewControllerDelegate;



@interface YCameraViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate>{
    
    UIImagePickerController *imgPicker;
    BOOL pickerDidShow;
    
    //Today Implementation
    BOOL FrontCamera;
    BOOL haveImage;
    BOOL initializeCamera, photoFromCam;
    AVCaptureSession *session;
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
    AVCaptureStillImageOutput *stillImageOutput;
    UIImage *croppedImageWithoutOrientation;
    PookPost *postInfo;
    
    IBOutlet UIImageView *slide_Top;
    IBOutlet UIImageView *slide_Bottom;
    IBOutlet UIButton *dimButton;
    IBOutlet UIView *view_location_searched;
    IBOutlet UIView *view_Location_NeaerBy;
    
    IBOutlet UIView *view_CommentaboutPhoto;
    IBOutlet UILabel *lbl_Locationname;
    IBOutlet UITextView *txt_CommentPhoto;
}
@property (nonatomic, readwrite) BOOL dontAllowResetRestaurant;
@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) id            m_parentView;

#pragma mark -
@property (nonatomic, strong) IBOutlet UIButton *photoCaptureButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraToggleButton;
@property (weak, nonatomic) IBOutlet UIButton *flashToggleButton;
@property (nonatomic, strong) IBOutlet UIButton *cancelButton;
@property (nonatomic, strong) IBOutlet UIButton *libraryToggleButton;

@property (retain, nonatomic) IBOutlet UIView *imagePreview;
@property (retain, nonatomic) IBOutlet UIImageView *captureImage;

@property (weak, nonatomic) IBOutlet UIView *view_Top;
@property (weak, nonatomic) IBOutlet UIView *view_Retake;
@property (weak, nonatomic) IBOutlet UIView *view_Location;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tbl_NearBy;
@property (weak, nonatomic) IBOutlet UITableView *tbl_Search;
@property (weak, nonatomic) IBOutlet UITableView *tbl_Result;



@end

@protocol YCameraViewControllerDelegate
- (void)didFinishPickingImage:(UIImage *)image;
- (void)yCameraControllerDidCancel;
- (void)yCameraControllerdidSkipped;
@end
