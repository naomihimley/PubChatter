//
//  SearchViewController.m
//  PubChatter
//
//  Created by David Warner on 6/13/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import "SearchViewController.h"
#import <AddressBookUI/AddressBookUI.h>
#import "BarDetailViewController.h"
#import "TDOAuth.h"
#import "YelpBar.h"
#import "SWRevealViewController.h"
#import "SearchTableViewCell.h"
#import <Parse/Parse.h>
#import "LoginViewController.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"

@interface SearchViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property CLLocationManager *locationManager;
@property CLLocation *userLocation;
@property NSString *userLocationString;
@property NSString *queryString;
@property NSArray *barLocations;
@property YelpBar *selectedBar;
@property NSArray *arrImagesUrl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *toggleControlOutlet;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *searchButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *redrawAreaButtonOutlet;
@property CGFloat span;
@property MKCoordinateSpan mapSpan;
@property AppDelegate *appDelegate;
@property NSInteger counter;
@property BOOL searchActivated;
-(void)userEnteredBar:(NSNotification *)notification;

@end

@implementation SearchViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userEnteredBar:)
                                                 name:@"userEnteredBar"
                                               object:nil];

    // Add tap gesture recognizer that dismisses keyboard on a screen tap.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];

    // Do set up work, set querystring, mapspan, and begin looking for user location.
    self.queryString = @"bar";
    self.mapSpan = MKCoordinateSpanMake(0.01, 0.01);
    self.toggleControlOutlet.selectedSegmentIndex = 0;
    self.mapView.hidden = NO;
    self.redrawAreaButtonOutlet.hidden = NO;
    self.redrawAreaButtonOutlet.layer.cornerRadius = 5.0f;
    self.tableView.hidden = YES;
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager startUpdatingLocation];
    self.locationManager.delegate = self;
    self.searchBar.delegate = self;
    self.searchActivated = NO;

    // Set drawerview actions
    self.rateBarButton.customView.hidden = YES;
    self.rateBarButton.tintColor = [UIColor blueColor];
    self.rateBarButton.target = self.revealViewController;
    self.rateBarButton.action = @selector(rightRevealToggle:);
//    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self.view resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self isUserInBar];
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[self.appDelegate beaconRegionManager]canUserUseApp];

    [self.appDelegate.mcManager setupPeerAndSessionWithDisplayName:[[PFUser currentUser]objectForKey:@"username"]];
    [self.appDelegate.mcManager advertiseSelf:YES];
}

// Finds user location and sets the userLocation property
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for (CLLocation *location in locations) {
        if (location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000) {
            [self.locationManager stopUpdatingLocation];
            self.userLocation = location;
            CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(self.userLocation.coordinate.latitude, self.userLocation.coordinate.longitude);
            MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, self.mapSpan);
            [self.mapView setRegion:region animated:YES];
            [self getYelpJSONWithSearch:self.queryString andLongitude:self.userLocation.coordinate.longitude andLatitude:self.userLocation.coordinate.latitude andSortType:@"1" andNumResults:@"20"];
            break;
        }
    }
}

-(void)userEnteredBar:(NSNotification *)notification
{
    NSLog(@"notification %@",[notification.userInfo objectForKey:@"barName"]);
    self.navigationItem.title = [notification.userInfo objectForKey:@"barName"];
}

// Check if the user is listed as being in a "Bar", add in Parse backend.
- (void)isUserInBar
{
    if ([PFUser currentUser]) {
        PFQuery *queryForBar = [PFQuery queryWithClassName:@"Bar"];
        [queryForBar whereKey:@"usersInBar" equalTo:[PFUser currentUser]];
        [queryForBar includeKey:@"usersInBar"];
        [queryForBar findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             PFObject *bar = [objects firstObject];
             if (bar)
             {
                 self.rateBarButton.customView.hidden = NO;
                 self.navigationItem.title = [bar objectForKey:@"barName"];
             }
             else
             {
                 self.navigationItem.title = @"PubChat";
             }
         }];
    }
}

- (void)search
{
    // Clear the map of previous annotations and set queryString from user input.
    [self.mapView removeAnnotations:self.mapView.annotations];
    self.queryString = self.searchBar.text;

    // Finds the single best result based on querystring input and user's current location.
    [self getYelpJSONWithSearch:self.queryString andLongitude:self.userLocation.coordinate.longitude andLatitude:self.userLocation.coordinate.latitude andSortType:@"0" andNumResults:@"1"];

    // Disables search button until results are returned and dismisses keyboard.
    self.searchButtonOutlet.enabled = NO;
    [self.searchBar endEditing:YES];
}

#pragma mark - IBActions

- (IBAction)onSearchButtonPressed:(id)sender
{
    // Check for an empty search field and displays an alert to user.
    if ([self.searchBar.text isEqual:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Search for local bars in the search field above" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    // Perform search.
    else {
        self.searchActivated  = YES;
        [self search];
    }
}

// Removes all annotations from mapView, creates a new map region from the current mapView region, which is used to make another call to Yelp API. Disables button until results are returned.
- (IBAction)onRedrawRegionButtonPressed:(id)sender
{
    self.redrawAreaButtonOutlet.enabled = NO;
    [self.mapView removeAnnotations:self.mapView.annotations];
    CGFloat latitude = self.mapView.centerCoordinate.latitude;
    CGFloat longitude = self.mapView.centerCoordinate.longitude;
    CLLocation *centerLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    self.mapSpan = self.mapView.region.span;
    MKCoordinateRegion region = MKCoordinateRegionMake(centerLocation.coordinate, self.mapSpan);
    [self.mapView setRegion:region animated:YES];
    [self getYelpJSONWithSearch:@"bar" andLongitude:centerLocation.coordinate.longitude andLatitude:centerLocation.coordinate.latitude andSortType:@"1" andNumResults:@"20"];
}

// Toggles mapview and tableview
- (IBAction)onToggleMapListViewPressed:(id)sender
{
    [self segmentChanged:sender];
}


// Gets JSON data from Yelp and sets YelpBar custom class properties.
-(void)getYelpJSONWithSearch:(NSString *)query andLongitude:(CGFloat)longitude andLatitude:(CGFloat)latitude andSortType:(NSString*)sortType andNumResults:(NSString *)numResults;
{
//    NSLog(@"%@", sortType);
    id rq = [TDOAuth URLRequestForPath:@"/v2/search" GETParameters:@{@"term": query, @"ll": [NSString stringWithFormat:@"%f,%f", latitude, longitude], @"limit" : numResults, @"sort" : sortType}
                                  host:@"api.yelp.com"
                           consumerKey:@"LdaQSTTYqZuYXrta5vVAgw"
                        consumerSecret:@"k6KpVPXHSykD8aQXSXqdi7GboMY"
                           accessToken:@"PRBX3m8UH4Q2RmZ-HOTKmjFPLVzmz4UL"
                           tokenSecret:@"ao0diFl7jAe8cDDXnc-O1N-vQm8"];

    [NSURLConnection sendAsynchronousRequest:rq queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSLog(@"Yelp data returned");
        if (connectionError) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to retrieve data due to poor network connection" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            NSLog(@"connection error %@", connectionError);
        }
        else
        {
            NSDictionary *dictionary  = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&connectionError];

            NSMutableArray *arrayOfYelpBarObjects = [[NSMutableArray alloc] init];
            NSArray *yelpBars = [dictionary objectForKey:@"businesses"];

            for (NSDictionary *dictionary in yelpBars)
            {
                YelpBar *yelpBar = [[YelpBar alloc] init];
                yelpBar.name = [dictionary objectForKey:@"name"];
                yelpBar.address = [NSString stringWithFormat:@"%@ %@ %@ %@", [[[dictionary objectForKey:@"location"] objectForKey:@"address"] firstObject], [[dictionary objectForKey:@"location"] objectForKey:@"city"], [[dictionary objectForKey:@"location"] objectForKey:@"state_code"], [[dictionary objectForKey:@"location"] objectForKey:@"postal_code"]];
                yelpBar.distanceFromUser = [[dictionary objectForKey:@"distance"] floatValue];
                yelpBar.telephone = [dictionary objectForKey:@"phone"];
                yelpBar.businessMobileURL = [dictionary objectForKey:@"mobile_url"];
                yelpBar.businessURL = [dictionary objectForKey:@"url"];
                yelpBar.businessImageURL = [dictionary objectForKey:@"image_url"];
                yelpBar.businessRatingImageURL = [dictionary objectForKey:@"rating_img_url_small"];
                yelpBar.aboutBusiness = [dictionary objectForKey:@"snippet_text"];

                if ([[dictionary objectForKey:@"categories"] count] == 3) {
                    yelpBar.categories = [[[dictionary objectForKey:@"categories"] objectAtIndex:0] objectAtIndex:0];
                    yelpBar.offers = [NSString stringWithFormat:@"%@, %@", [[[dictionary objectForKey:@"categories"] objectAtIndex:1] objectAtIndex:0], [[[dictionary objectForKey:@"categories"] objectAtIndex:2] objectAtIndex:0]];
                }
                else if ([[dictionary objectForKey:@"categories"] count] == 2) {
                    yelpBar.categories = [[[dictionary objectForKey:@"categories"] objectAtIndex:0] objectAtIndex:0];
                    yelpBar.offers = [NSString stringWithFormat:@"%@", [[[dictionary objectForKey:@"categories"] objectAtIndex:1] objectAtIndex:0]];
                }
                else if ([[dictionary objectForKey:@"categories"] count] == 1) {
                    yelpBar.categories = [[[dictionary objectForKey:@"categories"] objectAtIndex:0] objectAtIndex:0];
                    yelpBar.offers = @"n/a";
                }
                else {
                    yelpBar.categories = @"n/a";
                    yelpBar.offers = @"n/a";
                }
                yelpBar.yelpID = [dictionary objectForKey:@"id"];
                [arrayOfYelpBarObjects addObject:yelpBar];
            }
            // Order objects based on proximity to user.
            NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"distanceFromUser" ascending:YES];
            self.barLocations = [arrayOfYelpBarObjects sortedArrayUsingDescriptors:@[descriptor]];

            // Create array of business image URL for lazy loading in tableView.
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            for (YelpBar *yelpBar in self.barLocations) {
                [tempArray addObject:yelpBar.businessImageURL];
            }
            self.arrImagesUrl = [NSArray arrayWithArray:tempArray];
            [self getBarLatandLong:self.barLocations];
        }
    }];
}

-(void)getBarLatandLong:(NSArray *)yelpBars
{
    // Check if search results were found, if not, display the alert.
    if (self.barLocations.count == 0) {
        [self showNoResultsFound];
    }
    // Else there are YelpBars.
    else {
    // Set counter to 0
    self.counter = 0;
    for (YelpBar *yelpBar in yelpBars) {

    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:yelpBar.address
                 completionHandler:^(NSArray* placemarks, NSError* error){

                     // Increment counter every time a YelpBar address is evaluated.
                     self.counter += 1;

                     // Check if user is doing a search, and if no placemarks for address are found, display an alert to user.
                     if (self.searchActivated) {
                         NSLog(@"This was a search");
                         if (placemarks.count == 0) {
                             NSLog(@"No results");
                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Unable to find a location for %@", yelpBar.name] message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                             [alert show];
                             self.searchActivated = NO;
                         }
                         // If a placemark is found, set yelpBar lat/long, add annotation to map, and set mapView area around that location.
                         else {
                             NSLog(@"Result found");
                             MKPlacemark *pmark = [placemarks firstObject];
                             // Find YelpBar lat/long and place pointannotation on the map.
                             yelpBar.latitude = pmark.location.coordinate.latitude;
                             yelpBar.longitude = pmark.location.coordinate.longitude;
                             MKPointAnnotation *barAnnotation = [[MKPointAnnotation alloc] init];
                             barAnnotation.coordinate = CLLocationCoordinate2DMake(yelpBar.latitude, yelpBar.longitude);
                             barAnnotation.title = yelpBar.name;
                             barAnnotation.subtitle = [NSString stringWithFormat:@"%.02f miles", yelpBar.distanceFromUser * 0.000621371];
                             [self.mapView addAnnotation:barAnnotation];

                             self.mapSpan = MKCoordinateSpanMake(0.015, 0.015);
                             CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(pmark.location.coordinate.latitude, pmark.location.coordinate.longitude);
                             MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, self.mapSpan);
                             [self.mapView setRegion:region animated:YES];
                             self.searchActivated = NO;
                         }
                     }

                     // Else, the user is doing search in region, and must iterate through placemarks and place annotations on map.
                     else {

                     for (CLPlacemark* placemark in placemarks)
                     {
                         yelpBar.latitude = placemark.location.coordinate.latitude;
                         yelpBar.longitude = placemark.location.coordinate.longitude;
                         MKPointAnnotation *barAnnotation = [[MKPointAnnotation alloc] init];
                         barAnnotation.coordinate = CLLocationCoordinate2DMake(yelpBar.latitude, yelpBar.longitude);
                         barAnnotation.title = yelpBar.name;
                         barAnnotation.subtitle = [NSString stringWithFormat:@"%.02f miles", yelpBar.distanceFromUser * 0.000621371];
                         [self.mapView addAnnotation:barAnnotation];
                         break;
                        }
                         NSLog(@"This was a redraw in region");
                     }

                     // When counter equals the number of barLocations in the array, then tableview can be reloaded and buttons set to enabled.
                     if (self.counter == self.barLocations.count) {
                         [self.tableView reloadData];
                         self.searchButtonOutlet.enabled = YES;
                         self.redrawAreaButtonOutlet.enabled = YES;
                         NSLog(@"Finished search");
                   }
            }];
        }
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    pin.canShowCallout = YES;
    pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    return pin;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view
calloutAccessoryControlTapped:(UIControl *)control
{
    [self performSegueWithIdentifier:@"segue" sender:self];
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKPinAnnotationView *)view
{
    for (YelpBar *bar in self.barLocations)
    {
        if ([view.annotation.title isEqualToString:bar.name]) {
            self.selectedBar = bar;
        }
    }
}

#pragma mark - Tableview methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.barLocations.count;
}

-(SearchTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YelpBar *yelpBar = [self.barLocations objectAtIndex:indexPath.row];
    SearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.imageView.clipsToBounds = YES;

    NSString *milesFromUser = [NSString stringWithFormat:@"%.02f miles", yelpBar.distanceFromUser * 0.000621371];
    cell.barNameLabel.text = yelpBar.name;
    cell.barDistanceLabel.text = milesFromUser;
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[self.arrImagesUrl objectAtIndex:indexPath.row]]
                      placeholderImage:[UIImage imageNamed:@"placeholder"]];
    [cell layoutSubviews];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *selectedIndexPath = self.tableView.indexPathForSelectedRow;
    self.selectedBar = [self.barLocations objectAtIndex:selectedIndexPath.row];
    [self performSegueWithIdentifier:@"segue" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    BarDetailViewController *detailViewController = segue.destinationViewController;
    detailViewController.barFromSourceVC = self.selectedBar;
}

- (void)segmentChanged:(id)sender
{
    if ([sender selectedSegmentIndex] == 0) {
            self.mapView.hidden = NO;
            self.tableView.hidden = YES;
            self.redrawAreaButtonOutlet.hidden = NO;
        }
        else
        {
            self.mapView.hidden = YES;
            self.tableView.hidden = NO;
            self.redrawAreaButtonOutlet.hidden = YES;
        }
}

-(void)showNoResultsFound
{
    // Display "no results found alert"
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"No results found matching %@", self.queryString] message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        self.searchButtonOutlet.enabled = YES;
        self.redrawAreaButtonOutlet.enabled = YES;
        NSLog(@"No search results");
}

-(void)dismissKeyboard
{
    [self.view endEditing:YES];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // Check for an empty search field and displays an alert to user.
    if ([self.searchBar.text isEqual:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Search for local bars in the search field above" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    // Perform search.
    else {
        self.searchActivated  = YES;
        [self search];
    }
}



@end
