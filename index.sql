#mysql 실행 방법
cd C:\Bitnami\wampstack-7.1.19-0\mysql\bin
mysql -uroot -p
111111
-p 비밀번호
-h 호스트 주소 

show databases; #db목록 보여줌
show tables; # table 목록 보여줌
use [DATABASE_NAME] # 데이터 베이스 pick

#sql mode 설정
select @@GLOBAL.SQL_MODE, @@SESSION.SQL_MODE LIMIT 0, 1000;
set sql_mode = "ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLESRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION,STRICT_ALL_TABLES";
#delete * from table 가능케하기
set sql_safe_updates = 0

#Select
SELECT
    [ALL | DISTINCT | DISTINCTROW ]
      [HIGH_PRIORITY]
      [STRAIGHT_JOIN]
      [SQL_SMALL_RESULT] [SQL_BIG_RESULT] [SQL_BUFFER_RESULT]
      [SQL_CACHE | SQL_NO_CACHE] [SQL_CALC_FOUND_ROWS]
    select_expr [, select_expr ...]
    [FROM table_references
      [PARTITION partition_list]
    [WHERE where_condition]
    [GROUP BY {col_name | expr | position}
      [ASC | DESC], ... [WITH ROLLUP]]
    [HAVING where_condition]
    [ORDER BY {col_name | expr | position}
      [ASC | DESC], ...]
    [LIMIT {[offset,] row_count | row_count OFFSET offset}]
    [PROCEDURE procedure_name(argument_list)]
    [INTO OUTFILE 'file_name'
        [CHARACTER SET charset_name]
        export_options
      | INTO DUMPFILE 'file_name'
      | INTO var_name [, var_name]]
    [FOR UPDATE | LOCK IN SHARE MODE]]
	
	
#View - join 같이 명령문이 길 경우 사용하는 임시 테이블
CREATE
    [OR REPLACE]
    [ALGORITHM = {UNDEFINED | MERGE | TEMPTABLE}]
    [DEFINER = { user | CURRENT_USER }]
    [SQL SECURITY { DEFINER | INVOKER }]
    VIEW view_name [(column_list)]
    AS select_statement
    [WITH [CASCADED | LOCAL] CHECK OPTION] #뷰를 만들때 where 조건이 있다면, 그 조건에 맞는 값만 입력 가능.
Create vuew view_name as select * from table1 t1 join table2 t2 on t1.id = t2.id;

#Lock - 락을 거는 순간 다른 테이블에 접근 불가능
LOCK TABLES
    tbl_name [[AS] alias] lock_type
    [, tbl_name [[AS] alias] lock_type] ...

lock_type: {
    READ [LOCAL]
  | [LOW_PRIORITY] WRITE
}
#READ : 락을 건 세션은 읽기만 가능
#WRITE : 락을 건 세션은 읽기, 쓰기 가능
락을 건 세션만 테이블에 접근가능
WRITE 락이 READ보다 우선순위 높음
lock tables table_name write;

lock tables sales read, sales_history write;
select @total := sum(transaction_value) from sales;
insert into sales_history (recoreded, total) values (now(), @total);
unlock tables;

UNLOCK TABLES

#Transaction
START TRANSACTION
    [transaction_characteristic [, transaction_characteristic] ...]

transaction_characteristic: {
    WITH CONSISTENT SNAPSHOT
  | READ WRITE
  | READ ONLY
}

SET [GLOBAL | SESSION] TRANSACTION
    transaction_characteristic [, transaction_characteristic] ...

transaction_characteristic: {
    ISOLATION LEVEL level
  | access_mode
}

level: {
     REPEATABLE READ
   | READ COMMITTED
   | READ UNCOMMITTED
   | SERIALIZABLE
}

access_mode: {
     READ WRITE
   | READ ONLY
}

BEGIN [WORK]
COMMIT [WORK] [AND [NO] CHAIN] [[NO] RELEASE]
ROLLBACK [WORK] [AND [NO] CHAIN] [[NO] RELEASE]
SET autocommit = {0 | 1}

set autocommit = 0;
#...
commit;

start transaction:
select * from books;
commit;

ex) 
set session transaction isolation level read uncommited;
start transaction;
savepoint point1;
delete from person where id = 2;
select * from person where id = 1;
rollback to point1;
commit | rollback;


#isonlation levels
#1. Read Uncommitted - 다른 트랙잭션의 Commit 되지 않은 값을 읽을 수 있음
해당 트랜잭션이 rollback(commit 되지 않음) 된다면 존재하지 않는 데이터 읽어오게됨. (dirty read)
#2. Read Commited - 다른 트랜잭션의 Commit 된 데이터만 읽어옴
다른 트랙잭션이 이 트랜잭션 중간에 커밋을 할경우 이 트랜잭션이 다른 트랙잭션 Commit 전에 Select를 할 때와 후의 Select 값이 다르다 => (phantom read)
#3. Repeatable Read - 이 트랜잭션이 실행될 때 snapshot을 만들어 다른 트랙잭션이 Commit 하더라도 추가된 데이터를 읽지 않음
select는 항상 동일하더라도, 이 트랙잭션에서 Update, Delete를 할경우에는 최신 snapshot에서 데이터를 읽어온다.
#4. Serializable
Reapeatable Read가 실행중 다른 트랙잭션이 영향을 끼칠 수 있는 반면, Serializable이 실행중일 때는 다른 트랙잭션은 읽기만 가능.

#변수 설정
set @user = "John";
select @user;
set @value = 99;
select @value;
select @total := sum(value), @min_value := min(value) from sales;
select @total, @min_value;
 
 #sql 함수
 curdate() => 2018-01-01;
 curdate() + interval 36 days; # 36일 더 함
 date_sub('2010-06-16', interval 5 month); # 5개월 뺌
 curtime() => 16:55:20;
 dayname(curdate());
 from_days(datediff(curdate(), @born)) => 0041-09-26;
 str_to_date('15/05/1974', '%d/%m/%Y) ;
 date_format('2010-02-02', '%a %d %M \ '%y'); => Sat 27 Feburary '2010;
 
 select if(id is not null, 'hello', 'goodbye');
 select ifnull(id, B) # if id is null prints B if id is not null prints id;
 
 cast('1999-01-01' as char);
 concat('a', 'b');
 
 #procedure - 함수와 
 
 CREATE
    [DEFINER = { user | CURRENT_USER }]
    PROCEDURE sp_name ([proc_parameter[,...]])
    [characteristic ...] routine_body

CREATE
    [DEFINER = { user | CURRENT_USER }]
    FUNCTION sp_name ([func_parameter[,...]])
    RETURNS type
    [characteristic ...] routine_body

proc_parameter:
    [ IN | OUT | INOUT ] param_name type

func_parameter:
    param_name type

type:
    Any valid MySQL data type

characteristic:
    COMMENT 'string'
  | LANGUAGE SQL
  | [NOT] DETERMINISTIC
  | { CONTAINS SQL | NO SQL | READS SQL DATA | MODIFIES SQL DATA }
  | SQL SECURITY { DEFINER | INVOKER }

routine_body:
    Valid SQL routine statement
 
 ex)
 /* DELIMITER는 프로시저 앞,뒤의 위치하여 안에 있는 부분은  한번에 실행될 수 있게 하는 역할을 한다. */
 delimiter $$
 create procedure HelloWorld()
 begin
 select "Hello World!!";
 end$$
 
 delimiter ;
 drop  procedure HelloWorld;
 
 call HelloWorld();
 
 
