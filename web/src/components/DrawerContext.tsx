"use client";

import { createContext, useContext, useState } from "react";

const DrawerContext = createContext<{ open: boolean; setOpen: (v: boolean) => void } | null>(
  null,
);

export function DrawerProvider({ children }: { children: React.ReactNode }) {
  const [open, setOpen] = useState(false);
  return <DrawerContext.Provider value={{ open, setOpen }}>{children}</DrawerContext.Provider>;
}

export function useDrawer() {
  const ctx = useContext(DrawerContext);
  if (!ctx) throw new Error("useDrawer deve ser usado dentro de <DrawerProvider>");
  return ctx;
}
