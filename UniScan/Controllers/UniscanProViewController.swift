

import UIKit
import StoreKit
import ApphudSDK

class UniscanProViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var naviBar: UINavigationBar!
    @IBOutlet weak var policyBtn: UIButton!
    @IBOutlet weak var termsBtn: UIButton!
    
    //MARK: - Vars
    var products = [SKProduct]()
    
    let cellSpacingHeight: CGFloat = 10
    
    var isUnlockPro = false
    
    var introductoryEligibility = [String : Bool]()
    var promoOffersEligibility = [String : Bool]()
    var canShowApphudScreen = true
    
    var policyUrl = URL(string: "https://caramba-apps.com/privacy/")
    
    var termsUrl = URL(string: "https://www.caramba-apps.com/terms/")
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // In this example we set delegate to ViewController to reload tableview when changes come
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.separatorStyle = .none
        
        Apphud.setDelegate(self)
        Apphud.setUIDelegate(self)
        
        reload()
        
        if Apphud.products() == nil {
            Apphud.productsDidFetchCallback { (products) in
                print("products loaded and callback called!")
                self.products = products
                self.reload()
            }
        } else {
            print("products already loaded and callback not called!")
            self.products = Apphud.products()!
        }
        
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
        //            Apphud.refreshStoreKitProducts { products in
        //                print("storekit products are refreshed! \(products.count)")
        //                self.products = products
        //                self.reload()
        //            }
        //        }
        //
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //print("will appear")
        super.viewWillAppear(animated)
        
        policyBtn.layer.masksToBounds = true
        termsBtn.layer.masksToBounds = true
        policyBtn.layer.cornerRadius = 7
        termsBtn.layer.cornerRadius = 7
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //print("did appear")
        super.viewDidAppear(animated)
    }
    
    //MARK: - Funcs
    @objc func reload(){
        Apphud.checkEligibilitiesForIntroductoryOffers(products: products) { (response) in
            self.introductoryEligibility = response
            if #available(iOS 12.2, *) {
                Apphud.checkEligibilitiesForPromotionalOffers(products: self.products) { (response) in
                    self.promoOffersEligibility = response
                    self.tableView.reloadData()
                }
            } else {
                self.tableView.reloadData()
            }
        }
        
        tableView.reloadData()
    }
    
    @available(iOS 12.2, *)
    func showPromoOffersAlert(product : SKProduct) {
        
        let controller = UIAlertController(title: "You already have subscription for this product", message: "would you like to activate promo offer?", preferredStyle: .alert)
        
        for discount in product.discounts {
            controller.addAction(UIAlertAction(title: "Purchase Promo: \(discount.identifier!)", style: .default, handler: { act in
                self.purchaseProduct(product: product, promoID: discount.identifier!)
            }))
        }
        
        controller.addAction(UIAlertAction(title: "Purchase Product As Usual", style: .destructive, handler: { act in
            self.purchaseProduct(product: product)
        }))
        
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)
    }
    
    @available(iOS 12.2, *)
    func purchaseProduct(product: SKProduct, promoID: String){
        Apphud.purchasePromo(product, discountID: promoID) { (result) in
            self.reload()
        }
    }
    
    func purchaseProduct(product : SKProduct) {
        Apphud.purchase(product) { (result) in
            self.reload()
        }
    }
    
    //MARK:- TableView Delegate methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! ProductCell
        let product = products[indexPath.item]
        
        if var text = product.fullSubscriptionInfoString() {
            if self.promoOffersEligibility[product.productIdentifier] != nil {
                //                text = "\(text)\nEligible for promo: \(self.promoOffersEligibility[product.productIdentifier]!)"
                //            }
                //            if self.introductoryEligibility[product.productIdentifier] != nil {
                //                text = "\(text)\nEligible for introductory: \(self.introductoryEligibility[product.productIdentifier]!)"
                cell.textLabel?.text = text
            }
            cell.textLabel?.text = text
        } else {
            cell.textLabel?.text = product.localizedPriceFrom(price: product.price)
        }
        
        if let subscription = Apphud.subscriptions()?.first(where: {$0.productId == product.productIdentifier}) {
            
            cell.detailTextLabel?.text = // subscription.expiresDate.description +
                "\nState: \(subscription.status.toStringDuplicate())"
            
            //            \nIntroductory used:\(subscription.isIntroductoryActivated)".uppercased()
        }
        //            else if let purchase = Apphud.nonRenewingPurchases()?.first(where: {$0.productId == product.productIdentifier}) {
        //            cell.detailTextLabel?.text = "\(purchase.productId). Last Purchased at: \(purchase.purchasedAt)"
        //            print("purchase: \(purchase.productId) is active: \(purchase.isActive())")
        //        } else {
        //            cell.detailTextLabel?.text = "\(product.productIdentifier): not active"
        //        }
        
        cell.layer.cornerRadius = 10
        
        cell.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0.9179827571, alpha: 1)
        
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowRadius = 5.5
        cell.layer.shadowOpacity = 1.3
        cell.layer.shadowOffset = CGSize.zero
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.borderWidth = 3.5
        cell.layer.masksToBounds = false
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let product = products[indexPath.item]
        
        if #available(iOS 12.2, *) {
            if product.discounts.count > 0 && (Apphud.subscriptions()?.first(where: {$0.productId == product.productIdentifier}) != nil){
                // purchase promo offer
                showPromoOffersAlert(product: product)
            } else {
                purchaseProduct(product: product)
            }
        } else {
            purchaseProduct(product: product)
        }
    }
    
    //MARK: - Actions
    @IBAction func restore(_ sender: Any){
        Apphud.restorePurchases { subscriptions, purchases, error in
            self.reload()
            if Apphud.hasActiveSubscription() {
                self.isUnlockPro = true
                let ud = UserDefaults.standard
                ud.set(self.isUnlockPro, forKey: "unlock")
            } else {
                self.isUnlockPro = false
                let ud = UserDefaults.standard
                ud.set(self.isUnlockPro, forKey: "unlock")
                let alert = UIAlertController(title: "Oops!!!", message: "It looks like you didn’t make a purchase before or the deactivation of the purchase has expired ... Try again or buy the product.", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showPolicy(_ sender: Any) {
        UIApplication.shared.open(self.policyUrl!, options: [:], completionHandler: nil)
    }
    
    @IBAction func showTerms(_ sender: Any) {
        UIApplication.shared.open(self.termsUrl!, options: [:], completionHandler: nil)
    }
}

//MARK: - Extension of ApphudDelegate
extension UniscanProViewController : ApphudDelegate {
    
    func apphudDidChangeUserID(_ userID: String) {
        print("new apphud user id: \(userID)")
    }
    
    func apphudDidFetchStoreKitProducts(_ products: [SKProduct]) {
        print("apphudDidFetchStoreKitProducts")
        //   self.products = products
        self.reload()
    }
    
    func apphudSubscriptionsUpdated(_ subscriptions: [ApphudSubscription]) {
        self.reload()
        print("apphudSubscriptionsUpdated")
    }
    
    func apphudNonRenewingPurchasesUpdated(_ purchases: [ApphudNonRenewingPurchase]) {
        print("non renewing purchases updated")
    }
    
    func apphudShouldStartAppStoreDirectPurchase(_ product: SKProduct) -> ((ApphudPurchaseResult) -> Void)? {
        let callback : ((ApphudPurchaseResult) -> Void) = { result in
            // handle ApphudPurchaseResult
            self.reload()
        }
        return callback
    }
}

//MARK: - Extension of ApphudUIDelegate
extension UniscanProViewController : ApphudUIDelegate {
    
    func apphudShouldPerformRule(rule: ApphudRule) -> Bool {
        return true
    }
    
    func apphudShouldShowScreen(screenName: String) -> Bool {
        return true
    }
    
    func apphudScreenPresentationStyle(controller: UIViewController) -> UIModalPresentationStyle {
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .pageSheet
        } else {
            return .pageSheet
        }
    }
    
    func apphudDidDismissScreen(controller: UIViewController) {
        print("did dismiss screen")
    }
    
    func apphudDidPurchase(product: SKProduct, offerID: String?, screenName: String) {
        print("did purchase \(product.productIdentifier), offer: \(offerID ?? ""), screenName: \(screenName)")
    }
    
    func apphudDidFailPurchase(product: SKProduct, offerID: String?, errorCode: SKError.Code, screenName: String) {
        print("did fail purchase \(product.productIdentifier), offer: \(offerID ?? ""), screenName: \(screenName), errorCode:\(errorCode.rawValue)")
    }
    
    func apphudWillPurchase(product: SKProduct, offerID: String?, screenName: String) {
        print("will purchase \(product.productIdentifier), offer: \(offerID ?? ""), screenName: \(screenName)")
    }
    
}
