//
//  ExplanatoryView.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 19/12/2021.
//
// Original project by KaffeDiem
// Modified by TheodoreEMatt to include Simplified Chinese translation and new icons
import SwiftUI

/// A snapping carousel view used for the onboarding experience for dIM.
///
/// It works as a few slides of short explanatory slides giving users a first
/// impression of what dIM is and how it works.
struct SnapCarousel: View {
    /// UIStateModel keeps track of the active card in the carousel.
    @EnvironmentObject var UIState: CarouselViewModel
    /// Detect if the system is light or dark and update UI accordingly.
    @Environment(\.colorScheme) var colorScheme
    /// Used to open URLS by pressing the *Read More* button.
    @Environment(\.openURL) var openURL
    
    var body: some View {
        let spacing: CGFloat = 16
        let widthOfHiddenCards: CGFloat = 32 /// UIScreen.main.bounds.width - 10
        let cardHeight: CGFloat = 279
        
        let items = [
            Card(id: 0, text: "在离线下发送消息。", image: "appiconsvg"),
            Card(id: 1, text: "通过蓝牙连接，向其他Ciallo用户发送信息。", image: "ExplanatoryMulti"),
            Card(id: 2, text: "使用iPhone摄像头扫描他人的二维码以添加联系人。", image: "ExplanatoryQR"),
            Card(id: 3, text: "您的消息是安全的，除了你和通过端对端的接收者，没有人可以访问你的消息。", image: "ExplanatoryLock"),
            Card(id: 4, text: "因为蓝牙的削弱范围为100米内，因此您必须靠近其他Ciallo用户才可以使用。", image: "ExplanatoryRange"),
            Card(id: 5, text: "", image: "appiconsvg")
        ]
        
        return Canvas {
            Carousel(
                numberOfItems: CGFloat(items.count),
                spacing: spacing,
                widthOfHiddenCards: widthOfHiddenCards
            ) {
                ForEach(items, id: \.self.id) { item in
                    Item(
                        _id: Int(item.id),
                        spacing: spacing,
                        widthOfHiddenCards: widthOfHiddenCards,
                        cardHeight: cardHeight
                    ) {
                        VStack {
                            Spacer()
                            Image(item.image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 128)
                            Spacer()
                            // Show a link on the last slide instead of text.
                            if item.id == items.count - 1 {
                                Button(action: {
                                    openURL(URL(string: "https://dimchat.org")!)
                                }, label: {
                                    Text("点击阅读更多。")
                                        .padding(UIState.activeCard == items.count - 1 ? 10 : 3)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Asset.dimOrangeDark.swiftUIColor, Asset.dimOrangeLight.swiftUIColor]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(10.0)
                                })
                            } else { // Show the corresponding text to the image of this card.
                                Text("\(item.text)")
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(20)
                    }
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    .background(colorScheme == .dark ? Asset.greyDark.swiftUIColor : Asset.greyLight.swiftUIColor)
                    .cornerRadius(20)
                    .transition(AnyTransition.slide)
                    .animation(.spring())
                }
            }
        }
    }
}

/// A card is an item in the carousel.
fileprivate struct Card: Decodable, Hashable, Identifiable {
    /// The id of the card which determines placement in the carousel.
    var id: Int
    /// The text to show the end user for this card.
    var text: String = ""
    /// The image to show the end user (links to asset)
    var image: String
}


/// Keeps track of the carousel view
public class CarouselViewModel: ObservableObject {
    @Published var activeCard: Int = 0
    /// Amount of drag from user input
    @Published var screenDrag: Float = 0.0
}

/// The actual carousel struct which handles the logic of the carousel.
/// - Note: Dive in to the code to see how this works.
fileprivate struct Carousel<Items : View> : View {
    let items: Items
    let numberOfItems: CGFloat //= 8
    let spacing: CGFloat //= 16
    let widthOfHiddenCards: CGFloat //= 32
    let totalSpacing: CGFloat
    let cardWidth: CGFloat
    
    @GestureState var isDetectingLongPress = false
    
    @EnvironmentObject var UIState: CarouselViewModel
        
    @inlinable public init(
        numberOfItems: CGFloat,
        spacing: CGFloat,
        widthOfHiddenCards: CGFloat,
        @ViewBuilder _ items: () -> Items) {
        
        self.items = items()
        self.numberOfItems = numberOfItems
        self.spacing = spacing
        self.widthOfHiddenCards = widthOfHiddenCards
        self.totalSpacing = (numberOfItems - 1) * spacing
        self.cardWidth = UIScreen.main.bounds.width - (widthOfHiddenCards*2) - (spacing*2) //279
    }
    
    var body: some View {
        let totalCanvasWidth: CGFloat = (cardWidth * numberOfItems) + totalSpacing
        let xOffsetToShift = (totalCanvasWidth - UIScreen.main.bounds.width) / 2
        let leftPadding = widthOfHiddenCards + spacing
        let totalMovement = cardWidth + spacing
                
        let activeOffset = xOffsetToShift + (leftPadding) - (totalMovement * CGFloat(UIState.activeCard))
        let nextOffset = xOffsetToShift + (leftPadding) - (totalMovement * CGFloat(UIState.activeCard) + 1)

        var calcOffset = Float(activeOffset)
        
        if (calcOffset != Float(nextOffset)) {
            calcOffset = Float(activeOffset) + UIState.screenDrag
        }
        
        return HStack(alignment: .center, spacing: spacing) {
            items
        }
        .offset(x: CGFloat(calcOffset), y: 0)
        .gesture(DragGesture().updating($isDetectingLongPress) { currentState, gestureState, transaction in
            self.UIState.screenDrag = Float(currentState.translation.width)
            
        }.onEnded { value in
            self.UIState.screenDrag = 0
            
            if (value.translation.width < -50 && CGFloat(self.UIState.activeCard) < numberOfItems - 1) {
                self.UIState.activeCard = self.UIState.activeCard + 1
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
            }
            
            if  (value.translation.width > 50 && CGFloat(self.UIState.activeCard) > 0) {
                self.UIState.activeCard = self.UIState.activeCard - 1
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
            }
        })
    }
}

fileprivate struct Canvas<Content : View> : View {
    let content: Content
    @EnvironmentObject var UIState: CarouselViewModel
    
    @inlinable init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
    }
}

fileprivate struct Item<Content: View>: View {
    @EnvironmentObject var UIState: CarouselViewModel
    let cardWidth: CGFloat
    let cardHeight: CGFloat

    var _id: Int
    var content: Content

    @inlinable public init(
        _id: Int,
        spacing: CGFloat,
        widthOfHiddenCards: CGFloat,
        cardHeight: CGFloat,
        @ViewBuilder _ content: () -> Content
    ) {
        self.content = content()
        self.cardWidth = UIScreen.main.bounds.width - (widthOfHiddenCards*2) - (spacing*2) //279
        self.cardHeight = cardHeight
        self._id = _id
    }

    var body: some View {
        content
            .frame(width: cardWidth, height: _id == UIState.activeCard ? cardHeight : cardHeight - 80, alignment: .center)
    }
}
