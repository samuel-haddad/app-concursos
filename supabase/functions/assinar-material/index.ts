// Edge Function: assina uma URL temporária (GET) para um objeto no Cloudflare R2.
// Exige usuário autenticado (verify_jwt) — o conteúdo é privado.
//
// Secrets necessários (defina no Supabase):
//   R2_ACCOUNT_ID, R2_ACCESS_KEY_ID, R2_SECRET_ACCESS_KEY, R2_BUCKET
// (SUPABASE_URL e SUPABASE_ANON_KEY já são injetados automaticamente.)

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { AwsClient } from 'https://esm.sh/aws4fetch@1.0.20';

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

const EXPIRA = 3600; // segundos

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors });
  try {
    const authHeader = req.headers.get('Authorization') ?? '';
    const supa = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      { global: { headers: { Authorization: authHeader } } },
    );
    const { data: { user } } = await supa.auth.getUser();
    if (!user) {
      return new Response(JSON.stringify({ error: 'nao_autenticado' }), {
        status: 401, headers: { ...cors, 'Content-Type': 'application/json' },
      });
    }

    const { key } = await req.json();
    if (!key || typeof key !== 'string') {
      return new Response(JSON.stringify({ error: 'key_ausente' }), {
        status: 400, headers: { ...cors, 'Content-Type': 'application/json' },
      });
    }

    const account = Deno.env.get('R2_ACCOUNT_ID')!;
    const bucket = Deno.env.get('R2_BUCKET')!;
    const client = new AwsClient({
      accessKeyId: Deno.env.get('R2_ACCESS_KEY_ID')!,
      secretAccessKey: Deno.env.get('R2_SECRET_ACCESS_KEY')!,
      service: 's3',
      region: 'auto',
    });

    const encKey = key.split('/').map(encodeURIComponent).join('/');
    const endpoint =
      `https://${account}.r2.cloudflarestorage.com/${bucket}/${encKey}?X-Amz-Expires=${EXPIRA}`;
    const signed = await client.sign(endpoint, { method: 'GET', aws: { signQuery: true } });

    return new Response(JSON.stringify({ url: signed.url, expira: EXPIRA }), {
      headers: { ...cors, 'Content-Type': 'application/json' },
    });
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500, headers: { ...cors, 'Content-Type': 'application/json' },
    });
  }
});
