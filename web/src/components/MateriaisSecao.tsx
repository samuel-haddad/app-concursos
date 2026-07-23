"use client";

import { useState } from "react";
import { useMateriais } from "@/lib/data/hooks";
import { urlAssinadaMaterial } from "@/lib/data/queries";
import type { MaterialItem } from "@/lib/types";
import { Card, Spinner } from "./Card";
import { IconFolder, IconPdf, IconAudio, IconVideo, IconOpenExternal } from "./Icons";

const VISUAL: Record<
  MaterialItem["tipo"],
  { icon: typeof IconPdf; cor: string; acao: string }
> = {
  PDF: { icon: IconPdf, cor: "var(--danger)", acao: "Abrir em tela cheia" },
  AUDIO: { icon: IconAudio, cor: "#00796B", acao: "Reproduzir áudio" },
  VIDEO: { icon: IconVideo, cor: "var(--sessao-estudo)", acao: "Reproduzir vídeo" },
  OUTRO: { icon: IconFolder, cor: "var(--text-weaker)", acao: "Abrir" },
};

export function MateriaisSecao({
  licaoId,
  hideHeading,
}: {
  licaoId: string;
  hideHeading?: boolean;
}) {
  const { data: mapa } = useMateriais();
  if (!licaoId) return null;
  const itens = mapa?.[licaoId] ?? [];
  if (itens.length === 0) return null;

  return (
    <div className="mt-1">
      {!hideHeading && (
        <div className="flex items-center gap-2 mb-2">
          <IconFolder size={18} />
          <h3 className="font-bold text-[15px]">Materiais</h3>
        </div>
      )}
      <div className="flex flex-col gap-2">
        {itens.map((item, i) => (
          <MaterialTile key={i} item={item} />
        ))}
      </div>
    </div>
  );
}

function MaterialTile({ item }: { item: MaterialItem }) {
  const [carregando, setCarregando] = useState(false);
  const [erro, setErro] = useState(false);
  const v = VISUAL[item.tipo] ?? VISUAL.OUTRO;
  const Icone = v.icon;

  async function abrir() {
    setCarregando(true);
    setErro(false);
    try {
      const url = await urlAssinadaMaterial(item.key);
      window.open(url, "_blank", "noopener,noreferrer");
    } catch {
      setErro(true);
    } finally {
      setCarregando(false);
    }
  }

  return (
    <Card padding={12} onClick={carregando ? undefined : abrir} className="flex items-center gap-3">
      <div
        className="rounded-lg flex items-center justify-center flex-shrink-0"
        style={{ width: 32, height: 32, background: `color-mix(in srgb, ${v.cor} 15%, transparent)` }}
      >
        <Icone size={18} className="" />
      </div>
      <div className="flex-1 min-w-0">
        <div className="font-semibold text-[14px] truncate">{item.titulo}</div>
        <div className="text-weak text-[12px]">{erro ? "Falha ao carregar o material." : v.acao}</div>
      </div>
      {carregando ? <Spinner size={18} /> : <IconOpenExternal size={16} className="text-weaker" />}
    </Card>
  );
}
