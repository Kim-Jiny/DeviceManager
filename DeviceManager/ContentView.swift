//
//  ContentView.swift
//  DeviceManager
//
//  Created by 김미진 on 11/25/23.
//

import SwiftUI
import Firebase

struct ContentView: View {
    @State var isShowGroupView: Bool = false
    @State var isShowMainView: Bool = false
    
    var body: some View {
        ZStack {
            Color.DMColor.main.edgesIgnoringSafeArea(.all)
            VStack {
                Image(systemName: IconName.Main.phone)
                    .imageScale(.large)
                    .foregroundColor(Color.DMColor.white)
                Text("Hello, world!")
            }
            .padding()
            .onAppear {
                // 자동로그인 정보가 있는지 체크해서 로그인 페이지로 or 메인으로 보내줌.
                // 현재는 로그인화면부터 구현
                isShowGroupView = true
               // Firebase 앱 초기화
                FirebaseApp.configure()
            }
            .fullScreenCover(isPresented: $isShowGroupView) {
                DMCNumberView()
            }
        }
    }
}

//#Preview {
//    ContentView()
//}
