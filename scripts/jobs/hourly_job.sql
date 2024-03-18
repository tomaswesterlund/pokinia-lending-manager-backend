create or replace function hourly_job()
returns void as $$
declare
	loan_statement_record RECORD;
	loan_record RECORD;
	client_record RECORD;
begin
    PERFORM create_info_log_entry('hourly_job', 'start');
   
   -- Run over all loan statements
   FOR loan_statement_record IN SELECT id FROM loan_statements loop
	   	PERFORM create_debug_log_entry('hourly_job', 'loan_statement_record.id: ' || loan_statement_record.id);
        PERFORM calculate_loan_statement_values(loan_statement_record.id);
    END LOOP;
   
   -- Run over all loans
   FOR loan_record IN SELECT id FROM loans loop
		PERFORM create_debug_log_entry('hourly_job', 'loan_record.id: ' || loan_record.id);
        PERFORM calculate_loan_values(loan_record.id);
    END LOOP;
   
   -- Run over all clients
   FOR client_record IN SELECT id FROM clients loop
		PERFORM create_debug_log_entry('hourly_job', 'client_record.id: ' || client_record.id);
        PERFORM calculate_client_values(client_record.id);
    END LOOP;
   
   perform create_info_log_entry('hourly_job', 'end');
end;
$$ LANGUAGE plpgsql;