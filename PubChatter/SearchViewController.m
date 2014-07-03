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
#import "UIColor+DesignColors.h"
#import "AppDelegate.h"

@interface SearchViewController () < UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate, SWRevealViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property CLLocationManager *locationManager;
@property CLLocation *userLocation;
@property NSString *userLocationString;
@property NSString *queryString;
@property NSArray *barLocations;
@property YelpBar *selectedBar;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorOutlet;
@property (weak, nonatomic) IBOutlet UIButton *currentLocationButtonOutlet;
@property (weak, nonatomic) IBOutlet UISegmentedControl *toggleControlOutlet;
@property (weak, nonatomic) IBOutlet UITextField *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *redrawAreaButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *rateBarButton;
@property (weak, nonatomic) IBOutlet UIView *searchBackGroundView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButtonOutlet;
@property CGFloat span;
@property CGFloat SWBoundsLatitude;
@property CGFloat SWBoundsLongitude;
@property CGFloat NEBoundsLatitude;
@property CGFloat NEBoundsLongitude;
@property MKCoordinateSpan mapSpan;
@property AppDelegate *appDelegate;
@property NSInteger counter;
@property NSInteger secondcounter;
@property BOOL searchActivated;
@property BOOL redrawActivated;
@property BOOL didCheckForBeaconMonitoring;
@property BOOL initialMapLoad;
@property BOOL isUserInteraction;
@property id request;
-(void)userEnteredBar:(NSNotification *)notification;

@end

@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setStyle];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userEnteredBar:)
                                                 name:@"userEnteredBar"
                                               object:nil];


    // Do set up work, set querystring, mapspan, and begin looking for user location.
    self.searchBar.delegate = self;
    self.activityIndicatorOutlet.hidden = YES;
    self.didCheckForBeaconMonitoring = NO;
    self.initialMapLoad = YES;
    self.queryString = @"bar";
    self.mapSpan = MKCoordinateSpanMake(0.01, 0.01);
    self.toggleControlOutlet.selectedSegmentIndex = 0;
    self.currentLocationButtonOutlet.hidden = NO;
    self.mapView.hidden = NO;
    self.redrawAreaButtonOutlet.hidden = NO;
    self.redrawAreaButtonOutlet.layer.cornerRadius = 5.0f;
    self.tableView.hidden = YES;
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager startUpdatingLocation];
    self.locationManager.delegate = self;
    self.searchActivated = NO;
    self.redrawActivated = NO;
    self.rateBarButton.hidden = YES;

    // Set drawerview actions
    self.revealViewController.delegate = self;
    [self.rateBarButton addTarget:self.revealViewController action:@selector(rightRevealToggle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view resignFirstResponder];

    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[self.appDelegate beaconRegionManager]canUserUseApp];

//    [self.appDelegate.mcManager setupPeerAndSessionWithDisplayName:[[PFUser currentUser]objectForKey:@"username"]];
//    [self.appDelegate.mcManager advertiseSelf:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.isUserInteraction = YES;

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
            NSLog(@"setting map region");
            NSLog(@"Mapview delegate %@", self.mapView.delegate);
            self.mapView.delegate = self;
            self.mapView.showsUserLocation = YES;
            self.currentLocationButtonOutlet.enabled = YES;
            break;
        }
    }
}

#pragma  mark - Notifications

-(void)userEnteredBar:(NSNotification *)notification
{
    NSString *barname = [notification.userInfo objectForKey:@"barName"];
    if ([barname isEqualToString:@"PubChat"])
    {
        self.rateBarButton.hidden = YES;
    }
    else
    {
        self.rateBarButton.hidden = NO;
    }
}

#pragma mark - IBActions

// Removes all annotations from mapView, finds current map SW and NE coordinates for bounded box Yelp query.
- (IBAction)onRedrawRegionButtonPressed:(id)sender
{
    self.redrawActivated = YES;
    self.activityIndicatorOutlet.hidden = NO;
    [self.activityIndicatorOutlet startAnimating];
    self.redrawAreaButtonOutlet.enabled = NO;
    [self.mapView removeAnnotations:self.mapView.annotations];

    // Get's the SW and NE coordinates of the current mapView, which are used in setting the boundary box parameters of the Yelp API call.
    [self getMapRect];

    // Call method to get JSON with boundary box parameters, "bar" search term, 20 results
    [self getYelpJSONFromMapRedraw:@"bar" andSWLatitude:self.SWBoundsLatitude andSWLongitude:self.SWBoundsLongitude andNELatitude:self.NEBoundsLatitude andNELongitude:self.NEBoundsLongitude andSortType:@"1" andNumResults:@"20" andLongitude:0.0 andLatitude:0.0];
}

// Enables search on keyPad search button pressed.
//-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
//{
//    self.activityIndicatorOutlet.hidden = NO;
//    [self.activityIndicatorOutlet startAnimating];
//
//    // Set search boolean.
//    self.searchActivated  = YES;
//
//    // Clear the map of previous annotations and set queryString from user input.
//    [self.mapView removeAnnotations:self.mapView.annotations];
//    self.queryString = self.searchBar.text;
//    self.searchBar.text = nil;
//
//    // Finds the single best result based on querystring input and user's current location.
//    [self getYelpJSONFromMapRedraw:self.queryString andSWLatitude:0.0 andSWLongitude:0.0 andNELatitude:0.0 andNELongitude:0.0 andSortType:@"0" andNumResults:@"1" andLongitude:self.userLocation.coordinate.longitude andLatitude:self.userLocation.coordinate.latitude];
//
//    // Dismiss keyboard.
//    [self.searchBar endEditing:YES];
//}

// Toggles mapview and tableview
- (IBAction)onToggleMapListViewPressed:(id)sender
{
    [self segmentChanged:sender];
}

- (IBAction)snapToCurrentLocation:(id)sender
{
    self.currentLocationButtonOutlet.enabled = NO;
    [self.locationManager startUpdatingLocation];
}
- (IBAction)onCancelButtonPressed:(id)sender
{
    // Dismiss keyboard and remove searchbar text.
    self.searchBar.text = nil;
    [self.searchBar endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

        self.activityIndicatorOutlet.hidden = NO;
        [self.activityIndicatorOutlet startAnimating];

        // Set search boolean.
        self.searchActivated  = YES;

        // Clear the map of previous annotations and set queryString from user input.
        [self.mapView removeAnnotations:self.mapView.annotations];
        self.queryString = self.searchBar.text;
        self.searchBar.text = nil;

        // Finds the single best result based on querystring input and user's current location.
        [self getYelpJSONFromMapRedraw:self.queryString andSWLatitude:0.0 andSWLongitude:0.0 andNELatitude:0.0 andNELongitude:0.0 andSortType:@"0" andNumResults:@"1" andLongitude:self.userLocation.coordinate.longitude andLatitude:self.userLocation.coordinate.latitude];

        // Dismiss keyboard.
        [self.searchBar endEditing:YES];
    
    return YES;
}


#pragma mark - API call methods

-(void)getYelpJSONFromMapRedraw:(NSString *)query andSWLatitude:(CGFloat)swlatitude andSWLongitude:(CGFloat)swlongitude andNELatitude:(CGFloat)nelatitude andNELongitude:(CGFloat)nelongitude andSortType:(NSString*)sortType andNumResults:(NSString *)numResults andLongitude:(CGFloat)longitude andLatitude:(CGFloat)latitude
{
    //Perform a bounded box query
    if (self.redrawActivated && self.initialMapLoad) {
        NSLog(@"Initial mapview load");

        NSLog(@"latitude : %f", latitude);
        NSLog(@"longitude: %f", longitude);
        NSLog(@"# results %@", numResults);
        NSLog(@"sort type :%@", sortType);

        self.request = [TDOAuth URLRequestForPath:@"/v2/search" GETParameters:@{@"term": query, @"ll": [NSString stringWithFormat:@"%f,%f", latitude, longitude], @"limit" : numResults, @"sort" : sortType}
                                             host:@"api.yelp.com"
                                      consumerKey:@"LdaQSTTYqZuYXrta5vVAgw"
                                   consumerSecret:@"k6KpVPXHSykD8aQXSXqdi7GboMY"
                                      accessToken:@"PRBX3m8UH4Q2RmZ-HOTKmjFPLVzmz4UL"
                                      tokenSecret:@"ao0diFl7jAe8cDDXnc-O1N-vQm8"];
    }
    else if (self.redrawActivated) {

        NSLog(@"left lower corner latitude : %f", swlatitude);
        NSLog(@"left lower corner longitude : %f", swlongitude);
        NSLog(@"right upper corner latitude: %f", nelatitude);
        NSLog(@"right upper corner longitude %f", nelongitude);
        NSLog(@"# results %@", numResults);
        NSLog(@"sort type :%@", sortType);

    self.request = [TDOAuth URLRequestForPath:@"/v2/search" GETParameters:@{@"term": query, @"bounds": [NSString stringWithFormat:@"%f,%f|%f,%f", swlatitude, swlongitude, nelatitude, nelongitude], @"limit" : numResults, @"sort" : sortType}
                                  host:@"api.yelp.com"
                           consumerKey:@"LdaQSTTYqZuYXrta5vVAgw"
                        consumerSecret:@"k6KpVPXHSykD8aQXSXqdi7GboMY"
                           accessToken:@"PRBX3m8UH4Q2RmZ-HOTKmjFPLVzmz4UL"
                           tokenSecret:@"ao0diFl7jAe8cDDXnc-O1N-vQm8"];
    }

    //Perform a point query (i.e. query about a center long/lat point).
    else  {
        NSLog(@"latitude : %f", latitude);
        NSLog(@"latitude: %f", longitude);
        NSLog(@"# results %@", numResults);
        NSLog(@"sort type :%@", sortType);

        self.request = [TDOAuth URLRequestForPath:@"/v2/search" GETParameters:@{@"term": query, @"ll": [NSString stringWithFormat:@"%f,%f", latitude, longitude], @"limit" : numResults, @"sort" : sortType}
                                      host:@"api.yelp.com"
                               consumerKey:@"LdaQSTTYqZuYXrta5vVAgw"
                            consumerSecret:@"k6KpVPXHSykD8aQXSXqdi7GboMY"
                               accessToken:@"PRBX3m8UH4Q2RmZ-HOTKmjFPLVzmz4UL"
                               tokenSecret:@"ao0diFl7jAe8cDDXnc-O1N-vQm8"];
    }

    self.initialMapLoad = NO;

    [NSURLConnection sendAsynchronousRequest:self.request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

        if (connectionError) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to retrieve data due to poor network connection" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [self.activityIndicatorOutlet stopAnimating];
            self.activityIndicatorOutlet.hidden = YES;
            self.redrawAreaButtonOutlet.enabled = YES;
            self.currentLocationButtonOutlet.enabled = YES;
            self.redrawActivated = NO;
            self.searchActivated = NO;
        }
        else
        {
            NSLog(@"Yelp data returned");
            NSDictionary *dictionary  = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&connectionError];

            NSMutableArray *arrayOfYelpBarObjects = [[NSMutableArray alloc] init];
            NSArray *yelpBars = [dictionary objectForKey:@"businesses"];

            for (NSDictionary *dictionary in yelpBars)
            {
                YelpBar *yelpBar = [[YelpBar alloc] init];
                yelpBar.name = [dictionary objectForKey:@"name"];
                yelpBar.address = [NSString stringWithFormat:@"%@ %@ %@ %@", [[[dictionary objectForKey:@"location"] objectForKey:@"address"] firstObject], [[dictionary objectForKey:@"location"] objectForKey:@"city"], [[dictionary objectForKey:@"location"] objectForKey:@"state_code"], [[dictionary objectForKey:@"location"] objectForKey:@"postal_code"]];
                yelpBar.telephone = [dictionary objectForKey:@"phone"];
                yelpBar.businessMobileURL = [dictionary objectForKey:@"mobile_url"];
                yelpBar.businessURL = [dictionary objectForKey:@"url"];
                yelpBar.businessImageURL = [dictionary objectForKey:@"image_url"];

                if (!yelpBar.businessImageURL) {
                    NSURL *placeholderURL = [[NSBundle mainBundle] URLForResource:@"placeholder" withExtension:@"png"];
                    NSString *placeholderURLString = [NSString stringWithContentsOfURL:placeholderURL encoding:NSASCIIStringEncoding error:nil];
                    yelpBar.businessImageURL = placeholderURLString;
                }
                yelpBar.businessImageURL = [dictionary objectForKey:@"image_url"];
                yelpBar.businessRatingImageURL = [dictionary objectForKey:@"rating_img_url_small"];
                yelpBar.aboutBusiness = [dictionary objectForKey:@"snippet_text"];

                if (self.searchActivated) {
                    yelpBar.distanceFromUser = [[dictionary objectForKey:@"distance"] floatValue];
                }

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
            self.barLocations = [NSArray arrayWithArray:arrayOfYelpBarObjects];

            // Check if bar locations array is empty, if so, present alerts to user that no results were found.
            if (self.barLocations.count == 0) {
                if (self.searchActivated) {
                    // Search returned no results.
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"No results found matching %@", self.queryString] message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                    [self.activityIndicatorOutlet stopAnimating];
                    self.activityIndicatorOutlet.hidden = YES;
                    self.redrawAreaButtonOutlet.enabled = YES;
                    self.currentLocationButtonOutlet.enabled = YES;
                    self.redrawActivated = NO;
                    self.searchActivated = NO;
                    [self.tableView reloadData];
                    NSLog(@"No search results");
                }
                    //Redraw in region returned no results.
                else if (self.redrawActivated) {
                    NSLog(@"No results found for this area");
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No results found in this area" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                    [self.activityIndicatorOutlet stopAnimating];
                    self.activityIndicatorOutlet.hidden = YES;
                    self.redrawAreaButtonOutlet.enabled = YES;
                    self.currentLocationButtonOutlet.enabled = YES;
                    self.redrawActivated = NO;
                    self.searchActivated = NO;
                    [self.tableView reloadData];
                }
            }

            // Else, query returned results.
            else {
            [self getBarLatandLong:self.barLocations];
            }
        }
    }];
}

-(void)getBarLatandLong:(NSArray *)yelpBars
{
    NSLog(@"Number of YelpBar's returned: %lu", (unsigned long)yelpBars.count);
    NSMutableArray *redrawLanguageQuery = [[NSMutableArray alloc] init];

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
                             // Address pulled from Yelp is bad and MapKit couldn't find a placemark, so attempt a natural language query based on YelpBar's name.
                             NSMutableArray *searchquery = [NSMutableArray arrayWithArray:self.barLocations];
                             [self performLanguageQuery:searchquery];
                             NSLog(@"Bad Yelp address string");
                         }
                         // If a placemark is found from search, set yelpBar lat/long, add annotation to map, and set mapView area around that location.
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

                     // Else, the user is doing a redraw in mapArea, so iterate through placemarks and place annotations on map.
                     else {
                         // Grab first placemark in placemarks array.
                         MKPlacemark *placemark = [placemarks firstObject];
                            if (placemark) {
                             MKPointAnnotation *barAnnotation = [[MKPointAnnotation alloc] init];
                             yelpBar.latitude = placemark.location.coordinate.latitude;
                             yelpBar.longitude = placemark.location.coordinate.longitude;
                             yelpBar.distanceFromUser = [self.userLocation distanceFromLocation:placemark.location];
                             barAnnotation.coordinate = CLLocationCoordinate2DMake(yelpBar.latitude, yelpBar.longitude);
                             barAnnotation.title = yelpBar.name;
                             barAnnotation.subtitle = [NSString stringWithFormat:@"%.02f miles", yelpBar.distanceFromUser * 0.000621371];
                             [self.mapView addAnnotation:barAnnotation];
                            }

                         //Couldn't find a placemark, add yelpBar to array used in natural language query
                            else {
                                [redrawLanguageQuery addObject:yelpBar];
                         }
                     }
                     // When counter equals the number of barLocations in the array, then tableview can be reloaded and buttons set to enabled.
                     if (self.counter == self.barLocations.count) {
                         // Check if any placemarks weren't found, and run the natural language query.
                         if (redrawLanguageQuery.count > 0) {
                             [self performLanguageQuery:redrawLanguageQuery];
                         }
                         // Else, all placemarks were found, redraw should be completed.
                         else {
                             // Sort barLocations array by distance from user.
                             NSArray *array = [NSArray arrayWithArray:self.barLocations];
                             self.barLocations = nil;
                             NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"distanceFromUser" ascending:YES];
                             self.barLocations = [array sortedArrayUsingDescriptors:@[descriptor]];

                             //Reload tableview
                             [self.tableView reloadData];
                             self.redrawAreaButtonOutlet.enabled = YES;
                             self.currentLocationButtonOutlet.enabled = YES;
                             self.searchActivated = NO;
                            self.redrawActivated = NO;
                             [self.activityIndicatorOutlet stopAnimating];
                             self.activityIndicatorOutlet.hidden = YES;
                             if (!self.didCheckForBeaconMonitoring) {
                             [self checkIfBeaconMonitoringIsAvailable];
                             }
                         }
                         NSLog(@"Done");
                   }
            }];
        }
}

-(void)performLanguageQuery:(NSMutableArray *)queryArray
{
    self.secondcounter = 0;

    for (YelpBar *yelpBar in queryArray) {
        NSLog(@"Language query on: %@", yelpBar.name);
        // Perform natural lanuage query on YelpBar's name property.

        // Increment counter every time a YelpBar address is evaluated.
        self.secondcounter += 1;

        MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
        request.naturalLanguageQuery = yelpBar.name;
        request.region = MKCoordinateRegionMake(self.userLocation.coordinate, MKCoordinateSpanMake(.3, .3));
        MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];

        [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {

        NSArray *mapItems = response.mapItems;
        // If there is a response from query, then set the lat/long properties of YelpBar and add the MKPointAnnotation to the map.
            if (mapItems.count > 0) {
                NSLog(@"Natural language query items returned");
                MKMapItem *mapItem = [mapItems firstObject];
                // Set YelpBar properties from the MapItem.
                yelpBar.latitude = mapItem.placemark.coordinate.latitude;
                yelpBar.longitude = mapItem.placemark.coordinate.longitude;
                yelpBar.distanceFromUser = [self.userLocation distanceFromLocation:mapItem.placemark.location];

                // Creat MKPointAnnotations, set attributes and add them to the mapView.
                MKPointAnnotation *barAnnotation = [[MKPointAnnotation alloc] init];
                barAnnotation.coordinate = CLLocationCoordinate2DMake(yelpBar.latitude, yelpBar.longitude);
                barAnnotation.title = yelpBar.name;
                barAnnotation.subtitle = [NSString stringWithFormat:@"%.02f miles", yelpBar.distanceFromUser * 0.000621371];
                [self.mapView addAnnotation:barAnnotation];

                // Check if this is a search and, if, so snap the map to the returned coordinate.
                if (self.searchActivated) {
                    self.mapSpan = MKCoordinateSpanMake(0.015, 0.015);
                    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(yelpBar.latitude, yelpBar.longitude);
                    MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, self.mapSpan);
                    [self.mapView setRegion:region animated:YES];
                    NSLog(@"Search language query successfully completed");
                }

                NSLog(@"Natural language query for redraw successful");
        }
        // Else, natural language query was unsuccessful.
        else {
            // Check if this was a search and, if so, tell user search was unsuccessful
            if (self.searchActivated) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Unable to find a location for %@", yelpBar.name] message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];

                // Since a YelpBar does exist, but MapKit can't find it's location, show the user the tableView, where the bar will be displayed.
                self.toggleControlOutlet.selectedSegmentIndex = 1;
                [self changeSegment:self.toggleControlOutlet.selectedSegmentIndex];
                NSLog(@"Search language query unnsuccessfully completed");
            }

                // Else, this was a redraw
                else if (self.redrawActivated)
                {
                    NSLog(@"Redraw language query unsuccessful");
                }
            }

            // All YelpBars in query array have been evaluated.
            if (self.secondcounter == queryArray.count) {

                // Sort barLocations array by distance from user.
                NSArray *array = [NSArray arrayWithArray:self.barLocations];
                self.barLocations = nil;
                NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"distanceFromUser" ascending:YES];
                self.barLocations = [array sortedArrayUsingDescriptors:@[descriptor]];

                // Reset redraw/search booleans, activate buttons, dismiss activity indicator.
                self.redrawActivated = NO;
                self.searchActivated = NO;
                self.redrawAreaButtonOutlet.enabled = YES;
                self.currentLocationButtonOutlet.enabled = YES;
                [self.activityIndicatorOutlet stopAnimating];
                self.activityIndicatorOutlet.hidden = YES;

                //Check if beacon monitoring method has been called
                if (!self.didCheckForBeaconMonitoring) {
                    [self checkIfBeaconMonitoringIsAvailable];
                }

                //Reload the tableView so distance taken from NLQ is displayed.
                [self.tableView reloadData];
                NSLog(@"Done with Natural Language Query");
            }
        }];
    }
}

#pragma mark - MapKit methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:MKUserLocation.class]) {
        return nil;
    }
    else {
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    pin.canShowCallout = YES;
    pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    pin.pinColor = MKPinAnnotationColorGreen;
    return pin;
    }
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

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered
{
    if (fullyRendered) {
    NSLog(@"Map finished loading");
    if (self.initialMapLoad) {
    self.activityIndicatorOutlet.hidden = NO;
    self.redrawActivated = YES;
    [self.activityIndicatorOutlet startAnimating];
    [self getMapRect];

    [self getYelpJSONFromMapRedraw:self.queryString andSWLatitude:0.0 andSWLongitude:0.0 andNELatitude:0.0 andNELongitude:0.0 andSortType:@"1" andNumResults:@"20" andLongitude:self.userLocation.coordinate.longitude andLatitude:self.userLocation.coordinate.latitude];
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

    if (yelpBar.distanceFromUser) {
    NSString *milesFromUser = [NSString stringWithFormat:@"%.02f miles", yelpBar.distanceFromUser * 0.000621371];
        cell.barDistanceLabel.text = milesFromUser;
    }
    else {
        NSString *milesFromUser = @"Distance not found";
        cell.barDistanceLabel.text = milesFromUser;
    }

    cell.barNameLabel.text = yelpBar.name;
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:yelpBar.businessImageURL]
                      placeholderImage:[UIImage imageNamed:@"placeholder2"]];
    [cell layoutSubviews];
    cell.backgroundColor = [[UIColor backgroundColor]colorWithAlphaComponent:0.5f];
    cell.barNameLabel.textColor = [UIColor nameColor];
    cell.barDistanceLabel.textColor = [UIColor whiteColor];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *selectedIndexPath = self.tableView.indexPathForSelectedRow;
    self.selectedBar = [self.barLocations objectAtIndex:selectedIndexPath.row];
    [self performSegueWithIdentifier:@"segue" sender:self];

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    BarDetailViewController *detailViewController = segue.destinationViewController;
    detailViewController.barFromSourceVC = self.selectedBar;
}

#pragma  mark - Toggle logic methods
- (void)segmentChanged:(id)sender
{
    if ([sender selectedSegmentIndex] == 0) {
            self.mapView.hidden = NO;
            self.currentLocationButtonOutlet.hidden = NO;
            self.tableView.hidden = YES;
            self.redrawAreaButtonOutlet.hidden = NO;
        }
        else
        {
            self.currentLocationButtonOutlet.hidden = YES;
            self.mapView.hidden = YES;
            self.tableView.hidden = NO;
            self.redrawAreaButtonOutlet.hidden = YES;
        }
}

- (void)changeSegment:(NSInteger)index
{
    if (index == 0) {
        self.mapView.hidden = NO;
        self.currentLocationButtonOutlet.hidden = NO;
        self.tableView.hidden = YES;
        self.redrawAreaButtonOutlet.hidden = NO;
    }
    else
    {
        self.currentLocationButtonOutlet.hidden = YES;
        self.mapView.hidden = YES;
        self.tableView.hidden = NO;
        self.redrawAreaButtonOutlet.hidden = YES;
    }
}

#pragma mark - SWReveal Delegate Method

- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position
{
    if (self.isUserInteraction)
    {
        self.mapView.userInteractionEnabled = NO;
        self.tableView.userInteractionEnabled = NO;
        self.tabBarController.tabBar.userInteractionEnabled = NO;
        self.isUserInteraction = NO;
    }
    else
    {
        self.mapView.userInteractionEnabled = YES;
        self.tableView.userInteractionEnabled = YES;
        self.tabBarController.tabBar.userInteractionEnabled = YES;
        self.isUserInteraction = YES;
    }
}
#pragma  mark - Map bound helper methods

-(void)getMapRect {
    MKMapRect mRect = self.mapView.visibleMapRect;
    [self getBoundingBox:mRect];
}

-(CLLocationCoordinate2D)getNECoordinate:(MKMapRect)mRect
{
    return [self getCoordinateFromMapRectanglePoint:MKMapRectGetMaxX(mRect) y:mRect.origin.y];
}

-(CLLocationCoordinate2D)getNWCoordinate:(MKMapRect)mRect
{
    return [self getCoordinateFromMapRectanglePoint:MKMapRectGetMinX(mRect) y:mRect.origin.y];
}

-(CLLocationCoordinate2D)getSECoordinate:(MKMapRect)mRect
{
    return [self getCoordinateFromMapRectanglePoint:MKMapRectGetMaxX(mRect) y:MKMapRectGetMaxY(mRect)];
}

-(CLLocationCoordinate2D)getSWCoordinate:(MKMapRect)mRect
{
    return [self getCoordinateFromMapRectanglePoint:mRect.origin.x y:MKMapRectGetMaxY(mRect)];
}

-(CLLocationCoordinate2D)getCoordinateFromMapRectanglePoint:(double)x y:(double)y{
    MKMapPoint swMapPoint = MKMapPointMake(x, y);
    return MKCoordinateForMapPoint(swMapPoint);
}

-(void)getBoundingBox:(MKMapRect)mRect
{
    CLLocationCoordinate2D bottomLeft = [self getSWCoordinate:mRect];
    CLLocationCoordinate2D topRight = [self getNECoordinate:mRect];
    self.SWBoundsLatitude = bottomLeft.latitude;
    self.SWBoundsLongitude = bottomLeft.longitude;
    self.NEBoundsLatitude = topRight.latitude;
    self.NEBoundsLongitude  = topRight.longitude;
}

#pragma mark - Set style method

-(void)setStyle
{
    //Segmented control.
    self.toggleControlOutlet.backgroundColor = [UIColor whiteColor];

    //Redraw button.
    [self.redrawAreaButtonOutlet setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.redrawAreaButtonOutlet.layer.borderWidth = 1.0f;
    self.redrawAreaButtonOutlet.layer.borderColor = [[UIColor clearColor] CGColor];
    self.redrawAreaButtonOutlet.backgroundColor = [UIColor blackColor];

    //Tableview
    self.tableView.backgroundColor = [UIColor clearColor];


    self.view.backgroundColor = [UIColor clearColor];


    self.activityIndicatorOutlet.color = [UIColor backgroundColor];
    [self.rateBarButton setTitleColor:[UIColor buttonColor] forState:UIControlStateHighlighted];
    [self.rateBarButton setTitleColor:[UIColor buttonColor] forState:UIControlStateNormal];
    [self.rateBarButton setTitleColor:[UIColor buttonColor] forState:UIControlStateSelected];
    self.rateBarButton.backgroundColor = [UIColor clearColor];
    self.rateBarButton.layer.cornerRadius = 5.0f;
    self.rateBarButton.layer.masksToBounds = YES;
    self.rateBarButton.layer.borderWidth = 2.0f;
    self.rateBarButton.layer.borderColor= [[UIColor buttonColor]CGColor];
    [self.tabBarController.tabBar setTintColor:[UIColor whiteColor]];
    [self.cancelButtonOutlet setTitleColor:[UIColor buttonColor] forState:UIControlStateNormal];
    self.cancelButtonOutlet.layer.borderWidth = 2.0f;
    self.cancelButtonOutlet.layer.borderColor = [[UIColor buttonColor] CGColor];
    self.cancelButtonOutlet.layer.cornerRadius = 5.0f;

    self.searchBackGroundView.alpha = 0.0f;
//    self.currentLocationButtonOutlet.backgroundColor = [UIColor whiteColor];
    self.currentLocationButtonOutlet.layer.borderWidth = 2.0f;
    self.currentLocationButtonOutlet.layer.cornerRadius = 5.0f;
    self.currentLocationButtonOutlet.layer.borderColor = [[UIColor blackColor] CGColor];

}

#pragma mark - other methods

//Gets called once, when viewcontroller loads and map/table has loaded.
-(void)checkIfBeaconMonitoringIsAvailable
{
    self.didCheckForBeaconMonitoring = YES;

    if (![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"iBeacon ranging not available on this device" message:@"iBeacon ranging available on iOS 5 or later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}



@end
