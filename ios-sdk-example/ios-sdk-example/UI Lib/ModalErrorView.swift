//
//  ModalErrorView.swift
//  ArctopCentral
//
//  Created by Shai on 30/03/2023.
//

import SwiftUI
struct ModalErrorView<Content>: View where Content: View {

    var isShowing: Bool
    var contentMessage:String
    var titleMessage:String = "Error"
    var content: () -> Content

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                self.content()
                    .disabled(self.isShowing)
                    .blur(radius: self.isShowing ? 3 : 0)
                let errorWidth = geometry.size.width / 2 - geometry.size.width / 16
                VStack {
                    HStack{
                        Text(titleMessage).foregroundColor(.white)
                    }.frame(width: errorWidth).background(.red)
                    Text(contentMessage).padding(.top)
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .frame(width: geometry.size.width / 2,
                       height: geometry.size.height / 4)
                .background(Color.secondary.colorInvert())
                .foregroundColor(Color.primary)
                .cornerRadius(20)
                .opacity(self.isShowing ? 1 : 0)
            }
        }
    }

}
struct ModalErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ModalErrorView(isShowing: true, contentMessage: "No network detected. this is an error"){EmptyView()}
    }
}
