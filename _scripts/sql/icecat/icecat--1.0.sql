-- ICECAT 1.0

/* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  */
/**
    Icecat Language Code
 */
do
$$
    begin
        perform '"IceCatLang"'::regtype;
    exception
        when undefined_object then
            create type "IceCatLang" as enum
                ('EN', 'NL', 'FR', 'DE', 'IT', 'ES', 'DK', 'RU', 'US', 'BR', 'PT',
                    'ZH', 'SV', 'PL', 'CZ', 'HU', 'FI', 'EL', 'NO', 'TR', 'BG',
                    'KA', 'RO', 'SR', 'UK', 'JA', 'CA', 'ES_AR', 'HR', 'AR', 'VI',
                    'KO', 'MK', 'SL', 'EN_SG', 'EN_ZA', 'ZH_TW', 'HE', 'LT', 'LV',
                    'EN_IN', 'DE_CH', 'ID', 'SK', 'FA', 'ES_MX', 'ET', 'DE_BE',
                    'FR_BE', 'NL_BE', 'TH', 'RU_UA', 'DE_AT', 'FR_CH', 'EN_NZ',
                    'EN_SA', 'EN_ID', 'EN_MY', 'HI', 'FR_CA', 'TE', 'TA', 'KN',
                    'EN_IE', 'ML', 'EN_AE', 'ES_CL', 'ES_PE', 'ES_CO', 'MR',
                    'BN', 'MS', 'EN_AU', 'IT_CH', 'EN_PH', 'FL_PH', 'EN_CA',
                    'EN_EG', 'AR_EG', 'AR_SA');
    end
$$;
comment on type "IceCatLang" is 'IceCat Language Code';
grant usage on type "IceCatLang" to public;

/* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  */
/**
    Resolves Icecat Language Code
 */
create or replace function "resolveLangCode"(in "inLangCode" varchar(5))
    returns "IceCatLang"
    strict
    language plpgsql
    immutable
    security definer
as
$fun$
begin
    return (upper(trim("inLangCode")))::"IceCatLang";
exception
    when others then
        return null::"IceCatLang";
end;
$fun$;
comment on function "resolveLangCode"(varchar) is 'Resolves Icecat Language Code';

/* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  */
/**
    Extracts timestamp from uuid
 */
create or replace function "uuidExtractDate"(in "inValue" uuid)
    returns date
    strict
    language plpgsql
    immutable
    security definer
as
$fun$
begin
    return uuid_extract_timestamp("inValue")::date;
exception
    when others then
        return null;
end;
$fun$;
grant execute on function "uuidExtractDate"(uuid) to public;
comment on function "uuidExtractDate"(uuid) is 'Extracts timestamp from uuid';

/* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  */
/**
    Checks whether given json data is valid object
 */
create or replace function "isJsonObjectEmpty"(in "inJson" jsonb)
    returns boolean
    immutable
    language sql
as
$fun$
select "inJson" is null or "inJson" = '{}'::jsonb or jsonb_strip_nulls("inJson") = '{}'::jsonb
$fun$;
grant execute on function "isJsonObjectEmpty"(jsonb) to public;
comment on function "isJsonObjectEmpty"(jsonb) is 'Checks whether given json data is non empty object';

/* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  */
/**
    Extracts days old from uuid
 */
create or replace function "extractDaysAgo"(in "inValue" uuid)
    returns bigint
    language plpgsql
    immutable
    security definer
as
$fun$
begin
    return (current_date - coalesce("uuidExtractDate"("inValue"), current_date))::bigint;
exception
    when others then
        return -1;
end;
$fun$;
grant execute on function "extractDaysAgo"(uuid) to public;
comment on function "extractDaysAgo"(uuid) is 'Extracts days old from uuid';

/* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  */
/**
    IceCat Products Meta
 */
create table if not exists "IceCatProductsMeta"
(
    "prdUUID"        uuid           default uuidv7() not null,
    "prdMetaVersion" uuid  not null default uuidv7()
        constraint "pkIceCatProducts" primary key,
    "prdID"          bigint         default 0 not null
        constraint "uxIceCatProductNumber" unique,
    "prdMeta"        jsonb not null default '{}'::jsonb
        constraint "chkIsPrdMetaObject" check (jsonb_typeof("prdMeta") = 'object'),
    "isMetaEmpty"    boolean generated always as ("isJsonObjectEmpty"("prdMeta")) stored
);
comment on table "IceCatProductsMeta" is 'Icecat Products Meta';
comment on column "IceCatProductsMeta"."prdUUID" is 'Product UUID';
comment on column "IceCatProductsMeta"."prdID" is 'Product ID';
comment on column "IceCatProductsMeta"."prdMeta" is 'IceCata product metadata';
comment on column "IceCatProductsMeta"."prdMetaVersion" is 'Version identifier';
comment on column "IceCatProductsMeta"."isMetaEmpty" is 'TRUE if data is empty';

/* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  */
/**
    IceCat Product Data.
    Supports multilanguage storage of product data.
 */
create table if not exists "IceCatProductsData"
(
    "prdUUID"        uuid         not null,
    "prdDataVersion" uuid         not null default uuidv7(),
    "prdLang"        "IceCatLang" not null default 'EN'::"IceCatLang",
    "prdData"        jsonb                 default '{}'::jsonb
        constraint "chkIsPrdDataObject" check (jsonb_typeof("prdData") = 'object'),
    "isDataEmpty"    boolean generated always as ( "isJsonObjectEmpty"("prdData")) stored
);
comment on table "IceCatProductsData" is 'Icecat Products Data';
comment on column "IceCatProductsData"."prdUUID" is 'Product UUID';
comment on column "IceCatProductsData"."prdLang" is 'Language of record';
comment on column "IceCatProductsData"."prdData" is 'Product data';
comment on column "IceCatProductsData"."prdDataVersion" is 'Version identifier';
comment on column "IceCatProductsData"."isDataEmpty" is 'TRUE if data is empty';

/* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  */
/**
    Saves IceCat Product Meta (single record).
 */
create or replace function "saveIceCatProductMeta"(in "inProductId" bigint, in "inMeta" jsonb)
    returns uuid
    language plpgsql
    volatile
    security definer
as
$fun$
declare
    "sanData"     jsonb := jsonb_strip_nulls(coalesce("inMeta", '{}'::jsonb));
    "outPrdUUUID" uuid;
begin
    if "inProductId" is null then
        raise exception 'Product ID cannot be null';
    end if;
    if "isJsonObjectEmpty"("sanData") then
        "sanData" = '{}'::jsonb;
    end if;
    insert into "IceCatProductsMeta" ("prdID", "prdMeta")
    values ("inProductId", "sanData")
    on conflict ("prdID") do update
        set "prdMeta" = excluded."prdMeta", "prdMetaVersion" = uuidv7()
    returning "prdUUID" into "outPrdUUUID";
    return "outPrdUUUID";
end;
$fun$;
comment on function "saveIceCatProductMeta"(bigint, jsonb) is 'Stores IceCat Product Meta (single record)';

/* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  */
/**
    Saves IceCat Product Meta (single record).
 */
create or replace function "saveIceCatProductData"(in "inProductUUID" uuid, in "inData" jsonb)
    returns uuid
    language plpgsql
    volatile
    security definer
as
$fun$
declare
    "sanData"     jsonb        := jsonb_strip_nulls(coalesce("inData", '{}'::jsonb));
    "langCode"    "IceCatLang" := 'EN'::"IceCatLang";
    "outPrdUUUID" uuid;
begin
    if "inProductUUID" is null then
        raise exception 'Product UUID cannot be null';
    end if;
    if "isJsonObjectEmpty"("sanData") then
        "sanData" = '{}'::jsonb;
    end if;
    "langCode" = 'EN'::"IceCatLang";
    insert into "IceCatProductsData" ("prdUUID", "prdData")
    values ("IceCatProductsData"."prdUUID", "sanData")
    on conflict ("prdUUID") do update
        set "prdData" = excluded."prdData", "prdDataVersion" = uuidv7()
    returning "prdUUID" into "outPrdUUUID";
    return "outPrdUUUID";
end;
$fun$;
comment on function "saveIceCatProductData"(uuid, jsonb) is 'Stores IceCat Product Meta (single record)';

/* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  */
/**
    Number of IceCat Product Meta records
 */
create or replace function "countIceCatMeta"()
    returns bigint
    language sql
    stable
    security definer
    parallel safe
as
$fun$
select
    count(*)
from "IceCatProductsMeta";
$fun$;
comment on function "countIceCatMeta"() is 'Number of IceCat Product Meta records';

/**
    Number of IceCat Product Data records
 */
create or replace function "countIceCatData"()
    returns bigint
    language sql
    stable
    security definer
    parallel safe
as
$fun$
select
    count(*)
from "IceCatProductsData";
$fun$;
alter function "countIceCatData"() owner to postgres;
grant execute on function "countIceCatData"() to dbu_storage;
comment on function "countIceCatData"() is 'Number of IceCat Product Data records';

/**
    Number of IceCat Product Data records by language code
 */
create or replace function "countIceCatDataByLang"(in "inLangCode" varchar(5))
    returns bigint
    language sql
    stable
    security definer
    parallel safe
as
$fun$
select
    count(*)
from "IceCatProductsData"
where
    "prdLang" = "resolveLangCode"("inLangCode");
$fun$;
alter function "countIceCatDataByLang"(varchar) owner to postgres;
grant execute on function "countIceCatDataByLang"(varchar) to dbu_storage;
comment on function "countIceCatDataByLang"(varchar) is 'Number of IceCat Product Data records by language code';


/* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  */
/**
    Number of outdated IceCat Product Meta records.
 */
create or replace function "countIceCatMetaOutdated"(in "expireDays" bigint default 30)
    returns bigint
    language sql
    stable
    security definer
    parallel safe
as
$fun$
select
    count(*)
from "IceCatProductsMeta"
where
    "extractDaysAgo"("prdMetaVersion") > abs(coalesce("expireDays", 0)) ;
$fun$;
comment on function "countIceCatMetaOutdated"(bigint) is 'Number of outdated IceCat Product Meta records';

/* -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  */
/**
    Number of outdated IceCat Product Data records.
 */
create or replace function "countIceCatDataOutdated"(in "expireDays" bigint default 30)
    returns bigint
    language sql
    stable
    security definer
    parallel safe
as
$fun$
select
    count(*)
from "IceCatProductsData"
where
    "extractDaysAgo"("prdDataVersion") > abs(coalesce("expireDays", 0)) ;
$fun$;
comment on function "countIceCatDataOutdated"(bigint) is 'Number of outdated IceCat Product Data records';

