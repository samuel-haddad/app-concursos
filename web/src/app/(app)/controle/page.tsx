"use client";

import { useMemo } from "react";
import { TopBar } from "@/components/TopBar";
import { ScreenBody, Card, Spinner } from "@/components/Card";
import { ProgressBar } from "@/components/ProgressBar";
import { IconCheckCircle } from "@/components/Icons";
import {
  useLicoes,
  useModulos,
  useLicoesPorModulo,
  useProgresso,
  usePlano,
  useSessoesRealizadas,
} from "@/lib/data/hooks";
import { derivarSessoes, sessaoId } from "@/lib/data/queries";
import { corBloco, rotuloBloco } from "@/lib/theme-tokens";
import { minutos, iso } from "@/lib/format";
import type { Bloco, Licao, Modulo } from "@/lib/types";

interface Prog {
  feitas: number;
  total: number;
  minFeitos: number;
  minTotal: number;
}
const novoProg = (): Prog => ({ feitas: 0, total: 0, minFeitos: 0, minTotal: 0 });
const pct = (p: Prog) => (p.total === 0 ? 0 : p.feitas / p.total);

const ORDEM_BLOCO: Bloco[] = ["P1", "P2", "P3", "P4", "FORA"];

export default function ControlePage() {
  const { data: licoesMap, isLoading: l1 } = useLicoes();
  const { data: mods, isLoading: l2 } = useModulos();
  const porModulo = useLicoesPorModulo();
  const { data: progArr } = useProgresso();
  const { data: plano } = usePlano();
  const { data: realizadasArr } = useSessoesRealizadas();

  const prog = useMemo(() => new Set(progArr ?? []), [progArr]);

  const { geral, porBloco } = useMemo(() => {
    const geral = novoProg();
    const porBloco: Partial<Record<Bloco, Prog>> = {};
    for (const l of Object.values(licoesMap ?? {})) {
      const feita = prog.has(l.licaoId);
      const b = (porBloco[l.bloco] ??= novoProg());
      geral.total++;
      geral.minTotal += l.estudoMin;
      b.total++;
      b.minTotal += l.estudoMin;
      if (feita) {
        geral.feitas++;
        geral.minFeitos += l.estudoMin;
        b.feitas++;
        b.minFeitos += l.estudoMin;
      }
    }
    return { geral, porBloco };
  }, [licoesMap, prog]);

  const adesao = useMemo(() => {
    if (!plano) return null;
    const hoje = iso(new Date());
    const diasPassados = plano.filter((p) => p.data <= hoje);
    const sessoes = derivarSessoes(diasPassados);
    const realizadas = new Set(realizadasArr ?? []);
    const feitas = sessoes.filter((s) => realizadas.has(sessaoId(s)));
    const minTotal = sessoes.reduce((a, s) => a + s.minutos, 0);
    const minFeitos = feitas.reduce((a, s) => a + s.minutos, 0);
    return {
      pct: sessoes.length === 0 ? 0 : feitas.length / sessoes.length,
      feitas: feitas.length,
      total: sessoes.length,
      minFeitos,
      minTotal,
    };
  }, [plano, realizadasArr]);

  if (l1 || l2) {
    return (
      <>
        <TopBar title="Controle" />
        <div className="flex justify-center py-16">
          <Spinner />
        </div>
      </>
    );
  }

  const blocos = ORDEM_BLOCO.filter((b) => porBloco[b]);

  return (
    <>
      <TopBar title="Controle" />
      <ScreenBody>
        <Card padding={18}>
          <div className="flex items-end gap-2">
            <span className="font-extrabold" style={{ fontSize: 44, color: "var(--primary)", lineHeight: 1 }}>
              {Math.round(pct(geral) * 100)}%
            </span>
            <span className="text-weak pb-1.5">das lições concluídas</span>
          </div>
          <div className="mt-3">
            <ProgressBar value={pct(geral)} height={10} color="var(--primary)" />
          </div>
          <div className="flex mt-3.5 gap-2">
            <Metric rotulo="Lições" valor={`${geral.feitas}/${geral.total}`} />
            <Metric rotulo="Tempo estudado" valor={minutos(geral.minFeitos)} />
            <Metric
              rotulo="% por tempo"
              valor={`${geral.minTotal === 0 ? 0 : ((geral.minFeitos / geral.minTotal) * 100).toFixed(1)}%`}
            />
          </div>
        </Card>

        {adesao && (
          <Card padding={16} style={{ background: "var(--surface-tint-primary)" }}>
            <div className="flex items-baseline gap-2">
              <span className="font-extrabold" style={{ fontSize: 26, color: "var(--primary)" }}>
                {Math.round(adesao.pct * 100)}%
              </span>
              <span className="text-weak text-[13px]">de adesão ao plano</span>
            </div>
            <div className="mt-2.5">
              <ProgressBar value={adesao.pct} height={8} color="var(--primary)" track="rgba(2,99,224,0.15)" />
            </div>
            <div className="text-weak text-[12px] mt-2">
              {adesao.feitas}/{adesao.total} sessões · {minutos(adesao.minFeitos)} de{" "}
              {minutos(adesao.minTotal)}
            </div>
          </Card>
        )}

        <h2 className="font-bold text-[16px] mt-1">Por bloco de prova</h2>
        <Card padding={14}>
          <div className="flex flex-col gap-3.5">
            {blocos.map((b) => (
              <LinhaBloco key={b} bloco={b} prog={porBloco[b]!} />
            ))}
          </div>
        </Card>

        <h2 className="font-bold text-[16px] mt-1">Por módulo</h2>
        <div className="flex flex-col gap-3">
          {(mods ?? []).map((m) => (
            <LinhaModulo key={m.moduloId} modulo={m} licoes={porModulo?.[m.moduloId] ?? []} prog={prog} />
          ))}
        </div>
      </ScreenBody>
    </>
  );
}

function Metric({ rotulo, valor }: { rotulo: string; valor: string }) {
  return (
    <div className="flex-1 min-w-0">
      <div className="font-bold text-[16px] truncate">{valor}</div>
      <div className="text-weak" style={{ fontSize: 11 }}>
        {rotulo}
      </div>
    </div>
  );
}

function LinhaBloco({ bloco, prog }: { bloco: Bloco; prog: Prog }) {
  const cor = corBloco(bloco);
  return (
    <div>
      <div className="flex items-center gap-2">
        <span className="inline-block rounded-full" style={{ width: 10, height: 10, background: cor }} />
        <span className="font-semibold text-[14px]">
          {bloco} · {rotuloBloco(bloco)}
        </span>
        <span className="flex-1" />
        <span className="text-weak" style={{ fontSize: 12 }}>
          {prog.feitas}/{prog.total}
        </span>
      </div>
      <div className="mt-1.5">
        <ProgressBar value={pct(prog)} height={6} color={cor} />
      </div>
    </div>
  );
}

function LinhaModulo({
  modulo,
  licoes,
  prog,
}: {
  modulo: Modulo;
  licoes: Licao[];
  prog: Set<string>;
}) {
  const cor = corBloco(modulo.bloco);
  const total = licoes.length;
  const feitas = licoes.filter((l) => prog.has(l.licaoId)).length;
  const p = total === 0 ? 0 : feitas / total;
  const concluido = total > 0 && feitas === total;

  return (
    <div>
      <div className="flex items-center gap-2">
        <span className="flex-1 truncate" style={{ fontSize: 13 }}>
          {modulo.ordem}. {modulo.nome}
        </span>
        {concluido && <IconCheckCircle size={16} className="text-[var(--primary)]" />}
        <span className="text-weak" style={{ fontSize: 12 }}>
          {feitas}/{total}
        </span>
      </div>
      <div className="mt-1">
        <ProgressBar value={p} height={5} color={concluido ? "var(--primary)" : cor} />
      </div>
    </div>
  );
}
