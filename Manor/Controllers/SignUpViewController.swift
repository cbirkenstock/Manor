//
//  SignUpViewController.swift
//  Manor
//
//  Created by Colin Birkenstock on 5/12/21.
//

import UIKit
import Firebase
import Amplify
import AmplifyPlugins
import Combine
import SwiftKeychainWrapper


class SignUpViewController: UIViewController {
    
    @IBOutlet weak var infoStackView: UIStackView!
    @IBOutlet weak var manorLogo: UIImageView!
    
    @IBOutlet weak var firstNameInput: UITextField!
    @IBOutlet weak var firstNameView: UIView!
    
    
    @IBOutlet weak var lastNameInput: UITextField!
    @IBOutlet weak var lastNameView: UIView!
    
    
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var emailView: UIView!
    
    
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var passwordView: UIView!
    
    
    //--//
    
    let db = Firestore.firestore()
    var ref: DocumentReference?
    let usersRef = Database.database().reference().child("users")
    let defaults = UserDefaults.standard
    
    //--//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.shadowImage = UIImage()
        //navigationItem.backBarButtonItem?.tintColor = UIColor(named: K.BrandColors.purple)
        self.navigationController?.navigationBar.tintColor = UIColor(named: K.BrandColors.purple)
        
        
        //sets up notificiations for whether keyboard is up or not
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //button layout
        firstNameView.layer.cornerRadius = firstNameView.bounds.height/2
        firstNameView.layer.borderWidth = 3
        firstNameView.layer.borderColor = UIColor(named: K.BrandColors.purple)?.cgColor
        
        lastNameView.layer.cornerRadius = lastNameView.bounds.height/2
        lastNameView.layer.borderWidth = 3
        lastNameView.layer.borderColor = UIColor(named: K.BrandColors.purple)?.cgColor
        
        emailView.layer.cornerRadius = emailView.bounds.height/2
        emailView.layer.borderWidth = 3
        emailView.layer.borderColor = UIColor(named: K.BrandColors.purple)?.cgColor
        
        passwordView.layer.cornerRadius = passwordView.bounds.height/2
        passwordView.layer.borderWidth = 3
        passwordView.layer.borderColor = UIColor(named: K.BrandColors.purple)?.cgColor
        
        
        firstNameInput.attributedPlaceholder = NSAttributedString(string: firstNameInput.placeholder!, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        lastNameInput.attributedPlaceholder = NSAttributedString(string: lastNameInput.placeholder!, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        emailInput.attributedPlaceholder = NSAttributedString(string: emailInput.placeholder!, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        passwordInput.attributedPlaceholder = NSAttributedString(string: passwordInput.placeholder!, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        
    }
    
    
    //checks to see if name has any symbols or numbers that is shouldn't, turns red if it does and turns green otherwise
    @IBAction func firstNameEditingEnded(_ sender: UITextField) {
        
        let decimalRange = firstNameInput.text?.rangeOfCharacter(from: CharacterSet.decimalDigits)
        let hasNumbers = (decimalRange != nil)
    
        let symbolsRange = firstNameInput.text?.rangeOfCharacter(from: CharacterSet.symbols)
        let hasSymbols = (symbolsRange != nil)
        
        if (hasNumbers || hasSymbols || firstNameInput.text == "") {
            firstNameView.layer.borderColor = UIColor.red.cgColor
        } else {
            firstNameView.layer.borderColor = UIColor.green.cgColor
        }
    }
    
    @IBAction func firstNameEditingBegan(_ sender: Any) {
        
    }
    //checks to see if name has any symbols or numbers that is shouldn't, turns red if it does and turns green otherwise
    @IBAction func lastNameEditingEnded(_ sender: UITextField) {
        let decimalRange = lastNameInput.text?.rangeOfCharacter(from: CharacterSet.decimalDigits)
        let hasNumbers = (decimalRange != nil)
    
        let symbolsRange = lastNameInput.text?.rangeOfCharacter(from: CharacterSet.symbols)
        let hasSymbols = (symbolsRange != nil)
        
        if (hasNumbers || hasSymbols || lastNameInput.text == "") {
            lastNameView.layer.borderColor = UIColor.red.cgColor
        } else {
            lastNameView.layer.borderColor = UIColor.green.cgColor
        }
    }
    
    //checks to see if email contains "@" and "." and turns green if it does
    @IBAction func emailEditingEnded(_ sender: UITextField) {
        if (emailInput.text?.contains("@") ?? false && emailInput.text?.contains(".") ?? false) {
            emailView.layer.borderColor = UIColor.green.cgColor
        } else {
        emailView.layer.borderColor = UIColor.red.cgColor
        }
    }
    
    //checks to see if password count is atleast 6 and turns green if it is
    @IBAction func passwordEditingEnded(_ sender: UITextField) {
        if (passwordInput.text?.count ?? 0 < 6) {
            passwordView.layer.borderColor = UIColor.red.cgColor
        } else {
        passwordView.layer.borderColor = UIColor.green.cgColor
        }
    }
    
    //checks same as above but while typing -- only has option to turn green so doesn't become red immediately
    @IBAction func passwordEditingChanged(_ sender: UITextField) {
            if (passwordInput.text?.count ?? 0 >= 6) {
                passwordView.layer.borderColor = UIColor.green.cgColor
            }
    }
    
    //moves view if keyboard appears
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = keyboardSize.cgRectValue.height
        let spaceLeft = (self.view.bounds.height - keyboardFrame) - infoStackView.bounds.height
        
        self.infoStackView.frame.origin.y =
            self.view.bounds.origin.y + (spaceLeft/2)
        self.manorLogo.frame.origin.y = -205
       

        //self.view.frame.origin.y = -290
        
        UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
    }
    
    //moves view back down when keyboard hides
    @objc func keyboardWillHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else {return}
        
        self.view.frame.origin.y = 0
        
        
        UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
    }
    
    
    
    //sets password bubble to green if it is over 6 characters, creates user with firebase, and adds user information to users.email, then performs segue to main menu
    @IBAction func SignUpPressed(_ sender: Any) {
        if (self.passwordInput.text?.count ?? 0 < 6) {
            self.passwordView.layer.borderColor = UIColor.red.cgColor
        }
        
        if emailInput.text != "", passwordInput.text != "", firstNameInput.text != "", lastNameInput.text != "" {
            if let email: String = emailInput.text, let password = passwordInput.text, let firstName = firstNameInput.text, let LastName = lastNameInput.text {
                
                let username = email.replacingOccurrences(of: ".", with: ",")//"\(firstName)\(LastName)"
                
                signUp(username: username, password: password, email: email)
                
                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    if let e = error {
                        print(e.localizedDescription)
                    } else {
                        let commaEmail = email.replacingOccurrences(of: ".", with: ",")
                        
                        self.usersRef.child(commaEmail).setValue([
                            "firstName": firstName,
                            "lastName": LastName,
                            "email": email,
                            "fcmToken": "",
                            "badgeCount": "0"
                        ])
                    }
                }
            }
        } else {
            let alert = UIAlertController(title: "Oops...", message: "Please make sure all bubbles are filled in.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { UIAlertAction in
                self.dismiss(animated: true)
            }))
            self.present(alert, animated: true)
        }
    }
    
    func signUp(username: String, password: String, email: String) {
        let userAttributes = [AuthUserAttribute(.email, value: email)]
        let options = AuthSignUpRequest.Options(userAttributes: userAttributes)
        
        let alert = UIAlertController(title: "Remember Password?", message: "If you choose remember, you won't be asked to sign in again", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { UIAlertAction in
            self.defaults.setValue(true, forKey: "rememberUser")
            self.defaults.setValue(self.emailInput.text, forKey: "savedEmail")
            KeychainWrapper.standard.set(self.passwordInput.text ?? "", forKey: "savedPassword")
            Amplify.Auth.signUp(username: username, password: password, options: options) { result in
                switch result {
                case .success(let key):
                    print("Success!", key)
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: K.Segues.ContactPageViewSegue, sender: self)
                    }
                case .failure(let error):
                    print("error", error)
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: K.Segues.ContactPageViewSegue, sender: self)
                    }
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { UIAlertAction in
            self.dismiss(animated: true)
            Amplify.Auth.signUp(username: username, password: password, options: options) { result in
                switch result {
                case .success(let key):
                    print("Success!", key)
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: K.Segues.ContactPageViewSegue, sender: self)
                    }
                case .failure(let error):
                    print("error", error)
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: K.Segues.ContactPageViewSegue, sender: self)
                    }
                }
            }
        }))
        
        self.present(alert, animated: true)
    }
    
    func confirmSignUp(for username: String, with confirmationCode: String) -> AnyCancellable {
        Amplify.Auth.confirmSignUp(for: username, confirmationCode: confirmationCode)
            .resultPublisher
            .sink {
                if case let .failure(authError) = $0 {
                    print("An error occurred while confirming sign up \(authError)")
                }
            }
            receiveValue: { _ in
                print("Confirm signUp succeeded")
            }
    }
    
    //shows navigation bar when view opening up
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    //shows navigation bar when view closing
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
