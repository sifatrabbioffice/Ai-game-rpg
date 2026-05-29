import Foundation

// MARK: - Models

enum CharacterClass: String, Codable, CaseIterable {
    case warrior = "Warrior"
    case mage = "Mage"
    case rogue = "Rogue"
    case paladin = "Paladin"
    
    var baseStats: CharacterStats {
        switch self {
        case .warrior:
            return CharacterStats(maxHP: 100, attack: 15, defense: 8, magic: 3)
        case .mage:
            return CharacterStats(maxHP: 60, attack: 8, defense: 3, magic: 18)
        case .rogue:
            return CharacterStats(maxHP: 75, attack: 16, defense: 5, magic: 10)
        case .paladin:
            return CharacterStats(maxHP: 90, attack: 12, defense: 12, magic: 12)
        }
    }
}

struct CharacterStats: Codable {
    var maxHP: Int
    var attack: Int
    var defense: Int
    var magic: Int
}

struct Item: Identifiable, Codable {
    let id = UUID()
    let name: String
    let type: ItemType
    let value: Int
    
    enum ItemType: String, Codable {
        case weapon, armor, potion, quest
    }
}

class Player: ObservableObject, Codable {
    @Published var name: String
    @Published var characterClass: CharacterClass
    @Published var level: Int = 1
    @Published var currentHP: Int
    @Published var maxHP: Int
    @Published var attack: Int
    @Published var defense: Int
    @Published var magic: Int
    @Published var experience: Int = 0
    @Published var gold: Int = 50
    @Published var inventory: [Item] = []
    @Published var currentLocation: String = "Village"
    
    enum CodingKeys: String, CodingKey {
        case name, characterClass, level, currentHP, maxHP
        case attack, defense, magic, experience, gold, inventory, currentLocation
    }
    
    init(name: String, characterClass: CharacterClass) {
        self.name = name
        self.characterClass = characterClass
        let baseStats = characterClass.baseStats
        self.maxHP = baseStats.maxHP
        self.currentHP = baseStats.maxHP
        self.attack = baseStats.attack
        self.defense = baseStats.defense
        self.magic = baseStats.magic
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        characterClass = try container.decode(CharacterClass.self, forKey: .characterClass)
        level = try container.decode(Int.self, forKey: .level)
        currentHP = try container.decode(Int.self, forKey: .currentHP)
        maxHP = try container.decode(Int.self, forKey: .maxHP)
        attack = try container.decode(Int.self, forKey: .attack)
        defense = try container.decode(Int.self, forKey: .defense)
        magic = try container.decode(Int.self, forKey: .magic)
        experience = try container.decode(Int.self, forKey: .experience)
        gold = try container.decode(Int.self, forKey: .gold)
        inventory = try container.decode([Item].self, forKey: .inventory)
        currentLocation = try container.decode(String.self, forKey: .currentLocation)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(characterClass, forKey: .characterClass)
        try container.encode(level, forKey: .level)
        try container.encode(currentHP, forKey: .currentHP)
        try container.encode(maxHP, forKey: .maxHP)
        try container.encode(attack, forKey: .attack)
        try container.encode(defense, forKey: .defense)
        try container.encode(magic, forKey: .magic)
        try container.encode(experience, forKey: .experience)
        try container.encode(gold, forKey: .gold)
        try container.encode(inventory, forKey: .inventory)
        try container.encode(currentLocation, forKey: .currentLocation)
    }
    
    func takeDamage(_ damage: Int) -> Int {
        let actualDamage = max(1, damage - defense)
        currentHP = max(0, currentHP - actualDamage)
        return actualDamage
    }
    
    func heal(_ amount: Int) {
        currentHP = min(maxHP, currentHP + amount)
    }
    
    func gainExperience(_ amount: Int) {
        experience += amount
        let expNeeded = 100 * level
        if experience >= expNeeded {
            levelUp()
        }
    }
    
    func levelUp() {
        level += 1
        maxHP += 20
        currentHP = maxHP
        attack += 3
        defense += 2
        magic += 2
    }
    
    func addItem(_ item: Item) {
        DispatchQueue.main.async {
            self.inventory.append(item)
        }
    }
    
    var isAlive: Bool {
        currentHP > 0
    }
}

class Enemy: Codable {
    let name: String
    var hp: Int
    let maxHP: Int
    let attack: Int
    let defense: Int
    let experience: Int
    let loot: Item
    
    init(name: String, hp: Int, attack: Int, defense: Int, experience: Int, loot: Item) {
        self.name = name
        self.hp = hp
        self.maxHP = hp
        self.attack = attack
        self.defense = defense
        self.experience = experience
        self.loot = loot
    }
    
    func takeDamage(_ damage: Int) -> Int {
        let actualDamage = max(1, damage - defense)
        hp -= actualDamage
        return actualDamage
    }
    
    var isAlive: Bool {
        hp > 0
    }
}

// MARK: - Game Manager

class GameManager: ObservableObject {
    @Published var player: Player?
    @Published var currentEnemy: Enemy?
    @Published var gameState: GameState = .mainMenu
    @Published var battleLog: [String] = []
    @Published var showBattleView = false
    
    enum GameState {
        case mainMenu
        case village
        case forest
        case dungeon
        case tower
        case battle
        case gameOver
        case victory
    }
    
    private let enemies: [String: (Int, Int, Int, Int, Item)] = [
        "Goblin": (25, 8, 2, 20, Item(name: "Rusty Dagger", type: .weapon, value: 5)),
        "Orc": (40, 12, 4, 35, Item(name: "Iron Sword", type: .weapon, value: 15)),
        "Skeleton": (35, 10, 3, 30, Item(name: "Bone Staff", type: .weapon, value: 10)),
        "Troll": (60, 14, 6, 50, Item(name: "Troll Hammer", type: .weapon, value: 20)),
    ]
    
    func createCharacter(name: String, characterClass: CharacterClass) {
        player = Player(name: name, characterClass: characterClass)
        gameState = .village
    }
    
    func explore() {
        guard let player = player else { return }
        
        if Bool.random() {
            let enemyNames = Array(enemies.keys)
            let selectedEnemyName = enemyNames.randomElement() ?? "Goblin"
            let (hp, atk, def, exp, loot) = enemies[selectedEnemyName]!
            currentEnemy = Enemy(name: selectedEnemyName, hp: hp, attack: atk, defense: def, experience: exp, loot: loot)
            gameState = .battle
            showBattleView = true
            battleLog.removeAll()
            battleLog.append("A wild \(selectedEnemyName) appears!")
        } else {
            let gold = Int.random(in: 10...30)
            player.gold += gold
            battleLog.append("You found \(gold) gold!")
        }
    }
    
    func playerAttack() {
        guard let player = player, let enemy = currentEnemy else { return }
        
        let baseDamage = Int.random(in: (player.attack - 3)...(player.attack + 3))
        let damage = enemy.takeDamage(baseDamage)
        battleLog.append("You dealt \(damage) damage!")
        
        if !enemy.isAlive {
            endBattle()
            return
        }
        
        enemyTurn()
    }
    
    func playerMagic() {
        guard let player = player, let enemy = currentEnemy else { return }
        
        if player.magic < 5 {
            battleLog.append("Not enough magic power!")
            return
        }
        
        let damage = enemy.takeDamage(Int.random(in: player.magic...(player.magic + 5)))
        battleLog.append("Magic spell deals \(damage) damage!")
        
        if !enemy.isAlive {
            endBattle()
            return
        }
        
        enemyTurn()
    }
    
    func playerHeal() {
        guard let player = player else { return }
        player.heal(25)
        battleLog.append("You heal 25 HP! Current HP: \(player.currentHP)")
        enemyTurn()
    }
    
    private func enemyTurn() {
        guard let player = player, let enemy = currentEnemy else { return }
        
        let damage = player.takeDamage(Int.random(in: max(1, enemy.attack - 2)...(enemy.attack + 2)))
        battleLog.append("\(enemy.name) dealt \(damage) damage!")
        
        if !player.isAlive {
            gameState = .gameOver
            showBattleView = false
        }
    }
    
    private func endBattle() {
        guard let player = player, let enemy = currentEnemy else { return }
        
        battleLog.append("✨ Victory! You defeated \(enemy.name)!")
        player.gainExperience(enemy.experience)
        player.gold += enemy.loot.value
        player.addItem(enemy.loot)
        battleLog.append("Gained \(enemy.experience) EXP and \(enemy.loot.value) gold!")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.showBattleView = false
            self.gameState = .village
        }
    }
    
    func resetGame() {
        player = nil
        currentEnemy = nil
        gameState = .mainMenu
        battleLog.removeAll()
        showBattleView = false
    }
}
