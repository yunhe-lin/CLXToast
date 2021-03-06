//
//  DefaultWaiting.swift
//  CLXToast
//
//  Created by chen liangxiu on 2018/1/25.
//

import Foundation

final class DefaultWating: ToastContent, DefaultWaitingExport, DefaultCurrentWaitingExport {
    weak var toast: Toast! //为了链式语法，直接一步到位show出来

    @discardableResult
    public func show(in container: UIView, with layout: ((Toast) -> Void)?, animated: Bool, completion: (() -> Void)?) -> Toast {
        return self.toast!.show(in: container, with: layout, animated: animated, completion: completion);
    }
    @discardableResult
    public func show(animated: Bool = true, with completion: (() -> Void)? = nil) -> Toast {
        return self.toast!.show(animated: animated, with: completion)
    }


    var contentInset: UIEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
    @discardableResult
    public func contentInset(_ inset: UIEdgeInsets) -> DefaultWating {
        contentInset = inset
        return self
    }

    var _activity: UIActivityIndicatorView! //菊花,如果为空，组件自己会创建，默认样式为白色（waiting模式）
    public func activityView(_ newValue: UIActivityIndicatorView?) -> DefaultWating {
        _activity = newValue
        return self
    }

    var _promptLabel: UILabel? //菊花提示（waiting模式）
    @discardableResult
    public func prompt(_ newValue: String?) -> DefaultWating {//菊花提示的链式快捷方式（waiting模式）
        if _promptLabel == nil {
            _promptLabel = UILabel()
            _promptLabel!.font = UIFont.systemFont(ofSize: 15.0)
        }
        _promptLabel!.text = newValue
        if let toast = self.toast,let transaction = toast.myTransaction {
            if transaction.isExecuting {
                self.toast.setNeedsUpdateConstraints()
            }
        }
        return self
    }

    @discardableResult
    public func promptLabel(_ newValue: UILabel?) -> DefaultWating {
        _promptLabel = newValue
        return self
    }

    var _space: CGFloat = 4
    @discardableResult
    public func interitemSpacing(_ space: CGFloat) -> DefaultWating {
        _space = max(space, 0.0)
        return self
    }

    init() {
        super.init(style: .waiting)
    }

    func dismiss() {
        self.dismiss(animated: true)
    }

    func dismiss(animated: Bool) {
        toast.dismiss()
    }

    override func addSubviews(to contentView: UIView) {
        if _activity == nil {
            _activity = UIActivityIndicatorView()
            _activity.hidesWhenStopped = false
        }
        if _activity.superview != contentView {
            contentView.addSubview(_activity)
        }
        _activity.startAnimating()

        let empty = _promptLabel?.text?.isEmpty ?? true
        if !empty && _promptLabel?.superview != contentView {
            contentView.addSubview(_promptLabel!)
        }
    }

    override func layoutSubviews(in contentView: UIView) {
        _activity.translatesAutoresizingMaskIntoConstraints = false
        let empty = _promptLabel?.text?.isEmpty ?? true

        let activityCenterX = NSLayoutConstraint(item: _activity, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0)

        let activityCenterY = NSLayoutConstraint(item: _activity, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0)

        let activityLeading = NSLayoutConstraint(item: _activity, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: contentView, attribute: .leading, multiplier: 1, constant: contentInset.left)

        let activityTop = NSLayoutConstraint(item: _activity, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: contentView, attribute: .top, multiplier: 1, constant: contentInset.top)

        let activityTrailing = NSLayoutConstraint(item: _activity, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -contentInset.right)

        var activityBottom: NSLayoutConstraint
        if empty {
            activityBottom = NSLayoutConstraint(item: _activity, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: contentView, attribute: .bottom, multiplier: 1, constant: -contentInset.bottom)
            contentView.addConstraints([activityCenterX, activityCenterY, activityLeading, activityTop, activityTrailing, activityBottom])
            //子控件布局完成
            return
        } else {
            //需要布局prompt label
            activityBottom = NSLayoutConstraint(item: _activity, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: -_space / 2.0)
            contentView.addConstraints([activityCenterX, activityLeading, activityTop, activityTrailing, activityBottom])
        }

        //布局promptLabel
        _promptLabel!.translatesAutoresizingMaskIntoConstraints = false
        let promptCenterX = NSLayoutConstraint(item: _promptLabel!, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0)

        let promptLeading = NSLayoutConstraint(item: _promptLabel!, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: contentView, attribute: .leading, multiplier: 1, constant: contentInset.left)

        let promptTop = NSLayoutConstraint(item: _promptLabel!, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant:  _space / 2.0)

        let promptTrailing = NSLayoutConstraint(item: _promptLabel!, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -contentInset.right)

        let promptBottom = NSLayoutConstraint(item: _promptLabel!, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: contentView, attribute: .bottom, multiplier: 1, constant: -contentInset.bottom)
        contentView.addConstraints([promptCenterX, promptLeading, promptTop, promptTrailing, promptBottom])
    }
}
