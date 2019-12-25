//
//  WDTagsView.swift
//  ShoppingDemo
//
//  Created by Unique on 2019/12/25.
//  Copyright © 2019 Unique. All rights reserved.
//

import UIKit

@objc protocol WDTagsViewDelegate: NSObjectProtocol {
    func tagsView(view: WDTagsView, didTappedAtIndex index: Int, didTappedAtText text: String) -> Void
}

class WDTagsView: UIView {
    // MARK: Public
    public weak var delegate: WDTagsViewDelegate?
    public var tagHeight: CGFloat          = 32// 标签高度，默认为32
    public var viewHMargin: CGFloat        = 10// 整体左右间距 默认为10
    public var viewVMargin: CGFloat        = 10// 整体上下间距 默认为10
    public var tagInnerSpace: CGFloat      = 10// 标签内部左右间距 默认为10
    public var tagHMargin: CGFloat         = 10// 标签之间的水平间距 默认为10
    public var tagVMargin: CGFloat         = 5// 标签之间的行间距 默认为5
    public var tagFont: UIFont             = .systemFont(ofSize: 14)// 标签字体 默认为5
    public var tagTextColor: UIColor       = .black// 标签字体颜色
    public var tagBackgroundColor: UIColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)// 标签背景颜色
    public var itemArray: Array<String> = Array() {
        didSet {
            setupViews()
        }
    }

    // MARK: Private
    private var tagsArray: Array<UIButton>  = Array()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func refreshView() {
        DispatchQueue.main.async {
             self.setupViews()
        }
    }
    
    private func setupViews() {
        for v in self.subviews {
            v.removeFromSuperview()
        }
        tagsArray.removeAll()
        for (index, item) in itemArray.enumerated() {
            let b = UIButton(type: .roundedRect)
            b.setTitle(item, for: .normal)
            b.setTitleColor(tagTextColor, for: .normal)
            b.titleLabel?.font = tagFont
            b.backgroundColor = tagBackgroundColor
            b.layer.cornerRadius = 10
            b.tag = index
            b.addTarget(self, action: #selector(buttonTargetAction(sender:)), for: .touchUpInside)
            addSubview(b)
            tagsArray.append(b)
        }
        layoutItems()
    }

    private func layoutItems() {
        var tagLineWidth   = viewHMargin                // 单行的总宽度
        let allWidth       = UIScreen.main.bounds.width // 默认为屏幕宽度
        var isChange: Bool = false                      // 是否需要换行

        var lastItem: UIButton!
        for index in 0..<tagsArray.count {
            let button = tagsArray[index]
            let tagTitle: NSString = itemArray[index] as NSString
            var tagWidth = tagTitle.boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: tagHeight), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : tagFont], context: nil).size.width + 2 * tagInnerSpace + 0.5
            tagLineWidth += (tagWidth + tagHMargin)
            if tagLineWidth > (allWidth - viewHMargin) {
                isChange = true
                if (tagWidth + 2 * tagHMargin) > allWidth {
                    tagWidth = allWidth - 2 * tagHMargin
                    button.titleEdgeInsets = UIEdgeInsets(top: 0, left: tagInnerSpace / 2, bottom: 0, right: tagInnerSpace / 2)
                }
                tagLineWidth = viewHMargin + tagWidth + tagHMargin
            }
            
            button.snp.makeConstraints { (make) in
                make.height.equalTo(tagHeight)
                make.width.equalTo(tagWidth)
                if lastItem == nil {
                    make.top.equalTo(viewVMargin)
                    make.leading.equalTo(viewHMargin)
                } else {
                    if isChange {
                        make.leading.equalTo(viewVMargin)
                        make.top.equalTo(lastItem.snp.bottom).offset(tagVMargin)
                        isChange = false
                    } else {
                        make.leading.equalTo(lastItem.snp.trailing).offset(tagHMargin)
                        make.top.equalTo(lastItem.snp.top)
                    }
                }
            }
            lastItem = button
        }
        
        lastItem.snp.makeConstraints { (make) in
            make.bottom.equalTo(-viewVMargin).priority(.high)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func buttonTargetAction(sender: UIButton) {
        delegate?.tagsView(view: self, didTappedAtIndex: sender.tag, didTappedAtText: itemArray[sender.tag])
    }
}
