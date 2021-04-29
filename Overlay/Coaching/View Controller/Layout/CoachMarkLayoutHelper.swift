// Copyright (c) 2016-present Frédéric Maquin <fred@ephread.com> and contributors.
// Licensed under the terms of the MIT License.

import UIKit

class CoachMarkLayoutHelper {
    var layoutDirection: UIUserInterfaceLayoutDirection = .leftToRight

    // TODO: Improve the layout system. Make it smarter.
    func constraints(
        for coachMarkView: CoachMarkBubbleView,
        coachMark: CoachMark,
        parentView: UIView
    ) -> [NSLayoutConstraint] {
        if coachMarkView.superview != parentView {
            print(ErrorMessage.Error.notAChild)
            return []
        }

        self.layoutDirection = UIView.userInterfaceLayoutDirection(
            for: parentView.semanticContentAttribute
        )

        let computedProperties = CoachMarkComputedProperties(layoutDirection: self.layoutDirection,
                                                             horizontalAlignment: .centered)

        switch computedProperties.horizontalAlignment {
        case .leading:
            return leadingConstraints(for: coachMarkView, withCoachMark: coachMark,
                                      inParentView: parentView)
        case .centered:
            return middleConstraints(for: coachMarkView, withCoachMark: coachMark,
                                     inParentView: parentView)
        case .trailing:
            return trailingConstraints(for: coachMarkView, withCoachMark: coachMark,
                                       inParentView: parentView)
        }
    }

    private func leadingConstraints(for coachMarkView: CoachMarkBubbleView,
                                    withCoachMark coachMark: CoachMark,
                                    inParentView parentView: UIView
    ) -> [NSLayoutConstraint] {

        if #available(iOS 11.0, *) {
            let layoutGuide = parentView.safeAreaLayoutGuide

            return [
                coachMarkView.leadingAnchor
                             .constraint(equalTo: layoutGuide.leadingAnchor,
                                         constant: coachMark.horizontalMargin),
                coachMarkView.widthAnchor
                             .constraint(lessThanOrEqualToConstant: coachMark.maxWidth),
                coachMarkView.trailingAnchor
                             .constraint(lessThanOrEqualTo: layoutGuide.trailingAnchor,
                                         constant: -coachMark.horizontalMargin)
            ]
        }

        let visualFormat = """
                           H:|-(==\(coachMark.horizontalMargin))-\
                           [currentCoachMarkView(<=\(coachMark.maxWidth))]-\
                           (>=\(coachMark.horizontalMargin))-|
                           """

        return NSLayoutConstraint.constraints(withVisualFormat: visualFormat,
                                              options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                              metrics: nil,
                                              views: ["currentCoachMarkView": coachMarkView])
    }

    private func middleConstraints(for coachMarkView: CoachMarkBubbleView,
                                   withCoachMark coachMark: CoachMark,
                                   inParentView parentView: UIView
    ) -> [NSLayoutConstraint] {
        let maxWidth = min(coachMark.maxWidth, (parentView.bounds.width - 2 *
                                                coachMark.horizontalMargin))

        let visualFormat = "H:[currentCoachMarkView(<=\(maxWidth)@1000)]"

        var constraints =
            NSLayoutConstraint.constraints(withVisualFormat: visualFormat,
                                           options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                           metrics: nil,
                                           views: ["currentCoachMarkView": coachMarkView])

        var offset: CGFloat = 0

        if let pointOfInterest = coachMark.pointOfInterest {
            if layoutDirection == .leftToRight {
                offset = parentView.center.x - pointOfInterest.x
            } else {
                offset = pointOfInterest.x - parentView.center.x
            }
        }

        constraints.append(NSLayoutConstraint(
            item: coachMarkView, attribute: .centerX, relatedBy: .equal,
            toItem: parentView, attribute: .centerX,
            multiplier: 1, constant: -offset
        ))

        return constraints
    }

    private func trailingConstraints(for coachMarkView: CoachMarkBubbleView,
                                     withCoachMark coachMark: CoachMark,
                                     inParentView parentView: UIView
    ) -> [NSLayoutConstraint] {
        if #available(iOS 11.0, *) {
            let layoutGuide = parentView.safeAreaLayoutGuide

            return [
                coachMarkView.leadingAnchor
                    .constraint(greaterThanOrEqualTo: layoutGuide.leadingAnchor,
                                constant: coachMark.horizontalMargin),
                coachMarkView.widthAnchor
                    .constraint(lessThanOrEqualToConstant: coachMark.maxWidth),
                coachMarkView.trailingAnchor
                    .constraint(equalTo: layoutGuide.trailingAnchor,
                                constant: -coachMark.horizontalMargin)
            ]
        }

        let visualFormat = """
                           H:|-(>=\(coachMark.horizontalMargin))-\
                           [currentCoachMarkView(<=\(coachMark.maxWidth))]-\
                           (==\(coachMark.horizontalMargin))-|
                           """

        return NSLayoutConstraint.constraints(withVisualFormat: visualFormat,
                                              options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                              metrics: nil,
                                              views: ["currentCoachMarkView": coachMarkView])
    }

 
    /// Compute the segment index (for now the screen is separated
    /// in two horizontal areas and depending in which one the coach
    /// mark stand, it will be laid out in a different way.
    ///
    /// - Parameters:
    ///   - coachMark: coachmark data.
    ///   - layoutDirection: the layout direction (LTR or RTL)
    ///   - frame: frame of the parent view
    ///
    /// - Returns: the alignment
    private func computeHorizontalAlignment(
        of coachMark: CoachMark,
        forLayoutDirection layoutDirection: UIUserInterfaceLayoutDirection,
        inFrame frame: CGRect
    ) -> CoachMarkHorizontalAlignment {
        if let pointOfInterest = coachMark.pointOfInterest, frame.size.width > 0 {
            let segmentIndex = Int(ceil(2 * pointOfInterest.x / frame.size.width))

            switch (segmentIndex, layoutDirection) {
            case (1, .leftToRight): return .leading
            case (2, .leftToRight): return .trailing
            case (1, .rightToLeft): return .trailing
            case (2, .rightToLeft): return .leading
            default: return .centered
            }
        } else {
            if coachMark.pointOfInterest == nil {
                print(ErrorMessage.Info.nilPointOfInterestCenterAlignment)
            } else {
                print(ErrorMessage.Warning.frameWithNoWidth)
            }

            return .centered
        }
    }
}

struct CoachMarkComputedProperties {
    let layoutDirection: UIUserInterfaceLayoutDirection
    let horizontalAlignment: CoachMarkHorizontalAlignment
}

enum CoachMarkHorizontalAlignment {
    case leading, centered, trailing
}
