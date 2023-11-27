//
//  DMCNumberViewModel.swift
//  DeviceManager
//
//  Created by 김미진 on 11/27/23.
//

import Foundation
import Combine
import FirebaseFirestore

class DMCNumberViewModel: ObservableObject {
    @Published var isLoggedIn: Bool?
    
    func enterWithCNumber(cNumber: String) {
        let db = Firestore.firestore()
        
        db.collection("accountList").document(cNumber).getDocument { (document, error) in
            if let document = document, document.exists {
                self.isLoggedIn = true // 해당 아이디가 존재하면 로그인 성공
            } else {
                self.isLoggedIn = false // 해당 아이디가 존재하지 않으면 로그인 실패
            }
        }
    }
}
