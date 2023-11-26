//
//  ColoredTextView.swift
//  DeviceManager
//
//  Created by 김미진 on 11/25/23.
//

import Foundation
import SwiftUI

struct ColoredTextView: UIViewRepresentable {
    @Binding var text: String
    var textLimit: Int = 200
    var textColor: UIColor = UIColor(Color.DMColor.black)
    var placeholder: String? = nil
    var placeholderColor: UIColor = UIColor(Color.DMColor.placeholder)
    var cornerRadius: CGFloat? = nil
    var borderWidth: CGFloat? = nil
    var borderColor: CGColor? = nil
    var isScrollEnabled: Bool = false
    var isEditable: Bool = true
    var isUserInteractionEnabled: Bool = true
    var lineFragmentPadding: CGFloat = 0
    var textContainerInset: UIEdgeInsets = .init(top: 20, left: 10, bottom: 20, right: 10)
    
    public func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()

        if let cornerRadius = cornerRadius {
            textView.layer.cornerRadius = cornerRadius
            textView.layer.masksToBounds = true
        }
        if let borderWidth = borderWidth {
            textView.layer.borderWidth = borderWidth
        }
        if let borderColor = borderColor {
            textView.layer.borderColor = borderColor
        }
        if let placeholder = placeholder, text == "" {
            textView.text = placeholder
            textView.textColor = placeholderColor
        } else {
            textView.text = text
            textView.textColor = textColor
        }
      
        textView.isScrollEnabled = isScrollEnabled
        textView.isEditable = isEditable
        textView.isUserInteractionEnabled = isUserInteractionEnabled
        textView.textContainer.lineFragmentPadding = lineFragmentPadding
        textView.textContainerInset = textContainerInset
        textView.delegate = context.coordinator
        textView.backgroundColor = UIColor(Color.DMColor.white)
        textView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        if let placeholder = placeholder, text == "" {
            textView.text = placeholder
            textView.textColor = placeholderColor
        } else {
            textView.text = text
            textView.textColor = textColor
        }
        return textView
    }
    
    public func updateUIView(_ uiView: UITextView, context: Context) {
        if text != "" {
            uiView.text = text
            uiView.textColor = textColor
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    public class Coordinator: NSObject, UITextViewDelegate {
        var parent: ColoredTextView
      
        init(parent: ColoredTextView) {
            self.parent = parent
        }
      
        public func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        
            if textView.text.isEmpty {
                textView.textColor = parent.placeholderColor
            } else {
                textView.textColor = parent.textColor
            }
        
            if textView.text.count > parent.textLimit {
                textView.text.removeLast()
            }
        }
      
        public func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.text == parent.placeholder {
                textView.text = ""
            }
        }
      
        public func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.text = parent.placeholder
                textView.textColor = parent.placeholderColor
            } else {
                textView.textColor = parent.textColor
            }
        }
        
        public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if text == "\n" {
                return false
            }
            return true
        }
    }
}
