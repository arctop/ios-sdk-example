//
//  HomeView.swift
//  ios-sdk-example
//
//  Created by Shai Kalev on 08/08/2023.
//

import SwiftUI
import NeuosSDK
struct HomeView: View {
    @Binding var userCalibrationStatus:NeuosUserCalibrationStatus
    var onStartPredictions: () -> Void
    var onLogoutClick: () -> Void
    var body: some View {
        VStack{
            Button("Logout"){
                onLogoutClick()
            }.buttonStyle(SquareButtonStyle()).padding(.bottom)
            switch (userCalibrationStatus){
            case .blocked , .unknown:
                Text("Awaiting Status...").padding([.vertical])
            case .needsCalibration:
                Text("User is not calibrated").padding([.vertical])
                //TODO: Deep link for calibration
            case .calibrationDone:
                Text("Your models are being processed").padding([.vertical])
            case .modelsAvailable:
                Button("Start Prediction"){
                    onStartPredictions()
                }.buttonStyle(SquareButtonStyle()).padding([.vertical])
            @unknown default:
                fatalError()
            }
        }.padding()
    }
}

