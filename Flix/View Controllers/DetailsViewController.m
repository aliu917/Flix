//
//  DetailsViewController.m
//  Flix
//
//  Created by aliu18 on 6/26/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "TrailerViewController.h"

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backdropView;
@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSURL *posterURL = [self getPictureURL: @"poster_path"];
    [self.posterView setImageWithURL: posterURL];
    NSURL *backdropURL = [self getPictureURL: @"backdrop_path"];
    [self.backdropView setImageWithURL: backdropURL];
    
    self.titleLabel.text = self.movie[@"title"];
    self.synopsisLabel.text = self.movie[@"overview"];
    
    [self.titleLabel sizeToFit];
    [self.synopsisLabel sizeToFit];

}

-(NSURL *)getPictureURL: (NSString *) string {
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *pictureURLString = self.movie[string];
    NSString *fullPictureURLString = [baseURLString stringByAppendingString: pictureURLString];
    NSURL *pictureURL = [NSURL URLWithString:fullPictureURLString];
    return pictureURL;
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSDictionary *movie = self.movie;
    TrailerViewController *trailerViewController = [segue destinationViewController];
    trailerViewController.movie = movie;
    
    NSLog(@"Tapping on a movie!");
}


@end
