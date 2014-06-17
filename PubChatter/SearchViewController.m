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
#import "Bar.h"
#import "YelpBar.h"
#import "YelpRequest.h"
#import "SearchTableViewCell.h"

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property CLLocationManager *locationManager;
@property CLLocation *userLocation;
@property NSString *userLocationString;
@property NSString *queryString;
@property NSArray *barLocations;
@property Bar *selectedBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *toggleControlOutlet;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *searchButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *redrawAreaButtonOutlet;
@property CGFloat span;
@property MKCoordinateSpan mapSpan;

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
    self.navigationItem.title = @"PubChatter";
}

#pragma mark - IBActions

// Removes all annotations off mapView, sets querystring to searchbar text, creates a sufficiently large search area, and calls the findBarNear method. The search button is also disabled until a list of bars are returned to prevent bombarding with requests.
- (IBAction)onSearchButtonPressed:(id)sender
{

    [self.mapView removeAnnotations:self.mapView.annotations];
    self.queryString = self.searchBar.text;
    self.mapSpan = MKCoordinateSpanMake(0.15, 0.15);
    [self findBarNear:self.userLocation inSpan:self.mapSpan];
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
    CLLocation *centerLocation = [[CLLocation alloc] initWithLatitude:self.mapView.centerCoordinate.latitude longitude:self.mapView.centerCoordinate.longitude];
    self.mapSpan = self.mapView.region.span;
    MKCoordinateRegion region = MKCoordinateRegionMake(centerLocation.coordinate, self.mapSpan);
    [self.mapView setRegion:region animated:YES];
    [self findBarNear:centerLocation inSpan:self.mapSpan];
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
            [self getUserLocationString];
            CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(self.userLocation.coordinate.latitude, self.userLocation.coordinate.longitude);
            MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, self.mapSpan);
            [self.mapView setRegion:region animated:YES];
            [self findBarNear:self.userLocation inSpan:self.mapSpan];

            YelpRequest *request = [[YelpRequest alloc] init];
            [request getYelpJSONWithSearch:self.queryString andLongitude:self.userLocation.coordinate.longitude andLatitude:self.userLocation.coordinate.latitude];

            break;
        }
    }
}

-(void)findBarNear:(CLLocation *)location inSpan:(MKCoordinateSpan)mapSpan
{
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = self.queryString;
    request.region = MKCoordinateRegionMake(location.coordinate, mapSpan);
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {

        NSMutableArray *arrayOfBarLocationMapItems = [[NSMutableArray alloc]init];

        for (MKMapItem *barMapItem in response.mapItems) {
            Bar *bar = [[Bar alloc] init];
            bar.distanceFromUser = [self.userLocation distanceFromLocation:barMapItem.placemark.location];
            bar.name = barMapItem.name;
            if ([barMapItem.phoneNumber hasPrefix:@"+"]) {
                bar.telephone = [barMapItem.phoneNumber substringFromIndex:1];
            }
            bar.address = ABCreateStringWithAddressDictionary(barMapItem.placemark.addressDictionary, NO);
            bar.latitude = barMapItem.placemark.location.coordinate.latitude;
            bar.longitude = barMapItem.placemark.location.coordinate.longitude;
            bar.businessURL = barMapItem.url;
            [arrayOfBarLocationMapItems addObject:bar];

            CLLocation *barLocation = [[CLLocation alloc] initWithLatitude:bar.latitude longitude:bar.longitude];
            MKPointAnnotation *barAnnotation = [[MKPointAnnotation alloc] init];
            barAnnotation.coordinate = barLocation.coordinate;
            barAnnotation.title = bar.name;
            barAnnotation.subtitle = [NSString stringWithFormat:@"%.02f miles", bar.distanceFromUser * 0.000621371];
            [self.mapView addAnnotation:barAnnotation];
                }
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"distanceFromUser" ascending:YES];
        self.barLocations = [arrayOfBarLocationMapItems sortedArrayUsingDescriptors:@[descriptor]];
        [self.tableView reloadData];
        self.searchButtonOutlet.enabled = YES;
        self.redrawAreaButtonOutlet.enabled = YES;
    }];
}

// Gets JSON data from Yelp
//-(void)getYelpData
//{
//    NSString *urlString = @"";
//    NSURL *url = [NSURL URLWithString:urlString];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//
//    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
//     {
//         NSDictionary *dictionary  = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&connectionError];
//
//         NSArray *yelpBars = [dictionary objectForKey:@"businesses"];
//         NSMutableArray *arrayOfYelpBarItems = [NSMutableArray new];
//
//         for (NSDictionary *dictionary in yelpBars) {
//             YelpBar *yelpBar = [[YelpBar alloc] init];
//             yelpBar.distanceFromUser =
//             yelpBar.name =
//             yelpBar.address =
//             yelpBar.latitude =
//             yelpBar.longitude =
//             yelpBar.businessImageURL =
//             yelpBar.businessRatingImageURL =
//             yelpBar.isClosed =
//             [arrayOfYelpBarItems addObject:yelpBar];
//
//             CLLocation *yelpBarLocation = [[CLLocation alloc] initWithLatitude:yelpBar.latitude longitude:yelpBar.longitude];
//             MKPointAnnotation *yelpBarAnnotation = [[MKPointAnnotation alloc] init];
//             yelpBarAnnotation.coordinate = yelpBarLocation.coordinate;
//             yelpBarAnnotation.title = yelpBar.name;
//             yelpBarAnnotation.subtitle = [NSString stringWithFormat:@"%.02f miles", yelpBar.distanceFromUser * 0.000621371];
//             [self.mapView addAnnotation:yelpBarAnnotation];
//         }
//         NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"distanceFromUser" ascending:YES];
//         self.barLocations = [arrayOfYelpBarItems sortedArrayUsingDescriptors:@[descriptor]];
//         [self.tableView reloadData];
//         self.searchButtonOutlet.enabled = YES;
//         self.redrawAreaButtonOutlet.enabled = YES;
//    }];
//}

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
    for (Bar *bar in self.barLocations)
    {
        if ([view.annotation.title isEqualToString:bar.name]) {
            self.selectedBar = bar;
        }
    }
}

- (void)getUserLocationString
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];

    [geocoder reverseGeocodeLocation:self.userLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        for (CLPlacemark *placemark in placemarks) {
            self.userLocationString = ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
        }
    }];
}

#pragma mark - Tableview methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.barLocations.count;
}

-(SearchTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Bar *bar = [self.barLocations objectAtIndex:indexPath.row];
    SearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSString *milesFromUser = [NSString stringWithFormat:@"%.02f miles", bar.distanceFromUser * 0.000621371];

    cell.barNameLabel.text = bar.name;
    cell.barDistanceLabel.text = milesFromUser;
    cell.barAddressLabel.text = bar.address;
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

#pragma mark - OAuth methods

//-(void)getRequestToken
//{
//    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//    [dict setObject:CALL_BACK_URL forKey:@"oauth_callback"];
//
//    //init request
//    NSURLRequest *rq = [TDOAuth URLRequestForPath:@"/request_token" GETParameters:dict scheme:@"https" host:@"oauth.withings.com/account" consumerKey:WITHINGS_OAUTH_KEY consumerSecret:WITHINGS_OAUTH_SECRET accessToken:nil tokenSecret:nil];
//
//    //fire request
//    NSURLResponse* response;
//    NSError* error = nil;
//    NSData* result = [NSURLConnection sendSynchronousRequest:rq  returningResponse:&response error:&error];
//    NSString *s = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
//    //parse result
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    NSArray *split = [s componentsSeparatedByString:@"&"];
//    for (NSString *str in split){
//        NSArray *split2 = [str componentsSeparatedByString:@"="];
//        [params setObject:split2[1] forKey:split2[0]];
//    }
//
//    token = params[@"oauth_token"];
//    tokenSecret = params[@"oauth_token_secret"];
//}

@end
