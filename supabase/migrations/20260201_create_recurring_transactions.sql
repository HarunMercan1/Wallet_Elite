-- Migration: Create recurring_transactions table
-- Created: 2026-02-01
-- Description: Tekrarlayan işlemler için tablo (maaş, fatura vb.)

-- Create recurring_transactions table
CREATE TABLE IF NOT EXISTS recurring_transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  amount DECIMAL(12, 2) NOT NULL CHECK (amount > 0),
  type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
  description TEXT,
  frequency TEXT NOT NULL CHECK (frequency IN ('daily', 'weekly', 'monthly', 'yearly')),
  day_of_month INT CHECK (day_of_month >= 1 AND day_of_month <= 31),
  day_of_week INT CHECK (day_of_week >= 0 AND day_of_week <= 6),
  start_date DATE NOT NULL,
  end_date DATE,
  next_execution_date DATE NOT NULL,
  last_execution_date DATE,
  is_active BOOLEAN DEFAULT TRUE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_recurring_user_id ON recurring_transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_recurring_next_exec ON recurring_transactions(next_execution_date) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_recurring_active ON recurring_transactions(user_id, is_active);

-- Enable Row Level Security
ALTER TABLE recurring_transactions ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view their own recurring transactions"
  ON recurring_transactions
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own recurring transactions"
  ON recurring_transactions
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own recurring transactions"
  ON recurring_transactions
  FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own recurring transactions"
  ON recurring_transactions
  FOR DELETE
  USING (auth.uid() = user_id);

-- Trigger for updated_at
CREATE OR REPLACE FUNCTION update_recurring_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_recurring_updated_at ON recurring_transactions;
CREATE TRIGGER trigger_update_recurring_updated_at
  BEFORE UPDATE ON recurring_transactions
  FOR EACH ROW
  EXECUTE FUNCTION update_recurring_updated_at();

-- Comments
COMMENT ON TABLE recurring_transactions IS 'Stores recurring transaction templates (salary, bills, subscriptions)';
COMMENT ON COLUMN recurring_transactions.frequency IS 'Frequency: daily, weekly, monthly, yearly';
COMMENT ON COLUMN recurring_transactions.day_of_month IS 'For monthly: which day (1-31)';
COMMENT ON COLUMN recurring_transactions.day_of_week IS 'For weekly: which day (0=Sunday, 6=Saturday)';
COMMENT ON COLUMN recurring_transactions.next_execution_date IS 'Next date when transaction should be created';
