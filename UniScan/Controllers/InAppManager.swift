import Foundation
import StoreKit

enum ProductType: String {
    case weekly = "com.example.app.weekly"
    case monthly = "com.example.app.monthly"
    case yearly = "com.example.app.yearly"
    
    static var all: [ProductType] {
        return [.weekly, .monthly, .yearly]
    }
}

enum InAppErrors: Swift.Error {
    case noSubscriptionPurchased
    case noProductsAvailable
    
    var localizedDescription: String {
        switch self {
        case .noSubscriptionPurchased:
            return "No subscription purchased"
        case .noProductsAvailable:
            return "No products available"
        }
    }
}

protocol InAppManagerDelegate: class {
    func inAppLoadingStarted()
    func inAppLoadingSucceded(productType: ProductType)
    func inAppLoadingFailed(error: Swift.Error?)
    func subscriptionStatusUpdated(value: Bool)
}

class InAppManager: NSObject {
    static let shared = InAppManager()
    
    weak var delegate: InAppManagerDelegate?
    
    var products: [SKProduct] = []
    
    var isTrialPurchased: Bool?
    var expirationDate: Date?
    var purchasedProduct: ProductType?
    
    var isSubscriptionAvailable: Bool = true
        {
        didSet(value) {
            self.delegate?.subscriptionStatusUpdated(value: value)
        }
    }
    
    func startMonitoring() {
        SKPaymentQueue.default().add(self)
        self.updateSubscriptionStatus()
    }
    
    func stopMonitoring() {
        SKPaymentQueue.default().remove(self)
    }
    
    func loadProducts() {
        let productIdentifiers = Set<String>(ProductType.all.map({$0.rawValue}))
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
    }
    
    func purchaseProduct(productType: ProductType) {
        guard let product = self.products.filter({$0.productIdentifier == productType.rawValue}).first else {
            self.delegate?.inAppLoadingFailed(error: InAppErrors.noProductsAvailable)
            return
        }
        let payment = SKMutablePayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func restoreSubscription() {
        SKPaymentQueue.default().restoreCompletedTransactions()
        self.delegate?.inAppLoadingStarted()
    }
    
    func checkSubscriptionAvailability(_ completionHandler: @escaping (Bool) -> Void) {
        guard let receiptUrl = Bundle.main.appStoreReceiptURL,
            let receipt = try? Data(contentsOf: receiptUrl).base64EncodedString() as AnyObject else {
                completionHandler(false)
                return
        }
        
//       let _ = Router.User.sendReceipt(receipt: receipt).request(baseUrl: "https://sandbox.itunes.apple.com").responseObject { (response: DataResponse<RTSubscriptionResponse>) in
//           switch response.result {
//           case .success(let value):
//               guard let expirationDate = value.expirationDate,
//                   let productId = value.productId else {completionHandler(false); return}
//               self.expirationDate = expirationDate
//               self.isTrialPurchased = value.isTrial
//               self.purchasedProduct = ProductType(rawValue: productId)
//               completionHandler(Date().timeIntervalSince1970 < expirationDate.timeIntervalSince1970)
//           case .failure(let error):
//               completionHandler(false)
//           }
//       }
    }
    
    func updateSubscriptionStatus() {
        self.checkSubscriptionAvailability({ [weak self] (isSubscribed) in
            self?.isSubscriptionAvailable = isSubscribed
        })
    }
}

extension InAppManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            guard let productType = ProductType(rawValue: transaction.payment.productIdentifier) else {fatalError()}
            switch transaction.transactionState {
            case .purchasing:
                self.delegate?.inAppLoadingStarted()
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
                self.updateSubscriptionStatus()
                self.isSubscriptionAvailable = true
                self.delegate?.inAppLoadingSucceded(productType: productType)
            case .failed:
                if let transactionError = transaction.error as? NSError,
                    transactionError.code != SKError.paymentCancelled.rawValue {
                    self.delegate?.inAppLoadingFailed(error: transaction.error)
                } else {
                    self.delegate?.inAppLoadingFailed(error: InAppErrors.noSubscriptionPurchased)
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                self.updateSubscriptionStatus()
                self.isSubscriptionAvailable = true
                self.delegate?.inAppLoadingSucceded(productType: productType)
            case .deferred:
                self.delegate?.inAppLoadingSucceded(productType: productType)
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Swift.Error) {
        self.delegate?.inAppLoadingFailed(error: error)
    }
    
}

//MARK: - SKProducatsRequestDelegate
extension InAppManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        guard response.products.count > 0 else {return}
        self.products = response.products
    }
}
