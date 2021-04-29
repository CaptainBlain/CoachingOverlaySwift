// Copyright (c) 2016-present Frédéric Maquin <fred@ephread.com> and contributors.
// Licensed under the terms of the MIT License.

/// Used by the CoachMarksViewController to notify user or system related events.
protocol CoachMarksViewControllerDelegate: AnyObject {
   
    /// - Parameter coachMarkView: the view that was tapped.
    func didTap(coachMarkView: CoachMarkBubbleView?)

}
