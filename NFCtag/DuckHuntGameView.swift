import SwiftUI
import CoreNFC

struct ScanNFCButton: View {
    @StateObject var nfcReader = NFCReader()
    @Binding var bullets: Int
    
    var body: some View {
        Button(action: {
            nfcReader.beginSession()
        }) {
            HStack {
                Image(systemName: "wave.3.right")
                    .foregroundColor(.white)
                Text("Scan NFC tag to reload")
                    .foregroundColor(.white)
            }
            .font(.headline)
            .padding(10)
            .background(Color.blue)
            .cornerRadius(10)
        }
        .padding(.top)
        .padding(.trailing)
        .onReceive(nfcReader.$message) { message in
            if message != "Scan a tag" {
                print("NFC Tag read: \(message)")
                // the tag content is the number of bullets to be added
                if let bulletsToAdd = Int(message) {
                    DispatchQueue.main.async {
                        addBullets(bulletsToAdd)
                    }
                }
            }
        }
    }
    
    func addBullets(_ bulletsToAdd: Int) {
        bullets += bulletsToAdd
    }
}

struct DuckHuntGameView: View {
    @State private var ducks = [Duck]()
    @State private var gameIsOver = false
    @State private var timeRemaining = 30 // 30 seconds for testing
    @State private var score = 0
    @State private var bullets = 0
    @StateObject private var nfcReader = NFCReader()

    var body: some View {
        Group {
            if gameIsOver {
                GameOverView(score: score, replayAction: replayGame)
                    .foregroundColor(.teal)
                    .font(.title)
                    .padding()
                    .textCase(.uppercase)
                    .fontWeight(.bold)
            } else {
                VStack {
                    ZStack {
                        ZStack {
                            Color(UIColor.systemTeal)
                            ForEach(ducks) { duck in
                                if !gameIsOver {
                                    DuckView(duck: duck)
                                        .onTapGesture {
                                            if bullets > 0 { // check if there are bullets left
                                                bullets -= 1 // consume one bullet
                                                
                                                if let index = ducks.firstIndex(where: { $0.id == duck.id }) {
                                                    score += 10
                                                    ducks.remove(at: index)
                                                    if ducks.isEmpty {
                                                        endGame()
                                                    }
                                                }
                                            }
                                        }
                                }
                            }
                        }
                        
                        VStack {
                            Spacer()
                            
                            HStack {
                                Spacer()
                                Text("\(timeRemaining) seconds left")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(Color.black.opacity(0.5))
                                    .cornerRadius(10)
                                
                                Spacer()
                                Text("Score: \(score)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(Color.black.opacity(0.5))
                                    .cornerRadius(10)
                                
                                Spacer()
                                
                                Text("Bullets: \(bullets)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(Color.black.opacity(0.5))
                                    .cornerRadius(10)
                                
                                Spacer()
                            }
                            .padding()
                        }
                    }
                    .edgesIgnoringSafeArea(.top)
                    .onAppear(perform: startGame)
                    .onReceive(timer) { _ in
                        if timeRemaining > 0 {
                            timeRemaining -= 1
                            if timeRemaining == 0 {
                                endGame()
                            }
                        }
                    }
                    .background(Color(UIColor.systemTeal).ignoresSafeArea())
                }
                .overlay(
                    VStack {
                        HStack {
                            Spacer()
                            ScanNFCButton(bullets: $bullets)
                                .padding(.top, -20)
                                .padding(.trailing, 0)
                        }
                        Spacer()
                    }
                )
            }}}
    
    // start the game by spawning ducks
    func startGame() {
        ducks.removeAll() // clear leftover ducks from the previous game
        bullets = 0 // reset bullets count
        // generate 12 ducks
        for _ in 0..<12 {
            spawnDuck()
        }
    }
    
    // spawn duck at a random position
    func spawnDuck() {
        let duck = Duck(position: randomPosition())
        ducks.append(duck)
        
        // move the duck randomly
        withAnimation(Animation.linear(duration: 3).repeatForever(autoreverses: true)) {
            ducks[ducks.count - 1].position = randomPosition()
        }
    }
    
    // generate a random position within the screen
    func randomPosition() -> CGPoint {
        return CGPoint(x: CGFloat.random(in: 0..<UIScreen.main.bounds.width),
                       y: CGFloat.random(in: 0..<UIScreen.main.bounds.height))
    }
    
    // timer for duration
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // end the game
    func endGame() {
        gameIsOver = true
    }
    
    // func to replay the game
    func replayGame() {
        gameIsOver = false
        timeRemaining = 30
        score = 0
        startGame()
    }
}

struct Duck: Identifiable {
    let id = UUID()
    var position: CGPoint
}

struct DuckView: View {
    var duck: Duck
    
    var body: some View {
        Image("ducks")
            .resizable()
            .frame(width: 100, height: 100)
            .position(duck.position)
    }
}
//game over screen
struct GameOverView: View {
    var score: Int
    var replayAction: () -> Void
    
    var body: some View {
         VStack {
             Text("GAME OVER")
                 .padding()
                 .font(.largeTitle)
                 .foregroundColor(.teal)
                 .textCase(.uppercase)
                 .fontWeight(.bold)
             
             Text("Final Score: \(score)")
                 .font(.headline)
                 .padding()
                 .foregroundColor(.black)
             
             Button(action: {
                 replayAction()
             }) {
                 HStack {
                     Image(systemName: "arrow.clockwise")
                         .foregroundColor(.white)
                     Text("Replay")
                         .font(.headline)
                         .foregroundColor(.white)
                 }
                 .padding()
                 .background(Color.teal)
                 .cornerRadius(10)
             }
             .padding()
             
             Spacer()
         }
     }
 }

class NFCReader: NSObject, ObservableObject, NFCNDEFReaderSessionDelegate {
    var nfcSession: NFCNDEFReaderSession?
    @Published var message: String = "Scan a tag"

    func beginSession() {
        nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        nfcSession?.alertMessage = "Hold your iPhone near the NFC tag."
        nfcSession?.begin()
    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        DispatchQueue.main.async {
            self.message = "Session invalidated: \(error.localizedDescription)"
        }
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        guard let ndefMessage = messages.first else { return }
        var result = ""
        var count = 0
        for record in ndefMessage.records {
            if let string = String(data: record.payload.advanced(by: 3), encoding: .utf8) {
                count += 1
                result += "\(string)"
            }
        }
        DispatchQueue.main.async {
            self.message = result.isEmpty ? "Tag read, but no valid text found." : result
        }
    }
}
