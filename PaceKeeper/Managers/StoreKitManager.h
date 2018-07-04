//
//  StoreKitManager.h
//  PaceKeeper
//
//  Created by Alex Coundouriotis on 7/3/18.
//  Copyright © 2018 Alex Coundouriotis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@protocol StoreKitManagerDelegate <NSObject>

@required
- (void)purchaseSuccessful;
- (void)purchaseUnsuccessful;

@end

@interface StoreKitManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (nonatomic, weak) id<StoreKitManagerDelegate> delegate;
@property (strong, nonatomic) SKProductsRequest *productsRequest;

+ (id)sharedManager;
- (void)startPremiumPurchase;
- (void)restorePurchases;

@end
