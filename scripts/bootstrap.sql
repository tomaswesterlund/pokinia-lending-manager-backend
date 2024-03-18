CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Set schedules
SELECT cron.schedule('schedule_hourly_job', '0 * * * *', $$ select hourly_job()$$);
