{{ config(materialized='ephemeral') }}

WITH
src_data as (
        SELECT
            ID              as EXCHANGE_CODE,           -- TEXT
            NAME            as EXCHANGE_NAME,           -- TEXT
            COUNTRY         as EXCHANGE_COUNTRY,        -- TEXT
            CITY            as EXCHANGE_CITY,           -- TEXT
            ZONE            as EXCHANGE_TIME_ZONE,      -- TEXT
            DELTA           as EXCHANGE_DELTA,          -- NUMBER
            DST_PERIOD      as EXCHANGE_DST_PERIOD,     -- TEXT
            OPEN            as EXCHANGE_OPEN,           -- TEXT
            CLOSE           as EXCHANGE_CLOSE,          -- TEXT
            LUNCH           as EXCHANGE_LUNCH,          -- TEXT
            OPEN_UTC        as EXCHANGE_OPEN_UTC,       -- TEXT
            CLOSE_UTC       as EXCHANGE_CLOSE_UTC,      -- TEXT
            LUNCH_UTC       as EXCHANGE_LUNCH_UTC,      -- TEXT
            LOAD_TS         as LOAD_TS,                  -- TIMESTAMP_NTZ
            'SEED.EXCHANGE_INFO' as RECORD_SOURCE

        FROM {{ source('seeds', 'EXCHANGE_INFO') }}         

),

default_record as (
    SELECT
        '-1'        as EXCHANGE_CODE,
        'Missing'   as EXCHANGE_NAME,
        'Missing'   as EXCHANGE_COUNTRY,
        'Missing'   as EXCHANGE_CITY,
        'Missing'   as EXCHANGE_TIME_ZONE,
        '0'         as EXCHANGE_DELTA,
        'Missing'   as EXCHANGE_DST_PERIOD,
        'Missing'   as EXCHANGE_OPEN,
        'Missing'   as EXCHANGE_CLOSE,
        'Missing'   as EXCHANGE_LUNCH,
        'Missing'   as EXCHANGE_OPEN_UTC,
        'Missing'   as EXCHANGE_CLOSE_UTC,
        'Missing'   as EXCHANGE_LUNCH_UTC,
        '2020-01-01'        as LOAD_TS_UTC,
        'System.DefaultKey' as RECORD_SOURCE
),

with_default_record as (
    SELECT * FROM src_data
    UNION ALL
    SELECT * FROM default_record
),

hashed as (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['EXCHANGE_CODE']) }} as EXCHANGE_HKEY,
        {{ dbt_utils.generate_surrogate_key(['EXCHANGE_CODE',
                       'EXCHANGE_NAME', 'EXCHANGE_COUNTRY',
                       'EXCHANGE_CITY', 'EXCHANGE_TIME_ZONE',
                       'EXCHANGE_DELTA', 'EXCHANGE_DST_PERIOD',
                       'EXCHANGE_OPEN', 'EXCHANGE_CLOSE',
                       'EXCHANGE_LUNCH', 'EXCHANGE_OPEN_UTC',
                       'EXCHANGE_CLOSE_UTC', 'EXCHANGE_LUNCH_UTC']) }} as EXCHANGE_HDIFF,
        * EXCLUDE LOAD_TS,
        LOAD_TS as LOAD_TS_UTC
    FROM with_default_record
)

SELECT * FROM hashed
