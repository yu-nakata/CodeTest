//
//  RotateView.swift
//  CodeTestApp
//
//  Created by 中田祐稀 on 2021/01/26.
//

import UIKit

public protocol RotaryProtocol: class {
    func touchesBegan(rotateView: RotateView, angle: CGFloat)
    func updatedRagianAngle(rotateView: RotateView, angle: CGFloat)
    func touchesEnded(rotateView: RotateView, angle: CGFloat)
}

@IBDesignable
 public class RotateView: UIView {
    // タップ開始時のTransform
    var startTransform: CGAffineTransform?
    // タップ座標と中心点の角度
    var deltaAngle: CGFloat = 0.0

    weak public var delegate: RotaryProtocol?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // タッチ開始
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let targetAngle = makeDeltaAngle(touches: touches) else { return }
        deltaAngle = targetAngle
        startTransform = self.transform
        delegate?.touchesBegan(rotateView: self, angle: targetAngle)
    }

    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let targetAngle = makeDeltaAngle(touches: touches) else { return }
        let angleDifference = deltaAngle - targetAngle
        self.transform = startTransform?.rotated(by: -angleDifference) ?? CGAffineTransform.identity
        delegate?.updatedRagianAngle(rotateView: self, angle: angleDifference)
    }

    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 回転をtransformから算出
        var angle = atan2(self.transform.b, self.transform.a)
        // ラジアン範囲を -.pi < Θ < pi から 0 < Θ < 2 piに変更
        if angle < 0 {
            angle += 2 * .pi
        }
        delegate?.touchesEnded(rotateView: self, angle: angle)
    }

    private func makeDeltaAngle(touches: Set<UITouch>) -> CGFloat? {
        guard let touch = touches.first else { return nil }
        let manager = CoordinateManager()
        let touchPoint = touch.location(in: self)
        let center = CGPoint(x: self.bounds.width/2, y: self.bounds.height/2)
        let dist = manager.calculateDistance(center: center, point: touchPoint)

        // タッチ範囲外
        if manager.isIgnoreRange(distance: dist, size: self.bounds.size) {
            print("ignoring tap \(touchPoint.x), \(touchPoint.y)")
            return nil
        }

        return manager.makeDeltaAngle(targetPoint: touchPoint, center: self.center)
    }
}
