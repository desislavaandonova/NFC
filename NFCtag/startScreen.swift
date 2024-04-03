import SwiftUI
import UIKit

@main
struct DuckHuntApp: App {
    var body: some Scene {
        WindowGroup {
            StartScreen()
        }
    }
}

struct StartScreen: View {
    var body: some View {
        NavigationView {
            VStack {
                Image("hunt")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .padding()
                Text("Welcome to Duck Hunt!")
                    .font(.title)
                    .padding()
                Text("Tap the ducks to shoot them. You have 3 bullets. When out of bullets, scan an NFC tag to reload.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding()
                NavigationLink(
                    destination: DuckHuntGameView(),
                    label: {
                        Text("Start Game")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    })
            }
            .navigationTitle("Duck Hunt")
        }
    }
}

struct StartScreen_Previews: PreviewProvider {
    static var previews: some View {
        StartScreen()
    }
}


