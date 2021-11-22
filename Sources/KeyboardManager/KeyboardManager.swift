import UIKit

public protocol KeyboardHeightObserver: AnyObject {
  func keyboardHeightUpdated(_ keyboardHeight: CGFloat)
}

public class KeyboardManager: NSObject {
  public static let shared = KeyboardManager()

  var observers: NSHashTable<AnyObject> = NSHashTable<AnyObject>.weakObjects()
  public var animationDuration: TimeInterval = 0
  public var animationOptions: UIView.AnimationOptions = []
  public var isKeyboardShowing: Bool {
    return keyboardHeight > 0
  }

  public var keyboardFrame: CGRect? {
    didSet {
      guard keyboardFrame != oldValue else { return }
      for ob in observers.allObjects {
        (ob as! KeyboardHeightObserver).keyboardHeightUpdated(keyboardHeight)
      }
    }
  }

  public var keyboardHeight: CGFloat {
    if let frame = keyboardFrame {
      if let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
        return max(keyWindow.bounds.maxY - frame.minY, 0)
      } else {
        return frame.height
      }
    } else {
      return 0
    }
  }

  override init() {
    super.init()
    NotificationCenter.default.addObserver(
      self, selector: #selector(keyboardWillBeShown(note:)), name: UIResponder.keyboardWillChangeFrameNotification,
      object: nil)
    NotificationCenter.default.addObserver(
      self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
  }

  public func addHeightObserver(_ observer: KeyboardHeightObserver) {
    observers.add(observer)
  }

  @objc func keyboardWillBeShown(note: Notification) {
    let userInfo = note.userInfo!

    animationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
    let rawAnimationCurveValue = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).uintValue
    animationOptions = UIView.AnimationOptions(rawValue: rawAnimationCurveValue)
    if let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect, frame != .zero {
      keyboardFrame = frame
    } else {
      keyboardFrame = nil
    }
  }

  @objc func keyboardWillHide() {
    keyboardFrame = nil
  }
}
