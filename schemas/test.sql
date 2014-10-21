set @cache_sql_log_bin := @@session.sql_log_bin;
set @@session.sql_log_bin = 1;

set @cache_event_scheduler := @@global.event_scheduler;
set @@global.event_scheduler = 0;

create database if not exists warehouse;
use warehouse;

drop event if exists etl_edit;
-- drop table if exists wikis;
-- drop table if exists edit;
-- drop table if exists user;
-- drop table if exists page;

create table if not exists edit (

    time    timestamp    default 0,
    wiki    varchar(100) not null,
    user_id int          not null,
    rev_id  int          not null,
    page_id int          not null,

    index i1 (wiki, time),
    index i2 (time, wiki)
)
engine=tokudb;

create table if not exists user (

    wiki              varchar(100) not null,
    user_id           int          not null,
    user_name         varchar(100) not null,
    user_registration timestamp    default 0,
    registration_type varchar(100) not null,
    in_bot_user_group boolean      default 0,
    valid_from        timestamp    default 0,
    valid_to          timestamp    default 0,
    valid_currently   boolean      default 0,

    index i1 (wiki, user_id),
    index i1 (wiki, user_name)

)
engine=tokudb;

create table if not exists page (

    wiki             varchar(100) not null,
    page_id          int          not null,
    namespace        int          not null,
    archived         boolean      default 0,
    page_is_redirect boolean      default 0,
    valid_from       timestamp    default 0,
    valid_to         timestamp    default 0,
    valid_currently  boolean      default 0,

    index i1 (wiki, page_id),
    index i2 (wiki, namespace, page_id)

)
engine=tokudb;

create table if not exists wikis (
    wiki varchar(100) primary key,
    stamp_edit varbinary(14) not null,
    stamp_user varbinary(14) not null
)
engine=tokudb;

delimiter ;;

create event if not exists etl_edit
    on schedule every 1 second starts date(now())
    do begin

        declare all_done int default 0;        
        declare wiki_db varchar(100) default null;

        declare wiki_list cursor for
            select wiki from wikis order by wiki;

        declare continue handler for not found
            begin
                set all_done = 1;
            end;

        declare exit handler for sqlwarning
            begin
                rollback;
            end;

        declare exit handler for sqlexception
            begin
                rollback;
            end;

        if (get_lock('etl_edit', 1) = 1) then

            set all_done = 0;
            open wiki_list;

            repeat fetch wiki_list into wiki_db;

                if (all_done = 0 and wiki_db is not null) then

                    start transaction;

                    -- edit
                    select @stamp_min := stamp_edit from wikis where wiki = wiki_db;
                    select @stamp_max := date_format(cast(@stamp_min as datetime) + interval 1 hour, "%Y%m%d%H%i%s");

                    set @sql = concat(
                        'insert into edit ',
                            'select ',
                                'rev_timestamp, ',
                                '"', wiki_db, '", ',
                                'rev_user, ',
                                'rev_id, ',
                                'rev_page ',
                            'from ',
                                wiki_db, '.revision ',
                            'where ',
                                'rev_timestamp >= "', @stamp_min, '" and rev_timestamp < "', @stamp_max, '"'
                    );
                    prepare stmt from @sql; execute stmt; deallocate prepare stmt;

                    set @sql = concat(
                        'insert into edit ',                    
                            'select ',
                                'ar_timestamp, ',
                                '"', wiki_db, '", ',
                                'ar_user, ',
                                'ar_id, ',
                                'ar_page_id ',
                            'from ',
                                wiki_db, '.archive ',
                            'where ',
                                'ar_timestamp >= "', @stamp_min, '" and ar_timestamp < "', @stamp_max, '"'
                    );
                    prepare stmt from @sql; execute stmt; deallocate prepare stmt;
                    update wikis set stamp_edit = @stamp_max where wiki = wiki_db;

                    -- user
                    select @stamp_min := stamp_user from wikis where wiki = wiki_db;
                    select @stamp_max := date_format(cast(@stamp_min as datetime) + interval 1 hour, "%Y%m%d%H%i%s");

                    set @sql = concat(
                        'insert into user '
                            'select ',
                                '"', wiki_db, '", ',
                                'user_id, ',
                                'user_name, ',
                                'user_registration, ',
                                'log_action, ',
                                'if(ug_group is null,1,0), ',
                                'user_registration, ',
                                '0, ',
                                '1 ',
                            'from ',
                                wiki_db, '.user ',
                            'inner join ',
                                wiki_db, '.logging ',
                                'on log_user = user_id ',
                                'and log_type = "newusers" ',
                                'and log_timestamp >= "', @stamp_min, '" and log_timestamp < "', @stamp_max, '" ',
                            'left join ',
                                wiki_db, '.user_groups ',
                                'on ug_user = user_id ',
                                'and ug_group = "bot" '
                    );
                    prepare stmt from @sql; execute stmt; deallocate prepare stmt;
                    update wikis set stamp_user = @stamp_max where wiki = wiki_db;

                    -- page
                    select @page_min := ifnull(page_id,0) from (
                        select page_id from page where wiki = wiki_db order by page_id desc limit 1
                    ) t;

                    set @sql = concat(
                        'insert into page ',
                            'select ',
                                '"', wiki_db, '", ',
                                'page_id, ',
                                'page_namespace, ',
                                '0, ',
                                'page_is_redirect',
                                'coalesce(rev_timestamp, ar_timestamp, 0), ',
                                '0, ',
                                '1 ',
                            'from ',
                                wiki_db, '.page ',
                            'left join ',
                                wiki_db, '.revision ',
                                'on rev_page = page_id ',
                                'and rev_parent_id = 0 ',
                            'left join ',
                                wiki_db, '.archive ',
                                'on ar_page_id = page_id ',
                                'and ar_parent_id = 0 ',
                            'where ',
                                'page_id > ', @page_min, ' ',
                            'order by ',
                                'page_id ',
                            'limit 10000 '
                    );

                    prepare stmt from @sql; execute stmt; deallocate prepare stmt;

                    commit;

                end if;

                until all_done
            end repeat;

            do release_lock('etl_edit');

        end if;

    end;; 

delimiter ;

set @@session.sql_log_bin = @cache_sql_log_bin;
set @@global.event_scheduler = @cache_event_scheduler;
