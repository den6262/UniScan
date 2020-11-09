

import UIKit
import PDFKit
import WeScan

class PDFScanViewController: UIViewController {
    
    //MARK: - Vars
    var documents = [URL]()
    var scannedImage: UIImage!
    
    var isUnlockPro = false
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Scan a Document"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK: - Funcs
    func savePicture(picture: UIImage, imageName: String) {
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
        let data = picture.jpegData(compressionQuality: 1.0)
        FileManager.default.createFile(atPath: imagePath, contents: data, attributes: nil)
    }
    
    func showSaveDialog(scannedImage: UIImage) {
        let dateNow = Helpers.getDate()
        let alertController = UIAlertController(title: "Save Documents", message: "Create a name for the document", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Save", style: .default) { (_) in
            let name = alertController.textFields?[0].text
            if name != "" {
                if Helpers.checkSameName(fileName: name!, documents: self.documents) {
                    self.savePicture(picture: scannedImage, imageName: "\(name!) (1).jpg")
                } else {
                    self.savePicture(picture: scannedImage, imageName: "\(name!).jpg")
                }
            } else {
                self.savePicture(picture: scannedImage, imageName: "\(dateNow).jpg")
            }
            self.documents = Helpers.getDocuments()
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = "\(dateNow)"
        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        present(alertController, animated: true, completion: nil)
    }
    
}
