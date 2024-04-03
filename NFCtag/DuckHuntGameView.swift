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
        }
    }
}

struct DuckHuntGameView: View {
    @State private var ducks = [Duck]()
    @State private var gameIsOver = false
    @State private var timeRemaining = 10
    @State private var score = 0
    
    var body: some View {
        Group {
            if gameIsOver {
                GameOverView(score: score, replayAction: replayGame)
            } else {
                VStack {
                    ZStack {
                        Color(UIColor.systemTeal)
                        ForEach(ducks) { duck in
                            if !gameIsOver {
                                DuckView(duck: duck)
                                    .onTapGesture {
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
                .navigationBarItems(
                    leading:
                        HStack {
                            Text("\(timeRemaining) seconds left")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.black.opacity(0.5))
                                .cornerRadius(10)
                                .padding()
                        },
                    trailing:
                        HStack {
                            Text("Score: \(score)")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.black.opacity(0.5))
                                .cornerRadius(10)
                                .padding()
                        }
                )
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
            }
        }
    }

    func startGame() {
        ducks.removeAll()
        for _ in 0..<12 {
            spawnDuck()
        }
    }
 
    func spawnDuck() {
        let duck = Duck(position: randomPosition())
        ducks.append(duck)
        
        withAnimation(Animation.linear(duration: 3).repeatForever(autoreverses: true)) {
            ducks[ducks.count - 1].position = randomPosition()
        }
    }
    
    func randomPosition() -> CGPoint {
        return CGPoint(x: CGFloat.random(in: 0..<UIScreen.main.bounds.width),
                       y: CGFloat.random(in: 0..<UIScreen.main.bounds.height))
    }
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    func endGame() {
        gameIsOver = true
    }
    
    func replayGame() {
        gameIsOver = false
        timeRemaining = 10
        score = 0
        ducks.removeAll()
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
