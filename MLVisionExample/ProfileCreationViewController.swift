//  ProfileCreationViewController.swift
//  BandzReal
//
//  Created by Matteo Agius on 6/4/19.
//  Copyright © 2019 Austin Rath. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage


protocol ProfileCreationControllerDelegate {
    func didDismissToHomeView()
}

class ProfileCreationViewController: UIViewController, UITextFieldDelegate {
    var BandzDatabase: Firestore!
    var imageIsSet: Bool = false
    var profileImageData: Data!
    var goToHome: Bool!
    var dispatchGroup = DispatchGroup()
    var delegate: ProfileCreationControllerDelegate?
    var profilePic: UIImage?
    
    // UI outlets as variables
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var profilePicture: UIButton!
    
    @IBOutlet weak var profilePictureImageView: UIImageView!
    
    
    // image picker declared
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //text field delegates
        firstNameTextField.delegate = self
        phoneNumberTextField.delegate = self
        lastNameTextField.delegate = self
        
        BandzDatabase = Firestore.firestore()
        // initialize the UI image picker
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        
        
    }
    
    @IBAction func profilePictureButtonTapped(_ sender: Any) {
        // calls the image picker
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func createAccount(_ sender: Any) {

        
        goToHome = true
        
        if checkTextFields() == false {
            showAlert(alertTitle: "Please Fill Every Field")
            return
        } else if imageIsSet == false {
            showAlert(alertTitle: "No Profile Picture Selected")
            return
        } else {
            // here we check if the username exists, then we log in. it is complicated bc we want to guarantee that everything goes smoothly otherwise we don't do anything at all
            
            handleImageSend(imageData: profileImageData) { (success) in
                if (success) {
                    self.performSegue(withIdentifier: "privacySegue", sender: nil)
                }
            }
            BandzDatabase = Firestore.firestore()
            BandzDatabase.collection("Users").document(Auth.auth().currentUser!.uid).setData(["firstName" : firstNameTextField.text!, "lastName":lastNameTextField.text!])
            
        
            
        }
        

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    
    // created functions
    
    
    
    func showAlert(alertTitle: String) {
        
        let alert = UIAlertController(title: alertTitle, message: "Please try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        self.present(alert, animated: true)
        
    }
    
    
    func checkTextFields() -> Bool {
        var returnBool = true
        
        
        if firstNameTextField.text?.isEmpty == true {
            firstNameTextField.attributedPlaceholder = NSAttributedString(string: "First Name",
                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            returnBool = false
        }
        
        if lastNameTextField.text?.isEmpty == true {
            lastNameTextField.attributedPlaceholder = NSAttributedString(string: "Last Name",
                                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            returnBool = false
        }
        
        if phoneNumberTextField.text?.isEmpty == true {
            phoneNumberTextField.attributedPlaceholder = NSAttributedString(string: "Phone Number",
                                                                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            returnBool = false
        }
        
        
        return returnBool
        
    }
    
    
    func handleSend(completion: ((Bool) -> Void)?) {
        var dispatchGroup: DispatchGroup = DispatchGroup()
        let batch = self.BandzDatabase.batch()
        guard let firstname = firstNameTextField.text else {return}
        guard let lastname = lastNameTextField.text else {return}

        guard let phoneNumber = phoneNumberTextField.text else {return}
        
        
        let userID = Auth.auth().currentUser!.uid
        
        let userReference = self.BandzDatabase.collection("Users").document(userID)
        batch.setData(["firstName": firstname, "lastName": lastname, "phoneNumber": phoneNumber, "userID": userID, "profilePictureRef": "UserProfilePictures/\(userID).jpg", "memberOfOrgs": 0, "followerOfOrgs": 0, "numberOfFriends": 0], forDocument: userReference, merge: true)
        
        let homeFeedRef = self.BandzDatabase.collection("Users").document(userID).collection("HomeFeed").document("homeFeed")
        batch.setData(["exists": true], forDocument: homeFeedRef)
        
        
        let buddyRef = self.BandzDatabase.collection("Users").document(userID).collection("Buddies").document("buddies")
        batch.setData(["exists": true], forDocument: buddyRef)
        
        let requestRef = self.BandzDatabase.collection("Users").document(userID).collection("Buddies").document("requests")
        batch.setData(["exists": true], forDocument: requestRef)
        
        
        let notificationRef = self.BandzDatabase.collection("Users").document(userID).collection("Notifications").document("notifications")
        batch.setData(["exists": true], forDocument: notificationRef)
        
        
        let orgFollowingRef = self.BandzDatabase.collection("Users").document(userID).collection("Organizations").document("following")
        batch.setData(["exists": true], forDocument: orgFollowingRef)
        
        
        let orgMemberRef = self.BandzDatabase.collection("Users").document(userID).collection("Organizations").document("memberOf")
        batch.setData(["exists": true], forDocument: orgMemberRef)
        
        let eventGoingRef = self.BandzDatabase.collection("Users").document(userID).collection("EventsGoing").document("eventsGoing")
        batch.setData(["exists": true], forDocument: eventGoingRef)
        
        
        
        batch.commit() { error in
            if let error = error {
                print (error.localizedDescription)
                if let completion = completion { completion (false)}
                
            } else {
                print ("batch success")
                if let completion = completion { completion (true)}
            }
            
            
            
        }
        
        
        
        
        /*
         
         
         
         userReference.document(userID).setData(["firstName": firstname, "lastName": lastname, "username": username,"usernameLowercased": username.lowercased(), "phoneNumber": phoneNumber, "userID": userID, "profilePictureRef": "UserProfilePictures/\(userID).jpg", "memberOfOrgs": 0, "followerOfOrgs": 0, "numberOfFriends": 0], merge: true) { error in
         if error != nil {
         print("issue")
         if let completion = completion { completion(false)}
         
         } else {
         print("saved!")
         if let completion = completion { completion(true)}
         userReference.document(userID).collection("HomeFeed").document("homeFeed").setData(["exists": true]) {error in
         if let error = error {
         print (error.localizedDescription)
         }
         
         }
         userReference.document(userID).collection("Friends").document("friends").setData(["exists": true])
         userReference.document(userID).collection("Notifications").document("notifications").setData(["exists": true])
         userReference.document(userID).collection("Organizations").document("following").setData(["exists": true])
         userReference.document(userID).collection("Organizations").document("memberOf").setData(["exists": true])
         userReference.document(userID).collection("EventsGoing").document("eventsGoing").setData(["exists": true])
         
         }
         
         }
         */
    }
    
    
    // uploads the image to firebase and returns if the operation went successfully
    func handleImageSend(imageData: Data, completion: ((Bool) -> Void)?)  {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let userID = Auth.auth().currentUser!.uid
        let userProfilePictureReference = storageRef.child("UserProfilePictures/\(userID).jpg")
        let uploadMetaData = StorageMetadata()
        
        uploadMetaData.contentType = "image/jpeg"
        let uploadTask = userProfilePictureReference.putData(imageData, metadata: uploadMetaData) { (metadata, error) in
            if error != nil {
                self.goToHome = false
                print (error?.localizedDescription)
                if let completion = completion { completion(false)}
                
            } else {
                print ("image uploaded successfully to firebase")
                if let completion = completion { completion(true)}
            }
        }
        
        
    }
    
    
}




extension ProfileCreationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        
        
        if let pickedimage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage, let imageData = pickedimage.jpegData(compressionQuality: 0.8) {
            profilePictureImageView.contentMode = .scaleAspectFit
            self.profilePictureImageView.image = pickedimage
            profilePictureImageView.clipsToBounds = true
            profilePictureImageView.backgroundColor = .black
            imageIsSet = true
            profileImageData = imageData
            self.profilePic = pickedimage
            
            
        }
        
        
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
}
