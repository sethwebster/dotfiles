import type { ComponentPropsWithoutRef, ReactNode } from 'react'

type CalloutProps = {
  title?: string
  tone?: 'default' | 'accent' | 'warning'
  children: ReactNode
}

const toneStyles: Record<NonNullable<CalloutProps['tone']>, string> = {
  default:
    'border-white/10 bg-white/5 text-[color:var(--ink-1)]',
  accent:
    'border-[color:var(--line-1)] bg-[color:var(--glow-0)] text-[color:var(--ink-0)]',
  warning:
    'border-amber-200/30 bg-amber-200/10 text-amber-100',
}

export function Callout({ title, tone = 'default', children }: CalloutProps) {
  return (
    <div className={`rounded-2xl border px-6 py-5 ${toneStyles[tone]}`}>
      {title ? (
        <div className="mb-2 text-sm uppercase tracking-[0.24em] text-[color:var(--ink-2)]">
          {title}
        </div>
      ) : null}
      <div className="text-sm leading-relaxed">{children}</div>
    </div>
  )
}

export function Badge({ children }: { children: ReactNode }) {
  return (
    <span className="inline-flex items-center gap-2 rounded-full border border-white/10 bg-white/5 px-3 py-1 text-xs uppercase tracking-[0.28em] text-[color:var(--ink-2)]">
      <span className="h-1.5 w-1.5 rounded-full bg-[color:var(--accent-1)] shadow-[0_0_12px_var(--accent-1)]" />
      {children}
    </span>
  )
}

export function Kbd({ children }: { children: ReactNode }) {
  return (
    <kbd className="rounded-lg border border-white/10 bg-white/10 px-2 py-1 text-xs font-medium text-[color:var(--ink-1)]">
      {children}
    </kbd>
  )
}

export function InlineCode({ children }: { children: ReactNode }) {
  return (
    <code className="rounded-md border border-white/10 bg-white/10 px-2 py-1 text-[0.85em] text-[color:var(--ink-1)]">
      {children}
    </code>
  )
}

export function Link(props: ComponentPropsWithoutRef<'a'>) {
  return (
    <a
      {...props}
      className="text-[color:var(--accent-1)] underline decoration-[color:var(--accent-1)]/40 underline-offset-4 transition hover:text-white hover:decoration-white/60"
    />
  )
}

export const mdxComponents = {
  Callout,
  Badge,
  Kbd,
  InlineCode,
  a: Link,
}
