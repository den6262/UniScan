

import UIKit

class OwnQRCodeViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var qrImgView: UIImageView!
    
    //MARK: - Vars
    var textForQR = String(UserDefaults.standard.string(forKey: "textForQR")!)
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "QR-code of: \(String(UserDefaults.standard.string(forKey: "textForQR")!))"
        
        qrImgView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0.9179827571, alpha: 1)
        qrImgView.layer.borderWidth = 4.4
        qrImgView.layer.masksToBounds = false
        
        qrImgView.layer.cornerRadius = 15
        qrImgView.layer.masksToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        qrImgView.image = generateQRCode(from: textForQR)
        
    }
    
    //MARK: - Functions
    func generateQRCode(from string:String) -> UIImage? {
        
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator"){
            
            filter.setValue(data, forKey: "inputMessage")
            
            let transform = CGAffineTransform(scaleX: 50, y: 50)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
            
        }
        
        return nil
        
    }
    
    open func save(_ shouldSave: Bool = true) -> UIImage? {
        var screenshotImage: UIImage?
        let layer = UIApplication.shared.keyWindow!.layer
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        guard let context = UIGraphicsGetCurrentContext() else {return nil}
        layer.render(in:context)
        screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let image = screenshotImage, shouldSave {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
        return screenshotImage
    }
    
    //MARK: - Actions
    @IBAction func save(_ sender: UIButton) {
        if qrImgView.image != nil {
            save()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let alert = UIAlertController(title: "Super!!!", message: "QR-code image successfully saved to the gallery", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            return
        }
        
    }
    
}
