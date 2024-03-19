CREATE OR REPLACE FUNCTION check_loan_exists(loan_id UUID)
RETURNS void AS $$
DECLARE
    v_id UUID;
BEGIN
    -- Attempt to select the ID from loans
    SELECT id INTO v_id FROM loans WHERE id = loan_id;
    
    -- Check if the SELECT found a row
    IF NOT FOUND THEN
        perform create_exception_log_entry('check_loan_exists', 'Loan with ID ' || loan_id || ' not found.');
        RAISE EXCEPTION 'Loan with ID % not found.', loan_id;
    END IF;
END;
$$ LANGUAGE plpgsql;