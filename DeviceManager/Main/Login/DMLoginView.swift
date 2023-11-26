//
//  DMLoginView.swift
//  DeviceManager
//
//  Created by 김미진 on 11/25/23.
//

import Foundation
import SwiftUI

struct DMLoginView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var emailForID: String = ""
    @State var password: String = ""
    
    @State var isShowDeviceListView: Bool = false
    
    var body: some View {
        ZStack {
            Color.DMColor.main.edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading) {
                Spacer()
                Text("e-mail")
                    .font(.headline)

                ColoredTextView(text: $emailForID, placeholder: "Enter your Email", cornerRadius: 25)
                    .frame(width: UIScreen.main.bounds.width - 90, height: 50)
                
                Spacer()
                    .frame(height: 20)
                
                Text("Password")
                    .font(.headline)
                
                ColoredTextView(text: $password, placeholder: "Enter your password", cornerRadius: 25)
                    .frame(width: UIScreen.main.bounds.width - 90, height: 50)
                
                Spacer()
                    .frame(height: 50)
                
                HStack {
                    Button(action: {
                        // 등록된 회사의 메일인지 확인하고 넘어가줌.
                        self.isShowDeviceListView = true
                    }, label: {
                        Text("Sign in")
                            .font(.headline)
                            .foregroundStyle(Color.DMColor.white)
                    })
                    .frame(width: UIScreen.main.bounds.width - 90, height: 50)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.DMColor.white, lineWidth: 1) // border 색 및 두께 조정
                    )
                    .fullScreenCover(isPresented: $isShowDeviceListView, content: {
                        DeviceListView()
                    })
                }
                
                Spacer()
                VStack(spacing: 0) {
                    Text("가입 된 계정이 없으신가요?\n각 그룹 관리자에게 문의해 주세요.")
                        .font(.headline)
                        .frame(width: UIScreen.main.bounds.width - 90)
                        .foregroundStyle(Color.DMColor.white)
//                    Button(action: {
//                        isShowSignUp = true
//                    }, label: {
//                        Text("Sign up")
//                            .font(.headline)
//                            .foregroundStyle(Color.DMColor.white)
//                            .underline() 
//                    })
//                    .frame(width: UIScreen.main.bounds.width - 90, height: 50)
//                    .sheet(isPresented: $isShowSignUp, content: {
//                        DMSignUpView(isShowSignUp: $isShowSignUp)
//                    })
                }
                Spacer()
                    .frame(height: 100)
            }
            .navigationBarBackButtonHidden(true) // 기본 뒤로가기 버튼 숨김
            .navigationBarItems(leading:
                Button(action: {
                    // 뒤로가기 기능 구현
                    self.presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.white) // 흰색으로 설정
                        .imageScale(.large)
                })
            )
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    if gesture.translation.width > 100 {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
        )
        
    }
}
