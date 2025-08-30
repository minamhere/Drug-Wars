#!/usr/bin/swift

import Foundation

class DrugWarsGame {
    var cash = 2000
    var debt = 5000
    var day = 1
    var location = "Manhattan"
    var inventory: [String: Int] = [:]
    var capacity = 100
    var hasGun = false
    
    let locations = ["Manhattan", "Bronx", "Brooklyn", "Queens", "Staten Island"]
    let drugs = ["Cocaine", "Heroin", "Acid", "Weed", "Speed", "Ludes"]
    var drugPrices: [String: [String: Int]] = [:]
    
    init() {
        generatePrices()
    }
    
    func generatePrices() {
        for loc in locations {
            drugPrices[loc] = [:]
            for drug in drugs {
                let base = basePriceFor(drug)
                let variation = Int.random(in: -base/2...base*2)
                drugPrices[loc]![drug] = max(1, base + variation)
            }
        }
    }
    
    func basePriceFor(_ drug: String) -> Int {
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
    
    func showStatus() {
        print("\n" + String(repeating: "=", count: 50))
        print("DRUG WARS - Day \(day)/30")
        print("Location: \(location)")
        print("Cash: $\(cash)")
        print("Debt: $\(debt)")
        print("Capacity: \(usedCapacity())/\(capacity)")
        print(String(repeating: "=", count: 50))
    }
    
    func showPrices() {
        print("\nDrug Prices in \(location):")
        for (i, drug) in drugs.enumerated() {
            let price = drugPrices[location]![drug]!
            let owned = inventory[drug] ?? 0
            print("\(i+1). \(drug): $\(price) (you have: \(owned))")
        }
    }
    
    func usedCapacity() -> Int {
        return inventory.values.reduce(0, +)
    }
    
    func mainMenu() {
        showStatus()
        showPrices()
        
        print("\nOptions:")
        print("B) Buy drugs")
        print("S) Sell drugs") 
        print("T) Travel")
        print("Q) Quit")
        print("\nEnter choice: ", terminator: "")
        
        if let input = readLine()?.uppercased() {
            switch input {
            case "B": buyMenu()
            case "S": sellMenu()
            case "T": travelMenu()
            case "Q": 
                print("Thanks for playing!")
                exit(0)
            default: 
                print("Invalid choice!")
                mainMenu()
            }
        }
    }
    
    func buyMenu() {
        print("\nWhich drug to buy? (1-6, 0 to cancel): ", terminator: "")
        if let input = readLine(), let choice = Int(input) {
            if choice == 0 {
                mainMenu()
                return
            }
            if choice >= 1 && choice <= drugs.count {
                let drug = drugs[choice - 1]
                buyDrug(drug)
            } else {
                print("Invalid choice!")
                buyMenu()
            }
        }
    }
    
    func sellMenu() {
        print("\nWhich drug to sell? (1-6, 0 to cancel): ", terminator: "")
        if let input = readLine(), let choice = Int(input) {
            if choice == 0 {
                mainMenu()
                return
            }
            if choice >= 1 && choice <= drugs.count {
                let drug = drugs[choice - 1]
                sellDrug(drug)
            } else {
                print("Invalid choice!")
                sellMenu()
            }
        }
    }
    
    func buyDrug(_ drug: String) {
        let price = drugPrices[location]![drug]!
        let maxAffordable = cash / price
        let maxCapacity = capacity - usedCapacity()
        let maxCanBuy = min(maxAffordable, maxCapacity)
        
        if maxCanBuy <= 0 {
            print("You can't buy any \(drug) (no money or space)")
            mainMenu()
            return
        }
        
        print("Max you can buy: \(maxCanBuy)")
        print("How many? ", terminator: "")
        
        if let input = readLine(), let amount = Int(input) {
            if amount > 0 && amount <= maxCanBuy {
                let cost = amount * price
                cash -= cost
                inventory[drug] = (inventory[drug] ?? 0) + amount
                print("Bought \(amount) \(drug) for $\(cost)")
            } else {
                print("Invalid amount!")
            }
        }
        mainMenu()
    }
    
    func sellDrug(_ drug: String) {
        let owned = inventory[drug] ?? 0
        if owned <= 0 {
            print("You don't have any \(drug)")
            mainMenu()
            return
        }
        
        let price = drugPrices[location]![drug]!
        print("You have \(owned) \(drug)")
        print("How many to sell? ", terminator: "")
        
        if let input = readLine(), let amount = Int(input) {
            if amount > 0 && amount <= owned {
                let earnings = amount * price
                cash += earnings
                inventory[drug] = owned - amount
                print("Sold \(amount) \(drug) for $\(earnings)")
            } else {
                print("Invalid amount!")
            }
        }
        mainMenu()
    }
    
    func travelMenu() {
        print("\nTravel to:")
        for (i, loc) in locations.enumerated() {
            if loc != location {
                print("\(i+1). \(loc)")
            }
        }
        print("0. Stay here")
        print("Choice: ", terminator: "")
        
        if let input = readLine(), let choice = Int(input) {
            if choice == 0 {
                mainMenu()
                return
            }
            if choice >= 1 && choice <= locations.count {
                let newLocation = locations[choice - 1]
                if newLocation != location {
                    travelTo(newLocation)
                }
            } else {
                print("Invalid choice!")
                travelMenu()
            }
        }
    }
    
    func travelTo(_ destination: String) {
        location = destination
        day += 1
        generatePrices()
        
        print("\nTraveling to \(destination)...")
        
        if day > 30 {
            gameOver()
            return
        }
        
        if Int.random(in: 1...10) <= 3 {
            policeEncounter()
        } else {
            mainMenu()
        }
    }
    
    func policeEncounter() {
        print("\n🚔 POLICE ENCOUNTER! 🚔")
        print("Officer Hardass appears!")
        print("\n1. Run")
        print("2. Fight" + (hasGun ? "" : " (no gun)"))
        print("3. Surrender")
        print("Choice: ", terminator: "")
        
        if let input = readLine(), let choice = Int(input) {
            switch choice {
            case 1:
                if Int.random(in: 1...10) <= 7 {
                    print("You escaped!")
                } else {
                    print("Caught! Lost $\(cash/4)")
                    cash = max(0, cash - cash/4)
                }
            case 2:
                if hasGun {
                    if Int.random(in: 1...10) <= 5 {
                        print("You won! Reward: $\(Int.random(in: 1000...5000))")
                        cash += Int.random(in: 1000...5000)
                    } else {
                        print("You lost the fight!")
                        cash = max(0, cash - cash/3)
                    }
                } else {
                    print("You can't fight without a gun!")
                    cash = max(0, cash - cash/2)
                }
            case 3:
                print("Arrested! Lost half your cash and drugs!")
                cash /= 2
                inventory = [:]
            default:
                print("Invalid choice!")
                policeEncounter()
                return
            }
        }
        mainMenu()
    }
    
    func gameOver() {
        let profit = cash - debt
        print("\n" + String(repeating: "=", count: 50))
        print("GAME OVER!")
        print("Final Cash: $\(cash)")
        print("Debt: $\(debt)")
        print("Net Profit: $\(profit)")
        if profit > 0 {
            print("🎉 YOU WON! 🎉")
        } else {
            print("💀 YOU LOST! 💀")
        }
        print(String(repeating: "=", count: 50))
        exit(0)
    }
    
    func run() {
        print("🎮 DRUG WARS 🎮")
        print("Welcome to the streets of NYC!")
        print("You owe $5,000 to the loan shark.")
        print("You have 30 days to pay it back...")
        mainMenu()
    }
}

let game = DrugWarsGame()
game.run()