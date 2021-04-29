// Copyright (c) 2016-present Frédéric Maquin <fred@ephread.com> and contributors.
// Licensed under the terms of the MIT License.

import UIKit

public class CoachMarkHelper {

    let instructionsRootView: InstructionsRootView

    init(instructionsRootView: InstructionsRootView) {
        self.instructionsRootView = instructionsRootView
    }

    /// Returns a new coach mark with a cutout path set to be
    /// around the provided UIView. The cutout path will be slightly
    /// larger than the view and have rounded corners, however you can
    /// bypass the default creator by providing a block.
    ///
    /// The point of interest (defining where the arrow will sit, horizontally)
    /// will be the one provided.
    ///
    /// - Parameter view: the view around which create the cutoutPath
    /// - Parameter pointOfInterest: the point of interest toward which the arrow should point
    /// - Parameter bezierPathBlock: a block customizing the cutoutPath
    public func makeCoachMark(for view: UIView? = nil,
                              cutoutPathMaker: CutoutPathMaker? = nil, arrowOrientation: PeakSide = .Bottom) -> CoachMark {
        var coachMark = CoachMark()
        coachMark.arrowOrientation = arrowOrientation
        guard let view = view else {
            return coachMark
        }

        self.update(coachMark: &coachMark, usingView: view, cutoutPathMaker: cutoutPathMaker)

        return coachMark
    }


    /// Updates the given coach mark with a cutout path set to be
    /// around the provided UIView. The cutout path will be slightly
    /// larger than the view and have rounded corners, however you can
    /// bypass the default creator by providing a block.
    ///
    /// The point of interest (defining where the arrow will sit, horizontally)
    /// will be the one provided.
    ///
    /// - Parameter coachMark: the CoachMark to update
    /// - Parameter forView: the view around which create the cutoutPath
    /// - Parameter bezierPathBlock: a block customizing the cutoutPath
    internal func update(coachMark: inout CoachMark,
                         usingView view: UIView? = nil,
                         cutoutPathMaker: CutoutPathMaker? = nil) {
        guard let view = view else { return }

        let convertedFrame = instructionsRootView.convert(view.frame, from: view.superview)

        let bezierPath: UIBezierPath

        if let makeCutoutPathWithFrame = cutoutPathMaker {
            bezierPath = makeCutoutPathWithFrame(convertedFrame)
        } else {
            bezierPath = UIBezierPath(roundedRect: convertedFrame.insetBy(dx: -4, dy: -4),
                                      byRoundingCorners: .allCorners,
                                      cornerRadii: CGSize(width: 4, height: 4))
        }

        coachMark.cutoutPath = bezierPath

    }

}

public typealias CutoutPathMaker = (_ frame: CGRect) -> UIBezierPath
