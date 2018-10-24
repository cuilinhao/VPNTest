

#import "SectionsViewController.h"
#import "YJLocalCountryData.h"
#import <SMS_SDK/SMSSDK.h>
#import <MOBFoundation/MOBFImage.h>
#import <MOBFoundation/MOBFColor.h>

@interface UIImage (Tint)

- (UIImage *) imageWithTintColor:(UIColor *)tintColor;

@end

@implementation UIImage (Tint)

- (UIImage *) imageWithTintColor:(UIColor *)tintColor
{
    //We want to keep alpha, set opaque to NO; Use 0.0f for scale to use the scale factor of the device’s main screen.
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    UIRectFill(bounds);
    
    //Draw the tinted image in context
    [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

@end

@interface SectionsViewController ()
{
    NSMutableData*_data;
   
    NSMutableArray* _areaArray;
    
    NSBundle *_bundle;
}

@end


@implementation SectionsViewController
@synthesize names;
@synthesize keys;
@synthesize table;
@synthesize search;
@synthesize allNames;

#pragma mark -
#pragma mark Custom Methods

- (void)resetSearch
{
    NSMutableDictionary *allNamesCopy = [YJLocalCountryData mutableDeepCopy:self.allNames];
    self.names = allNamesCopy;
    NSMutableArray *keyArray = [NSMutableArray array];
    [keyArray addObject:UITableViewIndexSearch];
    [keyArray addObjectsFromArray:[[self.allNames allKeys] 
                                   sortedArrayUsingSelector:@selector(compare:)]];
    self.keys = keyArray;
}

- (void)handleSearchForTerm:(NSString *)searchTerm
{
    NSMutableArray *sectionsToRemove = [NSMutableArray array];
    [self resetSearch];
    
    for (NSString *key in self.keys) {
        NSMutableArray *array = [names valueForKey:key];
        NSMutableArray *toRemove = [NSMutableArray array];
        for (NSString *name in array) {
            if ([name rangeOfString:searchTerm 
                            options:NSCaseInsensitiveSearch].location == NSNotFound)
                [toRemove addObject:name];
        }
        if ([array count] == [toRemove count])
            [sectionsToRemove addObject:key];
        [array removeObjectsInArray:toRemove];
    }
    [self.keys removeObjectsInArray:sectionsToRemove];
    [table reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"SMSSDKUI" ofType:@"bundle"];
    NSBundle *bundle = [[NSBundle alloc] initWithPath:filePath];
    _bundle = bundle;
    
    //左导航按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"back", @"Localizable", bundle, nil)
                                                                                                                style:UIBarButtonItemStyleBordered
                                                                                                               target:self
                                                                                                               action:@selector(clickLeftButton)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    //标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = NSLocalizedStringFromTableInBundle(@"countrychoose", @"Localizable", bundle, nil);
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat statusBarHeight = 0;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
    {
        statusBarHeight = 20;
    }
    
    //背景图
    UIImage *bgImage = [UIImage imageNamed:@"BackgroundImage.jpg" inBundle:_bundle compatibleWithTraitCollection:nil];
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    bgImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    bgImageView.image = bgImage;
    bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:bgImageView];
    
    NSString *whiteBgPath = [_bundle pathForResource:@"white_bg" ofType:@"png"];
    UIImage *whiteBgImg = [UIImage imageWithContentsOfFile:whiteBgPath];
    [self.navigationController.navigationBar setBackgroundImage:whiteBgImg forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    
    NSString *textfieldByPath = [_bundle pathForResource:@"searbar_textfield_bg" ofType:@"png"];
    NSString *searchIconPath = [_bundle pathForResource:@"SearchIcon@2x" ofType:@"png"];
    search = [[UISearchBar alloc] init];
    search.searchBarStyle = UISearchBarStyleDefault;
    search.tintColor = [UIColor whiteColor];
    search.frame = CGRectMake(0, 44 + statusBarHeight, self.view.frame.size.width, 44);
    search.backgroundImage = whiteBgImg;
    [search setImage:[UIImage imageWithContentsOfFile:searchIconPath] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [search setSearchFieldBackgroundImage:[[UIImage imageWithContentsOfFile:textfieldByPath] stretchableImageWithLeftCapWidth:15 topCapHeight:15] forState:UIControlStateNormal];
    [self.view addSubview:search];
    
    [[UITextField appearanceForTraitCollection:search.traitCollection
                               whenContainedIn:[UISearchBar class], nil]
     setDefaultTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    table = [[UITableView alloc] initWithFrame:CGRectMake(0, 88+statusBarHeight, self.view.frame.size.width, self.view.bounds.size.height-(88+statusBarHeight)) style:UITableViewStylePlain];
    table.sectionIndexBackgroundColor = [UIColor clearColor];
    table.sectionIndexColor = [UIColor whiteColor];
    table.backgroundColor = [UIColor clearColor];
    table.sectionHeaderHeight = 23.0;
    [self.view addSubview:table];

    table.dataSource = self;
    table.delegate = self;
    search.delegate = self;
    
    NSString *path = [_bundle pathForResource:@"country"
                                       ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc]
                          initWithContentsOfFile:path];
    self.allNames = dict;

    [self resetSearch];
    [table reloadData];
    [table setContentOffset:CGPointMake(0.0, 44.0) animated:NO];
}

-(void)setAreaArray:(NSArray*)array
{
    _areaArray = [NSMutableArray arrayWithArray:array];
}

#pragma mark Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [keys count];
    
}

- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section
{
    if ([keys count] == 0)
        return 0;
    
    NSString *key = [keys objectAtIndex:section];
    NSArray *nameSection = [names objectForKey:key];
    return [nameSection count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    NSString *key = [keys objectAtIndex:section];
    NSArray *nameSection = [names objectForKey:key];
    
    static NSString *SectionsTableIdentifier = @"SectionsTableIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             SectionsTableIdentifier ];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                       reuseIdentifier: SectionsTableIdentifier ];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [MOBFColor colorWithRGB:0xd2cecb];
    }
    
    NSString* str1 = [nameSection objectAtIndex:indexPath.row];
    NSRange range = [str1 rangeOfString:@"+"];
    NSString* str2 = [str1 substringFromIndex:range.location];
    NSString* areaCode = [str2 stringByReplacingOccurrencesOfString:@"+" withString:@""];
    NSString* countryName = [str1 substringToIndex:range.location];

    cell.textLabel.text = countryName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"+%@",areaCode];
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (isSearching)
        return nil;
    return keys;
}

#pragma mark - TableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section < keys.count && keys[section] != UITableViewIndexSearch)
    {
        return tableView.sectionHeaderHeight;
    }
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section < keys.count && keys[section] != UITableViewIndexSearch)
    {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, tableView.sectionHeaderHeight)];
        headerView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        
        NSString *key = [keys objectAtIndex:section];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.font = [UIFont boldSystemFontOfSize:15];
        label.textColor = [UIColor whiteColor];
        label.text = key;
        [label sizeToFit];
        label.frame = CGRectMake(15.0, 0.0, label.frame.size.width, headerView.frame.size.height);
        [headerView addSubview:label];
        
        return headerView;
    }
    
    return nil;
}

- (NSIndexPath *)tableView:(UITableView *)tableView 
  willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [search resignFirstResponder];
    search.text = @"";
    isSearching = NO;
    [tableView reloadData];
    return indexPath;
}

- (NSInteger)tableView:(UITableView *)tableView 
sectionForSectionIndexTitle:(NSString *)title 
               atIndex:(NSInteger)index
{
    NSString *key = [keys objectAtIndex:index];
    if (key == UITableViewIndexSearch)
    {
        [tableView setContentOffset:CGPointZero animated:NO];
        return NSNotFound;
    }
    else return index;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [table deselectRowAtIndexPath:indexPath animated:YES];
    
    NSUInteger section = [indexPath section];
    NSString *key = [keys objectAtIndex:section];
    NSArray *nameSection = [names objectForKey:key];
    
    NSString* str1 = [nameSection objectAtIndex:indexPath.row];
    NSRange range = [str1 rangeOfString:@"+"];
    NSString* str2 = [str1 substringFromIndex:range.location];
    NSString* areaCode = [str2 stringByReplacingOccurrencesOfString:@"+" withString:@""];
    NSString* countryName = [str1 substringToIndex:range.location];

//    SMSSDKCountryAndAreaCode* country = [[SMSSDKCountryAndAreaCode alloc] init];
//    country.countryName = countryName;
//    country.areaCode = areaCode;
    
    NSLog(@"%@ %@",countryName,areaCode);
    
    [self.view endEditing:YES];
    
    int compareResult = 0;
    
    for (int i = 0; i < _areaArray.count; i++)
    {
        NSDictionary* dict1 = [_areaArray objectAtIndex:i];
        
        [dict1 objectForKey:areaCode];
        NSString* code1 = [dict1 valueForKey:@"zone"];
        if ([code1 isEqualToString:areaCode])
        {
            compareResult = 1;
            break;
        }
    }
    
    if (!compareResult)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"notice", @"Localizable", _bundle, nil)
                                                      message:NSLocalizedStringFromTableInBundle(@"doesnotsupportarea", @"Localizable", _bundle, nil)
                                                     delegate:self
                                            cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"sure", @"Localizable", _bundle, nil)
                                            otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    //传递数据
//    if ([self.delegate respondsToSelector:@selector(setSecondData:)]) {
//        [self.delegate setSecondData:country];
//    }
    
    //关闭当前
    [self clickLeftButton];
}

#pragma mark -
#pragma mark Search Bar Delegate Methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *searchTerm = [searchBar text];
    [self handleSearchForTerm:searchTerm];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    isSearching = YES;
    [table reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar 
    textDidChange:(NSString *)searchTerm
{
    if ([searchTerm length] == 0)
    {
        [self resetSearch];
        [table reloadData];
        return;
    }
    
    [self handleSearchForTerm:searchTerm];
    
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    isSearching = NO;
    search.text = @"";

    [self resetSearch];
    [table reloadData];
    
    [searchBar resignFirstResponder];
}

-(void)clickLeftButton
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
