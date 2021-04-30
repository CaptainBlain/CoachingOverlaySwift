//
//  FlowManager.swift
//  Overlay
//
//  Created by Blain Ellis on 28/04/2021.
//

import UIKit

public class FlowManager {

    public var isStarted: Bool { return currentCoachMark != nil }

    internal unowned let coachMarksViewController: CoachMarksViewController
    internal weak var dataSource: CoachMarksControllerProxyDataSource?

    /// Reference to the currently displayed coach mark, supplied by the `datasource`.
    internal var currentCoachMark: CoachMark?

    init(coachMarksViewController: CoachMarksViewController) {
        self.coachMarksViewController = coachMarksViewController
    }

    // MARK: Internal methods
    internal func startFlow() {

        coachMarksViewController.prepareToShowCoachMarks {
            self.createAndShowCoachMark()
        }
    }

    /// Stop displaying the coach marks and perform some cleanup.

    internal func stopFlow(completion: (() -> Void)? = nil) {

        let animationBlock = { () -> Void in
            self.coachMarksViewController.currentCoachMarkView?.alpha = 0.0
        }

        let completionBlock = { [weak self] (finished: Bool) -> Void in
            guard let strongSelf = self else { return }
            strongSelf.coachMarksViewController.detachFromWindow()
            completion?()
        }

        UIView.animate(withDuration: coachMarksViewController.overlayManager.fadeAnimationDuration,
                       animations: animationBlock)

        coachMarksViewController.overlayManager.showOverlay(false, completion: completionBlock)
    }

    

    /// Ask the datasource, create the coach mark and display it. Also

    internal func createAndShowCoachMark() {

        // Retrieves the current coach mark structure from the datasource.
        // It can't be nil, that's why we'll force unwrap it everywhere.
        currentCoachMark = self.dataSource!.coachMark()

        if coachMarksViewController.instructionsRootView.bounds.isEmpty {
            print(ErrorMessage.Error.overlayEmptyBounds)
            self.stopFlow()
            return
        }
        
        coachMarksViewController.show(coachMark: &currentCoachMark!)
        
    }
}

extension FlowManager: CoachMarksViewControllerDelegate {
    func didTap(coachMarkView: CoachMarkBubbleView?) {
        self.stopFlow()
    }
}
