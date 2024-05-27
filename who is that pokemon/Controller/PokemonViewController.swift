//
//  ViewController.swift
//  who is that pokemon
//
//  Created by Raúl Gallego Alonso on 01/09/2023.
//

import UIKit
import Kingfisher

class PokemonViewController: UIViewController {
    
    @IBOutlet weak var pokemonImage: UIImageView!
    @IBOutlet weak var labelScore: UILabel!
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet var answerButtons: [UIButton]!
    
    lazy var pokemonManager = PokemonManager()
    lazy var imageManager = ImageManager()
    lazy var game = GameModel()
    
    var random4Pokemons: [PokemonModel] = [] {
        didSet {
            setButtonTitles()
        }
    }
    
    var correctAnswer: String = ""
    var correctAnswerImage: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pokemonManager.delegate = self
        imageManager.delegate = self
        
        createButtons()
        pokemonManager.fetchPokemon()
        labelMessage.text = " "
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        let userAnswer = sender.title(for: .normal)!
        
        if game.checkAnswer(userAnswer, correctAnswer) {
            labelMessage.text = "Sí, es un \(userAnswer.capitalized)"
            labelScore.text = "Puntuación: \(game.score)"
            
            sender.layer.borderColor = UIColor.systemGreen.cgColor
            sender.layer.borderWidth = 2
            
            let url = URL(string: correctAnswerImage)
            pokemonImage.kf.setImage(with: url)
            
            Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false) { timer in
                self.pokemonManager.fetchPokemon()
                self.labelMessage.text = " "
                sender.layer.borderWidth = 0
            }
        } else {
            //           labelMessage.text = "NOOO, es un \(correctAnswer.capitalized)"
            //          sender.layer.borderColor = UIColor.systemRed.cgColor
            //        sender.layer.borderWidth = 2
            //      let url = URL(string: correctAnswerImage)
            //    pokemonImage.kf.setImage(with: url)
            
            
            //  Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false) { timer in
            //    self.resetGame()
            //  sender.layer.borderWidth = 0
            //}
            self.performSegue(withIdentifier: "goToResult", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToResult" {
            let destination = segue.destination as! ResultsViewController
            destination.pokemonName = correctAnswer
            destination.pokemonImageURL = correctAnswerImage
            destination.finalScore = game.score
            resetGame()
        }
    }
    
    func resetGame() {
        self.pokemonManager.fetchPokemon()
        game.setScore(score: 0)
        labelScore.text = "Puntuación: \(game.score)"
        self.labelMessage.text = " "
    }
    
    func createButtons() {
        for button in answerButtons {
            button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
            button.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
            button.layer.shadowOpacity = 1.0
            button.layer.shadowRadius = 0
            button.layer.masksToBounds = false
            button.layer.cornerRadius = 10.0
        }
    }
    
    func setButtonTitles() {
        for (index, button) in answerButtons.enumerated() {
            DispatchQueue.main.async { [self] in
                button.setTitle(random4Pokemons[safe: index]?.name.capitalized, for: .normal)
            }
        }
    }
    
}

extension PokemonViewController: PokemonManagerDelegate {
    func didUpdatePokemon(pokemons: [PokemonModel]) {
        random4Pokemons = pokemons.choose(4)
        
        let index = Int.random(in: 0...3)
        let imageData = random4Pokemons[index].imageURL
        correctAnswer = random4Pokemons[index].name
        
        imageManager.fetchImage(url: imageData)
        
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
    
    
}

extension PokemonViewController: ImageManagerDelegate {
    func didUpdateImage(image: ImageModel) {
        correctAnswerImage = image.imageUR
        
        DispatchQueue.main.async { [self] in
            let url = URL(string: image.imageUR)
            // imageView.kf.setImage(with: url)
            // ColorControlsProcessor(brightness: 1.0, contrast: 0.7, saturation: 1.1, inputEV: 0.7)
            let effect = ColorControlsProcessor(brightness: -1, contrast: 1, saturation: 1, inputEV: 0)
            pokemonImage.kf.setImage(
                with: url,
                options: [
                    .processor(effect)
                ]
            )
            
            
        }
        
    }
    
    func didFailWithErrorImage(error: Error) {
        print(error)
    }
    
    
}

extension Collection where Indices.Iterator.Element == Index {
    public subscript(safe index: Index) -> Iterator.Element? {
        return (startIndex <= index && index < endIndex) ? self[index] : nil
    }
}

extension Collection {
    func choose(_ n: Int) -> Array<Element> {
        Array(shuffled().prefix(n))
    }
}
