//
//  CallManager.h
//  Lemp2
//
//  Created by Hyemin Kim on 13. 2. 5..
//  Copyright (c) 2013년 Hyemin Kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "VoIPSingleton.h"
//#import <AudioToolbox/AudioToolbox.h>

//extern const char alertNumber;

@interface CallManager : NSObject{
    UIImageView *outgoingView;
    UIView *fullOutgoingView;
    UIImageView *incomingView;
    UIView *fullIncomingView;
    UIImageView *callingView;
    UIView *fullCallingView;
    NSString *toName;
    NSString *fromName;
    NSString *savedNum;
//    NSString *talkingTime;
  	NSTimer *_timerCall, *_timerQual;
    NSDictionary *callingDic;
    UILabel *time;
    UILabel *qual;
    BOOL callingByPush;
    BOOL viewShown;
    
    UIButton *cancel;
    UIButton *answer;
    UIButton *dial;
    
    
    BOOL bSpeakerOn;
    BOOL bIncoming;
    NSInteger viewTag;
    UIView *dialView;
    SystemSoundID ringSound;
    
}

- (void)isCallingByPush:(BOOL)yn;
//- (void)isViewShown:(BOOL)yn;
- (UIView *)setFullIncoming:(NSDictionary *)dic active:(BOOL)active;
- (UIView *)setFullOutgoing:(NSString *)u usingUid:(int)usingUid;
- (void)mvoipIncomingWith:(NSDictionary *)dic;
- (void)checkPush;
- (void)loadCallMember;
- (UIView *)setReDialing:(NSDictionary *)dic uid:(NSString *)uid;
- (BOOL)isCalling;

@property (nonatomic,retain) AVAudioPlayer *audioPlayer;
@property (nonatomic, retain) NSString *fromName;
@property (nonatomic, retain) NSString *toName;
@property (nonatomic, retain) NSString *savedNum;

@end
