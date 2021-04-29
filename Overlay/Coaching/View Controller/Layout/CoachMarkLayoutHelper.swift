// Copyright (c) 2016-present Frédéric Maquin <fred@ephread.com> and contributors.
// Licensed under the terms of the MIT License.

import UIKit

class CoachMarkLayoutHelper {

    func constraints(
        for coachMarkView: CoachMarkBubbleView,
        coachMark: CoachMark,
        parentView: UIView,
        horizontalAlignment: HorizontalAlignment = .centered
    ) -> [NSLayoutConstraint] {
        if coachMarkView.superview != parentView {
            print(ErrorMessage.Error.notAChild)
            return []
        }

        switch horizontalAlignment {
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
            offset = parentView.center.x - pointOfInterest.x
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
}


