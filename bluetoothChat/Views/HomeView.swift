//
//  HomeView.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/08/2021.
//

import CoreData
import SwiftUI

/// The `HomeView` where users are presented with the different conversations that they are in.
/// It is also here that we redirect them to other pages, let it be the `ChatView` or the `SettingsView`.
struct HomeView: View {
    
    /// Context of the `CoreData` for persistent storage.
    @Environment(\.managedObjectContext) var context
    
    /**
     Initialize the ChatBrain which handles logic of Bluetooth
     and sending / receiving messages.
     */
    @StateObject var chatBrain: ChatBrain
    
    /**
     Get conversations saved to Core Data
     */
    @FetchRequest(
        entity: ConversationEntity.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \ConversationEntity.author, ascending: true)
        ]
    ) var conversations: FetchedResults<ConversationEntity>
    
    /**
     Used for confirmation dialog when deleting a contact.
     */
    @State var confirmationShown: Bool = false
    
    /**
     The actual body of the HomeView.
     */
    var body: some View {
        
        VStack {
            if !conversationsIsEmpty() {
                /*
                 List all added users and their conversations.
                 */
                List(conversations) { conversation in
                    NavigationLink(
                        destination: ChatView(conversation: conversation)
                            .environmentObject(chatBrain),
                        label: {
                            VStack {
                                Text(getSafeAuthor(conversation: conversation))
                                    .foregroundColor(.accentColor)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Text(conversation.lastMessage ?? "Start a new conversation.")
                                    .scaledToFit()
                                    .font(.footnote)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding()
                        })
                    /*
                     Swipe Actions are activated when swiping left on the conversation thread.
                     */
                        .swipeActions {
                            // Clearing a conversation.
                            Button {
                                conversation.removeFromMessages(conversation.messages!)
                                conversation.lastMessage = "Start a new conversation."
                                do {
                                    try context.save()
                                } catch {
                                    print("Context could not be saved.")
                                }
                            } label: {
                                Label("Clear Conversation", systemImage: "exclamationmark.bubble.fill")
                            }
                            .tint(.accentColor)
                            // Deleting a contact.
                            Button(role: .destructive, action: {confirmationShown = true}) {
                                Label("Delete Contact", systemImage: "person.fill.xmark")
                            }
                        }
                        .confirmationDialog(
                            "Are you sure?",
                            isPresented: $confirmationShown
                        ) {
                            Button("Delete Contact", role: .destructive) {
                                withAnimation {
                                    context.delete(conversation)
                                    do {
                                        try context.save()
                                    } catch {
                                        print("Context could not be saved.")
                                    }
                                }
                            }
                        }
                }
            } else {
                Image("QRHowTo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 192, alignment: .center)
                    .padding()
                Text("Add a new contact by scanning their QR code with your phones camera and by letting them scan yours.")
                    .padding()
            }
        }
        .navigationTitle("Chat")
        
        .onAppear() {
        }
        
        /*
         Toolbar in the navigation header for SettingsView and ChatView.
         */
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink(destination: SettingsView().environmentObject(chatBrain), label: {
                    Image(systemName: "gearshape.fill")
                })
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: QRView(), label: {
                    Image(systemName: "qrcode")
                })
            }
        }
    }
    
    /// As usernames gets a random 4 digit number added to them, which we do not want
    /// to present, we use this function to only get the actual username of the user.
    ///
    /// If it fails for some reason (most likely wrong formatting) we simply show
    /// "Unknown".
    /// - Parameter conversation: The conversation for which we want to get the username.
    /// - Returns: A string with only the username, where the 4 last digits are removed.
    func getSafeAuthor(conversation: ConversationEntity) -> String {
        if let safeAuthor = conversation.author {
            return safeAuthor.components(separatedBy: "#").first ?? "Unknown"
        }
        return "Unknown"
    }
    
    /// Checks if a conversation has no sent messages.
    ///
    /// It is used to show another text in the `recent` messages part.
    /// - Returns: A boolean confirming if the conversation has messages in it or not.
    func conversationsIsEmpty() -> Bool {
        do {
            let request: NSFetchRequest<ConversationEntity>
            request = ConversationEntity.fetchRequest()
            
            let count = try context.count(for: request)
            return count == 0
        } catch {
            return true
        }
    }
}
