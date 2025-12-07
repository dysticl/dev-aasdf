//
//  ProfileViewWrapper.swift
//  Wrapper um NewProfileView für die alte HomeView
//

import SwiftUI

struct ProfileViewWrapper: View {
    @State private var appData = AppData()
    
    var body: some View {
        NewProfileView()
            .environment(appData)
    }
}
