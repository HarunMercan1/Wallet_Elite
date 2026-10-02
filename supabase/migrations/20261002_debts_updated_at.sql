-- Migration: Align live debts table with 20260111_create_debts_table.sql
-- Created: 2026-10-02
-- Description: Repodaki debts migration'ı updated_at kolonu ve trigger'ı
-- tanımlıyordu, canlı tabloda yoktu. Canlıyı repoyla eşitler.

ALTER TABLE public.debts
  ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now();

CREATE OR REPLACE FUNCTION public.update_debts_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trigger_update_debts_updated_at ON public.debts;
CREATE TRIGGER trigger_update_debts_updated_at
  BEFORE UPDATE ON public.debts
  FOR EACH ROW
  EXECUTE FUNCTION public.update_debts_updated_at();
