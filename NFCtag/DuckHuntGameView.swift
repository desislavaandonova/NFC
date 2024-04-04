import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: DuckHuntGameView()) {
                    Text("Start Game")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Duck Hunt")
            .background(Color(UIColor.systemTeal).ignoresSafeArea())
        }
    }
}

struct DuckHuntGameView: View {
    @State private var ducks = [Duck]()
    @State private var gameIsOver = false
    @State private var timeRemaining = 10 // 10 seconds for testing
    @State private var score = 0
    @State private var bullets = 3 // maximum number of bullets
    
    var body: some View {
        Group {
            if gameIsOver {
                GameOverView(score: score, replayAction: replayGame)
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
            }
        }
    }
    
    // start the game by spawning ducks
    func startGame() {
        ducks.removeAll() // clear leftoover ducks from previous game
        bullets = 3 // reset bullets count
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
        timeRemaining = 10
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

struct GameOverView: View {
    var score: Int
    var replayAction: () -> Void
    
    var body: some View {
        VStack {
            Text("Game Over")
                .font(.title)
                .foregroundColor(.red)
                .padding()
            
            Text("Final Score: \(score)")
                .font(.headline)
                .foregroundColor(.black)
                .padding()
            
            Button(action: {
                replayAction()
            }) {
                Text("Replay")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
            
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
