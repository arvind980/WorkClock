//
//  TimeDisplayView.swift
//  Clocks


import UIKit

class TimeDisplayView: UIView {
	var components: DateComponents { didSet { setNeedsDisplay() } }
	
	override init(frame: CGRect) {
		components = DateComponents(hour: 0, minute: 0, second: 0)
		super.init(frame: frame)
	}
	
	required init?(coder aDecoder: NSCoder) {
		components = DateComponents(hour: 0, minute: 0, second: 0)
		super.init(coder: aDecoder)
	}
	
	override func layoutSubviews() {
		self.setNeedsDisplay()
	}
	
	@discardableResult
	func updateDisplay(timezone: Timezone) -> DateComponents {
		guard let tz = TimeZone(identifier: timezone.identifier) else { return DateComponents() }
		var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
		calendar.timeZone = tz
		let dateComponents = calendar.dateComponents([.hour, .minute, .second], from: Date())
		self.components = dateComponents
		return dateComponents
	}
	
	func radialMark(center: CGPoint, outerRadius: CGFloat, innerRadius: CGFloat, sixtieths: CGFloat, color: UIColor, lineWidth: CGFloat) {
		let path = UIBezierPath()
		let angle = -(2 * sixtieths / 60 + 1) * CGFloat.pi
		path.move(to: CGPoint(x: center.x + innerRadius * sin(angle), y: center.y + innerRadius * cos(angle)))
		path.addLine(to: CGPoint(x: center.x + outerRadius * sin(angle), y: center.y + outerRadius * cos(angle)))
		color.setStroke()
		path.lineWidth = lineWidth
		path.lineCapStyle = .round
		path.stroke()
	}
	
	override func draw(_ rect: CGRect) {
		let radius = 0.4 * min(self.bounds.width, self.bounds.height)
		let center = CGPoint(x: 0.5 * self.bounds.width + self.bounds.minX, y: 0.5 * self.bounds.height + self.bounds.minY)
		
		let small = radius < 50
		
		let background = UIBezierPath(ovalIn: CGRect(x: center.x - 1.0 * radius, y: center.y - 1.0 * radius, width: 2.0 * radius, height: 2.0 * radius))
		if let context = UIGraphicsGetCurrentContext() {
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [UIColor.white.cgColor, UIColor.white.cgColor] as CFArray, locations: nil)!
			background.addClip()
			context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: center.y - radius), end: CGPoint(x: 0, y: center.y + radius), options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
		}
		
		for i in 0...11 {
			radialMark(center: center, outerRadius: radius, innerRadius: 0.85 * radius, sixtieths: CGFloat(i) * 5, color: UIColor.darkGray, lineWidth: 1)
		}
        
        for i in 0...59 {
            radialMark(center: center, outerRadius: radius, innerRadius: 0.94 * radius, sixtieths: CGFloat(i) * 1, color: UIColor.darkGray, lineWidth: 0.75)
        }
		
//		let border = UIBezierPath(ovalIn: CGRect(x: center.x - 1.0 * radius, y: center.y - 1.0 * radius, width: 2.0 * radius, height: 2.0 * radius))
//        UIColor.darkGray.setStroke()
//		border.lineWidth = small ? 1.0 : 6.0
//		border.stroke()
		
		radialMark(center: center, outerRadius: 0.5 * radius, innerRadius: 0, sixtieths: 5 * CGFloat(components.hour ?? 0) + CGFloat(components.minute ?? 0) / 12 + CGFloat(components.second ?? 0) / 720, color: UIColor.black, lineWidth: small ? 2.0 : 4.0)
		radialMark(center: center, outerRadius: 0.8 * radius, innerRadius: 0, sixtieths: CGFloat(components.minute ?? 0) + CGFloat(components.second ?? 0) / 60, color: UIColor.darkGray, lineWidth: small ? 1.0 : 2.5)
		radialMark(center: center, outerRadius: 0.9 * radius, innerRadius: 0, sixtieths: CGFloat(components.second ?? 0), color: UIColor.red, lineWidth: small ? 1 : 1.5)
	}
}
