/**************************************************
******************** General Setup
**************************************************/

use role sysadmin;

create database tog_workshop;

create warehouse tog_workshop_vwh
    warehouse_size=xsmall,
    auto_resume=True,
    auto_suspend=60;



/**************************************************
******************** Doc AI Setup
**************************************************/


use role sysadmin;

use database tog_workshop;
create schema inspections;

use warehouse tog_workshop_vwh;

use role accountadmin;

create role if not exists doc_ai_role;
grant database role snowflake.document_intelligence_creator to role doc_ai_role;
grant usage, operate on warehouse tog_workshop_vwh to role doc_ai_role;
grant usage on database tog_workshop to role doc_ai_role;
grant usage on schema tog_workshop.inspections to role doc_ai_role;
grant create stage on schema tog_workshop.inspections to role doc_ai_role;
grant create snowflake.ml.document_intelligence on schema tog_workshop.inspections to role doc_ai_role;
grant create model on schema tog_workshop.inspections to role doc_ai_role;
grant create stream, create table, create task, create view on schema tog_workshop.inspections to role doc_ai_role;
grant execute task on account to role doc_ai_role;
grant role doc_ai_role to role sysadmin;
grant role doc_ai_role to user bmutell;


use role doc_ai_role;
use schema tog_workshop.inspections;
create or replace stage docs_stage
  directory = (enable = TRUE)
  encryption = (type = 'SNOWFLAKE_SSE');



/**************************************************
******************** Cortex Search Setup
**************************************************/

use role sysadmin;

use database tog_workshop;
create schema fireworks;


/**************************************************
******************** Corte Analyst Setup
**************************************************/

use role sysadmin;

use database tog_workshop;
create schema police;

use warehouse tog_workshop_vwh;

-- Load CSV of data
-- Create semantic model


