"use client";

import { TopBar } from "@/components/TopBar";
import { ScreenBody, Card, Spinner } from "@/components/Card";
import { useConcurso } from "@/lib/data/hooks";
import { dataCurta, diffDays, moeda, parseIso } from "@/lib/format";

export default function ConcursoPage() {
  const { data: c, isLoading, error } = useConcurso();

  return (
    <>
      <TopBar title="Concurso" />
      <ScreenBody>
        {isLoading ? (
          <div className="flex justify-center py-16">
            <Spinner />
          </div>
        ) : error || !c ? (
          <div className="text-weak text-center py-10">Erro: {String(error)}</div>
        ) : (
          <Conteudo c={c} />
        )}
      </ScreenBody>
    </>
  );
}

function Conteudo({
  c,
}: {
  c: {
    banca: string;
    cargo: string;
    orgao: string;
    vagas: string;
    escolaridade: string;
    salario: number;
    inscricaoIni: string;
    inscricaoFim: string;
    taxa: number;
    dataProva: string;
  };
}) {
  const faltam = diffDays(parseIso(c.dataProva), new Date());
  const linhas: [string, string][] = [
    ["Órgão", c.orgao],
    ["Banca", c.banca],
    ["Cargo", c.cargo],
    ["Vagas", c.vagas],
    ["Escolaridade", c.escolaridade],
    ["Salário", moeda(c.salario)],
    ["Inscrições", `${dataCurta(parseIso(c.inscricaoIni))} a ${dataCurta(parseIso(c.inscricaoFim))}`],
    ["Taxa", moeda(c.taxa)],
    ["Provas (objetivas e discursiva)", dataCurta(parseIso(c.dataProva))],
  ];

  return (
    <>
      <div className="card-hero flex items-center gap-4 p-5">
        <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="1.6">
          <rect x="3.5" y="5" width="17" height="15" rx="3" />
          <path d="M3.5 9.5h17M8 3v3M16 3v3" />
        </svg>
        <div>
          <div className="font-extrabold" style={{ fontSize: 26 }}>
            {faltam >= 0 ? `${faltam} dias` : "Prova realizada"}
          </div>
          <div style={{ color: "rgba(255,255,255,0.85)" }}>
            para a prova · {dataCurta(parseIso(c.dataProva))}
          </div>
        </div>
      </div>

      <Card padding={16}>
        {linhas.map(([rotulo, valor], i) => (
          <div key={rotulo}>
            <div className="flex gap-3 py-2.5">
              <span className="text-weak" style={{ width: 130, fontSize: 13, flexShrink: 0 }}>
                {rotulo}
              </span>
              <span className="text-[15px]">{valor}</span>
            </div>
            {i < linhas.length - 1 && <div style={{ borderTop: "1px solid var(--card-border)" }} />}
          </div>
        ))}
      </Card>
    </>
  );
}
