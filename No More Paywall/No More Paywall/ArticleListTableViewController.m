//
//  ArticleListTableViewController.m
//  
//
//  Created by Matthias Vermeulen on 5/01/17.
//
//

#define RGB(r, g, b) [UIColor colorWithRed:(float)r / 255.0 green:(float)g / 255.0 blue:(float)b / 255.0 alpha:1.0]


#import "ArticleListTableViewController.h"
#import "urlSharingFramework.h"
#import "tutorialViewController.h"
#import "UIScrollView+EmptyDataSet.h"
#import "ArticleTableViewCell.h"
#import <Google/Analytics.h>

@interface ArticleListTableViewController  () <KINWebBrowserDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate  >
{
    NSMutableArray *articleListArray;
    UrlShare *urlManager;
    NSArray *filteredLinks;
    Bookmark *urlStr;

}
@property (nonatomic, strong) UISearchController *searchController;

@property BOOL searchControllerWasActive;
@property BOOL searchControllerSearchFieldWasFirstResponder;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *deleteButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *searchButton;


@end

@implementation ArticleListTableViewController

- (void)viewDidLoad
{
       [super viewDidLoad];
    

    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:@"articleListView"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];

    
    //  searchController
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    _searchController.searchResultsUpdater = self;
    _searchController.searchBar.delegate = self;
    _searchController.dimsBackgroundDuringPresentation = false;
    _searchController.definesPresentationContext = true;
    _searchController.searchBar.scopeButtonTitles = @[@"All", @"Website", @"Title"];
    [_searchController.searchBar setTintColor:[UIColor whiteColor] ];
    [_searchController.searchBar setBarTintColor:RGB(243, 150, 66)];
  
    self.definesPresentationContext = YES;
   
    //design
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; //no empty cells
    self.tableView.separatorColor = RGB(243, 150, 66);
    [[UINavigationBar appearance] setTintColor:RGB(243, 150, 66) ];
    [[UINavigationBar appearance]  setTitleTextAttributes:@{NSForegroundColorAttributeName : RGB(243, 150, 66)}];
    
    
    //setup
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
    self.tableView.estimatedRowHeight = 130;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
   
 
    
    
    
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    
    urlManager = [UrlShare UrlShareManager];

    articleListArray = [[NSMutableArray alloc]init];
    articleListArray =  [[[[urlManager loadURLS]reverseObjectEnumerator] allObjects]mutableCopy];
[self tableReloading];
    
    NSLog(@"Array inhoud: %@", [urlManager loadURLS]);
    
    [self updateButtonsToMatchTableState];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    

    // restore the searchController's active state
    if (self.searchControllerWasActive) {
        self.searchController.active = self.searchControllerWasActive;
        _searchControllerWasActive = NO;
        
        if (self.searchControllerSearchFieldWasFirstResponder) {
            [self.searchController.searchBar becomeFirstResponder];
            _searchControllerSearchFieldWasFirstResponder = NO;
          
        }
    }
    
}


#pragma mark - Action methods

- (IBAction)editAction:(id)sender
{
    [self.tableView setEditing:YES animated:YES];
    [self updateButtonsToMatchTableState];
}

- (IBAction)cancelAction:(id)sender
{
    [self.tableView setEditing:NO animated:YES];
    [self updateButtonsToMatchTableState];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // The user tapped one of the OK/Cancel buttons.
    if (buttonIndex == 0)
    {
        // Delete what the user selected.
        NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
        BOOL deleteSpecificRows = selectedRows.count > 0;
        if (deleteSpecificRows)
        {
            // Build an NSIndexSet of all the objects to delete, so they can all be removed at once.
            NSMutableIndexSet *indicesOfItemsToDelete = [NSMutableIndexSet new];
            for (NSIndexPath *selectionIndex in selectedRows)
            {
                [indicesOfItemsToDelete addIndex:selectionIndex.row];
                
            }
            // Delete the objects from our data model.
           NSMutableArray *deleteArray = [[articleListArray objectsAtIndexes:indicesOfItemsToDelete]mutableCopy];
            
            [articleListArray removeObjectsAtIndexes:indicesOfItemsToDelete];

            [urlManager removeURL:deleteArray];

            
       [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];


        }
        else
        {
            // Delete everything, delete the objects from our data model.
            [urlManager removeURL:articleListArray];
            [articleListArray removeAllObjects];
            
            
            // Tell the tableView that we deleted the objects.
            // Because we are deleting all the rows, just reload the current table section
            [self.tableView reloadData];
        }
        
        // Exit editing mode after the deletion.
        
        [self.tableView setEditing:NO animated:YES];
        [self updateButtonsToMatchTableState];
    }
    
  
}


- (void)tableReloading
{
    [self.tableView reloadData]; //Fist table reload
    [self.tableView setNeedsLayout];
    [self.tableView layoutIfNeeded];
    [self.tableView reloadData];
  
}
- (IBAction)deleteAction:(id)sender
{
    // Open a dialog with just an OK button.
    NSString *actionTitle;
    if (([[self.tableView indexPathsForSelectedRows] count] == 1)) {
        actionTitle = NSLocalizedString(@"Are you sure you want to remove this item?", @"");
    }
    else
    {
        actionTitle = NSLocalizedString(@"Are you sure you want to remove these items?", @"");
    }
    
    NSString *cancelTitle = NSLocalizedString(@"Cancel", @"Cancel title for item removal action");
    NSString *okTitle = NSLocalizedString(@"OK", @"OK title for item removal action");
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:actionTitle
                                                             delegate:self
                                                    cancelButtonTitle:cancelTitle
                                               destructiveButtonTitle:okTitle
                                                    otherButtonTitles:nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    
    // Show from our table view (pops up in the middle of the table).
    [actionSheet showInView:self.view];
}

#pragma mark - Updating button state

- (void)updateButtonsToMatchTableState
{
    if (self.tableView.editing)
    {
        // Show the option to cancel the edit.
        self.navigationItem.rightBarButtonItem = self.cancelButton;
        
        [self updateDeleteButtonTitle];
        
        // Show the delete button.
        self.navigationItem.leftBarButtonItem = self.deleteButton;
    }
    else
    {
        // Not in editing mode.
        // Show the edit button, but disable the edit button if there's nothing to edit.
        if (articleListArray.count > 0)
        {
            self.editButton.enabled = YES;
        }
        else
        {
            self.editButton.enabled = NO;
            [self.tableView reloadData];
        }
        self.navigationItem.rightBarButtonItem = self.editButton;
        self.navigationItem.leftBarButtonItem = self.searchButton;
    }

}

- (void)updateDeleteButtonTitle
{
    // Update the delete button's title, based on how many items are selected
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    
    BOOL allItemsAreSelected = selectedRows.count == articleListArray.count;
    BOOL noItemsAreSelected = selectedRows.count == 0;
    
    if (allItemsAreSelected || noItemsAreSelected)
    {
        self.deleteButton.title = NSLocalizedString(@"Delete All", @"");
    }
    else
    {
        NSString *titleFormatString =
        NSLocalizedString(@"Delete (%d)", @"Title for delete button with placeholder for number");
        self.deleteButton.title = [NSString stringWithFormat:titleFormatString, selectedRows.count];
    }
}

#pragma mark EmptyDataSetDelegate
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"emptystateLogo"];
}


- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"Reading List";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"Websites you save with the extension will appear here.";
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0f],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}



- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIColor whiteColor];
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    return YES;
}

- (BOOL)emptyDataSetShouldAllowTouch:(UIScrollView *)scrollView
{
    return YES;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView
{
    return YES;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    
   [searchBar resignFirstResponder];
   

}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
     CGRect searchFrame = CGRectMake(0, 0, 320, 0.0f);
    searchBar.frame = searchFrame;
    searchBar.hidden = true;
    
    [self.tableView setTableHeaderView:nil];

}

- (void)filterContentForSearchText:(NSString *)searchText scope:(NSInteger )scope
{
    NSArray *links = [articleListArray copy];
    NSCompoundPredicate *resultPredicate;
        if(scope == 0)
        {
             resultPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[ [NSPredicate predicateWithFormat:@" title contains[c] %@", searchText], [NSPredicate predicateWithFormat:@" urlString contains[c] %@", searchText]]];
      
        }
       else if (scope == 1)
        {
            resultPredicate = [NSCompoundPredicate orPredicateWithSubpredicates: @[[NSPredicate predicateWithFormat:@" urlString contains[c] %@", searchText]]];
            
        }
       else if (scope == 2)
        {
            resultPredicate = [NSCompoundPredicate orPredicateWithSubpredicates: @[[NSPredicate predicateWithFormat:@" title contains[c] %@", searchText]]];
            
        }
            
    

    filteredLinks = [links filteredArrayUsingPredicate:resultPredicate];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    NSString *searchString = searchController.searchBar.text;
    NSInteger scope = searchController.searchBar.selectedScopeButtonIndex;
    [self filterContentForSearchText:searchString scope:scope];
    [self tableReloading];
}

#pragma mark - UISearchControllerDelegate

/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)appDidBecomeActive:(NSNotification *)notification
{
   
    
    NSLog(@"App terug actief");
    
}

- (void)appWillEnterForeground:(NSNotification *)notification
{
    NSLog(@"Array inhoud: %@", [urlManager loadURLS]);
    articleListArray = [[[[urlManager loadURLS]reverseObjectEnumerator] allObjects]mutableCopy];
    
    NSRange range = NSMakeRange(0, [self numberOfSectionsInTableView:self.tableView]);
    NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
    [self updateButtonsToMatchTableState];
    [self tableReloading];
    NSLog(@"will enter foreground notification");
}

- (IBAction)searchButtonTapped:(UIBarButtonItem *)sender
{
    self.searchController.searchBar.hidden = false;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    // [self.view addSubview:self.searchController.searchBar];
    [self.searchController.searchBar becomeFirstResponder];
    [_searchController setActive:YES];
   

}

- (IBAction)refresh:(UIRefreshControl *)sender
{
   
    [urlManager loadURLS];
    articleListArray = [[[[urlManager loadURLS]reverseObjectEnumerator] allObjects]mutableCopy];
    [self tableReloading];
    [sender endRefreshing];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"Number of articles: %lu", (unsigned long)[articleListArray count]);
    
    if (_searchController.active && ![_searchController.searchBar.text isEqualToString:@""])
    {
        return [filteredLinks count];
    }

    return [articleListArray count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
 {
     
    ArticleTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"articles" forIndexPath:indexPath];
     Bookmark *urlString;
     if (_searchController.active && ![_searchController.searchBar.text isEqualToString:@""])
     {
        
        urlString = [filteredLinks  objectAtIndex:indexPath.row];
     }
     else
     {
        
         urlString = [articleListArray objectAtIndex:indexPath.row];
     }

     cell.preservesSuperviewLayoutMargins = false;
     cell.separatorInset = UIEdgeInsetsZero;
     cell.layoutMargins = UIEdgeInsetsZero;
     
    cell.titleLabel.text = urlString.title;
     cell.urlLabel.text = [[NSURL URLWithString:urlString.urlString] host];
     NSLog(@"Text & url: %@ %@",  cell.titleLabel.text ,cell.urlLabel.text  );
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateButtonsToMatchTableState];
    if(![self.tableView isEditing])
    {
    urlStr = [articleListArray objectAtIndex:indexPath.row];
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc]init];
    [config setWebsiteDataStore:[WKWebsiteDataStore nonPersistentDataStore]];
    KINWebBrowserViewController *webBrowser = [KINWebBrowserViewController webBrowserWithConfiguration:config];
    webBrowser.hidesBottomBarWhenPushed = YES;
       
    [webBrowser setTintColor:RGB(243, 150, 66) ];
 
        UIBarButtonItem * doneButton =  [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Checkmark"] style:UIBarButtonItemStylePlain target:self action:@selector( hasReadArticle ) ];
        
        
         webBrowser.navigationItem.rightBarButtonItem =  doneButton;
    [self.navigationController pushViewController:webBrowser animated:YES];
    [webBrowser loadURLString:urlStr.urlString];
    NSLog(@"url string: %@",[articleListArray objectAtIndex:indexPath.row]);
    }
    else
    {
        
    }
}

- (void)hasReadArticle
{
    NSMutableArray *arr = [NSMutableArray arrayWithObject:urlStr];
    [articleListArray removeObject:urlStr];
    [urlManager removeURL:arr];
    [UIView animateWithDuration:0 animations:^{
        [self.navigationController popViewControllerAnimated:true];

    } completion:^(BOOL finished)
     {
      
         [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
         
     }];
    
}






- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    
}



 #pragma mark KINWebBrowserDelegate
 
 - (void)webBrowser:(KINWebBrowserViewController *)webBrowser didFinishLoadingURL:(NSURL *)URL
 {
 NSLog(@"Site geladen");
 }




@end
