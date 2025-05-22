//
//  HomeView.swift
//  ios-sdk-example
//
//  Created by Shai Kalev on 08/08/2023.
//

import SwiftUI
import ArctopSDK
struct HomeView: View {
    //@Binding var userPredictions:[PredictionDataModel]
    @StateObject var viewModel : ViewModel
    @State private var userPredictions: [PredictionDataModel] = []
    var onStartPredictions: () -> Void
    var onLogoutClick: () -> Void
    var onPermissionRequest: () -> Void
    var body: some View {
        VStack{
            Button("Logout Current User"){
                viewModel.updateUserPredictions(userPredictions)
                onLogoutClick()
            }.buttonStyle(SquareButtonStyle()).padding(.bottom)
            showAvailablePredictionsView
            Spacer()
            HStack{
                Button("Begin Recording"){
                    viewModel.updateUserPredictions(userPredictions)
                    onStartPredictions()
                }
                .disabled(
                    !userPredictions.contains{ item in item.CalibrationStatus == .modelsAvailable && item.PredictionPermission && item.isSelected}
                )
                .buttonStyle(SquareButtonStyle())
                Button(action: {
                    viewModel.updateUserPredictions(userPredictions)
                    onPermissionRequest()
                }, label:{
                    Image(systemName: "key")
                })
                .disabled(!userPredictions.contains{
                    item in !item.PredictionPermission
                })
                .buttonStyle(SquareButtonStyle())
                .frame(width: 40)
            }
        }.padding()
        .onReceive(viewModel.$userPredictions){ userPredictions in
            self.userPredictions = userPredictions
        }
    }
    var showAvailablePredictionsView : some View {
        ScrollView{
            Grid(alignment: .leading) {
                GridRow() {
                    Text("Prediction")
                        .foregroundColor(Color.black)
                    Image(systemName: "dot.scope")
                        .gridColumnAlignment(.center)
                    Image(systemName: "key.viewfinder")
                        .gridColumnAlignment(.center)
                    Text("Run")
                        .foregroundColor(.black)
                        .gridColumnAlignment(.center)
                }
                .font(.title3)
                Divider()
                ForEach($userPredictions) { $item in
                    GridRow() {
                        Text(item.PredictionTitle)
                            .foregroundColor(Color.black)
                        getCalibrationStatusDescription(item.CalibrationStatus).gridColumnAlignment(.center)
                        Image(systemName: item.PredictionPermission ? "key" : "key.slash").gridColumnAlignment(.center)
                        Toggle("", isOn: $item.isSelected).disabled(item.CalibrationStatus != .modelsAvailable || item.PredictionPermission != true)
                            .toggleStyle(CheckToggleStyle()).gridColumnAlignment(.center)
                    }
                    Divider()
                        .frame(height: 1.0)
                }
            }
        }.padding()
    }
    let frameSizes: CGFloat = 15.0
    func getCalibrationStatusDescription(_ calibrationStatus: UserCalibrationStatus) -> some View {
       
        switch calibrationStatus {
            case .calibrationDone:
                Circle().fill(Color.yellow).frame(width: frameSizes, height: frameSizes)
            case .modelsAvailable:
                Circle().fill(Color.green).frame(width: frameSizes, height: frameSizes)
            case .blocked:
                fallthrough
            case .needsCalibration:
                fallthrough
            case .lockedByOthers:
                fallthrough
            case .unknown:
                Circle().fill(Color.red).frame(width: frameSizes, height: frameSizes)
            @unknown default:
                Circle().fill(Color.clear).frame(width: frameSizes, height: frameSizes)
        }
    }
}

