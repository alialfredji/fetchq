
DROP FUNCTION IF EXISTS fetchq_drop(character varying, integer);
CREATE OR REPLACE FUNCTION fetchq_drop (
	PAR_queue VARCHAR,
	PAR_docId INTEGER,
	OUT affected_rows INTEGER
) AS $$
DECLARE
	VAR_q VARCHAR;
	VAR_version INTEGER;
BEGIN

	VAR_q = 'DELETE FROM fetchq__%s__documents WHERE id = %s AND status = 2 RETURNING version;';
	VAR_q = FORMAT(VAR_q, PAR_queue, PAR_docId);

	EXECUTE VAR_q INTO VAR_version;
	GET DIAGNOSTICS affected_rows := ROW_COUNT;
	-- raise log '% %', VAR_version, affected_rows;

	-- Update counters
	IF affected_rows > 0 THEN
		PERFORM fetchq_metric_log_increment(PAR_queue, 'prc', affected_rows);
		PERFORM fetchq_metric_log_increment(PAR_queue, 'drp', affected_rows);
		PERFORM fetchq_metric_log_decrement(PAR_queue, 'act', affected_rows);
		PERFORM fetchq_metric_log_decrement(PAR_queue, 'cnt', affected_rows);
		PERFORM fetchq_metric_log_decrement(PAR_queue, 'v' || VAR_version::text, affected_rows);
	END IF;

--	EXCEPTION WHEN OTHERS THEN BEGIN END;
END; $$
LANGUAGE plpgsql;
