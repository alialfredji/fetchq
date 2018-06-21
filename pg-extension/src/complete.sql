
DROP FUNCTION IF EXISTS fetchq_complete(CHARACTER VARYING, INTEGER);
CREATE OR REPLACE FUNCTION fetchq_complete (
	PAR_queue VARCHAR,
	PAR_docId INTEGER,
	OUT affected_rows INTEGER
) AS $$
DECLARE
	VAR_table_name VARCHAR = 'fetchq_';
	VAR_q VARCHAR;
BEGIN
	VAR_q = 'WITH fetchq_complete_lock_%s AS ( ';
	VAR_q = VAR_q || 'UPDATE fetchq__%s__documents AS lc SET ';
    VAR_q = VAR_q || 'status = 3,';
    VAR_q = VAR_q || 'attempts = 0,';
    VAR_q = VAR_q || 'iterations = lc.iterations + 1,';
    VAR_q = VAR_q || 'last_iteration = NOW(),';
    VAR_q = VAR_q || 'next_iteration = ''2970-01-01 00:00:00+00'' ';
	VAR_q = VAR_q || 'WHERE id IN ( SELECT id FROM fetchq__%s__documents WHERE id = %s AND status = 2 LIMIT 1 ) RETURNING version) ';
	VAR_q = VAR_q || 'SELECT version FROM fetchq_complete_lock_%s LIMIT 1;';
	VAR_q = FORMAT(VAR_q, PAR_queue, PAR_queue, PAR_queue, PAR_docId, PAR_queue);

	EXECUTE VAR_q;
	GET DIAGNOSTICS affected_rows := ROW_COUNT;

	-- Update counters
	IF affected_rows > 0 THEN
		PERFORM fetchq_metric_log_increment(PAR_queue, 'prc', affected_rows);
		PERFORM fetchq_metric_log_increment(PAR_queue, 'cpl', affected_rows);
		PERFORM fetchq_metric_log_decrement(PAR_queue, 'act', affected_rows);
	END IF;

	EXCEPTION WHEN OTHERS THEN BEGIN END;
END; $$
LANGUAGE plpgsql;


DROP FUNCTION IF EXISTS fetchq_complete(CHARACTER VARYING, INTEGER, JSONB);
CREATE OR REPLACE FUNCTION fetchq_complete (
	PAR_queue VARCHAR,
	PAR_docId INTEGER,
	PAR_payload JSONB,
	OUT affected_rows INTEGER
) AS $$
DECLARE
	VAR_table_name VARCHAR = 'fetchq_';
	VAR_q VARCHAR;
BEGIN
	VAR_q = 'WITH fetchq_complete_lock_%s AS ( ';
	VAR_q = VAR_q || 'UPDATE fetchq__%s__documents AS lc SET ';
	VAR_q = VAR_q || 'payload = ''%s'',';
    VAR_q = VAR_q || 'status = 3,';
    VAR_q = VAR_q || 'attempts = 0,';
    VAR_q = VAR_q || 'iterations = lc.iterations + 1,';
    VAR_q = VAR_q || 'last_iteration = NOW(),';
    VAR_q = VAR_q || 'next_iteration = ''2970-01-01 00:00:00+00'' ';
	VAR_q = VAR_q || 'WHERE id IN ( SELECT id FROM fetchq__%s__documents WHERE id = %s AND status = 2 LIMIT 1 ) RETURNING version) ';
	VAR_q = VAR_q || 'SELECT version FROM fetchq_complete_lock_%s LIMIT 1;';
	VAR_q = FORMAT(VAR_q, PAR_queue, PAR_queue, PAR_payload, PAR_queue, PAR_docId, PAR_queue);

	EXECUTE VAR_q;
	GET DIAGNOSTICS affected_rows := ROW_COUNT;

	-- Update counters
	IF affected_rows > 0 THEN
		PERFORM fetchq_metric_log_increment(PAR_queue, 'prc', affected_rows);
		PERFORM fetchq_metric_log_increment(PAR_queue, 'cpl', affected_rows);
		PERFORM fetchq_metric_log_decrement(PAR_queue, 'act', affected_rows);
	END IF;

--	EXCEPTION WHEN OTHERS THEN BEGIN END;
END; $$
LANGUAGE plpgsql;
