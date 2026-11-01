-- Migration: Tambah tabel notifications untuk notifikasi distribusi ompreng MBG
-- Pengguna lama tidak terpengaruh (tabel baru, tidak mengubah kolom yang ada).

BEGIN;

CREATE TABLE IF NOT EXISTS public.notifications (
  id          UUID        NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id     UUID        NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  title       TEXT        NOT NULL,
  body        TEXT        NOT NULL,
  type        TEXT        NOT NULL DEFAULT 'distribution',
  data        JSONB,
  is_read     BOOLEAN     NOT NULL DEFAULT FALSE,
  created_at  TIMESTAMP(3) NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notif_user_read
  ON public.notifications(user_id, is_read);

COMMIT;

