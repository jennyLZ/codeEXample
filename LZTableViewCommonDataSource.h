//
//  LZTableViewDataSourceUtility.h
//  ws_push_ios_1.0
//
//  Created by chengh on 16/10/2.
//  Copyright © 2016年 WNP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  该类是UITableView的UITableViewDataSource代理对象。
 *  当UITableView只是简单显示数据时，将dataSource设为该类，并进行简单配置，即可满足要求。
 *  从而无须在各个ViewController中都实现UITableViewDataSource。
 */
@interface LZTableViewDataSourceUtility : NSObject<UITableViewDataSource>

typedef void (^TableViewCellConfigureBlock)(id cell, id item);

typedef void (^TableViewCellConfigureEditingBlock)(UITableViewCellEditingStyle editingStyle, id cell, id item);

//设置是否cell之间的分割线宽度和tableview宽度一样，默认为NO
@property (assign, nonatomic) BOOL isFullWidth;

//设置cell是否可以滑动删除，默认为NO
@property (assign, nonatomic) BOOL isCanSlideDelete;

//初始化DataSource
- (instancetype)initWithItems:(NSArray *)anItems cellIdentifier:(NSString *)aCellIdentifier configureCellBlock:(TableViewCellConfigureBlock)aConfigureCellBlock;

//配置tableview的滑动删除
- (void)configureEditingBlock:(TableViewCellConfigureEditingBlock)block;


@end
