import UIKit

public enum PeakSide: Int {
    case Top
    case Left
    case Right
    case Bottom
}

public class CoachMarkBubble: UIControl {

    var lineWidth: CGFloat = 4 { didSet { setNeedsDisplay() } }
    var cornerRadius: CGFloat = 8 { didSet { setNeedsDisplay() } }
    
    var strokeColor: UIColor = #colorLiteral(red: 0.3450980392, green: 0.2509803922, blue: 0.7333333333, alpha: 1) { didSet { setNeedsDisplay() } }
    var fillColor: UIColor = #colorLiteral(red: 0.3450980392, green: 0.2509803922, blue: 0.7333333333, alpha: 1) { didSet { setNeedsDisplay() } }
    
    /// - Parameter peakWidth: The width of the peak on the bubble
    var peakWidth: CGFloat  = 10 { didSet { setNeedsDisplay() } }
    var peakHeight: CGFloat = 10 { didSet { setNeedsDisplay() } }
    var peakOffset: CGFloat = 0 { didSet { setNeedsDisplay() } }
    
    var text: String  = "" { didSet { setNeedsDisplay() } }
    var highlightText: String  = "" { didSet { setNeedsDisplay() } }
    
    var textView: UITextView!
    var textStorage: NSTextStorage!
    
    public var peakSide: PeakSide = .Top
    
    // MARK: - Initialization
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }

    public init(frame: CGRect, peakSide: PeakSide, hintText: String, highlightText: String?) {
        super.init(frame: frame)
        self.peakSide = peakSide
        self.text = hintText
        self.highlightText = highlightText ?? ""

    }

    convenience public init(peakSide: PeakSide, hintText: String, highlightText: String?) {
        self.init(frame: CGRect.zero, peakSide: peakSide, hintText: hintText, highlightText: highlightText)
    }

    convenience public init() {
        self.init(frame: CGRect.zero)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError(ErrorMessage.Fatal.doesNotSupportNSCoding)
    }
    
//    private func layoutViewComposition() {
//        translatesAutoresizingMaskIntoConstraints = false
//
//        //self.addSubview(bubbleView)
//        //self.addConstraints(bubbleView.makeConstraintToFillSuperviewHorizontally())
//
//        self.topAnchor.constraint(equalTo: topAnchor).isActive = true
//        self.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
//    }
}

extension CoachMarkBubble {

    public override func draw(_ rectangle: CGRect) {
        
        //Add a bounding area so we can fit the peak in the view
        let rect = bounds.insetBy(dx: (peakHeight + lineWidth/2), dy: (peakHeight + lineWidth/2))
        
        drawBubble(rect)
        drawTitle(rect)
        drawTextView(rect)
        drawCloseButton(rect)
        
    }
    
    func drawBubble(_ rect: CGRect) {
        //Peak height
        let h: CGFloat = peakHeight * sqrt(3.0) / 2
        
        //create the path
        let path = UIBezierPath()
        path.lineWidth = lineWidth
        
        // Start of bubble (Top Left)
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
        path.addQuadCurve(to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY),
                          controlPoint: CGPoint(x: rect.minX, y: rect.minY))
        
        if peakSide == .Top {
            let x = rect.midX
            let y = rect.minY
            path.addLine(to: CGPoint(x: (x + peakOffset) - peakWidth, y: y))
            path.addLine(to: CGPoint(x: (x + peakOffset), y: y - h))
            path.addLine(to: CGPoint(x: (x + peakOffset) + peakWidth, y: y))
        }
        
        // Top Right
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + cornerRadius),
                          controlPoint: CGPoint(x: rect.maxX, y: rect.minY))
        
        if peakSide == .Right {
            let x = rect.maxX
            let y = rect.midY
            path.addLine(to: CGPoint(x: x, y: (y + peakOffset) - peakWidth))
            path.addLine(to: CGPoint(x: x + h, y: (y + peakOffset)))
            path.addLine(to: CGPoint(x: x, y: (y + peakOffset) + peakWidth))
        }
        
        // Bottom Right
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
        path.addQuadCurve(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY),
                          controlPoint: CGPoint(x: rect.maxX, y: rect.maxY))
        
        if peakSide == .Bottom {
            let x = rect.minX
            let y = rect.maxY
            path.addLine(to: CGPoint(x: (x + peakOffset) + peakWidth, y: y))
            path.addLine(to: CGPoint(x: (x + peakOffset), y: y + h))
            path.addLine(to: CGPoint(x: (x + peakOffset) - peakWidth, y: y))
        }
        
        //Bottom Left
        path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY - cornerRadius), controlPoint: CGPoint(x: rect.minX, y: rect.maxY))
        
        if peakSide == .Left {
            let x = rect.minX
            let y = rect.midY
            path.addLine(to: CGPoint(x: x, y: (y + peakOffset) + peakWidth))
            path.addLine(to: CGPoint(x: x - h, y: (y + peakOffset)))
            path.addLine(to: CGPoint(x: x, y: (y + peakOffset) - peakWidth))
        }
        
        
        // Back to start
        path.addLine(to: CGPoint(x: rect.origin.x, y: rect.minY + cornerRadius))
        
        //set and draw stroke color
        strokeColor.setStroke()
        path.stroke()
        
        //set and draw fill color
        fillColor.setFill()
        path.fill()
    }
    
    func drawTitle(_ rect: CGRect) {
        
        let attrs = getAttributesDictionary(ForFont: UIFont.helvetica(size: 18.0), color: #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1), andTextAlignment: .left)
        let title = "Tip"
        title.draw(in: rect.insetBy(dx: 10, dy: 10), withAttributes: attrs)
    }
    
    func drawTextView(_ rect: CGRect) {
        
        let attrs = getAttributesDictionary(ForFont: UIFont.helveticaThin(size: 16.0), color: #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1))
        
        //Instantiate an instance of your custom text storage and initialize it with an attributed string holding the content of the note.
        let attrString = NSMutableAttributedString(string: text, attributes: attrs)
        
        //If we find the text that needs higlighting
        if let substringRange = text.range(of: highlightText) {
            //Get the range
            let nsRange = NSRange(substringRange, in: text)
            let ast = NSMutableAttributedString(string: highlightText, attributes: getAttributesDictionary(ForFont: UIFont.helvetica(size: 16.0), color: #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1)))
            //Updte the string
            attrString.replaceCharacters(in: nsRange, with: ast)
        }
        
        let padding = CGSize(width: 10, height: 38)
        let frame = CGRect(x: rect.minX + padding.width, y: rect.minY + padding.height, width: rect.width, height: rect.maxY - padding.height - 12)
        attrString.draw(in: frame)
        
    }
    
    func drawCloseButton(_ rect: CGRect) {
      
        let closebuttonRect = CGRect(x: rect.maxX - 22, y: 16, width: 18, height: 18)
        let path = UIBezierPath(roundedRect: closebuttonRect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 4, height: 4))
        
        #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).setFill()
        path.fill()
        
        #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1).setStroke()
        path.lineWidth = 2
        path.stroke()
        
        //create the path
        let closePath = UIBezierPath()
        
        //set the path's line width to the height of the stroke
        closePath.lineWidth = 2
        
        let closeIconPadding: CGFloat = 6
        let closeRect = closebuttonRect.insetBy(dx: closeIconPadding, dy: closeIconPadding)
        //move the initial point of the path
        closePath.move(to: CGPoint(x: closeRect.minX, y: closeRect.minY))
        //add a point to the path at the end of the stroke
        closePath.addLine(to: CGPoint(x: closeRect.maxX, y: closeRect.maxY))
        
        closePath.move(to: CGPoint(x: closeRect.minX, y: closeRect.maxY))
        
        closePath.addLine(to: CGPoint(x: closeRect.maxX, y: closeRect.minY))
        
        //set the stroke color
        UIColor.white.setStroke()
        
        //draw the stroke
        closePath.stroke()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = .clear
        if textView != nil {
            //Add a bounding area so we can fit the peak in the view
            let rect = bounds.insetBy(dx: (peakHeight + lineWidth/2), dy: (peakHeight + lineWidth/2))
            let exclusionPath = buttonPath(rect)
            textView.textContainer.exclusionPaths = [exclusionPath]
        }
    }
    
    func buttonPath(_ rect: CGRect) -> UIBezierPath {
        
        let size = CGSize(width: 100, height: 90)
        let buttonRect = CGRect(x: rect.maxX - size.width, y: rect.maxY - size.height, width: size.width, height: size.height)
        return UIBezierPath(rect: buttonRect)
    }
    
    
    
    func getAttributesDictionary(ForFont font: UIFont, color: UIColor, andTextAlignment textAlignment: NSTextAlignment = .left) -> Dictionary<NSAttributedString.Key, Any> {
        
        let style = NSMutableParagraphStyle()
        style.alignment = textAlignment
        
        return [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: color, NSAttributedString.Key.paragraphStyle: style]
        
    }
}

extension UIFont {
    
    static func helvetica(size: CGFloat) -> UIFont {
        
        return UIFont(name: "HelveticaNeue-Bold", size: size)!
    }
    static func helveticaThin(size: CGFloat) -> UIFont {
        
        return UIFont(name: "HelveticaNeue-Thin", size: size)!
    }
    
}
