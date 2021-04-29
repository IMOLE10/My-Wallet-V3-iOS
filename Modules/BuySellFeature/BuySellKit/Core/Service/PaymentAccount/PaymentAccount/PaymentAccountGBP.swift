// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

struct PaymentAccountGBP: PaymentAccount, Equatable {
    var fields: [PaymentAccountProperty.Field] {
        [
            .accountNumber(accountNumber),
            .sortCode(sortCode),
            .recipientName(recipientName)
        ]
    }

    static let currency: FiatCurrency = .GBP
    let identifier: String
    let state: PaymentAccountProperty.State
    let currency: FiatCurrency = Self.currency
    let accountNumber: String
    let sortCode: String
    let recipientName: String

    init?(response: PlatformKit.PaymentAccount) {
        guard response.currency == Self.currency else {
            return nil
        }
        guard
            let accountNumber: String = response.agent.account,
            let sortCode: String = response.agent.code,
            let recipientName: String = response.agent.recipient
            else { return nil }
        self.accountNumber = accountNumber
        self.sortCode = sortCode
        self.recipientName = recipientName
        self.identifier = response.id
        self.state = response.state
    }
}
