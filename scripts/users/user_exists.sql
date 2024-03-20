CREATE OR REPLACE FUNCTION user_exists(v_user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS(
    SELECT 1 FROM users WHERE id = v_user_id
  );
END;
$$ LANGUAGE plpgsql;
