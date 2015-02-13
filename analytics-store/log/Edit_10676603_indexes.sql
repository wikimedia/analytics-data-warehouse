-- This script creates indexes for EventLogging Edit_10676603 table
-- to speed up scheduled queries, including funnel data extraction.
-- See related task: https://phabricator.wikimedia.org/T89256.

CREATE INDEX ix_Edit_10676603_event_action
    ON Edit_10676603 (event_action)
 USING HASH;

CREATE INDEX ix_Edit_10676603_event_editingSessionId
    ON Edit_10676603 (event_editingSessionId)
 USING HASH;
