

import UIKit

class StartQRScannerVC: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var scanQRBtn: UIButton!
    @IBOutlet weak var createOwnQRBtn: UIButton!
    
    //MARK: - Vars
    //var isLockOrNot = false
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Scan a QR-code"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
}
