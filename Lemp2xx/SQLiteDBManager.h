//
//  SQLiteDBManager.h
//  iTender
//
//  Created by HyeongJun Park on 13. 2. 20..
//  Copyright (c) 2013년 BENCHBEE. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface SQLiteDBManager : NSObject

+ (void)initDB;

#pragma mark - Contact / Organize / Favorite
+ (NSMutableArray *)getOrganizing;
+ (NSMutableArray *)getList;

+ (BOOL)addDept:(NSMutableArray *)array init:(BOOL)init;
+ (void)addDeptDic:(NSDictionary *)dic;
+ (BOOL)addContact:(NSMutableArray *)array init:(BOOL)init;
+ (void)addContactDic:(NSDictionary *)dic;

+ (void)removeContactWithUid:(NSString *)uid all:(BOOL)all;
+ (BOOL)removeContact:(NSArray*)array;
+ (void)removeDeptWithCode:(NSString *)code all:(BOOL)all;
+ (BOOL)removeDept:(NSArray*)array;

+ (void)updateFavorite:(NSString *)fav uniqueid:(NSString *)uid;
+ (void)updateFavoriteOnlyDB:(NSString *)fav uniqueid:(NSString *)uid;

+ (BOOL)updateContact:(NSDictionary *)dic;
+ (BOOL)updateContactArray:(NSMutableArray *)array;
+ (void)updateMyProfileImage:(NSString*)fileName;
+ (void)updateDept:(NSDictionary *)dic;
+ (BOOL)updateDeptArray:(NSMutableArray *)array;

+ (NSDictionary *)searchContactDictionaryLight:(NSString *)uid;
+ (NSArray *)getProfileImageDirectory;

#pragma mark - ChatList
+ (void)removeRoom:(NSString *)rk all:(BOOL)all;
+ (void)removeRooms:(NSArray*)array;
+ (void)removeMessageWithRk:(NSString *)rk index:(NSString *)index;
+ (void)AddChatListWithRk:(NSString *)rk uids:(NSString *)uids names:(NSString *)names lastmsg:(NSString *)lastmsg
                     date:(NSString *)date time:(NSString *)time msgidx:(NSString *)lastidx type:(NSString *)rtype order:(NSString *)order groupnumber:(NSString *)groupnumber;
+ (void)updateLastmessage:(NSString *)msg date:(NSString *)date time:(NSString *)time idx:(NSString *)lastidx rk:(NSString *)rk order:(NSString *)order;
//+ (void)updateRoomMember:(NSString *)member name:(NSString *)name rk:(NSString *)rk;
+ (void)updateRoomMember:(NSString *)uids rk:(NSString *)rk;
//+ (void)updateAlarmIsMute:(BOOL)status roomkey:(NSString*)rk;
+ (NSArray *)getChatList;
+ (NSArray *)getRecentChatList;
//+ (BOOL)getAlarmIsMute:(NSString*)roomkey;
+ (void)updateRoomName:(NSString *)names rk:(NSString *)rk;

#pragma mark - MSG
+ (void)AddMessageWithRk:(NSString *)rk read:(NSString *)read sid:(NSString *)sid msg:(NSString *)msg date:(NSString *)date time:(NSString *)time
				  msgidx:(NSString *)msgidx type:(NSString *)type direct:(NSString *)direct name:(NSString *)name;
+ (void)updateReadInfo:(NSString *)read changingIdx:(NSString *)cidx idx:(NSString *)idx;
+ (void)updateUnreadAtRoom:(NSString *)rk;
+ (void)updateReadInfoAtRoom:(NSString *)rk;
+ (void)RemoveMessageWithRk:(NSString *)rk index:(NSString *)index all:(BOOL)all;
+ (NSMutableArray *)getMessageFromDB:(NSString *)rk type:(NSString *)type number:(int)num;
+ (NSString*)getFileStatus:(NSString*)idx;
+ (void)updateUnReadInfo:(NSString *)unread atIdx:(NSString *)idx;
+ (void)updateRoomkey:(NSString *)rk number:(NSString *)number;

#pragma mark - CALLLOG
+ (void)AddListWithTalkdate:(NSString *)Talkdate FromName:(NSString *)FromName ToName:(NSString *)ToName Talktime:(NSString *)Talktime Num:(NSString *)Num;
+ (void)removeCallLogRecordWithId:(int)Id all:(BOOL)all;
+ (void)removeCallLogRecords:(NSArray*)array;
+ (NSArray *)getLog;

@end
