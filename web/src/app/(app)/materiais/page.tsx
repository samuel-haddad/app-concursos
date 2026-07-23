"use client";

import { useMemo, useState } from "react";
import { TopBar } from "@/components/TopBar";
import { ScreenBody, Card, Spinner, CenterMsg } from "@/components/Card";
import { IconChevronRight } from "@/components/Icons";
import { SearchInput } from "@/components/SearchInput";
import { useModulos, useLicoesPorModulo, useMateriais } from "@/lib/data/hooks";
import { corBloco } from "@/lib/theme-tokens";
import { contem } from "@/lib/format";
import { MateriaisSecao } from "@/components/MateriaisSecao";
import type { Licao } from "@/lib/types";

export default function MateriaisPage() {
  const { data: mods, isLoading: l1 } = useModulos();
  const porModulo = useLicoesPorModulo();
  const { data: materiaisMap, isLoading: l3 } = useMateriais();
  const [abertos, setAbertos] = useState<Set<string>>(new Set());
  const [busca, setBusca] = useState("");

  const modsComMaterial = useMemo(() => {
    if (!mods || !porModulo || !materiaisMap) return [];
    return mods.filter((m) =>
      (porModulo[m.moduloId] ?? []).some((l: Licao) => (materiaisMap[l.licaoId]?.length ?? 0) > 0),
    );
  }, [mods, porModulo, materiaisMap]);

  const modsFiltrados = useMemo(() => {
    if (!busca.trim()) return modsComMaterial;
    return modsComMaterial.filter((m) => {
      if (contem(m.nome, busca)) return true;
      const licoes = porModulo?.[m.moduloId] ?? [];
      return licoes.some((l: Licao) => contem(l.titulo, busca));
    });
  }, [modsComMaterial, porModulo, busca]);

  if (l1 || l3 || !porModulo) {
    return (
      <>
        <TopBar title="Materiais" />
        <div className="flex justify-center py-16">
          <Spinner />
        </div>
      </>
    );
  }

  return (
    <>
      <TopBar title="Materiais" />
      <ScreenBody>
        <SearchInput value={busca} onChange={setBusca} placeholder="Buscar módulo ou lição..." />
        {modsComMaterial.length === 0 ? (
          <CenterMsg>Nenhum material disponível ainda.</CenterMsg>
        ) : modsFiltrados.length === 0 ? (
          <CenterMsg>Nenhum resultado para a busca.</CenterMsg>
        ) : (
          modsFiltrados.map((m) => {
            const aberto = abertos.has(m.moduloId) || busca.trim().length > 0;
            const licoes = (porModulo[m.moduloId] ?? []).filter((l: Licao) => {
              if ((materiaisMap?.[l.licaoId]?.length ?? 0) === 0) return false;
              if (!busca.trim()) return true;
              return contem(m.nome, busca) || contem(l.titulo, busca);
            });
            const cor = corBloco(m.bloco);
            return (
              <Card key={m.moduloId} padding={0}>
                <button
                  className="w-full flex items-center gap-3 p-3.5"
                  onClick={() =>
                    setAbertos((s) => {
                      const n = new Set(s);
                      if (n.has(m.moduloId)) n.delete(m.moduloId);
                      else n.add(m.moduloId);
                      return n;
                    })
                  }
                >
                  <div
                    className="rounded-full flex items-center justify-center font-bold flex-shrink-0"
                    style={{
                      width: 30,
                      height: 30,
                      background: `color-mix(in srgb, ${cor} 15%, transparent)`,
                      color: cor,
                      fontSize: 13,
                    }}
                  >
                    {m.ordem}
                  </div>
                  <span className="flex-1 text-left font-semibold text-[14px] truncate">{m.nome}</span>
                  <span
                    className="text-weaker inline-flex"
                    style={{ transform: aberto ? "rotate(90deg)" : "none", transition: "transform .15s" }}
                  >
                    <IconChevronRight size={18} />
                  </span>
                </button>
                {aberto && (
                  <div className="px-3.5 pb-3.5 flex flex-col gap-3">
                    {licoes.map((l: Licao) => (
                      <div key={l.licaoId}>
                        <div className="text-weak text-[12px] mb-1.5">
                          Lição {l.nLicao}: {l.titulo}
                        </div>
                        <MateriaisSecao licaoId={l.licaoId} hideHeading />
                      </div>
                    ))}
                  </div>
                )}
              </Card>
            );
          })
        )}
      </ScreenBody>
    </>
  );
}
