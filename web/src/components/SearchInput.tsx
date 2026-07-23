"use client";

import { IconSearch, IconClose } from "./Icons";

export function SearchInput({
  value,
  onChange,
  placeholder = "Buscar",
}: {
  value: string;
  onChange: (v: string) => void;
  placeholder?: string;
}) {
  return (
    <div
      className="flex items-center gap-2 px-3"
      style={{ height: 42, borderRadius: 12, background: "var(--card)", border: "1px solid var(--card-border)" }}
    >
      <IconSearch size={17} className="text-weaker flex-shrink-0" />
      <input
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder={placeholder}
        className="flex-1 min-w-0 text-[14px] bg-transparent outline-none"
        style={{ color: "var(--text)" }}
      />
      {value && (
        <button onClick={() => onChange("")} className="text-weaker flex-shrink-0" title="Limpar busca">
          <IconClose size={15} />
        </button>
      )}
    </div>
  );
}
