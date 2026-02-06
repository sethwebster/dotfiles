import { MDXProvider } from '@mdx-js/react'
import LandingContent from './content/landing.mdx'
import { Faq } from './components/faq'
import { mdxComponents } from './components/mdx-components'

export default function App() {
  return (
    <div className="relative min-h-screen overflow-hidden">
      <div
        className="pointer-events-none absolute inset-0 opacity-60"
        style={{
          backgroundImage:
            'linear-gradient(transparent 0%, rgba(255,255,255,0.02) 50%, transparent 100%),' +
            'linear-gradient(90deg, rgba(255,255,255,0.05) 1px, transparent 1px)',
          backgroundSize: '100% 120px, 120px 120px',
          maskImage:
            'radial-gradient(circle at top, rgba(0,0,0,0.9), transparent 70%)',
        }}
      />

      <header className="relative z-10 border-b border-white/5">
        <div className="mx-auto flex w-full max-w-6xl items-center justify-between px-6 py-6">
          <div className="flex items-center gap-3">
            <div className="flex h-11 w-11 items-center justify-center rounded-2xl border border-white/10 bg-white/10 text-lg font-semibold text-white">
              DF
            </div>
            <div className="text-sm uppercase tracking-[0.3em] text-[color:var(--ink-2)]">
              Dotfiles
            </div>
          </div>
          <nav className="hidden items-center gap-8 text-sm text-[color:var(--ink-2)] md:flex">
            <a className="transition hover:text-white" href="#guides">
              Guides
            </a>
            <a className="transition hover:text-white" href="#platform">
              Platform
            </a>
            <a className="transition hover:text-white" href="#faq">
              FAQ
            </a>
          </nav>
          <div className="flex items-center gap-3">
            <button className="hidden rounded-full border border-white/10 px-5 py-2 text-xs uppercase tracking-[0.3em] text-[color:var(--ink-2)] transition hover:border-white/30 hover:text-white md:inline-flex">
              Contact
            </button>
            <button className="rounded-full bg-white px-5 py-2 text-xs font-semibold uppercase tracking-[0.3em] text-black shadow-[0_20px_60px_rgba(124,155,255,0.25)] transition hover:translate-y-[-1px] hover:shadow-[0_20px_70px_rgba(124,155,255,0.35)]">
              Get Dotfiles
            </button>
          </div>
        </div>
      </header>

      <main className="relative z-10">
        <section className="mx-auto flex w-full max-w-6xl flex-col gap-10 px-6 pb-20 pt-16 md:flex-row md:items-center">
          <div className="flex-1 space-y-8">
            <div className="flex items-center gap-3 text-xs uppercase tracking-[0.3em] text-[color:var(--ink-2)]">
              <span className="h-2 w-2 rounded-full bg-[color:var(--accent-1)] shadow-[0_0_16px_var(--accent-1)]" />
              GitHub-grade dotfiles, built for teams
            </div>
            <h1 className="text-4xl font-semibold leading-tight text-white md:text-6xl">
              Build dotfiles that feel
              <span className="text-[color:var(--accent-1)]"> inevitable</span>.
            </h1>
            <p className="max-w-xl text-base text-[color:var(--ink-2)] md:text-lg">
              A Vite + React + MDX system that captures GitHub-quality
              polish, but ships as a static, blazing-fast SPA. Perfect for
              dotfiles, setup guides, and team onboarding.
            </p>
            <div className="flex flex-wrap items-center gap-4">
              <button className="rounded-full bg-[color:var(--accent-1)] px-6 py-3 text-xs font-semibold uppercase tracking-[0.35em] text-black shadow-[0_20px_70px_rgba(125,255,216,0.4)] transition hover:translate-y-[-1px]">
                Start Reading
              </button>
              <button className="rounded-full border border-white/15 px-6 py-3 text-xs font-semibold uppercase tracking-[0.35em] text-white transition hover:border-white/40">
                View Components
              </button>
            </div>
          </div>
          <div className="flex-1">
            <div className="relative overflow-hidden rounded-[32px] border border-white/10 bg-white/5 p-8 shadow-[0_30px_80px_rgba(0,0,0,0.45)]">
              <div className="absolute right-6 top-6 h-24 w-24 rounded-full bg-[color:var(--accent-0)] opacity-20 blur-3xl" />
              <div className="space-y-6">
                <div className="flex items-center justify-between text-xs uppercase tracking-[0.35em] text-[color:var(--ink-2)]">
                  <span>Signal</span>
                  <span>v4</span>
                </div>
                <h2 className="text-2xl font-semibold text-white">
                  Dotfiles that ship with your repo.
                </h2>
                <p className="text-sm text-[color:var(--ink-2)]">
                  Author in Markdown, enhance with React components, and
                  deploy a single static artifact. No server, no surprises.
                </p>
                <div className="grid gap-4 md:grid-cols-2">
                  {[
                    { title: 'MDX Content', body: 'Composable content blocks.' },
                    { title: 'Radix UI', body: 'Accessible primitives.' },
                    { title: 'Tailwind v4', body: 'Design tokens with speed.' },
                    { title: 'Static Build', body: 'GitHub Pages ready.' },
                  ].map((card) => (
                    <div
                      key={card.title}
                      className="rounded-2xl border border-white/10 bg-white/5 p-4"
                    >
                      <div className="text-sm font-semibold text-white">
                        {card.title}
                      </div>
                      <div className="mt-2 text-xs text-[color:var(--ink-2)]">
                        {card.body}
                      </div>
                    </div>
                  ))}
                </div>
                <div className="rounded-2xl border border-white/10 bg-black/40 p-4 font-mono text-xs text-[color:var(--ink-1)]">
                  bun run build
                  <div className="mt-2 text-[color:var(--ink-2)]">
                    → dist/ ready for deployment
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>

        <section
          id="guides"
          className="mx-auto grid w-full max-w-6xl gap-12 px-6 pb-16 md:grid-cols-[1.2fr_0.8fr]"
        >
          <div className="rounded-[28px] border border-white/10 bg-white/5 p-8">
            <MDXProvider components={mdxComponents}>
              <div className="prose prose-invert max-w-none">
                <LandingContent />
              </div>
            </MDXProvider>
          </div>
          <div className="space-y-6">
            <div className="rounded-[28px] border border-white/10 bg-white/5 p-6">
              <div className="text-xs uppercase tracking-[0.3em] text-[color:var(--ink-2)]">
                Layout map
              </div>
              <ul className="mt-4 space-y-4 text-sm text-[color:var(--ink-2)]">
                {[
                  'Hero + navigation shell',
                  'MDX-driven narrative',
                  'Feature grid + CTA',
                  'Radix FAQ section',
                ].map((item) => (
                  <li key={item} className="flex items-start gap-3">
                    <span className="mt-1 h-2 w-2 rounded-full bg-[color:var(--accent-0)]" />
                    {item}
                  </li>
                ))}
              </ul>
            </div>
            <div className="rounded-[28px] border border-white/10 bg-white/5 p-6">
              <div className="text-xs uppercase tracking-[0.3em] text-[color:var(--ink-2)]">
                Focus
              </div>
              <p className="mt-4 text-sm text-[color:var(--ink-2)]">
                The visual system mirrors GitHub-quality clarity, but adds
                a cinematic palette, oversized typography, and deliberate
                motion.
              </p>
            </div>
          </div>
        </section>

        <section
          id="platform"
          className="mx-auto w-full max-w-6xl px-6 pb-16"
        >
          <div className="grid gap-6 md:grid-cols-3">
            {[
              {
                title: 'Content-first IA',
                body: 'MDX keeps writers in control while React handles layout.',
              },
              {
                title: 'Composable primitives',
                body: 'Radix makes accessibility effortless without visual noise.',
              },
              {
                title: 'Static reliability',
                body: 'No server, no runtime build. Just deploy the build output.',
              },
            ].map((item) => (
              <div
                key={item.title}
                className="rounded-[24px] border border-white/10 bg-white/5 p-6"
              >
                <div className="text-lg font-semibold text-white">
                  {item.title}
                </div>
                <p className="mt-3 text-sm text-[color:var(--ink-2)]">
                  {item.body}
                </p>
              </div>
            ))}
          </div>
        </section>

        <section
          id="faq"
          className="mx-auto w-full max-w-6xl px-6 pb-24"
        >
          <div className="flex flex-col gap-6 rounded-[32px] border border-white/10 bg-white/5 p-8">
            <div>
              <div className="text-xs uppercase tracking-[0.3em] text-[color:var(--ink-2)]">
                FAQ
              </div>
              <h2 className="mt-4 text-2xl font-semibold text-white">
                The essentials, clarified.
              </h2>
            </div>
            <Faq />
          </div>
        </section>
      </main>

      <footer className="relative z-10 border-t border-white/5">
        <div className="mx-auto flex w-full max-w-6xl flex-col gap-6 px-6 py-10 text-sm text-[color:var(--ink-2)] md:flex-row md:items-center md:justify-between">
          <div className="space-y-2">
            <div className="text-xs uppercase tracking-[0.3em]">
              Dotfiles
            </div>
            <div>Static build ready for GitHub Pages.</div>
          </div>
          <div className="flex flex-wrap gap-6 text-xs uppercase tracking-[0.3em]">
            <span>MDX</span>
            <span>Vite</span>
            <span>Tailwind v4</span>
            <span>Radix</span>
          </div>
        </div>
      </footer>
    </div>
  )
}
