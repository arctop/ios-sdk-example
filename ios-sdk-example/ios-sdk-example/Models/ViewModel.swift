//
//  ViewModel.swift
//  ios-sdk-example
//
//  Created by Shai Kalev on 08/08/2023.
//

import Foundation
import OrderedCollections
import ArctopSDK
import SwiftUI
enum myViewState : String{
    case start = "Start" , pair = "Pair" , qa = "QA" , prediction = "Prediction", summery = "Summery"
}
class ViewModel : NSObject, ObservableObject , ArctopSDKListener , ArctopSDKQAListener{
    public let sdk = ArctopSDKClient()
    @Published public var clientInit = false
    @Published public var realtimeQaValue: (Bool , QAFailureType) = (true, .passed)
    @Published public var realtimePredictionValues: OrderedDictionary<String, Float> = [:]
    @Published public var realtimeMotionData: OrderedDictionary<String , [Float]> = [:]
    @Published var userLoggedInStatus:Bool = false
    @Published var userCalibrationStatus: UserCalibrationStatus = .unknown
    @Published var museList:[String] = []
    @Published public var lastError:LocalizedAlertError? = nil
    @Published var loadingShowing = false
    @Published var loadingMessage: String = "Loading..."
    @Published var currentTime:String = ""
    private let dateFormatter = DateFormatter()
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
        sdk.registerListener(listener: self as ArctopSDKQAListener)
        sdk.registerListener(listener: self as ArctopSDKListener)
        dateFormatter.dateFormat = "H : mm : ss:SSS"
        currentTime = dateFormatter.string(from: Date())
    }
    func onMotionData(motionData: [Float], motionType: ArctopSDK.MotionDataType) {
        DispatchQueue.main.async {
            self.realtimeMotionData[ motionType.rawValue ] = motionData
        }
    }
    
    func onValueChanged(key: String, value: Float) {
        DispatchQueue.main.async {
            self.realtimePredictionValues[key] = value
        }
    }
    
    func onQAStatus(passed: Bool, type: ArctopSDK.QAFailureType) {
        DispatchQueue.main.async {
            self.realtimeQaValue = (passed , type)
        }
    }
    
    func onError(errorCode: Error, message: String) {
        self.lastError = LocalizedAlertError(errorCode , title: "message")
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
    
    func onConnectionChanged(previousConnection: ArctopSDK.ConnectionState, currentConnection: ArctopSDK.ConnectionState) {
        
    }
    
    func onSessionComplete() {
        
    }
    
    public func initClient() async{
        let res = await self.sdk.initializeArctop(apiKey: "jCWv8ScSiEoX3K0m8" , bundle: Bundle(for:ViewModel.self))
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
        let result = await sdk.checkUserCalibrationStatus()
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
    public func logoutUser() async{
        try? await sdk.logoutUser()
        DispatchQueue.main.async {
            self.userLoggedInStatus = false
        }
    }
    public func login() async -> Result<Bool , Error>{
        //showLoadingWithMessage("Logging In...")
       // var result:Result<Bool,Error>
        //do{
            let result = await sdk.loginUser()
            //result = .success(true)
            DispatchQueue.main.async {
                self.userLoggedInStatus = true
            }
//        }
//        catch{
//            result = .failure(error)
//        }
        //loadingShowing = false
        return result
    }
    public func scanForDevices(){
        try? sdk.scanForAvailableDevices()
    }
    public func onQAPassed(){
        qaModel!.stop()
        runClock()
        Task{
            let result = await sdk.startPredictionSession(ArctopSDKPredictions.FLOW)
            switch result{
                case .success(_):
                DispatchQueue.main.async {
                    self.myViewState = .prediction
                }
                case .failure(let error):
                print(error)
            }
            
        }
    }
    private func runClock(){
        Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true,
                             block: {_ in
                self.currentTime = self.dateFormatter.string(from: Date())
        })
        
    }
    public func setUserMarker(_ text:String, timeStamp:Int64){
        print("Setting marker: \(text) at \(timeStamp)")
        try? sdk.writeUserMarker(text, timeStamp: timeStamp)
    }
}
