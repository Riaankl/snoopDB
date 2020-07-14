create materialized view conformance.eligible_endpoint_coverage as
       select
       oa.endpoint,
       (array_agg(test.release order by test.release::semver))[1] as first_conformance_test,
       (array_agg(test.testname order by test.release::semver))[1] as test,
       (array_agg(test.codename order by test.release::semver))[1] as codename,
       (array_agg(test.file order by test.release::semver))[1] as file,
       (array_agg(oa.release order by oa.release::semver))[1] as first_release,
       array_remove((array_agg(distinct test.release::semver order by test.release::semver)), null) as all_test_releases
       from
                 open_api oa
      inner join conformance.eligible_endpoint using(endpoint)
       left join audit_event ae using(endpoint)
       left join test on (ae.test = test.codename)
group by endpoint;

comment on materialized view conformance.eligible_endpoint_coverage is 'conformance-eligible endpoints-- when they were first released and conformance tested';

comment on column conformance.eligible_endpoint_coverage.endpoint is 'endpoint as defined in table open_api';
comment on column conformance.eligible_endpoint_coverage.first_conformance_test is 'release of earliest conformance test that hits endpoint. May be earlier than release of endpoint.';
comment on column conformance.eligible_endpoint_coverage.test is 'Name of first test that hits endopint, as given in conformance.yaml';
comment on column conformance.eligible_endpoint_coverage.codename is 'first test as it appears in useragent of auditlog';
comment on column conformance.eligible_endpoint_coverage.file is 'file where this first test is defined';
comment on column conformance.eligible_endpoint_coverage.first_release is 'release in which this endpoint first appears in the open_api spec as a stable,eligible endpoint.';
comment on column conformance.eligible_endpoint_coverage.all_test_releases is 'set of releases for tests that hit this endpoint';

\dmv+ conformance.eligible_endpoint_coverage;
