{{ config(materialized='ephemeral') }}

-- use CTE's to generate the staging schema
WITH

-- incoming data
src_data as (
    SELECT
        ACCOUNTID           as ACCOUNT_CODE     -- TEXT
        , SYMBOL            as SECURITY_CODE    -- TEXT
        , DESCRIPTION       as SECURITY_NAME    -- TEXT
        , EXCHANGE          as EXCHANGE_CODE    -- TEXT
        , {{ to_21st_century_date('REPORT_DATE') }}        
                            as REPORT_DATE      -- DATE
        , QUANTITY          as QUANTITY         -- NUMBER
        , COST_BASE         as COST_BASE        -- NUMBER
        , POSITION_VALUE    as POSITION_VALUE   -- NUMBER
        , CURRENCY          as CURRENCY_CODE    -- TEXT

        , 'SOURCE_DATA.ABC_BANK_POSITION' as RECORD_SOURCE

    FROM {{ source('abc_bank', 'ABC_BANK_POSITION') }}
),

-- add support for saving history
hashed as (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['ACCOUNT_CODE', 'SECURITY_CODE']) }} AS POSITION_HKEY
        , {{ dbt_utils.generate_surrogate_key(['ACCOUNT_CODE', 'SECURITY_CODE', 'SECURITY_NAME',
                    'EXCHANGE_CODE', 'REPORT_DATE', 'QUANTITY', 'COST_BASE',
                    'POSITION_VALUE', 'CURRENCY_CODE']) }} AS POSITION_HDIFF
        , *
        , '{{ run_started_at }}' AS LOAD_TS_UTC
    FROM src_data
)

SELECT * FROM hashed

