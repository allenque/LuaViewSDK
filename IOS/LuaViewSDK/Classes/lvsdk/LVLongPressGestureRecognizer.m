//
//  LVLongPressGestureRecognizer.m
//  LVSDK
//
//  Created by 城西 on 15/3/9.
//  Copyright (c) 2015年 dongxicheng. All rights reserved.
//

#import "LVLongPressGestureRecognizer.h"
#import "LVGestureRecognizer.h"
#import "LView.h"

@implementation LVLongPressGestureRecognizer


-(void) dealloc{
    LVLog(@"LVLongPressGestureRecognizer.dealloc");
    [LVGestureRecognizer releaseUD:_userData];
}

-(id) init:(lv_State*) l{
    self = [super initWithTarget:self action:@selector(handleGesture:)];
    if( self ){
        self.lv_lview = (__bridge LView *)(l->lView);
    }
    return self;
}

-(void) handleGesture:(LVLongPressGestureRecognizer*)sender {
    lv_State* l = self.lv_lview.l;
    if ( l ){
        lv_checkStack32(l);
        lv_pushUserdata(l,self.userData);
        [LVUtil call:l lightUserData:self key:"callback" nargs:1];
    }
}

static int lvNewGestureRecognizer (lv_State *L) {
    {
        LVLongPressGestureRecognizer* gesture = [[LVLongPressGestureRecognizer alloc] init:L];
        
        if( lv_type(L, 1) != LV_TNIL ) {
            [LVUtil registryValue:L key:gesture stack:1];
        }
        
        {
            NEW_USERDATA(userData, LVUserDataGesture);
            gesture.userData = userData;
            userData->gesture = CFBridgingRetain(gesture);
            
            lvL_getmetatable(L, META_TABLE_LongPressGesture );
            lv_setmetatable(L, -2);
        }
    }
    return 1; /* new userdatum is already on the stack */
}

static int setNumberOfTouchesRequired (lv_State *L) {
    LVUserDataGesture * user = (LVUserDataGesture *)lv_touserdata(L, 1);
    if( LVIsType(user,LVUserDataGesture) ){
        LVLongPressGestureRecognizer* gesture =  (__bridge LVLongPressGestureRecognizer *)(user->gesture);
        if( lv_gettop(L)>=2 ){
            float num = lv_tonumber(L, 2);
            gesture.numberOfTouchesRequired = num;
            return 0;
        } else {
            float num = gesture.numberOfTouchesRequired;
            lv_pushnumber(L, num);
            return 1;
        }
    }
    return 0;
}

+(int) classDefine:(lv_State *)L {
    {
        lv_pushcfunction(L, lvNewGestureRecognizer);
        lv_setglobal(L, "UILongPressGestureRecognizer");
    }
    
    lv_createClassMetaTable(L, META_TABLE_LongPressGesture);
    
    lvL_openlib(L, NULL, [LVGestureRecognizer baseMemberFunctions], 0);
    
    {
        const struct lvL_reg memberFunctions [] = {
            {"numberOfTouchesRequired",     setNumberOfTouchesRequired},
            {"setNumberOfTouchesRequired",  setNumberOfTouchesRequired},
            {NULL, NULL}
        };
        lvL_openlib(L, NULL, memberFunctions, 0);
    }
    return 1;
}


@end