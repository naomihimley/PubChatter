//
//  SearchViewController.m
//  PubChatter
//
//  Created by David Warner on 6/13/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import "SearchViewController.h"
#import <AddressBookUI/AddressBookUI.h>
#import "TDOAuth.h"
#import "Bar.h"


@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property CLLocationManager *locationManager;
@property CLLocation *userLocation;
@property NSString *userLocationString;
@property NSArray *barLocations;

@end

@implementation SearchViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager startUpdatingLocation];
    self.locationManager.delegate = self;
    self.navigationItem.title = @"PubChatter";
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
            MKCoordinateSpan span = MKCoordinateSpanMake(.02, .02);
            MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, span);
            [self.mapView setRegion:region animated:YES];
            [self findBarNear:self.userLocation];

//            [self getJSON];
            break;
        }
    }
}

-(void)findBarNear:(CLLocation *)location
{
    NSLog(@"FindBarNear ran");
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = @"bar";
    request.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(.02, .02));
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {

        NSMutableArray *arrayOfBarLocationMapItems = [[NSMutableArray alloc]init];

        for (MKMapItem *barMapItem in response.mapItems) {
            Bar *bar = [[Bar alloc] init];
            bar.distanceFromUser = [self.userLocation distanceFromLocation:barMapItem.placemark.location];
            bar.name = barMapItem.name;
            bar.address = ABCreateStringWithAddressDictionary(barMapItem.placemark.addressDictionary, NO);
            bar.latitude = barMapItem.placemark.location.coordinate.latitude;
            bar.longitude = barMapItem.placemark.location.coordinate.longitude;
            [arrayOfBarLocationMapItems addObject:bar];
            NSLog(@"%lu", (unsigned long)arrayOfBarLocationMapItems.count);

            CLLocation *barLocation = [[CLLocation alloc] initWithLatitude:bar.latitude longitude:bar.longitude];
            self.barAnnotation = [[MKPointAnnotation alloc] init];
            self.barAnnotation.coordinate = barLocation.coordinate;
            self.barAnnotation.title = bar.name;
            self.barAnnotation.subtitle = [NSString stringWithFormat:@"%.02f miles", bar.distanceFromUser * 0.000621371];
            [self.mapView addAnnotation:self.barAnnotation];
                }
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"distanceFromUser" ascending:YES];
        self.barLocations = [arrayOfBarLocationMapItems sortedArrayUsingDescriptors:@[descriptor]];
        [self.tableView reloadData];
    }];
}

// Gets JSON data from Yelp
//-(void)getJSON
//{
//    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
//    NSString *urlString = @"http://www.divvybikes.com/stations/json";
//    NSURL *url = [NSURL URLWithString:urlString];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//
//    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
//     {
//         NSDictionary *dictionary  = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&connectionError];
//
//         NSArray *stationsArray = [dictionary objectForKey:@"stationBeanList"];
//
//         for (NSDictionary *dictionary in stationsArray) {
//
//             DivvyStation *divvyStation = [[DivvyStation alloc] init];
//         }
//    }];
//}

// Finds an address string from the user's current location.
- (void)getUserLocationString
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];

    [geocoder reverseGeocodeLocation:self.userLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        for (CLPlacemark *placemark in placemarks) {
            self.userLocationString = ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
            NSLog(@"%@", self.userLocationString);
        }
    }];
}

#pragma mark - Tableview methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.barLocations.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Bar *bar = [self.barLocations objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSString *milesFromUser = [NSString stringWithFormat:@"%.02f miles", bar.distanceFromUser * 0.000621371];

    cell.textLabel.text = bar.name;
    cell.detailTextLabel.text = milesFromUser;
    return cell;
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
