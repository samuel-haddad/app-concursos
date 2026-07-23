"use client";

import { createContext, useCallback, useContext, useEffect, useState } from "react";

type ThemeMode = "light" | "dark";

interface ThemeContextValue {
  tema: ThemeMode;
  alternar: () => void;
}

const ThemeContext = createContext<ThemeContextValue | null>(null);
const CHAVE = "tema_escuro";

function lerTemaSalvo(): ThemeMode {
  if (typeof window === "undefined") return "light";
  return window.localStorage.getItem(CHAVE) === "1" ? "dark" : "light";
}

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  const [tema, setTema] = useState<ThemeMode>(lerTemaSalvo);

  useEffect(() => {
    document.documentElement.setAttribute("data-theme", tema);
  }, [tema]);

  const alternar = useCallback(() => {
    setTema((atual) => {
      const novo: ThemeMode = atual === "dark" ? "light" : "dark";
      window.localStorage.setItem(CHAVE, novo === "dark" ? "1" : "0");
      return novo;
    });
  }, []);

  return <ThemeContext.Provider value={{ tema, alternar }}>{children}</ThemeContext.Provider>;
}

export function useThemeMode() {
  const ctx = useContext(ThemeContext);
  if (!ctx) throw new Error("useThemeMode deve ser usado dentro de <ThemeProvider>");
  return ctx;
}
