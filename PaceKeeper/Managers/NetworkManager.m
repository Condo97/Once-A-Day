//
//  NetworkManager.m
//  EReceipts
//
//  Created by Alex Coundouriotis on 2/27/18.
//  Copyright © 2018 Alex Coundouriotis. All rights reserved.
//

#import "NetworkManager.h"
#import "CDManager.h"

#define BASE_URL @"https://ereceipts.acapplications.com/"

@implementation NetworkManager

+ (id)sharedManager {
    static NetworkManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    
    return sharedMyManager;
}

- (void)createUser:(NSString *)username pass:(NSString *)pass email:(NSString *)email  {
    NSError __block *error;
    NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:
                          username, @"Username",
                          pass, @"Password",
                          email, @"Email",
                          nil];
    NSError *toPostSerializationError;
    NSData *dataToPost = [NSJSONSerialization dataWithJSONObject:message options:NSJSONWritingPrettyPrinted error:&toPostSerializationError];
    
    if(toPostSerializationError == nil) {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@createUser", BASE_URL]]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setTimeoutInterval:20.0];
        [request setHTTPBody:dataToPost];
        
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithRequest:request
                    completionHandler:^(NSData *data,
                                        NSURLResponse *urlResponse,
                                        NSError *httpError) {
                        if(httpError == nil) {
                            NSError *errorJSON;
                            NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorJSON];
                            if(errorJSON == nil) {
                                if((int)[[responseJSON objectForKey:@"Success"] intValue] == 1) {
                                    NSString *userID = [responseJSON objectForKey:@"UserID"];
                                    
                                    [[CDManager sharedManager] updateUser:username userID:userID password:pass];
                                    [self.delegate userCreated:YES error:nil];
                                } else {
                                    NSError *theError = [[NSError alloc] initWithDomain:@"" code:(int)[[responseJSON objectForKey:@"Success"] intValue] userInfo:@{@"Error": (NSString *)[responseJSON objectForKey:@"Reason"]}];
                                    error = theError;
                                    [self.delegate userCreated:NO error:error];
                                }
                            } else {
                                error = errorJSON;
                                [self.delegate userCreated:NO error:error];
                            }
                        } else {
                            error = httpError;
                            [self.delegate userCreated:NO error:error];
                        }
                    }] resume];
    } else {
        error = toPostSerializationError;
        [self.delegate userCreated:NO error:error];
    }
}

- (void)signIn:(NSString *)username password:(NSString *)password {
    NSError __block *error;
    NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:
                             username, @"Username",
                             password, @"Password",
                             nil];
    NSError *toPostSerializationError;
    NSData *dataToPost = [NSJSONSerialization dataWithJSONObject:message options:NSJSONWritingPrettyPrinted error:&toPostSerializationError];
    
    if(toPostSerializationError == nil) {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@userLogin", BASE_URL]]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setTimeoutInterval:20.0];
        [request setHTTPBody:dataToPost];
        
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithRequest:request
                    completionHandler:^(NSData *data,
                                        NSURLResponse *urlResponse,
                                        NSError *httpError) {
                        if(httpError == nil) {
                            NSError *errorJSON;
                            NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorJSON];
                            if(errorJSON == nil) {
                                if((int)[[responseJSON objectForKey:@"Success"] intValue] == 1) {
                                    NSString *userID = [responseJSON objectForKey:@"UserID"];
                                    
                                    [[CDManager sharedManager] updateUser:username userID:userID password:password];
                                    [self.delegate userSignedIn:YES error:nil];
                                } else {
                                    NSError *theError = [[NSError alloc] initWithDomain:@"" code:(int)[[responseJSON objectForKey:@"Success"] intValue] userInfo:@{@"Error": (NSString *)[responseJSON objectForKey:@"Reason"]}];
                                    error = theError;
                                    [self.delegate userSignedIn:NO error:error];
                                }
                            } else {
                                error = errorJSON;
                                [self.delegate userSignedIn:NO error:error];
                            }
                        } else {
                            error = httpError;
                            [self.delegate userSignedIn:NO error:error];
                        }
                    }] resume];
    } else {
        error = toPostSerializationError;
        [self.delegate userSignedIn:NO error:error];
    }
}

- (void)sendCID:(NSString *)CID userID:(NSString *)UID {
    NSError __block *error;
    NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:
                             CID, @"CID",
                             UID, @"UID",
                             nil];
    NSError *toPostSerializationError;
    NSData *dataToPost = [NSJSONSerialization dataWithJSONObject:message options:NSJSONWritingPrettyPrinted error:&toPostSerializationError];
    
    if(toPostSerializationError == nil) {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@userObtainedCID", BASE_URL]]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setTimeoutInterval:20.0];
        [request setHTTPBody:dataToPost];
        
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithRequest:request
                    completionHandler:^(NSData *data,
                                        NSURLResponse *urlResponse,
                                        NSError *httpError) {
                        if(httpError == nil) {
                            NSError *errorJSON;
                            NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorJSON];
                            if(errorJSON == nil) {
                                if((int)[[responseJSON objectForKey:@"Success"] intValue] == 1) {
                                    NSString *receiptID = [responseJSON objectForKey:@"ReceiptID"];
                                    
                                    ReceiptObject *receipt = [[ReceiptObject alloc] initWithReceiptID:receiptID open:YES];
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [[CDManager sharedManager] saveReceipt:receipt];
                                        
                                        [self.delegate receiptIDScanned:YES receiptID:receiptID error:nil];
                                    });
                                } else if((int)[[responseJSON objectForKey:@"Success"] intValue] == 58) {
                                    NSError *theError = [[NSError alloc] initWithDomain:@"" code:(int)[[responseJSON objectForKey:@"Success"] intValue] userInfo:@{@"Error": (NSString *)[responseJSON objectForKey:@"Reason"]}];
                                    error = theError;
                                    [self.delegate receiptIDScanned:NO receiptID:@"" error:error];
                                } else {
                                    NSError *theError = [[NSError alloc] initWithDomain:@"" code:(int)[[responseJSON objectForKey:@"Success"] intValue] userInfo:@{@"Error": (NSString *)[responseJSON objectForKey:@"Reason"]}];
                                    error = theError;
                                    [self.delegate receiptIDScanned:NO receiptID:@"" error:error];
                                }
                            } else {
                                error = errorJSON;
                                [self.delegate receiptIDScanned:NO receiptID:@"" error:error];
                            }
                        } else {
                            error = httpError;
                            [self.delegate receiptIDScanned:NO receiptID:@"" error:error];
                        }
                    }] resume];
    } else {
        error = toPostSerializationError;
        [self.delegate receiptIDScanned:NO receiptID:@"" error:error];
    }
}

- (void)getReceipt:(NSString *)receiptID userID:(NSString *)UID {
    NSError __block *error;
    NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:
                             receiptID, @"ReceiptID",
                             UID, @"UserID",
                             nil];
    NSError *toPostSerializationError;
    NSData *dataToPost = [NSJSONSerialization dataWithJSONObject:message options:NSJSONWritingPrettyPrinted error:&toPostSerializationError];
    
    if(toPostSerializationError == nil) {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@userObtainedCID", BASE_URL]]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setTimeoutInterval:20.0];
        [request setHTTPBody:dataToPost];
        
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithRequest:request
                    completionHandler:^(NSData *data,
                                        NSURLResponse *urlResponse,
                                        NSError *httpError) {
                        if(httpError == nil) {
                            NSError *errorJSON;
                            NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorJSON];
                            if(errorJSON == nil) {
                                if((int)[[responseJSON objectForKey:@"Success"] intValue] == 1) {
                                    ReceiptObject *receipt;
                                    NSString *receiptID = [responseJSON objectForKey:@"ReceiptID"];
                                    
                                    if([((NSNumber *)[responseJSON objectForKey:@"Open"]) isEqualToNumber:@0]) {
                                        NSArray *unimportantMeta = [responseJSON objectForKey:@"UnimportantMeta"];
                                        NSDictionary *importantMeta = [responseJSON objectForKey:@"ImportantMeta"];
                                        NSArray *receiptData = [responseJSON objectForKey:@"ReceiptData"];
                                        
                                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                        [dateFormatter setDateFormat:@"yyyy:MM:dd:HH:mm:ss"];
                                        NSString *timeString = [responseJSON objectForKey:@"Time"];
                                        NSDate *date = [dateFormatter dateFromString:timeString];
                                        
                                        receipt = [[ReceiptObject alloc] initWithReceiptID:receiptID open:NO       importantMeta:importantMeta unimportantMeta:unimportantMeta  receiptData:receiptData businessName:[responseJSON objectForKey:@"BusinessName"] businessAddress:[responseJSON objectForKey:@"BusinessAddress"] merchantName:[responseJSON objectForKey:@"MerchantName"] merchantID:[responseJSON objectForKey:@"MerchantID"] time:date transactionType:[responseJSON objectForKey:@"TransactionType"] paymentMethod:[responseJSON objectForKey:@"PaymentMethod"] cardBrand:[responseJSON objectForKey:@"CardBrand"] cardResponse:[responseJSON objectForKey:@"CardResponse"] approvalID:[responseJSON objectForKey:@"ApprovalID"] refundPolicy:[responseJSON objectForKey:@"RefundPolicy"] lastFourCC:[responseJSON objectForKey:@"LastFourCC"] categoryIndex:((NSNumber *)[responseJSON objectForKey:@"CategoryIndex"]).intValue categoryName:[responseJSON objectForKey:@"CategoryName"]];
                                        
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [[CDManager sharedManager] saveReceipt:receipt];
                                        });
                                    } else {
                                        receipt = [[ReceiptObject alloc] initWithReceiptID:receiptID open:YES];
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [[CDManager sharedManager] saveReceipt:receipt];
                                        });
                                    }
                                    
                                    [self.delegate receiptSaved:YES error:nil];
                                } else {
                                    NSError *theError = [[NSError alloc] initWithDomain:@"" code:(int)[[responseJSON objectForKey:@"Success"] intValue] userInfo:@{@"Error": (NSString *)[responseJSON objectForKey:@"Reason"]}];
                                    error = theError;
                                    [self.delegate receiptSaved:NO error:error];
                                }
                            } else {
                                error = errorJSON;
                                [self.delegate receiptSaved:NO error:error];
                            }
                        } else {
                            error = httpError;
                            [self.delegate receiptSaved:NO error:error];
                        }
                    }] resume];
    } else {
        error = toPostSerializationError;
        [self.delegate receiptSaved:NO error:error];
    }
}

- (void)getNewReceiptsExcludingOpen:(NSString *)userID password:(NSString *)password receiptIDs:(NSArray *)receiptIDs {
    NSError __block *error;
    
    NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:
                             userID, @"UserID",
                             password, @"Password",
                             receiptIDs, @"ReceiptIDs",
                             nil];
    NSError *toPostSerializationError;
    NSData *dataToPost = [NSJSONSerialization dataWithJSONObject:message options:NSJSONWritingPrettyPrinted error:&toPostSerializationError];
    
    if(toPostSerializationError == nil) {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@getNewReceipts", BASE_URL]]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setTimeoutInterval:20.0];
        [request setHTTPBody:dataToPost];
        
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithRequest:request
                    completionHandler:^(NSData *data,
                                        NSURLResponse *urlResponse,
                                        NSError *httpError) {
                        if(httpError == nil) {
                            NSError *errorJSON;
                            NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorJSON];
                            if(errorJSON == nil) {
                                if((int)[[responseJSON objectForKey:@"Success"] intValue] == 1) {
                                    NSArray *receipts = [responseJSON objectForKey:@"Receipts"];
                                    for(int i = 0; i < receipts.count; i++) {
                                        if([((NSNumber *)[receipts[i] objectForKey:@"Open"]) isEqualToNumber:@0]) {
                                            if([receipts[i] objectForKey:@"ReceiptData"] != nil) {
                                                NSString *receiptID = [receipts[i] objectForKey:@"ReceiptID"];
                                                
                                                [[CDManager sharedManager] shouldReplaceReceipt:receiptID completion:^(BOOL shouldReplace) {
                                                    if(shouldReplace) {
                                                        [[CDManager sharedManager] deleteReceiptWithID:receiptID];
                                                    } else {
                                                        NSArray *unimportantMeta = [receipts[i] objectForKey:@"UnimportantMeta"];
                                                        NSDictionary *importantMeta = [receipts[i] objectForKey:@"ImportantMeta"];
                                                        NSArray *receiptData = [receipts[i] objectForKey:@"ReceiptData"];
                                                        
                                                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                                        [dateFormatter setDateFormat:@"yyyy:MM:dd:HH:mm:ss"];
                                                        NSString *timeString = [receipts[i] objectForKey:@"Time"];
                                                        NSDate *date = [dateFormatter dateFromString:timeString];
                                                        ReceiptObject *receipt;
                                                        receipt = [[ReceiptObject alloc] initWithReceiptID:receiptID open:NO       importantMeta:importantMeta unimportantMeta:unimportantMeta  receiptData:receiptData businessName:[receipts[i] objectForKey:@"BusinessName"] businessAddress:[receipts[i] objectForKey:@"BusinessAddress"] merchantName:[receipts[i] objectForKey:@"MerchantName"] merchantID:[receipts[i] objectForKey:@"MerchantID"] time:date transactionType:[receipts[i] objectForKey:@"TransactionType"] paymentMethod:[receipts[i] objectForKey:@"PaymentMethod"] cardBrand:[receipts[i] objectForKey:@"CardBrand"] cardResponse:[receipts[i] objectForKey:@"CardResponse"] approvalID:[receipts[i] objectForKey:@"ApprovalID"] refundPolicy:[receipts[i] objectForKey:@"RefundPolicy"] lastFourCC:[receipts[i] objectForKey:@"LastFourCC"] categoryIndex:((NSNumber *)[receipts[i] objectForKey:@"CategoryIndex"]).intValue categoryName:[receipts[i] objectForKey:@"CategoryName"]];
                                                        [[CDManager sharedManager] saveReceipt:receipt];
                                                        
                                                        [self.delegate newReceiptsRetrieved:YES error:nil];
                                                    }
                                                }];
                                            } else {
                                                [self.delegate newReceiptsRetrieved:NO error:nil];
                                            }
                                        } else {
                                            
//                                            NSString *receiptID = [receipts[i] objectForKey:@"ReceiptID"];
//                                            receipt = [[ReceiptObject alloc] initWithReceiptID:receiptID open:YES];
//                                            [[CDManager sharedManager] saveReceipt:receipt];
                                        }
                                    }
                                    
                                    if(receipts.count == 0)
                                        [self.delegate newReceiptsRetrieved:NO error:nil];                                        
                                } else {
                                    NSError *theError = [[NSError alloc] initWithDomain:@"" code:(int)[[responseJSON objectForKey:@"Success"] intValue] userInfo:@{@"Error": (NSString *)[responseJSON objectForKey:@"Reason"]}];
                                    error = theError;
                                    [self.delegate newReceiptsRetrieved:NO error:error];
                                }
                            } else {
                                error = errorJSON;
                                [self.delegate newReceiptsRetrieved:NO error:error];
                            }
                        } else {
                            error = httpError;
                            [self.delegate newReceiptsRetrieved:NO error:error];
                        }
                    }] resume];
    } else {
        error = toPostSerializationError;
        [self.delegate newReceiptsRetrieved:NO error:error];
    }
}

- (void)getLogoForReceipt:(NSString *)receiptID {
    NSError __block *error;
    NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:
                             receiptID, @"ReceiptID",
                             nil];
    NSError *toPostSerializationError;
    NSData *dataToPost = [NSJSONSerialization dataWithJSONObject:message options:NSJSONWritingPrettyPrinted error:&toPostSerializationError];
    
    if(toPostSerializationError == nil) {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@getLogoForReceipt", BASE_URL]]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setTimeoutInterval:20.0];
        [request setHTTPBody:dataToPost];
        
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithRequest:request
                    completionHandler:^(NSData *data,
                                        NSURLResponse *urlResponse,
                                        NSError *httpError) {
                        if(httpError == nil) {
                            NSError *errorJSON;
                            NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorJSON];
                            if(errorJSON == nil) {
                                if((int)[[responseJSON objectForKey:@"Success"] intValue] == 1) {
                                    if([responseJSON objectForKey:@"ImageData"] != nil) {
                                        NSString *tempDataString = [responseJSON objectForKey:@"ImageData"];
                                        
                                        if([tempDataString containsString:@"base64"]) {
                                            NSRange range = [tempDataString rangeOfString:@"base64,"];
                                            NSInteger end = range.location + range.length;
                                            NSString *trimmedString = [tempDataString substringFromIndex:end];
                                            
                                            NSData *data = [[NSData alloc] initWithBase64EncodedString:trimmedString options:0];
                                            [[CDManager sharedManager] saveLogo:[UIImage imageWithData:data] receiptID:[responseJSON objectForKey:@"ReceiptID"]];
                                            
                                            [self.delegate obtainedLogo:YES error:nil];
                                        } else {
                                            [self.delegate obtainedLogo:NO error:error];
                                        }
                                    }
                                } else {
                                    NSError *theError = [[NSError alloc] initWithDomain:@"" code:(int)[[responseJSON objectForKey:@"Success"] intValue] userInfo:@{@"Error": (NSString *)[responseJSON objectForKey:@"Reason"]}];
                                    error = theError;
                                    [self.delegate obtainedLogo:NO error:error];
                                }
                            } else {
                                error = errorJSON;
                                [self.delegate obtainedLogo:NO error:error];
                            }
                        } else {
                            error = httpError;
                            [self.delegate obtainedLogo:NO error:error];
                        }
                    }] resume];
    } else {
        error = toPostSerializationError;
        [self.delegate receiptSaved:NO error:error];
    }
}

@end
