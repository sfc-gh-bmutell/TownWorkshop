use role doc_ai_role;

use warehouse tog_workshop_vwh;

use schema tog_workshop.inspections;

create or replace stage inference_stage
    directory = (enable = TRUE)
    encryption = (type = 'SNOWFLAKE_SSE');

-- Upload new docs for inference

create or replace table inspection_results as (
 with temp as (
   select
     relative_path as file_name,
     size as file_size,
     last_modified,
     file_url as snowflake_file_url,
     inspection_reviews!predict(get_presigned_url('@inference_stage', relative_path), 1) as json_content
   from directory(@inference_stage)
 )
 select
   file_name,
   file_size,
   last_modified,
   snowflake_file_url,
   json_content:__documentMetadata.ocrScore::FLOAT AS ocrScore,
   f.value:score::FLOAT AS inspection_date_score,
   f.value:value::STRING AS inspection_date_value,
   g.value:score::FLOAT AS inspection_grade_score,
   g.value:value::STRING AS inspection_grade_value,
   i.value:score::FLOAT AS inspector_score,
   i.value:value::STRING AS inspector_value,
   array_to_string(array_agg(j.value:value::STRING), ', ') AS list_of_units
 from temp,
   lateral flatten(input => json_content:inspection_date) f,
   lateral flatten(input => json_content:inspection_grade) g,
   lateral flatten(input => json_content:inspector) i,
   lateral flatten(input => json_content:list_of_units) j
group by all
);

select *
    from inspection_results;