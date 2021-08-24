/* Replace with your SQL commands */

drop schema app_hidden cascade;
drop schema app_private cascade;
drop schema app_public cascade;
drop role graphile;
drop role graphile_visitor;
grant all on schema public to public;