//
//  PersistWords.m
//  RainbowGet
//
//  Created by Realank on 2017/3/16.
//  Copyright © 2017年 Realank. All rights reserved.
//

#import "PersistWords.h"
#import <sqlite3.h>
@implementation PersistWords

+ (NSString*)dbPath{
    NSString *dirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString* filePath = [dirPath stringByAppendingPathComponent:@"words.db"];
    return filePath;
}

+ (BOOL)dbFileExist{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:[self dbPath] isDirectory:nil];
    return existed;
}



+(NSArray*)allWords{
    if (![self dbFileExist]) {
        return nil;
    }
    
    char sql_stmt[1000];
    
    sqlite3 *newWordsDB; //Declare a pointer to sqlite database structure
    const char *dbpath = [[self dbPath] UTF8String]; // Convert NSString to UTF-8
    //打开数据库文件，没有则创建
    if (sqlite3_open(dbpath, &newWordsDB) == SQLITE_OK) {
        NSLog(@"数据库打开成功");
    } else {
        NSLog(@"数据库打开失败");
    }
    sqlite3_stmt *statement;
    //－－－查－－－
    NSString* command = [NSString stringWithFormat:@"SELECT WORDID, START, PERIOD ,AUDIOFILE FROM WORDS"];
    snprintf(sql_stmt, sizeof(sql_stmt)/sizeof(char), "%s", [command UTF8String]);
    //准备一个SQL语句，用于执行
    sqlite3_prepare_v2(newWordsDB, sql_stmt, -1, &statement, NULL);
    NSMutableArray* wordsList = [NSMutableArray array];
    //执行一条准备的语句,如果找到一行匹配的数据，则返回SQLITE_ROW
    while (sqlite3_step(statement) == SQLITE_ROW) {
        //获取执行的结果中，某一列的数据，并指定获取的类型（int, text...）,如果内部类型和获取的类型不一致，方法内部将会对内容进行类型转换
        NSString *wordid = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)];
        double start = sqlite3_column_double(statement, 1);
        double period = sqlite3_column_double(statement, 2);
        NSString *audioFile = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 3)];
        NSString* word = [NSString stringWithFormat:@"%@ %.3f %.3f %@",wordid, start, period,audioFile];
        [wordsList addObject:word];
    }
    sqlite3_finalize(statement);//在内存中，清除之前准备的语句
    
    sqlite3_close(newWordsDB);//关闭数据库

    return [wordsList copy];
}
+(void)addWordWithStart:(double)start period:(double)period wordid:(NSString*)wordID audioFileName:(NSString*)audioFileName{
    
    char sql_stmt[1000];
    sqlite3 *newWordsDB; //Declare a pointer to sqlite database structure
    const char *dbpath = [[self dbPath] UTF8String]; // Convert NSString to UTF-8
    //打开数据库文件，没有则创建
    if (sqlite3_open(dbpath, &newWordsDB) == SQLITE_OK) {
        NSLog(@"数据库打开成功");
    } else {
        NSLog(@"数据库打开失败");
    }
    //创建表
    snprintf(sql_stmt, sizeof(sql_stmt)/sizeof(char),"CREATE TABLE IF NOT EXISTS WORDS (ID INTEGER PRIMARY KEY AUTOINCREMENT, WORDID TEXT, START REAL, PERIOD REAL,AUDIOFILE TEXT)");
    if (sqlite3_exec(newWordsDB, sql_stmt, NULL, NULL, NULL) == SQLITE_OK)
    {
        NSLog(@"创建表成功");
    }else{
        NSLog(@"创建表失败");
    }
    
    //－－－增－－－
    NSString* addcommand = [NSString stringWithFormat:@"INSERT INTO WORDS (WORDID, START, PERIOD,AUDIOFILE) VALUES (\"%@\",%lf,%lf,\"%@\")",wordID,start,period,audioFileName];
    snprintf(sql_stmt, sizeof(sql_stmt)/sizeof(char), "%s", [addcommand UTF8String]);
    if (sqlite3_exec(newWordsDB, sql_stmt, NULL, NULL, NULL) == SQLITE_OK)
    {
        NSLog(@"成功增加一行");
    }
    sqlite3_close(newWordsDB);//关闭数据库
    
}
@end
