//
//  LoginViewController.swift
//  MUD
//
//  Created by Jordan Christensen on 3/3/20.
//  Copyright © 2020 Mazjap Co. All rights reserved.
//

import UIKit
import SpriteKit

class LoginViewController: UIViewController {
    var apiController: APIController?
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatTextField: UITextField!
    @IBOutlet weak var loginSegmentedControl: UISegmentedControl!
    @IBOutlet weak var signinButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUp()
    }
    
    private func setUp() {
        loginSegmentedControl.selectedSegmentIndex = 0
        signinButton.layer.cornerRadius = 6
        updateViews()
        
        loginSegmentedControl.addTarget(self, action: #selector(updateViews), for: .valueChanged)
        loginSegmentedControl.addTarget(self, action: #selector(updateViews), for: .touchUpInside)
    }
    
    @objc
    private func updateViews() {
        if loginSegmentedControl.selectedSegmentIndex == 0 { // Signin
            emailTextField.isHidden = true
            repeatTextField.isHidden = true
            signinButton.setTitle("Sign in", for: .normal)
        } else if loginSegmentedControl.selectedSegmentIndex == 1 { // Signup
            emailTextField.isHidden = false
            repeatTextField.isHidden = false
            signinButton.setTitle("Sign up", for: .normal)
        }
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        guard let apiController = apiController else { return }
        
        if loginSegmentedControl.selectedSegmentIndex == 0 { // Signin
            guard let username = usernameTextField.text, let password = passwordTextField.text else { return }
            let user = UserLogin(username: username, password: password)
            apiController.login(user: user) { error in
                if let error = error {
                    NSLog("\(#file):L\(#line): Configuration failed inside \(#function) with error: \(error)")
                } else if apiController.key != nil {
                    DispatchQueue.main.async {
                        if let scene = SKScene(fileNamed: "GameScene") as? GameScene {
                            scene.setUp()
                        }
                        self.dismiss(animated: true)
                    }
                }
            }
        } else if loginSegmentedControl.selectedSegmentIndex == 1 { // Signup
            guard let email = emailTextField.text, let username = usernameTextField.text, let password1 = passwordTextField.text, let password2 = repeatTextField.text else { return }
            let user = UserRegister(username: username, email: email, password1: password1, password2: password2)
            apiController.register(user: user) { error in
                if let error = error {
                    NSLog("\(#file):L\(#line): Configuration failed inside \(#function) with error: \(error)")
                } else if apiController.key != nil {
                    DispatchQueue.main.async {
                        self.dismiss(animated: true)
                    }
                }
            }
        }
    }
}
