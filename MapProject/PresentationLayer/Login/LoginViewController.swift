//
//  LoginViewController.swift
//  MapProject
//
//  Created by Арсений Дорогин on 14/08/2019.
//  Copyright © 2019 Арсений Дорогин. All rights reserved.
//

import UIKit
import RealmSwift
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //DataForTestStart
        loginTextField.text = "arseniydor"
        passwordTextField.text = "qwerty"
        //DataForTestEnd
        
        
        loginTextField.autocorrectionType = .no
        passwordTextField.isSecureTextEntry = true
        configureLoginBindings()
        
    }
  
    func configureLoginBindings() {
        Observable
            // Объединяем два обсервера в один
            .combineLatest(
                // Обсервер изменения текста
                loginTextField.rx.text,
                // Обсервер изменения текста
                passwordTextField.rx.text
            )
            // Модифицируем значения из двух обсерверов в один
            .map { login, password in
                // Если введены логин и пароль больше 6 символов, будет возвращено “истина”
                return !(login ?? "").isEmpty && (password ?? "").count >= 6
            }
            // Подписываемся на получение событий
            .bind { [weak loginButton] inputFilled in
                // Если событие означает успех, активируем кнопку, иначе деактивируем
                loginButton?.isEnabled = inputFilled
        }
    }

    
    @IBAction func loginPress(_ sender: UIButton){
        
        let realm = try! Realm()
        guard let login = loginTextField.text else{
            return
        }
        let password = passwordTextField.text
        let user = realm.objects(User.self).filter("login == %@",login).first
        
        if user?.passsword == password {
            //alerts().showSuccesAlert(vc: self, title: "Отлично", message: "Вы успешно вошли")
            performSegue(withIdentifier: "LogIn", sender: self)
        }else{
            alerts().showErrorAlert(vc: self, message: "Не верный логин или пароль")
        }
        
    }
    
    @IBAction func registrationPress(_ sender: UIButton){
        
        let realm = try! Realm()
        guard let login = loginTextField.text else{
            return
        }
        guard let password = passwordTextField.text else{
            return
        }
        let user = User()
        user.login = login
        let userForCheck = realm.objects(User.self).filter("login == %@",login).first
        if userForCheck != nil {
            let newPassword = password + "1"
            user.passsword = newPassword
            alerts().showErrorAlert(vc: self, message: "Этот пользователь уже зарегестрирован")
        }else{
            user.passsword = password
            try! realm.write {
                realm.add(user)
                performSegue(withIdentifier: "LogIn", sender: self)
            }
        }
        
        
    }

}
