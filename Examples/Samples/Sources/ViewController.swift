//
//  ViewController.swift
//  FloatingModalSample
//
//  Created by Shin Yamamoto on 2018/09/18.
//  Copyright © 2018 Shin Yamamoto. All rights reserved.
//

import UIKit
import FloatingPanel

class SampleListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!

    enum Menu: Int, CaseIterable {
        case trackingTableView
        case trackingTextView
        case showDetail
        case showModal
        case showTabBar

        var name: String {
            switch self {
            case .trackingTableView: return "Scroll tracking (UITableView)"
            case .trackingTextView: return "Scroll tracking (UITextView)"
            case .showDetail: return "Show Detail Panel"
            case .showModal: return "Show Modal"
            case .showTabBar: return "Show Tab Bar"
            }
        }

        var storyboardID: String? {
            switch self {
            case .trackingTableView: return nil
            case .trackingTextView: return "ConsoleViewController"
            case .showDetail: return "DetailViewController"
            case .showModal: return "ModalViewController"
            case .showTabBar: return "TabBarViewController"
            }
        }
    }

    var mainPanelVC: FloatingPanelController!
    var detailPanelVC: FloatingPanelController!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        let contentVC = DebugTableViewController(style: .plain)
        addMainPanel(with: contentVC)
    }

    func addMainPanel(with contentVC: UIViewController) {
        // Initialize FloatingPanelController
        mainPanelVC = FloatingPanelController()

        // Initialize FloatingPanelController and add the view
        mainPanelVC.surfaceView.cornerRadius = 6.0
        mainPanelVC.surfaceView.shadowHidden = false

        // Add a content view controller and connect with the scroll view
        mainPanelVC.show(contentVC, sender: self)

        switch contentVC {
        case let consoleVC as DebugTextViewController:
            mainPanelVC.track(scrollView: consoleVC.textView)

        case let contentVC as DebugTableViewController:
            mainPanelVC.track(scrollView: contentVC.tableView)

        default:
            fatalError()
        }
        //  Add FloatingPanel to self.view
        mainPanelVC.addPanel(toParent: self, belowView: nil, animated: true)
    }

    @objc func dismissDetailPanelVC()  {
        detailPanelVC.removePanelFromParent(animated: true, completion: nil)
    }

    // MARK:- TableViewDatasource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Menu.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let menu = Menu.allCases[indexPath.row]
        cell.textLabel?.text = menu.name
        return cell
    }

    // MARK:- TableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menu = Menu.allCases[indexPath.row]
        let contentVC: UIViewController = {
            guard let storyboardID = menu.storyboardID else { return DebugTableViewController(style: .plain) }
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: storyboardID) else { fatalError() }
            return vc
        }()

        switch menu {
        case .showDetail:
            detailPanelVC?.removeFromParent()

            // Initialize FloatingPanelController
            detailPanelVC = FloatingPanelController()

            // Initialize FloatingPanelController and add the view
            detailPanelVC.surfaceView.cornerRadius = 6.0
            detailPanelVC.surfaceView.shadowHidden = false

            // Add a content view controller and connect with the scroll view
            detailPanelVC.show(contentVC, sender: self)

            // (contentVC as? DetailViewController)?.closeButton?.addTarget(self, action: #selector(dismissDetailPanelVC), for: .touchUpInside)

            //  Add FloatingPanel to self.view
            detailPanelVC.addPanel(toParent: self, belowView: nil, animated: true)
        case .showModal, .showTabBar:
            let modalVC = contentVC
            present(modalVC, animated: true, completion: nil)
        default:
            detailPanelVC?.removePanelFromParent(animated: true, completion: nil)
            mainPanelVC?.removePanelFromParent(animated: true) {
                self.addMainPanel(with: contentVC)
            }
        }
    }
}

class DebugTextViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        if #available(iOS 11.0, *) {
            textView.contentInsetAdjustmentBehavior = .never
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("TextView --- ", scrollView.contentOffset, scrollView.contentInset)
        if #available(iOS 11.0, *) {
            print("TextView --- ", scrollView.adjustedContentInset)
        }
    }

    @IBAction func close(sender: UIButton) {
        // Now impossible
        // dismiss(animated: true, completion: nil)
        (self.parent as? FloatingPanelController)?.removePanelFromParent(animated: true, completion: nil)
    }
}

class DebugTableViewController: UITableViewController {
    var items: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        for i in 0...100 {
            items.append("Items \(i)")
        }
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    @objc func close(sender: UIButton) {
        //  Remove FloatingPanel from a view
        (self.parent as! FloatingPanelController).removePanelFromParent(animated: true, completion: nil)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        //print("Content View: viewWillLayoutSubviews")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //print("Content View: viewDidLayoutSubviews")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Content View: viewWillAppear")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Content View: viewDidAppear", view.bounds)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("Content View: viewWillDisappear")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("Content View: viewDidDisappear")
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        print("Content View: willMove(toParent: \(String(describing: parent))")
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        print("Content View: didMove(toParent: \(String(describing: parent))")
    }

    public override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        print("Content View: willTransition(to: \(newCollection), with: \(coordinator))")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66.0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
}

class DetailViewController: UIViewController {
    @IBOutlet weak var closeButton: UIButton!
    @IBAction func close(sender: UIButton) {
        // Now impossible
        // dismiss(animated: true, completion: nil)
        (self.parent as? FloatingPanelController)?.removePanelFromParent(animated: true, completion: nil)
    }
}

class ModalViewController: UIViewController {
    var fpc: FloatingPanelController!
    var consoleVC: DebugTextViewController!
    @IBOutlet weak var safeAreaView: UIView!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Initialize FloatingPanelController
        fpc = FloatingPanelController()

        // Initialize FloatingPanelController and add the view
        fpc.surfaceView.cornerRadius = 6.0
        fpc.surfaceView.shadowHidden = false

        // Add a content view controller and connect with the scroll view
        let consoleVC = storyboard?.instantiateViewController(withIdentifier: "ConsoleViewController") as! DebugTextViewController
        fpc.show(consoleVC, sender: self)
        self.consoleVC = consoleVC
        fpc.track(scrollView: consoleVC.textView)

        //  Add FloatingPanel to self.view
        fpc.addPanel(toParent: self, belowView: safeAreaView)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //  Remove FloatingPanel from a view
        fpc.removePanelFromParent(animated: false)
    }

    @IBAction func close(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func moveToFull(sender: UIButton) {
        fpc.move(to: .full, animated: true)
    }
    @IBAction func moveToHalf(sender: UIButton) {
        fpc.move(to: .half, animated: true)
    }
    @IBAction func moveToTip(sender: UIButton) {
        fpc.move(to: .tip, animated: true)
    }
}

class TabBarViewController: UITabBarController {}

class TabBarContentViewController: UIViewController, FloatingPanelControllerDelegate {
    var fpc: FloatingPanelController!
    var consoleVC: DebugTextViewController!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Initialize FloatingPanelController
        fpc = FloatingPanelController()
        fpc.delegate = self

        // Initialize FloatingPanelController and add the view
        fpc.surfaceView.cornerRadius = 6.0
        fpc.surfaceView.shadowHidden = false

        // Add a content view controller and connect with the scroll view
        let consoleVC = storyboard?.instantiateViewController(withIdentifier: "ConsoleViewController") as! DebugTextViewController
        fpc.show(consoleVC, sender: self)
        self.consoleVC = consoleVC
        fpc.track(scrollView: consoleVC.textView)

        //  Add FloatingPanel to self.view
        fpc.addPanel(toParent: self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //  Remove FloatingPanel from a view
        fpc.removePanelFromParent(animated: false)
    }

    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        switch self.tabBarItem.tag {
        case 0:
            return OneTabBarPanelLayout()
        case 1:
            return TwoTabBarPanel2Layout()
        default:
            return nil
        }
    }

    @IBAction func close(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension FloatingPanelLayout {
    func prepareLayout(surfaceView: UIView, in view: UIView) -> [NSLayoutConstraint] {
        if #available(iOS 11.0, *) {
            return [
                surfaceView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0.0),
                surfaceView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0.0),
            ]
        } else {
            return [
                surfaceView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0.0),
                surfaceView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0.0),
            ]
        }
    }
}

class OneTabBarPanelLayout: FloatingPanelLayout {
    var initialPosition: FloatingPanelPosition {
        return .tip
    }
    var supportedPositions: Set<FloatingPanelPosition> {
        return [.full, .tip]
    }

    func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
        case .full: return 16.0
        case .tip: return 22.0
        default: return nil
        }
    }
}

class TwoTabBarPanel2Layout: FloatingPanelLayout {
    var initialPosition: FloatingPanelPosition {
        return .half
    }
    var supportedPositions: Set<FloatingPanelPosition> {
        return [.full, .half]
    }
    var bottomInteractionBuffer: CGFloat {
        return 261.0 - 22.0
    }

    func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
        case .full: return 16.0
        case .half: return 261.0
        default: return nil
        }
    }
}
