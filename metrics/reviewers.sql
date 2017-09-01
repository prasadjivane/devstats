create temp table matching as select event_id from gha_texts where created_at >= '{{from}}' and created_at < '{{to}}' and substring(body from '(?i)(?:^|\n|\r)\s*/lgtm\s*(?:\n|\r|$)') is not null;
select
  count(distinct actor_id) as result
from
  gha_issues_events_labels
where
  actor_login not in ('googlebot')
  and actor_login not like 'k8s-%'
  and event_id in (
    select min(event_id)
    from
      gha_issues_events_labels
    where
      created_at >= '{{from}}'
      and created_at < '{{to}}'
      and label_name = 'lgtm'
    group by
      issue_id
    union select event_id from matching
  );
drop table matching;
