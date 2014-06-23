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
#import "SearchTableViewCell.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property CLLocationManager *locationManager;
@property CLLocation *userLocation;
@property NSString *userLocationString;
@property NSString *queryString;
@property NSArray *barLocations;
@property YelpBar *selectedBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *toggleControlOutlet;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *searchButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *redrawAreaButtonOutlet;
@property CGFloat span;
@property MKCoordinateSpan mapSpan;
@property AppDelegate *appDelegate;

@end

@implementation SearchViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.queryString = @"bar";
    self.mapSpan = MKCoordinateSpanMake(0.02, 0.02);
    self.toggleControlOutlet.selectedSegmentIndex = 0;
    self.mapView.hidden = NO;
    self.redrawAreaButtonOutlet.hidden = NO;
    self.redrawAreaButtonOutlet.layer.cornerRadius = 5.0f;
    self.tableView.hidden = YES;
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager startUpdatingLocation];
    self.locationManager.delegate = self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self isUserInBar];
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[self.appDelegate beaconRegionManager]canUserUseApp];
}

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

// Removes all annotations off mapView, sets querystring to searchbar text, creates a sufficiently large search area, and calls the findBarNear method. The search button is also disabled until a list of bars are returned to prevent bombarding with requests.
- (IBAction)onSearchButtonPressed:(id)sender
{

    [self.mapView removeAnnotations:self.mapView.annotations];
    self.queryString = self.searchBar.text;
    self.mapSpan = MKCoordinateSpanMake(0.15, 0.15);
    [self getYelpJSONWithSearch:self.queryString andLongitude:self.userLocation.coordinate.longitude andLatitude:self.userLocation.coordinate.latitude andSortType:@"0" andNumResults:@"1"];
    self.searchButtonOutlet.enabled = NO;
    [self.searchBar endEditing:YES];
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(self.userLocation.coordinate.latitude, self.userLocation.coordinate.longitude);
    MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, self.mapSpan);
    [self.mapView setRegion:region animated:YES];
}

// Removes all annotations off mapView, creates a new map region from the current mapView region, which is used to make another call to findBarNear. Disables button until results are returned.
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

- (IBAction)onToggleMapListViewPressed:(id)sender
{
    [self segmentChanged:sender];
}

// Finds user location and sets the userLocation property
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for (CLLocation *location in locations) {
        if (location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000) {
            [self.locationManager stopUpdatingLocation];
            self.userLocation = location;
//            [self getUserLocationString];
            CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(self.userLocation.coordinate.latitude, self.userLocation.coordinate.longitude);
            MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, self.mapSpan);
            [self.mapView setRegion:region animated:YES];
            [self getYelpJSONWithSearch:self.queryString andLongitude:self.userLocation.coordinate.longitude andLatitude:self.userLocation.coordinate.latitude andSortType:@"1" andNumResults:@"20"];
            break;
        }
    }
}

// Gets JSON data from Yelp
-(void)getYelpJSONWithSearch:(NSString *)query andLongitude:(CGFloat)longitude andLatitude:(CGFloat)latitude andSortType:(NSString*)sortType andNumResults:(NSString *)numResults;
{
//    NSLog(@"%@", sortType);
    id rq = [TDOAuth URLRequestForPath:@"/v2/search" GETParameters:@{@"term": query, @"ll": [NSString stringWithFormat:@"%f,%f", latitude, longitude], @"limit" : numResults, @"sort" : sortType}
                                  host:@"api.yelp.com"
                           consumerKey:@"LdaQSTTYqZuYXrta5vVAgw"
                        consumerSecret:@"k6KpVPXHSykD8aQXSXqdi7GboMY"
                           accessToken:@"PRBX3m8UH4Q2RmZ-HOTKmjFPLVzmz4UL"
                           tokenSecret:@"ao0diFl7jAe8cDDXnc-O1N-vQm8"];
    NSLog(@"%@", rq);

    [NSURLConnection sendAsynchronousRequest:rq queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

        NSLog(@"Got the data");

        NSDictionary *dictionary  = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&connectionError];

        NSMutableArray *arrayOfYelpBarObjects = [[NSMutableArray alloc] init];
        NSArray *yelpBars = [dictionary objectForKey:@"businesses"];

        for (NSDictionary *dictionary in yelpBars) {
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
            yelpBar.categories = [dictionary objectForKey:@"categories"];
            yelpBar.yelpID = [dictionary objectForKey:@"id"];
            [arrayOfYelpBarObjects addObject:yelpBar];
        }
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"distanceFromUser" ascending:YES];
        self.barLocations = [arrayOfYelpBarObjects sortedArrayUsingDescriptors:@[descriptor]];
        [self getBarLatandLong:self.barLocations];
    }];
}

-(void)getBarLatandLong:(NSArray *)yelpBars
{

    for (YelpBar *yelpBar in yelpBars) {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:yelpBar.address
                 completionHandler:^(NSArray* placemarks, NSError* error){
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
            [self.tableView reloadData];
            self.searchButtonOutlet.enabled = YES;
            self.redrawAreaButtonOutlet.enabled = YES;
        }];
    }
}

// Finds an address string from the user's current location.

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
    NSString *milesFromUser = [NSString stringWithFormat:@"%.02f miles", yelpBar.distanceFromUser * 0.000621371];

    cell.barNameLabel.text = yelpBar.name;
    cell.barDistanceLabel.text = milesFromUser;
    cell.barAddressLabel.text = yelpBar.address;
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




@end
