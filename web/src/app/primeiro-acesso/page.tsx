"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/lib/supabase/auth-context";
import { useDisponibilidade } from "@/lib/data/hooks";
import { disponibilidadePadrao } from "@/lib/data/queries";
import { minutos } from "@/lib/format";
import { LogoIcon } from "@/components/Logo";
import { Spinner } from "@/components/Card";
import {
  IconWeekday,
  IconWeekend,
  IconMinus,
  IconPlus,
  IconRefresh,
  IconCheck,
  IconInfo,
  IconChevronLeft,
} from "@/components/Icons";

const NOMES = ["Segunda", "Terça", "Quarta", "Quinta", "Sexta", "Sábado", "Domingo"];
const TOTAL_PASSOS = 3;

export default function PrimeiroAcessoPage() {
  const auth = useAuth();
  const router = useRouter();
  const { data: mins, isLoading, salvarERegenerar } = useDisponibilidade();

  const [passo, setPasso] = useState<1 | 2 | 3>(1);
  const [nome, setNome] = useState("");
  const [rascunho, setRascunho] = useState<number[] | null>(null);
  const [salvando, setSalvando] = useState(false);
  const [erro, setErro] = useState<string | null>(null);

  useEffect(() => {
    if (auth.carregando) return;
    if (!auth.logado) router.replace("/login");
    else if (auth.pendenteAprovacao) router.replace("/aguardando-aprovacao");
    else if (!auth.precisaPrimeiroAcesso) router.replace("/hoje");
  }, [auth.carregando, auth.logado, auth.pendenteAprovacao, auth.precisaPrimeiroAcesso, router]);

  // Pré-preenche o nome com o que já veio do Google (display_name/full_name).
  useEffect(() => {
    if (auth.user && !nome) setNome(auth.user.nome);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [auth.user]);

  // Rascunho de disponibilidade começa no padrão (novo usuário ainda não tem
  // nenhuma linha salva — carregarDisponibilidade já retorna o padrão nesse caso).
  useEffect(() => {
    if (mins && rascunho === null) setRascunho([...mins]);
  }, [mins, rascunho]);

  if (
    auth.carregando ||
    !auth.logado ||
    auth.pendenteAprovacao ||
    !auth.precisaPrimeiroAcesso ||
    isLoading ||
    !rascunho
  ) {
    return (
      <main className="min-h-screen flex items-center justify-center" style={{ background: "var(--bg)" }}>
        <div className="animate-pulse">
          <LogoIcon size={48} />
        </div>
      </main>
    );
  }

  const editarDia = (dia: number, valor: number) => {
    setRascunho((r) => {
      if (!r) return r;
      const novo = [...r];
      novo[dia] = Math.max(0, Math.min(600, valor));
      return novo;
    });
  };

  const irPara = (p: 1 | 2 | 3) => {
    setErro(null);
    setPasso(p);
  };

  const confirmarNome = async () => {
    const limpo = nome.trim();
    if (!limpo) {
      setErro("Digite um nome para continuar.");
      return;
    }
    setSalvando(true);
    setErro(null);
    try {
      if (limpo !== auth.user?.nome) await auth.atualizarNome(limpo);
      irPara(2);
    } catch {
      setErro("Não foi possível salvar o nome. Tente de novo.");
    } finally {
      setSalvando(false);
    }
  };

  const concluir = async () => {
    if (!rascunho) return;
    setSalvando(true);
    setErro(null);
    try {
      await salvarERegenerar(rascunho);
      auth.marcarPrimeiroAcessoConcluido();
      router.replace("/hoje");
    } catch (e) {
      setErro(e instanceof Error ? e.message : "Não foi possível concluir. Tente de novo.");
      setSalvando(false);
    }
  };

  const semana = rascunho.slice(0, 5).reduce((a, b) => a + b, 0);
  const fds = rascunho.slice(5).reduce((a, b) => a + b, 0);

  return (
    <main className="min-h-screen flex items-center justify-center px-4 py-8" style={{ background: "var(--bg)" }}>
      <div className="w-full max-w-[420px] flex flex-col items-center">
        <LogoIcon size={44} />
        <h1 className="font-extrabold mt-3 text-center" style={{ fontSize: 22 }}>
          Bem-vindo(a) ao Concursos
        </h1>
        <p className="text-weak text-center mt-1" style={{ fontSize: 13 }}>
          Vamos configurar seu acesso em {TOTAL_PASSOS} passos rápidos.
        </p>

        <Passos passo={passo} />

        <div className="card w-full mt-5" style={{ padding: 20 }}>
          {passo === 1 && (
            <PassoNome
              nome={nome}
              setNome={setNome}
              salvando={salvando}
              erro={erro}
              onContinuar={confirmarNome}
            />
          )}
          {passo === 2 && (
            <PassoDisponibilidade
              rascunho={rascunho}
              editarDia={editarDia}
              restaurarPadrao={() => setRascunho([...disponibilidadePadrao])}
              onVoltar={() => irPara(1)}
              onContinuar={() => irPara(3)}
            />
          )}
          {passo === 3 && (
            <PassoConfirmar
              nome={nome}
              semana={semana}
              fds={fds}
              salvando={salvando}
              erro={erro}
              onVoltar={() => irPara(2)}
              onConcluir={concluir}
            />
          )}
        </div>
      </div>
    </main>
  );
}

function Passos({ passo }: { passo: 1 | 2 | 3 }) {
  return (
    <div className="flex items-center gap-2 mt-5">
      {[1, 2, 3].map((p) => (
        <span
          key={p}
          style={{
            width: p === passo ? 22 : 8,
            height: 8,
            borderRadius: 999,
            background: p <= passo ? "var(--primary)" : "var(--surface-neutral-2)",
            transition: "width 0.2s ease",
          }}
        />
      ))}
    </div>
  );
}

function PassoNome({
  nome,
  setNome,
  salvando,
  erro,
  onContinuar,
}: {
  nome: string;
  setNome: (v: string) => void;
  salvando: boolean;
  erro: string | null;
  onContinuar: () => void;
}) {
  return (
    <div className="flex flex-col gap-4">
      <div>
        <h2 className="font-bold" style={{ fontSize: 16 }}>
          Como podemos te chamar?
        </h2>
        <p className="text-weak mt-1" style={{ fontSize: 12.5 }}>
          Esse é o nome que vai aparecer no app. Pode editar depois em Aluno.
        </p>
      </div>
      <input
        autoFocus
        value={nome}
        onChange={(e) => setNome(e.target.value)}
        onKeyDown={(e) => e.key === "Enter" && onContinuar()}
        disabled={salvando}
        placeholder="Seu nome"
        className="w-full font-semibold px-3 py-2.5 rounded-[10px]"
        style={{
          fontSize: 15,
          background: "var(--surface-neutral-2)",
          color: "var(--text)",
          border: "1px solid var(--card-border)",
        }}
      />
      {erro && <p style={{ color: "var(--danger)", fontSize: 12 }}>{erro}</p>}
      <BotaoPrimario onClick={onContinuar} disabled={salvando}>
        {salvando ? <Spinner size={16} /> : null}
        Continuar
      </BotaoPrimario>
    </div>
  );
}

function PassoDisponibilidade({
  rascunho,
  editarDia,
  restaurarPadrao,
  onVoltar,
  onContinuar,
}: {
  rascunho: number[];
  editarDia: (dia: number, valor: number) => void;
  restaurarPadrao: () => void;
  onVoltar: () => void;
  onContinuar: () => void;
}) {
  return (
    <div className="flex flex-col gap-3">
      <div className="flex items-start justify-between gap-2">
        <div>
          <h2 className="font-bold" style={{ fontSize: 16 }}>
            Sua disponibilidade
          </h2>
          <p className="text-weak mt-1" style={{ fontSize: 12.5 }}>
            Quanto tempo por dia você pode estudar? É só uma estimativa inicial.
          </p>
        </div>
        <button className="icon-btn flex-shrink-0" title="Restaurar padrão" onClick={restaurarPadrao}>
          <IconRefresh size={16} />
        </button>
      </div>

      <div className="flex flex-col">
        {NOMES.map((nomeDia, i) => (
          <div key={nomeDia} className="flex items-center gap-3 py-2" style={{ borderTop: i > 0 ? "1px solid var(--card-border)" : undefined }}>
            {i >= 5 ? <IconWeekend size={18} className="text-weaker" /> : <IconWeekday size={18} className="text-weaker" />}
            <span className="flex-1 text-[13px]">{nomeDia}</span>
            <button className="icon-btn" style={{ width: 28, height: 28 }} disabled={rascunho[i] <= 0} onClick={() => editarDia(i, rascunho[i] - 15)}>
              <IconMinus size={14} />
            </button>
            <span className="text-center font-semibold text-[13px]" style={{ width: 64 }}>
              {minutos(rascunho[i])}
            </span>
            <button className="icon-btn" style={{ width: 28, height: 28 }} onClick={() => editarDia(i, rascunho[i] + 15)}>
              <IconPlus size={14} />
            </button>
          </div>
        ))}
      </div>

      <div className="flex gap-2 mt-1">
        <BotaoSecundario onClick={onVoltar}>
          <IconChevronLeft size={16} /> Voltar
        </BotaoSecundario>
        <BotaoPrimario onClick={onContinuar}>Continuar</BotaoPrimario>
      </div>
    </div>
  );
}

function PassoConfirmar({
  nome,
  semana,
  fds,
  salvando,
  erro,
  onVoltar,
  onConcluir,
}: {
  nome: string;
  semana: number;
  fds: number;
  salvando: boolean;
  erro: string | null;
  onVoltar: () => void;
  onConcluir: () => void;
}) {
  return (
    <div className="flex flex-col gap-3">
      <div>
        <h2 className="font-bold" style={{ fontSize: 16 }}>
          Confirmar e gerar seu plano
        </h2>
        <p className="text-weak mt-1" style={{ fontSize: 12.5 }}>
          Confira os dados abaixo. Ao confirmar, seu plano de estudo é gerado a partir de hoje.
        </p>
      </div>

      <div className="rounded-[10px] px-3.5 py-3 flex flex-col gap-2" style={{ background: "var(--surface-neutral-2)" }}>
        <Linha rotulo="Nome" valor={nome} />
        <Linha rotulo="Seg–Sex" valor={minutos(semana)} />
        <Linha rotulo="Fim de semana" valor={minutos(fds)} />
        <Linha rotulo="Total/semana" valor={minutos(semana + fds)} />
      </div>

      <div className="rounded-[10px] px-3.5 py-3 flex items-start gap-2.5" style={{ background: "var(--surface-tint-primary)" }}>
        <IconInfo size={17} className="text-weak flex-shrink-0 mt-0.5" />
        <p className="text-weak" style={{ fontSize: 12 }}>
          Você pode ajustar seu nome e sua disponibilidade a qualquer momento na tela <b>Aluno</b>.
        </p>
      </div>

      {erro && <p style={{ color: "var(--danger)", fontSize: 12 }}>{erro}</p>}

      <div className="flex gap-2 mt-1">
        <BotaoSecundario onClick={onVoltar} disabled={salvando}>
          <IconChevronLeft size={16} /> Voltar
        </BotaoSecundario>
        <BotaoPrimario onClick={onConcluir} disabled={salvando}>
          {salvando ? <Spinner size={16} /> : <IconCheck size={16} />}
          Concluir e gerar plano
        </BotaoPrimario>
      </div>
    </div>
  );
}

function Linha({ rotulo, valor }: { rotulo: string; valor: string }) {
  return (
    <div className="flex items-center justify-between">
      <span className="text-weak" style={{ fontSize: 12.5 }}>
        {rotulo}
      </span>
      <span className="font-semibold" style={{ fontSize: 13 }}>
        {valor}
      </span>
    </div>
  );
}

function BotaoPrimario({
  children,
  onClick,
  disabled,
}: {
  children: React.ReactNode;
  onClick: () => void;
  disabled?: boolean;
}) {
  return (
    <button
      onClick={onClick}
      disabled={disabled}
      className="flex-1 flex items-center justify-center gap-2 font-semibold"
      style={{ height: 46, borderRadius: 12, background: "var(--primary)", color: "var(--on-primary)", opacity: disabled ? 0.6 : 1 }}
    >
      {children}
    </button>
  );
}

function BotaoSecundario({
  children,
  onClick,
  disabled,
}: {
  children: React.ReactNode;
  onClick: () => void;
  disabled?: boolean;
}) {
  return (
    <button
      onClick={onClick}
      disabled={disabled}
      className="flex-1 flex items-center justify-center gap-2 font-semibold"
      style={{ height: 46, borderRadius: 12, background: "var(--surface-neutral-2)", color: "var(--text)", opacity: disabled ? 0.6 : 1 }}
    >
      {children}
    </button>
  );
}
