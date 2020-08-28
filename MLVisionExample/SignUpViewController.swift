import UIKit
import Firebase
import FirebaseAuth

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    
    // outlet variables
    

    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var ConfirmPasswordTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    
    // array of schools initialized to empty
    var schools: [String] = []
    //picked school (which will display in view controller) set to empty originally
    var pickedSchool = ""
    var BandzDatabase: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //showActivityIndicatory(uiView: self.view)
        EmailTextField.delegate = self
        ConfirmPasswordTextField.delegate = self
        PasswordTextField.delegate = self
        
        BandzDatabase = Firestore.firestore()
        
        
        // Do any additional setup after loading the view.
    }
    
    
    // IB Actiion button code
    
    @IBAction func SignUpButton(_ sender: Any) {
        let email = EmailTextField.text!
        let password = PasswordTextField.text!
        //check if passwords are the same
        
        if PasswordTextField.text != ConfirmPasswordTextField.text {
            
            showAlert(alertTitle: "Passwords do not match")
            
            self.ConfirmPasswordTextField.text = ""
            
            
            return
        }
        
        // check if School is selected

        
        
        // Now we pass the email/password into firebase and let it do the rest
        //showActivityIndicatory(uiView: self.view)
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if(error != nil) {
                self.showAlert(alertTitle: error!.localizedDescription)
                //stopActivityIndicator()
                return
            }
            
            self.handleSend()
            
            // created!
            
        }}
    
    
    @IBAction func logInBackButtonPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        //executes everytime the view appears
        super.viewDidAppear(true)
        // displays current school chosen
    }
    

    
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Sends the school strings to the Search VC

        
        if let profileCreationVC = segue.destination as? ProfileCreationViewController, let logInVC = self.presentingViewController as? LogInViewController{
            profileCreationVC.delegate = logInVC
            
            
            
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    // Here are all our external functions which abstract the processes above
    
    
    // shows alert with given message
    
    func showAlert(alertTitle: String) {
        
        let alert = UIAlertController(title: alertTitle, message: "Please try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        self.present(alert, animated: true)
        
    }
    
    func handleSend() {
        
        guard let email = EmailTextField.text else {return}
        
        //let userFirstPart = UserData(email: email, firstName: "hi", lastName: "hi", phoneNumber: "hi", profilePicture: "hi", userID: "hi", username: "hi")    put in --> .setData() userFirstPart.dictionary
        
        let userReference = self.BandzDatabase.collection("Users")
        
        let userID = Auth.auth().currentUser!.uid
        
        userReference.document(userID).setData(["email": email, "firstName": ""]) { error in
            if error != nil {
                print("issue")
                //stopActivityIndicator()
                self.showAlert(alertTitle: "Something went wrong")
            } else {
                print("saved!")
                //stopActivityIndicator()
                self.performSegue(withIdentifier: "CreateProfileSegue", sender: nil)
            }
            
        }}
    
    
    
    
    
    
}
