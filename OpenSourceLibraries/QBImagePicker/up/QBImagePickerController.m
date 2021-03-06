//
//  QBImagePickerController.m
//  QBImagePicker
//
//  Created by Katsuma Tanaka on 2015/04/03.
//  Copyright (c) 2015 Katsuma Tanaka. All rights reserved.
//

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000


#import "QBImagePickerController.h"
#import <Photos/Photos.h>

// ViewControllers
#import "QBAlbumsViewController.h"

@interface QBImagePickerController ()

@property (nonatomic, strong) CBNavigationController *albumsNavigationController;

@property (nonatomic, strong) NSBundle *assetBundle;

@end

@implementation QBImagePickerController

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
//        self.edgesForExtendedLayout = UIRectEdgeBottom;
        // Set default values
        self.assetCollectionSubtypes = @[
                                         @(PHAssetCollectionSubtypeAlbumRegular),
                                         @(PHAssetCollectionSubtypeAlbumSyncedEvent),
                                         @(PHAssetCollectionSubtypeAlbumSyncedFaces),
                                         @(PHAssetCollectionSubtypeAlbumSyncedAlbum),
                                         @(PHAssetCollectionSubtypeAlbumImported),
                                         @(PHAssetCollectionSubtypeSmartAlbumRecentlyAdded),
                                         @(PHAssetCollectionSubtypeSmartAlbumUserLibrary)
                                         ];

        
        self.minimumNumberOfSelection = 1;
        self.numberOfColumnsInPortrait = 4;
        self.numberOfColumnsInLandscape = 7;
        
        _selectedAssets = [NSMutableOrderedSet orderedSet];
        
        // Get asset bundle
        self.assetBundle = [NSBundle bundleForClass:[self class]];
        NSString *bundlePath = [self.assetBundle pathForResource:@"QBImagePicker" ofType:@"bundle"];
        if (bundlePath) {
            self.assetBundle = [NSBundle bundleWithPath:bundlePath];
        }
        
        [self setUpAlbumsViewController];
        
        // Set instance
        QBAlbumsViewController *albumsViewController = (QBAlbumsViewController *)self.albumsNavigationController.topViewController;
        albumsViewController.imagePickerController = self;
        
    }
    
    return self;
}




- (void)pushView:(UIViewController *)viewController animated:(BOOL)animated
{
    
    NSLog(@"pushView");
//    if(![self.navigationController.topViewController isKindOfClass:[viewController class]])
//    CBNavigationController *nv = [[CBNavigationController alloc]initWithRootViewController:viewController];
    
    dispatch_async(dispatch_get_main_queue(), ^{
    [self.albumsNavigationController pushViewController:(CBNavigationController *)viewController animated:animated];
    });
    
#ifdef BearTalk
    NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"themeColor"]; // [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    [self.albumsNavigationController.navigationBar setBarTintColor:[NSKeyedUnarchiver unarchiveObjectWithData:colorData]];
    [viewController.navigationController.navigationBar setBarTintColor:[NSKeyedUnarchiver unarchiveObjectWithData:colorData]];
#endif
}


- (void)setUpAlbumsViewController
{
    NSLog(@"setupalbumsviewcontroller upper 8.0");
    // Add QBAlbumsViewController as a child
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"QBImagePicker" bundle:self.assetBundle];
    CBNavigationController *navigationController = [storyboard instantiateViewControllerWithIdentifier:@"QBAlbumsNavigationController"];

    
    // Configure navigation item
    
    [self addChildViewController:navigationController];
    
    navigationController.view.frame = self.view.bounds;
    [self.view addSubview:navigationController.view];
    
    [navigationController didMoveToParentViewController:self];
    
    self.albumsNavigationController = navigationController;
    
}


@end

#else
/*
 Copyright (c) 2013 Katsuma Tanaka
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "QBImagePickerController.h"

// Views
#import "QBImagePickerGroupCell.h"

// Controllers
#import "QBAssetCollectionViewController.h"

@interface QBImagePickerController ()

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *assetsGroups;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) UIBarStyle previousBarStyle;
@property (nonatomic, assign) BOOL previousBarTranslucent;
@property (nonatomic, assign) UIStatusBarStyle previousStatusBarStyle;

- (void)cancel;
- (NSDictionary *)mediaInfoFromAsset:(ALAsset *)asset;

@end

@implementation QBImagePickerController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        /* Check sources */
        NSLog(@"upper 8.0 init");
        [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
        [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
        [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
        
        /* Initialization */
        //        [SharedAppDelegate.root returnTitle:self.title viewcon:self noti:NO alarm:NO];
        self.filterType = QBImagePickerFilterTypeAllPhotos;
        self.showsCancelButton = YES;
        self.fullScreenLayoutEnabled = YES;
        
        self.allowsMultipleSelection = NO;
        self.limitsMinimumNumberOfSelection = NO;
        self.limitsMaximumNumberOfSelection = NO;
        self.minimumNumberOfSelection = 0;
        self.maximumNumberOfSelection = 0;
        
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        self.assetsLibrary = assetsLibrary;
        
        self.assetsGroups = [NSMutableArray array];
        
        // Table View
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.view addSubview:tableView];
        self.tableView = tableView;
        
        
        if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [self.tableView setSeparatorInset:UIEdgeInsetsZero];
        }
        if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
            [self.tableView setLayoutMargins:UIEdgeInsetsZero];
        }
        
        
        
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    void (^assetsGroupsEnumerationBlock)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *assetsGroup, BOOL *stop) {
        if (assetsGroup) {
            //            switch(self.filterType) {
            //                case QBImagePickerFilterTypeAllAssets:
            //                    [assetsGroup setAssetsFilter:[ALAssetsFilter allAssets]];
            //                    break;
            //                case QBImagePickerFilterTypeAllPhotos:
            [assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
            //                    break;
            //                case QBImagePickerFilterTypeAllVideos:
            //                    [assetsGroup setAssetsFilter:[ALAssetsFilter allVideos]];
            //                    break;
            //            }
            
            if (assetsGroup.numberOfAssets > 0) {
                [self.assetsGroups addObject:assetsGroup];
                [self.tableView reloadData];
            }
        }
    };
    
    void (^assetsGroupsFailureBlock)(NSError *) = ^(NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);
    };
    
    // Enumerate Camera Roll
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:assetsGroupsEnumerationBlock failureBlock:assetsGroupsFailureBlock];
    
    //    // Photo Stream
    //    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupPhotoStream usingBlock:assetsGroupsEnumerationBlock failureBlock:assetsGroupsFailureBlock];
    //
    //    // Album
    //    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:assetsGroupsEnumerationBlock failureBlock:assetsGroupsFailureBlock];
    //
    //    // Event
    //    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupEvent usingBlock:assetsGroupsEnumerationBlock failureBlock:assetsGroupsFailureBlock];
    //
    //    // Faces
    //    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupFaces usingBlock:assetsGroupsEnumerationBlock failureBlock:assetsGroupsFailureBlock];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSLog(@"viewWillAppear under 8.0 ");
    
//    self.navigationController.navigationBar.translucent = NO;
    
#ifdef BearTalk
    NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"themeColor"]; // [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [UINavigationBar appearance].barTintColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];//[UIColor lightGrayColor];
    
    NSShadow *shadow = [NSShadow new];
    [shadow setShadowColor:RGBA(0,0,0,0.3)];
    [shadow setShadowOffset: CGSizeMake(1, 1)];
    
    
    
    NSDictionary *titleState = @{
                                 NSForegroundColorAttributeName : [UIColor whiteColor],//[UIColor colorWithRed:0.2 green:0.5 blue:1.0 alpha:1.0],
                                 NSShadowAttributeName: shadow
                                 };
    
    
    [[UINavigationBar appearance] setTitleTextAttributes:titleState];
    
#endif
    
    self.title = @"사진";
    
    // Full screen layout
    if (self.fullScreenLayoutEnabled) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        if (indexPath == nil) {
            self.previousBarStyle = self.navigationController.navigationBar.barStyle;
            self.previousBarTranslucent = self.navigationController.navigationBar.translucent;
            self.previousStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
            
            self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
            self.navigationController.navigationBar.translucent = YES;
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
            
            CGFloat top = 0;
            if (![[UIApplication sharedApplication] isStatusBarHidden]) top = top + 20;
            if (!self.navigationController.navigationBarHidden) top = top + 44;
            self.tableView.contentInset = UIEdgeInsetsMake(top, 0, 0, 0);
            self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(top, 0, 0, 0);
            
            [self setWantsFullScreenLayout:YES];
        }
    }
    
    // Cancel table view selection
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Flash scroll indicators
    [self.tableView flashScrollIndicators];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.fullScreenLayoutEnabled) {
        // Restore bar styles
        self.navigationController.navigationBar.barStyle = self.previousBarStyle;
        self.navigationController.navigationBar.translucent = self.previousBarTranslucent;
        [[UIApplication sharedApplication] setStatusBarStyle:self.previousStatusBarStyle animated:YES];
    }
}

- (void)setShowsCancelButton:(BOOL)showsCancelButton
{
    _showsCancelButton = showsCancelButton;
    
    if (self.showsCancelButton) {
        //        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
        //        [self.navigationItem setRightBarButtonItem:cancelButton animated:NO];
        
        //        UIButton *button = [CustomUIKit closeButtonWithTarget:self selector:@selector(cancel)];
        //        UIBarButtonItem *btnNavi = [[UIBarButtonItem alloc]initWithCustomView:button];
        //        self.navigationItem.leftBarButtonItem = btnNavi;
        //        [btnNavi release];
        
        
        
        UIButton *button;
        UIBarButtonItem *btnNavi;
        button = [CustomUIKit emptyButtonWithTitle:@"barbutton_close.png" target:self selector:@selector(cancel)];
        btnNavi = [[UIBarButtonItem alloc]initWithCustomView:button];
        self.navigationItem.leftBarButtonItem = btnNavi;
        
        
    } else {
        [self.navigationItem setLeftBarButtonItem:nil animated:NO];
    }
}


#pragma mark - Instance Methods

- (void)cancel
{
    //    if ([self.delegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]) {
    //        [self.delegate imagePickerControllerDidCancel:self];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    //    }
}

- (NSDictionary *)mediaInfoFromAsset:(ALAsset *)asset
{
    NSMutableDictionary *mediaInfo = [NSMutableDictionary dictionary];
    [mediaInfo setObject:[asset valueForProperty:ALAssetPropertyType] forKey:@"UIImagePickerControllerMediaType"];
    [mediaInfo setObject:[UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]] forKey:@"UIImagePickerControllerOriginalImage"];
    
    [mediaInfo setObject:[[asset valueForProperty:ALAssetPropertyURLs] valueForKey:[[[asset valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]] forKey:@"UIImagePickerControllerReferenceURL"];
    
    return mediaInfo;
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.assetsGroups.count;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    QBImagePickerGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[QBImagePickerGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    ALAssetsGroup *assetsGroup = [self.assetsGroups objectAtIndex:indexPath.row];
    
    cell.imageView.image = [UIImage imageWithCGImage:assetsGroup.posterImage];
    cell.titleLabel.text = @"카메라롤";//[NSString stringWithFormat:@"%@", [assetsGroup valueForProperty:ALAssetsGroupPropertyName]];
    cell.countLabel.text = [NSString stringWithFormat:@"(%d)",(int)assetsGroup.numberOfAssets];
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ALAssetsGroup *assetsGroup = [self.assetsGroups objectAtIndex:indexPath.row];
    
    BOOL showsHeaderButton = ([self.delegate respondsToSelector:@selector(descriptionForSelectingAllAssets:)] && [self.delegate respondsToSelector:@selector(descriptionForDeselectingAllAssets:)]);
    
    BOOL showsFooterDescription = NO;
    
    //    switch(self.filterType) {
    //        case QBImagePickerFilterTypeAllAssets:
    //            showsFooterDescription = ([self.delegate respondsToSelector:@selector(imagePickerController:descriptionForNumberOfPhotos:numberOfVideos:)]);
    //            break;
    //        case QBImagePickerFilterTypeAllPhotos:
    showsFooterDescription = ([self.delegate respondsToSelector:@selector(imagePickerController:descriptionForNumberOfPhotos:)]);
    //            break;
    //        case QBImagePickerFilterTypeAllVideos:
    //            showsFooterDescription = ([self.delegate respondsToSelector:@selector(imagePickerController:descriptionForNumberOfVideos:)]);
    //            break;
    //    }
    
    // Show assets collection view
    QBAssetCollectionViewController *assetCollectionViewController = [[QBAssetCollectionViewController alloc] init];
    assetCollectionViewController.title = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    assetCollectionViewController.delegate = self;
    assetCollectionViewController.assetsGroup = assetsGroup;
    assetCollectionViewController.filterType = self.filterType;
    assetCollectionViewController.showsCancelButton = self.showsCancelButton;
    assetCollectionViewController.fullScreenLayoutEnabled = self.fullScreenLayoutEnabled;
    assetCollectionViewController.showsHeaderButton = showsHeaderButton;
    assetCollectionViewController.showsFooterDescription = showsFooterDescription;
    
    assetCollectionViewController.allowsMultipleSelection = self.allowsMultipleSelection;
    assetCollectionViewController.limitsMinimumNumberOfSelection = self.limitsMinimumNumberOfSelection;
    assetCollectionViewController.limitsMaximumNumberOfSelection = self.limitsMaximumNumberOfSelection;
    assetCollectionViewController.minimumNumberOfSelection = self.minimumNumberOfSelection;
    assetCollectionViewController.maximumNumberOfSelection = self.maximumNumberOfSelection;
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(![self.navigationController.topViewController isKindOfClass:[assetCollectionViewController class]]){
        [self.navigationController pushViewController:assetCollectionViewController animated:YES];
        });
        
#ifdef BearTalk
    [self.navigationController.navigationBar setBarTintColor:[NSKeyedUnarchiver unarchiveObjectWithData:colorData]];
    [assetCollectionViewController.navigationController.navigationBar setBarTintColor:[NSKeyedUnarchiver unarchiveObjectWithData:colorData]];
#endif
    }
}


#pragma mark - QBAssetCollectionViewControllerDelegate

- (void)assetCollectionViewController:(QBAssetCollectionViewController *)assetCollectionViewController didFinishPickingAsset:(ALAsset *)asset
{
    if ([self.delegate respondsToSelector:@selector(imagePickerControllerWillFinishPickingMedia:)]) {
        [self.delegate imagePickerControllerWillFinishPickingMedia:self];
    }
    
    if ([self.delegate respondsToSelector:@selector(qbimagePickerController:didFinishPickingMediaWithInfo:)]) {
        [self.delegate qbimagePickerController:self didFinishPickingMediaWithInfo:[self mediaInfoFromAsset:asset]];
    }
}

- (void)assetCollectionViewController:(QBAssetCollectionViewController *)assetCollectionViewController didFinishPickingAssets:(NSArray *)assets
{
    if ([self.delegate respondsToSelector:@selector(imagePickerControllerWillFinishPickingMedia:)]) {
        [self.delegate imagePickerControllerWillFinishPickingMedia:self];
    }
    
    if ([self.delegate respondsToSelector:@selector(qbimagePickerController:didFinishPickingMediaWithInfo:)]) {
        NSMutableArray *info = [NSMutableArray array];
        
        for (ALAsset *asset in assets) {
            [info addObject:[self mediaInfoFromAsset:asset]];
        }
        
        [self.delegate qbimagePickerController:self didFinishPickingMediaWithInfo:info];
    }
}

- (void)assetCollectionViewControllerDidCancel:(QBAssetCollectionViewController *)assetCollectionViewController
{
    if ([self.delegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]) {
        [self.delegate imagePickerControllerDidCancel:self];
    }
}

- (NSString *)descriptionForSelectingAllAssets:(QBAssetCollectionViewController *)assetCollectionViewController
{
    NSString *description = nil;
    
    if ([self.delegate respondsToSelector:@selector(descriptionForSelectingAllAssets:)]) {
        description = [self.delegate descriptionForSelectingAllAssets:self];
    }
    
    return description;
}

- (NSString *)descriptionForDeselectingAllAssets:(QBAssetCollectionViewController *)assetCollectionViewController
{
    NSString *description = nil;
    
    if ([self.delegate respondsToSelector:@selector(descriptionForDeselectingAllAssets:)]) {
        description = [self.delegate descriptionForDeselectingAllAssets:self];
    }
    
    return description;
}

- (NSString *)assetCollectionViewController:(QBAssetCollectionViewController *)assetCollectionViewController descriptionForNumberOfPhotos:(NSUInteger)numberOfPhotos
{
    NSString *description = nil;
    
    if ([self.delegate respondsToSelector:@selector(imagePickerController:descriptionForNumberOfPhotos:)]) {
        description = [self.delegate imagePickerController:self descriptionForNumberOfPhotos:numberOfPhotos];
    }
    
    return description;
}

- (NSString *)assetCollectionViewController:(QBAssetCollectionViewController *)assetCollectionViewController descriptionForNumberOfVideos:(NSUInteger)numberOfVideos
{
    NSString *description = nil;
    
    if ([self.delegate respondsToSelector:@selector(imagePickerController:descriptionForNumberOfVideos:)]) {
        description = [self.delegate imagePickerController:self descriptionForNumberOfVideos:numberOfVideos];
    }
    
    return description;
}

- (NSString *)assetCollectionViewController:(QBAssetCollectionViewController *)assetCollectionViewController descriptionForNumberOfPhotos:(NSUInteger)numberOfPhotos numberOfVideos:(NSUInteger)numberOfVideos
{
    NSString *description = nil;
    
    if ([self.delegate respondsToSelector:@selector(imagePickerController:descriptionForNumberOfPhotos:numberOfVideos:)]) {
        description = [self.delegate imagePickerController:self descriptionForNumberOfPhotos:numberOfPhotos numberOfVideos:numberOfVideos];
    }
    
    return description;
}

@end





#endif
