//
//  PairViewModel.swift
//  ios-sdk-example
//
//  Created by Shai Kalev on 09/08/2023.
//

import Foundation
import SwiftUI
import NeuosSDK
class PairViewModel : NSObject, ObservableObject , NeuosSDKListener{
    @Published var museList:[String] = []
    func onConnectionChanged(previousConnection: NeuosSDK.ConnectionState, currentConnection: NeuosSDK.ConnectionState) {
        
    }
    
    func onMotionData(motionData: [Float], motionType: NeuosSDK.MotionDataType) {
        
    }
    
    func onValueChanged(key: String, value: Float) {
        
    }
    
    func onQAStatus(passed: Bool, type: NeuosSDK.QAFailureType) {
        
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
