//
//  NetworkManager.h
//  EReceipts
//
//  Created by Alex Coundouriotis on 2/27/18.
//  Copyright © 2018 Alex Coundouriotis. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NetworkManagerDelegate <NSObject>
@optional
- (void)userCreated:(BOOL)success error:(NSError *)error;
- (void)userSignedIn:(BOOL)success error:(NSError *)error;
- (void)receiptIDScanned:(BOOL)success receiptID:(NSString *)receiptID error:(NSError *)error;
- (void)receiptSaved:(BOOL)success error:(NSError *)error;
- (void)newReceiptsRetrieved:(BOOL)success error:(NSError *)error;
- (void)obtainedLogo:(BOOL)success error:(NSError *)error;

@end

@interface NetworkManager : NSObject

@property (nonatomic, assign) id<NetworkManagerDelegate> delegate;

+ (id)sharedManager;
- (void)createUser:(NSString *)username pass:(NSString *)pass email:(NSString *)email;
- (void)signIn:(NSString *)username password:(NSString *)password;
- (void)sendCID:(NSString *)CID userID:(NSString *)UID;
- (void)getReceipt:(NSString *)receiptID userID:(NSString *)UID;
- (void)getNewReceiptsExcludingOpen:(NSString *)userID password:(NSString *)password receiptIDs:(NSArray *)receiptIDs;
- (void)getLogoForReceipt:(NSString *)receiptID;

@end
