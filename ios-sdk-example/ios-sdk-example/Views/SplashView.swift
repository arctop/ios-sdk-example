//
//  SplashView.swift
//  UITests
//
//  Created by Shai on 22/01/2023.
//

import SwiftUI
import NeuosSDK
struct SplashView : View {
    private let lightSplashImage = "stanford_splash"
    @ObservedObject var viewModel:ViewModel
    @ObservedObject var qaModel:QAViewModel
    @EnvironmentObject var hardwareMonitor: HardwareMonitorModel
    
    var body: some View {
        
            if (!viewModel.clientInit){
                    VStack(alignment: .center,spacing: 10){
                        Spacer()
                        Image(lightSplashImage)
                            .scaledToFill()
                        .onAppear{
                            Task{
                                await viewModel.initClient()
                                viewModel.qaModel = qaModel
                                await viewModel.checkUserLoggedInStatus()
                            }
                        }
                        Spacer()
                    }
            }
            else{
                if (viewModel.userLoggedInStatus){
                        VStack{
                            Image("stanford_header")
                                .scaledToFill().padding()
                        }
                        Spacer()
                        VStack{
                            
                            switch viewModel.myViewState {
                            case .start:
                                HomeView(userCalibrationStatus: $viewModel.userCalibrationStatus, onStartPredictions: viewModel.onStartPrediction, onLogoutClick: viewModel.onLogoutClick)
                                    .errorAlert(error: $viewModel.lastError)
                                    .onAppear{
                                        Task{
                                            await viewModel.checkUserCalibrationStatus()
                                        }
                                    }
                            case .pair:
                                PairDeviceView(muses: $viewModel.museList, onSelectDevice: viewModel.onSelectDevice).onAppear{
                                    viewModel.scanForDevices()
                                }.errorAlert(error: $viewModel.lastError)
                            case .qa:
                                QAView(qaColors: $qaModel.qaColors, isHeadbandOn: $qaModel.isHeadbandOn).errorAlert(error: $viewModel.lastError)
                                VStack(alignment: .leading){
                                    Text("Signal quality").bold()
                                    LinearGradient(gradient: Gradient(colors: [viewModel.noSignalColor , viewModel.goodSignalColor]),
                                           startPoint: .leading, endPoint: .trailing)
                                    .frame(height: 20)
                                    HStack{
                                        Text("No Signal")
                                        Spacer()
                                        Text("Good")
                                    }.padding(.bottom)

                                    Text("Headband battery").bold().padding(.bottom)
                                    HStack{
                                        let tint:Color = getBatteryTint()
                                        if viewModel.batteryPower >= 0{
                                            let image = "\(Int(round(viewModel.batteryPower / 25) * 25))"
                                            Image(systemName: "battery.\(image)").rotationEffect(Angle(degrees: -90)).foregroundColor(tint)
                                            Text("\(Int(viewModel.batteryPower))%")
                                        }
                                        else{
                                            Image(systemName: "battery.0").rotationEffect(Angle(degrees: -90)).foregroundColor(tint)
                                            Text("Checking...")
                                        }
                                    }
                                    #if DEBUG
                                    Button("Debug Skip"){
                                        viewModel.onQAPassed()
                                    }.buttonStyle(SquareButtonStyle())
                                    #endif
                                }
                            case .prediction:
                                PredictionView(viewModel: viewModel).errorAlert(error: $viewModel.lastError)
                            case .summery:
                                Text("Upload Successful!").font(.largeTitle).padding(.bottom)
                                Button("Exit"){
                                    viewModel.myViewState = .start
                                }.buttonStyle(SquareButtonStyle()).padding(.top)
                            }
                        
                        }.padding()
                    Spacer()
                }
                else{
                    VStack{
                        Image("stanford_header")
                            .scaledToFill().padding()
                    }
                    Spacer()
                        LoginView(viewModel: viewModel)
                            .errorAlert(error: $viewModel.lastError).padding()
                    Spacer()
                }
            }
        }
    private func getBatteryTint() -> Color{
        switch viewModel.batteryPower {
            case 0...15: return .red
            case 16...50: return .yellow
            case 51...100: return .green
            default: return .white
        }
    }
    
}
