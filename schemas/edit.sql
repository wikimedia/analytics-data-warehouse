-- Edits from the revision and archive tables land here

-- fact table
 create table edit as (
    time            timestamp,
    wiki            varchar(100),
    user_id         int,            -- see user dimension below
    rev_id          int,
    page_id         int,            -- see page dimension below
 )

-- user dimension
 create table user as (
    wiki                varchar(100),
    user_id             int,
    user_name           varchar(100),
    user_registration   timestamp,
    registration_type   varchar(100),
    in_bot_user_group   boolean,

    valid_from          timestamp,
    valid_to            timestamp,
    valid_currently     boolean,
 )

-- page dimension (not strictly needed right away)
 create table page as (
    wiki                varchar(100),
    page_id             int,
    namespace           int,
    archived            boolean,
    page_is_redirect    boolean,

    valid_from          timestamp,
    valid_to            timestamp,
    valid_currently     boolean,
 )


-- ETL-ing data to these tables is sometimes straighforward, and sometimes not.
-- filling edit table:
 select rev_timestamp,
        database(),
        rev_user,
        rev_id,
        rev_page
   from revision
<< since last rev_timestamp we fetched >>

union all

 select ar_timestamp,
        database(),
        ar_user,
        ar_rev_id,
        ar_page
   from archive
<< since last ar_timestamp we fetched >>

-- filling the user dimension:
 select database(),
        user_id,
        user_name,
        user_registration,
        log_action,
        ug_group is null
        user_registration,
        null,
        true

   from user
            inner join
        logging         on log_user = user_id
                        and log_type = 'newusers'
                        -- maybe filter by log_timestamp for speed
            left join
        user_groups     on ug_user = user_id
                        and ug_group = 'bot'

-- filling the page dimension:
 select database(),
        page_id,
        page_namespace,
        false,
        page_is_redirect,
        coalesce(rev_timestamp, ar_timestamp),
        null,
        true
   from page
            left join
        revision        on rev_page = page_id
                        and rev_parent_id = 0
            left join
        archive         on ar_page_id = page_id
                        and ar_parent_id = 0

-- Hoever, *updating* the tables could prove quite difficult.  Because at any point,
--   a revision might be modified by an admin
--   a page might be deleted or archived
--   a user might become a bot
--   a user might change their name

-- I have not thought through all the possible changes, but the ones we care about
--   are at least known.  This is what I'm looking for out of an ETL tool - help
--   with these types of slowly changing dimensions, maybe some kind of efficient
--   way to keep tabs on what changes without re-scanning all the tables constantly


-- with this setup, we could re-write metrics as follows.
-- The hope is that we can optimize these queries more easily than we can the current queries
-- for simplicity:
--      C = day to run
--      B = C - 1 month
--      A = C - 2 months

-- rolling recurring old active editor
 select user_id
   from edit
            inner join
        user    on edit.user_id = user.user_id
                and edit.wiki = user.wiki
                and C between user.valid_from and user.valid_to
  where time between A and C
    and user.in_bot_user_group = 0
    and user.user_registration < A
  group by user_id
 having sum(time <= B) >= 5
    and sum(time > B) >= 5

-- rolling new active editor
 select user_id
   from edit
            inner join
        user    on edit.user_id = user.user_id
                and edit.wiki = user.wiki
                and C between user.valid_from and user.valid_to
  where time between B and C
    and user.in_bot_user_group = 0
    and user.user_registration >= B
  group by user_id
 having count(*) > 5
