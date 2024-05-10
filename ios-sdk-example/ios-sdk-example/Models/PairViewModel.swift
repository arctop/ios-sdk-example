//
//  PairViewModel.swift
//  ios-sdk-example
//
//  Created by Shai Kalev on 09/08/2023.
//

import Foundation
import SwiftUI
import ArctopSDK
class PairViewModel : NSObject, ObservableObject , ArctopSDKListener{
    @Published var museList:[String] = []
    func onConnectionChanged(previousConnection: ArctopSDK.ConnectionState, currentConnection: ArctopSDK.ConnectionState) {
        
    }
    
    func onMotionData(motionData: [Float], motionType: ArctopSDK.MotionDataType) {
        
    }
    
    func onValueChanged(key: String, value: Float) {
        
    }
    
    func onQAStatus(passed: Bool, type: ArctopSDK.QAFailureType) {
        
    }
    
    func onSessionComplete() {
        
    }
    
    func onError(errorCode: Error, message: String) {
        
    }
    
    func onDeviceListUpdated(museDeviceList: [String]) {
        DispatchQueue.main.async {
            self.museList = museDeviceList
        }
    }
    
}
