//
//  ContentView.swift
//  WordScramble
//
//  Created by Liko Setiawan on 08/02/24.
//

import SwiftUI

struct ContentView: View {
    
    let gradient = LinearGradient(colors: [Color.orange,Color.green],
                                  startPoint: .top, endPoint: .bottom)
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var score = 0
    
    //error alerts properties
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationStack{
            List{
                VStack{	
                    Text("Your Word is : \(rootWord)")
                        .font(.system(size: 20))
                    
                    
                }
                Text("Score : \(score)")
                Section{
                    TextField("Enter Your Word", text: $newWord)
                        .textInputAutocapitalization(.never)
                        .font(.system(size: 20))
                }
                //button
                
                Section{
                    ForEach(usedWords, id : \.self){word in
                        HStack{
                            Text(word)
                            Spacer()
                            Image(systemName: "\(word.count).circle")
                        }
                        .font(.system(size: 20))
                    }
                }
                
            }
            .toolbar{
                Button("Change Word", action : startGame)
                    .foregroundColor(.black)
            }
//            .scrollContentBackground(.hidden)
//            .background(
//                   LinearGradient(gradient: Gradient(colors: [.blue, .red]), startPoint: .top, endPoint: .bottom)
//               )
            .navigationTitle("Scramble Game")
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError){
                Button("OK"){}
            }message: {
                Text(errorMessage)
            }
        }
        
        
        
        
    }
    //
    //
    func addNewWord(){
        //make the string lowercased and trim the word, to make sure no duplicate words
        let answers = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        //exit if user input is empty
        guard answers.count > 0 else{ return }
        
        guard answers.count >= 3 else{
            wordError(title: "Too short ", message: "3 is the minimal")
            return
        }
        
        guard answers != rootWord else{
            wordError(title: "Cannot use the word", message: "Please input different word than \(rootWord)")
            return
        }
        
        guard isOriginal(word: answers) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answers) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        
        guard isReal(word: answers) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        withAnimation{
            usedWords.insert(answers, at: 0)
        }
        
        newWord = ""
        score += answers.count
        
        
    }
    
    func startGame(){
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            
            if let startWords = try? String(contentsOf: startWordsURL){
                let allWords = startWords.components(separatedBy: "\n")
                
                rootWord = allWords.randomElement() ?? "silkworm"
                score = 0
                usedWords = []
                return
            }
        }
        
        fatalError("start.txt could not be loaded")
    }
    
    func isOriginal(word : String) -> Bool{
        !usedWords.contains(word)
    }
    
    
    func isPossible(word : String) -> Bool{
        var tempWord = rootWord
        
        for letter in word{
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            }else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word : String) -> Bool{
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message : String){
        errorTitle = title
        errorMessage = message
        showingError = true
        
    }
    
}

#Preview {
    ContentView()
}



