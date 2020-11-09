

import UIKit
import PDFKit
import ApphudSDK

class AllFilesVC: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - Vars
    var menuBtn: UIButton!
    var leftBtn: UIBarButtonItem!
    
    var documents = [URL]()
    var scannedImage: UIImage!
    var documentOrderNumber = 0
    
    var isUnlockPro = false
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem?.tintColor = .white
        
        title = "All Files"
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(closeMenu),
                                               name: NSNotification.Name("CloseMenu"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(openMenu),
                                               name: NSNotification.Name("OpenMenu"),
                                               object: nil)
        
        menuBtn = UIButton(frame: CGRect(x: 0,y: 0,width: 30,height: 30))
        menuBtn.addTarget(self, action: #selector(onMenuTapped(_:)), for: .touchUpInside)
        menuBtn.setImage(UIImage(named: "menu"), for: .normal)
        leftBtn = UIBarButtonItem(customView: menuBtn)
        self.navigationItem.setLeftBarButtonItems([leftBtn], animated: true)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showPDFScanner),
                                               name: NSNotification.Name("ShowPDFScanner"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showQRScanner),
                                               name: NSNotification.Name("ShowQRScanner"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showPro),
                                               name: NSNotification.Name("ShowPro"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(collectionViewReload),
                                               name: NSNotification.Name("ReloadData"),
                                               object: nil)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.backgroundColor = .white
        collectionView?.contentInset = UIEdgeInsets(top: 15, left: 10, bottom: 15, right: 10)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        documents = Helpers.getDocuments()
        collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if Apphud.hasActiveSubscription() {
                self.isUnlockPro = true
                let ud = UserDefaults.standard
                ud.set(self.isUnlockPro, forKey: "unlock")
            } else {
                self.isUnlockPro = false
                let ud = UserDefaults.standard
                ud.set(self.isUnlockPro, forKey: "unlock")
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "UniscanProViewController") as! UniscanProViewController
                self.present(vc, animated: true, completion: nil)
            }
        }
        
        collectionView.reloadData()
    }
    
    @objc func collectionViewReload() {
        DispatchQueue.main.async {
            self.documents = Helpers.getDocuments()
            self.collectionView.reloadData()
        }
    }
    
    //MARK: - Funcs
    @objc func showPDFScanner() {
        performSegue(withIdentifier: "showPDF", sender: nil)
    }
    
    @objc func showQRScanner() {
        performSegue(withIdentifier: "showQR", sender: nil)
    }
    
    @objc func showPro() {
        performSegue(withIdentifier: "showPro", sender: nil)
    }
    
    @objc func closeMenu() {
        menuBtn.setImage(UIImage(named: "menu"), for: .normal)
    }
    
    @objc func openMenu() {
        isUnlockPro = UserDefaults.standard.bool(forKey: "unlock")
        if isUnlockPro {
            menuBtn.setImage(UIImage(named: "open-menu"), for: .normal)
        } else {
            menuBtn.setImage(UIImage(named: "menu"), for: .normal)
        }
    }
    
    @objc func onMenuTapped(_ sender: UIButton) {
        checkSubscriptions()
        isUnlockPro = UserDefaults.standard.bool(forKey: "unlock")
        if isUnlockPro {
            NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"),
                                            object: nil)
        } else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "UniscanProViewController") as! UniscanProViewController
            self.present(vc, animated: true, completion: nil)
        }
        
        
    }
    
    func checkSubscriptions() {
        if Apphud.hasActiveSubscription() {
            self.isUnlockPro = true
            let ud = UserDefaults.standard
            ud.set(self.isUnlockPro, forKey: "unlock")
        } else {
            self.isUnlockPro = false
            let ud = UserDefaults.standard
            ud.set(self.isUnlockPro, forKey: "unlock")
        }
    }
    
    func savePicture(picture: UIImage, imageName: String) {
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
        let data = picture.jpegData(compressionQuality: 0.9)
        FileManager.default.createFile(atPath: imagePath, contents: data, attributes: nil)
    }
    
    func showSaveDialog(scannedImage: UIImage) {
        let dateNow = Helpers.getDate()
        let alertController = UIAlertController(title: "Save Documents", message: "Enter document name", preferredStyle: .alert)
        
        //the confirm action taking the inputs
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
            self.collectionView.reloadData()
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
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "imageDetail" {
            var documentTitle = documents[documentOrderNumber].path.components(separatedBy: "Documents/")[1]
            documentTitle = String(Array(documentTitle)[0..<(documentTitle.count-4)])
            let imageVC = segue.destination as! ImageDetailViewController
            imageVC.imgNumber = documentOrderNumber
            imageVC.imageTitle = documentTitle
        } else if segue.identifier == "pdfDetail" {
            var documentTitle = documents[documentOrderNumber].path.components(separatedBy: "Documents/")[1]
            documentTitle = String(Array(documentTitle)[0..<(documentTitle.count-4)])
            let pdfVC = segue.destination as! PDFDetailViewController
            pdfVC.pdfNumber = documentOrderNumber
            pdfVC.pdfTitle = documentTitle
        }
    }
    
    // MARK: - Actions
    @IBAction func actionCollectionViewReload(_ sender: Any) {
        DispatchQueue.main.async {
            self.documents = Helpers.getDocuments()
            self.collectionView.reloadData()
        }
    }
}
