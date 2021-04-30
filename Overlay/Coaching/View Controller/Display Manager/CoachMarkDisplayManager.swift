//
//  CoachMarkDisplayManager.swift
//  Overlay
//
//  Created by Blain Ellis on 28/04/2021.
//

import UIKit

/// This class deals with the layout of coach marks.
class CoachMarkDisplayManager {
    // MARK: - Public properties
    weak var dataSource: CoachMarksControllerProxyDataSource!
    weak var overlayManager: OverlayManager?

    // MARK: - Private properties
    /// The coach mark view (the one displayed)
    private var coachMarkBubbleView: CoachMarkBubbleView!

    private let coachMarkLayoutHelper: CoachMarkLayoutHelper

    // MARK: - Initialization
    /// Allocate and initialize the manager.
    ///
    /// - Parameter coachMarkLayoutHelper: auto-layout constraint generator
    init(coachMarkLayoutHelper: CoachMarkLayoutHelper) {
        self.coachMarkLayoutHelper = coachMarkLayoutHelper
    }

    func createCoachMarkBubbleView(from coachMark: CoachMark) -> CoachMarkBubbleView {
        // Asks the data source for the bubble view.
        let coachMarkComponentView = dataSource.coachMarkBubble()

        // Creates the CoachMarkBubbleView, from the supplied component views.
        // CoachMarkBubbleView() is not a failable initializer. We'll force unwrap
        // currentCoachMarkView everywhere.
        return CoachMarkBubbleView(coachMarkComponentView)
    }

    // TODO: ❗️ Refactor this method into smaller components
    /// Hide the given CoachMark View
    ///
    /// - Parameters:
    ///   - coachMarkBubbleView: the coach mark view to show.
    ///   - coachMark: the coach mark metadata
    ///   - completion: a handler to call after the coach mark was successfully hidden.
    func hide(coachMarkBubbleView: UIView, from coachMark: CoachMark, completion: (() -> Void)? = nil) {
        guard let overlay = overlayManager else { return }

        let transitionManager = CoachMarkTransitionManager(coachMark: coachMark)

        overlay.showCutoutPath(false, withDuration: transitionManager.parameters.duration)
        
        guard let animations = transitionManager.animations else {
            UIView.animate(withDuration: transitionManager.parameters.duration,
                           animations: { coachMarkBubbleView.alpha = 0.0 },
                           completion: { _ in
                coachMarkBubbleView.removeFromSuperview()
                completion?()
            })

            return
        }

        let completionBlock: (Bool) -> Void = { success in
            coachMarkBubbleView.removeFromSuperview()
            completion?()
            transitionManager.completion?(success)
        }

        let context = transitionManager.createContext()
        let animationBlock = { animations(context) }

        transitionManager.initialState?()

        if transitionManager.animationType == .regular {
            UIView.animate(withDuration: transitionManager.parameters.duration,
                           delay: transitionManager.parameters.delay,
                           options: transitionManager.parameters.options,
                           animations: animationBlock, completion: completionBlock)
        } else {
            UIView.animateKeyframes(withDuration: transitionManager.parameters.duration,
                                    delay: transitionManager.parameters.delay,
                                    options: transitionManager.parameters.keyframeOptions,
                                    animations: animationBlock, completion: completionBlock)
        }
    }

    // TODO: ❗️ Refactor this method into smaller components
    /// Display the given CoachMark View
    ///
    /// - Parameters:
    ///   - coachMarkBubbleView: the coach mark view to show.
    ///   - coachMark: the coach mark metadata
    ///   - completion: a handler to call after the coach mark was successfully displayed.
    func showNew(coachMarkBubbleView: CoachMarkBubbleView,
                 from coachMark: CoachMark,
                 completion: (() -> Void)? = nil) {
        
        guard let overlay = overlayManager else { return }

        prepare(coachMarkBubbleView: coachMarkBubbleView, forDisplayIn: overlay.overlayView.superview!,
                usingCoachMark: coachMark, andOverlayView: overlay.overlayView)

        overlay.isUserInteractionEnabledInsideCutoutPath =
            coachMark.isUserInteractionEnabledInsideCutoutPath

        let transitionManager = CoachMarkTransitionManager(coachMark: coachMark)

        overlay.showCutoutPath(true, withDuration: transitionManager.parameters.duration)

        guard let animations = transitionManager.animations else {
            // The view shall be invisible, 'cause we'll animate its entry.
            coachMarkBubbleView.alpha = 0.0

            UIView.animate(withDuration: transitionManager.parameters.duration,
                           animations: { coachMarkBubbleView.alpha = 1.0 },
                           completion: { [weak self] _ in
                completion?()
                self?.applyIdleAnimation(to: coachMarkBubbleView, from: coachMark)
            })

            return
        }

        let completionBlock: (Bool) -> Void = { [weak self] success in
            completion?()
            transitionManager.completion?(success)
            self?.applyIdleAnimation(to: coachMarkBubbleView, from: coachMark)
        }

        let context = transitionManager.createContext()
        let animationBlock = { animations(context) }

        transitionManager.initialState?()

        if transitionManager.animationType == .regular {
            UIView.animate(withDuration: transitionManager.parameters.duration,
                           delay: transitionManager.parameters.delay,
                           options: transitionManager.parameters.options,
                           animations: animationBlock, completion: completionBlock)
        } else {
            UIView.animateKeyframes(withDuration: transitionManager.parameters.duration,
                                    delay: transitionManager.parameters.delay,
                                    options: transitionManager.parameters.keyframeOptions,
                                    animations: animationBlock, completion: completionBlock)
        }
    }

    // MARK: - Private methods
    /// Add the current coach mark to the view, making sure it is
    /// properly positioned.
    ///
    /// - Parameters:
    ///   - coachMarkBubbleView: the coach mark to display
    ///   - parentView: the view in which display coach marks
    ///   - coachMark: the coachmark data
    ///   - overlayView: the overlayView (covering everything and showing cutouts)
    private func prepare(coachMarkBubbleView: CoachMarkBubbleView,
                         forDisplayIn parentView: UIView,
                         usingCoachMark coachMark: CoachMark,
                         andOverlayView overlayView: OverlayView) {
        // Add the view and compute its associated constraints.
        parentView.addSubview(coachMarkBubbleView)

        coachMarkBubbleView.widthAnchor.constraint(lessThanOrEqualToConstant: coachMark.maxWidth).isActive = true

        if let cutoutPath = coachMark.cutoutPath {

            generateAndEnableVerticalConstraints(of: coachMarkBubbleView, forDisplayIn: parentView,
                                                 usingCoachMark: coachMark, cutoutPath: cutoutPath,
                                                 andOverlayView: overlayView)

            generateAndEnableHorizontalConstraints(of: coachMarkBubbleView, forDisplayIn: parentView,
                                                  usingCoachMark: coachMark,
                                                  andOverlayView: overlayView)

            overlayView.cutoutPath = cutoutPath
        } else {
            overlayView.cutoutPath = nil
        }
    }

    /// Generate the vertical constraints needed to lay out `coachMarkBubbleView` above or below the
    /// cutout path.
    ///
    /// - Parameters:
    ///   - coachMarkBubbleView: the coach mark to display
    ///   - parentView: the view in which display coach marks
    ///   - coachMark: the coachmark data
    ///   - cutoutPath: the cutout path
    ///   - overlayView: the overlayView (covering everything and showing cutouts)
    private func generateAndEnableVerticalConstraints(of coachMarkBubbleView: CoachMarkBubbleView,
                                                      forDisplayIn parentView: UIView,
                                                      usingCoachMark coachMark: CoachMark,
                                                      cutoutPath: UIBezierPath,
                                                      andOverlayView overlayView: OverlayView) {
        
        let offset = coachMark.gapBetweenCoachMarkAndCutoutPath

        // Depending where the cutoutPath sits, the coach mark will either
        // stand above or below it.
        if coachMarkBubbleView.bubbleView.peakSide == .Bottom {
            let constant = -(parentView.frame.size.height -
                cutoutPath.bounds.minY + offset)

            coachMarkBubbleView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor,
                                                  constant: constant).isActive = true
        }
        else {
            let constant = cutoutPath.bounds.maxY + offset
            coachMarkBubbleView.topAnchor.constraint(equalTo: parentView.topAnchor,
                                               constant: constant).isActive = true 
        }
    }

    /// Generate horizontal constraints needed to lay out `coachMarkBubbleView` at the
    /// right place.
    /// - Parameters:
    ///   - coachMarkBubbleView: the coach mark to display
    ///   - parentView: the view in which display coach marks
    ///   - coachMark: the coachmark data
    ///   - overlayView: the overlayView (covering everything and showing cutouts)
    private func generateAndEnableHorizontalConstraints(of coachMarkBubbleView: CoachMarkBubbleView,
                                                        forDisplayIn parentView: UIView,
                                                        usingCoachMark coachMark: CoachMark,
                                                        andOverlayView overlayView: OverlayView) {
        
        let horizontalAlignment = dataSource.coachMarkBubbleHorizontalAlignment()
        // Generating the constraints for the first pass. This constraints center
        // the view around the point of interest.
        let constraints = coachMarkLayoutHelper.constraints(for: coachMarkBubbleView,
                                                            coachMark: coachMark,
                                                            parentView: parentView,
                                                            horizontalAlignment: horizontalAlignment)
        // Laying out the view
        parentView.addConstraints(constraints)
        parentView.setNeedsLayout()
        parentView.layoutIfNeeded()

    }

    /// Fetch and perform user-defined idle animation on given coach mark view.
    ///
    /// - Parameters:
    ///   - coachMarkBubbleView: the view to animate.
    ///   - coachMark: the related coach mark metadata.
    ///   - index: the index of the coach mark.
    private func applyIdleAnimation(to coachMarkBubbleView: UIView, from coachMark: CoachMark) {
        let transitionManager = CoachMarkAnimationManager(coachMark: coachMark)

        if let animations = transitionManager.animations {
            let context = transitionManager.createContext()
            let animationBlock = { animations(context) }

            if transitionManager.animationType == .regular {
                UIView.animate(withDuration: transitionManager.parameters.duration,
                               delay: transitionManager.parameters.delay,
                               options: transitionManager.parameters.options,
                               animations: animationBlock, completion: nil)
            } else {
                UIView.animateKeyframes(withDuration: transitionManager.parameters.duration,
                                        delay: transitionManager.parameters.delay,
                                        options: transitionManager.parameters.keyframeOptions,
                                        animations: animationBlock, completion: nil)
            }
        }
    }
}
