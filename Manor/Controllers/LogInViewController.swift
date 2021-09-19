//
//  LogInViewController.swift
//  Manor
//
//  Created by Colin Birkenstock on 5/11/21.
//

import UIKit
import Firebase
import Amplify
import AmplifyPlugins
import SwiftKeychainWrapper


class LogInViewController: UIViewController {
    
    @IBOutlet weak var rememberMeStackView: UIStackView!
    @IBOutlet weak var rememberMeButton: UIButton!
    
    
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var emailView: UIView!
    
    
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var passwordView: UIView!
    
    
    @IBOutlet weak var ManorLogo: UIImageView!
    @IBOutlet weak var infoStackView: UIStackView!
    @IBOutlet weak var logoStack: UIStackView!
    @IBOutlet weak var holderView: UIView!
    
    //--//
    
    let defaults = UserDefaults.standard
    
    //--//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = ""
        
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.shadowImage = UIImage()
        //navigationItem.backBarButtonItem?.tintColor = UIColor(named: K.BrandColors.purple)
        self.navigationController?.navigationBar.tintColor = UIColor(named: K.BrandColors.purple)
        
        
        //checks whether remember me is checked and colors in button and fills in information if it is
        if defaults.bool(forKey: "rememberUser") == true {
            
            rememberMeButton.layer.backgroundColor = UIColor(named: K.BrandColors.purple)?.cgColor
            rememberMeButton.layer.borderWidth = 1
            rememberMeButton.layer.borderColor = UIColor(named: K.BrandColors.purple)?.cgColor
            
            if let savedEmail = defaults.string(forKey: "savedEmail") {
                emailInput.text = savedEmail
            }
            
            if let savedPassword = KeychainWrapper.standard.string(forKey: "savedPassword") {
                passwordInput.text = savedPassword
            }
            
        } else {
            rememberMeButton.layer.borderColor = UIColor(named: K.BrandColors.purple)?.cgColor
            rememberMeButton.layer.borderWidth = 1
            rememberMeButton.layer.backgroundColor = UIColor.clear.cgColor
        }
        
        //setting up notifications to move view when keyboard appears and dissapears
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        // view layout for buttons
        emailView.layer.cornerRadius = emailView.bounds.height/2
        emailView.layer.borderWidth = 3
        emailView.layer.borderColor = UIColor(named: K.BrandColors.purple)?.cgColor
        
        passwordView.layer.cornerRadius = passwordView.bounds.height/2
        passwordView.layer.borderWidth = 3
        passwordView.layer.borderColor = UIColor(named: K.BrandColors.purple)?.cgColor
        
    }
    
    //moves view up when keyboard is called
    @objc func keyboardWillShow(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo else {return}
        guard let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = keyboardSize.cgRectValue.height
        let spaceLeft = (self.view.bounds.height - keyboardFrame) - infoStackView.bounds.height
        
        self.infoStackView.frame.origin.y =
            self.view.bounds.origin.y + (spaceLeft/2)
        self.logoStack.frame.origin.y = -205
        
        UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
    }
    
    //moves view back down if keyboard goes away
    @objc func keyboardWillHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else {return}
        
        self.view.frame.origin.y = 0
        
        
        UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
    }
    
    //checks to see if email portion contains a "@" and a ".", if it does it turns green, else turns red
    @IBAction func emailEditingEnded(_ sender: UITextField) {
        if (emailInput.text?.contains("@") ?? false && emailInput.text?.contains(".") ?? false) {
            emailView.layer.borderColor = UIColor.green.cgColor
        } else {
            emailView.layer.borderColor = UIColor.red.cgColor
        }
    }
    
    //checks to see if password count is at least 6 characters and chooses its color based on that
    @IBAction func passwordEditingEnded(_ sender: Any) {
        if (passwordInput.text?.count ?? 0 < 6) {
            passwordView.layer.borderColor = UIColor.red.cgColor
        } else {
            passwordView.layer.borderColor = UIColor.green.cgColor
        }
    }
    
    //when remember me is pressed it saves info if it is enabled, and deletes information if disabled
    @IBAction func rememberMePressed(_ sender: UIButton) {
        if (rememberMeButton.layer.backgroundColor == UIColor.clear.cgColor) {
            rememberMeButton.layer.backgroundColor = UIColor(named: K.BrandColors.purple)?.cgColor
            rememberMeButton.layer.borderColor = UIColor(named: K.BrandColors.purple)?.cgColor
            
            self.defaults.setValue(true, forKey: "rememberUser")
            self.defaults.setValue(self.emailInput.text, forKey: "savedEmail")
            KeychainWrapper.standard.set(self.passwordInput.text ?? "", forKey: "savedPassword")
            
        } else {
            rememberMeButton.layer.borderColor = UIColor(named: K.BrandColors.purple)?.cgColor
            rememberMeButton.layer.backgroundColor = UIColor.clear.cgColor
            
            self.defaults.setValue(false, forKey: "rememberUser")
            self.defaults.setValue(nil, forKey: "savedEmail")
            KeychainWrapper.standard.set("", forKey: "savedPassword")
            //self.defaults.setValue(nil, forKey: "savedPassword")
        }
    }
    
    //goes through firebase authentication and lets user pass if info is correct
    @IBAction func LogInPressed(_ sender: Any){
        if let email = emailInput.text, let password = passwordInput.text {
            
            /*let usernameArray = email.split(separator: " ")
             let username = "\(usernameArray[0])\(usernameArray[1])"*/
            
            let username = email.replacingOccurrences(of: ".", with: ",")
            
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e)
                    /*let alert = UIAlertController(title: "Oops...", message: "\(e.localizedDescription)", preferredStyle: .alert)
                     alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                     self.present(alert, animated: true)*/
                } else {
                    //self.performSegue(withIdentifier: K.Segues.ContactPageViewSegue, sender: self)
                    print("success")
                }
            }
            
            signIn(username: username, password: password, isFirstTry: true)
        }
    }
    
    func signIn(username: String, password: String, isFirstTry: Bool) {
        Amplify.Auth.signIn(username: username, password: password) { result in
            switch result {
            case .success:
                print("Sign in succeeded")
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: K.Segues.ContactPageViewSegue, sender: self)
                }
            case .failure(let error):
                print("Sign in failed \(error)")
                if isFirstTry {
                    Amplify.Auth.signOut { result in
                        switch result {
                        case .success:
                            print("success signing out")
                            DispatchQueue.main.async {
                                self.signIn(username: username, password: password, isFirstTry: false)
                            }
                        case .failure(let error):
                            print("Sign out failed \(error)")
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Login Failed", message: "\(error)", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { UIAlertAction in
                            alert.dismiss(animated: true)
                        }))
                        self.present(alert, animated: true)
                    }
                }
            }
            return
        }
    }
    
    
    //shows navigation bar on next view controller
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
    }
    
    //shows navigation bar
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
