//
//  LZTableViewDataSourceUtility.m
//  ws_push_ios_1.0
//
//  Created by chengh on 16/10/2.
//  Copyright © 2016年 WNP. All rights reserved.
//

#import "LZTableViewDataSourceUtility.h"

@interface LZTableViewDataSourceUtility()

@property (strong, nonatomic) NSString *cellIdentifier;
@property (strong, nonatomic) NSArray *items;
@property (strong, nonatomic) TableViewCellConfigureBlock configureCellBlock;
@property (strong, nonatomic) TableViewCellConfigureEditingBlock configureEditingCellBlock;

@end

@implementation LZTableViewDataSourceUtility

#pragma mark - public Method

- (instancetype)initWithItems:(NSArray *)anItems cellIdentifier:(NSString *)aCellIdentifier configureCellBlock:(TableViewCellConfigureBlock)aConfigureCellBlock{
    self = [super init];
    if (self) {
        _items = anItems;
        _cellIdentifier = aCellIdentifier;
        _configureCellBlock = aConfigureCellBlock;
        
        _isFullWidth = NO;
        _isCanSlideDelete = NO;
    }
    return self;
}


- (id)itemAtIndexPath:(NSIndexPath*)indexPath {
    return _items[(NSUInteger)indexPath.row];
}


- (void)configureEditingBlock:(TableViewCellConfigureEditingBlock)block{
    _configureEditingCellBlock = block;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_items) {
        return _items.count;
    }else{
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    id cell = nil;
    if ([_cellIdentifier isEqualToString:@"forwardCell"]) {
        cell = [tableView dequeueReusableCellWithIdentifier:_cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] init];
        }
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:_cellIdentifier forIndexPath:indexPath];
    }
    id item = [self itemAtIndexPath:indexPath];
    _configureCellBlock(cell,item);
    ///配置cell的分割线和tableView的宽度一样宽
    if (_isFullWidth) {
        UITableViewCell *resultCell = (UITableViewCell *)cell;
        [resultCell setSeparatorInset:UIEdgeInsetsZero];
        resultCell.layoutMargins = UIEdgeInsetsZero;
        resultCell.preservesSuperviewLayoutMargins = NO;
        return resultCell;
    }else{
        return cell;
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return _isCanSlideDelete;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    if (_configureEditingCellBlock) {
        id cell = [tableView dequeueReusableCellWithIdentifier:_cellIdentifier forIndexPath:indexPath];
        id item = [self itemAtIndexPath:indexPath];
        _configureEditingCellBlock(editingStyle,cell,item);
    }
}


@end
