
-----123----
CREATE TABLE IF NOT EXISTS "status" (
    "userId" integer,
    "statusId" integer,
    "status" text,
    "createTime" text DEFAULT (dateTime('now','localTime')),
    PRIMARY KEY ("userId", "statusId")
);
