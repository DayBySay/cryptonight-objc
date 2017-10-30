//
//  ViewController.m
//  CryptoNight
//
//  Created by 清 貴幸 on 2017/10/20.
//  Copyright © 2017年 VOYAGE GROUP, Inc. All rights reserved.
//

#import "ViewController.h"
#include "hash-ops.h"
#import <mach/mach.h>
#import <assert.h>


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *threadLabel;
@property (weak, nonatomic) IBOutlet UILabel *cpuusageLabel;

@property (nonatomic) NSInteger count;
@property (nonatomic) NSInteger threadNum;
@property (weak, nonatomic) IBOutlet UILabel *hashRateLabel;

@property (nonatomic) BOOL start;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [[NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        _hashRateLabel.text = [NSString stringWithFormat:@"%ld / s", _count];
        _count = 0;
        _cpuusageLabel.text = [NSString stringWithFormat:@"%.2f\%%", cpu_usage()];
    }] fire];
    
    self.start = YES;
}
- (IBAction)didTouchUpThreadButton:(id)sender {
    [self doMining];
}

- (void)setCount:(NSInteger)count {
    dispatch_async(dispatch_get_main_queue(), ^{
        _count += count;
    });
}

- (void)doMining {
    self.threadNum += 1;
    self.threadLabel.text = [NSString stringWithFormat:@"%ld", self.threadNum];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        NSData *inputData = [@"This is a test" dataUsingEncoding:NSUTF8StringEncoding];
        size_t len = [inputData length];
        Byte *inputByte = (Byte*)malloc(len);
        memcpy(inputByte, [inputData bytes], len);
        
        char inputChar[len];
        for (int i = 0; i < len; i++) {
            inputChar[i] = (char)inputByte[i];
        }
        
        char h[32];
        
        
        int count = 100;
        NSDate *now = [NSDate date];
        while (self.start) {
            cn_slow_hash(&inputChar, len, &h[0]);
            [self setCount:1];
        }
        
        //        NSDate *past = [NSDate date];
        //        NSLog(@"ハッシュ回数 %d, 経過時間 %f sec", count, [now timeIntervalSinceDate:past]);
        //
        //        for (int i = 0; i < sizeof(h); i++) {
        //            printf("%02x", (unsigned char)h[i]);
        //        }
    });

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

float cpu_usage()
{
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0; // Mach threads
    
    basic_info = (task_basic_info_t)tinfo;
    
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    if (thread_count > 0)
        stat_thread += thread_count;
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < (int)thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->user_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
        
    } // for each thread
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return tot_cpu;
}

@end
