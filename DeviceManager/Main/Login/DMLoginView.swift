//
//  DMLoginView.swift
//  DeviceManager
//
//  Created by 김미진 on 11/25/23.
//

import Foundation
import SwiftUI

struct DMLoginView: View {
    @State var emailForID: String = ""
    @State var password: String = ""
    
    @State var isShowSignUp: Bool = false
    
    var body: some View {
        ZStack {
            Color.DMColor.main.edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading) {
                Text("e-mail")
                    .font(.headline)

                ColoredTextView(text: $emailForID, placeholder: "Enter your Email", cornerRadius: 12)
                    .frame(width: UIScreen.main.bounds.width - 90, height: 50)
                
                Spacer()
                    .frame(height: 20)
                
                Text("Password")
                    .font(.headline)
                
                ColoredTextView(text: $password, placeholder: "Enter your password", cornerRadius: 12)
                    .frame(width: UIScreen.main.bounds.width - 90, height: 50)
                
                Spacer()
                    .frame(height: 50)
                
                HStack {
                    Button(action: {}, label: {
                        Text("Sign in")
                            .font(.headline)
                            .foregroundStyle(Color.DMColor.white)
                    })
                    .frame(width: UIScreen.main.bounds.width - 90, height: 50)
//                    .background(Color.blue)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.DMColor.white, lineWidth: 1) // border 색 및 두께 조정
                    )
                }
                Spacer()
                    .frame(height: 100)
                VStack(spacing: 0) {
                    Text("가입 된 계정이 없으신가요?")
                        .font(.headline)
                        .frame(width: UIScreen.main.bounds.width - 90)
                        .foregroundStyle(Color.DMColor.white)
                    Button(action: {
                        isShowSignUp = true
                    }, label: {
                        Text("Sign up")
                            .font(.headline)
                            .foregroundStyle(Color.DMColor.white)
                            .underline() 
                    })
                    .frame(width: UIScreen.main.bounds.width - 90, height: 50)
                    .sheet(isPresented: $isShowSignUp, content: {
                        DMSignUpView(isShowSignUp: $isShowSignUp)
                    })
                }
            }
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}
