//
//  ViewController.m
//  SpeechTest
//
//  Created by Zs on 2017/10/10.
//  Copyright © 2017年 Zs. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Speech/Speech.h>
#import <MediaPlayer/MediaPlayer.h>
/*资料贡献
 http://www.jianshu.com/p/9cd581e53256  AVSpeechUtterance类详解
 
 设置语音播报的模式 AVAudioSessionCategoryPlayback 开始 主要处理静音模式
 [[AVAudioSession sharedInstance]setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
 [[AVAudioSession sharedInstance]setActive:YES error:nil];
 
 使用代理 代理废弃 使用通知 http://www.jianshu.com/p/014aa679424b 处理通知  解决电话接入问题
 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
 
 AVSpeechSynthesizerDelegate 代理  处理音乐播放器问题 通知播报完成 继续播放音乐
 [[AVAudioSession sharedInstance] setActive:NO error:nil];
 
 */

@interface ViewController ()<AVAudioSessionDelegate,AVSpeechSynthesizerDelegate>


@property (nonatomic, strong)AVSpeechSynthesizer *synth;

@property (nonatomic, strong)MPVolumeView *volumeView;
@property (nonatomic, strong)UISlider *volumeSlider;
@property (nonatomic, strong)UISlider *showVolueSlider;
@property (nonatomic, assign) float volumeValue;

@property (nonatomic, assign) float volValue;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn =[UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:btn];
    btn.frame =CGRectMake(100, 200, 70, 40);
    [btn setTitle:@"测试" forState:UIControlStateNormal];
    btn.backgroundColor =[UIColor orangeColor];
    [btn addTarget:self action:sel_registerName("btnClick") forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)btnClick{
    [self controlVolume];

    //设置语音播报的模式 主要处理静音模式
    [[AVAudioSession sharedInstance]setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
    [[AVAudioSession sharedInstance]setActive:YES error:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    
    NSString *str =[NSString stringWithFormat:@"知君仙骨无寒暑。千载相逢犹旦暮"];
    
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:str];
    AVSpeechSynthesisVoice*voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];//设置发音，这是中文普通话
    utterance.voice = voice;
    
    _synth = [[AVSpeechSynthesizer alloc] init];
    _synth.delegate =self;
    
    [_synth speakUtterance:utterance];
}

-(void)controlVolume{
    _volumeView = [[MPVolumeView alloc]init];
    _volumeView.showsRouteButton = NO;
    //默认YES，这里为了突出，故意设置一遍
    _volumeView.showsVolumeSlider = YES;
    
    [_volumeView sizeToFit];
    [_volumeView setFrame:CGRectMake(-100, -100, 10, 10)];
    
    [_volumeView userActivity];
    
    for (UIView *view in [_volumeView subviews]){
        if ([[view.class description] isEqualToString:@"MPVolumeSlider"]){
            _volumeSlider = (UISlider*)view;
            
            break;
        }
    }
    //输出当前音量 保存 改变后再改回之前音量
    _volValue = [[AVAudioSession sharedInstance] outputVolume];
    
    //设置默认打开视频时声音为0.3，如果不设置的话，获取的当前声音始终是0
    [_volumeSlider setValue:1];
    
    //获取最是刚打开时的音量值
    _volumeValue = _volumeSlider.value;
    
    //设置展示音量条的值
    
    _showVolueSlider.value = _volumeValue;
    
}


- (void)handleInterruption:(NSNotification *)notificaiton{
    NSLog(@"%@",notificaiton.userInfo);
    AVAudioSessionInterruptionType type = [notificaiton.userInfo[AVAudioSessionInterruptionTypeKey] intValue];
    if (type == AVAudioSessionInterruptionTypeBegan) {//1是被系统占用 有电话进入
        //暂停播报,并保存进度
        [_synth pauseSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    } else {
        //恢复播报
        [_synth continueSpeaking];
    }
}

//播报结束后 关闭播报线程  继续播放音乐
- (void)speechSynthesizer:(AVSpeechSynthesizer*)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance*)utterance{
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    [_volumeSlider setValue:_volValue];//恢复之前音量
}

@end
