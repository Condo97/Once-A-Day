//
//  StoreKitManager.m
//  PaceKeeper
//
//  Created by Alex Coundouriotis on 7/3/18.
//  Copyright © 2018 Alex Coundouriotis. All rights reserved.
//

#import "StoreKitManager.h"
#import "SecretDefines2.pch"
#import "KFKeychain.h"

@implementation StoreKitManager

+ (id)sharedManager {
    static StoreKitManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    
    return sharedMyManager;
}

- (void)startPremiumPurchase {
    NSSet *identifiers = [NSSet setWithObject:PREMIUM_ID];
    self.productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:identifiers];
    [self.productsRequest setDelegate:self];
    [self.productsRequest start];
}

- (BOOL)canMakePurchases {
    return [SKPaymentQueue canMakePayments];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    int count = (int)response.products.count;
    
    if(count > 0) {
        NSArray *products = response.products;
        BOOL canMakePurchases = [SKPaymentQueue canMakePayments];
        
        if(canMakePurchases) {
            SKProduct *product = [products objectAtIndex:0];
            SKPayment *payment = [SKPayment paymentWithProduct:product];
            [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
            [[SKPaymentQueue defaultQueue] addPayment:payment];
        }
//        else {
//            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Error" message:@"Your device is not configured to make In App Purchases." preferredStyle:UIAlertControllerStyleAlert];
//            [ac addAction:[UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:nil]];
//        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    for(SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing: {
                NSLog(@"Purchasing");
                break;
            }   
            case SKPaymentTransactionStatePurchased: {
                if ([transaction.payment.productIdentifier
                     isEqualToString:PREMIUM_ID]) {
                    NSLog(@"Purchased ");
                    [KFKeychain saveObject:[NSNumber numberWithBool:YES] forKey:PREMIUM_PURCHASED];
                    [self.delegate purchaseSuccessful];
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            }
            case SKPaymentTransactionStateRestored: {
                NSLog(@"Restored ");
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            }
                
            case SKPaymentTransactionStateFailed: {
                NSLog(@"Purchase failed ");
                [self.delegate purchaseUnsuccessful];
                break;
            }
            default:
                break;
        }
    }
}

- (void)restorePurchases {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

@end
