//
//  ContentView.swift
//  Mate
//
//  Created by User on 30.06.2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(themeManager.currentColors.mainAccentColor)
            Text("hello_world".localized(language: localizationManager.currentLanguage))
                .foregroundColor(themeManager.currentColors.mainTextColor)
        }
        .padding()
        .background(themeManager.currentColors.mainBgColor)
    }
}

#Preview {
    ContentView()
}
