-- ============================================================
-- Migration: Change user_id from INT to VARCHAR(50) everywhere
-- Run this against the production database
-- ============================================================

ALTER TABLE community_posts           MODIFY user_id VARCHAR(50) NOT NULL;
ALTER TABLE community_post_likes      MODIFY user_id VARCHAR(50) NOT NULL;
ALTER TABLE community_comments        MODIFY user_id VARCHAR(50) NOT NULL;
ALTER TABLE community_comment_replies MODIFY user_id VARCHAR(50) NOT NULL;
ALTER TABLE community_notifications   MODIFY user_id VARCHAR(50) NOT NULL;
ALTER TABLE community_notifications   MODIFY from_user_id VARCHAR(50) NOT NULL;
ALTER TABLE community_reports         MODIFY user_id VARCHAR(50) NOT NULL;