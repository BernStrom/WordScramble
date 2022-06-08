//
//  ContentView.swift
//  WordScramble
//
//  Created by Bern N on 6/7/22.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var playerScore = 0
    
    var body: some View {
        NavigationView {
            List {
                Section("Starter Word") {
                    Text(rootWord)
                        .font(.largeTitle)
                }
                
                Section("Your Answer") {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                    
                    Text("Total Score: \(playerScore)")
                        .font(.headline)
                }
                
                Section("Used Words") {
                    ForEach(usedWords, id:\.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text("+")
                            Image(systemName: "2.circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle("WordScramble")
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .toolbar {
                Button("Restart", action: startGame)
            }
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    func addNewWord() {
        // lowercase and trim the word, to make sure not to add duplicate words with case differences
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // exit if the remaining string is empty
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word Used Already", message: "Try again with a different word 🙃")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word Not Possible", message: "You can't spell that word from \(rootWord)!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word Not Recognized", message: "Needs to be an actual English word!")
            return
        }
        
        addScore(word: answer)
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        
        newWord = ""
    }
    
    func startGame() {
        // 1. Find the URL for starter.txt in our app bundle
        if let starterWordsURL = Bundle.main.url(forResource: "starter", withExtension: "txt") {
            // 2. Load starter.txt into a string
            if let starterWords = try? String(contentsOf: starterWordsURL) {
                // 3. Split the string up into an array of strings, splitting on line breaks
                let allWords = starterWords.components(separatedBy: "\n")
                // 4. Pick one random word, or use "silkworm" as a sensible default
                rootWord = allWords.randomElement() ?? "silkworm"
                playerScore = 0
                usedWords = [String]()
                // Exit here if everything above has worked
                return
            }
        }
        // If there was a problem with the above – trigger a crash and report the error
        fatalError("Could not load starter.txt from bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word) && word != rootWord
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func addScore(word: String) {
        playerScore += word.count + 2
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
