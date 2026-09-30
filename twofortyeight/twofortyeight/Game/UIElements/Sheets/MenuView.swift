import SwiftUI

struct MenuView: View {
    let newGameAction: () -> ()
    let resetScoreAction: () -> ()
    private let resources = MenuResources.current
    @State private var showConfirmation = false

    private var tokens: MenuTokens { resources.tokens }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 0) {
                    VStack(spacing: 8) {
                        Text(tokens.brand)
                            .font(.system(size: tokens.brandSize, weight: .bold, design: .rounded))
                            .tracking(3)
                            .accessibilityIdentifier("menuBrand")
                        Text(tokens.title)
                            .font(.system(size: tokens.titleSize, weight: .black, design: .rounded))
                            .accessibilityIdentifier("menuTitle")
                    }
                    .padding(.top, 64)
                    Spacer(minLength: 24)
                    Text(tokens.hint)
                        .font(.system(size: tokens.hintSize, design: .rounded))
                        .foregroundColor(tokens.muted.color)
                        .padding(.bottom, 32)
                        .accessibilityIdentifier("menuHint")
                }
                .padding(.horizontal, tokens.sideInset)

                VStack(spacing: 0) {
                    Spacer(minLength: 24)
                    VStack(spacing: tokens.buttonGap) {
                        menuButton(tokens.newGame, artwork: resources.primary,
                                   width: min(tokens.buttonMaxWidth, geometry.size.width - 2 * tokens.sideInset),
                                   identifier: "newGameButton", action: newGameAction)
                        menuButton(tokens.resetBestScore, artwork: resources.secondary,
                                   width: min(tokens.buttonMaxWidth, geometry.size.width - 2 * tokens.sideInset),
                                   identifier: "resetBestScoreButton") { self.showConfirmation.toggle() }
                    }
                    Spacer(minLength: 24)
                }
                .offset(y: 8)
            }
            .foregroundColor(tokens.text.color)
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .background(tokens.background.color.edgesIgnoringSafeArea(.all))
        .alert(isPresented: $showConfirmation) { confirmationAlert }
    }

    private func menuButton(_ title: String, artwork: UIImage, width: CGFloat,
                            identifier: String, action: @escaping () -> ()) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: tokens.buttonTextSize, weight: .bold, design: .rounded))
                .frame(width: width, height: tokens.buttonHeight)
                .background(Image(uiImage: artwork)
                    .resizable(capInsets: tokens.buttonCapInsets.edges, resizingMode: .stretch)
                    .accessibilityHidden(true))
                .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityIdentifier(identifier)
    }
}

extension MenuView {
    private var confirmationAlert: Alert {
        Alert(title: confirmationMessage,
              primaryButton: resetScoreAlertButton,
              secondaryButton: .cancel())
    }
    
    private var confirmationMessage: Text {
        Text("Are you sure you want to erase your best score?")
    }
    
    private var resetScoreAlertButton: Alert.Button {
        .default(Text("Yeah, whatever"), action: self.resetScoreAction)
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MenuView(newGameAction:{}){}
        }
    }
}
