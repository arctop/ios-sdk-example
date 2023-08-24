//
//  ContentView.swift
//  ios-sdk-example
//
//  Created by Shai Kalev on 02/07/2023.
//

import SwiftUI
import NeuosSDK

struct ContentView: View {
    @State var userStatus:Bool = false
    @State var userCalibrationStatus: NeuosUserCalibrationStatus = .unknown
    @State var progressShowing:Bool = false
    @ObservedObject var qaModel:QAViewModel = QAViewModel()
    @ObservedObject var viewModel:ViewModel = ViewModel()
    @ObservedObject var pairViewModel = PairViewModel()
    init(){
        viewModel.onSigQuality = onQaString
        viewModel.onHeadbandStatus = onHead
        //qaModel.setOnQAPassed(onQAPassed)
        viewModel.sdk.registerListener(listener: viewModel as NeuosSDKQAListener)
        viewModel.sdk.registerListener(listener: viewModel as NeuosSDKListener)
        viewModel.sdk.registerListener(listener: pairViewModel)
    }
    var body: some View {
        VStack {
            Text("State: \(viewModel.myViewState.rawValue)")
            switch viewModel.myViewState {
            case .start:
                //HomeView(userCalibrationStatus: $userCalibrationStatus, onStartPredictions: onStartPred)
                Text("User LoggedIn \(userStatus ? "True" : "False")")
                Text("User Calibration Status \(userCalibrationStatus.rawValue)")
                Button("Check Login"){
                    Task{
                        await viewModel.initClient()
                        userStatus = ((try? await viewModel.sdk.isUserLoggedIn()) != nil)
                        if (!userStatus){
                            // TODO: Open deep link into neuos with my token
                        }
                        let result = await viewModel.sdk.checkNeuosUserCalibrationStatus()
                        switch (result){
                            case .success(let value):
                                userCalibrationStatus = value
                            case .failure(_):
                                print("Error getting calibration status")
                        }
                    }
                }
            case .pair:
                PairDeviceView(muses: $pairViewModel.museList, onSelectDevice: onSelectDevive)
            case .qa:
                QAView(qaColors: $qaModel.qaColors, isHeadbandOn: $qaModel.isHeadbandOn)
            case .prediction:
                if (progressShowing){
                    ProgressView()
                }
                else{
                    List{
                        Text("QA passed:\(viewModel.realtimeQaValue.0.description) , reason: \(viewModel.realtimeQaValue.1.description)")
                        
                        ForEach(viewModel.realtimePredictionValues.keys , id: \.self){ key in
                            Text("\(key) : \(viewModel.realtimePredictionValues[key]!.description)")
                        }
                        ForEach(viewModel.realtimeMotionData.keys , id: \.self){ key in
                            Text("\(key) : \(viewModel.realtimeMotionData[key]!.description)")
                        }
                    }.padding(.bottom)
                    Button("Finish"){
                        Task{
                            await tryUploadSession()
                        }
                    }
                }
            }
           
        }
        .padding()
    }
    private func onHead(value:Bool){
        qaModel.isHeadbandOn = value
    }
    private func onQaString(value:String){
        qaModel.qaString = value
    }
    private func onStartPred(){
        try? viewModel.sdk.scanForAvailableDevices()
        viewModel.myViewState = .pair
    }
    private func onSelectDevive(deviceId:String){
        try? viewModel.sdk.connectSensorDevice(deviceId: deviceId)
        qaModel.start(quality: .perfect)
        viewModel.myViewState = .qa
    }
   
    private func onQAPassed(){
        qaModel.stop()
        viewModel.myViewState = .prediction
        Task{
            await viewModel.sdk.startPredictionSession("zone")
        }
    }
    private func tryUploadSession() async{
        progressShowing = true
        let result = await viewModel.sdk.finishSession()
        switch result {
        case .success(_):
            progressShowing = false
            viewModel.myViewState = .start
        case .failure(let error):
            print(error)
           // viewModel.lastError = LocalizedAlertError(error , title: "Uploading Session Failed")
            //showRetryUpload = true
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
