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
    @State private var bullets = 3
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
                Text("Scan an NFC tag to gain bullets. Tap the ducks to shoot them, each tap consuming one bullet. To reload scan NFC tag. Different tags hold different numbers of bullets. Have fun!")
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
                            .background(Color.teal)
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


