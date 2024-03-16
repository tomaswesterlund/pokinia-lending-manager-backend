CREATE OR REPLACE FUNCTION check_loan_statement_exists(loan_statement_id UUID)
RETURNS void AS $$
DECLARE
    v_id UUID;
BEGIN
    -- Attempt to select the ID from loan_statements
    SELECT id INTO v_id FROM loan_statements WHERE id = loan_statement_id;
    
    -- Check if the SELECT statement found a row
    IF NOT FOUND THEN
        perform create_exception_log_entry('check_loan_statement_exists', 'Loan statement with ID ' || loan_statement_id || ' not found.');
        RAISE EXCEPTION 'Loan statement with ID % not found.', loan_statement_id;
    END IF;
END;
$$ LANGUAGE plpgsql;