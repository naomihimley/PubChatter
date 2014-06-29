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
@property (weak, nonatomic) IBOutlet UIButton *currentLocationButtonOutlet;
@property (weak, nonatomic) IBOutlet UISegmentedControl *toggleControlOutlet;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *redrawAreaButtonOutlet;
@property CGFloat span;
@property CGFloat SWBoundsLatitude;
@property CGFloat SWBoundsLongitude;
@property CGFloat NEBoundsLatitude;
@property CGFloat NEBoundsLongitude;
@property MKCoordinateSpan mapSpan;
@property AppDelegate *appDelegate;
@property NSInteger counter;
@property BOOL searchActivated;
@property BOOL didCheckForBeaconMonitoring;
@property BOOL initialMapLoad;
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

    // Do set up work, set querystring, mapspan, and begin looking for user location.
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
            NSLog(@"setting map region");
            self.mapView.delegate = self;
            self.mapView.showsUserLocation = YES;
            self.currentLocationButtonOutlet.enabled = YES;
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


#pragma mark - IBActions

// Removes all annotations from mapView, creates a new map region from the current mapView region, which is used to make another call to Yelp API. Disables button until results are returned.
- (IBAction)onRedrawRegionButtonPressed:(id)sender
{
    self.redrawAreaButtonOutlet.enabled = NO;
    [self.mapView removeAnnotations:self.mapView.annotations];

    // Get's the SW and NE coordinates of the current mapView, which are used in setting the boundary box parameters of the Yelp API call.
    [self getMapRect];

    // Call method to get JSON with boundary box parameters, "bar" search term, 20 results
    [self getYelpJSONFromMapRedraw:@"bar" andSWLatitude:self.SWBoundsLatitude andSWLongitude:self.SWBoundsLongitude andNELatitude:self.NEBoundsLatitude andNELongitude:self.NEBoundsLongitude andSortType:@"1" andNumResults:@"20"];
}

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

// Gets JSON data from Yelp and sets YelpBar custom class properties.
-(void)getYelpJSONWithSearch:(NSString *)query andLongitude:(CGFloat)longitude andLatitude:(CGFloat)latitude andSortType:(NSString*)sortType andNumResults:(NSString *)numResults
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
                if (yelpBar.businessImageURL) {
                    [tempArray addObject:yelpBar.businessImageURL];
                }

                // If bar does not have a businessImageURL, use the placeholder image.
                else {
                    NSURL *placeholderURL = [[NSBundle mainBundle] URLForResource:@"placeholder" withExtension:@"png"];
                    NSString *placeholderURLString = [NSString stringWithContentsOfURL:placeholderURL encoding:NSASCIIStringEncoding error:nil];
                    NSLog(@"%@", placeholderURLString);
                    [tempArray addObject:placeholderURLString];
                }
            }
            self.arrImagesUrl = [NSArray arrayWithArray:tempArray];
            [self getBarLatandLong:self.barLocations];
        }
    }];
}

-(void)getYelpJSONFromMapRedraw:(NSString *)query andSWLatitude:(CGFloat)swlatitude andSWLongitude:(CGFloat)swlongitude andNELatitude:(CGFloat)nelatitude andNELongitude:(CGFloat)nelongitude andSortType:(NSString*)sortType andNumResults:(NSString *)numResults
{
    //    NSLog(@"%@", sortType);
    id rq = [TDOAuth URLRequestForPath:@"/v2/search" GETParameters:@{@"term": query, @"bounds": [NSString stringWithFormat:@"%f,%f|%f,%f", swlatitude, swlongitude, nelatitude, nelongitude], @"limit" : numResults, @"sort" : sortType}
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
            self.barLocations = [NSArray arrayWithArray:arrayOfYelpBarObjects];

            // Check if bar locations array is empty, if so, present alert to user that no results were found.
            if (self.barLocations.count == 0) {
                NSLog(@"No results found for this area");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No results found in this area" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                self.redrawAreaButtonOutlet.enabled = YES;
            }

            else {
            // Create array of business image URL for lazy loading in tableView.
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            for (YelpBar *yelpBar in self.barLocations) {
                if (yelpBar.businessImageURL) {
                    [tempArray addObject:yelpBar.businessImageURL];
                }
                // If bar does not have a businessImageURL, use the placeholder image.
                else {
                    NSURL *placeholderURL = [[NSBundle mainBundle] URLForResource:@"placeholder" withExtension:@"png"];
                    NSString *placeholderURLString = [NSString stringWithContentsOfURL:placeholderURL encoding:NSASCIIStringEncoding error:nil];
                    NSLog(@"%@", placeholderURLString);
                    [tempArray addObject:placeholderURLString];
                    }
                }
            self.arrImagesUrl = [NSArray arrayWithArray:tempArray];
            [self getBarLatandLong:self.barLocations];
            }
        }
    }];
}

-(void)getBarLatandLong:(NSArray *)yelpBars
{
    NSLog(@"Number of YelpBar's returned: %lu", (unsigned long)yelpBars.count);

    // Check if search results were found, if not, display the alert.
    if (self.barLocations.count == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"No results found matching %@", self.queryString] message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        NSLog(@"No search results");
    }
    // Else, API call returned YelpBars.
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
                             // Address pulled from Yelp is bad and MapKit couldn't find a placemark, so attempt a natural language query based on YelpBar's name.
                             NSLog(@"Address from Yelp was bad");
                             [self performLanguageQuery];
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

                     for (CLPlacemark* placemark in placemarks)
                     {
                         yelpBar.latitude = placemark.location.coordinate.latitude;
                         yelpBar.longitude = placemark.location.coordinate.longitude;
                         yelpBar.distanceFromUser = [self.userLocation distanceFromLocation:placemark.location];
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
                        // Sort barLocations array by distance from user.
                         NSArray *array = [NSArray arrayWithArray:self.barLocations];
                         self.barLocations = nil;
                         NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"distanceFromUser" ascending:YES];
                         self.barLocations = [array sortedArrayUsingDescriptors:@[descriptor]];

                         //Reload tableview
                         [self.tableView reloadData];
                         self.redrawAreaButtonOutlet.enabled = YES;
                         if (!self.didCheckForBeaconMonitoring) {
                             [self checkIfBeaconMonitoringIsAvailable];
                         }
                         NSLog(@"Done");
                   }
            }];
        }
    }
}

-(void)performLanguageQuery
{
    NSLog(@"Performing natural language query");
    YelpBar *yelpBar = [self.barLocations firstObject];
    NSLog(@"YelpBar name: %@", yelpBar.name);
    // Double-check that A YelpBar has been returned from search.
    if (yelpBar) {
    // Perform natural lanuage query on YelpBar's name property.
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = yelpBar.name;
    request.region = MKCoordinateRegionMake(self.userLocation.coordinate, MKCoordinateSpanMake(.3, .3));
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        NSArray *mapItems = response.mapItems;

        // If there is a response from query, then set the lat/long properties of YelpBar and add the MKPointAnnotation to the map.
        if (mapItems.count > 0) {
        NSLog(@"Natural language query successful");
        MKMapItem *mapItem = [mapItems firstObject];
        yelpBar.latitude = mapItem.placemark.coordinate.latitude;
        yelpBar.longitude = mapItem.placemark.coordinate.longitude;

        MKPointAnnotation *barAnnotation = [[MKPointAnnotation alloc] init];
        barAnnotation.coordinate = CLLocationCoordinate2DMake(yelpBar.latitude, yelpBar.longitude);
        barAnnotation.title = yelpBar.name;
        barAnnotation.subtitle = [NSString stringWithFormat:@"%.02f miles", yelpBar.distanceFromUser * 0.000621371];
        [self.mapView addAnnotation:barAnnotation];

        self.mapSpan = MKCoordinateSpanMake(0.015, 0.015);
        CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(yelpBar.latitude, yelpBar.longitude);
        MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, self.mapSpan);
        [self.mapView setRegion:region animated:YES];
        self.searchActivated = NO;
        }

        // Else, natural language query was unsuccessful. Tell user a location couldn't be found, but display the tableView, so they know they can see the bar details.
        else {
            NSLog(@"Natural language query unnsuccessful, no results");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Unable to find a location for %@", yelpBar.name] message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];

            // Since a YelpBar does exist, but MapKit can't find it's location, show the user the tableView, where the bar will be displayed.
            self.toggleControlOutlet.selectedSegmentIndex = 1;
            [self changeSegment:self.toggleControlOutlet.selectedSegmentIndex];
            self.searchActivated = NO;
            }
        }];
    }
}

-(void)checkIfBeaconMonitoringIsAvailable
{
    if (![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"iBeacon ranging not available on this device" message:@"iBeacon ranging available on iOS 5 or later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    }
    self.didCheckForBeaconMonitoring = YES;
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
    if (self.initialMapLoad) {
    NSLog(@"Map finished loading");
    [self getMapRect];
    [self getYelpJSONFromMapRedraw:@"bar" andSWLatitude:self.SWBoundsLatitude andSWLongitude:self.SWBoundsLongitude andNELatitude:self.NEBoundsLatitude andNELongitude:self.NEBoundsLongitude andSortType:@"0" andNumResults:@"20"];
        self.initialMapLoad = NO;
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
                      placeholderImage:[UIImage imageNamed:@"placeholder2"]];
    [cell layoutSubviews];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"I ran");
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

#pragma mark - Search bar delegate methods.
// Enables search on keyPad search button pressed.
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // Set search boolean.
    self.searchActivated  = YES;

    // Clear the map of previous annotations and set queryString from user input.
    [self.mapView removeAnnotations:self.mapView.annotations];
    self.queryString = self.searchBar.text;
    self.searchBar.text = nil;

    // Finds the single best result based on querystring input and user's current location.
    [self getYelpJSONWithSearch:self.queryString andLongitude:self.userLocation.coordinate.longitude andLatitude:self.userLocation.coordinate.latitude andSortType:@"0" andNumResults:@"1"];

    // Dismiss keyboard.
    [self.searchBar endEditing:YES];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    // Dismiss keyboard and remove searchbar text.
    self.searchBar.text = nil;
    [self.searchBar endEditing:YES];
}

#pragma  mark - Map coordinate methods

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

@end
