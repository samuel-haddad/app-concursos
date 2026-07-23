import seedModulos from "@/lib/data/seed_modulos.json";
import { ModuloDetalheClient } from "./ModuloDetalheClient";

// Export estático (GitHub Pages) não tem servidor para resolver rotas
// dinâmicas sob demanda — precisa saber todos os :id possíveis no build.
// Usa o mesmo seed que popula a tabela `modulo` no Supabase (data/seed_modulos.json).
export function generateStaticParams() {
  return (seedModulos as { modulo_id: string }[]).map((m) => ({ id: m.modulo_id }));
}

export default async function ModuloDetalhePage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  return <ModuloDetalheClient moduloId={id} />;
}
