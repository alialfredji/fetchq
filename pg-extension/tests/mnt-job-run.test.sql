
CREATE OR REPLACE FUNCTION fetchq_test__mnt_job_run_01 (
    OUT passed BOOLEAN
) AS $$
DECLARE
    VAR_testName VARCHAR = 'IT SHOULD RUN MAINTENANCE JOBS FOR A QUEUE';
    VAR_r RECORD;
BEGIN
    
    -- initialize test
    PERFORM fetchq_test_init();
    PERFORM fetchq_queue_create('foo');
    PERFORM fetchq_doc_push('foo', 'a1', 0, 0, NOW() - INTERVAL '1s', '{}');
    -- PERFORM fetchq_metric_log_pack();
    UPDATE fetchq_sys_jobs SET next_iteration = NOW() - INTERVAL '1s';

    -- run the test
    SELECT * INTO VAR_r FROM fetchq_mnt_job_run(5);
    IF VAR_r.success IS NULL THEN
        RAISE EXCEPTION 'failed - %', VAR_testName;
    END IF;

    -- cleanup
    PERFORM fetchq_test_clean();
    passed = TRUE;
END; $$
LANGUAGE plpgsql;
