//
//  AppDelegate.swift
//  StudioLight
//
//  Created by Frederico Curto on 12/08/22.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow!
    private var statusItem: NSStatusItem!
    private var leftWindow: MainWindow!
    private var rightWindow: MainWindow!
    private var temperatureLabel: NSMenuItem!
    private var widthLabel: NSMenuItem!
    private var stateLabel: NSMenuItem!
    private var isOn = true
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        
        leftWindow = storyboard.instantiateController(withIdentifier: "Window") as! MainWindow
        rightWindow = storyboard.instantiateController(withIdentifier: "Window") as! MainWindow
        
        rightWindow.showWindow(self)
        leftWindow.showWindow(self)
        
        for window in NSApplication.shared.windows {
            window.level = .floating
        }
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "sparkles", accessibilityDescription: "1")
        }
        
        setupMenus()
        changeTemperature(value: Int(UserDefaults.standard.integer(forKey: "temp")))
        changeWidth(value: Int(UserDefaults.standard.integer(forKey: "width")))
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    func setupMenus() {
    
        let menu = NSMenu()
    
        menu.addItem(NSMenuItem(title: "Sparkles ✨", action: nil, keyEquivalent: ""))
        stateLabel = NSMenuItem(title: "Disable", action: #selector(AppDelegate.toggleOnOff(_:)), keyEquivalent: "")
        menu.addItem(stateLabel)
        
        menu.addItem(NSMenuItem.separator())
        
        let widthSliderItem = NSMenuItem()
        let widthSlider = NSSlider(target: WidthSliderViewController(), action: #selector(AppDelegate.widthSliderChanged(_:)))
        widthSlider.setFrameSize(NSSize(width: widthSliderItem.view?.frame.maxX ?? 160, height: 30))
        widthLabel = NSMenuItem(title: "Width:", action: nil, keyEquivalent: "")
        menu.addItem(widthLabel)
        widthSlider.minValue = 1
        widthSlider.maxValue = 100
        widthSlider.intValue = Int32(UserDefaults.standard.integer(forKey: "width"))
        widthSliderItem.view = widthSlider
        menu.addItem(widthSliderItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let temperatureSliderItem = NSMenuItem()
        let temperatureSlider = NSSlider(target: WidthSliderViewController(), action: #selector(AppDelegate.temperatureSliderChanged(_:)))
        temperatureSlider.minValue = 10
        temperatureSlider.maxValue = 120
        temperatureSlider.intValue = Int32(UserDefaults.standard.integer(forKey: "temp") > 0 ? UserDefaults.standard.integer(forKey: "temp") : 70)
        temperatureSlider.isContinuous = true
        temperatureSlider.setFrameSize(NSSize(width: temperatureSliderItem.view?.frame.maxX ?? 160, height: 30))
        temperatureLabel = NSMenuItem(title: "Temp: \(temperatureSlider.intValue * 100)K", action: nil, keyEquivalent: "")
        menu.addItem(temperatureLabel)
        temperatureSliderItem.view = temperatureSlider
        menu.addItem(temperatureSliderItem)
        
        menu.addItem(NSMenuItem.separator())
        
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: ""))
        statusItem.menu = menu
        
    }
    
    @IBAction func widthSliderChanged(_ sender: NSSlider) {
        UserDefaults.standard.set(sender.intValue, forKey: "width")
        changeWidth(value: Int(sender.intValue))
    }
    
    @IBAction func temperatureSliderChanged(_ sender: NSSlider) {
        UserDefaults.standard.set(sender.intValue, forKey: "temp")
        changeTemperature(value: Int(sender.intValue))
    }
    
    @IBAction func toggleOnOff(_ sender: NSMenuItem) {
        isOn = !isOn
        stateLabel.title = "\(isOn ? "Disable" : "Enable")"
        for window in NSApplication.shared.windows {
            if (window.windowController?.className == Optional("Sparkles.MainWindow")) {
                window.setIsVisible(isOn)
            }
        }
    }
    
    func changeTemperature(value: Int) {
        let amount = Int(value == 0 ? 7000 : value * 100)
        temperatureLabel.title = "Temp: \(amount)K"
        rightWindow.changeColor(temp: amount)
        leftWindow.changeColor(temp: amount)
    }
    
    func changeWidth(value: Int) {
        let amount = CGFloat(value == 0 ? 1 : value)
        widthLabel.title = "Width: \(Int(amount * 25))px"
        rightWindow.paint(scale: amount)
        leftWindow.paint(scale: amount)
    }
}

