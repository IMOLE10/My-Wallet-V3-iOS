// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol WalletPayloadServiceAPI: class {
    func requestUsingSessionToken() -> Single<AuthenticatorType>
    func requestUsingSharedKey() -> Completable
    func request(guid: String, sharedKey: String) -> Completable
}
