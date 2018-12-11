//
//  AuthorizationManage.swift
//  EQS
//
//  Created by Miaoz on 2018/12/11.
//  Copyright © 2018年 ShuXun. All rights reserved.
//

import Foundation
import CoreLocation
import AVFoundation
import LEEAlert

typealias onAuthority = (Bool) -> Void

class AuthorizationManage: NSObject {
    
    static let `default` = AuthorizationManage()
    
    let locationManager:CLLocationManager = CLLocationManager()
    var completion:onAuthority?
    let alert = LEEAlert.alert()
    
    func checkGPSAuthority(showAlert:Bool,completion:@escaping onAuthority ) {
        self.completion = completion
        let authorizationStatus = CLLocationManager.authorizationStatus()
        
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            self.completion?(false)
        case .denied:
            if  showAlert {
                
              let _ =  alert.config
                    .leeTitle("温馨提示")
                    .leeContent("需要您打开位置权限，请设置为允许")
                    .leeCancelAction("去设置",{
                        UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                    })
                    .leeShow()
            }
            self.completion?(false)
        case .authorizedWhenInUse,.authorizedAlways:
            self.completion?(true)
        case .restricted:
          let _ = alert.config
                .leeTitle("温馨提示")
                .leeContent("GPS功能受限于某些限制，无法使用定位服务")
                .leeCancelAction("知道了",nil)
                .leeShow()
            self.completion?(false)
        }
    }
    
 
    
    func checkCameraAuthority(showAlert:Bool,completion:@escaping onAuthority){
         self.completion = completion
        //判断前置
//        if !self.isFrontCameraAvailable() {
//            self.alertIsCamera()
//            self.completion?(false)
//        }
        //获得App相机目前权限
        let authStatus:AVAuthorizationStatus =  AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if authStatus == AVAuthorizationStatus.authorized {
             self.completion?(true)
        } else if authStatus == AVAuthorizationStatus.notDetermined {
            //系统的相机授权弹框
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { (allowVideo) in
            }
             self.completion?(false)
        } else {
            if showAlert {
                self.alertAuthority()
            }
            
              self.completion?(false)
        }
    }
    
    func checkMicrophoneAuthority(showAlert:Bool,completion:@escaping onAuthority) {
         self.completion = completion
        let permission:AVAudioSessionRecordPermission = AVAudioSession.sharedInstance().recordPermission()
        if (permission == AVAudioSessionRecordPermission.undetermined) {
            //系统的麦克风授权弹框
            AVAudioSession.sharedInstance().requestRecordPermission { (allowAudio) in
                
            }
            
            self.completion?(false)
        } else if (permission == AVAudioSessionRecordPermission.denied) {
            if showAlert {
                self.alertMicrophoneAuthority()
               
            }
             self.completion?(false)
        } else if (permission == AVAudioSessionRecordPermission.granted) {
            self.completion?(true)
        } else {
             self.completion?(false)
        }
    }
    
    func alertIsCamera() {
        
        let _ = alert.config
            .leeTitle("温馨提示")
            .leeContent("手机前置摄像头故障，无法正常调用该功能，请确认后使用！")
            .leeCancelAction("确定",{})
            .leeShow()
    }
    
    func alertAuthority() {
        let _ = alert.config
            .leeTitle("温馨提示")
            .leeContent("需要您打开相机权限，请设置为允许")
            .leeCancelAction("去设置",{
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
            })
            .leeShow()
    }
    
    func alertMicrophoneAuthority() {
        let _ = alert.config
            .leeTitle("温馨提示")
            .leeContent("需要您打开麦克风权限，请设置为允许")
            .leeCancelAction("去设置",{
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
            })
            .leeShow()
    }
    
    ///是否有摄像头
    func isCameraAvailable() -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
    }
    ///前置摄像头是否可用
    func isFrontCameraAvailable() -> Bool {
        return UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.front)
    }
    ///后置摄像头是否可用
    func isRearCameraAvailable() -> Bool {
        return UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.rear)
    }
    
}
