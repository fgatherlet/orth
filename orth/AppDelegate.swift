import UIKit
import FlexLayout

class ViewController: UIViewController {
    func label(_ x: String)->UILabel {
        let ret = UILabel()
        ret.backgroundColor = UIColor.gray
        ret.text = x
        return ret
    }
    func tf(_ placeholder: String)->UITextField {
        let ret = UITextField()
        ret.text = ""
        ret.placeholder = placeholder
        return ret
    }
    func tv()->UITextView {
        let ret = UITextView()
        ret.text = ""
        //ret.placeholder = placeholder
        return ret
    }
    func btn(_ x: String)->UIButton {
        let ret = UIButton()
        ret.setTitle(x, for: .normal)
        ret.backgroundColor = UIColor.black

        ret.addTarget(self, action: #selector(tap(sender:)), for: .touchDown)
        return ret
    }
    @objc func tap(sender: UIButton) {
        let xlayer = prop("layer")
        let xsplitp = prop("splitp")
        self._tv.text = "layer:\(xlayer). splitp:\(xsplitp)"
    }

    func defaults()->UserDefaults {
        return UserDefaults(suiteName: "dn.orth.conf")!
    }
    func prop(_ key: String)->Int {
        return self.defaults().integer(forKey: key)
    }
    func prop(_ key: String, _ val: Int) {
        self.defaults().set(val, forKey: key)
    }

    var labels: [UILabel] = []
    var tfs: [UITextField] = []
    var btns: [UIButton] = []
    var _tv: UITextView = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()


        view.backgroundColor = UIColor.lightGray

        self.view.flex
          .justifyContent(.start)
          .define { (flex) in
              self.view.addSubview(self._tv)

              let title = UILabel()
              title.text = "orth simple keyboard"
              self.view.addSubview(title)

              let sub_title = UILabel()
              sub_title.text = "try type."
              self.view.addSubview(sub_title)


              flex.addItem(title).width(100%).margin(4)

              flex.addItem(sub_title).width(100%).margin(4).marginTop(12)

              flex.addItem(self._tv).width(100%).height(100).margin(4)

              // for i in 0...10 {
              //     let xlabel = label("aa\(i)")
              //     let xtf = tf("AA\(i)")
              //     let xbtn = btn("a\(i)")
              // 
              //     labels.append(xlabel)
              //     tfs.append(xtf)
              //     btns.append(xbtn)
              // 
              //     view.addSubview(xlabel)
              //     view.addSubview(xtf)
              //     view.addSubview(xbtn)
              // 
              //     flex.addItem()
              //       .justifyContent(.spaceBetween)
              //       .direction(.row)
              //       .width(100%)
              //       .height(30)
              //       .padding(4)
              //       .define { (flex) in
              //           flex.addItem(xlabel).width(30%)
              //           flex.addItem(xtf).paddingLeft(8).width(40%)
              //           flex.addItem(xbtn).width(30%)
              //       }
              // }
              // let xtv = self._tv
              // view.addSubview(xtv)
              // flex.addItem(xtv)
              //   .width(100%)
              //   .height(100)
              //   .margin(4)
          }

    }

    override func viewDidLayoutSubviews() {
        self.view.flex.padding(self.view.safeAreaInsets)
        self.view.flex.layout()
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        //window?.rootViewController = ViewController()
        window?.rootViewController = UINavigationController(rootViewController: ViewController())
        window?.makeKeyAndVisible()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}
