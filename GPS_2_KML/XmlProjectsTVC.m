//
//  XmlProjectsTVC.m
//  GPS_2_KML
//
//  Created by philopian on 11/18/13.
//  Copyright (c) 2013 philopian. All rights reserved.
//

#define r 79.0/255.0
#define g 226.0/255.0
#define b 110.0/255.0
#define a 1.0


#import "XmlProjectsTVC.h"

@interface XmlProjectsTVC ()
@property (nonatomic) BOOL segueFromUIAlert;
@property (nonatomic, strong) NSString *projectNameCreatedFromUIAlert;
@end

@implementation XmlProjectsTVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Add edit button
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    // get a list of all the XML files in the user's dir
    self.listXmlProjectsInDocumentsDir = [[NSMutableArray alloc]initWithArray:[self listOfAllXmlFilesInUsersDirectory]];
    
    // set the segueFromUIAlert to NO
    self.segueFromUIAlert = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}






#pragma mark - List XML files in Documents

-(NSArray*)listOfAllXmlFilesInUsersDirectory
{
    NSMutableArray *listOfXmlFiles = [[NSMutableArray alloc]init];
    
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [dirPaths objectAtIndex:0];
    
    NSError * error;
    NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory
                                                                                     error:&error];
    
    [directoryContents enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop){
        if (  ([object rangeOfString:@".xml"].location != NSNotFound) && ([object isKindOfClass:[NSString class]])   ){
            NSLog(@"%@", object);
            NSString *fileNameWithoutDotXml = [object stringByDeletingPathExtension];
            [listOfXmlFiles addObject:fileNameWithoutDotXml];
        }                                      }
     ];
    
    
    NSLog(@"%lu", (unsigned long)[listOfXmlFiles count]);
    return listOfXmlFiles;
}



#pragma mark - Table View Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [self.listXmlProjectsInDocumentsDir count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"XmlProjectCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"XmlProjectCell"];
    }
    
    NSString *cellLabel = [_listXmlProjectsInDocumentsDir objectAtIndex:indexPath.row];
    cell.textLabel.text = cellLabel;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // perform segue
    [self performSegueWithIdentifier:@"segToProject" sender:self];
    
    // Deselect the row
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


// Editable Cells

-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}


- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath: (NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // XML Project to delete
        NSString *projectToDelete = [[NSString alloc]initWithString:[_listXmlProjectsInDocumentsDir
                                                                     objectAtIndex:indexPath.row]];
        
        // Delete the row from the data source
        [_listXmlProjectsInDocumentsDir removeObjectAtIndex:[indexPath row]];
        
        // Delete row using the cool literal version of [NSArray arrayWithObject:indexPath]
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [self deleteXmlFileFromDirectory:projectToDelete];
        
    }
    
}











#pragma mark - Actions


- (IBAction)btnAddNewProject:(id)sender
{
    [self alertViewCreateNewProject];
    
    NSLog(@"Plus tapped");
}



#pragma mark - Alert Views



-(void)alertViewCreateNewProject
{
    UIAlertView *createNewProjectAlert = [[UIAlertView alloc] initWithTitle:@"Create New Project"
                                                                    message:nil
                                                                   delegate:self
                                                          cancelButtonTitle:@"Cancel"
                                                          otherButtonTitles:@"OK",
                                          nil];
    createNewProjectAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    //......................................................
    createNewProjectAlert.tintColor = [UIColor colorWithRed:r green:g blue:b alpha:a];
    
    createNewProjectAlert.window.tintColor =[UIColor colorWithRed:r green:g blue:b alpha:a];
    createNewProjectAlert.window.viewForBaselineLayout.tintColor =[UIColor colorWithRed:r green:g blue:b alpha:a];
    
    //......................................................
    [createNewProjectAlert show];
    
}


-(void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    NSLog(@"....AlertView:%@",[alertView title]);
    
    if ([alertView.title isEqualToString:@"Create New Project"]) {
        if(buttonIndex == 0) {
            NSLog(@"user press Cancel");
        }
        else if(buttonIndex == 1) {
            NSLog(@"user press OK");
            NSString *userDefinedProjectName = [[NSString alloc] initWithString:[alertView textFieldAtIndex:0].text];
            
            if (![_listXmlProjectsInDocumentsDir containsObject:userDefinedProjectName]) {
                
                // project name doesn't already exist, create xmlTemplate with Project name
                [self saveXmlTemplated:userDefinedProjectName];
                
                // Add new project to listxmlProjectsInDocumentsDir
                [_listXmlProjectsInDocumentsDir addObject:[alertView textFieldAtIndex:0].text];
                
                // reload table
                [_tableView reloadData];
                
                // set projectNameCreatedFromUIAlert to the text inside the UIAlert
                [self setProjectNameCreatedFromUIAlert:[alertView textFieldAtIndex:0].text];
                
                // segue to mapview
                self.segueFromUIAlert = YES;
                [self performSegueWithIdentifier:@"segToProject" sender:self];
                
            } else {
                // Alert user that the project name already exist
                [self alertViewProjectAlreadyExits];
            }
        }
    }
}

-(void)alertViewProjectAlreadyExits
{
    UIAlertView *alertViewProjectExist = [[UIAlertView alloc]initWithTitle:@"Project Name Already Exist"
                                                                   message:@"Please choose a different name"
                                                                  delegate:self
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil];
    [alertViewProjectExist show];
}




#pragma mark - PrepareForeSegue

-(void)prepareForSegue:(UIStoryboardSegue *)segue
                sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segToProject"]) {
        
        MapProject *vc = segue.destinationViewController;
        NSIndexPath *selectedCell = [self.tableView indexPathForSelectedRow];
        
        
        if (_segueFromUIAlert == YES) {
            // user created project from UIAlert
            vc.projectName = self.projectNameCreatedFromUIAlert;
            vc.projectNameFilePath = [self filePathXmlOnDevice:self.projectNameCreatedFromUIAlert];;
            // set the BOOL back to NO
            self.segueFromUIAlert = NO;
            
        } else {
            // user selected projects from TableView
            vc.projectName = [self.listXmlProjectsInDocumentsDir objectAtIndex:selectedCell.row];
            vc.projectNameFilePath = [self filePathXmlOnDevice:vc.projectName];
        }
        
    }
}



#pragma mark - XML File management (create/delete)
- (NSString *)filePathXmlOnDevice:(NSString *)createProjectName
{
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [dirPaths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@.xml",createProjectName];
    //    NSString *fileName = [NSString stringWithFormat:@"%@.kml",createProjectName];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",documentDirectory,fileName];
    NSLog(@"filePath: %@",filePath);
    return filePath;
}
- (NSString *)filePathKmlOnDevice:(NSString *)createProjectName
{
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [dirPaths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@.kml",createProjectName];
    //    NSString *fileName = [NSString stringWithFormat:@"%@.kml",createProjectName];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",documentDirectory,fileName];
    NSLog(@"filePath: %@",filePath);
    return filePath;
}
- (void)saveXmlTemplated:(NSString*)createProjectName
{
    
    NSString *filePath = [self filePathXmlOnDevice:createProjectName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        
        
        NSString *xmlTemplated = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><Document></Document>"];
        NSData *xmlTemplatedData = [xmlTemplated dataUsingEncoding:NSUTF8StringEncoding];
        
        [xmlTemplatedData writeToFile:filePath atomically:YES];
    }
}


- (void)deleteXmlFileFromDirectory:(NSString*)ProjectName
{
    NSError *error = nil;
    
    NSString *filePathXml = [self filePathXmlOnDevice:ProjectName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePathXml]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePathXml error:&error];
    }
    NSLog(@"deleted (XML): %@",ProjectName);
    
    NSString *filePathKml = [self filePathKmlOnDevice:ProjectName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePathKml]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePathKml error:&error];
    }
    NSLog(@"deleted (KML): %@",ProjectName);
    
    [_tableView reloadData];
}



@end

