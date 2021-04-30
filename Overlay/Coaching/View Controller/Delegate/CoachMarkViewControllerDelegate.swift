//
//  CoachMarksViewControllerDelegate.swift
//  Overlay
//
//  Created by Blain Ellis on 28/04/2021.
//

/// Used by the CoachMarksViewController to notify user or system related events.
protocol CoachMarksViewControllerDelegate: AnyObject {
   
    /// - Parameter coachMarkView: the view that was tapped.
    func didTap(coachMarkView: CoachMarkBubbleView?)

}
