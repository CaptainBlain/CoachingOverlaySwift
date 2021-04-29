// Copyright (c) 2015-present Frédéric Maquin <fred@ephread.com> and contributors.
// Licensed under the terms of the MIT License.

import UIKit

// MARK: - Main Class
/// Handles a set of coach marks, and display them successively.
public class CoachMarkController {
    // MARK: - Public properties
    /// Implement the data source protocol and supply
    /// the coach marks to display.
    public weak var dataSource: CoachMarksControllerDataSource?

    /// Hide the UI.
    private(set) public lazy var overlay: OverlayManager = {
        let overlay = OverlayManager()
        overlay.overlayDelegate = self
        return overlay
    }()

    /// Provide cutout path related helpers.
    private(set) public lazy var helper: CoachMarkHelper! = {
        let instructionsTopView = self.coachMarksViewController.instructionsRootView
        return CoachMarkHelper(instructionsRootView: instructionsTopView)
    }()

    /// Handles the flow of coachmarks.
    private(set) public lazy var flow: FlowManager = {
        let flowManager = FlowManager(coachMarksViewController: self.coachMarksViewController)
        flowManager.dataSource = self
        self.coachMarksViewController.delegate = flowManager

        return flowManager
    }()

    // MARK: - Private properties
    private weak var controllerWindow: UIWindow?
    private var coachMarksWindow: UIWindow?

    /// Handle the UI part
    private lazy var coachMarksViewController: CoachMarksViewController = {
        let coachMarkController = CoachMarksViewController()
        coachMarkController.coachMarkDisplayManager = buildCoachMarkDisplayManager()
        coachMarkController.overlayManager = overlay
        return coachMarkController
    }()

    // MARK: - Lifecycle
    public init() { }
}


// MARK: - Flow management
public extension CoachMarkController {
    /// Start instructions in the given context.
    ///
    /// - Parameter presentationContext: the context in which show Instructions
    
    func start(in presentationContext: PresentationContext) {
        
        // If coach marks are currently being displayed, calling `start(in: )` doesn't do anything.
        if flow.isStarted { return }
        
        switch presentationContext {
        case .newWindow(let viewController, let windowLevel):
            
            controllerWindow = viewController.view.window
            coachMarksWindow = coachMarksWindow ?? buildNewWindow()
            coachMarksViewController.attach(to: coachMarksWindow!, over: viewController,
                                            at: windowLevel)
        case .currentWindow(let viewController):
            coachMarksViewController.attachToWindow(of: viewController)
        case .viewController(let viewController):
            coachMarksViewController.attach(to: viewController)
        }
        
        flow.startFlow()
    }
    
    /// Stop the flow of coach marks. Don't forget to call this method in viewDidDisappear or
    /// viewWillDisappear.
    func stop() {
        flow.stopFlow { [weak self] in
            self?.coachMarksWindow = nil
        }
    }
}

// MARK: - Protocol Conformance | OverlayViewDelegate


extension CoachMarkController: OverlayManagerDelegate {
    func didReceivedSingleTap() {
        flow.stopFlow()
    }
}

extension CoachMarkController: CoachMarksControllerProxyDataSource {

    func coachMark() -> CoachMark {
        return dataSource!.getCoachMark(for: self)
    }
    
    func coachMarkBubble() -> CoachMarkBubble {
        return dataSource!.getCoachMarkBubble(for: self)
    }
    
    func coachMarkBubbleHorizontalAlignment() -> HorizontalAlignment {
        return dataSource!.getCoachMarkBubbleHorizontalAlignment(for: self)
    }
}


// MARK: - Private builders
private extension CoachMarkController {
    func buildCoachMarkDisplayManager() -> CoachMarkDisplayManager {
        let coachMarkDisplayManager =
            CoachMarkDisplayManager(coachMarkLayoutHelper: CoachMarkLayoutHelper())
        coachMarkDisplayManager.dataSource = self

        return coachMarkDisplayManager
    }

    func buildNewWindow() -> UIWindow {

        if #available(iOS 13.0, *) {
            if let windowScene = UIApplication.shared.activeScene {
                let window = InstructionsWindow(windowScene: windowScene)
                window.frame = UIApplication.shared.keyWindow?.bounds ?? UIScreen.main.bounds

                return window
            }
        }
        else {
            let bounds = UIApplication.shared.keyWindow?.bounds ?? UIScreen.main.bounds
            return InstructionsWindow(frame: bounds)
        }

        return InstructionsWindow(frame: UIScreen.main.bounds)
    }
}
