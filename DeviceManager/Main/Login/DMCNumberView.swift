//
//  DMCNumberView.swift
//  DeviceManager
//
//  Created by 김미진 on 11/26/23.
//

import Foundation
import SwiftUI

struct DMCNumberView: View {
    @State var cNumber: String = ""
    
    @State var isShowPPView: Bool = false
    @State var isShowLoginView: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.DMColor.main.edgesIgnoringSafeArea(.all)
                VStack(alignment: .leading) {
                    VStack {
                        if let uiImage = UIImage(named: IconName.Main.pad) {
                            Image(uiImage: uiImage.withRenderingMode(.alwaysTemplate))
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundColor(Color.DMColor.white)
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width - 90)
                    Spacer()
                        .frame(height: 50)
                    
                    Text("그룹 번호")
                        .font(.headline)
                    
                    ColoredTextView(text: $cNumber, placeholder: "가입된 그룹 번호을 입력해 주세요.", cornerRadius: 25)
                        .frame(width: UIScreen.main.bounds.width - 90, height: 50)
                    
                    Spacer()
                        .frame(height: 20)
                    
                    HStack {
                        NavigationLink(destination: DMLoginView()) {
                            Text("입장 하기")
                                .font(.headline)
                                .foregroundStyle(Color.DMColor.white)
                                .frame(width: UIScreen.main.bounds.width - 90, height: 50)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.DMColor.white, lineWidth: 1) // border 색 및 두께 조정
                                )
                        }
//                        Button(action: {
//                            self.isShowLoginView = true
//                        }, label: {
//                            Text("입장 하기")
//                                .font(.headline)
//                                .foregroundStyle(Color.DMColor.white)
//                        })
//                        .frame(width: UIScreen.main.bounds.width - 90, height: 50)
//                        //                    .background(Color.blue)
//                        .cornerRadius(8)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 25)
//                                .stroke(Color.DMColor.white, lineWidth: 1) // border 색 및 두께 조정
//                        )
//                        .fullScreenCover(item: $isSho, content: <#T##(Identifiable) -> View#>)
                    }
                    Spacer()
                        .frame(height: 100)
                    VStack(spacing: 0) {
                        Text("DM이 처음이신가요?")
                            .font(.headline)
                            .frame(width: UIScreen.main.bounds.width - 90)
                            .foregroundStyle(Color.DMColor.white)
                        Button(action: {
                            isShowPPView = true
                        }, label: {
                            Text("그룹 등록하기")
                                .font(.headline)
                                .foregroundStyle(Color.DMColor.white)
                                .underline()
                        })
                        .frame(width: UIScreen.main.bounds.width - 90, height: 50)
                        .sheet(isPresented: $isShowPPView, content: {
                            DMPPView(isShowPPView: $isShowPPView)
                        })
                    }
                }
            }
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
    }
}
