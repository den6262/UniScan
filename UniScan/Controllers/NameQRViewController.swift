

import UIKit

class NameQRViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var createBtn: UIButton!
    
    //MARK: - Vars
    var updateTF = Timer()
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Text to generate QR-code"
        
        textField.placeholder = "Enter some text or urls"
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        timerFunc()
        
        textField.attributedPlaceholder = NSAttributedString(string: "Enter some text or urls",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.blue])
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        textField.text = ""
    }
    
    //MARK: - Funcs
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc func checkTextField() {
        if textField.text == "" || textField.text == " "{
            createBtn.isHidden = true
        } else {
            createBtn.isHidden = false
        }
    }
    
    func timerFunc() {
        updateTF.invalidate()
        
        updateTF = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(checkTextField), userInfo: nil, repeats: true)
    }
    
    //MARK: - Actions
    @IBAction func generateQRAction(_ sender: UIButton) {
        let ud = UserDefaults.standard
        ud.set(textField.text, forKey: "textForQR")
    }
    
}
