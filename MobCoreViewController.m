//
//  MobCoreViewController.m
//  CoreTech_MobCore_MobCTableViewController+NetworkingFeatures_iOS
//
//  Created by Raj Wilhoit on 12/16/13.
//  Copyright (c) 2013 UF.rajwilhoit. All rights reserved.
//

#import "MobCoreViewController.h"
#import "MobCoreItem.h"
#import "MobCoreCell.h"
//#import "UIImage+animatedGIF.h"
#import "UIImageView+AFNetworking.h"

@interface MobCoreViewController ()

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSURL *mobCoreURL;
@property (strong, nonatomic) NSString *searchQuery;
@property (strong, nonatomic) NSArray *results;
@property (strong, nonatomic) NSMutableArray *itemList;

@end

@implementation MobCoreViewController {

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initialize item list
    self.itemList = [[NSMutableArray alloc] init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}


- (IBAction)refreshControl:(id)sender
{
    [self makeRequest:self.searchBar.text];
}

- (void)makeRequest:(NSString *)searchQuery
{
    // Store the searchQuery only if the search bar isn't blank
    if([searchQuery length] > 0) {
        self.searchQuery = searchQuery;
    }
    
    // Enter the API url for the request
    self.mobCoreURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.dribbble.com/players/%@/shots", self.searchQuery]];
    
    // Make the request
    NSURLRequest *request = [NSURLRequest requestWithURL:self.mobCoreURL];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
        // Update the UI with the results from the request once it has completed
        if (!error) {
            if ([request.URL isEqual:self.mobCoreURL]) {
                NSData *dribbbleData = [[NSData alloc] initWithContentsOfURL:localFile];
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Update the UI on the main thread
                    [self updateUIWithFetchedData:dribbbleData];
                    // Stop refreshing if this is a pull to refresh
                    [self.refreshControl endRefreshing];
                });
            }
        }
    }]; // End block
    [task resume];
    
}

- (void)updateUIWithFetchedData:(NSData *)responseData
{
    //parse out the json data
    NSError* error;
    NSDictionary *json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:kNilOptions
                          error:&error];
    
    // Populate the array of shots (This is Dribbble API specific. This must be configured on a per-project basis.)
    self.results = [json objectForKey:@"shots"];
    
    // Populate the item list with the shots
    [self populateItems];
    
    // Reload the table view
    [self.tableView reloadData];
}

- (void)populateItems
{
    if(self.results)
    {
        // Remove all objects from the item list before storing more
        [self.itemList removeAllObjects];
        
        // Populate the array of items with the results data (using block enumeration)
        [self.results enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop){
            [self addItemToList:self.results[index]];
        } ];
    }
}

- (void)addItemToList:(NSDictionary *)newItem
{
    // Populate the item with the data from a single dictionary in the array
    MobCoreItem *mobCoreItem = [[MobCoreItem alloc] init];
    
    mobCoreItem.photoTitle = [newItem objectForKey:@"title"];
    mobCoreItem.photoImageUrl = [NSURL URLWithString:[newItem objectForKey:@"image_url"]];
    mobCoreItem.photoImagePreviewUrl = [NSURL URLWithString:[newItem objectForKey:@"image_teaser_url"]];
    // Takes the JSON date representation, converts it to an NSDate then finds the elapsed time
    mobCoreItem.dateCreated = [self timeSincePosting:[self dateWithJSONString:(NSString *)[newItem objectForKey:@"created_at"]]];
    mobCoreItem.photoDescription = [newItem objectForKey:@"image_url"];
    mobCoreItem.username = [[newItem objectForKey:@"player"] objectForKey:@"username"];
    mobCoreItem.userAvatarUrl = [NSURL URLWithString:[[newItem objectForKey:@"player"] objectForKey:@"avatar_url"]];
    mobCoreItem.commentsCount = [[newItem objectForKey:@"comments_count"] intValue];
    mobCoreItem.viewsCount = [[newItem objectForKey:@"views_count"] intValue];
    mobCoreItem.likesCount = [[newItem objectForKey:@"likes_count"] intValue];
    
    // Add the item to the list
    [self.itemList addObject:mobCoreItem];
}

- (NSDate *)dateWithJSONString:(NSString *)dateString
{
    // The format will have to be changed depending on the format of the date returned by the JSON
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy/MM/dd HH:mm:ss z"];
    NSDate *date = [dateFormat dateFromString:dateString];
    
    return date;
}

- (NSString *)timeSincePosting:(NSDate *)datePosted
{
    NSString *timeSincePosting = [[NSString alloc] init];
    NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceDate:datePosted];     // timeIntervalSinceNow returns seconds
    int days = elapsedTime / 86400; // (number of seconds) / (60*60*24)
    int hours = elapsedTime / 3600; // (number of seconds) / (60*60)
    int minutes = elapsedTime / 60; // (number of seconds) / 60
    int seconds = elapsedTime;      // (number of seconds)
    
    if(days != 0) {
        timeSincePosting = [NSString stringWithFormat:@"%dd", days];
    }
    else if(hours != 0) {
        timeSincePosting = [NSString stringWithFormat:@"%dh", hours];
    }
    else if(minutes != 0) {
        timeSincePosting = [NSString stringWithFormat:@"%dm", seconds];
    }
    else {
        timeSincePosting = [NSString stringWithFormat:@"%ds", seconds];
    }
    
    return timeSincePosting;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - Search Bar 

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    // Someone started editing the text in the search field
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    // The request is made everytime the user changes the text in the search field
    [self makeRequest:searchBar.text];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // This would be where to make the API request if we want to make it on search only
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    // Tells the delegate that the user finished editing the search text.
    // Typically, you implement this method to perform the text-based search.
    [searchBar resignFirstResponder];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    // Any preparation for ending editing should go here
    // Return NO to not resign the first responder (the keyboard)
    return YES;
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.itemList count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // A small hack to resign the keyboard if the user selects the tableview
    [self.searchBar resignFirstResponder];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Create a new cell
    MobCoreCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mobcore_cell"];
    
    // Get the item from the list
    MobCoreItem *mobCoreItem = [self.itemList objectAtIndex:indexPath.row];

    // Configure the cell...
    // The cell in the storyboard will need to be designed according to the data returned by the API
    [cell.usernameLabel setText:mobCoreItem.username];
    [cell.userAvatarImageView setImageWithURL:mobCoreItem.userAvatarUrl];
    cell.userAvatarImageView.layer.cornerRadius = 25; 
    cell.userAvatarImageView.layer.masksToBounds = YES;
    [cell.datePostedLabel setText:[NSString stringWithFormat:@"%@",mobCoreItem.dateCreated]];
    [cell.titleLabel setText:mobCoreItem.photoTitle];
    [cell.itemImageView setImageWithURL:mobCoreItem.photoImageUrl];
    [cell.likesLabel setText:[NSString stringWithFormat:@"%d likes",mobCoreItem.likesCount]];
    
    return cell;
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
