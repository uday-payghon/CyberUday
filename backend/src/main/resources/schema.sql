create table if not exists verification_audit_trail (
    verification_id uuid primary key,
    user_id varchar(80) not null,
    encrypted_account text not null,
    encrypted_pan text not null,
    bank_match_score double precision not null,
    pan_match_score double precision not null,
    match_score double precision not null,
    status varchar(32) not null,
    bank_status varchar(16) not null,
    pan_status varchar(16) not null,
    created_at timestamptz not null
);

create index if not exists idx_verification_audit_user_id_created_at
    on verification_audit_trail (user_id, created_at desc);

create table if not exists api_key_metadata (
    id uuid primary key,
    owner_name varchar(120) not null,
    organization_type varchar(24) not null,
    hashed_key varchar(64) not null unique,
    prefix varchar(24) not null unique,
    status varchar(16) not null,
    created_at timestamptz not null,
    expires_at timestamptz not null
);

create index if not exists idx_api_key_metadata_prefix_status
    on api_key_metadata (prefix, status);

create table if not exists cyber_news_items (
    news_id uuid primary key,
    headline varchar(180) not null,
    summary varchar(1200) not null,
    source_url varchar(500) not null,
    image_url varchar(500) not null,
    severity_tag varchar(16) not null,
    category varchar(80) not null,
    published_date timestamptz not null
);

create index if not exists idx_cyber_news_items_published_date
    on cyber_news_items (published_date desc);
