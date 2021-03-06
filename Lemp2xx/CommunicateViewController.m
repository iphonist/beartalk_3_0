//
//  CommunicateViewController.m
//  Lemp2xx
//
//  Created by HyeongJun Park on 2013. 11. 14..
//  Copyright (c) 2013년 Hyemin Kim. All rights reserved.
//

#import "CommunicateViewController.h"

@interface CommunicateViewController ()
{
//	UIBarButtonItem *messageActionButton;
	UIBarButtonItem *deleteButton;
    UIBarButtonItem *cancelButton;
    UIBarButtonItem *editButton;
    UIBarButtonItem *storeButton;
//    UIBarButtonItem *cdrButton;
}
@end

@implementation CommunicateViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.title = @"대화";
        
		[super setDelegate:self];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    
    
#ifdef BearTalk
    
    self.allowSwipeToMove = YES;
#else
    UIButton *editB;
    
    
#ifdef Batong
    editB = [CustomUIKit buttonWithTitle:@"" fontSize:0 fontColor:[UIColor clearColor] target:self selector:@selector(toggleStatus) frame:CGRectMake(0, 0, 26, 26) imageNamedBullet:nil imageNamedNormal:@"barbutton_delete.png" imageNamedPressed:nil];
    NSLog(@"editB");
#else
    editB = [CustomUIKit buttonWithTitle:NSLocalizedString(@"edit", @"edit") fontSize:16 fontColor:[UIColor blackColor] target:self selector:@selector(toggleStatus) frame:CGRectMake(0, 0, 32, 32) imageNamedBullet:nil imageNamedNormal:nil imageNamedPressed:nil];
#endif
    
    
    
	editButton = [[UIBarButtonItem alloc] initWithCustomView:editB];
	self.navigationItem.rightBarButtonItem = editButton;
    self.navigationItem.rightBarButtonItem.tag = NO;
	
	UIButton *cancelB = [CustomUIKit buttonWithTitle:NSLocalizedString(@"cancel", @"cancel") fontSize:16 fontColor:[UIColor blackColor] target:self selector:@selector(toggleStatus) frame:CGRectMake(0, 0, 32, 32) imageNamedBullet:nil imageNamedNormal:nil imageNamedPressed:nil];
	cancelButton = [[UIBarButtonItem alloc] initWithCustomView:cancelB];
    
    
    
    //    UIButton *msgButton = [CustomUIKit buttonWithTitle:nil fontSize:0 fontColor:nil target:SharedAppDelegate.root selector:@selector(messageActionsheet:) frame:CGRectMake(0, 0, 24, 24) imageNamedBullet:nil imageNamedNormal:@"scheduleadd_btn.png" imageNamedPressed:nil];
    //
    //	messageActionButton = [[UIBarButtonItem alloc] initWithCustomView:msgButton];
    //	self.navigationItem.rightBarButtonItem = messageActionButton;
    
	NSString *delString = @"삭제(0)";
	CGFloat fontSize = 16;
	UIFont *systemFont = [UIFont systemFontOfSize:fontSize];
	CGSize stringSize;
    stringSize = [delString sizeWithAttributes:@{NSFontAttributeName: systemFont}];
	
    
	UIButton *delButton = [CustomUIKit buttonWithTitle:delString fontSize:fontSize fontColor:[UIColor blackColor] target:self selector:@selector(deleteAction) frame:CGRectMake(0, 0, stringSize.width+3.0, 32) imageNamedBullet:nil imageNamedNormal:nil imageNamedPressed:nil];
	deleteButton = [[UIBarButtonItem alloc] initWithCustomView:delButton];
    
    
    
    UIButton *button = [CustomUIKit buttonWithTitle:nil fontSize:0 fontColor:nil target:self selector:@selector(goStoredList) frame:CGRectMake(0, 0, 36, 36) imageNamedBullet:nil imageNamedNormal:@"barbutton_note_favorite.png" imageNamedPressed:nil];
    storeButton = [[UIBarButtonItem alloc]initWithCustomView:button];
//    NSLog(@"goStored");
#endif

    
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = NO;
    
    
	if (self.navigationItem.rightBarButtonItem.tag == YES) {
        [self toggleStatus];
	}
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)toggleStatus
{
    NSLog(@"toggleStatus");
    
	if (self.navigationItem.rightBarButtonItem.tag == NO) {
		NSUInteger myListCount = (NSUInteger)[self.selectedViewController performSelector:@selector(myListCount)];
		if (myListCount == 0) {
			return;
		}
        
        //		UIButton *leftButton = (UIButton*)self.navigationItem.leftBarButtonItem.customView;
        //		[leftButton setTitle:NSLocalizedString(@"cancel", @"cancel") forState:UIControlStateNormal];
		[self.navigationItem setLeftBarButtonItem:cancelButton animated:YES];
		[self.navigationItem setRightBarButtonItem:deleteButton animated:YES];
		[self.selectedViewController performSelector:@selector(startEditing)];
        self.navigationItem.rightBarButtonItem.tag = YES;
        
	} else {
        
        [self initAction];
	}
}
- (void)initAction{
    [self.selectedViewController performSelector:@selector(endEditing)];
    
    if(self.selectedIndex == kSubTabIndexNote){
        NSLog(@"storeButton %@",storeButton);
        
        [self.navigationItem setLeftBarButtonItem:storeButton animated:YES];
    }
    else{
        [self.navigationItem setLeftBarButtonItem:nil animated:YES];
        
    }
    
    [self.navigationItem setRightBarButtonItem:editButton animated:YES];
    
    
    UIButton *rightButton = (UIButton*)deleteButton.customView;
    NSString *delString = @"삭제(0)";
    CGFloat fontSize = 16;
    UIFont *systemFont = [UIFont systemFontOfSize:fontSize];
    CGSize stringSize;
    
    stringSize = [delString sizeWithAttributes:@{NSFontAttributeName:systemFont}];

    CGRect rightFrame = rightButton.frame;
    rightFrame.size.width = stringSize.width+3.0;
    rightButton.frame = rightFrame;
    [rightButton setTitle:delString forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem.tag = NO;

}

- (void)deleteAction
{
	NSUInteger selectedCount = (NSUInteger)[self.selectedViewController performSelector:@selector(selectListCount)];
	if (selectedCount > 0) {
		NSString *message;
		if (self.selectedIndex == kSubTabIndexChat) {
			message = NSLocalizedString(@"delete_chat_alert", @"delete_chat_alert");
		} else if (self.selectedIndex == kSubTabIndexNote) {
			message = NSLocalizedString(@"delete_note_alert", @"delete_note_alert");
		} else { // 무료통화
			message = NSLocalizedString(@"delete_call_alert", @"delete_call_alert");
		}
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"delete", @"delete")
                                                                           message:message
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"delete", @"delete")
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action){
                                                           
                                                        
                                                               [self.selectedViewController performSelector:@selector(commitDelete)];
                                                          
                                                               
                                                           
                                                           [alert dismissViewControllerAnimated:YES completion:nil];
                                                       }];
            
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel")
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action){
                                                               [alert dismissViewControllerAnimated:YES completion:nil];
                                                           }];
            
            [alert addAction:cancel];
            [alert addAction:ok];
            //        [self presentViewController:alert animated:YES completion:nil];
            [SharedAppDelegate.root anywhereModal:alert];
            
        }
        else{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"delete", @"delete") message:message delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"cancel") otherButtonTitles:NSLocalizedString(@"delete", @"delete"), nil];
		alert.tag = self.selectedIndex;
		[alert show];
//		[alert release];
        }
	}
}
- (void)goStoredList{
    if (self.selectedIndex == kSubTabIndexNote) {
        [self.selectedViewController performSelector:@selector(goStoredList)];
    }
}

- (void)goCdrList{
    
    if (self.selectedIndex == kSubTabIndexCall) {
        [self.selectedViewController performSelector:@selector(goCdrList)];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1) {
		if (alertView.tag != self.selectedIndex) {
			// 경고창 떠 있는 사이 뷰가 바뀜
			[CustomUIKit popupSimpleAlertViewOK:@"알 림" msg:NSLocalizedString(@"changeview_not_done_alert", @"changeview_not_done_alert") con:self];
		} else {
			[self.selectedViewController performSelector:@selector(commitDelete)];
		}
	}
}

- (void)setCountForRightBar:(NSNumber*)count
{
    NSLog(@"setCountForRightBar %@",count);

	if (self.navigationItem.rightBarButtonItem.tag == YES) {
		NSString *titleString = [NSString stringWithFormat:@"삭제(%@)",count];
        //		self.navigationItem.rightBarButtonItem.title = titleString;
		
		UIButton *rightButton = (UIButton*)deleteButton.customView;
		CGFloat fontSize = 16;
		UIFont *systemFont = [UIFont systemFontOfSize:fontSize];
		CGSize stringSize;
		
        stringSize = [titleString sizeWithAttributes:@{NSFontAttributeName: systemFont}];
	
		
		CGRect rightFrame = rightButton.frame;
		rightFrame.size.width = stringSize.width+3.0;
		rightButton.frame = rightFrame;
		[rightButton setTitle:titleString forState:UIControlStateNormal];
		
	}
}
//- (void)setEditing:(BOOL)editing animated:(BOOL)animated
//{
//	[super setEditing:editing animated:animated];
//
//	if (editing == YES) {
//		[self.navigationItem setRightBarButtonItem:deleteButton animated:YES];
//	} else {
//		[self.navigationItem setRightBarButtonItem:messageActionButton animated:YES];
//	}
//}

- (BOOL)mh_tabBarController:(MHTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index
{
    //	UIButton *button = [CustomUIKit buttonWithTitle:nil fontSize:0 fontColor:nil target:SharedAppDelegate.root selector:@selector(messageActionsheet:) frame:CGRectMake(0, 0, 32, 32) imageNamedBullet:nil imageNamedNormal:@"addmessage_btn.png" imageNamedPressed:nil];
    //
    //
    //
    //	NSMutableArray *buttons = [NSMutableArray arrayWithArray:self.navigationItem.rightBarButtonItems];
    //
    //	if (button != nil) {
    //		[self.subBarButton setCustomView:button];
    //		if ([buttons containsObject:self.subBarButton] == NO) {
    //			[buttons addObject:self.subBarButton];
    //		}
    //	} else {
    //		if ([buttons containsObject:self.subBarButton] == YES) {
    //			[buttons removeObject:self.subBarButton];
    //		}
    //	}
    //
    //	self.navigationItem.rightBarButtonItems = buttons;
	if (self.navigationItem.rightBarButtonItem.tag == YES) {
		[self toggleStatus];
	}
    
	return YES;
}

- (void)mh_tabBarController:(MHTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index
{
    //	[tabBarController reloadTabBadges];
}

- (void)newCommunicate{
    
    
    if (self.selectedIndex == kSubTabIndexChat) {
        [SharedAppDelegate.root.chatList loadSearch];
    } else if (self.selectedIndex == kSubTabIndexNote) {
        [SharedAppDelegate.root.note loadMember:0];
    } else { // 무료통화
        [SharedAppDelegate.root.callManager loadCallMember];
    }
}
//- (void)dealloc
//{
//	[messageActionButton release];
//	[deleteButton release];
//    [editButton release];
//    [cancelButton release];
//	[super dealloc];
//}
@end
