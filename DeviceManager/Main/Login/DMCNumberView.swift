//
//  DMCNumberView.swift
//  DeviceManager
//
//  Created by 김미진 on 11/26/23.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore

struct DMCNumberView: View {
    @State var cNumber: String = ""
    @ObservedObject var viewModel = DMCNumberViewModel()
    
    @State private var isLoading = false
    @State var isShowPPView: Bool = false
    @State var isShowLoginView: Bool = false
    @State private var isLoginSuccessful = false
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.DMColor.main.edgesIgnoringSafeArea(.all)
                VStack {
                    VStack {
                        if let uiImage = UIImage(named: IconName.Main.pad) {
                            Image(uiImage: uiImage.withRenderingMode(.alwaysTemplate))
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundColor(Color.DMColor.white)
                        }
                    }
                    .frame(width: 300)
                    Spacer()
                        .frame(height: 50)
                    
                    Text("그룹 번호")
                        .font(.headline)
                    
                    ColoredTextView(text: $cNumber, placeholder: "가입된 그룹 번호을 입력해 주세요.", cornerRadius: 25)
                        .frame(width: 300, height: 50)
                    
                    Spacer()
                        .frame(height: 10)
                    
                    HStack {
                        Button(action: {
                            // enterApp 함수 호출
                            isLoading = true
                            viewModel.enterWithCNumber(cNumber: cNumber)
                        }) {
                            Text("입장 하기")
                                .font(.headline)
                                .foregroundStyle(Color.DMColor.white)
                                .frame(width: 300, height: 50)
                                .cornerRadius(8)
//                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.DMColor.white, lineWidth: 1) // border 색 및 두께 조정
                                )
                        }
//                        .padding()
                        .disabled(cNumber.isEmpty)
                        NavigationLink(destination: DMLoginView(), isActive: $isLoginSuccessful) {
                            EmptyView()
                        }
                        .alert(isPresented: $showingAlert) {
                            Alert(title: Text("입장 실패"), message: Text("그룹 번호를 다시 확인해 주세요."), dismissButton: .default(Text("확인")))
                        }
                    }
                    Spacer()
                        .frame(height: 100)
                    VStack(spacing: 0) {
                        Text("DM이 처음이신가요?")
                            .font(.headline)
                            .frame(width: 300)
                            .foregroundStyle(Color.DMColor.white)
                        Button(action: {
                            isShowPPView = true
                        }, label: {
                            Text("그룹 등록하기")
                                .font(.headline)
                                .foregroundStyle(Color.DMColor.white)
                                .underline()
                        })
                        .frame(width: 300, height: 50)
                        .sheet(isPresented: $isShowPPView, content: {
                            DMPPView(isShowPPView: $isShowPPView)
                        })
                    }
                }
                
                if isLoading {
                    ProgressView("")
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(2.0) // 크기 조절
                        .padding()
                        .tint(Color.black)
                }
            }
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .onReceive(viewModel.$isLoggedIn) { isLoggedIn in
                guard let isLoggedIn = isLoggedIn else { return }
                if isLoggedIn {
                    
                    isLoading = false
                    isLoginSuccessful = true
                    // 로그인 성공 시 다음 화면으로 이동하거나 필요한 동작 수행
                    // 예: NavigationLink를 이용한 다음 화면으로 이동
                } else {
                    isLoading = false
                    showingAlert = true
                    // 로그인 실패 시 경고 메시지 표시 등의 작업 수행
                    // 예: Alert 표시
                }
            }
        }
    }
    
    
//    private func enterApp() {
//        // Firestore 참조 생성
//        let db = Firestore.firestore()
//        let docRef = db.collection("accountList").document(cNumber)
//        // Firestore에서 데이터 읽기 (예시: "users" 컬렉션에서 데이터 읽어오기)
//        docRef.getDocument { document, error in
//            if let error = error {
//                showingAlert = true
//                print("Error fetching document: \(error.localizedDescription)")
//                
//            } else {
//                if let document = document, document.exists {
//                    // 문서가 존재하는 경우
//                    let fetchedData = document.data() ?? [:] as? [String:Any] // 문서 데이터를 가져옴
//                    isLoginSuccessful = true
//                } else {
//                    showingAlert = true
//                }
//            }
//        }
//    }
}
