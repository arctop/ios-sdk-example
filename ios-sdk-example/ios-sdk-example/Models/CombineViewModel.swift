//
//  PredictionDataModel.swift
//  ios-sdk-example
//
//  Created by Shai Kalev on 6/11/25.
//


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
import Combine
class CombineViewModel : NSObject, ObservableObject,  @unchecked Sendable{
    public let sdk = ArctopSDKClient()
    @Published public var clientInit = false
    @Published public var realtimeQaValue: (Bool , QAFailureType) = (true, .passed)
    @Published public var realtimePredictionValues: OrderedDictionary<String, Float> = [:]
    @Published public var realtimeMotionData: OrderedDictionary<String , [Float]> = [:]
    @Published var userLoggedInStatus:Bool = false
    @Published var deviceList:[String] = []
    @Published public var lastError:LocalizedAlertError? = nil
    @Published var loadingShowing = false
    @Published var loadingMessage: String = "Loading..."
    @Published var currentTime:String = ""
    @Published public private(set) var clientAllowedPredictions:[String] = []
    @Published public var userPredictions: [PredictionDataModel] = []
    public var onSigQuality: (String) -> Void = {_ in }
    public var onHeadbandStatus: (Bool) -> Void = {_ in}
    @Published var myViewState : myViewState = .start
    @Published var batteryPower:Float = -1
    private let dateFormatter = DateFormatter()
    public private(set) var noSignalColor:Color = Color(hex:0xff0411)
    public private(set) var goodSignalColor:Color = Color(hex:0x6fe100)
    private var cancellables = Set<AnyCancellable>()
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
        dateFormatter.dateFormat = "H : mm : ss:SSS"
        currentTime = dateFormatter.string(from: Date())
        
        sdk.sdkObserables.motionDataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.realtimeMotionData[ data.type.rawValue ] = data.data
            }
            .store(in: &cancellables)
        sdk.sdkObserables.valueChangedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.realtimePredictionValues[data.key] = data.value
            }
            .store(in: &cancellables)
        sdk.sdkObserables.qaStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.realtimeQaValue = (data.passed , data.type)
            }
            .store(in: &cancellables)
        sdk.sdkObserables.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.lastError = LocalizedAlertError(error.error , title: error.message)
            }
            .store(in: &cancellables)
        sdk.sdkObserables.deviceListPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] list in
                self?.deviceList = list
            }
            .store(in: &cancellables)
        sdk.sdkObserables.signalQualityPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.onSigQuality(data)
            }
            .store(in: &cancellables)
        sdk.sdkObserables.headbandStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.onHeadbandStatus(data)
            }
            .store(in: &cancellables)
        sdk.sdkObserables.batteryStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.batteryPower = data
            }
            .store(in: &cancellables)
    }
    
   

    public func initClient() async{
        let res = await self.sdk.initializeArctop(apiKey: "jCWv8ScSiEoX3K0m8" , bundle: Bundle(for:ViewModel.self))
        switch res{
        case .success(_):
            DispatchQueue.main.async {
                self.clientInit = true
                self.clientAllowedPredictions = self.sdk.clientAllowedPredictions
            }
        case .failure(let error):
            print(error)
        }
        
    }
    
    public func checkUserLoggedInStatus() async {
        do{
            let result = try await sdk.isUserLoggedIn()
            DispatchQueue.main.async {
                if (result){
                    self.loadUserData()
                }
                self.userLoggedInStatus = result
                
            }
        }
        catch{
            print("Error getting user login status.")
        }
        
    }
    
    public func updateUserPredictions(_ predictions: [PredictionDataModel]) {
        self.userPredictions = predictions
    }
    
    public func loadUserData() {
        var newData = sdk.userPredictionsData.map({ data in
            PredictionDataModel(data: data)
        })
       
        // need to restore the isSelected value here.
        for i in 0..<newData.count {
            if let oldData = userPredictions.first(where: { newItem in
                newItem.PredictionId == newData[i].PredictionId
            }){
                newData[i].isSelected = oldData.isSelected
            }
            
        }
        
        DispatchQueue.main.async {
            self.userPredictions = newData
        }
        
    }
    
    public func onSelectDevice(deviceID:String){
        do
        {
            try sdk.connectSensorDevice(deviceId: deviceID)
        }
        catch{
            return
        }
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
    public func login() async -> Result<Void , Error>{
        let result = await sdk.loginUser()
        switch (result){
            case .success(_):
                DispatchQueue.main.async {
                    self.loadUserData()
                    self.userLoggedInStatus = true
                }
            case .failure(_):
                print("Error logging in")
                DispatchQueue.main.async {
                    self.userLoggedInStatus = false
                }
        }
        return result
    }
    public func scanForDevices(){
        try? sdk.scanForAvailableDevices()
    }
    public func onQAPassed(){
        qaModel!.stop()
        runClock()
        Task{
            let ids = userPredictions.filter{
                item in item.isSelected
            }.map{ pred in pred.PredictionId }
            let result = await sdk.startMultiPredictionSession(ids)
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
