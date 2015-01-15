-- period of time to check for
set @to     = '20140829000100';
set @to     = '20141001000100';

set @from   = '20140829000000';
set @to     = '20140903000000';


-- log of problems found using this script:
--   https://wikitech.wikimedia.org/wiki/Analytics/DataWarehouse/Requirements#Initial_Data_Verifications
-- edit fact matches source revision and archive table
 select etl.wiki,
        etl.k                           as date_with_bad_match,
        etl.value                       as value_in_warehouse,
        coalesce(en.value, de.value)    as value_in_original_db

   from (select wiki,
                date_format(time, '%Y%m%d') as k,
                count(*) as value
           from warehouse.edit
          where time between @from and @to
            and wiki in ('dewiki', 'enwiki')
          group by wiki, k
        ) etl

            left join

        (select 'dewiki' as wiki,
                left(time, 8) as k,
                archived,
                count(*) as value
           from (select rev_timestamp as time,
                        0 as archived
                   from dewiki.revision
                  where rev_timestamp between @from and @to

                  union all

                 select ar_timestamp as time,
                        1 as archived
                   from dewiki.archive
                  where ar_timestamp between @from and @to
                ) all_revisions
          group by wiki, k
        ) de            on de.k = etl.k
                       and de.value <> etl.value
                       and de.wiki = etl.wiki

            left join

        (select 'enwiki' as wiki,
                left(time, 8) as k,
                archived,
                count(*) as value
           from (select rev_timestamp as time,
                        0 as archived
                   from enwiki.revision
                  where rev_timestamp between @from and @to

                  union all

                 select ar_timestamp as time,
                        1 as archived
                   from enwiki.archive
                  where ar_timestamp between @from and @to
                ) all_revisions
          group by wiki, k
        ) en            on en.k = etl.k
                       and en.value <> etl.value
                       and en.wiki = etl.wiki

  where de.value is not null
     or en.value is not null
;
