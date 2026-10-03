#import "SettingsViewController.h"

@interface SettingsViewController () <UITextFieldDelegate>
@property (nonatomic, strong) UITextField *urlField;
@property (nonatomic, strong) UITextField *tokenField;
@property (nonatomic, strong) UILabel *statusLabel;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"⚙️ Cài Đặt Server";
    self.view.backgroundColor = [UIColor colorWithRed:0.07 green:0.08 blue:0.11 alpha:1.0];
    
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithTitle:@"Lưu" style:UIBarButtonItemStyleDone target:self action:@selector(saveTapped)];
    self.navigationItem.rightBarButtonItem = saveItem;
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Đóng" style:UIBarButtonItemStylePlain target:self action:@selector(cancelTapped)];
    self.navigationItem.leftBarButtonItem = cancelItem;
    
    [self setupUI];
    [self loadSettings];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    [self.view addGestureRecognizer:tap];
}

- (void)setupUI {
    CGFloat w = self.view.bounds.size.width - 32;
    
    UILabel *lbl1 = [[UILabel alloc] initWithFrame:CGRectMake(16, 110, w, 22)];
    lbl1.text = @"ĐỊA CHỈ SERVER (KÈM CỔNG 8686):";
    lbl1.textColor = [UIColor systemGrayColor];
    lbl1.font = [UIFont systemFontOfSize:13 weight:UIFontWeightBold];
    [self.view addSubview:lbl1];
    
    self.urlField = [[UITextField alloc] initWithFrame:CGRectMake(16, 138, w, 48)];
    self.urlField.backgroundColor = [UIColor colorWithRed:0.12 green:0.14 blue:0.18 alpha:1.0];
    self.urlField.textColor = [UIColor whiteColor];
    self.urlField.font = [UIFont systemFontOfSize:15];
    self.urlField.layer.cornerRadius = 12;
    self.urlField.layer.borderColor = [UIColor colorWithRed:0.25 green:0.28 blue:0.35 alpha:1.0].CGColor;
    self.urlField.layer.borderWidth = 1.0;
    self.urlField.placeholder = @"VD: http://103.x.x.x:8686";
    self.urlField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.urlField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.urlField.keyboardType = UIKeyboardTypeURL;
    UIView *p1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 48)];
    self.urlField.leftView = p1;
    self.urlField.leftViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:self.urlField];
    
    UILabel *lbl2 = [[UILabel alloc] initWithFrame:CGRectMake(16, 206, w, 22)];
    lbl2.text = @"MÃ BẢO MẬT (SECRET TOKEN):";
    lbl2.textColor = [UIColor systemGrayColor];
    lbl2.font = [UIFont systemFontOfSize:13 weight:UIFontWeightBold];
    [self.view addSubview:lbl2];
    
    self.tokenField = [[UITextField alloc] initWithFrame:CGRectMake(16, 234, w, 48)];
    self.tokenField.backgroundColor = [UIColor colorWithRed:0.12 green:0.14 blue:0.18 alpha:1.0];
    self.tokenField.textColor = [UIColor whiteColor];
    self.tokenField.font = [UIFont systemFontOfSize:15];
    self.tokenField.layer.cornerRadius = 12;
    self.tokenField.layer.borderColor = [UIColor colorWithRed:0.25 green:0.28 blue:0.35 alpha:1.0].CGColor;
    self.tokenField.layer.borderWidth = 1.0;
    self.tokenField.placeholder = @"Mã token bí mật trên server";
    self.tokenField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.tokenField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.tokenField.secureTextEntry = NO;
    UIView *p2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 48)];
    self.tokenField.leftView = p2;
    self.tokenField.leftViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:self.tokenField];
    
    UIButton *testBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    testBtn.frame = CGRectMake(16, 305, w, 50);
    testBtn.backgroundColor = [UIColor colorWithRed:0.0 green:0.48 blue:1.0 alpha:1.0];
    [testBtn setTitle:@"Kiểm Tra Kết Nối Server" forState:UIControlStateNormal];
    [testBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    testBtn.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    testBtn.layer.cornerRadius = 14;
    [testBtn addTarget:self action:@selector(testConnection) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testBtn];
    
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 370, w, 40)];
    self.statusLabel.numberOfLines = 2;
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:self.statusLabel];
}

- (void)loadSettings {
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSString *url = [defs stringForKey:@"kServerURL"];
    if (!url || url.length == 0) {
        url = @"http://127.0.0.1:8686";
    }
    self.urlField.text = url;
    self.tokenField.text = [defs stringForKey:@"kServerToken"] ?: @"";
}

- (void)saveTapped {
    NSString *url = [self.urlField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *token = [self.tokenField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (url.length == 0) {
        self.statusLabel.text = @"⚠️ Vui lòng nhập địa chỉ Server!";
        self.statusLabel.textColor = [UIColor systemRedColor];
        return;
    }
    
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    [defs setObject:url forKey:@"kServerURL"];
    [defs setObject:token forKey:@"kServerToken"];
    [defs synchronize];
    
    if ([self.delegate respondsToSelector:@selector(settingsDidUpdate)]) {
        [self.delegate settingsDidUpdate];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)testConnection {
    NSString *rawUrl = [self.urlField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *token = [self.tokenField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (rawUrl.length == 0) {
        self.statusLabel.text = @"⚠️ Vui lòng nhập URL!";
        self.statusLabel.textColor = [UIColor systemRedColor];
        return;
    }
    
    if (![rawUrl hasSuffix:@"/api/metrics"]) {
        if ([rawUrl hasSuffix:@"/"]) {
            rawUrl = [rawUrl stringByAppendingString:@"api/metrics"];
        } else {
            rawUrl = [rawUrl stringByAppendingString:@"/api/metrics"];
        }
    }
    
    self.statusLabel.text = @"⏳ Đang gửi tín hiệu kiểm tra...";
    self.statusLabel.textColor = [UIColor systemYellowColor];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rawUrl] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5.0];
    if (token.length > 0) {
        [req setValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:@"Authorization"];
    }
    
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
    [[[NSURLSession sharedSession] dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSTimeInterval duration = ([NSDate timeIntervalSinceReferenceDate] - start) * 1000.0;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                self.statusLabel.text = [NSString stringWithFormat:@"❌ Lỗi kết nối: %@", error.localizedDescription];
                self.statusLabel.textColor = [UIColor systemRedColor];
            } else {
                NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
                if (httpResp.statusCode == 200) {
                    self.statusLabel.text = [NSString stringWithFormat:@"🟢 Kết nối thành công! Ping: %.0f ms", duration];
                    self.statusLabel.textColor = [UIColor colorWithRed:0.0 green:0.95 blue:0.65 alpha:1.0];
                } else {
                    self.statusLabel.text = [NSString stringWithFormat:@"⚠️ Server trả mã HTTP %ld", (long)httpResp.statusCode];
                    self.statusLabel.textColor = [UIColor systemOrangeColor];
                }
            }
        });
    }] resume];
}

@end
