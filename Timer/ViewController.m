//
//  ViewController.m
//  Timer
//
//  Created by Realank on 2017/3/23.
//  Copyright © 2017年 Realank. All rights reserved.
//

#import "ViewController.h"
#import "MZTimerLabel.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UITableView *countTableView;
@property (strong, nonatomic) MZTimerLabel *myTimerLabel;

@property (strong,nonatomic) NSMutableArray* timeCountArrM;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _myTimerLabel = [[MZTimerLabel alloc] initWithLabel:_timerLabel andTimerType:MZTimerLabelTypeStopWatch];
    //    [timerExample3 setCountDownTime:30*60]; //** Or you can use [timer3 setCountDownToDate:aDate];
    _myTimerLabel.timeFormat = @"HH:mm:ss.SSS";
    _countTableView.delegate = self;
    _countTableView.dataSource = self;
}

- (IBAction)start:(id)sender {
    [_myTimerLabel start];
    _timeCountArrM = [NSMutableArray array];
    [_countTableView reloadData];
}

- (IBAction)count:(id)sender {
    if (![_myTimerLabel isRuning]) {
        return;
    }
    NSTimeInterval interval = [_myTimerLabel getTimeCounted];
    NSLog(@"%f",interval);
    [_timeCountArrM addObject:@(interval)];
    [_countTableView reloadData];
    [_countTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_timeCountArrM.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}
- (IBAction)stop:(id)sender {
    [_myTimerLabel pause];
}
- (IBAction)reset:(id)sender {
    [_myTimerLabel pause];
    [_myTimerLabel reset];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",_timeCountArrM[indexPath.row]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",indexPath.row + 1];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _timeCountArrM.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
@end
