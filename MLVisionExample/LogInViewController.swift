import UIKit
import Firebase




protocol LogInViewControllerDelegate {
    func didDismissToHomeView()
}

class LogInViewController: UIViewController, UITextFieldDelegate {
    
    // UI Outlets
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var logInViewControllerDelegate: LogInViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")

        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false

        view.addGestureRecognizer(tap)
        
        // Do any additional setup after loading the view.
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func LogInButton(_ sender: Any) {
        
        LogInWithFirebase()
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
    
    
    
    
    
    // Log in Code
    
    func LogInWithFirebase() {
        
        // checks if the email or password field is filled with something
        if let email = emailTextField.text, let password = passwordTextField.text {
            // passes it for firebase
            
            //showActivityIndicatory(uiView: self.view)
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                if error != nil {
                    // If there is no user, we throw a popup
                    //stopActivityIndicator()
                    let alert = UIAlertController(title: "Incorrect email or password.", message: "Please try again.", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                    //clear password field and make font red
                    self.passwordTextField.text = ""
                    self.passwordTextField.attributedPlaceholder = NSAttributedString(string: "password",
                                                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
                    
                    
                    
                }
                if let user = user {
                    // Log in to screen when the user is authenticated
                    // This logs them back into the home feed
                    
                    
                    
                    self.dismiss(animated: true) {
                        //stopActivityIndicator()
                        print ("completion")
                    }
                }
                
                
            }
        }
    }
    
    
}



extension LogInViewController: ProfileCreationControllerDelegate {
    func didDismissToHomeView() {
        self.logInViewControllerDelegate?.didDismissToHomeView()
    }
    
    
    
    
    
}
