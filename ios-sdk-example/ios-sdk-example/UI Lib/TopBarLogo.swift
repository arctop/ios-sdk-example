//
//  TopBarLogo.swift
//  UITests
//
//  Created by Shai on 23/01/2023.
//

import SwiftUI

struct TopBarLogo: View {
    @Environment(\.colorScheme) var colorScheme
    private let darkLogoImage = "Logo-Dark"
    private let lightLogoImage = "Logo"
    @State var logoSize:CGFloat = 0.75
    var body: some View {
        
        Text("").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image(colorScheme == .dark ? darkLogoImage : lightLogoImage)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(logoSize)
                }
            }
            /*.toolbar {
                ToolbarItem(placement: .principal) {
                    Image(colorScheme == .dark ? darkLogoImage : lightLogoImage)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(logoSize)
                }
            }*/
    }
}


struct TopBarLogo_Previews: PreviewProvider {
    static var previews: some View {
        TopBarLogo()
    }
}
