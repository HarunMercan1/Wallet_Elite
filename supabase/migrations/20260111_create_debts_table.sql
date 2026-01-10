-- Migration: Create debts table for debt tracking feature
-- Created: 2026-01-11

-- Create debts table
CREATE TABLE IF NOT EXISTS debts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  person_name TEXT NOT NULL,
  amount DECIMAL(12, 2) NOT NULL CHECK (amount > 0),
  remaining_amount DECIMAL(12, 2) NOT NULL CHECK (remaining_amount >= 0),
  due_date TIMESTAMPTZ,
  type TEXT NOT NULL CHECK (type IN ('lend', 'borrow')),
  is_completed BOOLEAN DEFAULT FALSE NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_debts_user_id ON debts(user_id);
CREATE INDEX IF NOT EXISTS idx_debts_type ON debts(type);
CREATE INDEX IF NOT EXISTS idx_debts_due_date ON debts(due_date) WHERE due_date IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_debts_is_completed ON debts(is_completed);
CREATE INDEX IF NOT EXISTS idx_debts_created_at ON debts(created_at DESC);

-- Composite index for common queries
CREATE INDEX IF NOT EXISTS idx_debts_user_type_completed 
  ON debts(user_id, type, is_completed);

-- Enable Row Level Security
ALTER TABLE debts ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Policy: Users can view their own debts
CREATE POLICY "Users can view their own debts"
  ON debts
  FOR SELECT
  USING (auth.uid() = user_id);

-- Policy: Users can insert their own debts
CREATE POLICY "Users can insert their own debts"
  ON debts
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own debts
CREATE POLICY "Users can update their own debts"
  ON debts
  FOR UPDATE
  USING (auth.uid() = user_id);

-- Policy: Users can delete their own debts
CREATE POLICY "Users can delete their own debts"
  ON debts
  FOR DELETE
  USING (auth.uid() = user_id);

-- Create trigger function for updated_at
CREATE OR REPLACE FUNCTION update_debts_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
DROP TRIGGER IF EXISTS trigger_update_debts_updated_at ON debts;
CREATE TRIGGER trigger_update_debts_updated_at
  BEFORE UPDATE ON debts
  FOR EACH ROW
  EXECUTE FUNCTION update_debts_updated_at();

-- Add helpful comments
COMMENT ON TABLE debts IS 'Stores user debt and lend records with payment tracking';
COMMENT ON COLUMN debts.type IS 'Type of debt: lend (money given) or borrow (money received)';
COMMENT ON COLUMN debts.amount IS 'Original total amount of the debt';
COMMENT ON COLUMN debts.remaining_amount IS 'Remaining amount to be paid (decreases with payments)';
COMMENT ON COLUMN debts.is_completed IS 'Whether the debt has been fully paid or marked as completed';
