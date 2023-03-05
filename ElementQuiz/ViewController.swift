//
//  ViewController.swift
//  ElementQuiz
//
//  Created by Ivan Komarov on 05.03.2023.
//

import UIKit

//creates two choices FlashCard/Quiz mode
enum Mode{
    case flashCard
    case quiz
}


//creates two choices Question/Answer
enum State{
    case queston
    case answer
    case score
}

class ViewController: UIViewController, UITextFieldDelegate {
    
    //declaring outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var modeSelector: UISegmentedControl!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var showAnswerButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    
    //creating options for selector
    let selectorOptions: [String] = ["Flash Card", "Quiz"]
    
    //creating array of elements
    let fixedElementList = ["Carbon", "Gold", "Chlorine", "Sodium"]
    var elementList: [String] = []
    
    //Quiz specific state
    var answerIsCorrect: Bool = false
    var correctAnswerCount: Int = 0
    
    //variable to track current elementList index
    var currentElementIndex = 0
    
    //variable for definign mode FlashCard/Quiz
    var mode: Mode = .flashCard{
        didSet {
            switch mode{
            case .flashCard:
                setupFlashCard()
            case .quiz:
                setupQuiz()
            }
            
            updateUI()
        }
    }
    
    // variable to track the choise Queston/Anwer mode
    var state: State = .queston
    
    //Load the screen
    override func viewDidLoad() {
        //sets tex for Selector
        modeSelector.removeAllSegments()
        for option in selectorOptions{
            modeSelector.insertSegment(withTitle: option, at: selectorOptions.count, animated: false)
        }
        modeSelector.selectedSegmentIndex = 0
        

        mode = .flashCard
        
        //loading screen
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    //Runs after the user hits the Return key on the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Get text from the text field
        let textFieldContents = textField.text!
        
        //determine whether the user answered correctly and update Quiz state
        if textFieldContents.lowercased() == elementList[currentElementIndex].lowercased(){
            answerIsCorrect = true
            correctAnswerCount += 1
        }else{
            answerIsCorrect = false
        }
        
        //The app should now display the answer to the user
        state = .answer
        
        updateUI()
        
        return true
    }
    
    //Alert after quiz finish
    func displayScoreAlert(){
        //creating alert
        let alert = UIAlertController(title: "Quiz Score", message: "Your score is \(correctAnswerCount) out of \(elementList.count)", preferredStyle: .alert)
        
        //creaating action
        let dismissAction = UIAlertAction(title: "OK", style: .default, handler: scoreAlertDismissed(_:))
        
        //adds action
        alert.addAction(dismissAction)
        
        //shows alert on screen
        present(alert, animated: true, completion: nil)
        
        //What did alert when user make action
        func scoreAlertDismissed(_ action: UIAlertAction){
            mode = .flashCard
        }
    }
    
    //reset Flash Card
    func setupFlashCard(){
        elementList = fixedElementList
        state = .queston
        currentElementIndex = 0
    }
    
    //reset Quiz
    func setupQuiz(){
        elementList = fixedElementList.shuffled()
        state = .queston
        currentElementIndex = 0
        answerIsCorrect = false
        correctAnswerCount = 0
    }
    
    ///Updates the app's UI in Flash Card mode
    func updateFlashCardUI(elementName: String){
        //Buttons
        showAnswerButton.isHidden = false
        nextButton.isEnabled = true
        nextButton.setTitle("Next Element", for: .normal)
        //put selector into Flash Card mode
        modeSelector.selectedSegmentIndex = 0
        
        //Text field and keyboard
        textField.isHidden = true
        textField.resignFirstResponder()
        
        //changing AnswerLabel text
        if state == .queston{
            answerLabel.text = "?"
        }else{
            answerLabel.text = elementName
        }
    }
    
    ///Updates the app's UI in Quiz mode
    func updateQuizUI(elementName: String){
        //Buttons
        showAnswerButton.isHidden = true
        if currentElementIndex == elementList.count - 1{
            nextButton.setTitle("Show Score", for: .normal)
        }else{
            nextButton.setTitle("Next Question", for: .normal)
        }
        switch state{
        case .answer:
            nextButton.isEnabled = true
        default:
            nextButton.isEnabled = false
        }
        
        //put selector into Quiz mode
        modeSelector.selectedSegmentIndex = 1
        
        //Text feild and keyboard
        textField.isHidden = false
        switch state{
        case .queston:
            textField.isEnabled = true
            textField.text = ""
            textField.becomeFirstResponder()
        case .answer:
            textField.isEnabled = false
            textField.resignFirstResponder()
        case .score:
            textField.isHidden = true
            textField.resignFirstResponder()
        }
        
        //changing AnswerLabel text
        switch state{
        case .queston:
            answerLabel.text = ""
        case .answer:
            if answerIsCorrect{
                answerLabel.text = "Correct!"
            }else{
                answerLabel.text = "❌ \n Correct Answer: " + elementName
            }
        case .score:
            displayScoreAlert()
        }
        
    }
    
    ///Updates the app's UI  based on its mode and state
    func updateUI(){
        //changing imageView image
        let elementName = elementList[currentElementIndex]
        let image = UIImage(named: elementName)
        imageView.image = image
        
        //Mode-specific UI updates are split into two methods for readability
        switch mode{
        case .flashCard:
            updateFlashCardUI(elementName: elementName)
        case .quiz:
            updateQuizUI(elementName: elementName)
        }
    }
    
    //when the button is pressed AnswerLabel reveal answer
    @IBAction func showAnswer(_ sender: Any) {
        //change the mode to Answer
        state = .answer
        
        updateUI()
    }
    
    //when the button is pressed it moves page to next elemnt
    @IBAction func next(_ sender: Any) {
        currentElementIndex += 1
        
        //checks if the currunt index out of range, if so it reset current index
        if currentElementIndex >= elementList.count{
            currentElementIndex = 0
            if mode == .quiz{
                state = .score
                updateUI()
                return
            }
        }
        //change the mode to Question
        state = .queston
        
        updateUI()
    }
    
    @IBAction func switchModes(_ sender: Any) {
        if modeSelector.selectedSegmentIndex == 0{
            mode = .flashCard
        }else{
            mode = .quiz
        }
    }
}
//
