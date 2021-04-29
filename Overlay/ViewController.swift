//
//  ViewController.swift
//  Overlay
//
//  Created by Blain Ellis on 28/04/2021.
//

import UIKit

class ViewController: UIViewController {
   
    @IBOutlet weak var button: UIButton!
    
    var coachMarksController = CoachMarkController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        coachMarksController.dataSource = self
        coachMarksController.overlay.isUserInteractionEnabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        coachMarksController.start(in: .window(over: self))
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        coachMarksController.stop()
    }

}

extension ViewController: CoachMarksControllerDataSource {

    func getCoachMark(for coachMarksController: CoachMarkController) -> CoachMark {
        
        return coachMarksController.helper.makeCoachMark(for: self.button)
    }

    func getCoachMarkBubble(for coachMarksController: CoachMarkController) -> CoachMarkBubble {
        
        
        let coachMarkBubble = CoachMarkBubble(frame: CGRect(x: 0, y: 0, width: 250, height: 140), peakSide: .Top, hintText: "This is a bubble", highlightText: "")
        
        return coachMarkBubble
    }



}
