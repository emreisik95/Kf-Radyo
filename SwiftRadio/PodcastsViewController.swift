//
// Created by Emre Işık
// Last update on 3/4/19


import UIKit
import MediaPlayer
import AVFoundation
import GoogleMobileAds

class PodcastsViewController: UIViewController {
    
    
    // MARK: - IB UI    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stationNowPlayingButton: UIButton!
    @IBOutlet weak var nowPlayingAnimationImageView: UIImageView!
    var bannerView = GADBannerView()
    
    // MARK: - Properties
    
    let radioPlayer = RadioPlayer()
    
    // Weak reference to update the NowPlayingViewController
    weak var nowPlayingViewController: NowPlayingViewController?
    
    // MARK: - Lists
    
    var stations = [RadioStation]() {
        didSet {
            guard stations != oldValue else { return }
            stationsDidUpdate()
        }
    }
    
    var podcasts = [Podcast]() {
        didSet {
            guard podcasts != oldValue else { return }
        }
    }

    
    var searchedStations = [RadioStation]()
    
    
    // MARK: - UI
    
    var searchController: UISearchController = {
        return UISearchController(searchResultsController: nil)
    }()
    
    var refreshControl: UIRefreshControl = {
        return UIRefreshControl()
    }()
    @IBOutlet weak var nowPlayView: UIView!
    
    //*****************************************************************
    // MARK: - ViewDidLoad
    //*****************************************************************
    var yayinci = ""
    @IBOutlet weak var themeBackground: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nowPlayView.backgroundColor = Theme.backgroundColor
        themeBackground.image = Theme.backgroundImage
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.adUnitID = "ca-app-pub-3940256099942544/6300978111"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        addBannerViewToView(bannerView)
        
        self.view.addSubview(bannerView)
        
        // Register 'Nothing Found' cell xib
        let cellNib = UINib(nibName: "NothingFoundCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "NothingFound")
        
        // Setup Player
        radioPlayer.delegate = self
        
        // Load Data
        loadStationsFromJSON()

        stationNowPlayingButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        // Setup TableView
        tableView.backgroundColor = .clear
        tableView.backgroundView = nil
        tableView.separatorStyle = .none
        
        // Setup Pull to Refresh
        setupPullToRefresh()
        
        // Create NowPlaying Animation
        createNowPlayingAnimation()
        
        // Activate audioSession
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            if kDebugLog { print("audioSession could not be activated") }
        }
        
        // Setup Search Bar
        setupSearchController()
        
        // Setup Remote Command Center
        setupRemoteCommandCenter()
        
        // Setup Handoff User Activity
        setupHandoffUserActivity()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (10)) {
            self.tableView.reloadData()
        }
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        switch UIDevice.current.orientation{
        case .portrait:
            self.tableView.reloadData()
        case .portraitUpsideDown:
            self.tableView.reloadData()
        case .landscapeLeft:
            self.tableView.reloadData()
        case .landscapeRight:
            self.tableView.reloadData()
        default:
            self.tableView.reloadData()
        }
    }
    override var supportedInterfaceOrientations:UIInterfaceOrientationMask {
        return UIDevice.current.userInterfaceIdiom == .pad ? UIInterfaceOrientationMask.all : UIInterfaceOrientationMask.portrait
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: stationNowPlayingButton,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Podcastler"
        
    }
    
    //*****************************************************************
    // MARK: - Setup UI Elements
    //*****************************************************************
    
    func setupPullToRefresh() {
        refreshControl.attributedTitle = NSAttributedString(string: "Yenile", attributes: [.foregroundColor: UIColor.white])
        refreshControl.backgroundColor = .black
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func createNowPlayingAnimation() {
        nowPlayingAnimationImageView.animationImages = AnimationFrames.createFrames()
        nowPlayingAnimationImageView.animationDuration = 0.7
    }
    
    func createNowPlayingBarButton() {
        guard navigationItem.rightBarButtonItem == nil else { return }
        let btn = UIBarButtonItem(title: "", style: .plain, target: self, action:#selector(nowPlayingBarButtonPressed))
        btn.image = UIImage(named: "btn-nowPlaying")
        navigationItem.rightBarButtonItem = btn
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @objc func nowPlayingBarButtonPressed() {
        performSegue(withIdentifier: "PodcastCal", sender: self)
    }
    
    @IBAction func nowPlayingPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "PodcastCal", sender: self)
    }
    
    @objc func refresh(sender: AnyObject) {
        // Pull to Refresh
        loadStationsFromJSON()
        
        // Wait 2 seconds then refresh screen
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.refreshControl.endRefreshing()
            self.view.setNeedsDisplay()
        }
    }
    
    //*****************************************************************
    // MARK: - Load Station Data
    //*****************************************************************
    
    func loadStationsFromJSON() {
        
        // Turn on network indicator in status bar
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        // Get the Radio Stations
        DataManager.getStationDataWithSuccess() { (data) in
            
            // Turn off network indicator in status bar
            defer {
                DispatchQueue.main.async { UIApplication.shared.isNetworkActivityIndicatorVisible = false }
            }
            if kDebugLog { print("Stations JSON Found") }
            
            guard let data = data, let jsonDictionary = try? JSONDecoder().decode([String: [RadioStation]].self, from: data), let stationsArray = jsonDictionary["\(self.yayinci)"] else {
                if kDebugLog { print("JSON Station Loading Error") }
                return
            }
            self.stations = stationsArray
        }
    }
    
    
    //*****************************************************************
    // MARK: - Segue
    //*****************************************************************
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PodcastCal"{
            
            let nowPlayingVC = segue.destination as? NowPlayingViewController
            
            title = ""
            
            let newStation: Bool
            
            if let indexPath = (sender as? IndexPath) {
                // User clicked on row, load/reset station
                radioPlayer.station = searchController.isActive ? searchedStations[indexPath.row] : stations[indexPath.row]
                newStation = true
            } else {
                // User clicked on Now Playing button
                newStation = false
            }
            
            nowPlayingViewController = nowPlayingVC
            nowPlayingVC!.load(station: radioPlayer.station, track: radioPlayer.track, isNewStation: newStation)
            nowPlayingVC!.delegate = self
        }
    }
    
    //*****************************************************************
    // MARK: - Private helpers
    //*****************************************************************
    
    private func stationsDidUpdate() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            guard let currentStation = self.radioPlayer.station else { return }
            
            // Reset everything if the new stations list doesn't have the current station
            if self.stations.index(of: currentStation) == nil { self.resetCurrentStation() }
        }
    }
    // Reset all properties to default
    private func resetCurrentStation() {
        radioPlayer.resetRadioPlayer()
        nowPlayingAnimationImageView.stopAnimating()
        stationNowPlayingButton.setTitle("Çalmasını istediğiniz podcasti seçin", for: .normal)
        stationNowPlayingButton.isEnabled = false
        navigationItem.rightBarButtonItem = nil
    }
    
    // Update the now playing button title
    private func updateNowPlayingButton(station: RadioStation?, track: Track?) {
        guard let station = station else { resetCurrentStation(); return }
        
        var playingTitle = station.name + ": "
        
        if track?.title == station.name {
            playingTitle += "Şimdi çalıyor..."
        } else if let track = track {
            playingTitle += track.title + " - Canlı yayın" //+ track.artist
        }
        
        stationNowPlayingButton.setTitle(playingTitle, for: .normal)
        stationNowPlayingButton.isEnabled = true
        createNowPlayingBarButton()
    }
    
    func startNowPlayingAnimation(_ animate: Bool) {
        animate ? nowPlayingAnimationImageView.startAnimating() : nowPlayingAnimationImageView.stopAnimating()
    }
    
    private func getIndex(of station: RadioStation?) -> Int? {
        guard let station = station, let index = stations.index(of: station) else { return nil }
        return index
    }
    
    //*****************************************************************
    // MARK: - Remote Command Center Controls
    //*****************************************************************
    
    func setupRemoteCommandCenter() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Add handler for Play Command
        commandCenter.playCommand.addTarget { event in
            return .success
        }
        
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { event in
            return .success
        }
        
        // Add handler for Next Command
        commandCenter.nextTrackCommand.addTarget { event in
            return .success
        }
        
        // Add handler for Previous Command
        commandCenter.previousTrackCommand.addTarget { event in
            return .success
        }
    }
    
    //*****************************************************************
    // MARK: - MPNowPlayingInfoCenter (Lock screen)
    //*****************************************************************
    
    func updateLockScreen(with track: Track?) {
        
        // Define Now Playing Info
        var nowPlayingInfo = [String : Any]()
        
        if let image = track?.artworkImage {
            if #available(iOS 10.0, *) {
                nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { size -> UIImage in
                    return image
                })
            } else {
                // Fallback on earlier versions
            }
        }
        
        if let artist = track?.artist {
            nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        }
        
        if let title = track?.title {
            nowPlayingInfo[MPMediaItemPropertyTitle] = title
        }
        
        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}

//*****************************************************************
// MARK: - TableViewDataSource
//*****************************************************************

extension PodcastsViewController: UITableViewDataSource {
    
    @objc(tableView:heightForRowAtIndexPath:)
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive {
            return searchedStations.count
        } else {
            return stations.isEmpty ? 1 : stations.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
                let label = UILabel()
                label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
                label.text = "Eski yayınlar"
                label.textAlignment = .center
                label.textColor = UIColor.white // my custom colour
                let blurEffect = UIBlurEffect(style: .dark)
                let blurEffectView = UIVisualEffectView(effect: blurEffect)
                blurEffectView.frame = headerView.frame
                headerView.insertSubview(blurEffectView, at: 0)
                headerView.addSubview(label)
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            let cell = tableView.dequeueReusableCell(withIdentifier: "PodcastListCell", for: indexPath) as! PodcastListTableViewCell
            cell.podcastListNameLabel.text = "Yükleniyor..."
            cell.podcastListDesc.text = "Yükleniyor..."
            cell.podcastListImageView.image = UIImage(named: "stationImage")

            // alternate background color
            cell.backgroundColor = (indexPath.row % 2 == 0) ? UIColor.clear : UIColor.black.withAlphaComponent(0.2)
        DispatchQueue.main.asyncAfter(deadline: .now() + (1)) {
            let station = self.searchController.isActive ? self.searchedStations[indexPath.row] : self.stations[indexPath.row]
            cell.configureStationCell(station: station)
        }
            return cell
        
    }
}

//*****************************************************************
// MARK: - TableViewDelegate
//*****************************************************************

extension PodcastsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
            performSegue(withIdentifier: "PodcastCal", sender: indexPath)
    }
}

//*****************************************************************
// MARK: - UISearchControllerDelegate / Setup
//*****************************************************************

extension PodcastsViewController: UISearchResultsUpdating {
    
    func setupSearchController() {
        guard searchable else { return }
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        
        // Add UISearchController to the tableView
        tableView.tableHeaderView = searchController.searchBar
        tableView.tableHeaderView?.backgroundColor = UIColor.clear
        definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = false
        
        // Style the UISearchController
        searchController.searchBar.barTintColor = UIColor.clear
        searchController.searchBar.tintColor = UIColor.white
        
        // Hide the UISearchController
        tableView.setContentOffset(CGPoint(x: 0.0, y: searchController.searchBar.frame.size.height), animated: false)
        
        // Set a black keyborad for UISearchController's TextField
        let searchTextField = searchController.searchBar.value(forKey: "_searchField") as! UITextField
        searchTextField.keyboardAppearance = UIKeyboardAppearance.dark
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        
        searchedStations.removeAll(keepingCapacity: false)
        searchedStations = stations.filter { $0.name.range(of: searchText, options: [.caseInsensitive]) != nil }
        self.tableView.reloadData()
    }
}

//*****************************************************************
// MARK: - RadioPlayerDelegate
//*****************************************************************

extension PodcastsViewController: RadioPlayerDelegate {
    
    func playerStateDidChange(_ playerState: FRadioPlayerState) {
        nowPlayingViewController?.playerStateDidChange(playerState, animate: true)
    }
    
    func playbackStateDidChange(_ playbackState: FRadioPlaybackState) {
        nowPlayingViewController?.playbackStateDidChange(playbackState, animate: true)
        startNowPlayingAnimation(radioPlayer.player.isPlaying)
    }
    
    func trackDidUpdate(_ track: Track?) {
        updateLockScreen(with: track)
        updateNowPlayingButton(station: radioPlayer.station, track: track)
        updateHandoffUserActivity(userActivity, station: radioPlayer.station, track: track)
        nowPlayingViewController?.updateTrackMetadata(with: track)
    }
    
    func trackArtworkDidUpdate(_ track: Track?) {
        updateLockScreen(with: track)
        nowPlayingViewController?.updateTrackArtwork(with: track)
    }
}

//*****************************************************************
// MARK: - Handoff Functionality - GH
//*****************************************************************

extension PodcastsViewController {
    
    func setupHandoffUserActivity() {
        userActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
        userActivity?.becomeCurrent()
    }
    
    func updateHandoffUserActivity(_ activity: NSUserActivity?, station: RadioStation?, track: Track?) {
        guard let activity = activity else { return }
        activity.webpageURL = (track?.title == station?.name) ? nil : getHandoffURL(from: track)
        updateUserActivityState(activity)
    }
    
    override func updateUserActivityState(_ activity: NSUserActivity) {
        super.updateUserActivityState(activity)
    }
    
    private func getHandoffURL(from track: Track?) -> URL? {
        guard let track = track else { return nil }
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "google.com"
        components.path = "/search"
        components.queryItems = [URLQueryItem]()
        components.queryItems?.append(URLQueryItem(name: "q", value: "\(track.artist) \(track.title)"))
        return components.url
    }
}

//*****************************************************************
// MARK: - NowPlayingViewControllerDelegate
//*****************************************************************

extension PodcastsViewController: NowPlayingViewControllerDelegate {
    
    func didPressPlayingButton() {
        radioPlayer.player.togglePlaying()
    }
    
    func didPressStopButton() {
        radioPlayer.player.stop()
    }
    
    func didPressNextButton() {
        guard let index = getIndex(of: radioPlayer.station) else { return }
        radioPlayer.station = (index + 1 == stations.count) ? stations[0] : stations[index + 1]
        handleRemoteStationChange()
    }
    
    func didPressPreviousButton() {
        guard let index = getIndex(of: radioPlayer.station) else { return }
        radioPlayer.station = (index == 0) ? stations.last : stations[index - 1]
        handleRemoteStationChange()
    }
    
    func handleRemoteStationChange() {
        if let nowPlayingVC = nowPlayingViewController {
            // If nowPlayingVC is presented
            nowPlayingVC.load(station: radioPlayer.station, track: radioPlayer.track)
            nowPlayingVC.stationDidChange()
        } else if let station = radioPlayer.station {
            // If nowPlayingVC is not presented (change from remote controls)
            radioPlayer.player.radioURL = URL(string: station.streamURL)
        }
    }
}
