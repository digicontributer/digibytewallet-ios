//
//  AssetDrawer.swift
//  DigiByte
//
//  Created by Julian Jäger on 04.12.19.
//  Copyright © 2019 DigiByte Foundation NZ Limited. All rights reserved.
//

import UIKit
import Kingfisher

fileprivate class LogoCell: UITableViewCell {
    private let digiassetsLogo = UIImageView(image: UIImage(named: "digiassets_logo"))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(digiassetsLogo)
        digiassetsLogo.contentMode = .scaleAspectFit
        
        digiassetsLogo.constrain([
            digiassetsLogo.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            digiassetsLogo.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0),
            digiassetsLogo.heightAnchor.constraint(equalToConstant: 50),
            digiassetsLogo.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -50),
        ])
        
        backgroundColor = UIColor.clear
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AssetDrawer: UIView {
    private var supervc: DrawerControllerProtocol!
    private let id: String
    
    private var assets = [AssetModel]()
    private var tx: Transaction!

    private let tableView: UITableView = UITableView()
    private var contextMenuConstraints = [NSLayoutConstraint]()
    
    private let contextMenu = AssetContextMenu()
    private let contextMenuUnderlay = UIView() // transparent view that closes contextmenu when tapped
    
    init(id: String) {
        self.id = id
        super.init(frame: .zero)
        
        addSubviews()
        addConstraints()
        setStyle()
        addEvents()
        
        configureTableView()
    }
    
    private func addSubviews() {
        addSubview(tableView)
        
        addSubview(contextMenuUnderlay)
        addSubview(contextMenu)
    }
    
    private func addConstraints() {
        tableView.constrain(toSuperviewEdges: nil)
        
        contextMenuUnderlay.constrain(toSuperviewEdges: nil)
        contextMenu.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setStyle() {
        backgroundColor = UIColor.da.backgroundColor
        contextMenuUnderlay.isHidden = true
        contextMenu.isHidden = true
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(LogoCell.self, forCellReuseIdentifier: "logo")
        tableView.register(AssetCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = .clear
        tableView.separatorColor = .clear
        
        tableView.contentInset = UIEdgeInsets(top: 40 + (E.isIPhoneXOrGreater ? 32 : 15), left: 0, bottom: 40, right: 0)
    }
    
    private func addEvents() {
        let gr = UITapGestureRecognizer(target: self, action: #selector(contextBgTapped))
        contextMenuUnderlay.isUserInteractionEnabled = true
        contextMenuUnderlay.addGestureRecognizer(gr)
    }
    
    @objc private func contextBgTapped() {
        // hide context menu
        contextMenuUnderlay.isHidden = true
        contextMenu.isHidden = true
        
        // reset all button states
        tableView.visibleCells.forEach { (cell) in
            if let cell = cell as? AssetCell {
                cell.menuButton.tintColor = UIColor.da.inactiveColor
            }
        }
    }
    
    func setAssets(for tx: Transaction, assets: [AssetModel]) {
        self.tx = tx
        self.assets = assets
        
        tableView.reloadData()
    }
    
    func setCloser(supervc: DrawerControllerProtocol?) {
        self.supervc = supervc
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AssetDrawer: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                return 1
            
            case 1:
                return assets.count
            
            default:
                return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "logo", for: indexPath) as! LogoCell
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AssetCell
            let assetModel = assets[indexPath.row]
            
            cell.configure(showContent: true)
            
            cell.assetLabel.text = assetModel.getAssetName()
            cell.amountLabel.text = "1000" // ToDo
            
            cell.menuButtonTapped = menuButtonTapped
            cell.menuButton.tintColor = UIColor.da.inactiveColor
            
            cell.assetImage.image = AssetCell.defaultImage
            cell.assetImage.kf.indicatorType = .activity
            
            if let description = assetModel.getDescription() {
                cell.descriptionLabel.text = description
            } else {
                cell.descriptionLabel.text = "No description"
            }
            
            cell.assetIdButton.value = assetModel.assetId
            cell.addressButton.value = tx.toAddress ?? "Unknown"
            cell.infoTextLabel.text = assetModel.getAssetInfo()
            
            if
                let urlModel = assetModel.getImage(),
                let urlStr = urlModel.url,
                let url = URL(string: urlStr)
            {
                cell.assetImage.kf.setImage(with: url)
            }
            
            return cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    // same function found in DAAssetsViewController. Find a way to reference on function?
    private func menuButtonTapped(cell: AssetCell) {
        if let idx = tableView.indexPath(for: cell) {
            let pos = tableView.rectForRow(at: idx)
            
            // get global position
            let gpos = tableView.convert(pos, to: self)
            
            // deactivate and remove each constraint
            contextMenuConstraints.forEach { c in
                c.isActive = false
                contextMenu.removeConstraint(c)
            }
            
            // set new constraints
            contextMenuConstraints = [
                contextMenu.trailingAnchor.constraint(equalTo: leadingAnchor, constant: gpos.origin.x + cell.menuButton.frame.origin.x + 10)
            ]
            
            if gpos.origin.y + contextMenu.frame.height > frame.height {
                // stick to bottom
                contextMenuConstraints.append(contextMenu.bottomAnchor.constraint(equalTo: topAnchor, constant: gpos.origin.y + 30))
            } else {
                // stick to top
                contextMenuConstraints.append(contextMenu.topAnchor.constraint(equalTo: topAnchor, constant: gpos.origin.y + 30))
            }
            
            // activate new constraints
            contextMenuConstraints.forEach { c in
                c.isActive = true
            }
            
            // initially scale
            contextMenu.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            
            // show context menu
            contextMenu.isHidden = false
            contextMenuUnderlay.isHidden = false
            bringSubviewToFront(contextMenuUnderlay)
            bringSubviewToFront(contextMenu)
            
            UIView.spring(0.3, animations: { [weak contextMenu, weak cell] in
                contextMenu?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                cell?.menuButton.tintColor = UIColor.da.darkSkyBlue
            }) { (_) in
                
            }
        }
    }
}
