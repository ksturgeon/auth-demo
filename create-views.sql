CREATE OR REPLACE VIEW dfs.tmp.`short_business` as
SELECT t.`name` as `name`, t.city as city, t.`state` as `state`, t.stars as stars
FROM dfs.`/demo/demo-data/business.json` t;
