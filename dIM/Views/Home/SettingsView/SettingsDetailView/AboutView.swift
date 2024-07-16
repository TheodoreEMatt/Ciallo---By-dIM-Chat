//
//  AboutView.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 16/10/2021.
//
// Original project by KaffeDiem
// Modified by TheodoreEMatt to include Simplified Chinese translation and new icons
import SwiftUI
import Foundation
import MessageUI

/// Shows some text together with an `Image`.
struct FeatureCell: View {
    var image: Image
    var title: String
    var subtitle: String
    
    var body: some View {
        HStack(spacing: 24) {
            image
                .resizable()
                .scaledToFit()
                .foregroundColor(.accentColor)
                .symbolRenderingMode(.hierarchical)
                .frame(width: 32, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                // Using `.init(:_)` to render Markdown links for iOS 15+
                Text(.init(subtitle))
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }
        }
    }
}

/// The `About` section in the `SettingsView`.
/// This is the small **dim** icon in the top of the settings as well as the description.
struct AboutView: View {
    @State private var emailHelperAlertIsShown = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                FeatureCell(image: Image("appiconsvg"), title: "关于切络", subtitle: "Ciallo是一个基于dIM开源项目以及蓝牙设备的开源且去中心化的即时聊天软件。连接世界，连接你我。")
                FeatureCell(image: Image(systemName: "network"), title: "端对端通讯", subtitle: "在您发送信息时，会由Ciallo组建的端对端网络进行传输，因此你无需担心信息安全。")
                FeatureCell(image: Image(systemName: "chevron.left.forwardslash.chevron.right"), title: "开放源代码", subtitle: "CialloChat和的父项目dIM的源代码都是公开的。两者共同遵循 GPL3.0许可证。这允许开发人员验证和改进dIM，使其成为最佳、最安全的去中心化即时聊天软件。您可以[在此处查看dIM的Github存储库](https://github.com/KaffeDiem/dIM)。")
                FeatureCell(image: Image(systemName: "lock.circle"), title: "加密性和隐私性", subtitle: "消息经过加密，只有您和接收者才能阅读，保护您免受无形的大手窥探。")
                FeatureCell(image: Image(systemName: "bubble.left.and.bubble.right"), title: "我们欢迎提交建议", subtitle: "你可以通过邮件或 [访问dIM项目的官方网站](https://www.dimchat.org).")
                    .padding(.bottom, 20)
                
                Button {
                    if !EmailHelper.shared.sendEmail(subject: "dIM Support or Feedback", body: "", to: "ma7836194@gmail.com") {
                        emailHelperAlertIsShown = true
                    }
                } label: {
                    Text("Email")
                }
                .padding(.bottom, 20)
                
                HStack {
                    Spacer()
                    Text("v\(Bundle.main.releaseVersionNumber ?? "")b\(Bundle.main.buildVersionNumber ?? "")")
                        .foregroundColor(.gray)
                        .font(.footnote)
                }
            }
        }
        .padding(20)
        .navigationTitle("关于Ciallo&dIM")
        .navigationBarTitleDisplayMode(.inline)
        .alert("没有找到默认邮箱", isPresented: $emailHelperAlertIsShown) {
            Button("了解", role: .cancel) { () }
        } message: {
            Text("请设置您的默认邮箱再向我们发送邮件。")
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}

/// An email helper class which allows us to send emails in the support section of
/// the settings view.
fileprivate class EmailHelper: NSObject, MFMailComposeViewControllerDelegate {
    /// The EmailHelper static object.
    public static let shared = EmailHelper()
    private override init() {}
    
    /// Send an email by using the built in email app in iOS.
    ///
    /// Should show a pop-up in the future if the default mail has not been set.
    /// - Parameters:
    ///   - subject: The subject field for the email.
    ///   - body: The text in the body of the email.
    ///   - to: The receiving email address.
    /// - Returns: A boolean confirming that a default email has been set up.
    func sendEmail(subject:String, body:String, to:String) -> Bool {
        if !MFMailComposeViewController.canSendMail() {
            print("No mail account found")
            return false
        }
        
        let picker = MFMailComposeViewController()
        
        picker.setSubject(subject)
        picker.setMessageBody(body, isHTML: true)
        picker.setToRecipients([to])
        picker.mailComposeDelegate = self
        
        EmailHelper.getRootViewController()?.present(picker, animated: true, completion: nil)
        return true
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        EmailHelper.getRootViewController()?.dismiss(animated: true, completion: nil)
    }
    
    static func getRootViewController() -> UIViewController? {
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController
    }
}
