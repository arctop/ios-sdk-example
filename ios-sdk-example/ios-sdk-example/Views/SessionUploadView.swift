//
//  SessionUploadView.swift
//  ArctopCentral
//
//  Created by Shai on 28/03/2023.
//

import SwiftUI
import ArctopSDK
struct SessionUploadView: View {
    var body: some View {
        VStack{
            ProgressView(){
                Text("Uploading...")
            }.progressViewStyle(.circular)
        }
    }
}

struct SessionUploadView_Previews: PreviewProvider {
    static var previews: some View {
        SessionUploadView()
    }
}
