//
//  ViewController.swift
//  RxSwift
//
//  Created by Rizal Fahrudin on 19/11/23.
//

import UIKit

import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var confirmPasswordTextField: UITextField!
    @IBOutlet var signUpButton: UIButton!
    
    var autoBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupRxSwift()
    }
    
    func setupRxSwift() {
       let nameStream = nameTextField.rx.text
            .orEmpty
            .skip(1)
            .map{ !$0.isEmpty }
        
        nameStream.subscribe { isValid in
            self.nameTextField.rightViewMode = isValid ? .never : .always
        }.disposed(by: autoBag)
        
        let emailStream = emailTextField.rx.text
             .orEmpty
             .skip(1)
             .map{ self.isValidEmail(from: $0) }
         
        emailStream.subscribe { isValid in
             self.emailTextField.rightViewMode = isValid ? .never : .always
         }.disposed(by: autoBag)
        
        let passwordStream = passwordTextField.rx.text
             .orEmpty
             .skip(1)
             .map{ !$0.isEmpty }
         
        passwordStream.subscribe { isValid in
             self.passwordTextField.rightViewMode = isValid ? .never : .always
         }.disposed(by: autoBag)
        
        let confirmPasswordStream = Observable.merge(
            passwordTextField.rx.text
                 .orEmpty
                 .skip(1)
                 .map{ $0.elementsEqual(self.confirmPasswordTextField.text ?? "")},
            confirmPasswordTextField.rx.text
                 .orEmpty
                 .skip(1)
                 .map{ $0.elementsEqual(self.passwordTextField.text ?? "") }
        )
         
        confirmPasswordStream.subscribe { isValid in
             self.confirmPasswordTextField.rightViewMode = isValid ? .never : .always
         }.disposed(by: autoBag)
        
        
        let button = Observable.combineLatest(nameStream, emailStream, passwordStream, confirmPasswordStream) { name, email, pass, conPass in
            name && email && pass && conPass
        }
        
        button.subscribe { isValid in
            self.signUpButton.isEnabled = isValid
            self.signUpButton.backgroundColor = isValid ? .systemGreen : .systemGray
        }.disposed(by: autoBag)
    }
    
    func setupView() {
        signUpButton.isEnabled = false
        signUpButton.backgroundColor = .systemGray
        nameTextField.setRightImage(action: #selector(showNameExistAlert), target: self)
        emailTextField.setRightImage(action: #selector(showEmailExistAlert), target: self)
        passwordTextField.setRightImage(action: #selector(showPasswordExistAlert), target: self)
        confirmPasswordTextField.setRightImage(action: #selector(showConfirmationPasswordExistAlert), target: self)
    }
    
    @objc func showNameExistAlert(_ sender: Any) {
        let alertController = UIAlertController(
            title: "Your name is invalid.",
            message: "Please double check your name, for example Rizal Rizal.",
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func showEmailExistAlert(_ sender: Any) {
        let alertController = UIAlertController(
            title: "Your email is invalid.",
            message: "Please double check your email format, for example like rizal@email.com.",
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func showPasswordExistAlert(_ sender: Any) {
        let alertController = UIAlertController(
            title: "Your password is invalid.",
            message: "Please double check the character length of your password.",
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func showConfirmationPasswordExistAlert(_ sender: Any) {
        let alertController = UIAlertController(
            title: "Confirmation passwords do not match.",
            message: "Please check your password confirmation again.",
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func isValidEmail(from email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    
}


extension UITextField {
    func setRightImage(action: Selector, target: Any?) {
        
        
        let imageView = UIButton(type: .custom)
        imageView.setImage(UIImage(systemName:"info.circle"), for: .normal)
        imageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        imageView.addTarget(target, action: action, for: .touchUpInside)
        
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: imageView.frame.width + 5, height: imageView.frame.height))
        view.addSubview(imageView)
        
        rightViewMode = .always
        rightView = view
    }
}
