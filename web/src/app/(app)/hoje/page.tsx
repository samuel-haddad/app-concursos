"use client";

import { Suspense, useState } from "react";
import { useSearchParams } from "next/navigation";
import { TopBar } from "@/components/TopBar";
import { ScreenBody, Card, CenterMsg, Spinner } from "@/components/Card";
import { Checkbox } from "@/components/Chip";
import { ProgressRing } from "@/components/ProgressRing";
import { MateriaisSecao } from "@/components/MateriaisSecao";
import { IconChevronLeft, IconChevronRight, IconTarget, IconTimer } from "@/components/Icons";
import { usePlano, useLicoes, useSessoesRealizadas } from "@/lib/data/hooks";
import { derivarSessoes, ordenarSessoes, sessaoId } from "@/lib/data/queries";
import { corSessao, rotuloSessao } from "@/lib/theme-tokens";
import { addDays, dataLonga, diffDays, iso, minutos, parseIso } from "@/lib/format";
import { DATA_PROVA } from "@/lib/types";
import type { Sessao } from "@/lib/types";

export default function HojePage() {
  return (
    <Suspense fallback={null}>
      <HojeConteudo />
    </Suspense>
  );
}

function HojeConteudo() {
  const { data: plano, isLoading, error } = usePlano();
  const { data: licoes } = useLicoes();
  const { data: realizadas, alternar: alternarSessao } = useSessoesRealizadas();
  const searchParams = useSearchParams();
  const dataParam = searchParams.get("data");
  const [selecionada, setSelecionada] = useState<string | null>(null);

  const acoes = (
    <button
      className="icon-btn"
      title="Ir para o dia atual"
      onClick={() => setSelecionada(iso(new Date()))}
    >
      <IconTarget size={18} />
    </button>
  );

  if (isLoading) {
    return (
      <>
        <TopBar title="Hoje" actions={acoes} />
        <div className="flex justify-center py-16">
          <Spinner />
        </div>
      </>
    );
  }

  if (error || !plano || plano.length === 0) {
    return (
      <>
        <TopBar title="Hoje" actions={acoes} />
        <CenterMsg>{error ? `Erro ao carregar: ${String(error)}` : "Plano vazio."}</CenterMsg>
      </>
    );
  }

  const primeiro = plano[0].data;
  const ultimo = plano[plano.length - 1].data;
  let atual = selecionada ?? dataParam ?? iso(new Date());
  if (atual < primeiro) atual = primeiro;
  if (atual > ultimo) atual = ultimo;

  const dia = plano.find((p) => p.data === atual) ?? plano[0];
  const sessoesDoDia = ordenarSessoes(derivarSessoes([dia]));
  const feitas = new Set(realizadas ?? []);
  const concluidas = sessoesDoDia.filter((s) => feitas.has(sessaoId(s)));
  const minFeitos = concluidas.reduce((a, s) => a + s.minutos, 0);
  const pctSessoes = sessoesDoDia.length === 0 ? 0 : concluidas.length / sessoesDoDia.length;

  const podeVoltar = dia.data > primeiro;
  const podeAvancar = dia.data < ultimo;
  const faltam = diffDays(parseIso(DATA_PROVA), parseIso(dia.data));

  return (
    <>
      <TopBar title="Hoje" actions={acoes} />
      <ScreenBody>
        <div className="flex items-center gap-2">
          <button
            className="icon-btn"
            disabled={!podeVoltar}
            onClick={() => setSelecionada(iso(addDays(parseIso(dia.data), -1)))}
          >
            <IconChevronLeft />
          </button>
          <div className="flex-1 text-center">
            <div className="font-bold text-[15px]">{dataLonga(parseIso(dia.data))}</div>
            <div className="text-weak text-[11.5px] mt-0.5">
              {faltam >= 0 ? `Faltam ${faltam} dias para a prova` : "Após a prova"}
            </div>
          </div>
          <button
            className="icon-btn"
            disabled={!podeAvancar}
            onClick={() => setSelecionada(iso(addDays(parseIso(dia.data), 1)))}
          >
            <IconChevronRight />
          </button>
        </div>

        <div className="card-hero flex items-center gap-4 p-4">
          <ProgressRing value={pctSessoes} size={74} strokeWidth={8}>
            <span className="font-extrabold text-[17px]">{Math.round(pctSessoes * 100)}%</span>
          </ProgressRing>
          <div className="flex-1 min-w-0">
            <div className="font-extrabold text-[17px]">{textoProgresso(pctSessoes)}</div>
            <div className="text-[13px] mt-1" style={{ color: "rgba(255,255,255,0.85)" }}>
              {concluidas.length} de {sessoesDoDia.length} sessões concluídas
            </div>
            <div className="text-[13px]" style={{ color: "rgba(255,255,255,0.85)" }}>
              {minutos(minFeitos)} de {minutos(dia.totalMin)} estudados
            </div>
          </div>
        </div>

        <div className="flex items-center justify-between mt-1">
          <h2 className="font-bold text-[16px]">Sessões do dia</h2>
          {dia.nConteudos >= 2 && <span className="chip">{dia.nConteudos} conteúdos</span>}
        </div>

        {sessoesDoDia.length === 0 ? (
          <Card>Sem sessões neste dia.</Card>
        ) : (
          <div className="flex flex-col gap-2.5">
            {sessoesDoDia.map((s, i) => (
              <SessaoCard
                key={i}
                sessao={s}
                licao={s.licaoRef ? licoes?.[s.licaoRef] : undefined}
                concluida={feitas.has(sessaoId(s))}
                onToggle={() => alternarSessao(s)}
              />
            ))}
          </div>
        )}

        <MateriaisSecao licaoId={dia.licaoPrincipal} />
      </ScreenBody>
    </>
  );
}

function textoProgresso(pct: number): string {
  if (pct <= 0) return "Vamos começar?";
  if (pct <= 0.5) return "Estamos no caminho";
  if (pct <= 0.75) return "Boa! Já passamos da metade.";
  if (pct < 1) return "Excelente! Falta pouco";
  return "Parabéns! Missão cumprida!";
}

function SessaoCard({
  sessao,
  licao,
  concluida,
  onToggle,
}: {
  sessao: Sessao;
  licao?: { nLicao: number; titulo: string };
  concluida: boolean;
  onToggle: () => void;
}) {
  const cor = corSessao(sessao.tipo);
  return (
    <div className="card flex overflow-hidden">
      <div style={{ width: 5, background: cor }} />
      <div className="flex-1 min-w-0 p-3.5 flex items-center gap-3">
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2">
            <span className="font-bold text-[12px] uppercase tracking-wide" style={{ color: cor }}>
              {rotuloSessao(sessao.tipo)}
            </span>
            <span className="flex-1" />
            <span className="text-weak text-[12px] flex items-center gap-1">
              <IconTimer size={13} /> {minutos(sessao.minutos)}
            </span>
          </div>
          {sessao.moduloRef && (
            <div className="text-[14px] font-medium mt-1 truncate">{sessao.moduloRef}</div>
          )}
          {licao && (
            <div className="text-weak text-[12px] mt-0.5 truncate">
              Lição {licao.nLicao}: {licao.titulo}
            </div>
          )}
        </div>
        <Checkbox checked={concluida} onChange={onToggle} />
      </div>
    </div>
  );
}
