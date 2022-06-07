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
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                
                Section {
                    ForEach(usedWords, id:\.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
        }
    }
    
    func addNewWord() {
        // lowercase and trim the word, to make sure not to add duplicate words with case differences
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // exit if the remaining string is empty
        guard answer.count > 0 else { return }
        
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
                // Exit here if everything above has worked
                return
            }
        }
        // If there was a problem with the above – trigger a crash and report the error
        fatalError("Could not load starter.txt from bundle.")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
