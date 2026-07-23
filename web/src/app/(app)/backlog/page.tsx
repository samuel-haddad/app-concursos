"use client";

import { useMemo, useState } from "react";
import { TopBar } from "@/components/TopBar";
import { ScreenBody, Card, Spinner, CenterMsg } from "@/components/Card";
import { Chip } from "@/components/Chip";
import { SearchInput } from "@/components/SearchInput";
import { useBacklog } from "@/lib/data/hooks";
import { corBloco } from "@/lib/theme-tokens";
import { minutos, contem } from "@/lib/format";

export default function BacklogPage() {
  const { data: lista, isLoading, error } = useBacklog();
  const [busca, setBusca] = useState("");

  const filtrada = useMemo(
    () => (lista ?? []).filter((l) => contem(l.titulo, busca) || contem(l.modulo, busca)),
    [lista, busca],
  );

  return (
    <>
      <TopBar title="Backlog" />
      <ScreenBody>
        <SearchInput value={busca} onChange={setBusca} placeholder="Buscar lição ou módulo..." />
        {isLoading ? (
          <div className="flex justify-center py-16">
            <Spinner />
          </div>
        ) : error ? (
          <div className="text-weak text-center py-10">Erro: {String(error)}</div>
        ) : !lista || lista.length === 0 ? (
          <CenterMsg>Backlog vazio.</CenterMsg>
        ) : filtrada.length === 0 ? (
          <CenterMsg>Nenhum resultado para a busca.</CenterMsg>
        ) : (
          <>
            <Card>
              <div className="font-bold text-[16px]">{lista.length} lições fora do plano</div>
              <p className="text-weak text-[13px] mt-1">
                Somam {minutos(lista.reduce((a, l) => a + l.estudoMin, 0))} de conteúdo.{" "}
                {lista.filter((l) => l.weight === 0).length} são de peso 0 (deixadas de lado); as
                demais não couberam no tempo disponível.
              </p>
            </Card>
            {filtrada.map((l) => {
              const cor = corBloco(l.bloco);
              const partes: string[] = [];
              if (l.docMin > 0) partes.push(`Leitura ${minutos(l.docMin)}`);
              if (l.videoMin > 0) partes.push(`Vídeo ${minutos(l.videoMin)}`);
              return (
                <Card key={l.licaoId} padding={12} className="flex items-start gap-3">
                  <Chip color={cor}>{l.weight === 0 ? "P0" : `P${l.weight}`}</Chip>
                  <div className="flex-1 min-w-0">
                    <div className="font-semibold text-[14px]">{l.modulo}</div>
                    <div className="text-weak text-[13px] mt-0.5">
                      Lição {l.nLicao}: {l.titulo}
                    </div>
                    {partes.length > 0 && (
                      <div className="text-weaker mt-1" style={{ fontSize: 11 }}>
                        {partes.join("  ·  ")}
                      </div>
                    )}
                  </div>
                </Card>
              );
            })}
          </>
        )}
      </ScreenBody>
    </>
  );
}
