#mysql 실행 방법
cd C:\Bitnami\wampstack-7.1.19-0\mysql\bin
mysql -uroot -p
111111
-p 비밀번호
-h 호스트 주소 

#show
show databases; #db목록 보여줌
show tables; # table 목록 보여줌
show users;
show errors; # 최근 에러 보여줌
show warnings;

primary key 중복 x null x
unique key 중복 x null o

create table if exists ...
drop table if exists ...

use [DATABASE_NAME] # 데이터 베이스 pick

#sql mode 설정
select @@GLOBAL.SQL_MODE, @@SESSION.SQL_MODE LIMIT 0, 1000;
set sql_mode = "ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLESRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION,STRICT_ALL_TABLES";
#delete * from table 가능케하기
set sql_safe_updates = 0

#Select
#################################################
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
	#################################################
	ex) select id, title into @Id, @Title from books where id = 1 limit 0, 1000; #앞에서 부터 순서대로 들어감
	
#View - join 같이 명령문이 길 경우 사용하는 임시 테이블
#################################################
CREATE
    [OR REPLACE]
    [ALGORITHM = {UNDEFINED | MERGE | TEMPTABLE}]
    [DEFINER = { user | CURRENT_USER }]
    [SQL SECURITY { DEFINER | INVOKER }]
    VIEW view_name [(column_list)]
    AS select_statement
    [WITH [CASCADED | LOCAL] CHECK OPTION] #뷰를 만들때 where 조건이 있다면, 그 조건에 맞는 값만 입력 가능.
	#################################################
ex) 
Create vuew view_name as select * from table1 t1 join table2 t2 on t1.id = t2.id;

#Lock - 락을 거는 순간 다른 테이블에 접근 불가능
#################################################
LOCK TABLES
    tbl_name [[AS] alias] lock_type
    [, tbl_name [[AS] alias] lock_type] ...

lock_type: {
    READ [LOCAL]
  | [LOW_PRIORITY] WRITE
}
#################################################
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
#################################################
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
#################################################
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


#Isonlation levels
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
 str_to_date('15/05/1974', '%d/%m/%Y') ;
 date_format('2010-02-02', '%a %d %M \ '%y'); => Sat 27 Feburary '2010
 
 select if(id is not null, 'hello', 'goodbye');
 select ifnull(id, B) # if id is null prints B if id is not null prints id;
 
 cast('1999-01-01' as char);
 concat('a', 'b');
 
 #User
 
 create user 'john@localhost' identified by 'passwordhere';
 grant all privileges on *.* to 'john@localhost';
 update user set password=password('newpassword') where user = 'john@localhost';
 flush privileges; # 권한 리로드 (업데이트, 인서트 등으로 수정시)
 delete from user where user = 'john@localhost';
 flush privileges;
 
 #프로시저 에러 핸들링
 #################################################
 DECLARE handler_action HANDLER
    FOR condition_value [, condition_value] ...
    statement

handler_action: {
    CONTINUE
  | EXIT
  | UNDO
}

condition_value: {
    mysql_error_code
  | SQLSTATE [VALUE] sqlstate_value
  | condition_name
  | SQLWARNING
  | NOT FOUND
  | SQLEXCEPTION
}
 #################################################
 #Procedure - 함수와 역할이 같음
 #################################################
#프로시저 생성 명령어
 CREATE
    [DEFINER = { user | CURRENT_USER }]
    PROCEDURE sp_name ([proc_parameter[,...]])
    [characteristic ...] routine_body
#함수 생성 명령어
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
  | SQL SECURITY { DEFINER | INVOKER } #definer : 생성한 user의 권한을 따름, invoker: 실행한 user의 권한을 따름

routine_body:
    Valid SQL routine statement
 #################################################
 ex)
 /* DELIMITER는 프로시저 앞,뒤의 위치하여 안에 있는 부분은  한번에 실행될 수 있게 하는 역할을 한다. */
 delimiter $$
 create procedure HelloWorld(in hello varchar(30), out helloOut varchar(30)) # inout도 있음
 begin
 select concat(hello, "World!!")
 into helloOut;
 end$$
 
 delimiter ;
 drop  procedure HelloWorld;
 
 call HelloWorld('hello', @helloOut);
 select @helloOut;
 
 ex2)
 create user shopuser@localhost identified by 'passwordhere';
 grant execute on procedure online_shop.ShowCustomers to shopuser@localhost;
 grant select on online_shop.customers to shopuser@localhost;
 
 delimiter $$
 create definer = shopuser@localhost procedure 'ShowCustomers' () 
 sql security definer
 begin
	declare var1 bool default false;
	
	declare exit handler for sqlexception # 타이포 에러, 없는 테이블 등...
	begin	
		show errors;
	end;
	declare exit handler for sqlwarning # 값이 없거나 등...
	begin 
		show warnings;
	end;
	
	start transaction;
	
		set var1 = true;
		
		if var1 = true then
			select * from customers for update of database.table wait 5; # 해당 테이블 업데이트를 하지 못하도록 락을 걸고, 락이 이미 걸려있으면 5초 대기 후 에러
		else 
			select "Goodbye";
		end if;
		
		declare count int default 0;
		while count < 10 do #해당 테이블 행 길이만큼 ,labelled loop도 있음
			select 'Hello Inf loof'
			set count := count + 1;
		end while;
		
	commit;
 end$$
 
 delimiter ;
 call ShowCustomers();
 
 #Cursor 
#읽기만 가능
 
 DECLARE cursor_name CURSOR FOR select_statement

 ex1)
 delimiter $$
 create procedure cursortest()
 begin
 declare the_email varhcar(40);
 
 declare cur1 cursor for select email from users;
 open cur1;

 fetch cur1 into the_email; # 값을 꺼내서 the_email에 넣어줌.

 close cur1;
 
 end $$
 delimiter ;
 
 ex2) labelled loop 안의 cursor
 
 delimiter $$
 create procedure cursortest()
 begin
	declare the_email varchar(40);
	declare finished boolean default false;
	declare cur1 for select email from users where active = true and registered > date(now()) - interval 1 year;
	declare coutinue handler for not found set finished := true; # 값을 찾지 못 했을 때 예외처리 (작업이 다 끝났음)
	
	open cur1;
	
	the_loop: loop
		fetch cur1 into the_email;
		if finished then
			leave the_loop;
		
		case the_email
			when 'abcd@abcd.com' then
				#...
			when 'abcd@abcd.kr' then
				#...
		end case;
			
	end loop the_loop;
	
	close cur1;
	select the_email;
	
end$$
 delimiter ;
 
 #Trigger - update, delete, select ,insert 등의 이벤트에 자동으로 실행되는 함수
 #1. cascad에는 작동하지 않음
 #2. start transaction, commit, rollback 등 확정적, 암시적으로 트랙잭션 시작 또는 종료 명령문 사용 불가능
 #3. before 트리거가 실패할 경우 실행되지 않음, after는 before(존재 한다면)와 모든 동작이 성공적으로 실행 될때 실행
 #4. autocommit = 1 일 경우 자동적으로 트랜잭션 적용, 트랜잭션 기능 사용가능 예) select for update ...
 #################################################
 CREATE
    [DEFINER = { user | CURRENT_USER }]
    TRIGGER trigger_name
    trigger_time trigger_event
    ON tbl_name FOR EACH ROW
    [trigger_order]
    trigger_body

trigger_time: { BEFORE | AFTER }

trigger_event: { INSERT | UPDATE | DELETE }

trigger_order: { FOLLOWS | PRECEDES } other_trigger_name
#################################################
DROP TRIGGER [IF EXISTS] [schema_name.]trigger_name
#################################################

 ex) 업데이트 이전, 이후 값
 create table sales1(id int primary key, product varchar(30) not null, value numeric(10, 2));
 create table sales2(id int primary key auto_increment, product_id int not null, changed_at timestamp, before_value numeric(10,2) not null, after_value numeric(10,2) not null);
 
 delimiter $$
 create trigger before_sales_update before update on sales1 for each row
 begin
	insert into sales2(product_id, chaged_at, before_value, after_value) 
	value (old.id, now(), old.value, new.value); #old(sales1)는 트리거 발생전의 컬럼 값, new(sales2)는 발생후 컬럼 값
 end$$
 delimiter ;
 
 ex2) Validating with transaction
  delimiter $$
  create trigger before_products_inserts before insert on products for each row
  begin 
	if new.value > 100.0 then
		set new.value := 100.0;
	end if;
  end$$
  
  create ti
  delimiter ;
  
  #User-Defined Function
  #functions vs procedures 
  #1. 함수는 무조건 값을 반환, 프로시저는 옵션
  #2. 프로시저는 in 뿐만 아니라 out 파라메터를 가질 수 있음
  #3. 프로시저는 예외처리 가능케하기
  #4. 프로시저는 트랜잭션 처리 가능
  #...
  
  ex)
  delimiter $$
  create function sales_after_tax(tax float, day date) returens numeric(10, 2)
  begin
	declare result numeric(10, 2);
	select sum (...);
	return result;
  end$$
  delimiter ;
  
  #실행
  select sales_after_tax(19, '2015-03-11');
