import clsx from "clsx";

export function Card({
  children,
  className,
  padding = 16,
  style,
  onClick,
}: {
  children: React.ReactNode;
  className?: string;
  padding?: number;
  style?: React.CSSProperties;
  onClick?: () => void;
}) {
  return (
    <div
      className={clsx("card", onClick && "cursor-pointer", className)}
      style={{ padding, ...style }}
      onClick={onClick}
    >
      {children}
    </div>
  );
}

export function ScreenBody({ children }: { children: React.ReactNode }) {
  return <div className="px-4 pt-2 pb-6 flex flex-col gap-3 max-w-2xl mx-auto w-full">{children}</div>;
}

export function CenterMsg({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex items-center justify-center py-16 text-weak text-center px-6">
      {children}
    </div>
  );
}

export function Spinner({ size = 22 }: { size?: number }) {
  return (
    <span
      className="inline-block animate-spin rounded-full border-2"
      style={{
        width: size,
        height: size,
        borderColor: "var(--card-border)",
        borderTopColor: "var(--primary)",
      }}
    />
  );
}
