//
//  CoachMarksViewController.swift
//  Overlay
//
//  Created by Blain Ellis on 28/04/2021.
//
import UIKit

// MARK: - Main Class
/// Handles a set of coach marks, and display them successively.
class CoachMarksViewController: UIViewController {
    // MARK: - Private properties

    private var presentationFashion: PresentationFashion = .window
    private weak var viewControllerDisplayedUnder: UIViewController?

    // MARK: - Internal properties
    weak var delegate: CoachMarksViewControllerDelegate?

    var coachMarkDisplayManager: CoachMarkDisplayManager!
    var overlayManager: OverlayManager! {
        didSet {
            coachMarkDisplayManager.overlayManager = overlayManager
        }
    }

    var currentCoachMarkView: CoachMarkBubbleView?

    lazy var instructionsRootView: InstructionsRootView = {
        let view = InstructionsRootView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        return view
    }()


    // Called after the view was loaded.
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
    }

    override func loadView() { view = PassthroughView() }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        overlayManager.updateStyle(with: traitCollection)
    }

    // MARK: - Internal Methods
    /// Will attach the controller as a child of the given window.
    ///
    /// - Parameters:
    ///   - window: the window which will hold the controller
    ///   - viewController: the controller displayed under the window
    ///   - windowLevel: the level at which display the window.
    func attach(to window: UIWindow, over viewController: UIViewController, at windowLevel: UIWindow.Level? = nil) {
        
        if #available(iOS 13.0, *) {
            if let windowLevel = windowLevel,
               windowLevel.rawValue >= UIWindow.Level.statusBar.rawValue {
                print(ErrorMessage.Warning.unsupportedWindowLevel)
            }
        }

        presentationFashion = .window
        window.windowLevel = windowLevel ?? UIWindow.Level.normal + 1

        viewControllerDisplayedUnder = viewController

        view.addSubview(instructionsRootView)
        instructionsRootView.fillSuperview()

        addOverlayView()

        window.rootViewController = self
        window.isHidden = false
    }

    /// Will attach the controller as a child of the given view controller and add
    /// Instructions-related view to the window of the given view controller.
    ///
    /// - Parameter viewController: the controller to which attach Instructions
    func attachToWindow(of viewController: UIViewController) {
        guard let window = viewController.view?.window else {
            print(ErrorMessage.Error.couldNotBeAttached)
            return
        }

        presentationFashion = .viewControllerWindow

        viewController.addChild(self)
        view.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(view)
        view.fillSuperview()

        self.didMove(toParent: viewController)

        addRootView(to: window)
        addOverlayView()

        window.layoutIfNeeded()
    }

    /// Will attach the controller as a child of the given view controller.
    ///
    /// - Parameter viewController: the controller to which attach the current view controller
    func attach(to viewController: UIViewController) {
        presentationFashion = .viewController

        viewController.addChild(self)
        view.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(view)
        view.fillSuperview()

        view.addSubview(instructionsRootView)
        instructionsRootView.fillSuperview()
        addOverlayView()

        self.didMove(toParent: viewController)
    }

    func addRootView(to window: UIWindow) {
        window.addSubview(instructionsRootView)
        instructionsRootView.fillSuperview()
    }

    /// Detach the controller from its parent view controller.
    func detachFromWindow() {
        switch presentationFashion {
        case .window:

            let window = view.window
            window?.isHidden = true
            window?.rootViewController = nil
            window?.accessibilityIdentifier = nil
        case .viewControllerWindow, .viewController:
            self.instructionsRootView.removeFromSuperview()
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
   
        }
    }

    // MARK: - Private Methods
    private func addOverlayView() {
        instructionsRootView.addSubview(overlayManager.overlayView)
        overlayManager.overlayView.fillSuperview()
    }
}

// MARK: - Coach Mark Display
extension CoachMarksViewController {
    // MARK: - Internal Methods
    func prepareToShowCoachMarks(_ completion: @escaping () -> Void) {
        disableInteraction()

        overlayManager.showOverlay(true, completion: { _ in
            self.enableInteraction()
            completion()
        })
    }

    func hide(coachMark: CoachMark, completion: (() -> Void)? = nil) {
        guard let currentCoachMarkView = currentCoachMarkView else {
            completion?()
            return
        }

        disableInteraction()

        coachMarkDisplayManager.hide(coachMarkBubbleView: currentCoachMarkView, from: coachMark) {
            self.enableInteraction()
            completion?()
        }
    }

    func show(coachMark: inout CoachMark, completion: (() -> Void)? = nil) {
        disableInteraction()

        let passthrough = coachMark.isUserInteractionEnabledInsideCutoutPath ||
                          overlayManager.areTouchEventsForwarded
        let coachMarkBubbleView = coachMarkDisplayManager.createCoachMarkBubbleView(from: coachMark)

        currentCoachMarkView = coachMarkBubbleView
        coachMarkDisplayManager.showNew(coachMarkBubbleView: coachMarkBubbleView, from: coachMark) {
            self.instructionsRootView.passthrough = passthrough
            self.enableInteraction()
            completion?()
        }
    }

    // MARK: - Private Methods
    private func disableInteraction() {
        instructionsRootView.passthrough = false
        instructionsRootView.isUserInteractionEnabled = true
        overlayManager.overlayView.isUserInteractionEnabled = false
        currentCoachMarkView?.isUserInteractionEnabled = false
    }

    private func enableInteraction() {
        instructionsRootView.isUserInteractionEnabled = true
        overlayManager.overlayView.isUserInteractionEnabled = true
        currentCoachMarkView?.isUserInteractionEnabled = true
    }
}


// MARK: - Private Extension: User Events
private extension CoachMarksViewController {
    /// Add touch up target to the current coach mark view.
    func addTargetToCurrentCoachView() {
        
    }
    
    /// Remove touch up target from the current coach mark view.
    func removeTargetFromCurrentCoachView() {
 
    }
    /// - Parameter sender: the object sending the message
    @objc func didTapCoachMark(_ sender: AnyObject?) {
        delegate?.didTap(coachMarkView: currentCoachMarkView)
    }
    
}
