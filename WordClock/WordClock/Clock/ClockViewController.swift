//
//  ClockViewController.swift
//  JioHospitality
//
//  Created by Arvind Kumar on 01/02/24.
//  Copyright © 2024 Arvind Kumar Singh. All rights reserved.
//

import UIKit

class ClockViewController: UIViewController {
    var observations = [NSObjectProtocol]()
    var sortedTimezones: [Timezone] = []
    var dateFormate = DateFormatter()
    var zoneArr: [String] = [ "Asia/Calcutta",
                              "America/Los_Angeles",
                              "Asia/Dubai",
                              "Australia/Sydney",
                              "Europe/London",]
    var timer: Timer? = nil
    
    private lazy var collctionView: UICollectionView! = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 0)
        layout.minimumLineSpacing = 20
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(UINib(nibName: "ClockCollectionCell", bundle: nil), forCellWithReuseIdentifier: "ClockCollectionCell")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.showsHorizontalScrollIndicator = false
   
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // self.backButton.isHidden = true
        setColorGradient()
        setAllTimeZone()
        setUpCollectionView()
        addCollectionView()
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] _ in
            if let s = self, let tv = s.collctionView{
                let indexPaths = tv.indexPathsForVisibleItems
                for indexPath in indexPaths {
                    if s.sortedTimezones.indices.contains(indexPath.item), let timeDisplay = tv.cellForItem(at: indexPath)?.viewWithTag(2) as? TimeDisplayView,let timeLbl = tv.cellForItem(at: indexPath)?.viewWithTag(3) as? UILabel,let dateLbl = tv.cellForItem(at: indexPath)?.viewWithTag(4) as? UILabel{
                       let dateComponents = timeDisplay.updateDisplay(timezone: s.sortedTimezones[indexPath.item])
                        let tz = TimeZone(identifier: s.sortedTimezones[indexPath.item].identifier)
                        self?.dateFormate.dateFormat = "hh:mm a"
                        self?.dateFormate.timeZone = tz
                       // dateLbl.text = self?.dateFormate.string(from: Date())
                        dateLbl.text = "Today"
                        timeLbl.textColor = .lightGray.withAlphaComponent(1)
                        timeLbl.textColor = .white
                        dateLbl.textColor = .lightGray.withAlphaComponent(0.8)
                        timeLbl.text = self?.dateFormate.string(from: Date())
                        dateLbl.textColor = .white
                        let backView = tv.cellForItem(at: indexPath)?.viewWithTag(5)
                        backView?.isHidden = false
                        backView?.layer.cornerRadius = (backView?.bounds.height ?? 0)/2
                    }
                }
            }
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer?.invalidate()
        timer = nil
    }
    
    func setAllTimeZone(){
        for identifier in zoneArr{
            let tz = Timezone(name: identifier.split(separator: "/").last?.replacingOccurrences(of: "_", with: " ") ?? identifier, identifier: identifier)
            sortedTimezones.append(tz)
        }
    }

    private func setUpCollectionView() {
        collctionView.delegate = self
        collctionView.dataSource  = self
    }

    private func addCollectionView() {
        self.view.addSubview(collctionView)
        NSLayoutConstraint.activate([
            collctionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            collctionView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            collctionView.heightAnchor.constraint(equalToConstant: (self.view.bounds.height / 2)),
            collctionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0)
        ])
    }
    
    //MARK: - For Component
    func setColorGradient() {
        let layer0 = CAGradientLayer()
        layer0.colors = [
            UIColor(red: 0.895, green: 0.824, blue: 0.763, alpha: 1).cgColor,
            UIColor(red: 0.92, green: 0.874, blue: 0.836, alpha: 1).cgColor
        ]
        layer0.locations = [0, 1]
        layer0.startPoint = CGPoint(x: 0.25, y: 0.5)
        layer0.endPoint = CGPoint(x: 0.75, y: 0.5)
        layer0.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 1.19, b: 1.67, c: -1.67, d: 3.75, tx: 0.84, ty: -1.82))
        layer0.bounds = view.bounds.insetBy(dx: -0.5*view.bounds.size.width, dy: -0.5*view.bounds.size.height)
        layer0.position = view.center
        self.view.layer.insertSublayer(layer0, at: 0)
    }
    
    @IBAction func tapOnbackBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
}

// MARK: - Collection View Delegate Method

extension ClockViewController: UICollectionViewDataSource,  UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sortedTimezones.count
    }
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ClockCollectionCell", for: indexPath)
        cell.backgroundColor = .clear
        cell.layer.cornerRadius = 24
        let timezone = sortedTimezones[indexPath.row]
        let zoneLbl = (cell.viewWithTag(1) as? UILabel)
        zoneLbl?.textColor = .white
        //zoneLbl?.textColor = JioDesign.Color.globalTheme.light.primary.colorGrey100.withAlphaComponent(0.8)
        zoneLbl?.text = timezone.name
        if let timeDisplay = cell.viewWithTag(2) as? TimeDisplayView {
            timeDisplay.updateDisplay(timezone: timezone)
        }
        return cell
        
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width-210)/4, height: collectionView.frame.size.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.alpha = 0
        cell.layer.transform = CATransform3DMakeScale(0.8, 0.8, 0.8)
        UIView.animate(withDuration: 1.0, animations: { () -> Void in
            cell.alpha = 1
            cell.layer.transform = CATransform3DScale(CATransform3DIdentity, 1, 1, 1)
        })
    }

}

