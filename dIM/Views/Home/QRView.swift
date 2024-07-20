//
//  QRScreen.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 29/08/2021.
//
// Original project by KaffeDiem
// Modified by TheodoreEMatt to include Simplified Chinese translation and new icons

import SwiftUI
import CodeScanner
import CoreImage.CIFilterBuiltins

/// The `QRView` gets the users public key in a string format,
/// then generates a QR code and displays it nicely.
struct QRView: View {
    
    /// The colorscheme of the current users device. Used for displaying
    /// different visuals depending on the colorscheme.
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var appSession: AppSession
    
    /// The username fetched from `UserDefaults`
    private let username: String
    
    /// Contect for drawing of the QR code.
    private let context = CIContext()
    /// Filter for drawing the QR code. Built-in function.
    private let filter = CIFilter.qrCodeGenerator()
    
    init() {
        guard let username = UsernameValidator.shared.userInfo?.asString else {
            fatalError("QR view was opened but no username has been set")
        }
        self.username = username
    }
    
    /// Show camera for scanning QR codes.
    @State private var qrCodeScannerIsShown = false
    
    var body: some View {
        VStack {
            
            Spacer()
            
            Text("扫描二维码\nScan the QR Code")
                .font(.title)
                .padding()
            
            ZStack {
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .foregroundColor(.white)
                    .frame(width: 225, height: 225)
                
                /*
                 Show the QR code which can be scanned to add you as a contact.
                 The form of the QR code is:
                 dim://username//publickey
                 */
                Image(uiImage: generateQRCode(from: "dim://\(username)//\(CryptoHandler.fetchPublicKeyString())"))
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200, alignment: .center)
            }
                
            Spacer(minLength: 150)
            
            Text("按下扫描按钮，扫描对方的二维码。\n注意，你们之间需要相互添加。")
                .font(.footnote)
                .foregroundColor(.accentColor)
            
            Button {
                qrCodeScannerIsShown = true
            } label: {
                Text("*点击此处扫描*")
                    .padding()
                    .foregroundColor(.blue)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Asset.dimOrangeDark.swiftUIColor, Asset.dimOrangeLight.swiftUIColor]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(10.0)
            }.sheet(isPresented: $qrCodeScannerIsShown, content: {
                ZStack {
                    CodeScannerView(codeTypes: [.qr], completion: handleScan)
                    VStack {
                        HStack {
                            Spacer()
                            Button {
                                qrCodeScannerIsShown = false
                            } label: {
                                Image(systemName: "xmark")
                                    .foregroundColor(.white)
                                    .imageScale(.large)
                                    .padding()
                            }

                        }
                        Spacer()
                        Text("通过扫描他们的二维码添加新联系人。")
                            .multilineTextAlignment(.center)
                            .font(.footnote)
                            .foregroundColor(.pink)
                            .padding()
                    }
                }
            })
        }
        .padding()
    
        .background(
            Image("bubbleBackground")
                .resizable(resizingMode: .tile)
                .edgesIgnoringSafeArea(.all)
        )
        .navigationBarTitle("添加联系人", displayMode: .inline)
    }
    
    /// Handles the result of the QR scan.
    /// - Parameter result: Result of the QR scan or an error.
    private func handleScan(result: Result<ScanResult, ScanError>) {
        qrCodeScannerIsShown = false
        switch result {
        case .success(let result):
            appSession.addUserFromQrScan(result.string)
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
    
    /// Generates a QR code given some string as an input.
    /// - Parameter string: The string to generate a QR code from. Formatted as dim://username//publickey
    /// - Returns: A UIImage for displaying on the phone.
    private func generateQRCode(from string: String) -> UIImage {
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")

        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}
