//
//  CharactersViewController.m
//  RPGExample
//
//  Created by Robin Chou on 3/19/13.
//  Copyright (c) 2013 Robin Chou. All rights reserved.
//

#import "CharactersViewController.h"
#import "DetailViewController.h"
#import <RPG/RPG.h>

@interface CharactersViewController ()
{
    UIRefreshControl *_refreshControl;
    NSArray *_characters;
}
@end

@implementation CharactersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(loadCharacters) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadCharacters];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _characters.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Character *character = [_characters objectAtIndex:indexPath.row];
    [cell.textLabel setText:character.name];
    [cell.detailTextLabel setText:character.characterClass];
    // Configure the cell...
    
    return cell;
}

#pragma mark - Custom Methods

-(void)loadCharacters
{
    [[RPG sharedClient] getCharacters:^(NSArray *characters, NSError *error) {
        _characters = characters;
        [self.tableView reloadData];
        [_refreshControl endRefreshing];
    }];
}

- (IBAction)addCharacter:(id)sender {    
    [[RPG sharedClient] postCharacter:nil completion:^(Character *character, NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
        } else {
            [self loadCharacters];
        }
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"pushDetailViewController"]) {
        Character *ch = [_characters objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        DetailViewController *vc = segue.destinationViewController;
        [vc setCharacter:ch];
    }
}
@end
