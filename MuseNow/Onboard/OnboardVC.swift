//  Pages.swift

import UIKit
import EventKit
import AVFoundation
import Speech


class OnboardVC: UIPageViewController {

    var onboardPages = [OnboardPage]()
    var pageIndex = 0
    var speakerBtn: UIButton!
    let pageControl = UIPageControl()

    override init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : Any]?) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: options)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @objc func speakerAction(_ sender: UIButton) {

        speakerBtn.isSelected = !speakerBtn.isSelected
        Actions.shared.doAction(.hearSpeaker, value: speakerBtn.isSelected ? 1 : 0)
        BubblesPlaying.shared.muteBubbles(on: !speakerBtn.isSelected)
    }

    override func viewDidLoad() {

        super.viewDidLoad()
        view.backgroundColor = .darkGray

        let viewSize = view.bounds.size
        let w = CGFloat(48) // button width (and height)
        speakerBtn = UIButton(frame: CGRect(x: viewSize.width/2 - w/2,
                                            y: viewSize.height - 2*w - w/2,
                                            width: w, height: w))

        speakerBtn.setImage( UIImage(named:"icon-speaker-off.png"), for: .normal)
        speakerBtn.setImage( UIImage(named:"icon-speaker-on.png"), for: .selected)
        speakerBtn.addTarget(self, action: #selector(self.speakerAction(_:)), for: .touchUpInside) //<- use `#selector(...)`
        speakerBtn.isSelected = true
        Actions.shared.doAction(.hearSpeaker, value: 1)
        view.addSubview(speakerBtn)
    }

    override func viewWillAppear(_ animated: Bool) {

        view.accessibilityIgnoresInvertColors = true
        dataSource = self
        delegate = self

        makeOnboardPages()
        makePageControl()

        setViewControllers([onboardPages[0]], direction: .forward, animated: true, completion: nil)
    }

    /**
     add the individual viewControllers to the pageViewController
     */
    func makeOnboardPages() {
        
        func nextPage() {
            Log("🔰 nextPage")
            guard let nextViewController = dataSource?.pageViewController(self, viewControllerAfter: self) else { return }
            setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
        }

        let approvals: CallWait! = { finish  in

            let queue = DispatchQueue(label: "com.muse.approvals", attributes: .concurrent, target: .main)
            let group = DispatchGroup()

            // events
            group.enter() ; queue.async (group: group) {
                EKEventStore().requestAccess(to: .event) { accessGranted, error in
                    Log("🔰 event granted:\(accessGranted)")
                    group.leave()
                }
            }
            // reminders
            group.enter() ;  queue.async (group: group) {
                EKEventStore().requestAccess(to: .reminder) { accessGranted, error in
                    Log("🔰 reminder granted:\(accessGranted)")
                    group.leave()
                }
            }
            // location
            group.enter() ; queue.async (group: group) {
                if CLLocationManager.locationServicesEnabled() {
                    let status = CLLocationManager.authorizationStatus()
                    switch status {
                    case .authorizedWhenInUse, .authorizedAlways:  break
                    default: CLLocationManager().requestWhenInUseAuthorization()
                    }
                    Log("🔰 location status:\(status)")
                }
                else {
                    CLLocationManager().requestWhenInUseAuthorization()
                    Log("🔰 location not enabled")
                }
                group.leave()
            }
            // microphone
            group.enter() ; queue.async (group: group) {
                let permission = AVAudioSession.sharedInstance().recordPermission()
                Log("🔰 mic permission:\(permission)")
                group.leave()
            }

            // speech to text
            group.enter() ; queue.async (group: group) {
                SFSpeechRecognizer.requestAuthorization { authStatus in
                    Log("🔰 speech-to-text status \(authStatus)")
                    group.leave()
                }
            }
            //  done
            group.notify(queue: queue, execute: {
                finish()
            })
        }


        let beginDemo: CallWait! = { finish  in
            Log("🔰 beginDemo")
            MainVC.shared?.transitionFromOnboarding()
            finish()
        }

        
        onboardPages = [
            OnboardPage("A clock that collects your thoughts", [
                
                "muse • is a clock that collects your thoughts.",
                "v_301.aif",
                
                "just raise your wrist and say muse • now " +
                "to see what's next and record what's on your mind",
                "v_302.aif",
                
                "over time, your collection of thoughts " +
                "grows into a private history",
                "v_303.aif",

                "connecting: " +
                    "where you were, who you're with, " +
                "what you're doing, and why it matters.",
                "v_304.aif",
                
                "This history of yours will help you " +
                "obtain nearly perfect recall. Just ask " +
                "about any person, place or thing.",
                "v_305.aif",
                
                "Ultimately, your history will help connect " +
                    "what you say to what you really want " +
                "from any outside service.",
                "v_306.aif",
                
                "That's our long term goal. But, for now, " +
                    "we start small: with a simple little clock " +
                    "that shows you what's next and " +
                "collect your thoughts.",
                "v_307.aif",
                
                nextPage]),
            
            OnboardPage("Privacy", [

                "Here is our guarantee",
                "v_308.aif",

                "You own your own history, which only *you* can see. " +
                "Muse never sees your history, and we never will.",
                "v_309.aif",

                "Instead, your history is kept " +
                    "inside Apple's privacy sandbox, on " +
                "your iDevices and on Apple's iCloud Drive.",
                "v_310.aif",


                "Moreover, your history is in an open format. " +
                    "So, you're free to use any open source tool " +
                "to learn new insights.",
                "v_311.aif",

                "With that in mind",
                "v_312.aif",
                nextPage]),

            OnboardPage("Permissions", [

                approvals,
                nextPage]),

            OnboardPage("Tour", [
                "let's get started",
                "v_313.aif",

                beginDemo])
        ]
        for page in onboardPages {
            page.view.tag = pageIndex
            pageIndex += 1
        }
        pageIndex = 0
    }

    /**
     */
    func makePageControl() {

        pageControl.frame = .zero
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.pageIndicatorTintColor = .gray
        pageControl.numberOfPages = onboardPages.count
        pageControl.currentPage = 0

        view.addSubview(pageControl)

        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15).isActive = true
        pageControl.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20).isActive = true
        pageControl.heightAnchor.constraint(equalToConstant: 20).isActive = true
        pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }

}

