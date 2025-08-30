import Foundation

class GameState: ObservableObject {
    @Published var cash: Int = 2000
    @Published var debt: Int = 5000
    @Published var currentDay: Int = 1
    @Published var currentLocation: String = "Manhattan"
    @Published var displayLines: [String] = []
    @Published var gameMode: GameMode = .menu
    @Published var inventory: [String: Int] = [:]
    @Published var capacity: Int = 100
    @Published var hasGun: Bool = false
    @Published var weaponsInventory: [String: Int] = [:]
    @Published var currentRoadblockType: String = ""
    @Published var hasCoat: Bool = false
    @Published var bankBalance: Int = 0
    @Published var numberInput: String = ""
    @Published var selectedDrug: String = ""
    
    let locations = ["Briargate", "Broadmoor", "Downtown", "Manitou Springs", "Old Colorado City"]
    let drugs = ["Cocaine", "Heroin", "Acid", "Weed", "Speed", "Ludes"]
    let weapons = ["Pistol", "Shotgun", "Rifle", "Machine Gun"]
    let roadblockTypes = ["Officer Hardass", "Detective Stone", "Agent Smith", "Sheriff Brown", "Captain Miller"]
    
    var drugPrices: [String: [String: Int]] = [:]
    
    enum GameMode {
        case menu
        case traveling
        case trading
        case buying
        case selling
        case buyingAmount
        case sellingAmount
        case encounter
        case gameOver
        case bank
        case randomEvent
    }
    
    init() {
        currentLocation = "Briargate"
        generateDrugPrices()
        initializeWeapons()
        showMainMenu()
    }
    
    func usedCapacity() -> Int {
        return inventory.values.reduce(0, +)
    }
    
    func maxCapacity() -> Int {
        return hasCoat ? 200 : capacity
    }
    
    func generateDrugPrices() {
        for location in locations {
            drugPrices[location] = [:]
            for drug in drugs {
                let basePrice = basePriceFor(drug: drug)
                let variation = Int.random(in: -basePrice/2...basePrice*2)
                drugPrices[location]![drug] = max(1, basePrice + variation)
            }
        }
    }
    
    func basePriceFor(drug: String) -> Int {
        switch drug {
        case "Cocaine": return 15000
        case "Heroin": return 5500
        case "Acid": return 3000
        case "Weed": return 300
        case "Speed": return 90
        case "Ludes": return 15
        default: return 100
        }
    }
    
    func showMainMenu() {
        displayLines = [
            "WELCOME TO DRUG WARS!",
            "",
            "YOU OWE $5,000 TO THE",
            "LOAN SHARK. YOU HAVE 30",
            "DAYS TO PAY IT BACK.",
            "",
            "1. START GAME",
            "2. INSTRUCTIONS", 
            "3. QUIT"
        ]
        gameMode = .menu
    }
    
    func showTradingScreen() {
        displayLines = [
            "LOCATION: \(currentLocation.uppercased())",
            "DAY: \(currentDay)/30",
            "CASH: $\(cash)",
            "DEBT: $\(debt)",
            "",
            "DRUG PRICES:"
        ]
        
        for (index, drug) in drugs.enumerated() {
            let price = drugPrices[currentLocation]?[drug] ?? 0
            let owned = inventory[drug] ?? 0
            displayLines.append("\(index + 1). \(drug): $\(price) (\(owned))")
        }
        
        displayLines.append("")
        displayLines.append("1)BUY  2)SELL  3)TRAVEL  4)BANK")
        gameMode = .trading
    }
    
    func handleButtonPress(_ button: String) {
        switch gameMode {
        case .menu:
            handleMenuInput(button)
        case .trading:
            handleTradingInput(button)
        case .traveling:
            handleTravelInput(button)
        case .buying:
            handleBuyInput(button)
        case .selling:
            handleSellInput(button)
        case .buyingAmount:
            handleNumberInput(button, action: "buy")
        case .sellingAmount:
            handleNumberInput(button, action: "sell")
        case .encounter:
            handleEncounterInput(button)
        case .bank:
            handleBankInput(button)
        case .randomEvent:
            handleRandomEventInput(button)
        case .gameOver:
            // Any button press restarts the game
            startGame()
        default:
            break
        }
    }
    
    func handleMenuInput(_ input: String) {
        print("Menu input received: \(input)")
        switch input {
        case "1":
            if displayLines.contains("1. START GAME") {
                print("Starting game...")
                startGame()
            } else if displayLines.contains("1. Return to menu") {
                showMainMenu()
            } else if displayLines.contains("1. Continue") {
                showTradingScreen()
            }
        case "2":
            showInstructions()
        case "3":
            quitGame()
        default:
            break
        }
    }
    
    func handleTradingInput(_ input: String) {
        switch input {
        case "1":
            showBuyMenu()
        case "2":
            showSellMenu()
        case "3":
            showTravelMenu()
        case "4":
            showBankMenu()
        default:
            break
        }
    }
    
    func handleTravelInput(_ input: String) {
        if input == "0" {
            showTradingScreen()
            return
        }
        
        if let menuChoice = Int(input), menuChoice >= 1 {
            let availableLocations = locations.filter { $0 != currentLocation }
            if menuChoice <= availableLocations.count {
                travelTo(availableLocations[menuChoice - 1])
            }
        }
    }
    
    func startGame() {
        print("startGame() called")
        cash = 2000
        debt = 5000
        currentDay = 1
        currentLocation = "Briargate"
        inventory = [:]
        hasGun = false
        weaponsInventory = [:]
        hasCoat = false
        bankBalance = 0
        initializeWeapons()
        print("About to generate drug prices...")
        generateDrugPrices()
        print("About to show trading screen...")
        showTradingScreen()
        print("startGame() completed")
    }
    
    func showInstructions() {
        displayLines = [
            "DRUG WARS INSTRUCTIONS",
            "",
            "You are a drug dealer",
            "with $2000 and a debt",
            "of $5000 to pay back",
            "in 30 days.",
            "",
            "Travel between Colorado",
            "Springs buying and",
            "selling drugs for profit.",
            "",
            "Watch out for police!",
            "",
            "1. Return to menu"
        ]
        gameMode = .menu
    }
    
    func showBuyMenu() {
        displayLines = [
            "BUY DRUGS",
            "",
            "Which drug to buy?",
            ""
        ]
        
        for (index, drug) in drugs.enumerated() {
            let price = drugPrices[currentLocation]?[drug] ?? 0
            displayLines.append("\(index + 1). \(drug): $\(price)")
        }
        
        displayLines.append("")
        displayLines.append("0. Back to main")
        gameMode = .buying
    }
    
    func showSellMenu() {
        displayLines = [
            "SELL DRUGS",
            "",
            "Which drug to sell?",
            ""
        ]
        
        for (index, drug) in drugs.enumerated() {
            let price = drugPrices[currentLocation]?[drug] ?? 0
            let owned = inventory[drug] ?? 0
            displayLines.append("\(index + 1). \(drug): $\(price) (\(owned))")
        }
        
        displayLines.append("")
        displayLines.append("0. Back to main")
        gameMode = .selling
    }
    
    func showTravelMenu() {
        displayLines = [
            "TRAVEL TO:",
            ""
        ]
        
        var menuIndex = 1
        for location in locations {
            if location != currentLocation {
                displayLines.append("\(menuIndex). \(location)")
                menuIndex += 1
            }
        }
        
        displayLines.append("")
        displayLines.append("0. Stay here")
        gameMode = .traveling
    }
    
    func showDrugDetails(_ drug: String) {
        let price = drugPrices[currentLocation]?[drug] ?? 0
        let owned = inventory[drug] ?? 0
        
        displayLines = [
            "DRUG: \(drug)",
            "Price: $\(price)",
            "You have: \(owned)",
            "Cash: $\(cash)",
            "",
            "How many to buy/sell?",
            "",
            "B)uy  S)ell  C)ancel"
        ]
    }
    
    func travelTo(_ destination: String) {
        currentLocation = destination
        currentDay += 1
        generateDrugPrices()
        
        if currentDay > 30 {
            gameOver()
            return
        }
        
        let encounterChance = Int.random(in: 1...10)
        if encounterChance <= 3 {
            policeEncounter()
        } else if encounterChance == 4 && Int.random(in: 1...10) <= 2 {
            findWeapon()
        } else if encounterChance == 5 && Int.random(in: 1...10) <= 3 {
            randomTravelEvent()
        } else {
            showTradingScreen()
        }
    }
    
    func policeEncounter() {
        currentRoadblockType = roadblockTypes.randomElement() ?? "Officer Hardass"
        let hasWeapons = !weaponsInventory.isEmpty
        
        displayLines = [
            "POLICE ENCOUNTER!",
            "",
            "\(currentRoadblockType) is here!",
            "",
            "What do you do?",
            "",
            "1. Run",
            "2. Fight" + (hasWeapons ? "" : " (no weapons)"),
            "3. Surrender"
        ]
        gameMode = .encounter
    }
    
    func gameOver() {
        let profit = cash - debt
        displayLines = [
            "GAME OVER",
            "",
            "Time's up!",
            "",
            "Final Cash: $\(cash)",
            "Debt: $\(debt)",
            "Profit: $\(profit)",
            "",
            profit > 0 ? "You won!" : "You lost!",
            "",
            "Press any button to play again"
        ]
        gameMode = .gameOver
    }
    
    func quitGame() {
        displayLines = [
            "Thanks for playing!",
            "",
            "Press 1 to restart"
        ]
    }
    
    func handleBuyInput(_ input: String) {
        if input == "0" {
            showTradingScreen()
            return
        }
        
        if let index = Int(input), index >= 1 && index <= drugs.count {
            let drug = drugs[index - 1]
            selectedDrug = drug
            showBuyDrugScreen(drug)
        }
    }
    
    func handleSellInput(_ input: String) {
        if input == "0" {
            showTradingScreen()
            return
        }
        
        if let index = Int(input), index >= 1 && index <= drugs.count {
            let drug = drugs[index - 1]
            selectedDrug = drug
            showSellDrugScreen(drug)
        }
    }
    
    func showBuyDrugScreen(_ drug: String) {
        let price = drugPrices[currentLocation]?[drug] ?? 0
        let maxAffordable = cash / price
        let maxCapacity = maxCapacity() - usedCapacity()
        let maxCanBuy = min(maxAffordable, maxCapacity)
        
        displayLines = [
            "BUY \(drug.uppercased())",
            "",
            "Price: $\(price)",
            "Cash: $\(cash)",
            "Max you can buy: \(maxCanBuy)",
            "",
            "Amount: \(numberInput)",
            "",
            "ENTER to confirm",
            "CLEAR to cancel"
        ]
        numberInput = ""
        gameMode = .buyingAmount
    }
    
    func showSellDrugScreen(_ drug: String) {
        let price = drugPrices[currentLocation]?[drug] ?? 0
        let owned = inventory[drug] ?? 0
        
        displayLines = [
            "SELL \(drug.uppercased())",
            "",
            "Price: $\(price)",
            "You have: \(owned)",
            "",
            "Amount: \(numberInput)",
            "",
            "ENTER to confirm",
            "CLEAR to cancel"
        ]
        numberInput = ""
        gameMode = .sellingAmount
    }
    
    func handleNumberInput(_ input: String, action: String) {
        switch input {
        case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
            numberInput += input
            updateNumberInputDisplay(action: action)
        case "CLEAR":
            numberInput = ""
            selectedDrug = ""
            showTradingScreen()
        case "ENTER":
            executeTransaction(action: action)
        case "DEL":
            if !numberInput.isEmpty {
                numberInput.removeLast()
                updateNumberInputDisplay(action: action)
            }
        default:
            break
        }
    }
    
    func updateNumberInputDisplay(action: String) {
        let price = drugPrices[currentLocation]?[selectedDrug] ?? 0
        
        if action == "buy" {
            let maxAffordable = cash / max(price, 1)
            let maxCapacity = maxCapacity() - usedCapacity()
            let maxCanBuy = min(maxAffordable, maxCapacity)
            
            displayLines = [
                "BUY \(selectedDrug.uppercased())",
                "",
                "Price: $\(price)",
                "Cash: $\(cash)",
                "Max you can buy: \(maxCanBuy)",
                "",
                "Amount: \(numberInput)",
                "",
                "ENTER to confirm",
                "CLEAR to cancel"
            ]
        } else {
            let owned = inventory[selectedDrug] ?? 0
            
            displayLines = [
                "SELL \(selectedDrug.uppercased())",
                "",
                "Price: $\(price)",
                "You have: \(owned)",
                "",
                "Amount: \(numberInput)",
                "",
                "ENTER to confirm",
                "CLEAR to cancel"
            ]
        }
    }
    
    func executeTransaction(action: String) {
        guard let amount = Int(numberInput), amount > 0 else {
            numberInput = ""
            showTradingScreen()
            return
        }
        
        if action == "buy" {
            buyDrug(selectedDrug, amount: amount)
        } else {
            sellDrug(selectedDrug, amount: amount)
        }
        
        numberInput = ""
        selectedDrug = ""
        showTradingScreen()
    }
    
    func buyDrug(_ drug: String, amount: Int) {
        let price = drugPrices[currentLocation]?[drug] ?? 0
        let cost = amount * price
        let maxCapacity = maxCapacity() - usedCapacity()
        
        if cost > cash {
            displayLines = ["Not enough cash!"]
            return
        }
        
        if amount > maxCapacity {
            displayLines = ["Not enough capacity!"]
            return
        }
        
        cash -= cost
        inventory[drug] = (inventory[drug] ?? 0) + amount
    }
    
    func sellDrug(_ drug: String, amount: Int) {
        let owned = inventory[drug] ?? 0
        
        if amount > owned {
            displayLines = ["You don't have that many!"]
            return
        }
        
        let price = drugPrices[currentLocation]?[drug] ?? 0
        let earnings = amount * price
        
        cash += earnings
        inventory[drug] = owned - amount
        if inventory[drug] == 0 {
            inventory.removeValue(forKey: drug)
        }
    }
    
    func handleEncounterInput(_ input: String) {
        switch input {
        case "1":
            // Run
            if Int.random(in: 1...10) <= 7 {
                displayLines = ["You escaped!", "", "1. Continue"]
            } else {
                let fine = cash / 4
                cash = max(0, cash - fine)
                displayLines = ["Caught! Lost $\(fine)", "", "1. Continue"]
            }
            gameMode = .menu
        case "2":
            // Fight
            if !weaponsInventory.isEmpty {
                let weapon = weaponsInventory.keys.randomElement() ?? "Pistol"
                let weaponPower = getWeaponPower(weapon)
                let enemyStrength = getEnemyStrength(currentRoadblockType)
                
                if weaponPower >= enemyStrength {
                    let reward = Int.random(in: 1000...5000)
                    cash += reward
                    displayLines = ["You won with \(weapon)!", "Reward: $\(reward)", "", "1. Continue"]
                    
                    // Small chance weapon breaks
                    if Int.random(in: 1...10) <= 2 {
                        weaponsInventory[weapon] = (weaponsInventory[weapon] ?? 1) - 1
                        if weaponsInventory[weapon]! <= 0 {
                            weaponsInventory.removeValue(forKey: weapon)
                        }
                        displayLines[1] = "Reward: $\(reward)\n\(weapon) broke!"
                    }
                } else {
                    let fine = cash / 3
                    cash = max(0, cash - fine)
                    displayLines = ["You lost with \(weapon)!", "Lost $\(fine)", "", "1. Continue"]
                }
            } else {
                let fine = cash / 2
                cash = max(0, cash - fine)
                displayLines = ["Can't fight without weapons!", "Lost $\(fine)", "", "1. Continue"]
            }
            gameMode = .menu
        case "3":
            // Surrender
            cash /= 2
            inventory = [:]
            displayLines = ["Arrested! Lost half cash", "and all drugs!", "", "1. Continue"]
            gameMode = .menu
        default:
            break
        }
    }
    
    func initializeWeapons() {
        // Player starts with no weapons
        weaponsInventory = [:]
    }
    
    func findWeapon() {
        let foundWeapon = weapons.randomElement() ?? "Pistol"
        weaponsInventory[foundWeapon] = (weaponsInventory[foundWeapon] ?? 0) + 1
        
        displayLines = [
            "WEAPON FOUND!",
            "",
            "You found a \\(foundWeapon)!",
            "",
            "Your arsenal:",
        ]
        
        for (weapon, count) in weaponsInventory {
            displayLines.append("\\(weapon): \\(count)")
        }
        
        displayLines.append("")
        displayLines.append("1. Continue")
        gameMode = .menu
    }
    
    func getWeaponPower(_ weapon: String) -> Int {
        switch weapon {
        case "Pistol": return 3
        case "Shotgun": return 5
        case "Rifle": return 7
        case "Machine Gun": return 10
        default: return 1
        }
    }
    
    func getEnemyStrength(_ enemy: String) -> Int {
        switch enemy {
        case "Officer Hardass": return 4
        case "Detective Stone": return 6
        case "Agent Smith": return 8
        case "Sheriff Brown": return 5
        case "Captain Miller": return 7
        default: return 4
        }
    }
    
    // MARK: - Bank System
    func showBankMenu() {
        displayLines = [
            "FIRST NATIONAL BANK",
            "",
            "Current Balance: $\(bankBalance)",
            "Your Debt: $\(debt)",
            "",
            "1. Deposit Money",
            "2. Withdraw Money", 
            "3. Get Loan",
            "4. Repay Loan",
            "0. Back to Main"
        ]
        gameMode = .bank
    }
    
    func handleBankInput(_ input: String) {
        switch input {
        case "1":
            if cash > 0 {
                bankBalance += cash
                displayLines = ["Deposited $\(cash)", "", "1. Continue"]
                cash = 0
            } else {
                displayLines = ["No money to deposit!", "", "1. Continue"]
            }
            gameMode = .menu
        case "2":
            if bankBalance > 0 {
                cash += bankBalance
                displayLines = ["Withdrew $\(bankBalance)", "", "1. Continue"]
                bankBalance = 0
            } else {
                displayLines = ["No money in bank!", "", "1. Continue"]
            }
            gameMode = .menu
        case "3":
            let loanAmount = Int.random(in: 1000...3000)
            cash += loanAmount
            debt += loanAmount
            displayLines = ["Loan approved: $\(loanAmount)", "New debt: $\(debt)", "", "1. Continue"]
            gameMode = .menu
        case "4":
            if cash >= debt {
                cash -= debt
                displayLines = ["Debt paid off!", "You're debt-free!", "", "1. Continue"]
                debt = 0
            } else if cash > 0 {
                let payment = cash
                debt -= payment
                cash = 0
                displayLines = ["Paid $\(payment)", "Remaining debt: $\(debt)", "", "1. Continue"]
            } else {
                displayLines = ["No money to pay debt!", "", "1. Continue"]
            }
            gameMode = .menu
        case "0":
            showTradingScreen()
        default:
            break
        }
    }
    
    // MARK: - Random Travel Events
    func randomTravelEvent() {
        let eventType = Int.random(in: 1...4)
        switch eventType {
        case 1:
            findMoney()
        case 2:
            findCoat()
        case 3:
            findDrugs()
        default:
            drugRaid()
        }
    }
    
    func handleRandomEventInput(_ input: String) {
        if input == "1" {
            showTradingScreen()
        }
    }
    
    func findMoney() {
        let amount = Int.random(in: 100...1000)
        cash += amount
        displayLines = [
            "LUCKY FIND!",
            "",
            "You found $\(amount)",
            "in an old coat!",
            "",
            "Cash: $\(cash)",
            "",
            "1. Continue"
        ]
        gameMode = .randomEvent
    }
    
    func findCoat() {
        if !hasCoat {
            hasCoat = true
            displayLines = [
                "COAT FOUND!",
                "",
                "You found a trench coat!",
                "Capacity doubled!",
                "",
                "New capacity: \(maxCapacity())",
                "",
                "1. Continue"
            ]
        } else {
            let amount = Int.random(in: 200...500)
            cash += amount
            displayLines = [
                "MONEY IN COAT!",
                "",
                "You found $\(amount)",
                "in a coat pocket!",
                "",
                "1. Continue"
            ]
        }
        gameMode = .randomEvent
    }
    
    func findDrugs() {
        let drug = drugs.randomElement() ?? "Weed"
        let amount = Int.random(in: 1...5)
        
        if usedCapacity() + amount <= maxCapacity() {
            inventory[drug] = (inventory[drug] ?? 0) + amount
            displayLines = [
                "DRUG STASH FOUND!",
                "",
                "You found \(amount) \(drug)!",
                "",
                "Capacity: \(usedCapacity())/\(maxCapacity())",
                "",
                "1. Continue"
            ]
        } else {
            displayLines = [
                "DRUG STASH FOUND!",
                "",
                "But you have no space!",
                "Get a coat for more capacity.",
                "",
                "1. Continue"
            ]
        }
        gameMode = .randomEvent
    }
    
    func drugRaid() {
        if !inventory.isEmpty {
            let lostDrug = inventory.keys.randomElement() ?? "Weed"
            let lostAmount = min(inventory[lostDrug] ?? 0, Int.random(in: 1...3))
            inventory[lostDrug] = max(0, (inventory[lostDrug] ?? 0) - lostAmount)
            if inventory[lostDrug] == 0 {
                inventory.removeValue(forKey: lostDrug)
            }
            
            displayLines = [
                "DRUG RAID!",
                "",
                "Police raided a stash house!",
                "Lost \(lostAmount) \(lostDrug)",
                "",
                "1. Continue"
            ]
        } else {
            displayLines = [
                "POLICE ACTIVITY!",
                "",
                "Heavy police presence",
                "in the area. Stay alert!",
                "",
                "1. Continue"
            ]
        }
        gameMode = .randomEvent
    }
}