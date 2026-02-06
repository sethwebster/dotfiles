import * as Accordion from '@radix-ui/react-accordion'
import { ChevronDownIcon } from '@radix-ui/react-icons'

const faqs = [
  {
    question: 'Is this compatible with GitHub Pages?',
    answer:
      'Yes. The build is static, and the Vite base is set to relative paths so the site can live in any subdirectory.',
  },
  {
    question: 'Where does the content live?',
    answer:
      'Markdown and MDX live in src/content. The landing page imports MDX directly, so editing content is instant.',
  },
  {
    question: 'Why Radix?',
    answer:
      'Radix provides accessible primitives without visual opinion, perfect for a crisp product aesthetic.',
  },
]

export function Faq() {
  return (
    <Accordion.Root
      type="single"
      collapsible
      className="space-y-3"
    >
      {faqs.map((item) => (
        <Accordion.Item
          key={item.question}
          value={item.question}
          className="rounded-2xl border border-white/10 bg-white/5 px-6 py-4"
        >
          <Accordion.Header>
            <Accordion.Trigger className="group flex w-full items-center justify-between text-left text-base font-semibold text-[color:var(--ink-0)]">
              <span>{item.question}</span>
              <ChevronDownIcon className="h-5 w-5 text-[color:var(--ink-2)] transition group-data-[state=open]:rotate-180" />
            </Accordion.Trigger>
          </Accordion.Header>
          <Accordion.Content className="overflow-hidden text-sm text-[color:var(--ink-2)] data-[state=open]:mt-3 data-[state=open]:animate-accordion-down data-[state=closed]:animate-accordion-up">
            {item.answer}
          </Accordion.Content>
        </Accordion.Item>
      ))}
    </Accordion.Root>
  )
}
