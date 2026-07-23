"use client";

import { useState } from "react";
import Link from "next/link";
import { TopBar } from "@/components/TopBar";
import { ScreenBody, Card, Spinner, CenterMsg } from "@/components/Card";
import { ProgressBar } from "@/components/ProgressBar";
import { Chip } from "@/components/Chip";
import { IconCheckCircle } from "@/components/Icons";
import { SearchInput } from "@/components/SearchInput";
import { useModulos, useLicoesPorModulo, useProgresso } from "@/lib/data/hooks";
import { corBloco } from "@/lib/theme-tokens";
import { contem } from "@/lib/format";

export default function ModulosPage() {
  const { data: mods, isLoading, error } = useModulos();
  const porModulo = useLicoesPorModulo();
  const { data: progArr } = useProgresso();
  const prog = new Set(progArr ?? []);
  const [busca, setBusca] = useState("");

  const filtrados = (mods ?? []).filter((m) => contem(m.nome, busca) || contem(m.bloco, busca));

  return (
    <>
      <TopBar title="Módulos" />
      <ScreenBody>
        <SearchInput value={busca} onChange={setBusca} placeholder="Buscar módulo..." />
        {isLoading ? (
          <div className="flex justify-center py-16">
            <Spinner />
          </div>
        ) : error ? (
          <div className="text-weak text-center py-10">Erro: {String(error)}</div>
        ) : filtrados.length === 0 ? (
          <CenterMsg>Nenhum módulo encontrado.</CenterMsg>
        ) : (
          filtrados.map((m) => {
            const licoes = porModulo?.[m.moduloId] ?? [];
            const total = licoes.length;
            const feitas = licoes.filter((l) => prog.has(l.licaoId)).length;
            const concluido = total > 0 && feitas === total;
            const cor = corBloco(m.bloco);
            return (
              <Link key={m.moduloId} href={`/modulos/${m.moduloId}`}>
                <Card>
                  <div className="flex items-center gap-3">
                    <div
                      className="rounded-full flex items-center justify-center font-bold flex-shrink-0"
                      style={{
                        width: 32,
                        height: 32,
                        background: `color-mix(in srgb, ${cor} 15%, transparent)`,
                        color: cor,
                      }}
                    >
                      {m.ordem}
                    </div>
                    <span className="flex-1 font-semibold text-[14px] truncate">{m.nome}</span>
                    {concluido && <IconCheckCircle size={20} className="text-[var(--primary)]" />}
                  </div>
                  <div className="flex items-center gap-2 mt-2.5">
                    <Chip color={cor}>{m.bloco}</Chip>
                    <Chip>Peso {m.weight}</Chip>
                    <span className="flex-1" />
                    <span className="text-weak" style={{ fontSize: 12 }}>
                      {feitas}/{total} lições
                    </span>
                  </div>
                  <div className="mt-2">
                    <ProgressBar value={total === 0 ? 0 : feitas / total} height={6} color={concluido ? "var(--primary)" : cor} />
                  </div>
                </Card>
              </Link>
            );
          })
        )}
      </ScreenBody>
    </>
  );
}
