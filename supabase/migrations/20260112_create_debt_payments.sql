-- Create debt_payments table
CREATE TABLE IF NOT EXISTS debt_payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  debt_id UUID NOT NULL REFERENCES debts(id) ON DELETE CASCADE,
  amount DECIMAL(12, 2) NOT NULL CHECK (amount > 0),
  payment_date TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_debt_payments_debt_id ON debt_payments(debt_id);
CREATE INDEX IF NOT EXISTS idx_debt_payments_date ON debt_payments(payment_date DESC);

-- Enable RLS
ALTER TABLE debt_payments ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Users can view payments for debts they own
CREATE POLICY "Users can view their own debt payments"
  ON debt_payments
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM debts
      WHERE debts.id = debt_payments.debt_id
      AND debts.user_id = auth.uid()
    )
  );

-- Users can insert payments for debts they own
CREATE POLICY "Users can insert their own debt payments"
  ON debt_payments
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM debts
      WHERE debts.id = debt_payments.debt_id
      AND debts.user_id = auth.uid()
    )
  );

-- Helper comments
COMMENT ON TABLE debt_payments IS 'Tracks individual payment history for debts';
