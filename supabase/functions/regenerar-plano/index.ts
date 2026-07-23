// Edge Function: regenera o plano de estudo do usuário autenticado a partir da
// sua disponibilidade atual (tabela `disponibilidade`).
//
// Preserva histórico: só reescreve `plano_dia` de D+1 em diante (dias passados
// ficam intactos) e NÃO toca em `licao_concluida` nem `sessao_realizada`.
// Lições já concluídas são removidas da fila (não reagendadas).
//
// Requer JWT (verify_jwt). Usa o token do usuário -> RLS aplica (dono + aprovado).

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { gerarPlano, type LicaoSeed } from "./gerador.ts";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });

/** data de hoje (YYYY-MM-DD) no fuso America/Sao_Paulo. */
function hojeSaoPaulo(): string {
  return new Intl.DateTimeFormat("en-CA", {
    timeZone: "America/Sao_Paulo",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).format(new Date());
}

function addDays(iso: string, n: number): string {
  const d = new Date(iso + "T00:00:00Z");
  d.setUTCDate(d.getUTCDate() + n);
  return d.toISOString().slice(0, 10);
}

const DISP_PADRAO = [60, 60, 60, 60, 60, 120, 120]; // 0=segunda .. 6=domingo

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  try {
    const authHeader = req.headers.get("Authorization") ?? "";
    const supa = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } },
    );

    const {
      data: { user },
    } = await supa.auth.getUser();
    if (!user) return json({ error: "nao_autenticado" }, 401);

    // --- carrega dados (RLS já restringe ao dono/aprovado) ---
    const [licRes, dispRes, concRes, concursoRes] = await Promise.all([
      supa.from("licao").select("licao_id,modulo_id,modulo,n_licao,estudo_min,weight"),
      supa.from("disponibilidade").select("dia_semana,minutos"),
      supa.from("licao_concluida").select("licao_id"),
      supa.from("concurso").select("data_prova").limit(1).single(),
    ]);

    if (licRes.error) return json({ error: "licao", detail: licRes.error.message }, 500);
    if (concursoRes.error) return json({ error: "concurso", detail: concursoRes.error.message }, 500);

    const licoes = (licRes.data ?? []) as LicaoSeed[];

    const disponibilidade = [...DISP_PADRAO];
    for (const r of (dispRes.data ?? []) as { dia_semana: number; minutos: number }[]) {
      if (r.dia_semana >= 0 && r.dia_semana < 7) disponibilidade[r.dia_semana] = r.minutos;
    }

    const concluidas = new Set<string>(
      ((concRes.data ?? []) as { licao_id: string }[]).map((e) => e.licao_id),
    );

    const dataProva = String((concursoRes.data as { data_prova: string }).data_prova);
    const inicio = addDays(hojeSaoPaulo(), 1); // D+1 — preserva dias passados
    const fim = addDays(dataProva, -7); // uma semana antes da prova

    if (inicio > fim) {
      return json({
        ok: true,
        aviso: "janela_vazia",
        inicio,
        fim,
        dias_gerados: 0,
        dias_removidos: 0,
      });
    }

    // --- gera o novo plano ---
    const { dias, backlog } = gerarPlano({ licoes, disponibilidade, inicio, fim, concluidas });

    // --- regrava só o futuro (>= inicio); passado permanece ---
    const del = await supa.from("plano_dia").delete().gte("data", inicio).eq("user_id", user.id);
    if (del.error) return json({ error: "delete_plano", detail: del.error.message }, 500);

    const rows = dias.map((d) => ({ ...d, user_id: user.id }));
    if (rows.length > 0) {
      const ins = await supa.from("plano_dia").insert(rows);
      if (ins.error) return json({ error: "insert_plano", detail: ins.error.message }, 500);
    }

    return json({
      ok: true,
      inicio,
      fim,
      dias_gerados: dias.length,
      backlog: backlog.length,
      licoes_concluidas_preservadas: concluidas.size,
    });
  } catch (e) {
    return json({ error: String(e) }, 500);
  }
});
