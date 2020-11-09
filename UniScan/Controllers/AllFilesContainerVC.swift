

import UIKit

class AllFilesContainerVC: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var sideMenuConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    
    //MARK: - Vars
    var isOpenMenu = false
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureShadow()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(toggleSideMenu),
                                               name: NSNotification.Name("ToggleSideMenu"),
                                               object: nil)
        
    }
    
    //MARK: - Funcs
    private func configureShadow() {
        containerView.backgroundColor = .white
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 3.3, height: 3.3)
        containerView.layer.shadowOpacity = 1.0
        containerView.layer.shadowRadius = 7.7
    }
    
    @objc func toggleSideMenu() {
        if isOpenMenu {
            isOpenMenu = false
            sideMenuConstraint.constant = -240
            NotificationCenter.default.post(name: NSNotification.Name("CloseMenu"),
                                            object: nil)
        } else {
            isOpenMenu = true
            sideMenuConstraint.constant = 0
            NotificationCenter.default.post(name: NSNotification.Name("OpenMenu"),
                                            object: nil)
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

