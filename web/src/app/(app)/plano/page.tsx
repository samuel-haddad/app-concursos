"use client";

import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { TopBar } from "@/components/TopBar";
import { ScreenBody, Card, CenterMsg, Spinner } from "@/components/Card";
import { IconChevronLeft, IconChevronRight } from "@/components/Icons";
import { usePlano, useModulosPorNome, useSessoesRealizadas } from "@/lib/data/hooks";
import { derivarSessoes, sessaoId } from "@/lib/data/queries";
import { corBloco, rotuloBloco } from "@/lib/theme-tokens";
import { iso, mesAno, parseIso } from "@/lib/format";
import type { PlanoDia } from "@/lib/types";

const DIAS_SEMANA = ["Seg", "Ter", "Qua", "Qui", "Sex", "Sáb", "Dom"];
const BLOCOS = ["P1", "P2", "P3", "P4"];

export default function PlanoPage() {
  const { data: plano, isLoading, error } = usePlano();
  const mods = useModulosPorNome();
  const { data: realizadasArr } = useSessoesRealizadas();
  const router = useRouter();
  const [mesOverride, setMesOverride] = useState<{ y: number; m: number } | null>(null);

  const porData = useMemo(() => {
    const out: Record<string, PlanoDia> = {};
    for (const p of plano ?? []) out[p.data] = p;
    return out;
  }, [plano]);

  const realizadas = useMemo(() => new Set(realizadasArr ?? []), [realizadasArr]);

  if (isLoading) {
    return (
      <>
        <TopBar title="Plano" />
        <div className="flex justify-center py-16">
          <Spinner />
        </div>
      </>
    );
  }
  if (error || !plano || plano.length === 0) {
    return (
      <>
        <TopBar title="Plano" />
        <CenterMsg>{error ? `Erro: ${String(error)}` : "Plano vazio."}</CenterMsg>
      </>
    );
  }

  const primeiro = parseIso(plano[0].data);
  const ultimo = parseIso(plano[plano.length - 1].data);
  const primeiroMes = { y: primeiro.getFullYear(), m: primeiro.getMonth() };
  const ultimoMes = { y: ultimo.getFullYear(), m: ultimo.getMonth() };

  let mes = mesOverride ?? primeiroMes;
  const idx = mes.y * 12 + mes.m;
  if (idx < primeiroMes.y * 12 + primeiroMes.m) mes = primeiroMes;
  if (idx > ultimoMes.y * 12 + ultimoMes.m) mes = ultimoMes;

  const mesDate = new Date(mes.y, mes.m, 1);
  const diasNoMes = new Date(mes.y, mes.m + 1, 0).getDate();
  const offset = (new Date(mes.y, mes.m, 1).getDay() + 6) % 7; // Seg=0..Dom=6

  const podeVoltar = mes.y * 12 + mes.m > primeiroMes.y * 12 + primeiroMes.m;
  const podeAvancar = mes.y * 12 + mes.m < ultimoMes.y * 12 + ultimoMes.m;

  const celulas: React.ReactNode[] = [];
  for (let i = 0; i < offset; i++) celulas.push(<div key={`off-${i}`} />);
  for (let dia = 1; dia <= diasNoMes; dia++) {
    const d = new Date(mes.y, mes.m, dia);
    const isoStr = iso(d);
    const p = porData[isoStr];
    celulas.push(
      <CelulaDia
        key={isoStr}
        dia={dia}
        plano={p}
        mods={mods}
        concluido={p ? diaConcluido(p, realizadas) : false}
        onTap={() => router.push(`/hoje?data=${isoStr}`)}
      />,
    );
  }

  return (
    <>
      <TopBar title="Plano" />
      <ScreenBody>
        <div className="flex items-center gap-2">
          <button
            className="icon-btn"
            disabled={!podeVoltar}
            onClick={() => setMesOverride({ y: mes.y, m: mes.m - 1 })}
          >
            <IconChevronLeft />
          </button>
          <div className="flex-1 text-center font-bold text-[15px]">{mesAno(mesDate)}</div>
          <button
            className="icon-btn"
            disabled={!podeAvancar}
            onClick={() => setMesOverride({ y: mes.y, m: mes.m + 1 })}
          >
            <IconChevronRight />
          </button>
        </div>

        <div className="grid grid-cols-7 gap-1">
          {DIAS_SEMANA.map((d) => (
            <div key={d} className="text-center text-weak font-semibold" style={{ fontSize: 12 }}>
              {d}
            </div>
          ))}
        </div>
        <div className="grid grid-cols-7 gap-1" style={{ gridAutoRows: "58px" }}>
          {celulas}
        </div>

        <Card padding={12}>
          <div className="flex flex-wrap gap-x-4 gap-y-2">
            {BLOCOS.map((b) => (
              <div key={b} className="flex items-center gap-1.5">
                <span
                  className="inline-block rounded-full"
                  style={{ width: 12, height: 12, background: corBloco(b) }}
                />
                <span style={{ fontSize: 12 }}>
                  {b} · {rotuloBloco(b)}
                </span>
              </div>
            ))}
          </div>
        </Card>
      </ScreenBody>
    </>
  );
}

function diaConcluido(p: PlanoDia, realizadas: Set<string>): boolean {
  const sessoes = derivarSessoes([p]);
  if (sessoes.length === 0) return false;
  return sessoes.every((s) => realizadas.has(sessaoId(s)));
}

function CelulaDia({
  dia,
  plano,
  mods,
  concluido,
  onTap,
}: {
  dia: number;
  plano?: PlanoDia;
  mods?: Record<string, { bloco: string }>;
  concluido: boolean;
  onTap: () => void;
}) {
  const hoje = iso(new Date());

  if (!plano) {
    return (
      <div
        className="rounded-[10px] flex items-start justify-center pt-1.5"
        style={{ background: "var(--surface-neutral-2)", opacity: 0.5 }}
      >
        <span className="text-weaker" style={{ fontSize: 12 }}>
          {dia}
        </span>
      </div>
    );
  }

  const blocos = plano.moduloDia
    ? plano.moduloDia.split(" + ").map((nome) => mods?.[nome]?.bloco ?? "FORA")
    : [];
  const corPrincipal = blocos.length > 0 ? corBloco(blocos[0]) : "var(--card-border)";
  const isHoje = plano.data === hoje;

  return (
    <button
      onClick={onTap}
      className="rounded-[10px] flex flex-col overflow-hidden text-left"
      style={{
        border: isHoje ? "2px solid var(--primary)" : "1px solid var(--card-border)",
        background: isHoje ? "var(--surface-tint-primary)" : "var(--card)",
      }}
    >
      <div style={{ height: 5, background: corPrincipal }} />
      <div className="flex-1 flex flex-col items-center justify-center gap-1 py-1">
        <span className="font-semibold" style={{ fontSize: 13 }}>
          {dia}
        </span>
        {concluido ? (
          <span
            className="rounded-full flex items-center justify-center"
            style={{ width: 14, height: 14, background: "var(--success)" }}
          >
            <svg width="9" height="9" viewBox="0 0 24 24" fill="none">
              <path d="M5 13l4 4L19 7" stroke="#fff" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" />
            </svg>
          </span>
        ) : (
          <div className="flex gap-0.5">
            {blocos.map((b, i) => (
              <span
                key={i}
                className="inline-block rounded-full"
                style={{ width: 6, height: 6, background: corBloco(b) }}
              />
            ))}
          </div>
        )}
      </div>
    </button>
  );
}
