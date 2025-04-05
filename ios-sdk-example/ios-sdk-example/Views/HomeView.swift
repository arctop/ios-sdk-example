//
//  HomeView.swift
//  ios-sdk-example
//
//  Created by Shai Kalev on 08/08/2023.
//

import SwiftUI
import ArctopSDK
struct HomeView: View {
    @Binding var userPredictions:[PredictionDataModel]
    var onStartPredictions: () -> Void
    var onLogoutClick: () -> Void
    var body: some View {
        VStack{
            Button("Logout Current User"){
                onLogoutClick()
            }.buttonStyle(SquareButtonStyle()).padding(.bottom)
            ForEach(userPredictions.indices) { item in
                HStack{
                    Text(userPredictions[item].PredictionTitle)
                    Text(getCalibrationStatusDescription(userPredictions[item].CalibrationStatus))
                    Toggle("", isOn: $userPredictions[item].isSelected).disabled(userPredictions[item].CalibrationStatus != .modelsAvailable)
                }.padding(.horizontal)
            }
            Spacer()
            if (userPredictions.contains{ item in item.CalibrationStatus == .modelsAvailable }){
                Button("Begin Recording"){
                    onStartPredictions()
                }
                .disabled(!userPredictions.contains(where: { PredictionDataModel in
                    PredictionDataModel.isSelected
                }))
                .buttonStyle(SquareButtonStyle()).padding([.vertical])
            }
            Spacer()
           
        }.padding()
    }
    private func getCalibrationStatusDescription(_ status: UserCalibrationStatus) -> String {
        switch status {
            case .needsCalibration: return "Needs calibration"
            case .blocked: return "Blocked"
            case .lockedByOthers : return "Locked by others"
            case .calibrationDone: return "Calibration done"
            case .modelsAvailable: return "Models available"
            case .unknown:
                return "Unknown"
            @unknown default:
                return "Unknown"
        }
    }
}

