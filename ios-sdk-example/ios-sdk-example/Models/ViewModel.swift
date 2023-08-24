//
//  ViewModel.swift
//  ios-sdk-example
//
//  Created by Shai Kalev on 08/08/2023.
//

import Foundation
import OrderedCollections
import NeuosSDK
import SwiftUI
enum myViewState : String{
    case start = "Start" , pair = "Pair" , qa = "QA" , prediction = "Prediction"
}
class ViewModel : NSObject, ObservableObject , NeuosSDKListener , NeuosSDKQAListener{
    public let sdk = NeuosSDKClient()
    @Published public var clientInit = false
    @Published public var realtimeQaValue: (Bool , QAFailureType) = (true, .passed)
    @Published public var realtimePredictionValues: OrderedDictionary<String, Float> = [:]
    @Published public var realtimeMotionData: OrderedDictionary<String , [Float]> = [:]
    @Published var userLoggedInStatus:Bool = false
    @Published var userCalibrationStatus: NeuosUserCalibrationStatus = .unknown
    @Published var museList:[String] = []
    @Published public var lastError:LocalizedAlertError? = nil
    @Published var loadingShowing = false
    @Published var loadingMessage: String = "Loading..."
    public private(set) var noSignalColor:Color = Color(hex:0xff0411)
    public private(set) var goodSignalColor:Color = Color(hex:0x6fe100)
    public var qaModel:QAViewModel? = nil{
        didSet{
            onSigQuality = { value in
                self.qaModel!.qaString = value
            }
            onHeadbandStatus = {value in
                self.qaModel!.isHeadbandOn = value
            }
            qaModel!.onQaPassed = onQAPassed
        }
    }
    public override init() {
        super.init()
        sdk.registerListener(listener: self as NeuosSDKQAListener)
        sdk.registerListener(listener: self as NeuosSDKListener)
    }
    func onMotionData(motionData: [Float], motionType: NeuosSDK.MotionDataType) {
        DispatchQueue.main.async {
            self.realtimeMotionData[ motionType.rawValue ] = motionData
        }
    }
    
    func onValueChanged(key: String, value: Float) {
        DispatchQueue.main.async {
            self.realtimePredictionValues[key] = value
        }
    }
    
    func onQAStatus(passed: Bool, type: NeuosSDK.QAFailureType) {
        DispatchQueue.main.async {
            self.realtimeQaValue = (passed , type)
        }
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
    
    public var onSigQuality: (String) -> Void = {_ in }
    public var onHeadbandStatus: (Bool) -> Void = {_ in}
    @Published var myViewState : myViewState = .start
    @Published var batteryPower:Float = -1
    func onSignalQuality(quality: String) {
        DispatchQueue.main.async {
            self.onSigQuality(quality)
        }
    }
    func onHeadbandStatusChange(headbandOn: Bool) {
        DispatchQueue.main.async {
            self.onHeadbandStatus(headbandOn)
        }
    }
    
    func onBatteryStatus(chargeLeft: Float) {
        DispatchQueue.main.async {
            self.batteryPower = chargeLeft
        }
    }
    
    func onDevicePluggedInStatusChange(pluggedIn: Bool) {
        
    }
    
    func onConnectionChanged(previousConnection: NeuosSDK.ConnectionState, currentConnection: NeuosSDK.ConnectionState) {
        
    }
    
    public func initClient() async{
        let res = await self.sdk.initializeNeuos(apiKey: "jCWv8ScSiEoX3K0m8" , bundle: Bundle(for:ViewModel.self))
        switch res{
        case .success(_):
            DispatchQueue.main.async {
                self.clientInit = true
            }
        case .failure(let error):
            print(error)
        }
        
    }
    
    public func checkUserLoggedInStatus() async{
        do{
            let result = try await sdk.isUserLoggedIn()
            DispatchQueue.main.async {
                self.userLoggedInStatus = result
            }
        }
        catch{
            print("Error getting user login status.")
        }
        
    }
    
    public func checkUserCalibrationStatus() async{
        let result = await sdk.checkNeuosUserCalibrationStatus()
        switch (result){
            case .success(let value):
            DispatchQueue.main.async {
                self.userCalibrationStatus = value
            }
            case .failure(_):
                print("Error getting calibration status")
        }
    }
    public func onSelectDevice(deviceID:String){
        try? sdk.connectSensorDevice(deviceId: deviceID)
        myViewState = .qa
        qaModel!.start(quality: .perfect)
    }
    
    public func onStartPrediction(){
        myViewState = .pair
    }
    public func onLogoutClick(){
        Task{
            try? await sdk.logoutUser()
            DispatchQueue.main.async {
                self.userLoggedInStatus = false
            }
        }
    }
    public func login(email:String, password:String) async -> Result<Bool , Error>{
        //showLoadingWithMessage("Logging In...")
        var result:Result<Bool,Error>
        do{
            try await sdk.loginUser(email: email, password: password)
            result = .success(true)
            DispatchQueue.main.async {
                self.userLoggedInStatus = true
            }
        }
        catch{
            result = .failure(error)
        }
        //loadingShowing = false
        return result
    }
    public func scanForDevices(){
        try? sdk.scanForAvailableDevices()
    }
    public func onQAPassed(){
        qaModel!.stop()
        Task{
            let result = await sdk.startPredictionSession("zone")
            switch result{
                case .success(_):
                    print("OK")
                DispatchQueue.main.async {
                    self.myViewState = .prediction
                }
                case .failure(let error):
                print(error)
            }
            
        }
    }
    
}
