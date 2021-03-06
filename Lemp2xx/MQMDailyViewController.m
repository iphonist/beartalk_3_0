//
//  MQMDailyViewController.m
//  Lemp2xx
//
//  Created by Hyemin Kim on 2015. 1. 15..
//  Copyright (c) 2015년 BENCHBEE Co., Ltd. All rights reserved.
//

#import "MQMDailyViewController.h"
#import "PostViewController.h"
#import "DetailViewController.h"
#import "PhotoViewController.h"
#import "SVPullToRefresh.h"

@interface MQMDailyViewController ()

@end

@implementation MQMDailyViewController

@synthesize timeLineCells;


- (id)init{
    self = [super init];
    
    if(self){
//        isFirst = 0;
        isRefresh = 0;
        isDetail = 0;
        
        self.title = @"일지";
    }
    return self;
}

- (void)close{
    
    
    NSLog(@"exitView");
        [self dismissViewControllerAnimated:YES completion:nil];
 
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    
    UIButton *button;
    UIBarButtonItem *btnNavi;
    button = [CustomUIKit emptyButtonWithTitle:@"barbutton_close.png" target:self selector:@selector(close)];
    btnNavi = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = btnNavi;
//    [btnNavi release];
    NSLog(@"home groupdic %@",SharedAppDelegate.root.home.groupDic);
    
    
    self.view.backgroundColor = RGB(246,246,246);
    
    myTable = [[UITableView alloc]init];
    
    myTable.delegate = self;
    myTable.dataSource = self;
    myTable.rowHeight = 145;
    myTable.scrollsToTop = YES;
    //    myTable.allowsMultipleSelectionDuringEditing = YES;
    //    myTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    myTable.backgroundColor = [UIColor clearColor];
    myTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if ([myTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [myTable setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([myTable respondsToSelector:@selector(setLayoutMargins:)]) {
        [myTable setLayoutMargins:UIEdgeInsetsZero];
    }
    
    
    CGRect tableFrame;
    
    tableFrame = CGRectMake(0, 0, 320, self.view.frame.size.height - 0);
    myTable.frame = tableFrame;
    
    NSLog(@"mytable_frame %@",NSStringFromCGRect(myTable.frame));
    NSLog(@"mytable_frame %f",myTable.contentOffset.y);
    [self.view addSubview:myTable];
    
    [myTable addPullToRefreshWithActionHandler:^{
        [self refreshTimeline];
    }];
    myTable.pullToRefreshView.backgroundColor = self.view.backgroundColor;
    
    [myTable addInfiniteScrollingWithActionHandler:^{
        [self loadMoreTimeline];
    }];
    
    //    myTable.translatesAutoresizingMaskIntoConstraints = YES;
    NSLog(@"viewDidLoad %@",NSStringFromCGRect(self.view.frame));
    
    
    
    writeButton = [CustomUIKit buttonWithTitle:nil fontSize:0 fontColor:nil target:self selector:@selector(newWrite:) frame:CGRectMake(320 - 65, self.view.frame.size.height - 65, 52, 52) imageNamedBullet:nil imageNamedNormal:@"button_timeline_floating_newdaily.png" imageNamedPressed:nil];
    [self.view addSubview:writeButton];
    
    writeButton.hidden = YES;
    

    
//      [self getTimeline:@""];
}

- (void)refreshTimeline
{
//    refreshed = NO;
    isRefresh++;
    [self getTimeline:@""];
    //    refreshed = YES;
    NSLog(@"viewDidLoad %@",NSStringFromCGRect(self.view.frame));
    
    
}
- (void)loadMoreTimeline
{
    
    [self getTimeline:[NSString stringWithFormat:@"-%d",(int)lastInteger]];
    
}


- (void)getTimeline:(NSString *)idx
{
    
    
#ifdef BearTalk
#else
    if([[SharedAppDelegate readPlist:@"was"]length]<1)
        return;
#endif
    
    
    
    
    if(didRequest){
        if ([idx length] > 0) {
            [[SDImageCache sharedImageCache] clearMemory];
            [[SDImageCache sharedImageCache] clearDisk];
            [myTable.infiniteScrollingView stopAnimating];
        } else {
            [myTable.pullToRefreshView stopAnimating];
        }
        return;
    }
    
    didRequest = YES;
    
    
    //    [MBProgressHUD showHUDAddedTo:self.view label:nil animated:YES];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    
//    NSString *urlString = [NSString stringWithFormat:@"https://%@",[SharedAppDelegate readPlist:@"was"]];
//    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:urlString]];
    
    NSString *urlString = [NSString stringWithFormat:@"https://%@/lemp/timeline/read/categorymsg.lemp",[SharedAppDelegate readPlist:@"was"]];
    NSURL *baseUrl = [NSURL URLWithString:urlString];
    
    
    AFHTTPRequestOperationManager *client = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:baseUrl];
    client.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSDictionary *parameters;
    
    
    //        [SVProgressHUD showWithStatus:@"타임라인을 가져오고 있습니다."];
    
    
    if(idx != nil && [idx length]>5){
        parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                      [ResourceLoader sharedInstance].mySessionkey,@"sessionkey",
                      [ResourceLoader sharedInstance].myUID,@"uid",
                      idx,@"time",
                      @"17",@"contenttype",
                      SharedAppDelegate.root.home.category,@"category",
                      SharedAppDelegate.root.home.targetuid,@"targetuid",
                      SharedAppDelegate.root.home.groupnum,@"groupnumber",
                      nil];//@{ @"uniqueid" : @"c110256" };
    }
    else{
        
//        myTable.contentOffset = CGPointMake(0, 0);
        idx = @"";
        parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                      [ResourceLoader sharedInstance].mySessionkey,@"sessionkey",
                      [ResourceLoader sharedInstance].myUID,@"uid",
                      @"0",@"time",
                      @"17",@"contenttype",
                      SharedAppDelegate.root.home.category,@"category",
                      SharedAppDelegate.root.home.targetuid,@"targetuid",
                      SharedAppDelegate.root.home.groupnum,@"groupnumber",
                      nil];//@{ @"uniqueid" : @"c110256" };
    }
    
    NSLog(@"parameters %@",parameters);
//    NSMutableURLRequest *request = [client requestWithMethod:@"POST" path:@"/lemp/timeline/read/categorymsg.lemp" parameters:parameters];
   
    
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [client.requestSerializer requestWithMethod:@"POST" URLString:[baseUrl absoluteString] parameters:parameters error:&serializationError];
    
    NSLog(@"timeout: %f", request.timeoutInterval);
    AFHTTPRequestOperation *operation = [client HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        //        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSDictionary *resultDic = [operation.responseString objectFromJSONString][0];
        NSLog(@"ResultDic %@",resultDic);
        NSString *isSuccess = resultDic[@"result"];
        if ([isSuccess isEqualToString:@"0"]) {
            didRequest = NO;
            
            if ([idx length] > 0) {
                [myTable.infiniteScrollingView stopAnimating];
            } else {
                [myTable.pullToRefreshView stopAnimating];
            }
            
            
            NSMutableArray *resultArray = [NSMutableArray array];
            resultArray = resultDic[@"past"];
            
            
            NSMutableArray *parsingArray = [NSMutableArray array];
            if([resultArray count]>0){
                for (NSDictionary *dic in resultArray) {
                    TimeLineCell *cellData = [[TimeLineCell alloc] init];
                    cellData.idx = dic[@"contentindex"];  //[[imageArrayobjectatindex:i]objectForKey:@"image"];
                    cellData.writeinfoType = dic[@"writeinfotype"];
                    cellData.personInfo = [dic[@"writeinfo"]objectFromJSONString];
                    
                    //                cellData.likeCountUse = [[dicobjectForKey:@"goodcount_use"]intValue];
                    cellData.currentTime = resultDic[@"time"];
                    cellData.time = dic[@"operatingtime"];
                    cellData.writetime = dic[@"writetime"];
                    
                    lastInteger = [cellData.time intValue];
                    //                NSLog(@"lastInteger %d",lastInteger);
                    
                    cellData.profileImage = dic[@"uid"]!=nil?dic[@"uid"]:@"";
                    cellData.favorite = dic[@"favorite"];
                    //                    cellData.deletePermission = [resultDic[@"delete"]intValue];
                    cellData.readArray = dic[@"readcount"];
                    //                    cellData.group = [dic[@"groupname"];
                    //                    cellData.targetname = [dicobjectForKey:@"targetname"];
                    cellData.notice = dic[@"notice"];
                    cellData.targetdic = dic[@"target"];
                    //                    cellData.company = [dicobjectForKey:@"companyname"];
                    
                    NSDictionary *contentDic = [dic[@"content"][@"msg"]objectFromJSONString];
                    //                NSLog(@"contentDic %@",contentDic);
                    cellData.contentDic = contentDic;
                    cellData.pollDic = [dic[@"content"][@"poll_data"] objectFromJSONString];
                    cellData.fileArray = [dic[@"content"][@"attachedfile"] objectFromJSONString];
                    //                    cellData.imageString = [contentDicobjectForKey:@"image"];
                    //                    cellData.content = [contentDicobjectForKey:@"msg"];
                    //                    cellData.where = [contentDicobjectForKey:@"location"];
                    cellData.contentType = dic[@"contenttype"];
                    cellData.type = dic[@"type"];
                    cellData.categoryType = SharedAppDelegate.root.home.category;
                    cellData.sub_category = dic[@"sub_category"];
                    cellData.likeCount = [dic[@"goodmember"]count];
                    cellData.likeArray = dic[@"goodmember"];
                    cellData.replyCount = [dic[@"replymsgcount"]intValue];
                    cellData.replyArray = dic[@"replymsg"];
                    //                if([[contentDicobjectForKey:@"image"]length]>1 && [contentDicobjectForKey:@"image"]!=nil)
                    
                    
                    [parsingArray addObject:cellData];
//                    [cellData release];
                }
            }
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:idx,@"idx",parsingArray,@"array",nil];
            [self performSelectorOnMainThread:@selector(handleContents:) withObject:dic waitUntilDone:NO];
            
            
        }else {
            NSString *msg = [NSString stringWithFormat:@"%@",resultDic[@"resultMessage"]];
            [CustomUIKit popupSimpleAlertViewOK:nil msg:msg con:self];
            NSLog(@"isSuccess NOT 0, BUT %@",isSuccess);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        didRequest = NO;
        //        [activity stopAnimating];
        //		[loadMoreIndicator stopAnimating];
        //        progressLabel.hidden = YES;
        //        myTable.scrollEnabled = YES;
        
        
        
        //        [SVProgressHUD dismiss];
        NSLog(@"FAIL : %@",operation.error);
        
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [HTTPExceptionHandler handlingByError:error];
        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"타임라인을 받아오는 데 실패했습니다. 잠시 후 다시 시도해 주세요!" delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"ok") otherButtonTitles:nil, nil];
        //        [alert show];
        
    }];
    
    [operation start];
    
}

- (void)handleContents:(NSDictionary *)dic
{
    NSLog(@"handleContents cell %@",dic);
    
    if([dic[@"idx"]length]<1)
    {
        self.timeLineCells = [NSMutableArray array];
        [self.timeLineCells setArray:dic[@"array"]];
        
        if ([self.timeLineCells count] > 9) {
            myTable.showsInfiniteScrolling = YES;
        } else {
            myTable.showsInfiniteScrolling = NO;
        }
    } else {
        [self.timeLineCells addObjectsFromArray:dic[@"array"]];
        
        if ([dic[@"array"] count] == 0) {
            myTable.showsInfiniteScrolling = NO;
        }
    }
    
    
    [myTable reloadData];

    
    CGRect tableFrame;

    tableFrame = CGRectMake(0, 0, 320, self.view.frame.size.height - 0);
    if(isRefresh >= 1 && isDetail == 0){
        tableFrame = CGRectMake(0, VIEWY, 320, self.view.frame.size.height - VIEWY);
    }
    myTable.frame = tableFrame;
}

#define kDaily 17

- (void)newWrite:(id)sender{
    
//    PostViewController *post = [[PostViewController alloc]initWithStyle:kDaily];//WithViewCon:self];
    //    post.title = [NSString stringWithFormat:@"%@",titleString];
    [SharedAppDelegate.root.home.post initData:kDaily];
    SharedAppDelegate.root.home.post.title = @"새일지";
    //    [SharedAppDelegate.root returnTitle:post.title viewcon:post noti:NO alarm:NO];
    UINavigationController *nc = [[CBNavigationController alloc]initWithRootViewController:SharedAppDelegate.root.home.post];
    [self presentViewController:nc animated:YES completion:nil];
//    [post release];
//    [nc release];
    
    
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGFloat height = 0.0;
    
    NSInteger fontSize = [[NSUserDefaults standardUserDefaults] integerForKey:@"GlobalFontSize"];
    
    
    TimeLineCell *dataItem = nil;
    dataItem = self.timeLineCells[indexPath.row];
    
    NSString *imageString = dataItem.contentDic[@"image"];
    NSString *content = dataItem.contentDic[@"msg"];
  
    NSString *where = dataItem.contentDic[@"jlocation"];
    NSDictionary *dic = [where objectFromJSONString];
    //			NSString *invite = dataItem.contentDic[@"question"];
    //			NSString *regiStatus = dataItem.contentDic[@"result"];
    NSDictionary *pollDic = dataItem.pollDic;
    NSArray *fileArray = dataItem.fileArray;
    
    
    if([dataItem.contentType intValue]>17 || [dataItem.type intValue]>7 || ([dataItem.writeinfoType intValue]>4 && [dataItem.writeinfoType intValue]!=10)){
        height += 15+40; // gap + defaultview
        height += 10 + 25; // gap 업그레이드가 필요합니다.
    }
    else
    {
        if([dataItem.writeinfoType intValue]==0){
            height += 15;
        }
        else{
            height += 15+40; // gap + defaultview
        }
        
        
        
        height += 10; // gap
        
        
        UILabel *contentsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 32, 0)];
        NSLog(@"contentsLabel %@",NSStringFromCGRect(contentsLabel.frame));
        NSInteger fontSize = [[NSUserDefaults standardUserDefaults] integerForKey:@"GlobalFontSize"];
        [contentsLabel setFont:[UIFont systemFontOfSize:fontSize]];
        contentsLabel.text = content;
        
        if(imageString != nil && [imageString length]>0){
            
            [contentsLabel setNumberOfLines:5];
            
        }
        else{
            [contentsLabel setNumberOfLines:10];
            
        }
        
        
        CGRect realFrame = contentsLabel.frame;
        
        realFrame.size.width = [[UIScreen mainScreen] bounds].size.width - 32; //양쪽 패딩 합한 값이 64
        
        contentsLabel.frame = realFrame;
        NSLog(@"contentsLabel %@",NSStringFromCGRect(contentsLabel.frame));
        
        [contentsLabel sizeToFit];
        

        
        if(imageString != nil && [imageString length]>0)
        {
            height += 5; // gap
            if([dataItem.contentType intValue]==10)
                height += 500;
            else
                height += 137;
            //                else
            //                    height += (imgCount+1)/2*75;
            
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
            NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize], NSParagraphStyleAttributeName:paragraphStyle};
            
            CGSize realSize = [content boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 32, NSIntegerMax) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
            CGFloat moreLabelHeight = 0.0;
            if (contentsLabel.frame.size.height > 0 && realSize.height > contentsLabel.frame.size.height) {
                moreLabelHeight = 20;
            }
            height += contentsLabel.frame.size.height + moreLabelHeight;
            
            
        }
        else{
            
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
            NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize], NSParagraphStyleAttributeName:paragraphStyle};
            
            CGSize realSize = [content boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 32, NSIntegerMax) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
            CGFloat moreLabelHeight = 0.0;
            if (contentsLabel.frame.size.height > 0 && realSize.height > contentsLabel.frame.size.height) {
                moreLabelHeight = 20;
            }
            height += contentsLabel.frame.size.height + moreLabelHeight;
            
            
        }
        height += 10; // contentslabel gap
        
        if(pollDic != nil){
            height += 78;
        }
        if([fileArray count]>0){
            height += 78; // gap+
        }
        if(dic[@"text"] != nil && [dic[@"text"] length]>0)
        {
            height += 22; // location
        }
        
        
        
        
        if([dataItem.type isEqualToString:@"5"] || [dataItem.type isEqualToString:@"6"]){
            if([dataItem.contentType isEqualToString:@"11"] || [dataItem.contentType isEqualToString:@"14"]){
                height += 10 + 30; // optionView;
            }
        }
        else{
            //            if(![dataItem.contentType isEqualToString:@"11"])
            height += 10 + 30; // optionView;
            
            
        }
    }
    
    
    
    
    if ([timeLineCells count] == 1 && height < 80) {
        height = 80;
    }
    
    height += 10; // gap
    
    
    
    
    return height;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return [self.timeLineCells count];//[ count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(didRequest)
        return;
    
    didRequest = YES;
    
    DetailViewController *contentsViewCon = [[DetailViewController alloc] init];//WithViewCon:self]autorelease];
    contentsViewCon.parentViewCon = self;
    
    contentsViewCon.contentsData = self.timeLineCells[indexPath.row];
    
    
    
    
    //    [contentsViewCon setPush];
    NSLog(@"contentsviewcon.contentsdata %@",contentsViewCon.contentsData);
    NSLog(@"contentsViewCon.contentsData.type %@",contentsViewCon.contentsData.type);
    if([contentsViewCon.contentsData.type isEqualToString:@"6"] || [contentsViewCon.contentsData.type isEqualToString:@"7"]) {
//        [contentsViewCon release];
        return;
    }
    
    
    
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(![self.navigationController.topViewController isKindOfClass:[contentsViewCon class]]){
//        contentsViewCon.hidesBottomBarWhenPushed = YES;
        isDetail++;
        [self.navigationController pushViewController:contentsViewCon animated:YES];
}
    });
//    [contentsViewCon release];
    
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



- (UITableViewCell *)tableView:(UITableView *)tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    static NSString *CellIdentifier = @"TimeLineCell";
    //    static NSString *PlaceholderCellIdentifier = @"PlaceholderCell";
    //    UIImageView *gradationView;//, *bgView;
    
    //    UILabel *label;
    
    
    NSLog(@"cellforrow");
    //    static NSString *CellIdentifier = @"TimeLineCell";
    TimeLineCell *cell = (TimeLineCell*)[tableView1 dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if(cell == nil)
    {
        cell = [[TimeLineCellSubViews alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil viewController:self];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        
        
        //        label = [CustomUIKit labelWithText:@"" fontSize:25 fontColor:[UIColor redColor] frame:CGRectMake(0, 0, 320, 30) numberOfLines:1 alignText:NSTextAlignmentCenter];
        //        label.tag = 5000;
        //        [cell.contentView addSubview:label];
        
        
    }
    else{
        
        //        label = (UILabel *)[cell viewWithTag:5000];
        
        
    }
    
    
    if([self.timeLineCells count]==0){
        NSLog(@"here");
        
        
        
        
    }
    else
    {
        
        TimeLineCell *dataItem = nil;
        dataItem = self.timeLineCells[indexPath.row];
        
        //        if([dataItem.type isEqualToString:@"6"] && [dataItem.idx isEqualToString:@"0"]){
        //            cell.idx = dataItem.idx;
        //
        //            cell.profileImage = dataItem.profileImage;
        //            cell.favorite = dataItem.favorite;
        //            //            cell.deletePermission = dataItem.deletePermission;
        //            cell.writeinfoType = dataItem.writeinfoType;
        //            cell.personInfo = dataItem.personInfo;
        //            cell.currentTime = dataItem.currentTime;
        //            cell.time = dataItem.time;
        //            cell.writetime = dataItem.writetime;
        //            cell.contentDic = dataItem.contentDic;
        //            cell.pollDic = dataItem.pollDic;
        //            cell.fileArray = dataItem.fileArray;
        //            //            cell.imageString = dataItem.imageString;
        //            //            cell.content = dataItem.content;
        //            //            [cell setImageString:dataItem.imageString content:dataItem.content wh:dataItem.where];
        //            //            cell.where = dataItem.where;
        //            cell.readArray = dataItem.readArray;
        //
        //            //            cell.group = dataItem.group;
        //            //            cell.company = dataItem.company;
        //            //            cell.targetname = dataItem.targetname;
        //            cell.notice = dataItem.notice;
        //            cell.targetdic = dataItem.targetdic;
        //
        //            cell.contentType = dataItem.contentType;
        //
        //            cell.type = dataItem.type;
        //            cell.categoryType = dataItem.categoryType;
        //            cell.likeCount = dataItem.likeCount;//
        //            cell.likeArray = dataItem.likeArray;
        //            cell.replyCount = dataItem.replyCount;
        //            cell.replyArray = dataItem.replyArray;
        //            cell.contentDic = [NSDictionary dictionaryWithObjectsAndKeys:
        //                               [[NSDictionary dictionaryWithObjectsAndKeys:@"test",@"msg", nil]JSONData],
        //                               @"msg",nil];
        //            NSLog(@"contentdic %@",cell.contentDic[@"msg"]);
        //
        //            return cell;
        //
        //        }
        
        
        cell.idx = dataItem.idx;
        
        cell.profileImage = dataItem.profileImage;
        cell.favorite = dataItem.favorite;
        //            cell.deletePermission = dataItem.deletePermission;
        cell.writeinfoType = dataItem.writeinfoType;
        cell.personInfo = dataItem.personInfo;
        cell.currentTime = dataItem.currentTime;
        cell.time = dataItem.time;
        cell.writetime = dataItem.writetime;
        cell.contentDic = dataItem.contentDic;
        cell.pollDic = dataItem.pollDic;
        cell.fileArray = dataItem.fileArray;
        //            cell.imageString = dataItem.imageString;
        //            cell.content = dataItem.content;
        //            [cell setImageString:dataItem.imageString content:dataItem.content wh:dataItem.where];
        //            cell.where = dataItem.where;
        cell.readArray = dataItem.readArray;
        
        //            cell.group = dataItem.group;
        //            cell.company = dataItem.company;
        //            cell.targetname = dataItem.targetname;
        cell.notice = dataItem.notice;
        cell.targetdic = dataItem.targetdic;
        
        cell.contentType = dataItem.contentType;
        
        cell.type = dataItem.type;
        cell.categoryType = dataItem.categoryType;
        cell.likeCount = dataItem.likeCount;//
        cell.likeArray = dataItem.likeArray;
        cell.replyCount = dataItem.replyCount;
        cell.replyArray = dataItem.replyArray;
        
        NSLog(@"cell.replyArray %@",cell.replyArray);
        //ContentImage:dataItem.imageContent
        //            cell.likeImage = dataItem.likeImage;
    }
    
    
    return cell;
}

- (void)didSelectImageScrollView:(NSString *)index{
    
    
    int rowOfIndex = 0;
    for(int i = 0; i < [self.timeLineCells count]; i++){
        TimeLineCell *dataItem = self.timeLineCells[i];
        if([dataItem.idx isEqualToString:index]){
            rowOfIndex = i;
        }
    }
    
    DetailViewController *contentsViewCon = [[DetailViewController alloc] init];//WithViewCon:self]autorelease];
    contentsViewCon.parentViewCon = self;
    
    
    contentsViewCon.contentsData = self.timeLineCells[rowOfIndex];
    
    if([contentsViewCon.contentsData.type isEqualToString:@"6"]) {
//        [contentsViewCon release];
        return;
    }
    if([contentsViewCon.contentsData.type isEqualToString:@"7"]){
//        [contentsViewCon release];
             isDetail++;
        NSDictionary *imgDic = [contentsViewCon.contentsData.contentDic[@"image"]objectFromJSONString];
        NSLog(@"imgDic %@",imgDic);
        NSString *imgUrl = [NSString stringWithFormat:@"https://%@%@%@",imgDic[@"server"],imgDic[@"dir"],imgDic[@"filename"][0]];
        NSLog(@"imgurl %@",imgUrl);
        UIViewController *photoCon;
        
        photoCon = [[PhotoViewController alloc] initWithFileName:imgDic[@"filename"][0] image:nil type:12 parentViewCon:self roomkey:@"" server:imgUrl];
        
        UINavigationController *nc = [[CBNavigationController alloc]initWithRootViewController:photoCon];
        [self presentViewController:nc animated:YES completion:nil];
//        [nc release];
//        [photoCon release];
        
        return;
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(![self.navigationController.topViewController isKindOfClass:[contentsViewCon class]]){
//        contentsViewCon.hidesBottomBarWhenPushed = YES;
             isDetail++;
        [self.navigationController pushViewController:contentsViewCon animated:YES];
}
    });
//    [contentsViewCon release];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    //    isFirst++;
    didRequest = NO;
//    refreshed = NO;
    NSLog(@"viewWillAppear %@ %@",SharedAppDelegate.root.home.groupDic[@"groupmaster"],[ResourceLoader sharedInstance].myUID);
    [self getTimeline:@""];
    
    
    NSLog(@"writebutton.frame %@",NSStringFromCGRect(writeButton.frame));
 
//    CGRect tableFrame;
//    
//    tableFrame = CGRectMake(0, 0, 320, self.view.frame.size.height - 0);
//    myTable.frame = tableFrame;


    
//    NSLog(@"isDetail %d",isDetail);
    
//    if(isDetail > 0){
//        writeButton.frame = CGRectMake(320 - 65, self.view.frame.size.height - VIEWY, 52, 52);
//}
//    else{
//        
        writeButton.frame = CGRectMake(320 - 65, self.view.frame.size.height - VIEWY, 52, 52);
//    }
    
    NSLog(@"writebutton.frame %@",NSStringFromCGRect(writeButton.frame));
    
    
        
    if([SharedAppDelegate.root.home.groupDic[@"groupmaster"]isEqualToString:[ResourceLoader sharedInstance].myUID]){
        writeButton.hidden = YES;
    }
    else{
        writeButton.hidden = NO;
    }
        
    
    

}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    didRequest = NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
