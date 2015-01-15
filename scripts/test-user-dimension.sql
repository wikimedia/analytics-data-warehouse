-- user dimension matches source user table

 select count(*) as enwiki_users_that_should_be_bots
   from warehouse.user
  where user_id in (
         select ug_user
           from enwiki.user_groups
          where ug_group = 'bot'
        )
    and wiki = 'enwiki'
    and in_bot_user_group = 0
;

 select count(*) as enwiki_users_that_should_not_be_bots
   from warehouse.user
  where user_id not in (
         select ug_user
           from enwiki.user_groups
          where ug_group = 'bot'
        )
    and wiki = 'enwiki'
    and in_bot_user_group = 1
;


 select count(*) as dewiki_users_that_should_be_bots
   from warehouse.user
  where user_id in (
         select ug_user
           from dewiki.user_groups
          where ug_group = 'bot'
        )
    and wiki = 'dewiki'
    and in_bot_user_group = 0
;

 select count(*) as dewiki_users_that_should_not_be_bots
   from warehouse.user
  where user_id not in (
         select ug_user
           from dewiki.user_groups
          where ug_group = 'bot'
        )
    and wiki = 'dewiki'
    and in_bot_user_group = 1
;


 select count(*) as enwiki_users_that_should_be_bots
   from warehouse.user
  where user_id in (
         select ug_user
           from enwiki.user_groups
          where ug_group = 'bot'
        )
    and wiki = 'enwiki'
    and in_bot_user_group = 0
;

 select count(*) as enwiki_users_that_should_not_be_bots
   from warehouse.user
  where user_id not in (
         select ug_user
           from enwiki.user_groups
          where ug_group = 'bot'
        )
    and wiki = 'enwiki'
    and in_bot_user_group = 1
;


 select count(*) as dewiki_users_that_should_be_bots
   from warehouse.user
  where user_id in (
         select ug_user
           from dewiki.user_groups
          where ug_group = 'bot'
        )
    and wiki = 'dewiki'
    and in_bot_user_group = 0
;

 select count(*) as dewiki_users_that_should_not_be_bots
   from warehouse.user
  where user_id not in (
         select ug_user
           from dewiki.user_groups
          where ug_group = 'bot'
        )
    and wiki = 'dewiki'
    and in_bot_user_group = 1
;


-- registration type checks
 select count(*) as wrong_action
   from warehouse.user
            left join
        enwiki.logging  on log_user = user_id
                       and log_type = 'newusers'
  where wiki = 'enwiki'
    and registration_type <> log_action
;

 select count(*) as wrong_action
   from warehouse.user
            left join
        dewiki.logging  on log_user = user_id
                       and log_type = 'newusers'
  where wiki = 'dewiki'
    and registration_type <> log_action
;
