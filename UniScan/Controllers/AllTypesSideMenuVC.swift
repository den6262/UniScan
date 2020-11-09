

import UIKit

class AllTypesSideMenuVC: UITableViewController {
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Setup TableView
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"),
                                        object: nil)
        
        switch indexPath.row {
        case 0:
            NotificationCenter.default.post(name: NSNotification.Name("ShowPDFScanner"),
                                            object: nil)
        case 1:
            NotificationCenter.default.post(name: NSNotification.Name("ShowQRScanner"),
                                            object: nil)
        default:
            break
        }
        
    }
    
}
