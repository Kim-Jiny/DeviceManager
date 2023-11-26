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
                    .frame(width: 300)
                    Spacer()
                        .frame(height: 50)
                    
                    Text("그룹 번호")
                        .font(.headline)
                    
                    ColoredTextView(text: $cNumber, placeholder: "가입된 그룹 번호을 입력해 주세요.", cornerRadius: 25)
                        .frame(width: 300, height: 50)
                    
                    Spacer()
                        .frame(height: 20)
                    
                    HStack {
                        NavigationLink(destination: DMLoginView()) {
                            Text("입장 하기")
                                .font(.headline)
                                .foregroundStyle(Color.DMColor.white)
                                .frame(width: 300, height: 50)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.DMColor.white, lineWidth: 1) // border 색 및 두께 조정
                                )
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
            }
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            
            .onAppear {
               // Firebase 앱 초기화
                FirebaseApp.configure()

                // Firestore 참조 생성
                let db = Firestore.firestore()

                // Firestore에서 데이터 읽기 (예시: "users" 컬렉션에서 데이터 읽어오기)
                db.collection("accountList").getDocuments { querySnapshot, error in
                    if let error = error {
                        print("Error fetching data: \(error.localizedDescription)")
                    } else {
                        guard let documents = querySnapshot?.documents else { return }
                        var fetchedData: [String: Any] = [:]
                        for document in documents {
                            fetchedData[document.documentID] = document.data()
                        }
                        // 읽어온 데이터를 State에 저장
                        print(fetchedData)
                    }
                }
           }
        }
    }
}
