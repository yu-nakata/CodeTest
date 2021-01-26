//
//  MainViewController.swift
//  CodeTestApp
//
//  Created by 中田祐稀 on 2021/01/20.
//

import UIKit
import RxSwift
import RxCocoa

class MainViewController: UIViewController {
    private let viewModel = MainViewModel()
    private let disposeBag = DisposeBag()
    @IBOutlet weak var rotateView: RotateView!
    private var iconViews: [UIView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        viewModel.fetchImage(disposeBag: disposeBag)
    }
    
    private func bindViewModel() {
        viewModel.onCompletedFetchImage
            .skip(1) // 初期化されたときの実行をスキップ
            .drive(onNext: { [weak self] result in
                if result {
                    self?.drawCircle()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func drawCircle() {
        rotateView.delegate = self
        
        // 描画用の円
        let circlePathDraw = UIBezierPath(arcCenter: rotateView.center, radius: (rotateView.frame.width / 2) - 18, startAngle: 0, endAngle: .pi*2, clockwise: true)
        let circleLayer = CAShapeLayer()
        circleLayer.path = circlePathDraw.cgPath
        circleLayer.strokeColor = UIColor.lightGray.cgColor
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.position = CGPoint(x: 0, y: -((rotateView.frame.width / 2)) / 2)
        rotateView.layer.addSublayer(circleLayer)
        
        // アイコン並べる
        let angles: [CGFloat] =
            [
                .pi / 6,
                .pi / 2,
                .pi / 1.2,
                .pi / 0.85,
                .pi / 0.66,
                .pi / 0.54
            ]
        viewModel.images.enumerated().forEach { (index, image) in
            let squareView = generateIconView(image: image, startAngle: angles[index])
            iconViews.append(squareView)
            rotateView.addSubview(squareView)
        }
    }
    
    private func generateIconView(image: UIImage?, startAngle: CGFloat) -> UIView {
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: rotateView.center.x, y: (rotateView.frame.width / 2)), radius: (rotateView.frame.width / 2) - 18, startAngle: startAngle, endAngle: startAngle + 2 * .pi, clockwise: true)
        let animation = createPathAnimation(path: circlePath.cgPath)
        let squareView = UIImageView(image: image)
        squareView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        squareView.layer.add(animation, forKey: nil)
        return squareView
    }
    
    /// アニメーションを作成
    /// - Parameter path: アニメーションパス
    /// - Returns: CAPropertyAnimation
    private func createPathAnimation(path: CGPath?) -> CAPropertyAnimation {
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.repeatCount = MAXFLOAT
        animation.isRemovedOnCompletion = false
        animation.duration = 15.0
        animation.path = path
        return animation
    }
}

extension MainViewController: RotaryProtocol {
    func touchesBegan(rotateView: RotateView, angle: CGFloat) {
        iconViews.forEach { (view) in
            let pausedTime: CFTimeInterval = view.layer.convertTime(CACurrentMediaTime(), from: nil)
            view.layer.speed = 0.0
            view.layer.timeOffset = pausedTime
        }
    }
    
    func touchesEnded(rotateView: RotateView, angle: CGFloat) {
        iconViews.forEach { (view) in
            view.transform = CGAffineTransform(rotationAngle: -angle)
            let pausedTime: CFTimeInterval = view.layer.timeOffset
            view.layer.speed = 1.0
            view.layer.timeOffset = 0.0
            view.layer.beginTime = 0.0
            let timeSincePause: CFTimeInterval = view.layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
            view.layer.beginTime = timeSincePause
        }
    }
    
    func updatedRagianAngle(rotateView: RotateView, angle: CGFloat) {
        iconViews.forEach { (view) in
            view.transform = CGAffineTransform(rotationAngle: angle)
        }
    }
}
