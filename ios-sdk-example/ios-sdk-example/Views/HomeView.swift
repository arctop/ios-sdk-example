//
//  HomeView.swift
//  ios-sdk-example
//
//  Created by Shai Kalev on 08/08/2023.
//

import SwiftUI
import ArctopSDK
struct HomeView: View {
    @Binding var userCalibrationStatus:UserCalibrationStatus
    var onStartPredictions: () -> Void
    var onLogoutClick: () -> Void
    var body: some View {
        VStack{
            Button("Logout Current User"){
                onLogoutClick()
            }.buttonStyle(SquareButtonStyle()).padding(.bottom)
            switch (userCalibrationStatus){
            case .blocked , .unknown:
                Text("Checking user calibration status...").padding([.vertical])
            case .needsCalibration:
                Text("User is not calibrated").padding([.vertical])
                //TODO: Deep link for calibration
            case .calibrationDone:
                Text("Your models are being processed").padding([.vertical])
            case .modelsAvailable:
                Button("Begin Recording"){
                    onStartPredictions()
                }.buttonStyle(SquareButtonStyle()).padding([.vertical])
            @unknown default:
                fatalError()
            }
        }.padding()
    }
}

