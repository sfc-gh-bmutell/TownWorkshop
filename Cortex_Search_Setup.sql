use role sysadmin;

use schema tog_workshop.fireworks;

use warehouse tog_workshop_vwh;

create or replace stage tog_workshop.fireworks.docs
    directory = (enable = TRUE)
    encryption = (type = 'SNOWFLAKE_SSE');

create or replace table tog_workshop.fireworks.parse_chunk_final (
      relative_path VARCHAR
    , scoped_file_url VARCHAR
    , chunk VARCHAR
    , category VARCHAR
    , language VARCHAR
    );
    

create or replace table tog_workshop.fireworks.parse_chunk_pre as 
    select 
        relative_path
        ,get_presigned_url( @tog_workshop.fireworks.docs, relative_path) as scoped_file_url
        ,snowflake.cortex.split_text_recursive_character
            (
                to_variant(snowflake.cortex.parse_document --text_to_split
                    (
                        @tog_workshop.fireworks.docs,
                        relative_path,
                        {'mode': 'LAYOUT'}
                    )):content, 
                'MARKDOWN', --format
                756, --chunk_size (can adjust to optimize results.)
                128 --overlap (can adjust to optimize results.)
            ) as chunks,
            'Fireworks' as category,
        'English' as language 
    from directory(@tog_workshop.fireworks.docs);

select *
    from tog_workshop.fireworks.parse_chunk_pre;


insert into parse_chunk_final (relative_path,  scoped_file_url, chunk, category, language)
    select  
        relative_path, 
        scoped_file_url, 
        c.value as chunk,
        category,    
        language
    from 
        tog_workshop.fireworks.parse_chunk_pre AS p, 
        lateral flatten(input => p.chunks) c;

select * 
    from tog_workshop.fireworks.parse_chunk_final;


create or replace cortex search service tog_workshop.fireworks.fireworks_cortex_search
    on chunk
    attributes language
    warehouse = tog_workshop_vwh
    target_lag = '1 hour'
    as (
    select
        chunk,
        relative_path,
        scoped_file_url, 
        language, 
        category
    from tog_workshop.fireworks.parse_chunk_final
    );

