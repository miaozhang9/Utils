//
//  SwiftProgressHUD.swift
//  SwiftProgressHUDDemo
//
//  Created by YJHou on 2016/3/12.
//  Copyright © 2016年 侯跃军. All rights reserved.
//

import UIKit
import Gifu

private let yj_topBarTag: Int = 1001
private let yj_showHUDBackColor = UIColor(red:0, green:0, blue:0, alpha: 0.8)

/// 显示类型
public enum SwiftProgressHUDType{
    case success    // 成功
    case fail       // 失败
    case info       // 圈感叹号
}

//------------------------------------ API START -------------------------------------
public class SwiftProgressHUD {
    
    /// 设置 keyWindow 蒙版背景颜色
    static public var hudBackgroundColor: UIColor = UIColor.clear {
        didSet{
            SwiftProgress.hudBackgroundColor = hudBackgroundColor
        }
    }
    
    /// 设置手动隐藏次数
    static public var hideHUDTaps: Int = 1000 {
        didSet{
            SwiftProgress.hideHUDTaps = hideHUDTaps
        }
    }
    
    /// 等待加载...
    @discardableResult
    public class func showWait() -> UIWindow? {
        if let _ = UIApplication.shared.keyWindow {
            return SwiftProgress.wait()
        }
        return nil
    }
    
    /// 成功
    @discardableResult
    public class func showSuccess(_ text: String, autoClear: Bool = true, autoClearTime: Int = 3) -> UIWindow? {
        if let _ = UIApplication.shared.keyWindow {
            return SwiftProgress.showNoticeWithText(SwiftProgressHUDType.success, text: text, autoClear: autoClear, autoClearTime: autoClearTime)
        }
        return nil
    }
    
    /// 错误
    @discardableResult
    public class func showFail(_ text: String, autoClear: Bool = true, autoClearTime: Int = 3) -> UIWindow? {
        if let _ = UIApplication.shared.keyWindow {
            return SwiftProgress.showNoticeWithText(SwiftProgressHUDType.fail, text: text, autoClear: autoClear, autoClearTime: autoClearTime)
        }
        return nil
    }
    
    /// 提示信息
    @discardableResult
    public class func showInfo(_ text: String, autoClear: Bool = true, autoClearTime: Int = 3) -> UIWindow? {
        if let _ = UIApplication.shared.keyWindow {
            return SwiftProgress.showNoticeWithText(SwiftProgressHUDType.info, text: text, autoClear: autoClear, autoClearTime: autoClearTime)
        }
        return nil
    }
    
    /// 提示自由类型(一般不用)
    @discardableResult
    public class func show(_ text: String, type: SwiftProgressHUDType, autoClear: Bool, autoClearTime: Int = 3) -> UIWindow? {
        if let _ = UIApplication.shared.keyWindow {
            return SwiftProgress.showNoticeWithText(type, text: text, autoClear: autoClear, autoClearTime: autoClearTime)
        }
        return nil
    }
    
    /// 只显示文字
    @discardableResult
    public class func showOnlyText(_ text: String) -> UIWindow? {
        if let _ = UIApplication.shared.keyWindow {
            return SwiftProgress.showText(text)
        }
        return nil
    }
    
    /// 状态栏提示
    @discardableResult
    public class func showOnStatusBar(_ text: String, autoClear: Bool = true, autoClearTime: Int = 1, textColor: UIColor = UIColor.black, backgroundColor: UIColor = UIColor.white) -> UIWindow? {
        if let _ = UIApplication.shared.keyWindow {
            return SwiftProgress.noticeOnStatusBar(text, autoClear: autoClear, autoClearTime: autoClearTime, textColor: textColor, backgroundColor: backgroundColor)
        }
        return nil
    }
    
    /// 动画图片数组
    @discardableResult
    public class func showAnimationImages(_ imageNames: Array<UIImage>, timeMilliseconds: Int, backgroundColor: UIColor = UIColor.clear, scale: Double = 1.0) -> UIWindow? {
        if let _ = UIApplication.shared.keyWindow {
            return SwiftProgress.wait(imageNames, timeMilliseconds: timeMilliseconds, backgroundColor: backgroundColor, scale: scale)
        }
        return nil
    }
    public class func loading(inView: UIView) {
        self.hiding(inView: inView)
        let ai = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        ai.bounds = CGRect(x: 0, y: 0, width: 36, height: 36)
        ai.center = CGPoint(x: inView.frame.width/2, y: inView.frame.height/2)
        inView.addSubview(ai)
        ai.startAnimating()
    }
    public class func hiding(inView: UIView) {
        inView.subviews.forEach { (view) in
            if view.isKind(of: UIActivityIndicatorView.self) {
                view.removeFromSuperview()
            }
        }
    }
    
    /// GIF
    @discardableResult
    public class func showGIFAnimation(_ imageName:String, hudBackgroundColor:UIColor = UIColor.clear, backgroundColor: UIColor = UIColor.clear, scale: Double = 1.0) -> UIWindow? {
        if let _ = UIApplication.shared.keyWindow {
            return SwiftProgress.waitGIF(imageName, hudBackgroundColor:hudBackgroundColor ,backgroundColor: backgroundColor, scale: scale)
        }
        return nil
    }
    
    
    
    
    /// 清除所有
    public class func hideAllHUD() {
        SwiftProgress.clear()
    }
}
//------------------------------------ API END -----------------------------------------


class SwiftProgress: NSObject {
    
    static var hudBackgroundColor: UIColor = UIColor.clear
    static var hideHUDTaps: Int = 1
    static var windows = Array<UIWindow!>()
    static let rv = UIView(frame: UIScreen.main.bounds)
    static var timer: DispatchSource!
    static var timerTimes = 0
    static var imageView : GIFImageView!
    /* just for iOS 8 */
    static var degree: Double {
        get {
            return [0, 0, 180, 270, 90][UIApplication.shared.statusBarOrientation.hashValue] as Double
        }
    }
    
    static func clear() {
        self.cancelPreviousPerformRequests(withTarget: self)
        if let _ = imageView {
            imageView.stopAnimatingGIF()
        }
        if let _ = timer {
            timer.cancel()
            timer = nil
            timerTimes = 0
        }
        windows.removeAll(keepingCapacity: false)
    }
    
    @discardableResult
    static func noticeOnStatusBar(_ text: String, autoClear: Bool, autoClearTime: Int, textColor: UIColor, backgroundColor: UIColor) -> UIWindow{
        let frame = UIApplication.shared.statusBarFrame
        let window = UIWindow()
        window.rootViewController = UIViewController()
        window.backgroundColor = UIColor.clear
        let view = UIView()
        view.backgroundColor = backgroundColor
        let label = UILabel(frame: frame)
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = textColor
        label.text = text
        view.addSubview(label)
        
        window.frame = frame
        view.frame = frame
        
        if let version = Double(UIDevice.current.systemVersion),
            version < 9.0 {
            // change center
            var array = [UIScreen.main.bounds.width, UIScreen.main.bounds.height]
            array = array.sorted(by: <)
            let screenWidth = array[0]
            let screenHeight = array[1]
            let x = [0, screenWidth/2, screenWidth/2, 10, screenWidth-10][UIApplication.shared.statusBarOrientation.hashValue] as CGFloat
            let y = [0, 10, screenHeight-10, screenHeight/2, screenHeight/2][UIApplication.shared.statusBarOrientation.hashValue] as CGFloat
            window.center = CGPoint(x: x, y: y)
            
            // change direction
            window.transform = CGAffineTransform(rotationAngle: CGFloat(degree * Double.pi / 180))
        }
        
        window.windowLevel = UIWindowLevelStatusBar
        window.isHidden = false
        window.addSubview(view)
        windows.append(window)
        
        var origPoint = view.frame.origin
        origPoint.y = -(view.frame.size.height)
        let destPoint = view.frame.origin
        view.tag = yj_topBarTag
        
        view.frame = CGRect(origin: origPoint, size: view.frame.size)
        UIView.animate(withDuration: 0.3, animations: {
            view.frame = CGRect(origin: destPoint, size: view.frame.size)
        }, completion: { b in
            if autoClear {
                
                DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + .seconds(autoClearTime), execute: {
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.3, animations: {
                            /// 消失动画
                            view.frame = CGRect(origin: origPoint, size: view.frame.size)
                        }, completion: { (b) in
                            let selector = #selector(SwiftProgress.hideNotice(_:))
                            self.perform(selector, with: window, afterDelay: TimeInterval(autoClearTime))
                        })
                    }
                })
            }
        })
        return window
    }
    
    @discardableResult
    static func wait(_ imageNames: Array<UIImage> = Array<UIImage>(), timeMilliseconds: Int = 0, backgroundColor: UIColor = yj_showHUDBackColor, scale: Double = 1.0, text: String = "加载中，请稍候") -> UIWindow {
        let frame = CGRect(x: 0, y: 0, width: 750/2, height: 327/2)
        let window = UIWindow()
        window.backgroundColor = hudBackgroundColor
        window.rootViewController = UIViewController()
        let mainView = UIView()
        mainView.layer.cornerRadius = 12
        mainView.backgroundColor = backgroundColor
        
        /// add tapGesture
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tapHideGesture(gesture:)))
        tapGesture.numberOfTapsRequired = hideHUDTaps
        window.addGestureRecognizer(tapGesture)
        
        /// 计算动画的Frame
        let imgViewFrame = CGRect(x: Double(frame.size.width) * (1 - scale) * 0.5, y: Double(frame.size.height) * (1 - scale) * 0.5, width: Double(frame.size.width) * scale, height: Double(frame.size.height) * scale)
        
        if imageNames.count > 0 {
            if imageNames.count > timerTimes {
                let iv = UIImageView(frame: imgViewFrame)
                iv.image = imageNames.first!
                iv.contentMode = UIViewContentMode.scaleAspectFit
                mainView.addSubview(iv)
                timer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: UInt(0)), queue: DispatchQueue.main) as! DispatchSource
                timer.schedule(deadline: DispatchTime.now(), repeating: DispatchTimeInterval.milliseconds(timeMilliseconds))
                timer.setEventHandler(handler: { () -> Void in
                    let name = imageNames[timerTimes % imageNames.count]
                    iv.image = name
                    timerTimes += 1
                })
                timer.resume()
            }
            let label = UILabel(frame: CGRect(x: Double(frame.size.width) * (1 - scale) * 0.5 - 10, y: Double(frame.size.height) * (1 - scale) * 0.5 + Double(frame.size.height) * scale + 5, width: Double(frame.size.width) * scale + 20, height: 16))
            label.font = UIFont.systemFont(ofSize: 15)
            label.textColor = 0x4A4A4A.color
            label.text = text
            label.textAlignment = NSTextAlignment.center
            mainView.addSubview(label)
        } else {
            let ai = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            ai.frame = CGRect(x: 21, y: 21, width: 36, height: 36)
            ai.startAnimating()
            mainView.addSubview(ai)
        }
        
        window.frame = rv.bounds
        mainView.frame = frame
        mainView.center = rv.center
        
        if let version = Double(UIDevice.current.systemVersion),
            version < 9.0 {
            // change center
            window.center = getRealCenter()
            // change direction
            window.transform = CGAffineTransform(rotationAngle: CGFloat(degree * Double.pi / 180))
        }
        
        window.windowLevel = UIWindowLevelAlert
        window.isHidden = false
        window.addSubview(mainView)
        windows.append(window)
        
        mainView.alpha = 0.0
        UIView.animate(withDuration: 0.2, animations: {
            mainView.alpha = 1
        })
        return window
    }
    
    @discardableResult
    static func waitGIF(_ imageName: String,hudBackgroundColor:UIColor = hudBackgroundColor, backgroundColor: UIColor = yj_showHUDBackColor, scale: Double = 1.0, text: String = "加载中，请稍候") -> UIWindow {
        let frame = CGRect(x: 0, y: 0, width: 132.scaleWidth, height: 132.scaleWidth)
        let window = UIWindow()
        window.backgroundColor = hudBackgroundColor
        window.rootViewController = UIViewController()
        let mainView = UIView()
        mainView.layer.cornerRadius = 12
        mainView.backgroundColor = backgroundColor
        
        /// add tapGesture
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tapHideGesture(gesture:)))
        tapGesture.numberOfTapsRequired = hideHUDTaps
        window.addGestureRecognizer(tapGesture)
        
        /// 计算动画的Frame
        let imgViewFrame = CGRect(x: Double(frame.size.width) * (1 - scale) * 0.5, y: Double(frame.size.height) * (1 - scale) * 0.5, width: Double(frame.size.width) * scale, height: Double(frame.size.height) * scale)
        
        if imageName.count > 0 {
             imageView = GIFImageView(frame: imgViewFrame)
            imageView.layer.cornerRadius = 5.0
            imageView.layer.masksToBounds = true
            imageView.animate(withGIFNamed: imageName)
            mainView.addSubview(imageView)
//            let label = UILabel(frame: CGRect(x: Double(frame.size.width) * (1 - scale) * 0.5 - 10, y: Double(frame.size.height) * (1 - scale) * 0.5 + Double(frame.size.height) * scale + 5, width: Double(frame.size.width) * scale + 20, height: 16))
//            label.font = UIFont.systemFont(ofSize: 15)
//            label.textColor = 0x4A4A4A.color
//            label.text = text
//            label.textAlignment = NSTextAlignment.center
//            mainView.addSubview(label)
        } else {
            let ai = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            ai.frame = CGRect(x: 21, y: 21, width: 36, height: 36)
            ai.startAnimating()
            mainView.addSubview(ai)
        }
        
        window.frame = rv.bounds
        mainView.frame = frame
        mainView.center = rv.center
        
        if let version = Double(UIDevice.current.systemVersion),
            version < 9.0 {
            // change center
            window.center = getRealCenter()
            // change direction
            window.transform = CGAffineTransform(rotationAngle: CGFloat(degree * Double.pi / 180))
        }
        
        window.windowLevel = UIWindowLevelAlert
        window.isHidden = false
        window.addSubview(mainView)
        windows.append(window)
        
        mainView.alpha = 0.0
        UIView.animate(withDuration: 0.2, animations: {
            mainView.alpha = 1
        })
        return window
    }
    
    @discardableResult
    static func showText(_ text: String, autoClear: Bool = true, autoClearTime: Int = 2) -> UIWindow {
        let window = UIWindow()
        window.backgroundColor = hudBackgroundColor
        window.rootViewController = UIViewController()
        let mainView = UIView()
        mainView.layer.cornerRadius = 10
        mainView.backgroundColor = yj_showHUDBackColor
        
        /// add tapGesture
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tapHideGesture(gesture:)))
        tapGesture.numberOfTapsRequired = hideHUDTaps
        window.addGestureRecognizer(tapGesture)
        
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.white
        let size = label.sizeThatFits(CGSize(width: UIScreen.main.bounds.width-82, height: CGFloat.greatestFiniteMagnitude))
        label.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        mainView.addSubview(label)
        
        let superFrame = CGRect(x: 0, y: 0, width: label.frame.width + 20 , height: label.frame.height + 20)
        
        window.frame = rv.bounds
        mainView.frame = superFrame
        
        label.center = mainView.center
        mainView.center = rv.center
        
        if let version = Double(UIDevice.current.systemVersion),
            version < 9.0 {
            // change center
            window.center = getRealCenter()
            // change direction
            window.transform = CGAffineTransform(rotationAngle: CGFloat(degree * Double.pi / 180))
        }
        
        window.windowLevel = UIWindowLevelAlert
        window.isHidden = false
        window.addSubview(mainView)
        windows.append(window)
        
        if autoClear {
            let selector = #selector(SwiftProgress.hideNotice(_:))
            self.perform(selector, with: window, afterDelay: TimeInterval(autoClearTime))
        }
        return window
    }
    
    @discardableResult
    static func showNoticeWithText(_ type: SwiftProgressHUDType,text: String, autoClear: Bool, autoClearTime: Int) -> UIWindow {
        let frame = CGRect(x: 0, y: 0, width: 90, height: 90)
        let window = UIWindow()
        window.backgroundColor = hudBackgroundColor
        window.rootViewController = UIViewController()
        let mainView = UIView()
        mainView.layer.cornerRadius = 10
        mainView.backgroundColor = yj_showHUDBackColor
        
        /// add tapGesture
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tapHideGesture(gesture:)))
        tapGesture.numberOfTapsRequired = hideHUDTaps
        window.addGestureRecognizer(tapGesture)
        
        var image = UIImage()
        switch type {
        case .success:
            image = SwiftProgressSDK.imageOfCheckmark
        case .fail:
            image = SwiftProgressSDK.imageOfCross
        case .info:
            image = SwiftProgressSDK.imageOfInfo
        }
        let checkmarkView = UIImageView(image: image)
        checkmarkView.frame = CGRect(x: 27, y: 15, width: 36, height: 36)
        mainView.addSubview(checkmarkView)
        
        let label = UILabel(frame: CGRect(x: 0, y: 60, width: 90, height: 16))
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.white
        label.text = text
        label.textAlignment = NSTextAlignment.center
        mainView.addSubview(label)
        
        window.frame = rv.bounds
        mainView.frame = frame
        mainView.center = rv.center
        
        if let version = Double(UIDevice.current.systemVersion),
            version < 9.0 {
            // change center
            window.center = getRealCenter()
            // change direction
            window.transform = CGAffineTransform(rotationAngle: CGFloat(degree * Double.pi / 180))
        }
        
        window.windowLevel = UIWindowLevelAlert
        window.center = rv.center
        window.isHidden = false
        window.addSubview(mainView)
        windows.append(window)
        
        mainView.alpha = 0.0
        UIView.animate(withDuration: 0.2, animations: {
            mainView.alpha = 1
        })
        
        if autoClear {
            let selector = #selector(SwiftProgress.hideNotice(_:))
            self.perform(selector, with: window, afterDelay: TimeInterval(autoClearTime))
        }
        return window
    }
    
    /// 修复 window 没有移除
    @objc static func hideNotice(_ sender: AnyObject) {
        if let window = sender as? UIWindow {
            
            if let v = window.subviews.first {
                UIView.animate(withDuration: 0.2, animations: {
                    
                    if v.tag == yj_topBarTag {
                        v.frame = CGRect(x: 0, y: -v.frame.height, width: v.frame.width, height: v.frame.height)
                    }
                    v.alpha = 0
                }, completion: { b in
                    if let index = windows.index(where: { (item) -> Bool in
                        return item == window
                    }) {
                        windows.remove(at: index)
                    }
                })
            }
        }
    }
    
    // just for iOS 8
    static func getRealCenter() -> CGPoint {
        if UIApplication.shared.statusBarOrientation.hashValue >= 3 {
            return CGPoint(x: rv.center.y, y: rv.center.x)
        } else {
            return rv.center
        }
    }
    
    /// tap Hide HUD
    @objc
    static func tapHideGesture(gesture: UITapGestureRecognizer) {
        clear()
    }
}

class SwiftProgressSDK {
    struct Cache {
        static var imageOfCheckmark: UIImage?
        static var imageOfCross: UIImage?
        static var imageOfInfo: UIImage?
    }
    class func draw(_ type: SwiftProgressHUDType) {
        let checkmarkShapePath = UIBezierPath()
        
        // draw circle
        checkmarkShapePath.move(to: CGPoint(x: 36, y: 18))
        checkmarkShapePath.addArc(withCenter: CGPoint(x: 18, y: 18), radius: 17.5, startAngle: 0, endAngle: CGFloat(Double.pi*2), clockwise: true)
        checkmarkShapePath.close()
        
        switch type {
        case .success: // draw checkmark
            checkmarkShapePath.move(to: CGPoint(x: 10, y: 18))
            checkmarkShapePath.addLine(to: CGPoint(x: 16, y: 24))
            checkmarkShapePath.addLine(to: CGPoint(x: 27, y: 13))
            checkmarkShapePath.move(to: CGPoint(x: 10, y: 18))
            checkmarkShapePath.close()
        case .fail: // draw X
            checkmarkShapePath.move(to: CGPoint(x: 10, y: 10))
            checkmarkShapePath.addLine(to: CGPoint(x: 26, y: 26))
            checkmarkShapePath.move(to: CGPoint(x: 10, y: 26))
            checkmarkShapePath.addLine(to: CGPoint(x: 26, y: 10))
            checkmarkShapePath.move(to: CGPoint(x: 10, y: 10))
            checkmarkShapePath.close()
        case .info:
            checkmarkShapePath.move(to: CGPoint(x: 18, y: 6))
            checkmarkShapePath.addLine(to: CGPoint(x: 18, y: 22))
            checkmarkShapePath.move(to: CGPoint(x: 18, y: 6))
            checkmarkShapePath.close()
            
            UIColor.white.setStroke()
            checkmarkShapePath.stroke()
            
            let checkmarkShapePath = UIBezierPath()
            checkmarkShapePath.move(to: CGPoint(x: 18, y: 27))
            checkmarkShapePath.addArc(withCenter: CGPoint(x: 18, y: 27), radius: 1, startAngle: 0, endAngle: CGFloat(Double.pi*2), clockwise: true)
            checkmarkShapePath.close()
            
            UIColor.white.setFill()
            checkmarkShapePath.fill()
        }
        
        UIColor.white.setStroke()
        checkmarkShapePath.stroke()
    }
    class var imageOfCheckmark: UIImage {
        if (Cache.imageOfCheckmark != nil) {
            return Cache.imageOfCheckmark!
        }
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 36, height: 36), false, 0)
        
        SwiftProgressSDK.draw(SwiftProgressHUDType.success)
        
        Cache.imageOfCheckmark = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return Cache.imageOfCheckmark!
    }
    class var imageOfCross: UIImage {
        if (Cache.imageOfCross != nil) {
            return Cache.imageOfCross!
        }
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 36, height: 36), false, 0)
        
        SwiftProgressSDK.draw(SwiftProgressHUDType.fail)
        
        Cache.imageOfCross = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return Cache.imageOfCross!
    }
    class var imageOfInfo: UIImage {
        if (Cache.imageOfInfo != nil) {
            return Cache.imageOfInfo!
        }
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 36, height: 36), false, 0)
        
        SwiftProgressSDK.draw(SwiftProgressHUDType.info)
        
        Cache.imageOfInfo = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return Cache.imageOfInfo!
    }
}

extension UIWindow{
    func hide(){
        SwiftProgress.hideNotice(self)
    }
}

