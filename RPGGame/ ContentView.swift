import SwiftUI

struct ContentView: View {
    @StateObject private var gameManager = GameManager()
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.purple.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                switch gameManager.gameState {
                case .mainMenu:
                    MainMenuView(gameManager: gameManager)
                case .village:
                    VillageView(gameManager: gameManager)
                case .forest:
                    ForestView(gameManager: gameManager)
                case .dungeon:
                    DungeonView(gameManager: gameManager)
                case .tower:
                    TowerView(gameManager: gameManager)
                case .battle:
                    BattleView(gameManager: gameManager)
                case .gameOver:
                    GameOverView(gameManager: gameManager)
                case .victory:
                    VictoryView(gameManager: gameManager)
                }
            }
        }
    }
}

// MARK: - Main Menu View

struct MainMenuView: View {
    @ObservedObject var gameManager: GameManager
    @State private var playerName = ""
    @State private var selectedClass: CharacterClass = .warrior
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 10) {
                Text("EPIC RPG QUEST")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.cyan)
                Text("Adventure Awaits")
                    .font(.title3)
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Character Name")
                    .foregroundColor(.cyan)
                    .font(.headline)
                TextField("Enter your name", text: $playerName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
            }
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Select Class")
                    .foregroundColor(.cyan)
                    .font(.headline)
                
                Picker("Class", selection: $selectedClass) {
                    ForEach(CharacterClass.allCases, id: \.self) { characterClass in
                        let stats = characterClass.baseStats
                        Text("\(characterClass.rawValue) (HP:\(stats.maxHP) ATK:\(stats.attack))")
                            .tag(characterClass)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
            }
            
            Button(action: {
                if !playerName.isEmpty {
                    gameManager.createCharacter(name: playerName, characterClass: selectedClass)
                }
            }) {
                Text("START ADVENTURE")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(LinearGradient(
                        gradient: Gradient(colors: [.purple, .blue]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .disabled(playerName.isEmpty)
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Village View

struct VillageView: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        VStack {
            if let player = gameManager.player {
                PlayerStatusBar(player: player)
                
                VStack(spacing: 15) {
                    Text("🏘️ VILLAGE")
                        .font(.title)
                        .foregroundColor(.cyan)
                    Text("A peaceful place to rest")
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    NavigationButton(title: "⚔️ Explore", color: .red) {
                        gameManager.explore()
                    }
                    
                    NavigationButton(title: "🏨 Inn (Heal)", color: .green) {
                        if gameManager.player?.gold ?? 0 >= 10 {
                            gameManager.player?.heal(gameManager.player?.maxHP ?? 100)
                            gameManager.player?.gold -= 10
                        }
                    }
                    
                    NavigationButton(title: "🌲 Go to Forest", color: .blue) {
                        gameManager.gameState = .forest
                    }
                    
                    NavigationButton(title: "🏰 Go to Dungeon", color: .orange) {
                        gameManager.gameState = .dungeon
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $gameManager.showBattleView) {
            BattleView(gameManager: gameManager)
        }
    }
}

// MARK: - Forest View

struct ForestView: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        VStack {
            if let player = gameManager.player {
                PlayerStatusBar(player: player)
                
                VStack(spacing: 15) {
                    Text("🌲 FOREST")
                        .font(.title)
                        .foregroundColor(.green)
                    Text("Dark and mysterious")
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    NavigationButton(title: "🔍 Explore", color: .red) {
                        gameManager.explore()
                    }
                    
                    NavigationButton(title: "← Return to Village", color: .blue) {
                        gameManager.gameState = .village
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $gameManager.showBattleView) {
            BattleView(gameManager: gameManager)
        }
    }
}

// MARK: - Dungeon View

struct DungeonView: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        VStack {
            if let player = gameManager.player {
                PlayerStatusBar(player: player)
                
                VStack(spacing: 15) {
                    Text("🏰 DUNGEON")
                        .font(.title)
                        .foregroundColor(.red)
                    Text("Dangerous depths")
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    NavigationButton(title: "💀 Explore", color: .red) {
                        gameManager.explore()
                    }
                    
                    NavigationButton(title: "🗼 Go to Tower", color: .purple) {
                        gameManager.gameState = .tower
                    }
                    
                    NavigationButton(title: "← Return to Village", color: .blue) {
                        gameManager.gameState = .village
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $gameManager.showBattleView) {
            BattleView(gameManager: gameManager)
        }
    }
}

// MARK: - Tower View

struct TowerView: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        VStack {
            if let player = gameManager.player {
                PlayerStatusBar(player: player)
                
                VStack(spacing: 15) {
                    Text("🗼 TOWER")
                        .font(.title)
                        .foregroundColor(.yellow)
                    Text("The final challenge")
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    NavigationButton(title: "🐉 Face the Dragon", color: .red) {
                        gameManager.currentEnemy = Enemy(
                            name: "Ancient Dragon",
                            hp: 100,
                            attack: 22,
                            defense: 12,
                            experience: 150,
                            loot: Item(name: "Dragon Amulet", type: .quest, value: 100)
                        )
                        gameManager.gameState = .battle
                        gameManager.showBattleView = true
                    }
                    
                    NavigationButton(title: "← Return to Dungeon", color: .blue) {
                        gameManager.gameState = .dungeon
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $gameManager.showBattleView) {
            BattleView(gameManager: gameManager)
        }
    }
}

// MARK: - Battle View

struct BattleView: View {
    @ObservedObject var gameManager: GameManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                }
                Spacer()
                Text("⚔️ BATTLE")
                    .font(.headline)
                    .foregroundColor(.cyan)
                Spacer()
            }
            .padding()
            .background(Color.black.opacity(0.7))
            
            if let player = gameManager.player, let enemy = gameManager.currentEnemy {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(gameManager.battleLog, id: \.self) { log in
                            Text(log)
                                .foregroundColor(.white)
                                .font(.caption)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                
                VStack(spacing: 10) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(player.name)
                                .font(.headline)
                                .foregroundColor(.cyan)
                            ProgressView(value: Double(player.currentHP) / Double(player.maxHP))
                                .tint(.green)
                            Text("HP: \(player.currentHP)/\(player.maxHP)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text(enemy.name)
                                .font(.headline)
                                .foregroundColor(.red)
                            ProgressView(value: Double(enemy.hp) / Double(enemy.maxHP))
                                .tint(.red)
                            Text("HP: \(enemy.hp)/\(enemy.maxHP)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    
                    if player.isAlive && enemy.isAlive {
                        HStack(spacing: 10) {
                            BattleButton(title: "⚔️ Attack", color: .red) {
                                gameManager.playerAttack()
                            }
                            BattleButton(title: "✨ Magic", color: .purple) {
                                gameManager.playerMagic()
                            }
                            BattleButton(title: "💚 Heal", color: .green) {
                                gameManager.playerHeal()
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .background(LinearGradient(
            gradient: Gradient(colors: [Color.black, Color.purple.opacity(0.2)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ))
    }
}

// MARK: - Game Over View

struct GameOverView: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 10) {
                Text("💀")
                    .font(.system(size: 60))
                Text("GAME OVER")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.red)
                Text("You were defeated...")
                    .foregroundColor(.gray)
            }
            
            if let player = gameManager.player {
                VStack(alignment: .leading, spacing: 10) {
                    StatLine(label: "Level Reached", value: "\(player.level)")
                    StatLine(label: "Experience", value: "\(player.experience)")
                    StatLine(label: "Gold Collected", value: "\(player.gold)")
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            }
            
            Spacer()
            
            Button(action: { gameManager.resetGame() }) {
                Text("TRY AGAIN")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }
}

// MARK: - Victory View

struct VictoryView: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 10) {
                Text("🎉")
                    .font(.system(size: 60))
                Text("YOU WIN!")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.yellow)
                Text("You defeated the Ancient Dragon!")
                    .foregroundColor(.gray)
            }
            
            if let player = gameManager.player {
                VStack(alignment: .leading, spacing: 10) {
                    StatLine(label: "Final Level", value: "\(player.level)")
                    StatLine(label: "Experience", value: "\(player.experience)")
                    StatLine(label: "Gold Collected", value: "\(player.gold)")
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            }
            
            Spacer()
            
            Button(action: { gameManager.resetGame() }) {
                Text("PLAY AGAIN")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }
}

// MARK: - Helper Views

struct PlayerStatusBar: View {
    @ObservedObject var player: Player
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(player.name)
                        .font(.headline)
                        .foregroundColor(.cyan)
                    Text("Lvl \(player.level) \(player.characterClass.rawValue)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 3) {
                    Text("💰 \(player.gold)")
                        .foregroundColor(.yellow)
                    Text("EXP: \(player.experience)/\(100 * player.level)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("HP")
                        .foregroundColor(.white)
                    ProgressView(value: Double(player.currentHP) / Double(player.maxHP))
                        .tint(.green)
                    Text("\(player.currentHP)/\(player.maxHP)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .padding()
    }
}

struct NavigationButton: View {
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(LinearGradient(
                    gradient: Gradient(colors: [color, color.opacity(0.7)]),
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .cornerRadius(10)
        }
    }
}

struct BattleButton: View {
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(color)
                .cornerRadius(8)
        }
    }
}

struct StatLine: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .foregroundColor(.cyan)
                .fontWeight(.bold)
        }
    }
}

#Preview {
    ContentView()
}
