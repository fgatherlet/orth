import UIKit
import FlexLayout

class Button: UIButton {
    weak var controller: KeyboardViewController!

    var down_time: Date = Date()
    var repeatp = true
    var repeat_timer: Timer = Timer()

    let color_gray = UIColor.gray
    let color_black = UIColor.black
    let color_transparent = UIColor(red:1.0, green:1.0, blue:1.0, alpha:0.0)

    // -99 : nothing
    // -1  : split
    // 0-4 : layer
    var button_type = -99
    var val: String = ""
    var vals: [Int: String] = [:]
    var downs: [Int: (Button)->Void] = [:]
    var ups: [Int: (Button, Bool)->Void] = [:]

    init(parent: KeyboardViewController) {
        super.init(frame: .zero)
        controller = parent
        vals[0] = ""
        downs[0] = { (button: Button) in
        }
        ups[0] = { (button: Button, insidep: Bool) in
        }
        self.addTarget(self, action: #selector(btn_down(sender:with:)), for: .touchDown)
        self.addTarget(self, action: #selector(btn_up_inside(sender:)), for: [.touchUpInside])
        self.addTarget(self, action: #selector(btn_up_outside(sender:)), for: [.touchUpOutside])

        self.layer.cornerRadius = 0
        self.backgroundColor = UIColor.black
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func current(_ xs: [Int:Any])->Any? {
        for i in (0...controller.layer).reversed() {
            if xs[i] != nil {
                return xs[i]!
            }
        }
        return nil
    }
    func update_view() {
        self.val = current(vals) as! String
        self.setTitle(self.val, for: .normal)
        update_view_tap_state()
    }
    func update_view_tap_state() {
        if self.button_type == -1 {
            if (controller.splitp) {
                self.backgroundColor = color_gray
            } else {
                self.backgroundColor = color_black
            }
        } else if self.button_type == controller.layer {
            self.backgroundColor = color_gray
        } else if self.val == "" {
            self.backgroundColor = color_transparent
        } else {
            self.backgroundColor = color_black
        }
    }

    func down(_ button: Button) {
        let fn = current(downs) as! (Button)->Void
        fn(button)
    }
    func up(_ button: Button, insidep: Bool) {
        let fn = current(ups) as! (Button, Bool)->Void
        fn(button, insidep)
    }
    @objc func btn_down(sender: UIButton, with: UIEvent) {
        let btn = sender as! Button
        down(btn)

        // ////
        // let touches = with.touches(for: sender)
        // let location = touches!.first!.location(in: self.controller.view)
        // self.controller.toast.flex.position(.absolute).left(location.x).top(location.y)
        // self.controller.view.flex.layout()
        // ////

        if repeatp {
            self.repeat_timer.invalidate() // to care about zombie
            down_time = Date()
            self.repeat_timer =
              Timer.scheduledTimer(
                withTimeInterval: 0.07, repeats: true,
                block: { (timer) in
                    let span: TimeInterval = timer.fireDate.timeIntervalSince(self.down_time)
                    if span > 0.5 {
                        self.down(btn)
                    }
                })
            self.backgroundColor = color_gray
        }
    }
    @objc func btn_up_inside(sender: UIButton) {
        up(sender as! Button, insidep: true)

        // ////
        // self.controller.toast.flex.position(.absolute).left(-100).bottom(-100)
        // self.controller.view.flex.layout()
        // ////

        update_view_tap_state()
        if self.repeatp {
            self.repeat_timer.invalidate()
        }
    }
    @objc func btn_up_outside(sender: UIButton) {
        up(sender as! Button, insidep: false)

        // ////
        // self.controller.toast.flex.position(.absolute).left(-100).bottom(-100)
        // self.controller.view.flex.layout()
        // ////

        update_view_tap_state()
        if self.repeatp {
            self.repeat_timer.invalidate()
        }
    }
}

class KeyboardViewController: UIInputViewController {
    func defaults()->UserDefaults {
        return UserDefaults(suiteName: "dn.orth.conf")!
    }
    func prop(_ key: String)->Int {
        return self.defaults().integer(forKey: key)
    }
    func prop(_ key: String, _ val: Int) {
        self.defaults().set(val, forKey: key)
    }

    var ipadp = false

    var btns: [Button] = [];
    func btnxy(_ btni: Int)->[Int] {
        let x = btni % 5
        let y = btni / 5
        return [x, y]
    }

    var previous_layer = 0
    var _layer = 0
    var layer: Int {
        get {
            return _layer
        }
        set {
            _layer = newValue
            prop("layer", _layer)

            update_all_btn_view()
        }
    }
    var _splitp = 0
    var splitp: Bool {
        get {
            return _splitp != 0
        }
        set {
            _splitp = newValue ? 1 : 0
            prop("splitp", _splitp)
        }
    }

    func poke_layer(_ new_layer: Int) {
        previous_layer = layer
        if new_layer == layer {
            enforce_layer(0)
        } else {
            enforce_layer(new_layer)
        }
    }
    func enforce_layer(_ new_layer: Int) {
        if layer == 4 {
            previous_layer = 0
        } else {
            previous_layer = layer
        }
        layer = new_layer
    }
    func poke_splitp() {
        splitp = !splitp
        let width = self.view.bounds.size.width
        update_view(width)
    }

    func update_view(_ new_width: CGFloat) {
        let xsplitp = splitp && (new_width >= 400)
        if xsplitp {
            let btn_size: CGFloat = 48.0
            fix_size_btn(btn_size)
        } else {
            var btn_size = (new_width - 12) / 10
            if (btn_size > 92.0) {
                btn_size = 92
            }
            fix_size_btn(btn_size)
        }

        view.layoutIfNeeded()
        update_all_btn_view()
    }

    func update_all_btn_view() {
        for btn in btns {
            btn.update_view()
        }
    }

    let main_view_l = UIView()
    let main_view_r = UIView()
    let toast = UIButton()

    var constraints: [Int: NSLayoutConstraint] = [:]

    let sub_views = [
      UIView(),
      UIView(),
      UIView(),
      UIView(),
      UIView(),
      UIView(),
      UIView(),
      UIView(),
    ]

    func fix_size_btn(_ btn_size: CGFloat) {
        let height_rate: CGFloat = btn_size <= 48.0 ? 1.2 : 1.0
        let bottom_diff: CGFloat = (ipadp && splitp) ? (-2 * btn_size) : -2

        for btn in self.btns {
            btn.flex
              .width(btn_size)
              .height(btn_size * height_rate)
        }
        self.view.flex.height(btn_size * height_rate * 4)

        for i in 0...1 {
            constraints[i]?.isActive = false
        }
        constraints[0] = main_view_l.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottom_diff)
        constraints[1] = main_view_r.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottom_diff)
        for i in 0...1 {
            constraints[i]?.isActive = true
        }
    }

    func fix_size(_ xsize: CGSize) {
        let width = xsize.width
        print("fix_size width:\(width)")
        //splitp = (width >= 400)
        update_view(width) // lame.
    }
    override func viewWillTransition(to xsize: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: xsize, with: coordinator)
        fix_size(xsize)
    }
    override func viewDidLayoutSubviews() {
        self.view.flex.layout()
    }
    override func viewDidLoad() {
        //print("width")
        super.viewDidLoad()

        _layer = prop("layer")
        _splitp = prop("splitp")

        self.view.flex.justifyContent(.start).direction(.row)
          .define { (flex) in
            flex.addItem(self.main_view_l).width(50%)
            flex.addItem(self.main_view_r).width(50%)

            self.toast.backgroundColor = UIColor.red
            flex.addItem(self.toast).position(.relative).bottom(10).left(10).size(50)
        }

        self.main_view_l.flex.define { (flex) in
            for i in 0...3 {
                flex.addItem(self.sub_views[ i*2 ])
                  .justifyContent(.start)
                  .direction(.row)
            }
        }
        self.main_view_r.flex.define { (flex) in
            for i in 0...3 {
                flex.addItem(self.sub_views[ i*2 + 1 ])
                  .justifyContent(.end)
                  .direction(.row)
            }
        }

        self.view.flex.justifyContent(.start).direction(.row).define { (flex) in
            for btni in 0...39 {
                let btn = Button(parent: self)
                //btn.tag = btni
                btns.append(btn)
                let xy = btnxy(btni)

                //self.view.addSubview(btn)

                flex.addItem(btn).size(40).margin(0)
                let sub_view = sub_views[xy[1]]
                sub_view.flex.define { (flex) in
                    flex.addItem(btn).margin(0.5)
                }
                // sub_view.addArrangedSubview(btn)
            }
        }

        for (layeri, vs) in [
              ["q", "w", "e", "r", "t",    "y", "u", "i", "o", "p",
               "a", "s", "d", "f", "g",    "h", "j", "k", "l", " ",
               "z", "x", "c", "v", "b",    "n", "m", ",", ".", "/",
              ],
              ["Q", "W", "E", "R", "T",    "Y", "U", "I", "O", "P",
               "A", "S", "D", "F", "G",    "H", "J", "K", "L", " ",
               "Z", "X", "C", "V", "B",    "N", "M", "<", ">", "?",
              ],
              ["`", "{",  "}", "\\", "~",    "y", "_", "[", "]", "+",
               "@", "$",  "#", "&",  "*",    "%", "-", "(", ")", ":",
               "'", "\"", "^", "|",  ";",    "!", "=", "<", ">", "?",
              ],
              ["", "", "", "5", "",    "", "6", "7", "8", "9",
               "", "", "", "0", "",    "", "1", "2", "3", "4",
               "", "", "", "",  "",    "", "", ",", ".", "/",
              ],
              ["", "", "", "", "",    "", "", "tab", "", "",
               "", "", "", "", "",    "\u{2190}", "", "", "\u{2192}", "",
               "", "", "", "", "",    "\u{232b}", "\u{23ce}", "", "", "",
              ]
            ].enumerated() {
            for (buttoni, v) in vs.enumerated() {
                btns[buttoni].vals[layeri] = v
                btns[buttoni].downs[layeri] = {(button: Button) in
                    button.controller.textDocumentProxy.insertText(v)
                }
            }
        }

        do {
            let i = 30
            btns[i].removeTarget(nil, action: nil, for: .allEvents)
            btns[i].addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
            btns[i].vals[0] = "\u{1f310}"
        }

        do {
            let i = 31
            btns[i].vals[0] = "\u{25be}"
            btns[i].repeatp = false
            btns[i].downs[0] = {(button: Button) in
                button.controller.dismissKeyboard()
            }
        }

        for i in 32...34 {
            btns[i].vals[0] = "fn"
            btns[i].repeatp = false
            btns[i].button_type = 4
            btns[i].downs[0] = {(button: Button) in
                if button.controller.layer == 4 {
                    button.controller.enforce_layer(0)
                } else {
                    button.controller.enforce_layer(4)
                }
            }
            btns[i].ups[0] = {(button: Button, insidep: Bool) in
                // stash pop
                if insidep {
                    button.controller.enforce_layer(button.controller.previous_layer)
                }
            }
            btns[i].layer.cornerRadius = 12
            switch i {
            case 32:
                btns[i].vals[0] = " "
                btns[i].layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner,]
            case 33:
                btns[i].layer.maskedCorners = []
            case 34:
                btns[i].vals[0] = " "
                btns[i].layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner,]
            default:
                break
            }
        }

        // ------------------------------
        do {
            let i = 35
            btns[i].vals[0] = "\u{21e7}"
            btns[i].repeatp = false
            btns[i].button_type = 1
            btns[i].downs[0] = {(button: Button) in
                button.controller.poke_layer(1)
            }
        }
        do {
            let i = 36
            btns[i].vals[0] = ".,"
            btns[i].repeatp = false
            btns[i].button_type = 2
            btns[i].downs[0] = {(button: Button) in
                button.controller.poke_layer(2)
            }
        }
        do {
            let i = 37
            btns[i].vals[0] = "123"
            btns[i].repeatp = false
            btns[i].button_type = 3
            btns[i].downs[0] = {(button: Button) in
                button.controller.poke_layer(3)
            }
        }
        do {
            let i = 38
            btns[i].vals[0] = ""
            btns[i].repeatp = false
            btns[i].downs[0] = {(button: Button) in
                //button.controller.textDocumentProxy.insertText("\t")
            }
        }

        do {
            let i = 39
            btns[i].vals[0] = "]["
            btns[i].repeatp = false
            btns[i].button_type = -1
            btns[i].downs[0] = {(button: Button) in
                button.controller.poke_splitp()
            }
        }

        // ------------------------------
        do {
            let i = 7
            btns[i].vals[4] = "tab"
            btns[i].downs[4] = {(button: Button) in
                button.controller.textDocumentProxy.insertText("\t")
            }
        }
        do {
            let i = 15
            btns[i].vals[4] = "\u{2190}"
            btns[i].downs[4] = {(button: Button) in
                button.controller.textDocumentProxy.adjustTextPosition(byCharacterOffset: -1)
            }
        }
        do {
            let i = 18
            btns[i].vals[4] = "\u{2192}"
            btns[i].downs[4] = {(button: Button) in
                button.controller.textDocumentProxy.adjustTextPosition(byCharacterOffset: 1)
            }
        }
        do {
            let i = 25
            btns[i].vals[4] = "\u{232b}"
            btns[i].downs[4] = {(button: Button) in
                button.controller.textDocumentProxy.deleteBackward()
            }
        }
        do {
            let i = 26
            btns[i].vals[4] = "\u{23ce}"
            btns[i].downs[4] = {(button: Button) in
                button.controller.textDocumentProxy.insertText("\n")
            }
        }
        update_all_btn_view()

        if self.layer == 4 {
            enforce_layer(0)
        }
    }

    //override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    //    let touch = touches.first!
    //    let location = touch.location(in: self.view)
    //    //self.key_toast.flex.position(.absolute).left(location.x).bottom(location.y)
    //    self.view.flex.layout()
    //}
    //override func touchesEnded(_ touches: Set<UITouch>, with: UIEvent?) {
    //}

    override func viewDidAppear(_ animation: Bool) {
        super.viewDidAppear(animation)
        if self.needsInputModeSwitchKey {
            btns[30].vals[0] = "\u{1f310}"
        } else {
            btns[30].vals[0] = ""
        }
    }

    override func viewWillLayoutSubviews() {
        let width = self.view.bounds.size.width
        let screen_size = UIScreen.main.bounds.size;
        if [screen_size.width, screen_size.height].min()! >= CGFloat(768.0) {
            self.ipadp = true
        }
        update_view(width)

        let window = self.view.window!
        let gr0 = window.gestureRecognizers![0] as UIGestureRecognizer
        let gr1 = window.gestureRecognizers![1] as UIGestureRecognizer
        gr0.delaysTouchesBegan = false
        gr1.delaysTouchesBegan = false
    }
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
    }
}
