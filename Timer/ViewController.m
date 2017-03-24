//
//  ViewController.m
//  Timer
//
//  Created by Realank on 2017/3/23.
//  Copyright © 2017年 Realank. All rights reserved.
//

#import "ViewController.h"
#import "MZTimerLabel.h"
#import <AVFoundation/AVFoundation.h>
#import <sqlite3.h>
#import "PersistWords.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,AVAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UITableView *countTableView;
@property (strong, nonatomic) MZTimerLabel *myTimerLabel;

@property (strong,nonatomic) NSMutableArray* timeCountArrM;

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@end

#define CLASSINDEX 3
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _myTimerLabel = [[MZTimerLabel alloc] initWithLabel:_timerLabel andTimerType:MZTimerLabelTypeStopWatch];
    //    [timerExample3 setCountDownTime:30*60]; //** Or you can use [timer3 setCountDownToDate:aDate];
    _myTimerLabel.timeFormat = @"HH:mm:ss.SSS";
    _countTableView.delegate = self;
    _countTableView.dataSource = self;
    self.title = [self audioFileName];
    _progressView.progress = 0;
    CADisplayLink* link = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateProgress)];
    link.preferredFramesPerSecond = 30;
    [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

#pragma mark - timer control
- (IBAction)start:(id)sender {
    [_myTimerLabel start];
    _timeCountArrM = [NSMutableArray array];
    [_countTableView reloadData];
    [self musicPlayback];
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
    [_audioPlayer pause];
}
- (IBAction)reset:(id)sender {
    
    NSTimeInterval interval = [_myTimerLabel getTimeCounted];
    NSLog(@"%f",interval);
    [_timeCountArrM addObject:@(interval)];
    [_countTableView reloadData];
    [_countTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_timeCountArrM.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    [_audioPlayer stop];
    _audioPlayer = nil;
    [_myTimerLabel pause];
    [_myTimerLabel reset];
}

#pragma mark - table view

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


#pragma mark - audio playback

- (NSString*)audioFileName{
    return [NSString stringWithFormat:@"MW1%02d",CLASSINDEX];
}

- (AVAudioPlayer *)audioPlayer {
    if (!_audioPlayer) {
        NSString *urlStr=[[NSBundle mainBundle]pathForResource:[self audioFileName] ofType:@"mp3"];
        NSURL *url=[NSURL fileURLWithPath:urlStr];
        NSError *error=nil;
        if (!url) {
            NSLog(@"not found");
            return nil;
        }
        //初始化播放器，注意这里的Url参数只能时文件路径，不支持HTTP Url
        _audioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        //设置播放器属性
        _audioPlayer.numberOfLoops=0;//设置为0不循环
        _audioPlayer.delegate = self;
        [_audioPlayer prepareToPlay];//加载音频文件到缓存
        if(error){
            NSLog(@"初始化播放器过程发生错误,错误信息:%@",error.localizedDescription);
            return nil;
        }
    }
    
    return _audioPlayer;
}

- (void)updateProgress{
    if (!_audioPlayer) {
        _progressView.progress = 0;
    }else{
        NSTimeInterval postion = _audioPlayer.currentTime;
        NSTimeInterval duration = _audioPlayer.duration;
        _progressView.progress = postion/duration;
    }
}


- (void)musicPlayback {
    if (!self.audioPlayer.isPlaying) {
        [self.audioPlayer play];
    }
    
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"音乐播放完成...");
    [self reset:nil];
}


#pragma mark - sql
- (IBAction)saveSQL:(id)sender {
    
    if (_timeCountArrM.count > 1) {
        for (int i = 0; i < _timeCountArrM.count - 1; i++) {
            double startTime = [_timeCountArrM[i] doubleValue];
            double endTime = [_timeCountArrM[i + 1] doubleValue];
            double duration = endTime - startTime;
            NSString* wordID = [NSString stringWithFormat:@"W1%02d%03d",CLASSINDEX,i + 1];
            [PersistWords addWordWithStart:startTime period:duration wordid:wordID audioFileName:[self audioFileName]];
        }
        NSLog(@"\n%@",[PersistWords allWords]);
    }
}




@end
