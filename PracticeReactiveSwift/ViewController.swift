//
//  ViewController.swift
//  RxSwift
//
//  Created by Rizal Fahrudin on 19/11/23.
//

import UIKit

import Combine


class ViewController: UIViewController {
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var confirmPasswordTextField: UITextField!
    @IBOutlet var signUpButton: UIButton!
    
    var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupCombine()
    }
    
    func setupCombine() {
        let namePublisher = NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: nameTextField)
            .map { ($0.object as? UITextField)?.text }
            .replaceNil(with: "")
            .map { !$0.isEmpty }
        
        namePublisher.sink { value in
            self.nameTextField.rightViewMode = value ? .never : .always
        }.store(in: &cancellables)
        
        let emailPublisher = NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: emailTextField)
            .map { ($0.object as? UITextField)?.text }
            .replaceNil(with: "")
            .map { self.isValidEmail(from: $0) }
        
        emailPublisher.sink { value in
            self.emailTextField.rightViewMode = value ? .never : .always
        }.store(in: &cancellables)
        
        let passwordPublisher = NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: passwordTextField)
            .map { ($0.object as? UITextField)?.text }
            .replaceNil(with: "")
            .map { !$0.isEmpty }
        
        passwordPublisher.sink { value in
            self.passwordTextField.rightViewMode = value ? .never : .always
        }.store(in: &cancellables)
        
        let confirmPasswordPublisher = Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UITextField.textDidChangeNotification, object: passwordTextField)
                .map { ($0.object as? UITextField)?.text }
                .replaceNil(with: "")
                .map { $0.elementsEqual(self.confirmPasswordTextField.text ?? "") },
            NotificationCenter.default
                .publisher(for: UITextField.textDidChangeNotification, object: confirmPasswordTextField)
                .map { ($0.object as? UITextField)?.text }
                .replaceNil(with: "")
                .map { $0.elementsEqual(self.passwordTextField.text ?? "") }
        )
        
        confirmPasswordPublisher.sink { value in
            self.confirmPasswordTextField.rightViewMode = value ? .never : .always
        }.store(in: &cancellables)
        
        let invalidFieldsPublisher = Publishers.CombineLatest4(
            namePublisher, emailPublisher, passwordPublisher, confirmPasswordPublisher).map {
                name, email, password, confirmPassword in
                name && email && password && confirmPassword
            }
        invalidFieldsPublisher.sink { isValid in
            if isValid {
                self.signUpButton.isEnabled = true
                self.signUpButton.backgroundColor = .systemBlue
            } else {
                self.signUpButton.isEnabled = false
                self.signUpButton.backgroundColor = .systemGray
            }
        }.store(in: &cancellables)
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
