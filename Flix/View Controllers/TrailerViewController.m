//
//  TrailerViewController.m
//  Flix
//
//  Created by aliu18 on 6/28/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "TrailerViewController.h"
#import <WebKit/WebKit.h>

@interface TrailerViewController ()
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet WKWebView *webView;

@end

@implementation TrailerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *movieID = [self.movie[@"id"] stringValue];
    
    NSString *baseURLString = @"https://api.themoviedb.org/3/movie/";
    NSString *posterURLString = movieID;
    NSString *firstPartPosterURLString = [baseURLString stringByAppendingString: posterURLString];
    NSString *endURLString = @"/videos?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed&language=en-US";
    NSString *fullURLString = [firstPartPosterURLString stringByAppendingString: endURLString];
    NSURL *url = [NSURL URLWithString:fullURLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            /*UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cannot get movies" message:@"The internet connection appears to be offline." preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [self fetchMovies];
            }];
            [alert addAction:cancelAction];
            [self presentViewController:alert animated:YES completion:^{
                
            }];*/
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSString *baseURL = @"https://www.youtube.com/watch?v=";
            NSDictionary *firstTrailer = dataDictionary[@"results"][0];
            NSString *trailerKey = firstTrailer[@"key"];
            NSString *trailerURLString = [baseURL stringByAppendingString: trailerKey];
            NSURL *url = [NSURL URLWithString:trailerURLString];
            NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
            [self.webView loadRequest:request];

            
            // TODO: Store the movies in a property to use elsewhere
            // TODO: Reload your table view data
            //[self.tableView reloadData];
            //[self.activityIndicator stopAnimating];
            
        }
        //[self.refreshControl endRefreshing];
    }];
    
    [task resume];
}

- (IBAction)closeModalScreen:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
