
#import "YCameraViewController.h"
#import "AppDelegate.h"
#import <ImageIO/ImageIO.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "Foursquare2.h"
#import "FSVenue.h"
#import "FSConverter.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "ASIFormDataRequest.h"
#import "SBJSON.h"
#import "MBProgressHUD.h"
#import "Constant.h"
#import "CommonMethods.h"

#import "UIImage+ImageEffects.h"

#define DegreesToRadians(x) ((x) * M_PI / 180.0)

@interface YCameraViewController (){
    UIInterfaceOrientation orientationLast, orientationAfterProcess;
    CMMotionManager *motionManager;
}

@property (nonatomic, assign) IBOutlet UIImageView *ivPhotoOnComment;
@property (nonatomic, assign) IBOutlet UIView *viewLocationAndShareButtonsOnComment;

@property (nonatomic, weak) NSOperation *lastSearchOperation;
@property (strong, nonatomic) NSArray *venues;
@property (strong, nonatomic) NSArray *near_venues;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) CLLocation *imageGeo;

@property (nonatomic, retain) NSData * dataImg;

@end

@implementation YCameraViewController
@synthesize delegate;
@synthesize dataImg;
@synthesize m_parentView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect rtScreen = [[UIScreen mainScreen] bounds];
    
    float screenWidth = CGRectGetWidth(rtScreen);
    float screenHeight = CGRectGetHeight(rtScreen);
    
    self.view_Location.frame = CGRectMake(screenWidth, 0, screenWidth, screenHeight);
    
    view_location_searched.frame = CGRectMake(screenWidth, view_location_searched.frame.origin.y, screenWidth, screenHeight);
    view_CommentaboutPhoto.frame = CGRectMake(screenWidth, view_CommentaboutPhoto.frame.origin.y, screenWidth, screenHeight);
    
    self.captureImage.clipsToBounds = YES;
    self.captureImage.contentMode = UIViewContentModeScaleAspectFit;
    //    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]){
    //        self.edgesForExtendedLayout = UIRectEdgeNone;
    //    }
    [self setNear_venues:[[NSArray alloc] init]];
    postInfo = [[PookPost alloc] initWithData];
    postInfo.userid = [AppDelegate getDelegate].curUser.userid;
    
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController setNavigationBarHidden:YES];
    
    //CLLocationManager
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
	// Do any additional setup after loading the view.
    pickerDidShow = NO;
    
    FrontCamera = YES;
    self.captureImage.hidden = YES;
    
    // Setup UIImagePicker Controller
    imgPicker = [[UIImagePickerController alloc] init];
    imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imgPicker.delegate = self;
    imgPicker.allowsEditing = YES;
    
    croppedImageWithoutOrientation = [[UIImage alloc] init];
    
    initializeCamera = YES;
    photoFromCam = YES;
    
    //Get Latest Photo from Camera Roll and Set as Button Background
    self.libraryToggleButton.clipsToBounds = YES;
    self.libraryToggleButton.layer.cornerRadius = self.libraryToggleButton.frame.size.width/9;
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
        // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        // Within the group enumeration block, filter to enumerate just photos.
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        
        // Chooses the photo at the last index
        [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
            
            // The end of the enumeration is signaled by asset == nil.
            if (alAsset) {
                ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                UIImage *latestPhoto = [UIImage imageWithCGImage:[representation fullScreenImage]];
                
                // Stop the enumerations
                *stop = YES; *innerStop = YES;
                
                // Do something interesting with the AV asset.
                //[self sendTweet:latestPhoto];
                //Change Thumphoto to right rectangle
                CGRect cropRect;
                if (latestPhoto.size.height>latestPhoto.size.width) {
                    cropRect = CGRectMake(0, (latestPhoto.size.height-latestPhoto.size.width)/2, latestPhoto.size.width, latestPhoto.size.width);
                }
                else
                {
                    cropRect = CGRectMake((latestPhoto.size.width-latestPhoto.size.height), 0, latestPhoto.size.height, latestPhoto.size.height);
                }
                
                CGImageRef imageRef = CGImageCreateWithImageInRect([latestPhoto CGImage], cropRect);
                
                
//                [self.libraryToggleButton setImage:latestPhoto forState:UIControlStateNormal];
                [self.libraryToggleButton setImage:[UIImage imageWithCGImage:imageRef] forState:UIControlStateNormal];
                NSLog(@"ThumSize=%f,%f", latestPhoto.size.width,latestPhoto.size.height );
            }
        }];
    } failureBlock: ^(NSError *error) {
        // Typically you should handle an error more gracefully than this.
        NSLog(@"No groups");
    }];
    
    // Initialize Motion Manager
    [self initializeMotionManager];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShowKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willChangeKeyboardFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (initializeCamera){
        initializeCamera = NO;
        
        // Initialize camera
        [self initializeCamera];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dealloc
{
    [_imagePreview release];
    [_captureImage release];
    [imgPicker release];
    imgPicker = nil;
    
    if (session)
        [session release], session=nil;
    
    if (captureVideoPreviewLayer)
        [captureVideoPreviewLayer release], captureVideoPreviewLayer=nil;
    
    if (stillImageOutput)
        [stillImageOutput release], stillImageOutput=nil;
}

- (void) willShowKeyboard:(NSNotification*)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    
    [self moveUpLocationViewWhenShowKeyboard:keyboardFrameBeginRect.size.height];
}

- (void) willChangeKeyboardFrame:(NSNotification *)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    
    [self moveUpLocationViewWhenShowKeyboard:keyboardFrameBeginRect.size.height];
}

- (void) willHideKeyboard:(NSNotification *)notification
{
    [self moveDownLocationView];
}

- (void) moveUpLocationViewWhenShowKeyboard:(float)keyboardHeight
{
    [UIView animateWithDuration:0.3f animations:^{
        
        self.viewLocationAndShareButtonsOnComment.frame = CGRectMake(0, CGRectGetHeight(self.view.frame) - (CGRectGetHeight(self.viewLocationAndShareButtonsOnComment.frame) + keyboardHeight), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.viewLocationAndShareButtonsOnComment.frame));
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void) moveDownLocationView
{
    [UIView animateWithDuration:0.3f animations:^{
        
        self.viewLocationAndShareButtonsOnComment.frame = CGRectMake(0, CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.viewLocationAndShareButtonsOnComment.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.viewLocationAndShareButtonsOnComment.frame));
        
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - CoreMotion Task
- (void)initializeMotionManager{
    motionManager = [[CMMotionManager alloc] init];
    motionManager.accelerometerUpdateInterval = .2;
    motionManager.gyroUpdateInterval = .2;
    
    [motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                        withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                                            if (!error) {
                                                [self outputAccelertionData:accelerometerData.acceleration];
                                            }
                                            else{
                                                NSLog(@"%@", error);
                                            }
                                        }];
}

#pragma mark - UIAccelerometer callback

- (void)outputAccelertionData:(CMAcceleration)acceleration{
    UIInterfaceOrientation orientationNew;
    
    if (acceleration.x >= 0.75) {
        orientationNew = UIInterfaceOrientationLandscapeLeft;
    }
    else if (acceleration.x <= -0.75) {
        orientationNew = UIInterfaceOrientationLandscapeRight;
    }
    else if (acceleration.y <= -0.75) {
        orientationNew = UIInterfaceOrientationPortrait;
    }
    else if (acceleration.y >= 0.75) {
        orientationNew = UIInterfaceOrientationPortraitUpsideDown;
    }
    else {
        // Consider same as last time
        return;
    }
    
    if (orientationNew == orientationLast)
        return;
    
    //    NSLog(@"Going from %@ to %@!", [[self class] orientationToText:orientationLast], [[self class] orientationToText:orientationNew]);
    
    orientationLast = orientationNew;
}

#ifdef DEBUG
+(NSString*)orientationToText:(const UIInterfaceOrientation)ORIENTATION {
    switch (ORIENTATION) {
        case UIInterfaceOrientationPortrait:
            return @"UIInterfaceOrientationPortrait";
        case UIInterfaceOrientationPortraitUpsideDown:
            return @"UIInterfaceOrientationPortraitUpsideDown";
        case UIInterfaceOrientationLandscapeLeft:
            return @"UIInterfaceOrientationLandscapeLeft";
        case UIInterfaceOrientationLandscapeRight:
            return @"UIInterfaceOrientationLandscapeRight";
    }
    return @"Unknown orientation!";
}
#endif

#pragma mark - Camera Initialization

//AVCaptureSession to show live video feed in view
- (void) initializeCamera {
    if (session)
        [session release], session=nil;
    
    self.imagePreview.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width);
    self.imagePreview.center = CGPointMake(self.view.frame.size.width / 2, 65 + (self.view.frame.size.height - (65 + 90)) / 2);
    
    self.captureImage.frame = self.imagePreview.frame;
    
    session = [[AVCaptureSession alloc] init];
	session.sessionPreset = AVCaptureSessionPresetPhoto;
	
    if (captureVideoPreviewLayer)
        [captureVideoPreviewLayer release], captureVideoPreviewLayer=nil;
    
	captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
//    [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
	captureVideoPreviewLayer.frame = self.imagePreview.bounds;
	[self.imagePreview.layer addSublayer:captureVideoPreviewLayer];
	
    UIView *view = [self imagePreview];
    CALayer *viewLayer = [view layer];
    [viewLayer setMasksToBounds:YES];
    
    CGRect bounds = [view bounds];
    [captureVideoPreviewLayer setFrame:bounds];
    
    NSArray *devices = [AVCaptureDevice devices];
    AVCaptureDevice *frontCamera=nil;
    AVCaptureDevice *backCamera=nil;
    
    // check if device available
    if (devices.count==0) {
        NSLog(@"No Camera Available");
        [self disableCameraDeviceControls];
        return;
    }
    
    for (AVCaptureDevice *device in devices) {
        
        NSLog(@"Device name: %@", [device localizedName]);
        
        if ([device hasMediaType:AVMediaTypeVideo]) {
            
            if ([device position] == AVCaptureDevicePositionBack) {
                NSLog(@"Device position : back");
                backCamera = device;
            }
            else {
                NSLog(@"Device position : front");
                frontCamera = device;
            }
        }
    }
    
    if (!FrontCamera) {
        
        if ([backCamera hasFlash]){
            [backCamera lockForConfiguration:nil];
            [backCamera unlockForConfiguration];
        }
        else{
            if ([backCamera isFlashModeSupported:AVCaptureFlashModeOff]) {
                [backCamera lockForConfiguration:nil];
                [backCamera setFlashMode:AVCaptureFlashModeOff];
                [backCamera unlockForConfiguration];
            }
        }
        
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
        if (!input) {
            NSLog(@"ERROR: trying to open camera: %@", error);
        }
        [session addInput:input];
    }
    
    if (FrontCamera) {
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
        if (!input) {
            NSLog(@"ERROR: trying to open camera: %@", error);
        }
        [session addInput:input];
    }
    
    if (stillImageOutput)
        [stillImageOutput release], stillImageOutput=nil;
    
    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil] autorelease];
    [stillImageOutput setOutputSettings:outputSettings];
    
    [session addOutput:stillImageOutput];
    
	[session startRunning];
    NSLog(@"Start!!!");
    [self SlideShow];
}

-(void) SlideShow
{
    slide_Top.hidden = NO;
    slide_Bottom.hidden = NO;
    [UIView animateWithDuration:0.1 animations:^{
        slide_Bottom.frame = CGRectMake(0, 212, slide_Bottom.frame.size.width, slide_Bottom.frame.size.height);
        slide_Top.frame = CGRectMake(0, 0, slide_Top.frame.size.width, slide_Top.frame.size.height);
    } completion:nil];
    [UIView animateWithDuration:0.1 delay:1 options:UIViewAnimationOptionCurveEaseIn animations:^{
        slide_Bottom.frame = CGRectMake(0, 568, slide_Bottom.frame.size.width, slide_Bottom.frame.size.height);
        slide_Top.frame = CGRectMake(0, -212, slide_Top.frame.size.width, slide_Top.frame.size.height);
    }completion:nil];
//    [UIView animateWithDuration:1.0 animations:^{
//        slide_Bottom.frame = CGRectMake(0, 568, slide_Bottom.frame.size.width, slide_Bottom.frame.size.height);
//        slide_Top.frame = CGRectMake(0, -212, slide_Top.frame.size.width, slide_Top.frame.size.height);
//    }completion:nil];
//    slide_Top.hidden = YES;
//    slide_Bottom.hidden = YES;
}

- (IBAction)snapImage:(id)sender {
    [self.photoCaptureButton setEnabled:NO];
    
    if (!haveImage) {
        self.captureImage.image = nil; //remove old image from view
        self.captureImage.hidden = NO; //show the captured image view
        self.imagePreview.hidden = YES; //hide the live video feed
        [self capImage];
    }
    else {
        self.captureImage.hidden = YES;
        self.imagePreview.hidden = NO;
        haveImage = NO;
    }
    [self SlideShow];
}

- (void) capImage { //method to capture image from AVCaptureSession video feed
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in stillImageOutput.connections) {
        
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        
        if (videoConnection) {
            break;
        }
    }
    
    NSLog(@"about to request a capture from: %@", stillImageOutput);
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        
        if (imageSampleBuffer != NULL) {
            
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
            [self processImage:[UIImage imageWithData:imageData]];
        }
    }];
}

- (UIImage*)imageWithImage:(UIImage *)sourceImage scaledToWidth:(float) i_width
{
    float oldWidth = sourceImage.size.width;
    float oldHeight = sourceImage.size.height;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = oldHeight * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
//    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
//    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
//    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(newWidth, newHeight), YES, 1.0);
    if(FrontCamera)
    {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(ctx, newWidth, 0.0);
        CGContextScaleCTM(ctx, -1.0, 1.0);
    }
    //CGContextDrawImage(ctx, sourceImage.CGImage, CGRectMake(0.0, 0.0, oldWidth, oldHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void) processImage:(UIImage *)image { //process captured image, crop, resize and rotate
    haveImage = YES;
    photoFromCam = YES;
    //Actual AVCaptureVideoPreviewLayer's view Height is 852
    // Resize image to 640x640
    // Resize image
    NSLog(@"Image size %@",NSStringFromCGSize(image.size));
    
    float finalImageWidth = 640;
    
    UIImage *smallImage = [self imageWithImage:image scaledToWidth:finalImageWidth]; //UIGraphicsGetImageFromCurrentImageContext();
    
    NSLog(@"New ImageSize %@", NSStringFromCGSize(smallImage.size));
    
    CGRect cropRect = CGRectMake(0, (smallImage.size.height - smallImage.size.width) / 2, smallImage.size.width, smallImage.size.width);
    CGImageRef imageRef = CGImageCreateWithImageInRect([smallImage CGImage], cropRect);
    
    croppedImageWithoutOrientation = [[UIImage imageWithCGImage:imageRef] copy];
    
    UIImage *croppedImage = nil;
    //    assetOrientation = ALAssetOrientationUp;
    
    // adjust image orientation
    NSLog(@"orientation: %ld",orientationLast);
    orientationAfterProcess = orientationLast;
    switch (orientationLast) {
        case UIInterfaceOrientationPortrait:
            NSLog(@"UIInterfaceOrientationPortrait");
            croppedImage = [UIImage imageWithCGImage:imageRef];
            break;
            
        case UIInterfaceOrientationPortraitUpsideDown:
            NSLog(@"UIInterfaceOrientationPortraitUpsideDown");
            croppedImage = [[[UIImage alloc] initWithCGImage: imageRef
                                                       scale: 1.0
                                                 orientation: UIImageOrientationDown] autorelease];
            break;
            
        case UIInterfaceOrientationLandscapeLeft:
            NSLog(@"UIInterfaceOrientationLandscapeLeft");
            croppedImage = [[[UIImage alloc] initWithCGImage: imageRef
                                                       scale: 1.0
                                                 orientation: UIImageOrientationRight] autorelease];
            break;
            
        case UIInterfaceOrientationLandscapeRight:
            NSLog(@"UIInterfaceOrientationLandscapeRight");
            croppedImage = [[[UIImage alloc] initWithCGImage: imageRef
                                                       scale: 1.0
                                                 orientation: UIImageOrientationLeft] autorelease];
            break;
            
        default:
            croppedImage = [UIImage imageWithCGImage:imageRef];
            break;
    }
    
    CGImageRelease(imageRef);
    
    [self.captureImage setImage:croppedImage];
    [self.ivPhotoOnComment setImage:croppedImage];
    
    [self setCapturedImage];
}

- (void)setCapturedImage{
    // Stop capturing image
    [session stopRunning];
    
    // Hide Top/Bottom controller after taking photo for editing
    //[self hideControllers];
    [self showControllers];
}

#pragma mark - Device Availability Controls
- (void)disableCameraDeviceControls{
    self.photoCaptureButton.enabled = NO;
}

#pragma mark - UIImagePicker Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //Getting Geotag from Image
    NSURL *url = [info objectForKey:UIImagePickerControllerReferenceURL];
    if (url) {
        ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset) {
            self.imageGeo = [myasset valueForProperty:ALAssetPropertyLocation];
            // location contains lat/long, timestamp, etc
            // extracting the image is more tricky and 5.x beta ALAssetRepresentation has bugs!
            NSLog(@"Location %f %f", self.imageGeo.coordinate.latitude, self.imageGeo.coordinate.longitude);
        };
        ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError *myerror) {
            NSLog(@"cant get image - %@", [myerror localizedDescription]);
        };
        ALAssetsLibrary *assetsLib = [[ALAssetsLibrary alloc] init];
        [assetsLib assetForURL:url resultBlock:resultblock failureBlock:failureblock];
    }
    
    
    //Get Image
    if (info)
    {
        photoFromCam = NO;
        
        UIImage* outputImage = [info objectForKey:UIImagePickerControllerEditedImage];
        NSLog(@"Output Imagesize %@", NSStringFromCGSize(outputImage.size));
        if (outputImage == nil) {
            outputImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        
        if (outputImage) {
            self.captureImage.hidden = NO;
            self.captureImage.image = outputImage;
            self.ivPhotoOnComment.image = outputImage;
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
            // Hide Top/Bottom controller after taking photo for editing
            [self showControllers];
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    initializeCamera = YES;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Button clicks
-(IBAction)switchToLibrary:(id)sender {
    
    if (session) {
        [session stopRunning];
    }
    
    //    self.captureImage = nil;
    
    //    UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
    //    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //    imagePickerController.delegate = self;
    //    imagePickerController.allowsEditing = YES;
    [self presentViewController:imgPicker animated:YES completion:NULL];
}


-(IBAction) cancel:(id)sender
{
    slide_Bottom.hidden = YES;
    slide_Top.hidden = YES;
    if ([delegate respondsToSelector:@selector(yCameraControllerDidCancel)]) {
        [delegate yCameraControllerDidCancel];
    }
    
    // Dismiss self view controller
    self.view_Top.hidden = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)donePhotoCapture:(id)sender
{
    slide_Bottom.hidden = YES;
    slide_Top.hidden = YES;
    if ([delegate respondsToSelector:@selector(didFinishPickingImage:)]) {
        [delegate didFinishPickingImage:self.captureImage.image];
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.view_Location.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }];
    
    [self startSearchWithString:@""];
    NSLog(@"Venues = %@", self.venues);
}

- (IBAction)onNexttoLocations:(id)sender
{
    if ([delegate respondsToSelector:@selector(didFinishPickingImage:)]) {
        [delegate didFinishPickingImage:self.captureImage.image];
    }
    
    // Dismiss self view controller
    [UIView animateWithDuration:0.2 animations:^{
        self.view_Location.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }];
    
    [self startSearchWithString:@""];
    NSLog(@"Venues = %@", self.venues);
}

- (IBAction)retakePhoto:(id)sender
{
    [self.photoCaptureButton setEnabled:YES];
    self.captureImage.image = nil;
    self.captureImage.hidden = YES;
    self.imagePreview.hidden = NO;
    // Show Camera device controls
    //[self showControllers];
    [self hideControllers];
    
    haveImage=NO;
    FrontCamera = YES;
    [self performSelector:@selector(initializeCamera) withObject:nil afterDelay:0.001];
}

- (IBAction)switchCamera:(UIButton *)sender
{ //switch cameras front and rear cameras
    // Stop current recording process
    [session stopRunning];
    
    if (sender.selected) {  // Switch to Back camera
        sender.selected = NO;
        FrontCamera = YES;
        [self performSelector:@selector(initializeCamera) withObject:nil afterDelay:0.001];
    }
    else {                  // Switch to Front camera
        sender.selected = YES;
        FrontCamera = NO;
        [self performSelector:@selector(initializeCamera) withObject:nil afterDelay:0.001];
    }
}

- (IBAction)toogleFlash:(UIButton *)sender
{
    if (!FrontCamera) {
        if (sender.selected) { // Set flash off
            [sender setSelected:NO];
            
            NSArray *devices = [AVCaptureDevice devices];
            for (AVCaptureDevice *device in devices) {
                
                NSLog(@"Device name: %@", [device localizedName]);
                
                if ([device hasMediaType:AVMediaTypeVideo]) {
                    
                    if ([device position] == AVCaptureDevicePositionBack) {
                        NSLog(@"Device position : back");
                        if ([device hasFlash]){
                            
                            [device lockForConfiguration:nil];
                            [device setFlashMode:AVCaptureFlashModeOff];
                            [device unlockForConfiguration];
                            
                            break;
                        }
                    }
                }
            }
            
        }
        else{                  // Set flash on
            [sender setSelected:YES];
            
            NSArray *devices = [AVCaptureDevice devices];
            for (AVCaptureDevice *device in devices) {
                
                NSLog(@"Device name: %@", [device localizedName]);
                
                if ([device hasMediaType:AVMediaTypeVideo]) {
                    
                    if ([device position] == AVCaptureDevicePositionBack) {
                        NSLog(@"Device position : back");
                        if ([device hasFlash]){
                            
                            [device lockForConfiguration:nil];
                            [device setFlashMode:AVCaptureFlashModeOn];
                            [device unlockForConfiguration];
                            
                            break;
                        }
                    }
                }
            }
            
        }
    }
}

#pragma mark -
#pragma mark Add BlurEffect on top and bottom of the Image
- (UIImage*)generateBlurImage
{
    UIImage *upper = [[UIImage alloc] init];
    UIImage *bottom = [[UIImage alloc] init];
    if (self.captureImage.image.size.height>=640)
    {
        CGImageRef imageRefUp = CGImageCreateWithImageInRect([self.captureImage.image CGImage], CGRectMake(0, 0, 640, 96));
        upper = [UIImage imageWithCGImage:imageRefUp];
        upper = [upper applyBlurWithRadius:55.0f tintColor:[UIColor clearColor] saturationDeltaFactor:1.8 maskImage:nil];
        CGImageRelease(imageRefUp);
        
        CGImageRef imageRef = CGImageCreateWithImageInRect([self.captureImage.image CGImage], CGRectMake(0, 518, 640, 122));
        bottom = [UIImage imageWithCGImage:imageRef];
        bottom = [bottom applyBlurWithRadius:55.0f tintColor:[UIColor clearColor] saturationDeltaFactor:1.8 maskImage:nil];
        CGImageRelease(imageRef);
    }
    else
    {
        upper = [self imageWithColor:[UIColor blackColor] andSize:CGSizeMake(640, 96)];
        bottom = [self imageWithColor:[UIColor blackColor] andSize:CGSizeMake(640, 122)];
    }
    
    UIImage *newImage = [self mergeImage:upper withImage:self.captureImage.image withImage:bottom];
    return newImage;
}

- (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size

{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage*)mergeImage:(UIImage*)first withImage:(UIImage*)second withImage:(UIImage*)third
{
    NSLog(@"upimage size = %@", NSStringFromCGSize(first.size));
    NSLog(@"middle size = %@", NSStringFromCGSize(second.size));
    NSLog(@"bottom size = %@", NSStringFromCGSize(third.size));
    // get size of the first image
    CGFloat firstWidth = first.size.width;
    CGFloat firstHeight = first.size.height;
    
    // get size of the second image
    CGFloat secondWidth = second.size.width;
    CGFloat secondHeight = second.size.height;
    
    CGFloat thirdWidth = third.size.width;
    CGFloat thirdHeight = third.size.height;
    
    // build merged size
    CGSize mergedSize = CGSizeMake(640, firstHeight+secondHeight+thirdHeight);
    
    // capture image context ref
    UIGraphicsBeginImageContext(mergedSize);
    
    //Draw images onto the context
    [first drawInRect:CGRectMake(0, 0, firstWidth, firstHeight)];
    [second drawInRect:CGRectMake(0, firstHeight, secondWidth, secondHeight)];
    [third drawInRect:CGRectMake(0, firstHeight+secondHeight, thirdWidth, thirdHeight)];
    
    // assign context to new UIImage
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // end context
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark-
#pragma mark OtherButton Actions

- (IBAction)nextOnLocation:(id)sender
{
    CGRect rtScreen = [[UIScreen mainScreen] bounds];
    
    float screenWidth = CGRectGetWidth(rtScreen);
    float screenHeight = CGRectGetHeight(rtScreen);
    
    postInfo.address= @"";
    self.viewLocationAndShareButtonsOnComment.hidden = YES;
    
    [UIView animateWithDuration:0.2 animations:^{
        view_Location_NeaerBy.frame = CGRectMake(- screenWidth, 0, screenWidth, screenHeight);
        view_CommentaboutPhoto.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    }];
    
    [txt_CommentPhoto becomeFirstResponder];
}

- (IBAction)nextOnNearBy:(id)sender
{
    CGRect rtScreen = [[UIScreen mainScreen] bounds];
    
    float screenWidth = CGRectGetWidth(rtScreen);
    float screenHeight = CGRectGetHeight(rtScreen);
    
    [UIView animateWithDuration:0.2 animations:^{
        view_location_searched.frame = CGRectMake(- screenWidth, 0, screenWidth, screenHeight);
        view_CommentaboutPhoto.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    }];
    [txt_CommentPhoto becomeFirstResponder];

    postInfo.address = @"";
}

- (IBAction)onShareFacebook:(id)sender
{
    
}

- (IBAction)onShareInstagram:(id)sender
{
    
}

#pragma mark - UI Control Helpers
- (void)hideControllers{
    [UIView animateWithDuration:0.2 animations:^{
        self.view_Top.frame = CGRectMake(0, - self.view_Top.frame.size.height, self.view_Top.frame.size.width, self.view_Top.frame.size.height);
        self.view_Retake.frame = CGRectMake(0, self.view.frame.size.height, self.view_Retake.frame.size.width, self.view_Retake.frame.size.height);
    } completion:nil];
    self.view_Top.hidden = YES;
}

- (void)showControllers{
    self.view_Top.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.view_Top.frame = CGRectMake(0, 0, self.view_Top.frame.size.width, self.view_Top.frame.size.height);
        self.view_Retake.frame = CGRectMake(0, self.view.frame.size.height - self.view_Retake.frame.size.height, self.view_Retake.frame.size.width, self.view_Retake.frame.size.height);
    } completion:nil];
}

#pragma -mark LocationManage

#pragma -mark searchBar Delegates
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    self.searchBar.showsCancelButton = YES;
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.tbl_NearBy.frame = CGRectMake(self.tbl_NearBy.frame.origin.x, self.tbl_NearBy.frame.origin.y, self.tbl_NearBy.frame.size.width, 256);
    dimButton.hidden = NO;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    dimButton.hidden = YES;
    self.tbl_NearBy.hidden = YES;
    [self.tbl_Search reloadData];
    if ([searchBar.text isEqualToString:@""])
    {
        self.tbl_NearBy.hidden = NO;
        dimButton.hidden = NO;
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
//    slide_Bottom.hidden = YES;
//    slide_Top.hidden = YES;
//    [self dismissViewControllerAnimated:YES completion:nil];
    
    dimButton.hidden = YES;
    self.tbl_NearBy.hidden = NO;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    self.tbl_NearBy.frame = CGRectMake(0, self.tbl_NearBy.frame.origin.y, self.tbl_NearBy.frame.size.width, self.tbl_NearBy.frame.size.height+216);
    //    self.searchBar.placeholder = @"Find or create a location                           ";
    self.searchBar.showsCancelButton = NO;
}

- (IBAction)onDimButton:(id)sender
{
    dimButton.hidden = YES;
    [self.searchBar resignFirstResponder];
    self.tbl_NearBy.frame = CGRectMake(0, self.tbl_NearBy.frame.origin.y, self.tbl_NearBy.frame.size.width, self.tbl_NearBy.frame.size.height+216);
//    self.searchBar.placeholder = @"Find or create a location                           ";
    self.searchBar.showsCancelButton = NO;
}

- (IBAction)onCancelLocation:(id)sender
{
    slide_Bottom.hidden = YES;
    slide_Top.hidden = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
    
//    self.view_Location.frame = CGRectMake(320, 0, self.view_Location.frame.size.width, self.view_Location.frame.size.height);
}

- (IBAction)onBacktoSearchTable:(id)sender
{
    [UIView animateWithDuration:0.2 animations:^{
        view_location_searched.frame = CGRectMake(320, 0, view_location_searched.frame.size.width, view_location_searched.frame.size.height);
        view_Location_NeaerBy.frame = CGRectMake(0, 0, view_Location_NeaerBy.frame.size.width, view_Location_NeaerBy.frame.size.height);
    }];
    [self.searchBar becomeFirstResponder];
    dimButton.hidden = YES;
}



#pragma -mark TableViewDelegate

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return  1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (tableView.tag) {
        case 0:
            return [self.near_venues count];
            break;
        case 1:
            return 2;
            break;
        case 2:
            if ([self.venues count]==0) {
                return 1;
            }
            else{
                return [self.venues count];
            }
            break;
        default:
            break;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 50;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier ];
//    if (cell == nil)
//    {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//    }
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel *lbl_detail = [[UILabel alloc] init];
    UILabel *lbl_main = [[UILabel alloc] init];
    lbl_main.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    lbl_detail.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14];
    lbl_detail.textColor = [UIColor colorWithRed:(128/255.f) green:(120/255.f) blue:(128/255.f) alpha:1];
    FSVenue *near_venue = [[FSVenue alloc] init];
    FSVenue *venue = [[FSVenue alloc] init];
    if (tableView == self.tbl_NearBy) {
        if ([self.near_venues count]!=0) {
            near_venue = self.near_venues[indexPath.row];
        }
    }
    else if (tableView == self.tbl_Result){
        if ([self.venues count] !=0) {
            venue = self.venues[indexPath.row];
        }
    }
    
    switch (tableView.tag) {
        case 0://tbl_NearyBy
            lbl_main.frame = CGRectMake(15, 5, 290, 20);
            lbl_detail.frame = CGRectMake(15, 28, 290, 17);
            [cell addSubview:lbl_main];
            [cell addSubview:lbl_detail];
            lbl_main.text = near_venue.name;
            lbl_detail.text = near_venue.location.fullAdd;
            //lbl_detail.text = @"California Street & Powell Street";
            break;
        case 1: //tbl_Search
            lbl_main.frame = CGRectMake(50, 5, 220, 20);
            lbl_detail.frame = CGRectMake(50, 28, 220, 17);
            [cell addSubview:lbl_detail];
            [cell addSubview:lbl_main];
            if (indexPath.row == 0) {
                lbl_main.text = [NSString stringWithFormat:@"Create \"%@\"", self.searchBar.text];
                lbl_detail.text = @"Create a custom location";
                UIImageView *geo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"graygeo.png"]];
                geo.frame = CGRectMake(18, 15, 14, 21);
                [cell addSubview:geo];
            }
            else{
                lbl_main.text = [NSString stringWithFormat:@"Find \"%@\"", self.searchBar.text];
                lbl_detail.text = @"Search more places nearby";
                UIImageView *search = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search icon.png"]];
                search.frame = CGRectMake(17, 17, 16, 16);
                [cell addSubview:search];
                UIImageView *detail = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sub_view_icon.png"]];
                detail.frame = CGRectMake(292, 21, 10, 14);
                [cell addSubview:detail];
            }
            break;
        case 2: //tbl_Result
            lbl_main.frame = CGRectMake(15, 5, 290, 20);
            lbl_detail.frame = CGRectMake(15, 28, 290, 17);
            [cell addSubview:lbl_main];
            [cell addSubview:lbl_detail];
            lbl_main.text = venue.name;
            lbl_detail.text = venue.location.fullAdd;
            //lbl_detail.text = @"California Street & Powell Street";
            if ([self.venues count] == 0) {
                lbl_main.text = @"No Results";
            }
            break;
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect rtScreen = [[UIScreen mainScreen] bounds];
    
    float screenWidth = CGRectGetWidth(rtScreen);
    float screenHeight = CGRectGetHeight(rtScreen);
    
    FSVenue *near_venue = [[FSVenue alloc] init];
    if ([self.near_venues count] !=0) {
        near_venue = [self.near_venues objectAtIndex:indexPath.row];
    }
    FSVenue *venue = [[FSVenue alloc] init];
    if ([self.venues count] !=0) {
        venue = [self.venues objectAtIndex:indexPath.row];
    }
    if (tableView.tag == 0) /*tbl_NearBy*/
    {
        postInfo.lat = [NSString stringWithFormat:@"%f", near_venue.location.coordinate.latitude];
        postInfo.lng = [NSString stringWithFormat:@"%f", near_venue.location.coordinate.longitude];
        postInfo.address = near_venue.name;
        //            [self postFeed];
        lbl_Locationname.text = postInfo.address;
        [UIView animateWithDuration:0.2 animations:^{
            view_Location_NeaerBy.frame = CGRectMake(- screenWidth, 0, screenWidth, screenHeight);
            view_CommentaboutPhoto.frame = CGRectMake(0, 0, screenWidth, screenHeight);
        }];
        [txt_CommentPhoto becomeFirstResponder];
    }
    else if (tableView.tag == 1)/*tbl_Search*/
    {
        if (indexPath.row == 1)
        {
            [self startSearchWithString:self.searchBar.text];
            [self.searchBar resignFirstResponder];
            [UIView animateWithDuration:0.2 animations:^{
                view_location_searched.frame = CGRectMake(0, 0, screenWidth, screenHeight);
                view_Location_NeaerBy.frame = CGRectMake(- screenWidth, 0, screenWidth, screenHeight);
            }];
        }
        else
        {
            postInfo.lat = [NSString stringWithFormat:@"%f",self.location.coordinate.latitude];
            postInfo.lng = [NSString stringWithFormat:@"%f", self.location.coordinate.longitude];
            postInfo.address = self.searchBar.text;
//          [self postFeed];
            lbl_Locationname.text = postInfo.address;
            [UIView animateWithDuration:0.2 animations:^{
                view_Location_NeaerBy.frame = CGRectMake(- screenWidth, 0, screenWidth, screenHeight);
                view_CommentaboutPhoto.frame = CGRectMake(0, 0, screenWidth, screenHeight);
            }];
            
            [txt_CommentPhoto becomeFirstResponder];
        }
    }
    else if (tableView.tag == 2)/*tbl_Result*/
    {
        postInfo.lat = [NSString stringWithFormat:@"%f", venue.location.coordinate.latitude];
        postInfo.lng = [NSString stringWithFormat:@"%f", venue.location.coordinate.longitude];
//      postInfo.address = venue.location.address;
        postInfo.address = venue.name;
//      [self postFeed];
        lbl_Locationname.text = postInfo.address;
        [UIView animateWithDuration:0.2 animations:^{
            view_location_searched.frame = CGRectMake(- screenWidth, 0, screenWidth, screenHeight);
            view_CommentaboutPhoto.frame = CGRectMake(0, 0, screenWidth, screenHeight);
        }];
        
        [txt_CommentPhoto becomeFirstResponder];
    }
    
    self.viewLocationAndShareButtonsOnComment.hidden = NO;
}

#pragma -mark FourSquare API

//- (void)locationManager:(CLLocationManager *)manager
//     didUpdateLocations:(NSArray *)locations
//{
//    
//}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    [self.locationManager stopUpdatingLocation];
    self.location = newLocation;
    [self startSearchWithString:nil];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    [self.locationManager stopUpdatingLocation];
}

- (void)startSearchWithString:(NSString *)string {
    [self setVenues:[[NSArray alloc] init]];
    [self.tbl_Result reloadData];
    NSLog(@"MyLocation %f %f", self.location.coordinate.longitude, self.location.coordinate.latitude);
    NSLog(@"Image Location %f %f", self.imageGeo.coordinate.longitude, self.imageGeo.coordinate.latitude);
    CLLocation *searchPoint = [[CLLocation alloc] init];
    if ((self.imageGeo.coordinate.longitude == 0) && (self.imageGeo.coordinate.latitude == 0))
    {
        searchPoint = self.location;
    }
    else{
        searchPoint = self.imageGeo;
    }
    //MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.lastSearchOperation cancel];
    self.lastSearchOperation = [Foursquare2
                                venueSearchNearByLatitude:@(searchPoint.coordinate.latitude)
                                longitude:@(searchPoint.coordinate.longitude)
                                query:string
                                limit:nil
                                intent:intentCheckin
                                radius:@(1000)
                                categoryId:nil
                                callback:^(BOOL success, id result){
                                    if (success) {
                                        //[MBProgressHUD hideHUDForView:self.view animated:YES];
                                        NSDictionary *dic = result;
                                        NSArray *venues = [dic valueForKeyPath:@"response.venues"];
                                        FSConverter *converter = [[FSConverter alloc] init];
                                        if ([string isEqualToString:@""]) {
                                            self.near_venues = [converter convertToObjects:venues];
                                        }
                                        self.venues = [converter convertToObjects:venues];
                                        [self.tbl_NearBy reloadData];
                                        [self.tbl_Result reloadData];
//                                        NSLog(@"%@", result);
                                        NSLog(@"%@", result);
                                    } else {
//                                        NSLog(@"%@",result);
                                    }
                                }];
}

#pragma -mark -
#pragma -mark Post

- (void)postFeed
{
//    self.dataImg = UIImageJPEGRepresentation(self.captureImage.image, 1.0);
    UIImage *postImage = [self generateBlurImage];
    NSLog(@"postImage Size %@", NSStringFromCGSize(postImage.size));
//    self.dataImg = UIImageJPEGRepresentation(postImage, 1.0);
    self.dataImg = UIImageJPEGRepresentation(self.captureImage.image, 1.0f);
    NSLog(@"Final ImageSize %@", NSStringFromCGSize(self.captureImage.image.size));
    NSLog(@"%@", postInfo);
    //    [self dismissViewControllerAnimated:YES completion:nil];
    
    //Encoding Text to UTF8 for Emoji
//    NSData *data = [postInfo.address dataUsingEncoding:NSNonLossyASCIIStringEncoding];
//    NSString *valueUnicode = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"unicode %@", valueUnicode);
    
    NSString *address = [CommonMethods encodeUTF8:postInfo.address];
    NSString *firstComment = [CommonMethods encodeUTF8:txt_CommentPhoto.text];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:ServerURL]];
    [request setRequestMethod:@"POST"];
    [request addPostValue:@"postfeed" forKey:@"service"];
    [request addPostValue:postInfo.userid forKey:@"userid"];
    if (address.length > 0)
    {
        [request addPostValue:address forKey:@"address"];
        [request addPostValue:postInfo.lng forKey:@"lng"];
        [request addPostValue:postInfo.lat forKey:@"lat"];
    }
    else{
        [request addPostValue:[NSString stringWithFormat:@"%f", self.location.coordinate.longitude] forKey:@"lng"];
        [request addPostValue:[NSString stringWithFormat:@"%f", self.location.coordinate.latitude] forKey:@"lat"];
    }
    if (txt_CommentPhoto.text.length > 0) {
        [request addPostValue:firstComment forKey:@"description"];
    }
    
    if (self.dataImg) {
        [request addData:self.dataImg withFileName:@"photo.jpg" andContentType:@"image/jpeg" forKey:@"photo"];
    }
    [request setTimeOutSeconds:30];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(Post_didSuccess:)];
    [request setDidFailSelector:@selector(Post_didFail:)];
    [request startAsynchronous];
}

- (void) Post_didSuccess:(ASIFormDataRequest*)request
{
    slide_Bottom.hidden = YES;
    slide_Top.hidden = YES;
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    app.isUpdatedFeeds = YES;
    
    if (request.responseStatusCode == 200) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
        NSString *responseString = request.responseString;
        
        NSLog(@"%@", responseString);
        
        //Send Push Notification to Users
        SBJSON *json = [SBJSON new];
        NSDictionary *dict = [json objectWithString:request.responseString error:nil];
        
        if(dict != nil)
        {
        }
    }
    else
    {
        [CommonMethods showAlertUsingTitle:@"Wasted Selfie" andMessage:@"Can't access Server"];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void) Post_didFail:(ASIFormDataRequest*)request
{
    slide_Bottom.hidden = YES;
    slide_Top.hidden = YES;
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [CommonMethods showAlertUsingTitle:@"Wasted Selfie" andMessage:@"Internet Connection Error!"];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma -mark - 
#pragma -mark Comment View

- (IBAction)ondismissComment:(id)sender
{
    CGRect rtScreen = [[UIScreen mainScreen] bounds];
    
    float screenWidth = CGRectGetWidth(rtScreen);
    float screenHeight = CGRectGetHeight(rtScreen);
    
    [UIView animateWithDuration:0.2 animations:^{
        if (view_location_searched.frame.origin.x == - screenWidth) {
            view_location_searched.frame = CGRectMake(0, 0, screenWidth, screenHeight);
            [txt_CommentPhoto resignFirstResponder];
        }
        else{
            view_Location_NeaerBy.frame = CGRectMake(0, 0, screenWidth, screenHeight);
            if (dimButton.hidden == YES) {
                [txt_CommentPhoto resignFirstResponder];
            }
            else{
                [self.searchBar becomeFirstResponder];
            }
        }
        view_CommentaboutPhoto.frame = CGRectMake(screenWidth, 0, screenWidth, screenHeight);
    }];
}

- (IBAction)onShare:(id)sender
{
    [txt_CommentPhoto resignFirstResponder];
    
    [self postFeed];
}

#pragma -mark -
#pragma -mark UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if([textView.text isEqualToString:@"Write something here..."])
    {
        textView.text = @"";
    }
    
    return YES;
}

@end
