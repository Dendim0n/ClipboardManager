import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  let clipboard = Clipboard()
  let history = History()
  let hotKey = GlobalHotKey()

  var mainApp: MainApplication {
    return MainApplication(history: history, clipboard: clipboard)
  }

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    mainApp.start()
    hotKey.handler = { self.mainApp.popUp() }
  }
}
