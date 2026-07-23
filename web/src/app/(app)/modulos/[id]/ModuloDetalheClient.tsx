"use client";

import { TopBar } from "@/components/TopBar";
import { ScreenBody, Card, Spinner } from "@/components/Card";
import { ProgressBar } from "@/components/ProgressBar";
import { Checkbox } from "@/components/Chip";
import { IconCheckCircle } from "@/components/Icons";
import { useModulos, useLicoesPorModulo, useProgresso } from "@/lib/data/hooks";
import { corBloco, rotuloBloco } from "@/lib/theme-tokens";
import { minutos } from "@/lib/format";
import type { Licao } from "@/lib/types";

export function ModuloDetalheClient({ moduloId }: { moduloId: string }) {
  const { data: mods, isLoading: l1 } = useModulos();
  const porModulo = useLicoesPorModulo();
  const l2 = !porModulo;
  const { data: progArr, alternar, definirVarias } = useProgresso();

  const modulo = mods?.find((m) => m.moduloId === moduloId);
  const licoes = porModulo?.[moduloId] ?? [];
  const prog = new Set(progArr ?? []);
  const feitas = licoes.filter((l) => prog.has(l.licaoId)).length;
  const total = licoes.length;
  const concluido = total > 0 && feitas === total;

  return (
    <>
      <TopBar
        title={modulo?.nome ?? "Módulo"}
        back
        actions={
          total > 0 ? (
            <button
              className="text-[13px] font-semibold"
              style={{ color: "var(--primary)" }}
              onClick={() => definirVarias(licoes.map((l) => l.licaoId), !concluido)}
            >
              {concluido ? "Limpar" : "Concluir tudo"}
            </button>
          ) : undefined
        }
      />
      <ScreenBody>
        {l1 || l2 ? (
          <div className="flex justify-center py-16">
            <Spinner />
          </div>
        ) : (
          <>
            {modulo && (
              <Card>
                <div className="flex items-center">
                  <span className="font-semibold text-[14px]" style={{ color: corBloco(modulo.bloco) }}>
                    {modulo.bloco} · {rotuloBloco(modulo.bloco)}
                  </span>
                  <span className="flex-1" />
                  <span className="text-weak text-[13px]">Peso {modulo.weight}</span>
                </div>
                <div className="flex items-center gap-3 mt-3">
                  <div className="flex-1">
                    <ProgressBar
                      value={total === 0 ? 0 : feitas / total}
                      height={8}
                      color={concluido ? "var(--primary)" : corBloco(modulo.bloco)}
                    />
                  </div>
                  <span className="font-bold text-[14px]">
                    {feitas}/{total}
                  </span>
                </div>
                {concluido && (
                  <div className="flex items-center gap-1.5 mt-3" style={{ color: "var(--primary)" }}>
                    <IconCheckCircle size={18} />
                    <span className="font-semibold text-[14px]">Módulo concluído</span>
                  </div>
                )}
              </Card>
            )}

            <h2 className="font-bold text-[16px] mt-1">Lições</h2>
            {licoes.length === 0 ? (
              <div className="text-weak py-4">Sem lições para este módulo.</div>
            ) : (
              <div className="flex flex-col gap-2">
                {licoes.map((l) => (
                  <LicaoTile key={l.licaoId} licao={l} concluida={prog.has(l.licaoId)} onToggle={() => alternar(l.licaoId)} />
                ))}
              </div>
            )}
          </>
        )}
      </ScreenBody>
    </>
  );
}

function LicaoTile({
  licao,
  concluida,
  onToggle,
}: {
  licao: Licao;
  concluida: boolean;
  onToggle: () => void;
}) {
  const partes: string[] = [];
  if (licao.docMin > 0) partes.push(`Leitura ${minutos(licao.docMin)}`);
  if (licao.videoMin > 0) partes.push(`Vídeo ${minutos(licao.videoMin)}`);
  return (
    <Card className="flex items-center gap-3" padding={14}>
      <Checkbox checked={concluida} onChange={onToggle} size={24} />
      <div className="flex-1 min-w-0">
        <div
          className="text-[14px] font-medium"
          style={{ textDecoration: concluida ? "line-through" : "none", opacity: concluida ? 0.6 : 1 }}
        >
          Lição {licao.nLicao}: {licao.titulo}
        </div>
        {partes.length > 0 && (
          <div className="text-weak mt-0.5" style={{ fontSize: 12 }}>
            {partes.join("  ·  ")}
          </div>
        )}
      </div>
    </Card>
  );
}
