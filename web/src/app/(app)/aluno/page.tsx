"use client";

import { useEffect, useState } from "react";
import { TopBar } from "@/components/TopBar";
import { ScreenBody, Card, Spinner } from "@/components/Card";
import { IconWeekday, IconWeekend, IconInfo, IconMinus, IconPlus, IconRefresh, IconEdit, IconCheck, IconClose } from "@/components/Icons";
import { useDisponibilidade } from "@/lib/data/hooks";
import { disponibilidadePadrao, type RegenerarResultado } from "@/lib/data/queries";
import { useAuth } from "@/lib/supabase/auth-context";
import { minutos } from "@/lib/format";
import { iniciais } from "@/lib/types";

const NOMES = ["Segunda", "Terça", "Quarta", "Quinta", "Sexta", "Sábado", "Domingo"];

const igual = (a: number[], b: number[]) => a.length === b.length && a.every((v, i) => v === b[i]);

export default function AlunoPage() {
  const { data: mins, isLoading, error, salvarERegenerar } = useDisponibilidade();

  // Rascunho local: as edições NÃO são persistidas até o usuário confirmar.
  const [rascunho, setRascunho] = useState<number[] | null>(null);
  const [confirmando, setConfirmando] = useState(false);
  const [salvando, setSalvando] = useState(false);
  const [feedback, setFeedback] = useState<
    { tipo: "ok"; res: RegenerarResultado } | { tipo: "erro"; msg: string } | null
  >(null);

  // Inicializa o rascunho quando os dados chegam do servidor.
  useEffect(() => {
    if (mins && rascunho === null) setRascunho([...mins]);
  }, [mins, rascunho]);

  const editar = (dia: number, valor: number) => {
    setRascunho((r) => {
      if (!r) return r;
      const novo = [...r];
      novo[dia] = Math.max(0, Math.min(600, valor));
      return novo;
    });
    setFeedback(null);
  };

  const restaurarPadrao = () => {
    setRascunho([...disponibilidadePadrao]);
    setFeedback(null);
  };

  const descartar = () => {
    if (mins) setRascunho([...mins]);
    setFeedback(null);
  };

  const confirmar = async () => {
    if (!rascunho) return;
    setSalvando(true);
    setFeedback(null);
    try {
      const res = await salvarERegenerar(rascunho);
      setFeedback({ tipo: "ok", res });
      setConfirmando(false);
    } catch (e) {
      setFeedback({ tipo: "erro", msg: e instanceof Error ? e.message : String(e) });
      setConfirmando(false);
    } finally {
      setSalvando(false);
    }
  };

  const acoes = (
    <button className="icon-btn" title="Restaurar padrão" onClick={restaurarPadrao} disabled={!rascunho}>
      <IconRefresh size={18} />
    </button>
  );

  if (isLoading || !mins || !rascunho) {
    return (
      <>
        <TopBar title="Aluno" actions={acoes} />
        <div className="flex justify-center py-16">
          <Spinner />
        </div>
      </>
    );
  }
  if (error) {
    return (
      <>
        <TopBar title="Aluno" actions={acoes} />
        <div className="text-weak text-center py-10">Erro: {String(error)}</div>
      </>
    );
  }

  const alterado = !igual(rascunho, mins);
  const semana = rascunho.slice(0, 5).reduce((a, b) => a + b, 0);
  const fds = rascunho.slice(5).reduce((a, b) => a + b, 0);
  const total = semana + fds;

  return (
    <>
      <TopBar title="Aluno" actions={acoes} />
      <ScreenBody>
        <PerfilCard />

        <Card padding={16} style={{ background: "var(--surface-tint-primary)" }}>
          <div className="flex gap-3">
            <Bloco rotulo="Seg–Sex" valor={minutos(semana)} />
            <Bloco rotulo="Fim de semana" valor={minutos(fds)} />
            <Bloco rotulo="Total/semana" valor={minutos(total)} />
          </div>
        </Card>

        <h2 className="font-bold text-[16px] mt-1">Disponibilidade por dia</h2>
        <Card padding={4}>
          {NOMES.map((nome, i) => (
            <div key={nome} className="flex items-center gap-3 px-3 py-2">
              {i >= 5 ? <IconWeekend size={20} className="text-weaker" /> : <IconWeekday size={20} className="text-weaker" />}
              <span className="flex-1 text-[14px]">{nome}</span>
              <button className="icon-btn" style={{ width: 30, height: 30 }} disabled={rascunho[i] <= 0} onClick={() => editar(i, rascunho[i] - 15)}>
                <IconMinus size={16} />
              </button>
              <span className="text-center font-semibold text-[14px]" style={{ width: 68 }}>
                {minutos(rascunho[i])}
              </span>
              <button className="icon-btn" style={{ width: 30, height: 30 }} onClick={() => editar(i, rascunho[i] + 15)}>
                <IconPlus size={16} />
              </button>
            </div>
          ))}
        </Card>

        <Card padding={14} className="flex items-start gap-2.5" style={{ background: "var(--surface-neutral-2)" }}>
          <IconInfo size={18} className="text-weak flex-shrink-0 mt-0.5" />
          <p className="text-weak" style={{ fontSize: 12 }}>
            As mudanças ficam em rascunho. Ao tocar em <b>Salvar e regenerar plano</b>, o plano é
            recriado de amanhã até uma semana antes da prova, respeitando sua nova disponibilidade.
            Os dias já passados e o histórico de lições concluídas são mantidos.
          </p>
        </Card>

        {feedback?.tipo === "ok" && (
          <Card padding={14} className="flex items-start gap-2.5" style={{ background: "var(--surface-tint-primary)" }}>
            <span className="flex-shrink-0 mt-0.5" style={{ color: "var(--primary)" }}>
              <IconCheck size={18} />
            </span>
            <p style={{ fontSize: 12 }}>
              Plano regenerado: <b>{feedback.res.dias_gerados}</b> dias (de {feedback.res.inicio} a{" "}
              {feedback.res.fim}).
              {typeof feedback.res.licoes_concluidas_preservadas === "number" &&
                ` ${feedback.res.licoes_concluidas_preservadas} lição(ões) concluída(s) preservada(s).`}
            </p>
          </Card>
        )}
        {feedback?.tipo === "erro" && (
          <Card padding={14} className="flex items-start gap-2.5" style={{ background: "var(--surface-neutral-2)" }}>
            <IconInfo size={18} className="text-weak flex-shrink-0 mt-0.5" />
            <p className="text-weak" style={{ fontSize: 12 }}>Não foi possível regenerar: {feedback.msg}</p>
          </Card>
        )}

        <div className="flex gap-2 mt-1">
          {alterado && (
            <BotaoSecundario onClick={descartar} disabled={salvando}>
              Descartar
            </BotaoSecundario>
          )}
          <BotaoPrimario onClick={() => setConfirmando(true)} disabled={!alterado || salvando}>
            {salvando ? <Spinner size={16} /> : <IconCheck size={16} />}
            Salvar e regenerar plano
          </BotaoPrimario>
        </div>
      </ScreenBody>

      {confirmando && (
        <div
          className="fixed inset-0 z-50 flex items-end sm:items-center justify-center p-4"
          style={{ background: "rgba(0,0,0,0.4)" }}
          onClick={() => !salvando && setConfirmando(false)}
        >
          <Card padding={20} className="w-full max-w-md flex flex-col gap-3" style={{ background: "var(--card)" }}>
            <div onClick={(e) => e.stopPropagation()}>
              <div className="flex items-center justify-between mb-1">
                <h3 className="font-bold text-[16px]">Regenerar plano de estudo?</h3>
                <button className="icon-btn" onClick={() => setConfirmando(false)} disabled={salvando}>
                  <IconClose size={18} />
                </button>
              </div>
              <p className="text-weak mb-4" style={{ fontSize: 13, lineHeight: 1.5 }}>
                O plano de amanhã em diante (até uma semana antes da prova) será recriado com a nova
                disponibilidade. Os dias já passados e o histórico de lições e sessões concluídas
                não são alterados; lições já concluídas não voltam para a fila.
              </p>
              <div className="flex gap-2">
                <BotaoSecundario onClick={() => setConfirmando(false)} disabled={salvando}>
                  Cancelar
                </BotaoSecundario>
                <BotaoPrimario onClick={confirmar} disabled={salvando}>
                  {salvando ? <Spinner size={16} /> : <IconCheck size={16} />}
                  Confirmar
                </BotaoPrimario>
              </div>
            </div>
          </Card>
        </div>
      )}
    </>
  );
}

function BotaoPrimario({ children, onClick, disabled }: { children: React.ReactNode; onClick: () => void; disabled?: boolean }) {
  return (
    <button
      onClick={onClick}
      disabled={disabled}
      className="flex-1 flex items-center justify-center gap-2 font-semibold"
      style={{ height: 46, borderRadius: 12, background: "var(--primary)", color: "var(--on-primary)", opacity: disabled ? 0.5 : 1 }}
    >
      {children}
    </button>
  );
}

function BotaoSecundario({ children, onClick, disabled }: { children: React.ReactNode; onClick: () => void; disabled?: boolean }) {
  return (
    <button
      onClick={onClick}
      disabled={disabled}
      className="flex-1 flex items-center justify-center gap-2 font-semibold"
      style={{ height: 46, borderRadius: 12, background: "var(--surface-neutral-2)", color: "var(--text)", opacity: disabled ? 0.5 : 1 }}
    >
      {children}
    </button>
  );
}

function PerfilCard() {
  const { user, atualizarNome } = useAuth();
  const [editando, setEditando] = useState(false);
  const [valor, setValor] = useState(user?.nome ?? "");
  const [salvando, setSalvando] = useState(false);
  const [erro, setErro] = useState(false);

  async function salvar() {
    const limpo = valor.trim();
    if (!limpo || limpo === user?.nome) {
      setEditando(false);
      return;
    }
    setSalvando(true);
    setErro(false);
    try {
      await atualizarNome(limpo);
      setEditando(false);
    } catch {
      setErro(true);
    } finally {
      setSalvando(false);
    }
  }

  return (
    <Card padding={16} className="flex items-center gap-3">
      <div
        className="rounded-full flex items-center justify-center font-bold flex-shrink-0"
        style={{ width: 44, height: 44, background: "var(--primary)", color: "#fff" }}
      >
        {iniciais(user?.nome ?? "?")}
      </div>
      <div className="flex-1 min-w-0">
        {editando ? (
          <div className="flex items-center gap-2">
            <input
              autoFocus
              value={valor}
              onChange={(e) => setValor(e.target.value)}
              onKeyDown={(e) => {
                if (e.key === "Enter") salvar();
                if (e.key === "Escape") setEditando(false);
              }}
              disabled={salvando}
              className="flex-1 min-w-0 text-[14px] font-semibold px-2 py-1 rounded-[8px]"
              style={{ background: "var(--surface-neutral-2)", color: "var(--text)", border: "1px solid var(--card-border)" }}
            />
            <button className="icon-btn" style={{ width: 30, height: 30 }} onClick={salvar} disabled={salvando} title="Salvar">
              {salvando ? <Spinner size={14} /> : <IconCheck size={16} />}
            </button>
            <button className="icon-btn" style={{ width: 30, height: 30 }} onClick={() => setEditando(false)} disabled={salvando} title="Cancelar">
              <IconClose size={16} />
            </button>
          </div>
        ) : (
          <div className="flex items-center gap-2">
            <div className="min-w-0">
              <div className="font-semibold text-[14px] truncate">{user?.nome ?? "—"}</div>
              <div className="text-weak text-[12px] truncate">{user?.email ?? ""}</div>
            </div>
            <button
              className="icon-btn flex-shrink-0"
              style={{ width: 28, height: 28 }}
              onClick={() => {
                setValor(user?.nome ?? "");
                setEditando(true);
              }}
              title="Editar nome"
            >
              <IconEdit size={14} />
            </button>
          </div>
        )}
        {erro && <div style={{ color: "var(--danger)", fontSize: 11, marginTop: 4 }}>Não foi possível salvar. Tente de novo.</div>}
      </div>
    </Card>
  );
}

function Bloco({ rotulo, valor }: { rotulo: string; valor: string }) {
  return (
    <div className="flex-1 min-w-0">
      <div className="font-extrabold text-[16px]" style={{ color: "var(--primary)" }}>
        {valor}
      </div>
      <div className="text-weak" style={{ fontSize: 11 }}>
        {rotulo}
      </div>
    </div>
  );
}
