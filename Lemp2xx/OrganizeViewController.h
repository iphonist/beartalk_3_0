//
//  OrganizeViewController.h
//  LEMPMobile
//
//  Created by Hyemin Kim on 12. 2. 12..
//  Copyright 2012 Benchbee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrganizeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UISearchBarDelegate>{
    UITableView *myTable;
    UISearchBar *search;
    UIScrollView *scrollView;
		NSMutableArray *myList;
		NSMutableArray *subList;
    
		int tagInfo;
//		NSMutableArray *peopleList;
		NSMutableArray *subPeopleList;
		BOOL select;
		NSMutableArray *selectCodeList;
		NSMutableArray *addArray;
//    NSMutableArray *chosungArray;
//    BOOL searching;
//    NSMutableArray *copyList;
//    NSMutableArray *originList;
    NSString *firstDept;
//    NSString *firstCode;
//    ProfileView *pView;
//    NSMutableArray *allList;
//    BOOL dragging;
//    NSThread *imageThread;
//    UIButton *addNameImage;
    BOOL isFirst;
}

- (void)checkSameLevel:(NSString *)code;
- (void)reloadCheck;
- (void)setFirst:(NSString *)first;
- (void)setFirstButton;
- (void)refreshSearchFavorite:(NSString *)uid fav:(NSString *)fav;


@property (nonatomic, assign) int tagInfo;
@property (nonatomic, retain) NSMutableArray *selectCodeList;
@property (nonatomic, retain) NSMutableArray *addArray;
//@property (nonatomic, retain) NSString *firstCode;




@end
