//
//  LoginViewController.swift
//  CodeTestApp
//
//  Created by 中田祐稀 on 2021/01/20.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    
    private let viewModel = LoginViewModel()
    
    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.isLoading
            .skip(1) // 初期化されたときの実行をスキップ
            .drive(onNext: { [weak self] result in
                if result {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.isSuccess
            .skip(1) // 初期化されたときの実行をスキップ
            .drive(onNext: { [weak self] result in
                if result {
                    // 成功
                } else {
                    // 失敗時アラートを表示
                    let alert = UIAlertController(title: nil, message: self?.viewModel.errMsgRelay.value, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
            })
            .disposed(by: disposeBag)
        
        mailTextField.rx.text.orEmpty
            .bind(to: viewModel.mail)
            .disposed(by: disposeBag)
        
        mailTextField.rx.text
            .subscribe { [unowned self] _ in
                // テキスト入力時の処理
                self.changeLoginButtonState()
            }
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text.orEmpty
            .bind(to: viewModel.password)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text
            .subscribe { [unowned self] _ in
                // テキスト入力時の処理
                self.changeLoginButtonState()
            }
            .disposed(by: disposeBag)
        
        loginButton.rx.tap
            .subscribe { [unowned self] _ in
                // ボタンタップ時の処理
                viewModel.login(disposeBag: disposeBag)
            }
            .disposed(by: disposeBag)
    }
    
    private func changeLoginButtonState() {
        guard let isMailEmpty = mailTextField.text?.isEmpty else {
            return
        }
        guard let isPasswordEmpty = passwordTextField.text?.isEmpty else {
            return
        }
        let enabled = !(isMailEmpty || isPasswordEmpty)
        // 入力されているか
        loginButton.isEnabled = enabled
        loginButton.backgroundColor = enabled ? .systemOrange : .systemYellow
    }
}
