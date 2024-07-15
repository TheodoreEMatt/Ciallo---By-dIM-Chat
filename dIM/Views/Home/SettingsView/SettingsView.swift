//
//  SettingsView.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 25/08/2021.
//

import SwiftUI

/// The main `SettingsView` which shows a number of subviews for different purposes.
///
/// It is here that we set new usernames and toggles different settings.
/// It also shows contact information for dIM among other things.
struct SettingsView: View {
    /// CoreDate context object
    @Environment(\.managedObjectContext) var context
    @Environment(\.colorScheme) var colorScheme
    
    /// The `UserDefaults` for getting information from persistent storage.
    private let defaults = UserDefaults.standard
    
    /// The `AppSession` to get things from the logic layer.
    @EnvironmentObject var appSession: AppSession
    
    @State private var usernameTextFieldText = ""
    @State private var usernameTextFieldIdentifier = ""
    
    @State private var invalidUsernameAlertMessageIsShown = false
    @State private var invalidUsernameAlertMessage = ""
    
    @State private var changeUsernameAlertMessageIsShown = false
    
    /// All conversations stored to CoreData
    @FetchRequest(
        entity: ConversationEntity.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \ConversationEntity.date, ascending: false)
        ]
    ) var conversations: FetchedResults<ConversationEntity>
    
    /// Read messages setting saved to UserDefaults
    @AppStorage(UserDefaultsKey.readMessages.rawValue) var readStatusToggle = false
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 65)
                    
                    if changeUsernameAlertMessageIsShown {
                        Spacer()
                        ProgressView()
                    } else {
                        TextField("Choose a username...", text: $usernameTextFieldText, onCommit: {
                            hideKeyboard()
                            
                            switch UsernameValidator.shared.validate(username: usernameTextFieldText) {
                            case .valid, .demoMode:
                                changeUsernameAlertMessageIsShown = true
                            case .error(message: let errorMessage):
                                invalidUsernameAlertMessage = errorMessage
                                invalidUsernameAlertMessageIsShown = true
                            default: ()
                            }
                        })
                        .keyboardType(.namePhonePad)
                        .padding()
                        .cornerRadius(10.0)
                    }
                    
                    Spacer()
                    
                    Text("# " + usernameTextFieldIdentifier)
                        .foregroundColor(.gray)
                }
                .foregroundColor(.accentColor)
            } header: {
                Text("用户名")
            } footer: {
                Text("若更改自己的用户名，将失去联系人并需要重新添加联系人。")
            }
            
            Section {
                Toggle(isOn: $readStatusToggle) {
                    Label("显示已读反馈", systemImage: "eye.fill")
                        .imageScale(.large)
                }
                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
            } footer: {
                Text("已读回执允许您的联系人查看您是否已阅读他们的消息。")
            }
            
            Section {
                NavigationLink(destination: AboutView()) {
                    Label("关于Ciallo Chat", systemImage: "questionmark")
                        .foregroundColor(.accentColor)
                        .imageScale(.large)
                }
            }
            
            Section {
                Label(
                    appSession.connectedDevicesAmount < 0 ? "No devices connected." : "\(appSession.connectedDevicesAmount) 个设备连接",
                    systemImage: "ipad.and.iphone")
                    .imageScale(.large)
                
                Label("\(appSession.routedCounter) 个在此次会话中收到的消息", systemImage: "arrow.left.arrow.right")
                    .imageScale(.large)
            } header: {
                Text("无线连接状态")
            } footer: {
                Text("已经与你手机形成端对端网络的设备详情。")
            }
        }
        .symbolRenderingMode(.hierarchical)
        .autocapitalization(.none)
        .disableAutocorrection(true)
        .navigationBarTitle("设置", displayMode: .large)
        .onAppear {
            setUsernameTextFieldToStoredValue()
        }
        // MARK: Alerts
        // Invalid username alert
        .alert("Invalid username", isPresented: $invalidUsernameAlertMessageIsShown) {
            Button("OK", role: .cancel) {
                setUsernameTextFieldToStoredValue()
            }
        } message: {
            Text(invalidUsernameAlertMessage)
        }
        // Change username alert
        .alert("更改用户名提示", isPresented: $changeUsernameAlertMessageIsShown) {
            Button("我已知晓", role: .destructive) {
                let state = UsernameValidator.shared.set(username: usernameTextFieldText, context: context)
                switch state {
                case .valid(let userInfo):
                    usernameTextFieldText = userInfo.name
                    usernameTextFieldIdentifier = userInfo.id
                    deleteAllConversations()
                    CryptoHandler.resetKeys()
                case .demoMode(let userInfo):
                    usernameTextFieldText = userInfo.name
                    usernameTextFieldIdentifier = userInfo.id
                    CryptoHandler.resetKeys()
                default:
                    setUsernameTextFieldToStoredValue()
                }
            }
            Button("算了", role: .cancel) {
                setUsernameTextFieldToStoredValue()
            }
        } message: {
            Text("更改用户名将重置Ciallo聊天记录并删除您的所有联系人，小心！")
        }
    }
    
    /// Revert username to what is stored in UserDefaults
    private func setUsernameTextFieldToStoredValue() {
        usernameTextFieldText = UsernameValidator.shared.userInfo?.name ?? ""
        usernameTextFieldIdentifier = UsernameValidator.shared.userInfo?.id ?? ""
    }
    
    /// Delete all conversations (very destructive)
    private func deleteAllConversations() {
        conversations.forEach { conversation in
            context.delete(conversation)
        }
        do {
            try context.save()
        } catch {
            print("删除所有对话后无法保存上下文。")
        }
    }
}
