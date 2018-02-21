//
//  LoginViewController.swift
//  BoardApp
//
//  Created by Paweł Szudrowicz on 21.02.2018.
//  Copyright © 2018 Paweł Szudrowicz. All rights reserved.
//

import UIKit
import RealmSwift
import RxSwift
import RxCocoa
import MBProgressHUD
import IHKeyboardAvoiding


class LoginViewController: UIViewController {
    @IBOutlet weak var dontHaveAccountButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var stackView: UIStackView!
    let disposeBag = DisposeBag()
    private var loginPage = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailAddressTextField.text = "pablo.szudrowicz@gmail.com"
        self.passwordTextField.text = "qwerty"
        
        setupRx()
        
        KeyboardAvoiding.avoidingView = self.stackView
        let gesture = UITapGestureRecognizer(target: self, action: #selector(touchedView))
        self.view.addGestureRecognizer(gesture)
    }

    func setupRx() {
        let emailRx = emailAddressTextField.rx.text.orEmpty.throttle(0.5,scheduler:MainScheduler.instance).map { (inputText) -> Bool in
            return ( (inputText.count > 0) && (inputText.contains("@")) )
        }
        let passwordRx = passwordTextField.rx.text.orEmpty.throttle(0.5, scheduler: MainScheduler.instance).map { (inputText) ->Bool in
            return (inputText.count) > 0
        }
        
        Observable.combineLatest(emailRx, passwordRx).subscribe(onNext: { (email, password) in
            if(email == true && password == true) {
                self.loginButton.isEnabled = true
                self.loginButton.alpha = 1.0
            } else {
                self.loginButton.isEnabled = false
                self.loginButton.alpha = 0.5
            }
        }).disposed(by: disposeBag)
    }
    
    @IBAction func loginButtonTapped(sender: UIButton!) {
        print("Touched")
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        RealmManager.sharedInstance.connectToRealmDatabase(username: emailAddressTextField.text!, password: passwordTextField.text!, register: !loginPage, viewControllerHandler: self) { (syncUser) in
            print("Success")
            //self.performSegue(withIdentifier: "loggedInSuccess", sender: nil)
        }
        
        hideKeyboard()
    }
    
    @IBAction func dontHaveAccountButtonTapped(sender: UIButton!) {
        if loginPage {
            dontHaveAccountButton.setTitle("I've already have an account! Go to Login Page", for: .normal)
            loginButton.setTitle("Register Now!", for: .normal)
        } else {
            dontHaveAccountButton.setTitle("Don't have account? Register here!", for: .normal)
            loginButton.setTitle("Log In", for: .normal)
        }
        
        loginPage = !loginPage
    }
    
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func touchedView() {
        hideKeyboard()
    }

}

