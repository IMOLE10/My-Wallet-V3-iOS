//
//  ContactTransaction.h
//  Blockchain
//
//  Created by kevinwu on 1/11/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "Transaction.h"

typedef enum {
    ContactTransactionStateNone,
    ContactTransactionStateSendWaitingForQR, // User tapped 'Ask to Send Bitcoin'
    ContactTransactionStateSendReadyToSend, // User tapped 'Ask to Send Bitcoin' -> QR Received OR Contact tapped 'Request Bitcoin from Contact'
    ContactTransactionStateReceiveAcceptOrDenyPayment, // Contact tapped 'Ask to Send Bitcoin'
    ContactTransactionStateReceiveWaitingForPayment, // User tapped 'Request Bitcoin from Contact' OR Contact tapped 'Ask to Send Bitcoin' -> QR Sent
    ContactTransactionStateCompletedSend,
    ContactTransactionStateCompletedReceive
} ContactTransactionState;

@interface ContactTransaction : Transaction

@property (nonatomic, readonly) ContactTransactionState transactionState;
@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) NSString *state;
@property (nonatomic, readonly) uint64_t intendedAmount;
@property (nonatomic, readonly) NSString *role;
@property (nonatomic, readonly) NSString *address;
@property (nonatomic, readonly) NSString *reason;

// Pending requests
@property (nonatomic, readonly) NSString *contactIdentifier;

- (id)initWithDictionary:(NSDictionary *)dictionary contactIdentifier:(NSString *)identifier;

@end
