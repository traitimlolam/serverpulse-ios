#import "RootViewController.h"
#import "SettingsViewController.h"

@interface RootViewController () <SettingsDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSTimer *autoTimer;

// Header Card
@property (nonatomic, strong) UIView *headerCard;
@property (nonatomic, strong) UILabel *hostLabel;
@property (nonatomic, strong) UILabel *pingBadge;
@property (nonatomic, strong) UILabel *uptimeLabel;

// CPU Card
@property (nonatomic, strong) UIView *cpuCard;
@property (nonatomic, strong) UILabel *cpuValueLabel;
@property (nonatomic, strong) UIProgressView *cpuProgress;
@property (nonatomic, strong) UILabel *cpuDetailLabel;

// RAM Card
@property (nonatomic, strong) UIView *ramCard;
@property (nonatomic, strong) UILabel *ramValueLabel;
@property (nonatomic, strong) UIProgressView *ramProgress;
@property (nonatomic, strong) UILabel *ramDetailLabel;

// Disk Card
@property (nonatomic, strong) UIView *diskCard;
@property (nonatomic, strong) UILabel *diskValueLabel;
@property (nonatomic, strong) UIProgressView *diskProgress;
@property (nonatomic, strong) UILabel *diskDetailLabel;

// Queue Card
@property (nonatomic, strong) UIView *queueCard;
@property (nonatomic, strong) UILabel *qPendingLabel;
@property (nonatomic, strong) UILabel *qProcessingLabel;
@property (nonatomic, strong) UILabel *qCompletedLabel;

@property (nonatomic, strong) UILabel *lastUpdatedLabel;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"ServerPulse";
    self.view.backgroundColor = [UIColor colorWithRed:0.04 green:0.04 blue:0.06 alpha:1.0];
    
    UIBarButtonItem *gearItem = [[UIBarButtonItem alloc] initWithTitle:@"⚙️" style:UIBarButtonItemStylePlain target:self action:@selector(openSettings)];
    self.navigationItem.rightBarButtonItem = gearItem;
    
    [self setupScrollView];
    [self setupCards];
    [self fetchMetrics];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopTimer];
}

- (void)startTimer {
    [self stopTimer];
    self.autoTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(fetchMetrics) userInfo:nil repeats:YES];
}

- (void)stopTimer {
    if (self.autoTimer) {
        [self.autoTimer invalidate];
        self.autoTimer = nil;
    }
}

- (void)openSettings {
    SettingsViewController *setVC = [[SettingsViewController alloc] init];
    setVC.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:setVC];
    nav.navigationBar.barStyle = UIBarStyleBlack;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)settingsDidUpdate {
    [self fetchMetrics];
}

- (void)setupScrollView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.alwaysBounceVertical = YES;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor colorWithRed:0.0 green:0.95 blue:0.65 alpha:1.0];
    [self.refreshControl addTarget:self action:@selector(fetchMetrics) forControlEvents:UIControlEventValueChanged];
    [self.scrollView addSubview:self.refreshControl];
    
    [self.view addSubview:self.scrollView];
}

- (UIView *)createCardAtY:(CGFloat)y height:(CGFloat)h width:(CGFloat)w {
    UIView *card = [[UIView alloc] initWithFrame:CGRectMake(16, y, w, h)];
    card.backgroundColor = [UIColor colorWithRed:0.09 green:0.10 blue:0.14 alpha:1.0];
    card.layer.cornerRadius = 16;
    card.layer.borderWidth = 1.0;
    card.layer.borderColor = [UIColor colorWithRed:0.18 green:0.20 blue:0.26 alpha:1.0].CGColor;
    card.layer.shadowColor = [UIColor blackColor].CGColor;
    card.layer.shadowOpacity = 0.3;
    card.layer.shadowOffset = CGSizeMake(0, 4);
    card.layer.shadowRadius = 8;
    return card;
}

- (void)setupCards {
    CGFloat w = self.view.bounds.size.width - 32;
    CGFloat y = 16;
    
    // 1. Header Card (y=16, h=105)
    self.headerCard = [self createCardAtY:y height:105 width:w];
    
    self.hostLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 16, w - 140, 26)];
    self.hostLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    self.hostLabel.textColor = [UIColor whiteColor];
    self.hostLabel.text = @"🖥️ Máy Chủ Đang Đo...";
    [self.headerCard addSubview:self.hostLabel];
    
    self.pingBadge = [[UILabel alloc] initWithFrame:CGRectMake(w - 120, 16, 104, 26)];
    self.pingBadge.textAlignment = NSTextAlignmentCenter;
    self.pingBadge.font = [UIFont systemFontOfSize:12 weight:UIFontWeightBold];
    self.pingBadge.layer.cornerRadius = 8;
    self.pingBadge.clipsToBounds = YES;
    self.pingBadge.backgroundColor = [UIColor colorWithRed:0.2 green:0.25 blue:0.3 alpha:1.0];
    self.pingBadge.textColor = [UIColor lightTextColor];
    self.pingBadge.text = @"Đang nối...";
    [self.headerCard addSubview:self.pingBadge];
    
    self.uptimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 52, w - 32, 38)];
    self.uptimeLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    self.uptimeLabel.textColor = [UIColor colorWithRed:0.7 green:0.75 blue:0.85 alpha:1.0];
    self.uptimeLabel.numberOfLines = 2;
    self.uptimeLabel.text = @"⏳ Uptime: Chưa có tín hiệu";
    [self.headerCard addSubview:self.uptimeLabel];
    
    [self.scrollView addSubview:self.headerCard];
    y += 105 + 14;
    
    // 2. CPU Card (h=120)
    self.cpuCard = [self createCardAtY:y height:120 width:w];
    UILabel *cpuTitle = [[UILabel alloc] initWithFrame:CGRectMake(16, 14, 150, 20)];
    cpuTitle.text = @"⚡ XUNG NHỊP CPU";
    cpuTitle.font = [UIFont systemFontOfSize:13 weight:UIFontWeightBold];
    cpuTitle.textColor = [UIColor systemGrayColor];
    [self.cpuCard addSubview:cpuTitle];
    
    self.cpuValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(w - 150, 12, 134, 26)];
    self.cpuValueLabel.textAlignment = NSTextAlignmentRight;
    self.cpuValueLabel.font = [UIFont systemFontOfSize:22 weight:UIFontWeightHeavy];
    self.cpuValueLabel.textColor = [UIColor whiteColor];
    self.cpuValueLabel.text = @"-- %";
    [self.cpuCard addSubview:self.cpuValueLabel];
    
    self.cpuProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.cpuProgress.frame = CGRectMake(16, 50, w - 32, 8);
    self.cpuProgress.layer.cornerRadius = 4;
    self.cpuProgress.clipsToBounds = YES;
    self.cpuProgress.trackTintColor = [UIColor colorWithRed:0.15 green:0.17 blue:0.23 alpha:1.0];
    self.cpuProgress.progressTintColor = [UIColor colorWithRed:0.0 green:0.9 blue:0.5 alpha:1.0];
    [self.cpuCard addSubview:self.cpuProgress];
    
    self.cpuDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 70, w - 32, 38)];
    self.cpuDetailLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    self.cpuDetailLabel.textColor = [UIColor lightGrayColor];
    self.cpuDetailLabel.numberOfLines = 2;
    self.cpuDetailLabel.text = @"Số nhân: --  |  Load Avg: --";
    [self.cpuCard addSubview:self.cpuDetailLabel];
    
    [self.scrollView addSubview:self.cpuCard];
    y += 120 + 14;
    
    // 3. RAM Card (h=120)
    self.ramCard = [self createCardAtY:y height:120 width:w];
    UILabel *ramTitle = [[UILabel alloc] initWithFrame:CGRectMake(16, 14, 150, 20)];
    ramTitle.text = @"🧠 BỘ NHỚ RAM";
    ramTitle.font = [UIFont systemFontOfSize:13 weight:UIFontWeightBold];
    ramTitle.textColor = [UIColor systemGrayColor];
    [self.ramCard addSubview:ramTitle];
    
    self.ramValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(w - 180, 12, 164, 26)];
    self.ramValueLabel.textAlignment = NSTextAlignmentRight;
    self.ramValueLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightHeavy];
    self.ramValueLabel.textColor = [UIColor whiteColor];
    self.ramValueLabel.text = @"-- MB / -- MB";
    [self.ramCard addSubview:self.ramValueLabel];
    
    self.ramProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.ramProgress.frame = CGRectMake(16, 50, w - 32, 8);
    self.ramProgress.layer.cornerRadius = 4;
    self.ramProgress.clipsToBounds = YES;
    self.ramProgress.trackTintColor = [UIColor colorWithRed:0.15 green:0.17 blue:0.23 alpha:1.0];
    self.ramProgress.progressTintColor = [UIColor colorWithRed:0.0 green:0.7 blue:1.0 alpha:1.0];
    [self.ramCard addSubview:self.ramProgress];
    
    self.ramDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 70, w - 32, 38)];
    self.ramDetailLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    self.ramDetailLabel.textColor = [UIColor lightGrayColor];
    self.ramDetailLabel.numberOfLines = 2;
    self.ramDetailLabel.text = @"Swap ảo: --";
    [self.ramCard addSubview:self.ramDetailLabel];
    
    [self.scrollView addSubview:self.ramCard];
    y += 120 + 14;
    
    // 4. Disk Card (h=115)
    self.diskCard = [self createCardAtY:y height:115 width:w];
    UILabel *diskTitle = [[UILabel alloc] initWithFrame:CGRectMake(16, 14, 160, 20)];
    diskTitle.text = @"💾 Ổ CỨNG LƯU TRỮ (/)";
    diskTitle.font = [UIFont systemFontOfSize:13 weight:UIFontWeightBold];
    diskTitle.textColor = [UIColor systemGrayColor];
    [self.diskCard addSubview:diskTitle];
    
    self.diskValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(w - 180, 12, 164, 26)];
    self.diskValueLabel.textAlignment = NSTextAlignmentRight;
    self.diskValueLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightHeavy];
    self.diskValueLabel.textColor = [UIColor whiteColor];
    self.diskValueLabel.text = @"-- GB / -- GB";
    [self.diskCard addSubview:self.diskValueLabel];
    
    self.diskProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.diskProgress.frame = CGRectMake(16, 50, w - 32, 8);
    self.diskProgress.layer.cornerRadius = 4;
    self.diskProgress.clipsToBounds = YES;
    self.diskProgress.trackTintColor = [UIColor colorWithRed:0.15 green:0.17 blue:0.23 alpha:1.0];
    self.diskProgress.progressTintColor = [UIColor colorWithRed:0.7 green:0.3 blue:1.0 alpha:1.0];
    [self.diskCard addSubview:self.diskProgress];
    
    self.diskDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 70, w - 32, 30)];
    self.diskDetailLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    self.diskDetailLabel.textColor = [UIColor lightGrayColor];
    self.diskDetailLabel.text = @"Còn trống: -- GB khả dụng";
    [self.diskCard addSubview:self.diskDetailLabel];
    
    [self.scrollView addSubview:self.diskCard];
    y += 115 + 14;
    
    // 5. Tweak Factory Queue Card (h=140)
    self.queueCard = [self createCardAtY:y height:140 width:w];
    UILabel *qTitle = [[UILabel alloc] initWithFrame:CGRectMake(16, 14, w - 32, 20)];
    qTitle.text = @"🏭 NHỊP TIM DÂY CHUYỀN TWEAK";
    qTitle.font = [UIFont systemFontOfSize:13 weight:UIFontWeightBold];
    qTitle.textColor = [UIColor systemGrayColor];
    [self.queueCard addSubview:qTitle];
    
    CGFloat colW = (w - 32 - 16) / 3.0;
    
    // Sub-box 1: Pending
    UIView *b1 = [[UIView alloc] initWithFrame:CGRectMake(16, 44, colW, 76)];
    b1.backgroundColor = [UIColor colorWithRed:0.2 green:0.15 blue:0.05 alpha:0.8];
    b1.layer.cornerRadius = 10;
    b1.layer.borderColor = [UIColor colorWithRed:0.8 green:0.6 blue:0.1 alpha:0.6].CGColor;
    b1.layer.borderWidth = 1;
    UILabel *l1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, colW, 16)];
    l1.text = @"⏳ Chờ Thợ";
    l1.font = [UIFont systemFontOfSize:11 weight:UIFontWeightBold];
    l1.textAlignment = NSTextAlignmentCenter;
    l1.textColor = [UIColor systemYellowColor];
    [b1 addSubview:l1];
    self.qPendingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 28, colW, 40)];
    self.qPendingLabel.text = @"0";
    self.qPendingLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightHeavy];
    self.qPendingLabel.textAlignment = NSTextAlignmentCenter;
    self.qPendingLabel.textColor = [UIColor whiteColor];
    [b1 addSubview:self.qPendingLabel];
    [self.queueCard addSubview:b1];
    
    // Sub-box 2: Processing
    UIView *b2 = [[UIView alloc] initWithFrame:CGRectMake(16 + colW + 8, 44, colW, 76)];
    b2.backgroundColor = [UIColor colorWithRed:0.05 green:0.15 blue:0.25 alpha:0.8];
    b2.layer.cornerRadius = 10;
    b2.layer.borderColor = [UIColor colorWithRed:0.0 green:0.6 blue:1.0 alpha:0.6].CGColor;
    b2.layer.borderWidth = 1;
    UILabel *l2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, colW, 16)];
    l2.text = @"⚙️ Đang Làm";
    l2.font = [UIFont systemFontOfSize:11 weight:UIFontWeightBold];
    l2.textAlignment = NSTextAlignmentCenter;
    l2.textColor = [UIColor systemCyanColor];
    [b2 addSubview:l2];
    self.qProcessingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 28, colW, 40)];
    self.qProcessingLabel.text = @"0";
    self.qProcessingLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightHeavy];
    self.qProcessingLabel.textAlignment = NSTextAlignmentCenter;
    self.qProcessingLabel.textColor = [UIColor whiteColor];
    [b2 addSubview:self.qProcessingLabel];
    [self.queueCard addSubview:b2];
    
    // Sub-box 3: Completed
    UIView *b3 = [[UIView alloc] initWithFrame:CGRectMake(16 + (colW + 8) * 2, 44, colW, 76)];
    b3.backgroundColor = [UIColor colorWithRed:0.05 green:0.2 blue:0.1 alpha:0.8];
    b3.layer.cornerRadius = 10;
    b3.layer.borderColor = [UIColor colorWithRed:0.0 green:0.8 blue:0.4 alpha:0.6].CGColor;
    b3.layer.borderWidth = 1;
    UILabel *l3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, colW, 16)];
    l3.text = @"✅ Hoàn Tất";
    l3.font = [UIFont systemFontOfSize:11 weight:UIFontWeightBold];
    l3.textAlignment = NSTextAlignmentCenter;
    l3.textColor = [UIColor colorWithRed:0.2 green:0.9 blue:0.5 alpha:1.0];
    [b3 addSubview:l3];
    self.qCompletedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 28, colW, 40)];
    self.qCompletedLabel.text = @"0";
    self.qCompletedLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightHeavy];
    self.qCompletedLabel.textAlignment = NSTextAlignmentCenter;
    self.qCompletedLabel.textColor = [UIColor whiteColor];
    [b3 addSubview:self.qCompletedLabel];
    [self.queueCard addSubview:b3];
    
    [self.scrollView addSubview:self.queueCard];
    y += 140 + 16;
    
    // 6. Last Updated
    self.lastUpdatedLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, y, w, 24)];
    self.lastUpdatedLabel.textAlignment = NSTextAlignmentCenter;
    self.lastUpdatedLabel.font = [UIFont systemFontOfSize:12];
    self.lastUpdatedLabel.textColor = [UIColor grayColor];
    self.lastUpdatedLabel.text = @"Chờ cập nhật...";
    [self.scrollView addSubview:self.lastUpdatedLabel];
    y += 40;
    
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, y);
}

- (UIColor *)colorForPercent:(CGFloat)pct {
    if (pct < 70.0) {
        return [UIColor colorWithRed:0.0 green:0.90 blue:0.55 alpha:1.0]; // Emerald green
    } else if (pct < 85.0) {
        return [UIColor systemYellowColor];
    } else {
        return [UIColor systemRedColor];
    }
}

- (NSString *)formatUptime:(NSInteger)sec {
    NSInteger d = sec / 86400;
    NSInteger h = (sec % 86400) / 3600;
    NSInteger m = (sec % 3600) / 60;
    if (d > 0) {
        return [NSString stringWithFormat:@"%ld ngày %ld giờ %ld phút", (long)d, (long)h, (long)m];
    } else if (h > 0) {
        return [NSString stringWithFormat:@"%ld giờ %ld phút", (long)h, (long)m];
    } else {
        return [NSString stringWithFormat:@"%ld phút", (long)m];
    }
}

- (void)fetchMetrics {
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSString *rawUrl = [defs stringForKey:@"kServerURL"];
    if (!rawUrl || rawUrl.length == 0) {
        rawUrl = @"http://127.0.0.1:8686";
    }
    NSString *token = [defs stringForKey:@"kServerToken"] ?: @"";
    
    if (![rawUrl hasSuffix:@"/api/metrics"]) {
        if ([rawUrl hasSuffix:@"/"]) {
            rawUrl = [rawUrl stringByAppendingString:@"api/metrics"];
        } else {
            rawUrl = [rawUrl stringByAppendingString:@"/api/metrics"];
        }
    }
    
    NSURL *targetUrl = [NSURL URLWithString:rawUrl];
    if (!targetUrl) return;
    
    // Extract host name for display
    self.hostLabel.text = [NSString stringWithFormat:@"🖥️ %@", targetUrl.host ?: @"Server"];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:targetUrl cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:4.0];
    if (token.length > 0) {
        [req setValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:@"Authorization"];
    }
    
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
    [[[NSURLSession sharedSession] dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSTimeInterval pingMs = ([NSDate timeIntervalSinceReferenceDate] - start) * 1000.0;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
            
            if (error || !data) {
                self.pingBadge.text = @"🔴 Mất kết nối";
                self.pingBadge.backgroundColor = [UIColor colorWithRed:0.35 green:0.05 blue:0.05 alpha:1.0];
                self.pingBadge.textColor = [UIColor systemRedColor];
                return;
            }
            
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (!json || ![json isKindOfClass:[NSDictionary class]]) {
                self.pingBadge.text = @"⚠️ Sai dữ liệu";
                self.pingBadge.backgroundColor = [UIColor colorWithRed:0.35 green:0.2 blue:0.0 alpha:1.0];
                self.pingBadge.textColor = [UIColor systemOrangeColor];
                return;
            }
            
            // Online Badge
            self.pingBadge.text = [NSString stringWithFormat:@"🟢 %.0f ms", pingMs];
            self.pingBadge.backgroundColor = [UIColor colorWithRed:0.05 green:0.25 blue:0.12 alpha:1.0];
            self.pingBadge.textColor = [UIColor colorWithRed:0.0 green:0.95 blue:0.65 alpha:1.0];
            
            // Uptime
            NSInteger uptime = [json[@"uptime"] integerValue];
            self.uptimeLabel.text = [NSString stringWithFormat:@"⏳ Đã chạy: %@", [self formatUptime:uptime]];
            
            // CPU
            NSDictionary *cpu = json[@"cpu"];
            CGFloat cpuPct = [cpu[@"percent"] floatValue];
            self.cpuValueLabel.text = [NSString stringWithFormat:@"%.1f%%", cpuPct];
            self.cpuValueLabel.textColor = [self colorForPercent:cpuPct];
            self.cpuProgress.progress = cpuPct / 100.0;
            self.cpuProgress.progressTintColor = [self colorForPercent:cpuPct];
            NSArray *loads = cpu[@"load_avg"] ?: @[@0, @0, @0];
            self.cpuDetailLabel.text = [NSString stringWithFormat:@"Số nhân: %@ Cores  |  Load: %@, %@, %@", cpu[@"cores"] ?: @"?", loads[0], loads[1], loads[2]];
            
            // RAM
            NSDictionary *ram = json[@"ram"];
            CGFloat ramPct = [ram[@"percent"] floatValue];
            NSInteger ramUsed = [ram[@"used_mb"] integerValue];
            NSInteger ramTotal = [ram[@"total_mb"] integerValue];
            self.ramValueLabel.text = [NSString stringWithFormat:@"%ld / %ld MB (%.0f%%)", (long)ramUsed, (long)ramTotal, ramPct];
            self.ramValueLabel.textColor = [self colorForPercent:ramPct];
            self.ramProgress.progress = ramPct / 100.0;
            self.ramProgress.progressTintColor = [self colorForPercent:ramPct];
            self.ramDetailLabel.text = [NSString stringWithFormat:@"Swap ảo: %@ MB (%@%%)", ram[@"swap_used_mb"] ?: @"0", ram[@"swap_percent"] ?: @"0"];
            
            // Disk
            NSDictionary *disk = json[@"disk"];
            CGFloat diskPct = [disk[@"percent"] floatValue];
            self.diskValueLabel.text = [NSString stringWithFormat:@"%@ / %@ GB (%.0f%%)", disk[@"used_gb"] ?: @"0", disk[@"total_gb"] ?: @"0", diskPct];
            self.diskValueLabel.textColor = [self colorForPercent:diskPct];
            self.diskProgress.progress = diskPct / 100.0;
            self.diskProgress.progressTintColor = [self colorForPercent:diskPct];
            self.diskDetailLabel.text = [NSString stringWithFormat:@"Còn trống: %@ GB khả dụng", disk[@"free_gb"] ?: @"0"];
            
            // Queue
            NSDictionary *q = json[@"queue"];
            self.qPendingLabel.text = [NSString stringWithFormat:@"%@", q[@"pending"] ?: @"0"];
            self.qProcessingLabel.text = [NSString stringWithFormat:@"%@", q[@"processing"] ?: @"0"];
            self.qCompletedLabel.text = [NSString stringWithFormat:@"%@", q[@"completed"] ?: @"0"];
            
            // Time
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"HH:mm:ss"];
            self.lastUpdatedLabel.text = [NSString stringWithFormat:@"Cập nhật lần cuối: %@", [df stringFromDate:[NSDate date]]];
        });
    }] resume];
}

@end
