create table message (
    id serial primary key,
    sender text not null,
    target text not null,
    contents text not null
);
