//
//  KBListView.m
//  Keybase
//
//  Created by Gabriel on 3/9/15.
//  Copyright (c) 2015 Gabriel Handford. All rights reserved.
//

#import "KBListView.h"

@interface KBListView ()
@property Class prototypeClass;
@property YONSView *prototypeView;
@end

@interface KBListViewDynamicHeight : KBListView
@end

@implementation KBListView

+ (instancetype)listViewWithPrototypeClass:(Class)prototypeClass rowHeight:(CGFloat)rowHeight {
  Class tableViewClass = KBListView.class;
  if (rowHeight == 0) tableViewClass = KBListViewDynamicHeight.class;

  KBListView *listView = [[tableViewClass alloc] init];

  listView.view.intercellSpacing = CGSizeZero;

  NSTableColumn *column1 = [[NSTableColumn alloc] initWithIdentifier:@""];
  [listView.view addTableColumn:column1];
  [listView.view setHeaderView:nil];

  listView.prototypeClass = prototypeClass;
  if (rowHeight > 0) listView.view.rowHeight = rowHeight;
  return listView;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  id object = [self.dataSource objectAtIndexPath:[NSIndexPath indexPathForItem:row inSection:0]];
  YONSView *view = [self.view makeViewWithIdentifier:NSStringFromClass(self.prototypeClass) owner:self];
  BOOL dequeued = NO;
  if (!view) {
    dequeued = YES;
    view = [[_prototypeClass alloc] init];
    view.identifier = NSStringFromClass(_prototypeClass);
  }

  self.cellSetBlock(view, object, [NSIndexPath indexPathWithIndex:row], tableColumn, self.view, dequeued);
  if ([view respondsToSelector:@selector(setNeedsLayout)]) [view setNeedsLayout];
  return view;
}

@end

@implementation KBListViewDynamicHeight

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
  if (!self.prototypeView) self.prototypeView = [[self.prototypeClass alloc] init];
  id object = [self.dataSource objectAtIndexPath:[NSIndexPath indexPathForItem:row inSection:0]];

  self.cellSetBlock(self.prototypeView, object, [NSIndexPath indexPathWithIndex:row], nil, self.view, NO);
  [self.prototypeView setNeedsLayout];

  CGFloat height = [self.prototypeView sizeThatFits:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)].height;
  //GHDebug(@"Row: %@, height: %@, width: %@", @(row), @(height), @(self.frame.size.width));
  return height;
}

@end
