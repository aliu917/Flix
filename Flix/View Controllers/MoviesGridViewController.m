//
//  MoviesGridViewController.m
//  Flix
//
//  Created by aliu18 on 6/26/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "MoviesGridViewController.h"
#import "MovieCollectionCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"

@interface MoviesGridViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSArray *movies;
//@property (nonatomic, strong) NSDictionary *nameToMovies;
@property (nonatomic, strong) NSArray *filteredMovies;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation MoviesGridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.searchBar.delegate = self;
    [self fetchMovies];
    self.filteredMovies = self.movies;
    
    /*[searchController.searchBar sizeToFit];
    searchBarPlaceholder.addSubview(searchController.searchBar)
    automaticallyAdjustsScrollViewInsets = false;
    definesPresentationContext = true;*/
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;
    
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 5;
    CGFloat postersPerLine = 3;
    CGFloat itemWidth = (self.collectionView.frame.size.width - layout.minimumInteritemSpacing * (postersPerLine - 1)) / postersPerLine;
    CGFloat itemHeight = itemWidth * 1.5;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
}
/*
-(void)makeNameToMovieDict {
    NSMutableDictionary *nameToMovie = [[NSMutableDictionary alloc] init];
    for (NSDictionary *movie in self.movies) {
        NSString *movieTitle = movie[@"title"];
        [nameToMovie setObject:movie forKey:movieTitle];
    }
    self.nameToMovies = nameToMovie;
}
 */

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    //NSArray *titleNames = [self.nameToMovies allKeys];
    
    if (searchText.length != 0) {
        
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject[@"title"] containsString:searchText];
        }];
        self.filteredMovies = [self.movies filteredArrayUsingPredicate:predicate];
        
        NSLog(@"Filtering.");
        NSLog(@"%@", self.filteredMovies);
        /*NSString *substring [NSString stringWithString: searchText];
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"title contains]*/
    }
    else {
        self.filteredMovies = self.movies;
    }
    
    [self.collectionView reloadData];
    
}

- (void)fetchMovies {
    [self.activityIndicator startAnimating];
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            NSLog(@"%@", dataDictionary);
            // TODO: Get the array of movies
            NSArray *movies = dataDictionary[@"results"];
            self.movies = movies;
            // TODO: Store the movies in a property to use elsewhere
            // TODO: Reload your table view data
            [self.collectionView reloadData];
            [self.activityIndicator stopAnimating];
        }
    }];
    [task resume];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UICollectionViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell: tappedCell];
    NSDictionary *movie = self.filteredMovies[indexPath.row];
    DetailsViewController *detailsViewController = [segue destinationViewController];
    detailsViewController.movie = movie;
    
    NSLog(@"Tapping on a movie!");
}


- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MovieCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MovieCollectionCell" forIndexPath:indexPath];
    
    NSDictionary *movie = [[NSDictionary alloc] init];
    if (self.filteredMovies != nil) {
       movie = self.filteredMovies[indexPath.item];
    } else {
        movie = self.movies[indexPath.item];
    }
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = movie[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingString: posterURLString];
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:posterURL];

    cell.posterView.image = nil;
    
    [cell.posterView setImageWithURL:posterURL];
    
    [cell.posterView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *imageRequest, NSHTTPURLResponse *imageResponse, UIImage *image) {
        // imageResponse will be nil if the image is cached
        //if (imageResponse) {
        NSLog(@"Image was NOT cached, fade in image");
        cell.posterView.alpha = 0.0;
        cell.posterView.image = image;
                                            
        //Animate UIImageView back to alpha 1 over 0.3sec
        [UIView animateWithDuration:1.0 animations:^{
            cell.posterView.alpha = 1.0;
        }];

    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse * response, NSError *error) {
                                        // do something for the failure condition
    }];
    
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.filteredMovies != nil) {
        return self.filteredMovies.count;
    } else {
        return self.movies.count;
    }
}

@end
