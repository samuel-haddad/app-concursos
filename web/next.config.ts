import type { NextConfig } from "next";

// GitHub Pages serve o repo em /app-concursos/ (Pages de projeto, não de
// usuário) — mesmo padrão do build Flutter anterior (--base-href
// /app-concursos/). Em dev local isso fica vazio.
const basePath = process.env.NEXT_PUBLIC_BASE_PATH || "";

const nextConfig: NextConfig = {
  output: "export",
  basePath,
  assetPrefix: basePath ? `${basePath}/` : undefined,
  trailingSlash: true,
  // Desliga o indicador de dev do Next (o selo "N" no canto), que fica
  // sobreposto à barra de navegação inferior do app. Não afeta o build de
  // produção (export estático) — é só overlay do `next dev`.
  devIndicators: false,
  images: {
    // Sem servidor no GitHub Pages — não há como rodar a otimização de
    // imagem do Next (que depende de `sharp`). Não usamos next/image no
    // app (só SVG inline), então isso não muda nada visualmente.
    unoptimized: true,
  },
};

export default nextConfig;
