//
//  ios_sdk_exampleApp.swift
//  ios-sdk-example
//
//  Created by Shai Kalev on 02/07/2023.
//

import SwiftUI
import ArctopSDK
@main
struct ios_sdk_exampleApp: App {
    @StateObject var hardwareMonitor = HardwareMonitorModel()
    @StateObject var viewModel = ViewModel()
    @StateObject var qaModel =  QAViewModel()
    init(){
    }
    var body: some Scene {
        WindowGroup {
            //ContentView()
            SplashView(viewModel: viewModel , qaModel: qaModel).environmentObject(hardwareMonitor).environment(\.colorScheme, .light)
        }
    }
}
