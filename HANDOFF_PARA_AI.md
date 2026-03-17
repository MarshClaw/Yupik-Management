# YUPIK OUTDOOR — HANDOFF COMPLETO PARA OPUS 4.6
# Data: 17 de Março de 2026
# De: Claude Sonnet 4.6
# Para: Claude Opus 4.6

---

## CONTEXTO DO UTILIZADOR

**Márcio Monteiro** — CEO e co-fundador da Yupik Outdoor, Lda.
- Loja de equipamento outdoor em Lisboa, Portugal
- Parceiros: Carlos Subtil (está temporariamente incapacitado por acidente), + 1 sócio
- Equipa: Kátia Mendes (administrativa), Nathália (marketing), Diogo, João Santos, Daniel
- Repositório GitHub: https://github.com/MarshClaw/Yupik-Management
- Email: marcio.monteiro@yupik.com.pt

---

## O QUE EXISTE: SISTEMA DE GESTÃO DE TESOURARIA

App React com 7 módulos:
1. **Pagamentos** — Contas a pagar, contas bancárias, histórico, categorias
2. **Confirming** — Abanca (plafond 20k) e BPI (plafond 40k), calendário, projeção 18 meses
3. **Contas Corrente** — Fornecedores e clientes, faturas, saldos positivos/negativos
4. **Vendas** — Fecho diário, comparativo anual (2022-2026), emails automáticos
5. **Comissões** — Cálculo por colaborador, quadro para afixar, regras editáveis
6. **Cofre** — Numerário (fundo fixo 290€), movimentos, depósitos para banco
7. **Tarefas** — Delegação Kátia/Márcio, prioridades, ligação a Pagamentos

Stack: React 18, Recharts 2.8.0, Lucide React 0.383.0, Tailwind CSS

---

## PROBLEMA ATUAL A RESOLVER

O ficheiro `YupikTesouraria.html` abre **página em branco** no browser do Márcio.

**Diagnóstico confirmado:**
- Bundle JS compilado com esbuild: ✅ sintaxe válida, React + Recharts + Lucide embutidos (985KB)
- `createRoot` presente: ✅
- `YupikApp` presente: ✅
- Sem `</script>` partidos no bundle: ✅
- **CAUSA RAIZ:** O ficheiro é aberto como `file://` no Chrome, que bloqueia o carregamento do `cdn.tailwindcss.com` (Tailwind CDN)
- Sem Tailwind CSS → componentes React rendem sem estilos → `LoginScreen` tem `min-h-screen flex items-center justify-center` sem CSS → altura 0px → página aparece em branco

**Soluções possíveis (por ordem de preferência):**

### Opção A — Script de lançamento (JÁ CRIADO)
O ficheiro `ABRIR_YUPIK.bat` inicia um servidor Python local e abre o browser em `http://localhost:8080/YupikTesouraria.html`. O utilizador faz duplo clique no .bat. Funciona se Python estiver instalado.

### Opção B — Embutir Tailwind CSS inline (RECOMENDADO PARA OPUS)
Gerar o CSS do Tailwind apenas com as classes usadas no YupikApp.jsx e embutir no HTML. Isso elimina a dependência CDN e o ficheiro funciona offline como `file://`.
Comando: `npx tailwindcss -i input.css -o output.css --content "./App.jsx"`
Depois embutir o CSS no `<style>` do HTML.

### Opção C — Adicionar inline styles críticos ao LoginScreen
O problema visível é que sem Tailwind o `LoginScreen` não tem altura. Basta adicionar:
`style={{..., minHeight:'100vh', display:'flex', alignItems:'center', justifyContent:'center'}}`
(Já implementado no YupikApp.jsx atual mas precisa rebuildar o HTML)

### Opção D — StackBlitz (para testar e desenvolver)
Abrir stackblitz.com/fork/react, colar o YupikApp.jsx em src/App.js, adicionar dependências no package.json e Tailwind CDN no index.html.

---

## ESTADO DAS CORREÇÕES (25/25 IMPLEMENTADAS)

Todas as correções pedidas foram implementadas. Ver secção detalhada abaixo.

**Confirming:**
1. ✅ Botões Gravar/Cancelar: sticky footer `flex-shrink-0 border-t bg-white px-6 py-4`
2. ✅ Saldo CC negativo: `getInvBalance` permite negativos, exibe "A nosso favor: X€" verde
3. ✅ CF aparece em Pagamentos: entrada automática `_cfEntry:true, partials:[]` ao agendar
4. ✅ Débito limpa "CF pend.deb.": `addDeb()` faz `pendingDebit:false` + `debitDate`
5. ✅ Modal débito com todas as contas + atualiza saldo: `bankAccounts.filter(!archived)`

**Pagamentos:**
6. ✅ Criar contas bancárias: modal com nome, saldo, métodos, taxa TPA
7. ✅ Arquivar contas: `archived:true`, modal "Arquivadas" com Restaurar
8. ✅ Métodos por conta: HiPay→[Ref MB, Visa Onl., MB Way], PayPal→[PayPal], etc.
9. ✅ Histórico pagamentos: últimos 10, "Ver todos" por ano, download CSV
10. ✅ Categorização com prompt ao registar pagamento sem categoria
11. ✅ Criar categorias personalizadas com color picker

**Vendas:**
12. ✅ Fecho diário: botão ✓ soma métodos às contas via `paymentMethods` lookup
13. ✅ Cartões: modal distribuição por banco com TPA automático
14. ✅ Comissões TPA: auto-registadas em Pagamentos como categoria "comissoesTPA"
15. ✅ Email mensal: colunas alinhadas com `padStart`/`padEnd` monospace
16. ✅ "não é vendas diretas" → texto removido
17. ✅ "pagas como adiantamento" → "registadas como adiantamento"

**Tarefas:**
18. ✅ Conclusão: atualiza Pagamentos + saldo bancário + histórico

**Comissões:**
19. ✅ Quadro imprimível: `window.print()`
20. ✅ Regras editáveis: modal com tiers, taxas, notas

**Cofre:**
21. ✅ Painel completo: fundo fixo, saldo anterior, movimentos, saldo corrente
22. ✅ Depósito para banco: `processDeposit()` + `setBankAccounts`

**Geral:**
23. ✅ Contas arquivadas: histórico preservado, consulta possível
24. ✅ CC saldos negativos: "A nosso favor: X€" em verde
25. ✅ Tarefas bank lookup: `activeBanks.find(b => b.id === task.bank)`

---

## DADOS INICIAIS CARREGADOS

**Contas Bancárias (INIT_BANK_ACCOUNTS):**
- Abanca: 33,78€ | TPA 1% | Métodos: Confirming Abanca
- BPI: 642,64€ | TPA 1% | Métodos: Confirming BPI
- CGD: 0€
- Montepio: 0€
- HiPay: 2.123,78€ | Métodos: Ref MB, Visa Onl., MB Way
- PayPal: 571,66€ | Métodos: PayPal
- Numerário: 862,85€ | Métodos: Dinheiro

**Contas Corrente Fornecedores:**
Scarpa (4 fat., ~38k€), Redicom (FAC25/738, 8.560,80€ qd liquidada), 
Equip UK, Trangoworld, SSO Portugal, Black Diamond (3.298,46€), Garmont (4.375,84€)

**Contas Corrente Clientes:**
Escala25 (162,28€), Crux (2 faturas), The West (2 faturas)

**Confirming ativo (5 entradas):**
Scarpa 2.733,44€ deb Jun26 | Equip UK 2.636,94€ deb Jun26 | Boreal 1.591,85€ deb Jun26
YY Vertical 700€ deb Jun26 | Dicaltex 439,82€ deb Mar10 (BPI)

**Vendas Março 2026 (6 dias):**
02-07 Mar, ~1.000-1.500€/dia loja + site

**Comissões:**
Tiers: ≤14.999→1%, ≤30.000→1,5%, >30.000→2%
Colaboradores: Carlos Subtil, Kátia Mendes, Joana Santos, Ana Silva
Nota: Distribuição NÃO incluída. Vales NÃO contam. Vales Reg. CONTAM.

**Cofre:** Fundo fixo 290€, saldo anterior 288,82€

---

## PRÓXIMAS FUNCIONALIDADES (NÃO IMPLEMENTADAS)

1. **Persistência localStorage** — PRIORIDADE ALTA (dados perdem-se ao fechar)
2. **Upload PDF PHC** — fecho de caixa automático
3. **Integração PHC Evolution API** — sincronizar faturas
4. **Multi-utilizador** — permissões Márcio/Kátia/Carlos
5. **Dashboard executivo** — KPIs resumidos

---

## NOTA SOBRE GITHUB

A integração direta Claude.ai ↔ GitHub tem bug confirmado (issues Anthropic #12839, #18467, #27155, #33875). Repositórios pessoais não aparecem no picker mesmo com GitHub App instalado. Workflow manual: editar código aqui → utilizador copia para GitHub.

---

## CÓDIGO FONTE COMPLETO (YupikApp.jsx — 2768 linhas)


```jsx
import { useState, useMemo, useCallback } from "react";
import {
  Wallet, TrendingUp, TrendingDown, Calendar, FileText,
  Download, Plus, Edit3, Trash2, Search, Filter, Bell,
  ChevronDown, ChevronRight, ChevronUp, ArrowUpRight, ArrowDownRight,
  AlertTriangle, CheckCircle, Clock, DollarSign, Building2,
  CreditCard, PieChart, BarChart3, Settings, X, Check,
  Send, Copy, Eye, EyeOff, RefreshCw, Briefcase, Users,
  AlertCircle, ArrowRight, Banknote, Target, Layers, Star,
  StarOff, ExternalLink, Mail, Minus, MoreHorizontal, Pin, Archive
} from "lucide-react";
import {
  BarChart, Bar, LineChart, Line, XAxis, YAxis, CartesianGrid,
  Tooltip, Legend, ResponsiveContainer, PieChart as RePieChart,
  Pie, Cell, AreaChart, Area
} from "recharts";

// ==================== UTILITIES ====================
const fmt = (v) => new Intl.NumberFormat('pt-PT', { style: 'currency', currency: 'EUR' }).format(v ?? 0);
const fmtNum = (v) => new Intl.NumberFormat('pt-PT', { minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(v ?? 0);
const fmtDate = (d) => { if (!d) return "—"; const dt = new Date(d); return `${String(dt.getDate()).padStart(2,'0')}.${String(dt.getMonth()+1).padStart(2,'0')}.${String(dt.getFullYear()).slice(-2)}`; };
const fmtDateFull = (d) => { if (!d) return "—"; const dt = new Date(d); return `${String(dt.getDate()).padStart(2,'0')}.${String(dt.getMonth()+1).padStart(2,'0')}.${dt.getFullYear()}`; };
const TODAY = "2026-03-08";
const todayDate = new Date(TODAY);
const isOverdue = (d) => new Date(d) < todayDate;
const daysUntil = (d) => Math.ceil((new Date(d) - todayDate) / (1000*60*60*24));
const genId = () => Date.now() + Math.random();

// ==================== PAYMENT CATEGORIES ====================
const DEFAULT_CATEGORIES = {
  salarios: { label: "Salários", color: "#dc2626" },
  confirming: { label: "Confirming", color: "#7c3aed" },
  impostos: { label: "Impostos/Fiscais", color: "#d97706" },
  fornecedor: { label: "Fornecedores", color: "#2563eb" },
  telecom: { label: "Telecomunicações", color: "#0891b2" },
  servicos: { label: "Serviços", color: "#059669" },
  logistica: { label: "Logística", color: "#db2777" },
  contabilidade: { label: "Contabilidade", color: "#4f46e5" },
  comissoesTPA: { label: "Comissões TPA", color: "#f59e0b" },
  outros: { label: "Outros", color: "#78716c" },
};

// ==================== UI COMPONENTS ====================
const Badge = ({ children, variant = "default", className = "" }) => {
  const v = {
    default: "bg-stone-100 text-stone-600",
    danger: "bg-red-50 text-red-700 ring-1 ring-red-200",
    warning: "bg-amber-50 text-amber-700 ring-1 ring-amber-200",
    success: "bg-emerald-50 text-emerald-700 ring-1 ring-emerald-200",
    info: "bg-sky-50 text-sky-700 ring-1 ring-sky-200",
    purple: "bg-violet-50 text-violet-700 ring-1 ring-violet-200",
    priority: "bg-orange-50 text-orange-700 ring-1 ring-orange-200"
  };
  return <span className={`inline-flex items-center px-2 py-0.5 rounded-md text-[11px] font-semibold tracking-wide ${v[variant]||v.default} ${className}`}>{children}</span>;
};

const Card = ({ children, className = "", ...p }) =>
  <div className={`bg-white rounded-xl border border-stone-200/80 shadow-sm ${className}`} {...p}>{children}</div>;

const Button = ({ children, variant = "default", size = "md", className = "", ...p }) => {
  const vs = {
    default: "bg-stone-800 text-white hover:bg-stone-700",
    outline: "border border-stone-300 text-stone-700 hover:bg-stone-50",
    ghost: "text-stone-500 hover:bg-stone-100 hover:text-stone-700",
    danger: "bg-red-600 text-white hover:bg-red-700",
    success: "bg-emerald-600 text-white hover:bg-emerald-700",
    priority: "bg-orange-500 text-white hover:bg-orange-600"
  };
  const ss = { xs: "px-2 py-0.5 text-[11px]", sm: "px-2.5 py-1 text-xs", md: "px-3.5 py-2 text-sm", lg: "px-5 py-2.5 text-sm" };
  return <button className={`inline-flex items-center justify-center gap-1.5 rounded-lg font-medium transition-all active:scale-[0.98] disabled:opacity-40 ${vs[variant]} ${ss[size]} ${className}`} {...p}>{children}</button>;
};

const Modal = ({ open, onClose, title, children, wide, noPad }) => {
  if (!open) return null;
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4" style={{ backgroundColor: 'rgba(15,15,15,0.45)', backdropFilter: 'blur(4px)' }}>
      <div className={`bg-white rounded-2xl shadow-2xl ${wide ? 'max-w-5xl' : 'max-w-xl'} w-full max-h-[88vh] flex flex-col`}>
        <div className="flex items-center justify-between px-6 py-4 border-b border-stone-100 flex-shrink-0">
          <h3 className="text-[15px] font-semibold text-stone-900">{title}</h3>
          <button onClick={onClose} className="p-1.5 rounded-lg hover:bg-stone-100 transition-colors"><X size={16} /></button>
        </div>
        <div className={`${noPad ? '' : 'px-6 py-5'} overflow-auto flex-1`}>{children}</div>
      </div>
    </div>
  );
};

const Input = ({ label, ...p }) => (
  <div>
    <label className="block text-[11px] font-medium text-stone-500 mb-1 uppercase tracking-wider">{label}</label>
    <input className="w-full px-3 py-2 rounded-lg border border-stone-200 text-sm focus:outline-none focus:ring-2 focus:ring-stone-300 focus:border-stone-400 transition-all" {...p} />
  </div>
);

const Select = ({ label, children, ...p }) => (
  <div>
    <label className="block text-[11px] font-medium text-stone-500 mb-1 uppercase tracking-wider">{label}</label>
    <select className="w-full px-3 py-2 rounded-lg border border-stone-200 text-sm focus:outline-none focus:ring-2 focus:ring-stone-300 bg-white" {...p}>{children}</select>
  </div>
);

// ==================== INITIAL DATA ====================
const INIT_BANK_ACCOUNTS = [
  { id: "abanca", name: "Abanca", balance: 33.78, paymentMethods: ["Confirming Abanca"], archived: false, tpaRate: 1.0 },
  { id: "bpi", name: "BPI", balance: 642.64, paymentMethods: ["Confirming BPI"], archived: false, tpaRate: 1.0 },
  { id: "cgd", name: "CGD", balance: 0, paymentMethods: [], archived: false, tpaRate: 0 },
  { id: "montepio", name: "Montepio", balance: 0, paymentMethods: [], archived: false, tpaRate: 0 },
  { id: "hipay", name: "HiPay", balance: 2123.78, paymentMethods: ["Ref MB", "Visa Onl.", "MB Way"], archived: false, tpaRate: 0 },
  { id: "paypal", name: "PayPal", balance: 571.66, paymentMethods: ["PayPal"], archived: false, tpaRate: 0 },
  { id: "numerario", name: "Numerário", balance: 862.85, paymentMethods: ["Dinheiro"], archived: false, tpaRate: 0 },
];

const INIT_PAYABLES = [
  { id:1, supplier:"Salários Yupik", doc:"", amount:13585.01, dueDate:"2026-02-28", category:"salarios", bank:"", method:"Transferência bancária", pinned:false, partials:[], ccLink:false },
  { id:2, supplier:"Confirming ABA — Scarpa", doc:"CO", amount:1390.40, dueDate:"2026-02-13", category:"confirming", bank:"abanca", method:"Confirming Abanca", pinned:false, partials:[], ccLink:false },
  { id:3, supplier:"Confirming ABA — Equip UK", doc:"CO", amount:2636.94, dueDate:"2026-02-16", category:"confirming", bank:"abanca", method:"Confirming Abanca", pinned:false, partials:[], ccLink:false },
  { id:4, supplier:"Confirming ABA — Boreal", doc:"CO", amount:1591.85, dueDate:"2026-02-23", category:"confirming", bank:"abanca", method:"Confirming Abanca", pinned:false, partials:[], ccLink:false },
  { id:5, supplier:"Confirming ABA — YY Vertical", doc:"CO", amount:700.00, dueDate:"2026-02-25", category:"confirming", bank:"abanca", method:"Confirming Abanca", pinned:false, partials:[], ccLink:false },
  { id:6, supplier:"Confirming BPI", doc:"CO", amount:439.82, dueDate:"2026-03-10", category:"confirming", bank:"bpi", method:"Confirming BPI", pinned:false, partials:[], ccLink:false },
  { id:7, supplier:"MEO", doc:"FT 707650940", amount:121.52, dueDate:"2026-03-08", category:"telecom", bank:"", method:"Transferência bancária", pinned:true, partials:[], ccLink:false },
  { id:8, supplier:"AR Telecom", doc:"F26_001853", amount:190.80, dueDate:"2026-03-03", category:"telecom", bank:"", method:"Transferência bancária", pinned:false, partials:[], ccLink:false },
  { id:9, supplier:"ThinkOpen", doc:"FT 2026_0978", amount:79.91, dueDate:"2026-03-01", category:"servicos", bank:"", method:"Transferência bancária", pinned:false, partials:[], ccLink:false },
  { id:10, supplier:"InterCourier", doc:"FA.20251652", amount:246.85, dueDate:"2026-03-01", category:"logistica", bank:"", method:"Transferência bancária", pinned:false, partials:[], ccLink:false },
  { id:11, supplier:"KornImprime", doc:"1SEC126/306", amount:439.73, dueDate:"2026-03-01", category:"servicos", bank:"", method:"Transferência bancária", pinned:false, partials:[], ccLink:false },
  { id:12, supplier:"Manuel Nabeiro", doc:"FT 1960439373", amount:76.24, dueDate:"2026-03-01", category:"fornecedor", bank:"", method:"Transferência bancária", pinned:false, partials:[], ccLink:false },
  { id:13, supplier:"BestAccount", doc:"FAC 25_1012", amount:473.55, dueDate:"2026-03-01", category:"contabilidade", bank:"", method:"Transferência bancária", pinned:false, partials:[], ccLink:false },
  { id:14, supplier:"IVA Abril 25 (3/3)", doc:"", amount:3775.93, dueDate:"2026-03-15", category:"impostos", bank:"", method:"Transferência bancária", pinned:false, partials:[], ccLink:false },
  { id:15, supplier:"IVA Maio 25 (2/3)", doc:"", amount:3164.00, dueDate:"2026-03-15", category:"impostos", bank:"", method:"Transferência bancária", pinned:false, partials:[], ccLink:false },
  { id:16, supplier:"IRS Out 25", doc:"", amount:984.00, dueDate:"2026-03-20", category:"impostos", bank:"", method:"Transferência bancária", pinned:false, partials:[], ccLink:false },
  { id:17, supplier:"TSU Out 25", doc:"", amount:5405.89, dueDate:"2026-03-20", category:"impostos", bank:"", method:"Transferência bancária", pinned:false, partials:[], ccLink:false },
  { id:18, supplier:"Black Diamond", doc:"", amount:3298.46, dueDate:"2026-04-01", category:"fornecedor", bank:"", method:"Transferência bancária", pinned:false, partials:[], ccLink:true },
  { id:19, supplier:"Garmont", doc:"", amount:4375.84, dueDate:"2026-04-01", category:"fornecedor", bank:"", method:"Transferência bancária", pinned:false, partials:[], ccLink:true },
  { id:20, supplier:"Jack Wolfskin", doc:"INV 920471341", amount:2461.54, dueDate:"2026-03-15", category:"fornecedor", bank:"", method:"Transferência bancária", pinned:false, partials:[], ccLink:true },
  { id:21, supplier:"Unit Legal", doc:"FT 2026A1/40", amount:851.78, dueDate:"2026-02-10", category:"servicos", bank:"", method:"Transferência bancária", pinned:false, partials:[], ccLink:false },
  { id:22, supplier:"IVA Dez 25", doc:"", amount:5627.25, dueDate:"2026-02-25", category:"impostos", bank:"", method:"Transferência bancária", pinned:false, partials:[], ccLink:false },
  { id:23, supplier:"Edelweiss", doc:"EVF250116", amount:772.34, dueDate:"2026-03-22", category:"fornecedor", bank:"", method:"Transferência bancária", pinned:false, partials:[], ccLink:true },
  { id:24, supplier:"Beal", doc:"BVF2508356+BVF2508624", amount:2976.65, dueDate:"2026-04-01", category:"fornecedor", bank:"", method:"Transferência bancária", pinned:false, partials:[], ccLink:true },
  { id:25, supplier:"Patagonia", doc:"P0001151611", amount:1237.90, dueDate:"2026-04-15", category:"fornecedor", bank:"", method:"Transferência bancária", pinned:false, partials:[], ccLink:true },
];

const INIT_CC_SUPPLIERS = [
  { id:1, name:"Scarpa", type:"fornecedor", invoices:[
    { id:101, doc:"2023FE02027", amount:4733.44, dueDate:"2025-06-24", partials:[{date:"2025-06-24",amount:2000}], plannedDate:"2026-03-20", plannedAmount:2733.44 },
    { id:102, doc:"2023FE02882", amount:5945.03, dueDate:"2025-04-27", partials:[{date:"2026-04-27",amount:1700}], plannedDate:"2026-05-15", plannedAmount:2245.03 },
    { id:103, doc:"2023FE03067", amount:5872.18, dueDate:"2025-06-17", partials:[], plannedDate:"", plannedAmount:0 },
    { id:104, doc:"2023FE03068", amount:21575.87, dueDate:"2025-08-19", partials:[], plannedDate:"", plannedAmount:0 },
  ]},
  { id:2, name:"Redicom", type:"fornecedor", invoices:[
    { id:201, doc:"FAC 25/738", amount:8560.80, dueDate:"2025-07-07", partials:[{date:"2025-08-07",amount:1000},{date:"2025-09-22",amount:1000},{date:"2025-09-29",amount:2000},{date:"2025-10-06",amount:1000},{date:"2025-10-07",amount:1000},{date:"2026-02-18",amount:1460.80}], plannedDate:"", plannedAmount:0 },
  ]},
  { id:3, name:"Equip UK", type:"fornecedor", invoices:[
    { id:301, doc:"SI2512-07360", amount:308.58, dueDate:"2026-02-23", partials:[{date:"2026-02-23",amount:308.58}], plannedDate:"", plannedAmount:0 },
    { id:302, doc:"SI2512-07363", amount:594.94, dueDate:"2026-02-25", partials:[{date:"2026-02-25",amount:594.94}], plannedDate:"", plannedAmount:0 },
    { id:303, doc:"SI2512-10034", amount:3054.06, dueDate:"2026-02-27", partials:[{date:"2026-02-27",amount:1624.06}], plannedDate:"", plannedAmount:0 },
  ]},
  { id:4, name:"Trangoworld", type:"fornecedor", invoices:[
    { id:401, doc:"VF-259902 2/3", amount:1833.64, dueDate:"2026-01-10", partials:[{date:"2025-11-03",amount:1160}], plannedDate:"", plannedAmount:0 },
    { id:402, doc:"VF-259902 3/3", amount:1833.64, dueDate:"2026-01-28", partials:[], plannedDate:"", plannedAmount:0 },
    { id:403, doc:"VF-260488", amount:940.60, dueDate:"2026-01-15", partials:[], plannedDate:"", plannedAmount:0 },
    { id:404, doc:"VF-260651", amount:379.80, dueDate:"2026-01-24", partials:[], plannedDate:"", plannedAmount:0 },
    { id:405, doc:"VF-261245", amount:2719.11, dueDate:"2026-02-05", partials:[], plannedDate:"", plannedAmount:0 },
  ]},
  { id:5, name:"SSO Portugal", type:"fornecedor", invoices:[
    { id:501, doc:"F2 BPA1/6110202458", amount:4452.53, dueDate:"2025-06-23", partials:[], plannedDate:"", plannedAmount:0 },
    { id:502, doc:"F2 BPA1/6110202707", amount:4431.94, dueDate:"2025-07-23", partials:[], plannedDate:"", plannedAmount:0 },
  ]},
  { id:6, name:"Black Diamond", type:"fornecedor", invoices:[
    { id:601, doc:"Various", amount:3298.46, dueDate:"2026-04-01", partials:[], plannedDate:"", plannedAmount:0 },
  ]},
  { id:7, name:"Garmont", type:"fornecedor", invoices:[
    { id:701, doc:"Various", amount:4375.84, dueDate:"2026-04-01", partials:[], plannedDate:"", plannedAmount:0 },
  ]},
];

const INIT_CC_CLIENTS = [
  { id:101, name:"Escala25", type:"cliente", invoices:[
    { id:1001, doc:"FT 2026A1/58", amount:162.28, dueDate:"2026-03-11", partials:[], plannedDate:"", plannedAmount:0 },
  ]},
  { id:102, name:"Crux", type:"cliente", invoices:[
    { id:1002, doc:"FT 2026A1/28 (Ressolagem)", amount:159.41, dueDate:"2026-02-04", partials:[{date:"2026-02-03",amount:706.54}], plannedDate:"", plannedAmount:0 },
    { id:1003, doc:"FT 2026A1/51", amount:393.77, dueDate:"2026-02-20", partials:[], plannedDate:"", plannedAmount:0 },
  ]},
  { id:103, name:"The West", type:"cliente", invoices:[
    { id:1004, doc:"FT 2026A1/15", amount:113.44, dueDate:"2026-01-19", partials:[], plannedDate:"", plannedAmount:0 },
    { id:1005, doc:"FT 2026A1/18", amount:543.68, dueDate:"2026-01-21", partials:[], plannedDate:"", plannedAmount:0 },
  ]},
];

const INIT_COMMISSION_RULES = {
  tiers: [
    { label: "Até 14.999", threshold: 14999, rate: 0.01 },
    { label: "> 15.000", threshold: 30000, rate: 0.015 },
    { label: "> 30.000", threshold: Infinity, rate: 0.02 },
  ],
  websiteRate: 0.01,
  employees: [
    { id:1, name:"CS", fullName:"Carlos Subtil", baseSalary:760, alimentDays:21, alimentRate:7.63, abono:30, tsu:0.11, irs:0.074 },
    { id:2, name:"KAT", fullName:"Kátia Mendes", baseSalary:1200, alimentDays:22, alimentRate:7, abono:0, tsu:0.11, irs:0.0378 },
    { id:3, name:"JS", fullName:"Joana Santos", baseSalary:564, alimentDays:21, alimentRate:7.63, abono:0, tsu:0.11, irs:0.0378 },
    { id:4, name:"AS", fullName:"Ana Silva", baseSalary:760, alimentDays:14, alimentRate:4.77, abono:0, tsu:0.11, irs:0.0378 },
  ],
  excludeDistribution: true,
  includeSite: true,
  notes: "Distribuição NÃO incluída. Recibos contam quando emitida fatura final. Vales NÃO contam. Vales Reg. CONTAM."
};

const INIT_COFRE = {
  fundoCaixa: 290,
  saldoAnterior: 288.82,
  movimentos: []
};

// ==================== PAYMENTS MODULE ====================
const PaymentsModule = ({
  payables, setPayables, tasks, setTasks,
  ccSuppliers, setCcSuppliers,
  bankAccounts, setBankAccounts,
  completedPayments, setCompletedPayments,
  categories, setCategories
}) => {
  const [search, setSearch] = useState("");
  const [filterCat, setFilterCat] = useState("all");
  const [filterStatus, setFilterStatus] = useState("all");
  const [sortField, setSortField] = useState("dueDate");
  const [sortDir, setSortDir] = useState("asc");
  const [showAdd, setShowAdd] = useState(false);
  const [showPartial, setShowPartial] = useState(null);
  const [showTaskModal, setShowTaskModal] = useState(null);
  const [partialData, setPartialData] = useState({ date: TODAY, amount: "", bankId: "" });
  const [newPay, setNewPay] = useState({ supplier:"", doc:"", amount:"", dueDate:"", category:"fornecedor", method:"Transferência bancária", bank:"", ccLink:false });
  const [taskData, setTaskData] = useState({ assignee:"Kátia Mendes", dueDate:TODAY, method:"Transferência bancária", bank:"", notes:"" });
  const [showNewBankModal, setShowNewBankModal] = useState(false);
  const [showArchivedAccounts, setShowArchivedAccounts] = useState(false);
  const [showPaymentHistory, setShowPaymentHistory] = useState(false);
  const [historyYear, setHistoryYear] = useState(2026);
  const [showCategoryPrompt, setShowCategoryPrompt] = useState(null);
  const [categoryPromptData, setCategoryPromptData] = useState({ category:"", amount:0, date:TODAY, payableId:null, bankId:"" });
  const [newBank, setNewBank] = useState({ name:"", initialBalance:"", paymentMethods:[], tpaRate:"" });
  const [showNewCatModal, setShowNewCatModal] = useState(false);
  const [newCat, setNewCat] = useState({ key:"", label:"", color:"#6366f1" });

  const getBalance = (p) => p.amount - p.partials.reduce((s, pp) => s + pp.amount, 0);
  const activeBanks = bankAccounts.filter(b => !b.archived);
  const archivedBanks = bankAccounts.filter(b => b.archived);
  const allMethods = [...new Set(bankAccounts.flatMap(b => b.paymentMethods)), "Transferência bancária", "Outro"];

  const pinnedPayables = useMemo(() =>
    payables.filter(p => p.pinned && getBalance(p) > 0).sort((a,b) => new Date(a.dueDate) - new Date(b.dueDate)),
    [payables]
  );

  const filteredPayables = useMemo(() => {
    let f = payables.filter(p => !p.pinned && getBalance(p) > 0);
    if (search) {
      const s = search.toLowerCase();
      f = f.filter(p => p.supplier.toLowerCase().includes(s) || p.doc.toLowerCase().includes(s) || String(p.amount).includes(s));
    }
    if (filterCat !== "all") f = f.filter(p => p.category === filterCat);
    if (filterStatus === "vencido") f = f.filter(p => isOverdue(p.dueDate));
    if (filterStatus === "pendente") f = f.filter(p => !isOverdue(p.dueDate));
    f.sort((a,b) => {
      let va, vb;
      if (sortField === "dueDate") { va = new Date(a.dueDate); vb = new Date(b.dueDate); }
      else if (sortField === "amount") { va = getBalance(a); vb = getBalance(b); }
      else { va = a.supplier.toLowerCase(); vb = b.supplier.toLowerCase(); }
      return sortDir === "asc" ? (va < vb ? -1 : 1) : (va > vb ? -1 : 1);
    });
    return f;
  }, [payables, search, filterCat, filterStatus, sortField, sortDir]);

  const totalAll = payables.filter(p => getBalance(p) > 0).reduce((s,p) => s + getBalance(p), 0);
  const totalOverdue = payables.filter(p => isOverdue(p.dueDate) && getBalance(p) > 0).reduce((s,p) => s + getBalance(p), 0);
  const totalPinned = pinnedPayables.reduce((s,p) => s + getBalance(p), 0);

  const thisMonth = new Date().getMonth();
  const thisYear = new Date().getFullYear();
  const monthlyPaid = completedPayments.filter(cp => {
    const d = new Date(cp.date);
    return d.getMonth() === thisMonth && d.getFullYear() === thisYear;
  }).reduce((s,cp) => s + cp.amount, 0);

  const categoryBreakdown = completedPayments.filter(cp => {
    const d = new Date(cp.date);
    return d.getMonth() === thisMonth && d.getFullYear() === thisYear;
  }).reduce((acc, cp) => {
    acc[cp.category] = (acc[cp.category] || 0) + cp.amount;
    return acc;
  }, {});

  const togglePin = (id) => setPayables(prev => prev.map(p => p.id === id ? {...p, pinned: !p.pinned} : p));
  const toggleSort = (f) => { if (sortField === f) setSortDir(d => d === "asc" ? "desc" : "asc"); else { setSortField(f); setSortDir("asc"); } };

  // FIX: Payment with category prompt
  const doAddPartial = (payableId, amount, date, bankId, category) => {
    setPayables(prev => prev.map(pp => pp.id === payableId ? { ...pp, partials: [...pp.partials, { date, amount }] } : pp));

    const p = payables.find(pp => pp.id === payableId);
    const finalCategory = category || p?.category || "outros";

    setCompletedPayments(prev => [...prev, {
      id: genId(), date, supplier: p?.supplier || "", amount,
      category: finalCategory, method: p?.method || "", bank: bankId || p?.bank || ""
    }]);

    // FIX: Update bank balance when payment is registered
    if (bankId) {
      setBankAccounts(prev => prev.map(b => b.id === bankId ? { ...b, balance: b.balance - amount } : b));
    }
  };

  const addPartial = (id) => {
    const amt = parseFloat(partialData.amount);
    if (!amt || amt <= 0) return;
    const p = payables.find(pp => pp.id === id);
    if (!p.category) {
      setShowCategoryPrompt(id);
      setCategoryPromptData({ category:"", amount:amt, date:partialData.date, payableId:id, bankId:partialData.bankId });
      return;
    }
    doAddPartial(id, amt, partialData.date, partialData.bankId, p.category);
    setShowPartial(null);
    setPartialData({ date: TODAY, amount: "", bankId: "" });
  };

  const confirmCategoryAndPay = () => {
    if (!categoryPromptData.category) return;
    doAddPartial(categoryPromptData.payableId, categoryPromptData.amount, categoryPromptData.date, categoryPromptData.bankId, categoryPromptData.category);
    setPayables(prev => prev.map(pp => pp.id === categoryPromptData.payableId ? { ...pp, category: categoryPromptData.category } : pp));
    setShowPartial(null);
    setShowCategoryPrompt(null);
    setPartialData({ date: TODAY, amount: "", bankId: "" });
  };

  const markFullyPaid = (id) => {
    const p = payables.find(pp => pp.id === id);
    if (!p) return;
    const bal = getBalance(p);
    if (bal <= 0) return;
    if (!p.category) {
      setShowCategoryPrompt(id);
      setCategoryPromptData({ category:"", amount:bal, date:TODAY, payableId:id, bankId:"" });
      return;
    }
    doAddPartial(id, bal, TODAY, "", p.category);
  };

  const sendToTask = (p) => {
    const bal = getBalance(p);
    setTasks(prev => [...prev, {
      id: genId(), title: `Processar pagamento ${p.supplier}`, amount: bal, assignee: taskData.assignee,
      priority: isOverdue(p.dueDate) ? "alta" : "média", status: "em_processamento", dueDate: taskData.dueDate,
      method: taskData.method, bank: taskData.bank, notes: taskData.notes || `${p.doc} — ${isOverdue(p.dueDate) ? `Vencido há ${Math.abs(daysUntil(p.dueDate))}d` : `Vence em ${daysUntil(p.dueDate)}d`}`,
      payableId: p.id, category: p.category
    }]);
    setShowTaskModal(null);
    setTaskData({ assignee:"Kátia Mendes", dueDate:TODAY, method:"Transferência bancária", bank:"", notes:"" });
  };

  const addPayable = () => {
    if (!newPay.supplier || !newPay.amount || !newPay.dueDate || !newPay.category) return;
    setPayables(prev => [...prev, {
      id: genId(), supplier: newPay.supplier, doc: newPay.doc,
      amount: parseFloat(newPay.amount), dueDate: newPay.dueDate,
      category: newPay.category, bank: newPay.bank, method: newPay.method,
      pinned: false, partials: [], ccLink: newPay.ccLink
    }]);
    setShowAdd(false);
    setNewPay({ supplier:"", doc:"", amount:"", dueDate:"", category:"fornecedor", method:"Transferência bancária", bank:"", ccLink:false });
  };

  const addBankAccount = () => {
    if (!newBank.name || !newBank.initialBalance) return;
    setBankAccounts(prev => [...prev, {
      id: genId().toString(), name: newBank.name,
      balance: parseFloat(newBank.initialBalance),
      paymentMethods: newBank.paymentMethods,
      tpaRate: parseFloat(newBank.tpaRate) || 0, archived: false
    }]);
    setShowNewBankModal(false);
    setNewBank({ name:"", initialBalance:"", paymentMethods:[], tpaRate:"" });
  };

  const downloadHistory = () => {
    const filtered = completedPayments.filter(cp => new Date(cp.date).getFullYear() === historyYear);
    const csv = "Data,Fornecedor,Valor,Categoria,Método,Conta\n" +
      filtered.map(cp => `${cp.date},${cp.supplier},${cp.amount},${cp.category},${cp.method},${cp.bank}`).join("\n");
    const a = document.createElement("a");
    a.href = "data:text/plain;charset=utf-8," + encodeURIComponent(csv);
    a.download = `pagamentos_${historyYear}.csv`;
    a.click();
  };

  const addCategory = () => {
    if (!newCat.key || !newCat.label) return;
    setCategories(prev => ({ ...prev, [newCat.key]: { label: newCat.label, color: newCat.color } }));
    setShowNewCatModal(false);
    setNewCat({ key:"", label:"", color:"#6366f1" });
  };

  const PayRow = ({ p, isPinned }) => {
    const bal = getBalance(p);
    const days = daysUntil(p.dueDate);
    const overdue = days < 0;
    const hasTask = tasks.some(t => t.payableId === p.id && t.status !== "concluido");
    const updateField = (field, val) => setPayables(prev => prev.map(pp => pp.id === p.id ? { ...pp, [field]: val } : pp));
    return (
      <tr className={`border-b border-stone-100 hover:bg-stone-50/70 transition-colors ${overdue ? 'bg-red-50/30' : ''} ${isPinned ? 'bg-orange-50/20' : ''}`}>
        <td className="py-2.5 px-3">
          <button onClick={() => togglePin(p.id)} className="p-0.5 hover:scale-110 transition-transform">
            {p.pinned ? <Star size={14} className="text-orange-500 fill-orange-500" /> : <Star size={14} className="text-stone-300" />}
          </button>
        </td>
        <td className="py-2.5 px-3">
          <div className="font-medium text-stone-800 text-[13px]">{p.supplier}</div>
          {p.doc && <div className="text-[11px] text-stone-400 font-mono mt-0.5">{p.doc}</div>}
        </td>
        <td className="py-2.5 px-3 text-center">
          <Badge>{(categories[p.category] || categories.outros).label}</Badge>
        </td>
        <td className="py-2.5 px-3 text-right">
          <div className="font-semibold text-red-600 text-[13px]">{fmt(bal)}</div>
          {p.partials.length > 0 && <div className="text-[10px] text-stone-400">de {fmt(p.amount)}</div>}
        </td>
        <td className="py-2.5 px-3 text-center text-[13px]">{fmtDate(p.dueDate)}</td>
        <td className="py-2.5 px-3 text-center">
          <Badge variant={overdue ? "danger" : days <= 7 ? "warning" : "success"}>
            {overdue ? `${Math.abs(days)}d atraso` : days === 0 ? "Hoje" : `${days}d`}
          </Badge>
        </td>
        <td className="py-2 px-2">
          <select value={p.method || ""} onChange={e => updateField("method", e.target.value)} className="text-[11px] px-1 py-0.5 rounded border border-stone-200 bg-white w-full max-w-[130px]">
            {allMethods.map(m => <option key={m} value={m}>{m}</option>)}
          </select>
          <select value={p.bank || ""} onChange={e => updateField("bank", e.target.value)} className="text-[10px] px-1 py-0.5 rounded border border-stone-200 bg-white w-full max-w-[130px] mt-0.5 text-stone-500">
            <option value="">Conta...</option>
            {activeBanks.map(b => <option key={b.id} value={b.id}>{b.name}</option>)}
          </select>
        </td>
        <td className="py-2.5 px-3">
          <div className="flex items-center justify-center gap-1">
            {hasTask && <Badge variant="info">Em tarefa</Badge>}
            <Button size="xs" variant="ghost" onClick={() => { setShowPartial(p.id); setPartialData({ date:TODAY, amount:String(bal), bankId:p.bank||"" }); }} title="Pagamento parcial"><Minus size={13} /></Button>
            <Button size="xs" variant="ghost" onClick={() => markFullyPaid(p.id)} title="Pago na totalidade"><Check size={13} className="text-emerald-600" /></Button>
            <Button size="xs" variant="ghost" onClick={() => { setShowTaskModal(p); setTaskData({ ...taskData, notes:`${p.doc} — ${fmt(bal)}` }); }} title="Enviar para tarefas"><Send size={13} className="text-sky-600" /></Button>
            <Button size="xs" variant="ghost" onClick={() => setPayables(prev => prev.filter(x => x.id !== p.id))} title="Remover"><Trash2 size={13} className="text-stone-400" /></Button>
          </div>
        </td>
      </tr>
    );
  };

  return (
    <div className="space-y-5">
      {/* Stats */}
      <div className="grid grid-cols-4 gap-4">
        <Card className="p-4">
          <p className="text-[11px] text-stone-400 uppercase tracking-wider font-medium">Total pendente</p>
          <p className="text-xl font-bold text-stone-900 mt-1">{fmt(totalAll)}</p>
          <p className="text-[11px] text-stone-400 mt-0.5">{payables.filter(p => getBalance(p) > 0).length} pagamentos</p>
        </Card>
        <Card className="p-4">
          <p className="text-[11px] text-stone-400 uppercase tracking-wider font-medium">Vencidos</p>
          <p className="text-xl font-bold text-red-600 mt-1">{fmt(totalOverdue)}</p>
          <p className="text-[11px] text-stone-400 mt-0.5">{payables.filter(p => isOverdue(p.dueDate) && getBalance(p) > 0).length} pagamentos</p>
        </Card>
        <Card className="p-4 ring-2 ring-orange-200">
          <p className="text-[11px] text-orange-600 uppercase tracking-wider font-semibold flex items-center gap-1"><Star size={11} className="fill-orange-500" />Prioritários</p>
          <p className="text-xl font-bold text-orange-700 mt-1">{fmt(totalPinned)}</p>
          <p className="text-[11px] text-stone-400 mt-0.5">{pinnedPayables.length} marcados</p>
        </Card>
        <Card className="p-4">
          <p className="text-[11px] text-stone-400 uppercase tracking-wider font-medium">Próx. 7 dias</p>
          <p className="text-xl font-bold text-stone-900 mt-1">{fmt(payables.filter(p => { const d = daysUntil(p.dueDate); return d >= 0 && d <= 7 && getBalance(p) > 0; }).reduce((s,p) => s + getBalance(p), 0))}</p>
        </Card>
      </div>

      {/* Bank Accounts Panel - FIX: Create, Archive, PaymentMethods */}
      <Card className="p-4 border border-sky-100 bg-sky-50/20">
        <div className="flex items-center justify-between mb-3">
          <h3 className="font-semibold text-stone-800 text-[13px] flex items-center gap-2"><CreditCard size={14} />Contas Bancárias</h3>
          <div className="flex gap-2">
            <Button size="xs" onClick={() => setShowNewBankModal(true)}><Plus size={13} />Nova Conta</Button>
            {archivedBanks.length > 0 && <Button size="xs" variant="outline" onClick={() => setShowArchivedAccounts(true)}>Arquivadas ({archivedBanks.length})</Button>}
          </div>
        </div>
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3">
          {activeBanks.map(b => (
            <div key={b.id} className="p-3 bg-white rounded-lg border border-sky-100 hover:shadow-sm transition">
              <div className="flex items-start justify-between mb-1.5">
                <div>
                  <p className="font-semibold text-stone-800 text-[13px]">{b.name}</p>
                  <p className="text-[13px] font-bold text-sky-700 mt-0.5">{fmt(b.balance)}</p>
                </div>
                <Button size="xs" variant="ghost" onClick={() => setBankAccounts(prev => prev.map(x => x.id === b.id ? { ...x, archived: true } : x))} title="Arquivar">
                  <Archive size={12} className="text-stone-400" />
                </Button>
              </div>
              {b.paymentMethods && b.paymentMethods.length > 0 && (
                <div className="flex flex-wrap gap-1 mt-1">
                  {b.paymentMethods.map(m => <Badge key={m} variant="info" className="text-[9px]">{m}</Badge>)}
                </div>
              )}
              {b.tpaRate > 0 && <p className="text-[10px] text-stone-400 mt-1">Taxa TPA: {b.tpaRate}%</p>}
            </div>
          ))}
        </div>
        {/* Summary */}
        <div className="mt-3 pt-3 border-t border-sky-100 flex items-center gap-4">
          <p className="text-xs text-stone-500">Saldo total: <span className="font-bold text-stone-800">{fmt(activeBanks.reduce((s,b) => s + b.balance, 0))}</span></p>
          <p className="text-xs text-stone-400">em {activeBanks.length} contas ativas</p>
        </div>
      </Card>

      {/* Analytics */}
      <Card className="p-4 border border-emerald-100 bg-emerald-50/20">
        <h3 className="font-semibold text-stone-800 text-[13px] mb-3 flex items-center gap-2"><BarChart3 size={14} />Análise de Pagamentos — Este Mês</h3>
        <div className="grid grid-cols-3 gap-4">
          <div className="p-3 bg-white rounded-lg border border-emerald-100">
            <p className="text-[11px] text-stone-500 font-medium">Total Pago</p>
            <p className="text-2xl font-bold text-emerald-600 mt-1">{fmt(monthlyPaid)}</p>
          </div>
          <div className="p-3 bg-white rounded-lg border border-emerald-100">
            <p className="text-[11px] text-stone-500 font-medium">Por Categoria</p>
            <div className="mt-2 space-y-1">
              {Object.entries(categoryBreakdown).sort((a,b) => b[1]-a[1]).slice(0,3).map(([cat, val]) => (
                <div key={cat} className="flex items-center justify-between text-[11px]">
                  <span className="text-stone-600">{(categories[cat] || {label:cat}).label}</span>
                  <span className="font-semibold text-stone-800">{fmt(val)}</span>
                </div>
              ))}
              {Object.keys(categoryBreakdown).length === 0 && <p className="text-[11px] text-stone-400">Sem pagamentos</p>}
            </div>
          </div>
          <div className="p-3 bg-white rounded-lg border border-emerald-100">
            <p className="text-[11px] text-stone-500 font-medium">Categorias</p>
            <div className="flex items-center justify-between mt-2">
              <span className="text-lg font-bold text-stone-700">{Object.keys(categories).length}</span>
              <Button size="xs" variant="outline" onClick={() => setShowNewCatModal(true)}><Plus size={11} />Nova</Button>
            </div>
          </div>
        </div>
      </Card>

      {/* Pinned */}
      {pinnedPayables.length > 0 && (
        <Card className="ring-2 ring-orange-200/80 overflow-hidden">
          <div className="px-4 py-3 bg-orange-50/50 border-b border-orange-100 flex items-center gap-2">
            <Star size={15} className="text-orange-500 fill-orange-500" />
            <h4 className="font-semibold text-orange-800 text-[13px]">Prioritários</h4>
            <Badge variant="priority" className="ml-auto">{fmt(totalPinned)}</Badge>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead><tr className="bg-orange-50/30 border-b border-orange-100">
                <th className="w-8 px-3 py-2"></th>
                <th className="text-left py-2 px-3 text-stone-500 text-[11px] font-medium">Fornecedor</th>
                <th className="text-center py-2 px-3 text-stone-500 text-[11px] font-medium">Cat.</th>
                <th className="text-right py-2 px-3 text-stone-500 text-[11px] font-medium">Valor</th>
                <th className="text-center py-2 px-3 text-stone-500 text-[11px] font-medium">Vencimento</th>
                <th className="text-center py-2 px-3 text-stone-500 text-[11px] font-medium">Estado</th>
                <th className="text-center py-2 px-3 text-stone-500 text-[11px] font-medium">Método</th>
                <th className="text-center py-2 px-3 text-stone-500 text-[11px] font-medium">Ações</th>
              </tr></thead>
              <tbody>{pinnedPayables.map(p => <PayRow key={p.id} p={p} isPinned />)}</tbody>
            </table>
          </div>
        </Card>
      )}

      {/* Filters */}
      <div className="flex items-center justify-between gap-3 flex-wrap">
        <div className="flex items-center gap-2 flex-1">
          <div className="relative flex-1 max-w-xs">
            <Search size={15} className="absolute left-3 top-2.5 text-stone-400" />
            <input className="w-full pl-9 pr-3 py-2 rounded-lg border border-stone-200 text-sm" placeholder="Pesquisar..." value={search} onChange={e => setSearch(e.target.value)} />
          </div>
          <select className="px-3 py-2 rounded-lg border border-stone-200 text-sm" value={filterCat} onChange={e => setFilterCat(e.target.value)}>
            <option value="all">Todas categorias</option>
            {Object.entries(categories).map(([k,v]) => <option key={k} value={k}>{v.label}</option>)}
          </select>
          <select className="px-3 py-2 rounded-lg border border-stone-200 text-sm" value={filterStatus} onChange={e => setFilterStatus(e.target.value)}>
            <option value="all">Todos</option>
            <option value="vencido">Vencidos</option>
            <option value="pendente">Pendentes</option>
          </select>
        </div>
        <Button onClick={() => setShowAdd(true)}><Plus size={15} />Novo Pagamento</Button>
      </div>

      {/* Main Table */}
      <Card className="overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead><tr className="bg-stone-50/70 border-b border-stone-200">
              <th className="w-8 px-3 py-2.5"></th>
              <th className="text-left py-2.5 px-3 text-stone-500 text-[11px] font-medium cursor-pointer hover:text-stone-700" onClick={() => toggleSort("supplier")}>Fornecedor {sortField === "supplier" && (sortDir === "asc" ? <ChevronUp size={10} className="inline" /> : <ChevronDown size={10} className="inline" />)}</th>
              <th className="text-center py-2.5 px-3 text-stone-500 text-[11px] font-medium">Categoria</th>
              <th className="text-right py-2.5 px-3 text-stone-500 text-[11px] font-medium cursor-pointer hover:text-stone-700" onClick={() => toggleSort("amount")}>Valor</th>
              <th className="text-center py-2.5 px-3 text-stone-500 text-[11px] font-medium cursor-pointer hover:text-stone-700" onClick={() => toggleSort("dueDate")}>Vencimento</th>
              <th className="text-center py-2.5 px-3 text-stone-500 text-[11px] font-medium">Estado</th>
              <th className="text-center py-2.5 px-3 text-stone-500 text-[11px] font-medium">Método</th>
              <th className="text-center py-2.5 px-3 text-stone-500 text-[11px] font-medium">Ações</th>
            </tr></thead>
            <tbody>{filteredPayables.map(p => <PayRow key={p.id} p={p} />)}</tbody>
            <tfoot><tr className="bg-stone-50 border-t-2 border-stone-200">
              <td colSpan={3} className="py-2.5 px-3 text-sm font-semibold text-stone-600">{filteredPayables.length} pagamentos</td>
              <td className="py-2.5 px-3 text-right text-sm font-bold text-red-600">{fmt(filteredPayables.reduce((s,p) => s + getBalance(p), 0))}</td>
              <td colSpan={4}></td>
            </tr></tfoot>
          </table>
        </div>
      </Card>

      {/* Payment History */}
      {completedPayments.length > 0 && (
        <Card className="p-4 border border-purple-100 bg-purple-50/20">
          <div className="flex items-center justify-between mb-3">
            <h3 className="font-semibold text-stone-800 text-[13px] flex items-center gap-2"><Clock size={14} />Últimos Pagamentos Realizados</h3>
            <div className="flex gap-2">
              <Button size="xs" variant="outline" onClick={() => setShowPaymentHistory(true)}>Ver todos</Button>
              <Button size="xs" variant="outline" onClick={downloadHistory}><Download size={12} />Descarregar</Button>
            </div>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead><tr className="bg-purple-50/30 border-b border-purple-100">
                <th className="text-left py-2 px-3 text-stone-500 text-[10px] font-medium">Data</th>
                <th className="text-left py-2 px-3 text-stone-500 text-[10px] font-medium">Fornecedor</th>
                <th className="text-right py-2 px-3 text-stone-500 text-[10px] font-medium">Valor</th>
                <th className="text-center py-2 px-3 text-stone-500 text-[10px] font-medium">Categoria</th>
                <th className="text-center py-2 px-3 text-stone-500 text-[10px] font-medium">Método</th>
                <th className="text-center py-2 px-3 text-stone-500 text-[10px] font-medium">Conta</th>
              </tr></thead>
              <tbody>
                {completedPayments.slice(-10).reverse().map(cp => (
                  <tr key={cp.id} className="border-b border-purple-50 hover:bg-purple-50/30 text-[11px]">
                    <td className="py-2 px-3 text-stone-600">{fmtDate(cp.date)}</td>
                    <td className="py-2 px-3 text-stone-800 font-medium">{cp.supplier}</td>
                    <td className="py-2 px-3 text-right text-emerald-600 font-semibold">{fmt(cp.amount)}</td>
                    <td className="py-2 px-3 text-center"><Badge variant="info">{(categories[cp.category] || {label:cp.category}).label}</Badge></td>
                    <td className="py-2 px-3 text-center text-stone-600">{cp.method}</td>
                    <td className="py-2 px-3 text-center text-stone-600">{cp.bank}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </Card>
      )}

      {/* Partial Payment Modal */}
      <Modal open={!!showPartial} onClose={() => setShowPartial(null)} title="Registar Pagamento">
        {showPartial && (() => {
          const p = payables.find(pp => pp.id === showPartial);
          if (!p) return null;
          const bal = getBalance(p);
          return (
            <div className="space-y-4">
              <div className="p-3 bg-stone-50 rounded-lg">
                <p className="font-medium text-stone-800">{p.supplier}</p>
                <p className="text-sm text-stone-500">Saldo: <span className="font-semibold text-red-600">{fmt(bal)}</span></p>
                {p.partials.length > 0 && <div className="mt-2 space-y-1">{p.partials.map((pp,i) => <div key={i} className="text-xs text-stone-400 flex justify-between"><span>{fmtDate(pp.date)}</span><span className="text-emerald-600">{fmt(pp.amount)}</span></div>)}</div>}
              </div>
              <div className="grid grid-cols-2 gap-3">
                <Input label="Data" type="date" value={partialData.date} onChange={e => setPartialData({ ...partialData, date: e.target.value })} />
                <Input label="Valor €" type="number" value={partialData.amount} onChange={e => setPartialData({ ...partialData, amount: e.target.value })} max={bal} />
              </div>
              <Select label="Conta bancária (débito)" value={partialData.bankId} onChange={e => setPartialData({ ...partialData, bankId: e.target.value })}>
                <option value="">— Não debitar conta —</option>
                {activeBanks.map(b => <option key={b.id} value={b.id}>{b.name} ({fmt(b.balance)})</option>)}
              </Select>
              <div className="flex justify-end gap-2">
                <Button variant="outline" onClick={() => setShowPartial(null)}>Cancelar</Button>
                <Button onClick={() => addPartial(showPartial)}>Registar</Button>
              </div>
            </div>
          );
        })()}
      </Modal>

      {/* Category Prompt */}
      <Modal open={!!showCategoryPrompt} onClose={() => setShowCategoryPrompt(null)} title="Categoria do Pagamento">
        <div className="space-y-4">
          <p className="text-sm text-stone-600">Selecione a categoria para este pagamento:</p>
          <Select label="Categoria" value={categoryPromptData.category} onChange={e => setCategoryPromptData({ ...categoryPromptData, category: e.target.value })}>
            <option value="">— Selecionar —</option>
            {Object.entries(categories).map(([k,v]) => <option key={k} value={k}>{v.label}</option>)}
          </Select>
          <Select label="Conta bancária (débito)" value={categoryPromptData.bankId} onChange={e => setCategoryPromptData({ ...categoryPromptData, bankId: e.target.value })}>
            <option value="">— Não debitar conta —</option>
            {activeBanks.map(b => <option key={b.id} value={b.id}>{b.name} ({fmt(b.balance)})</option>)}
          </Select>
          <div className="flex justify-end gap-2">
            <Button variant="outline" onClick={() => setShowCategoryPrompt(null)}>Cancelar</Button>
            <Button onClick={confirmCategoryAndPay} disabled={!categoryPromptData.category}>Confirmar</Button>
          </div>
        </div>
      </Modal>

      {/* Send to Task Modal */}
      <Modal open={!!showTaskModal} onClose={() => setShowTaskModal(null)} title="Enviar para Tarefas">
        {showTaskModal && (
          <div className="space-y-4">
            <div className="p-3 bg-stone-50 rounded-lg">
              <p className="font-medium text-stone-800">{showTaskModal.supplier}</p>
              <p className="text-sm text-red-600 font-semibold">{fmt(getBalance(showTaskModal))}</p>
            </div>
            <div className="grid grid-cols-2 gap-3">
              <Select label="Atribuir a" value={taskData.assignee} onChange={e => setTaskData({ ...taskData, assignee: e.target.value })}>
                <option>Kátia Mendes</option><option>Márcio Monteiro</option>
              </Select>
              <Input label="Data" type="date" value={taskData.dueDate} onChange={e => setTaskData({ ...taskData, dueDate: e.target.value })} />
            </div>
            <div className="grid grid-cols-2 gap-3">
              <Select label="Método" value={taskData.method} onChange={e => setTaskData({ ...taskData, method: e.target.value })}>
                {allMethods.map(m => <option key={m}>{m}</option>)}
              </Select>
              <Select label="Conta" value={taskData.bank} onChange={e => setTaskData({ ...taskData, bank: e.target.value })}>
                <option value="">—</option>
                {activeBanks.map(b => <option key={b.id} value={b.id}>{b.name}</option>)}
              </Select>
            </div>
            <div>
              <label className="block text-[11px] font-medium text-stone-500 mb-1 uppercase tracking-wider">Observações</label>
              <textarea className="w-full px-3 py-2 rounded-lg border border-stone-200 text-sm" rows={2} value={taskData.notes} onChange={e => setTaskData({ ...taskData, notes: e.target.value })} />
            </div>
            <div className="flex justify-end gap-2">
              <Button variant="outline" onClick={() => setShowTaskModal(null)}>Cancelar</Button>
              <Button onClick={() => sendToTask(showTaskModal)}>Criar Tarefa</Button>
            </div>
          </div>
        )}
      </Modal>

      {/* New Bank Modal */}
      <Modal open={showNewBankModal} onClose={() => setShowNewBankModal(false)} title="Nova Conta Bancária">
        <div className="space-y-4">
          <Input label="Nome" value={newBank.name} onChange={e => setNewBank({ ...newBank, name: e.target.value })} placeholder="Ex: Caixa Geral de Depósitos" />
          <Input label="Saldo Inicial €" type="number" value={newBank.initialBalance} onChange={e => setNewBank({ ...newBank, initialBalance: e.target.value })} />
          <Input label="Taxa TPA %" type="number" value={newBank.tpaRate} onChange={e => setNewBank({ ...newBank, tpaRate: e.target.value })} placeholder="0" />
          <div>
            <label className="block text-[11px] font-medium text-stone-500 mb-2 uppercase tracking-wider">Métodos de Pagamento</label>
            <div className="space-y-1 max-h-40 overflow-y-auto">
              {["Dinheiro","Cartões","Ref MB","MB Way","PayPal","Visa Onl.","Transferência bancária","Confirming Abanca","Confirming BPI","TB","Bitcoin","Cheque"].map(m => (
                <label key={m} className="flex items-center gap-2 text-sm cursor-pointer">
                  <input type="checkbox" checked={newBank.paymentMethods.includes(m)} onChange={e => setNewBank({ ...newBank, paymentMethods: e.target.checked ? [...newBank.paymentMethods, m] : newBank.paymentMethods.filter(x => x !== m) })} className="rounded" />
                  {m}
                </label>
              ))}
            </div>
          </div>
          <div className="flex justify-end gap-2">
            <Button variant="outline" onClick={() => setShowNewBankModal(false)}>Cancelar</Button>
            <Button onClick={addBankAccount}>Criar Conta</Button>
          </div>
        </div>
      </Modal>

      {/* Archived Accounts */}
      <Modal open={showArchivedAccounts} onClose={() => setShowArchivedAccounts(false)} title="Contas Arquivadas">
        <div className="space-y-2 max-h-96 overflow-y-auto">
          {archivedBanks.length > 0 ? archivedBanks.map(b => (
            <div key={b.id} className="p-3 bg-stone-50 rounded-lg border border-stone-200 flex items-center justify-between">
              <div>
                <p className="font-medium text-stone-800 text-[13px]">{b.name}</p>
                <p className="text-[11px] text-stone-500">Saldo: {fmt(b.balance)}</p>
                <p className="text-[10px] text-stone-400">Arquivada — consulta apenas</p>
              </div>
              <Button size="xs" variant="ghost" onClick={() => setBankAccounts(prev => prev.map(x => x.id === b.id ? { ...x, archived: false } : x))}>Restaurar</Button>
            </div>
          )) : <p className="text-sm text-stone-500">Nenhuma conta arquivada.</p>}
        </div>
      </Modal>

      {/* Payment History Modal */}
      <Modal open={showPaymentHistory} onClose={() => setShowPaymentHistory(false)} title="Histórico de Pagamentos" wide>
        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <input type="number" min="2020" max="2030" value={historyYear} onChange={e => setHistoryYear(parseInt(e.target.value))} className="px-3 py-1 rounded border border-stone-200 text-sm w-24" />
            <Button size="sm" variant="outline" onClick={downloadHistory}><Download size={13} />Descarregar CSV</Button>
          </div>
          <div className="overflow-x-auto max-h-96">
            <table className="w-full text-sm">
              <thead><tr className="bg-stone-50 sticky top-0">
                <th className="text-left py-2 px-2 text-[10px] font-medium text-stone-500">Data</th>
                <th className="text-left py-2 px-2 text-[10px] font-medium text-stone-500">Fornecedor</th>
                <th className="text-right py-2 px-2 text-[10px] font-medium text-stone-500">Valor</th>
                <th className="text-center py-2 px-2 text-[10px] font-medium text-stone-500">Categoria</th>
                <th className="text-center py-2 px-2 text-[10px] font-medium text-stone-500">Método</th>
                <th className="text-center py-2 px-2 text-[10px] font-medium text-stone-500">Conta</th>
              </tr></thead>
              <tbody>
                {completedPayments.filter(cp => new Date(cp.date).getFullYear() === historyYear).map(cp => (
                  <tr key={cp.id} className="border-b border-stone-100 text-[11px]">
                    <td className="py-2 px-2">{fmtDate(cp.date)}</td>
                    <td className="py-2 px-2">{cp.supplier}</td>
                    <td className="py-2 px-2 text-right font-semibold text-emerald-600">{fmt(cp.amount)}</td>
                    <td className="py-2 px-2 text-center">{(categories[cp.category] || {label:cp.category}).label}</td>
                    <td className="py-2 px-2 text-center">{cp.method}</td>
                    <td className="py-2 px-2 text-center">{cp.bank}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <Button variant="outline" onClick={() => setShowPaymentHistory(false)}>Fechar</Button>
        </div>
      </Modal>

      {/* Add Payment Modal */}
      <Modal open={showAdd} onClose={() => setShowAdd(false)} title="Novo Pagamento">
        <div className="space-y-4">
          <div className="grid grid-cols-2 gap-3">
            <div className="col-span-2">
              <label className="block text-[11px] font-medium text-stone-500 mb-1 uppercase tracking-wider">Fornecedor</label>
              <input className="w-full px-3 py-2 rounded-lg border border-stone-200 text-sm" value={newPay.supplier} onChange={e => setNewPay({ ...newPay, supplier: e.target.value })} list="sup-list" />
              <datalist id="sup-list">{[...new Set(payables.map(p => p.supplier))].sort().map(s => <option key={s} value={s} />)}</datalist>
            </div>
            <Input label="Nº Documento" value={newPay.doc} onChange={e => setNewPay({ ...newPay, doc: e.target.value })} />
            <Input label="Valor €" type="number" value={newPay.amount} onChange={e => setNewPay({ ...newPay, amount: e.target.value })} />
            <Input label="Vencimento" type="date" value={newPay.dueDate} onChange={e => setNewPay({ ...newPay, dueDate: e.target.value })} />
            <Select label="Categoria" value={newPay.category} onChange={e => setNewPay({ ...newPay, category: e.target.value })}>
              {Object.entries(categories).map(([k,v]) => <option key={k} value={k}>{v.label}</option>)}
            </Select>
            <Select label="Método" value={newPay.method} onChange={e => setNewPay({ ...newPay, method: e.target.value })}>
              {allMethods.map(m => <option key={m}>{m}</option>)}
            </Select>
            <Select label="Conta" value={newPay.bank} onChange={e => setNewPay({ ...newPay, bank: e.target.value })}>
              <option value="">—</option>
              {activeBanks.map(b => <option key={b.id} value={b.id}>{b.name}</option>)}
            </Select>
          </div>
          <label className="flex items-center gap-2 text-sm text-stone-600 cursor-pointer">
            <input type="checkbox" className="rounded" checked={newPay.ccLink} onChange={e => setNewPay({ ...newPay, ccLink: e.target.checked })} />
            Incluir nas Contas Corrente
          </label>
          <div className="flex justify-end gap-2">
            <Button variant="outline" onClick={() => setShowAdd(false)}>Cancelar</Button>
            <Button onClick={addPayable}>Adicionar</Button>
          </div>
        </div>
      </Modal>

      {/* New Category Modal */}
      <Modal open={showNewCatModal} onClose={() => setShowNewCatModal(false)} title="Nova Categoria">
        <div className="space-y-4">
          <Input label="Chave (ex: marketing)" value={newCat.key} onChange={e => setNewCat({ ...newCat, key: e.target.value.replace(/\s/g,'').toLowerCase() })} />
          <Input label="Nome visível" value={newCat.label} onChange={e => setNewCat({ ...newCat, label: e.target.value })} />
          <div>
            <label className="block text-[11px] font-medium text-stone-500 mb-1 uppercase tracking-wider">Cor</label>
            <input type="color" value={newCat.color} onChange={e => setNewCat({ ...newCat, color: e.target.value })} className="w-full h-9 rounded border border-stone-200 cursor-pointer" />
          </div>
          <div className="flex justify-end gap-2">
            <Button variant="outline" onClick={() => setShowNewCatModal(false)}>Cancelar</Button>
            <Button onClick={addCategory}>Criar</Button>
          </div>
        </div>
      </Modal>
    </div>
  );
};

// ==================== CONFIRMING MODULE ====================
const PT_HOL = {"2026-01-01":1,"2026-04-03":1,"2026-04-05":1,"2026-04-25":1,"2026-05-01":1,"2026-06-04":1,"2026-06-10":1,"2026-08-15":1,"2026-10-05":1,"2026-11-01":1,"2026-12-01":1,"2026-12-08":1,"2026-12-25":1};
const dsFmt = (y,m,d) => `${y}-${String(m+1).padStart(2,'0')}-${String(d).padStart(2,'0')}`;
const isCl = (y,m,d) => { const dow = new Date(y,m,d).getDay(); return dow === 0 || dow === 6 || !!PT_HOL[dsFmt(y,m,d)]; };

const ConfirmingModule = ({
  pays, setPays, payables, setPayables,
  ccSuppliers, setCcSuppliers, ccClients,
  bankAccounts, setBankAccounts,
  completedPayments, setCompletedPayments,
  categories
}) => {
  const LIM = { abanca: 20000, bpi: 40000 };
  const BC = { abanca: { p:"#2563eb", pl:"#93c5fd", d:"#9ca3af", l:"Abanca" }, bpi: { p:"#ea580c", pl:"#fdba74", d:"#9ca3af", l:"BPI" } };
  const MN = ["Jan","Fev","Mar","Abr","Mai","Jun","Jul","Ago","Set","Out","Nov","Dez"];
  const MNF = ["Janeiro","Fevereiro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"];
  const allSup = [...new Set([...(ccSuppliers||[]).map(c=>c.name),...(payables||[]).map(p=>p.supplier)])].sort();

  const [cv, setCv] = useState({ y:2026, m:2 });
  const [showForm, setShowForm] = useState(null);
  const [showDetail, setShowDetail] = useState(null);
  const [showDebit, setShowDebit] = useState(null);
  const [showNotes, setShowNotes] = useState(null);
  const [emailLang, setEmailLang] = useState("pt");
  const [miniV, setMiniV] = useState(null);
  const [nf, setNf] = useState({ supplier:"", doc:"", amount:"", payDate:TODAY, debitDate:"", bank:"abanca", notes:"", linkedFrom:"" });
  const [da, setDa] = useState({ date:TODAY, amount:"", bankId:"" });
  const [selInvoices, setSelInvoices] = useState([]);

  const getInvBalance = (inv) => inv.amount - inv.partials.reduce((s,p) => s + p.amount, 0);
  const getSupplierInvoices = (supplierName) => {
    const entity = (ccSuppliers||[]).find(e => e.name.toLowerCase() === supplierName.toLowerCase());
    if (!entity) return { entity:null, invoices:[] };
    return { entity, invoices:entity.invoices.filter(i => getInvBalance(i) > 0) };
  };

  const maxDD = (f) => { const d = new Date(f||TODAY); d.setDate(d.getDate()+120); return d.toISOString().split('T')[0]; };
  const debT = (p) => p.debits.reduce((s,d) => s+d.amount, 0);
  const rem = (p) => p.amount - debT(p);
  const nextM = (v) => v.m === 11 ? {y:v.y+1,m:0} : {y:v.y,m:v.m+1};
  const prevM = (v) => v.m === 0 ? {y:v.y-1,m:11} : {y:v.y,m:v.m-1};
  const ymLabel = (v) => `${MNF[v.m]} ${v.y}`;
  const ymShort = (v) => `${MN[v.m]} ${String(v.y).slice(2)}`;

  const getPl = (bk) => {
    const o = pays.filter(p => p.bank === bk && p.status === "processado" && rem(p) > 0).reduce((s,p) => s+rem(p), 0);
    return { limit:LIM[bk], occ:o, free:LIM[bk]-o };
  };
  const pl = { abanca:getPl("abanca"), bpi:getPl("bpi") };

  const mPv = (bk,y,m) => {
    const a = pays.filter(p => p.bank===bk && new Date(p.debitDate).getFullYear()===y && new Date(p.debitDate).getMonth()===m);
    return {
      proc: a.filter(p=>p.status==="processado").reduce((s,p)=>s+p.amount,0),
      plan: a.filter(p=>p.status==="planificado").reduce((s,p)=>s+p.amount,0),
      liq: a.filter(p=>p.status==="liquidado").reduce((s,p)=>s+p.amount,0)
    };
  };

  const calIt = (y,m) => {
    const r = [];
    pays.forEach(p => {
      const pd = new Date(p.payDate), dd = new Date(p.debitDate);
      if (pd.getFullYear()===y && pd.getMonth()===m) r.push({...p,calDate:p.payDate,ct:"pay"});
      if (dd.getFullYear()===y && dd.getMonth()===m) r.push({...p,calDate:p.debitDate,ct:"deb"});
    });
    return r;
  };

  const getDays = (y,m) => {
    const d = [];
    const s = (new Date(y,m,1).getDay()+6)%7;
    for (let i=0;i<s;i++) d.push(null);
    for (let i=1;i<=new Date(y,m+1,0).getDate();i++) d.push(i);
    return d;
  };

  const mProj = (() => {
    const r = [];
    let v = {y:2026,m:0};
    for (let i=0;i<18;i++) {
      const a=mPv("abanca",v.y,v.m), b=mPv("bpi",v.y,v.m);
      r.push({month:ymShort(v),aP:a.proc,aPl:a.plan,bP:b.proc,bPl:b.plan});
      v=nextM(v);
    }
    return r;
  })();

  // FIX: Save confirming — also adds to payables list so it shows under "Pagamentos"
  const save = () => {
    if (!nf.supplier || !nf.amount || !nf.debitDate) return;
    const dd = Math.ceil((new Date(nf.debitDate)-new Date(nf.payDate))/864e5);
    if (dd>120) { alert("Máx 120 dias entre pagamento e débito."); return; }
    if (dd<0) { alert("Débito deve ser posterior ao pagamento."); return; }
    const id = genId();
    const lf = nf.linkedFrom ? parseFloat(nf.linkedFrom) : null;
    const amt = parseFloat(nf.amount);

    setPays(prev => {
      let u = [...prev, {
        id, supplier:nf.supplier, doc:nf.doc||selInvoices.map(si=>si.doc).join('+'),
        amount:amt, payDate:nf.payDate, debitDate:nf.debitDate, bank:nf.bank,
        status: lf ? "planificado" : "processado",
        notes:nf.notes, linkedTo:null, linkedFrom:lf, debits:[]
      }];
      if (lf) u = u.map(x => x.id===lf ? {...x, linkedTo:id} : x);
      return u;
    });

    // FIX: Add to payables as a PENDING bank debit (not supplier payment — supplier is already paid)
    // The pending item in "Pagamentos" represents the bank's future debit
    if (setPayables) {
      setPayables(prev => [...prev, {
        id: genId(), supplier: `CF ${BC[nf.bank].l} — ${nf.supplier}`,
        doc: nf.doc||`CF-${BC[nf.bank].l}`,
        amount: amt,
        dueDate: nf.debitDate,  // Due date = when bank will debit
        category: "confirming",
        bank: nf.bank,
        method: `Confirming ${BC[nf.bank].l}`,
        pinned: false,
        partials: [],  // FIX: no partial — this is the bank debit not yet occurred
        ccLink: true,
        confirmingId: id,
        _cfEntry: true  // marker so we can find it when debit is processed
      }]);
    }

    // CC integration
    if (setCcSuppliers && selInvoices.length > 0) {
      setCcSuppliers(prev => prev.map(e => {
        const matching = selInvoices.filter(si => si.entityId===e.id);
        if (matching.length===0) return e;
        return { ...e, invoices: e.invoices.map(inv => {
          const sel = matching.find(si => si.invId===inv.id);
          if (!sel) return inv;
          return { ...inv, partials:[...inv.partials, {date:nf.payDate, amount:sel.amount, confirmingRef:`CF ${BC[nf.bank].l}`, confirmingId:id, pendingDebit:true}] };
        })};
      }));
    } else if (setCcSuppliers && nf.supplier && amt > 0) {
      const existing = (ccSuppliers||[]).find(e => e.name.toLowerCase()===nf.supplier.toLowerCase());
      const newPartial = {date:nf.payDate, amount:amt, confirmingRef:`CF ${BC[nf.bank].l}`, confirmingId:id, pendingDebit:true};
      if (existing) {
        setCcSuppliers(prev => prev.map(e => e.id===existing.id ? {
          ...e,
          invoices:[...e.invoices, {id:genId(), doc:nf.doc||`CF-${BC[nf.bank].l}`, amount:amt, dueDate:nf.payDate, partials:[newPartial], plannedDate:"", plannedAmount:0}]
        } : e));
      } else {
        setCcSuppliers(prev => [...prev, {
          id:genId(), name:nf.supplier, type:"fornecedor",
          invoices:[{id:genId(), doc:nf.doc||`CF-${BC[nf.bank].l}`, amount:amt, dueDate:nf.payDate, partials:[newPartial], plannedDate:"", plannedAmount:0}]
        }]);
      }
    }

    setShowForm(null);
    setNf({supplier:"",doc:"",amount:"",payDate:TODAY,debitDate:"",bank:"abanca",notes:"",linkedFrom:""});
    setMiniV(null);
    setSelInvoices([]);
  };

  const promote = (id) => setPays(p => p.map(x => x.id===id ? {...x,status:"processado"} : x));

  // FIX: addDeb — update CC correctly, update bank balance, update payables entry as paid
  const addDeb = (id) => {
    const a = parseFloat(da.amount);
    if (!a||a<=0) return;
    const bankId = da.bankId;
    if (!bankId) { alert("Por favor selecione a conta bancária debitada."); return; }

    const cfPay = pays.find(p=>p.id===id);
    if (!cfPay) return;

    // 1. Update confirming payment record
    setPays(prev => prev.map(p => {
      if (p.id!==id) return p;
      const nd = [...p.debits, {date:da.date, amount:a, bankId}];
      const newRem = p.amount - nd.reduce((s,d)=>s+d.amount,0);
      return {...p, debits:nd, status:newRem<=0.01?"liquidado":"processado"};
    }));

    // 2. FIX: Update CC — clear pendingDebit flag for this confirming entry
    if (setCcSuppliers) {
      setCcSuppliers(prevSup => prevSup.map(e => ({
        ...e,
        invoices: e.invoices.map(inv => ({
          ...inv,
          partials: inv.partials.map(part => {
            if (part.confirmingId===id && part.pendingDebit) {
              return {...part, pendingDebit:false, debitDate:da.date};
            }
            return part;
          })
        }))
      })));
    }

    // 3. FIX: Update bank balance — debit the amount
    if (bankId && setBankAccounts) {
      setBankAccounts(prevBanks => prevBanks.map(bank =>
        bank.id===bankId ? {...bank, balance:(bank.balance||0)-a} : bank
      ));
    }

    // 4. FIX: Mark the corresponding payables entry as paid
    if (setPayables) {
      setPayables(prev => prev.map(p => {
        if (p.confirmingId===id && p._cfEntry) {
          return {...p, partials:[...p.partials, {date:da.date, amount:a}]};
        }
        return p;
      }));
    }

    // 5. Register in completed payments
    if (setCompletedPayments) {
      setCompletedPayments(prev => [...prev, {
        id:genId(), date:da.date,
        supplier:`CF ${cfPay.bank==="abanca"?"Abanca":"BPI"} — ${cfPay.supplier}`,
        doc:cfPay.doc||"",
        amount:a, category:"confirming",
        method:`Confirming ${cfPay.bank==="abanca"?"Abanca":"BPI"}`,
        bank:bankId
      }]);
    }

    setShowDebit(null);
    setDa({date:TODAY,amount:"",bankId:""});
  };

  const navTo = (id) => {
    const p = pays.find(x=>x.id===id);
    if (p) { const dd=new Date(p.debitDate); setCv({y:dd.getFullYear(),m:dd.getMonth()}); setShowDetail(p); }
  };

  const clickDay = (ds) => {
    const debOnDay = pays.filter(p=>p.debitDate===ds&&p.status==="processado"&&!p.linkedTo&&rem(p)>0);
    const fd = debOnDay[0];
    setNf({supplier:"",doc:"",amount:fd?String(fd.amount):"",payDate:ds,debitDate:"",bank:fd?fd.bank:"abanca",notes:fd?"Reutilização "+fd.supplier+" ("+fmt(fd.amount)+")":"",linkedFrom:fd?String(fd.id):""});
    setShowForm({});
    setMiniV(null);
  };

  const reut = pays.filter(p=>p.status==="processado"&&!p.linkedTo&&rem(p)>0);
  const n14 = new Date(TODAY); n14.setDate(n14.getDate()+14);
  const upDeb = pays.filter(p=>p.status==="processado"&&rem(p)>0&&new Date(p.debitDate)<=n14&&new Date(p.debitDate)>=todayDate).sort((a,b)=>new Date(a.debitDate)-new Date(b.debitDate));
  const planToProc = pays.filter(p=>p.status==="planificado").sort((a,b)=>new Date(a.payDate)-new Date(b.payDate));

  const gmailPlan = (sup) => {
    const sp = pays.filter(p=>p.supplier===sup&&p.status!=="liquidado");
    let txt = emailLang==="pt"
      ? `Exmo(a) Sr(a),\n\nInformamos que estão previstos os seguintes pagamentos para a sua conta com a Yupik Outdoor, Lda.\n\nPagamentos planeados:\n\n`
      : emailLang==="en"
      ? `Dear Sir/Madam,\n\nWe are writing to inform you of our planned payment schedule.\n\nPlanned payments:\n\n`
      : `Estimado/a,\n\nLe informamos del plan de pagos previsto.\n\nPagos planificados:\n\n`;
    sp.forEach(p => { txt+=`${fmtDate(p.payDate)}\t${fmt(p.amount)}\t${p.doc}\t${BC[p.bank].l}\n`; });
    txt+=`\nTotal: ${fmt(sp.reduce((s,p)=>s+p.amount,0))}\n\nCom os melhores cumprimentos,\nMárcio Monteiro\nYupik Outdoor, Lda.`;
    window.open(`https://mail.google.com/mail/?view=cm&fs=1&su=${encodeURIComponent(`Yupik Outdoor — Plano Confirming ${sup}`)}&body=${encodeURIComponent(txt)}`,'_blank');
  };

  const uSup = [...new Set(pays.filter(p=>p.status!=="liquidado").map(p=>p.supplier))];

  const renderNav = (v,setV) => (
    <div className="flex items-center gap-2">
      <button onClick={()=>setV(prevM(v))} className="p-1 rounded hover:bg-stone-100">◀</button>
      <span className="text-[13px] font-semibold text-stone-900 min-w-[140px] text-center">{ymLabel(v)}</span>
      <button onClick={()=>setV(nextM(v))} className="p-1 rounded hover:bg-stone-100">▶</button>
    </div>
  );

  const renderCal = (v,items,onDayClick,onItemClick) => {
    const days = getDays(v.y,v.m);
    return (
      <div className="grid grid-cols-7 gap-1 text-center">
        {["Seg","Ter","Qua","Qui","Sex","Sáb","Dom"].map(d=><div key={d} className="text-[9px] font-semibold text-stone-400 py-0.5">{d}</div>)}
        {days.map((day,i)=>{
          if (!day) return <div key={`e${i}`} className="h-20"/>;
          const ds=dsFmt(v.y,v.m,day);
          const dI=items.filter(c=>c.calDate===ds);
          const isT=ds===TODAY;
          const cl=isCl(v.y,v.m,day);
          return (
            <div key={i} className={`h-20 rounded-lg border text-left p-0.5 overflow-hidden cursor-pointer transition-all hover:ring-2 hover:ring-stone-400 ${isT?'border-stone-800 bg-stone-50':cl?'border-amber-200 bg-amber-50/40':'border-stone-100'}`}
              onClick={()=>onDayClick&&onDayClick(ds)}>
              <div className="flex items-center gap-0.5">
                <span className={`text-[9px] font-medium ${isT?'text-stone-900':cl?'text-amber-500':'text-stone-400'}`}>{day}</span>
                {cl&&<span className="text-[7px] text-amber-400">●</span>}
              </div>
              {dI.slice(0,3).map((c,ci)=>{
                const isL=c.status==="liquidado"; const isP=c.status==="planificado";
                return (
                  <div key={`${c.id}-${c.ct}-${ci}`} className="text-[7px] leading-tight px-0.5 py-0.5 rounded mt-0.5 truncate"
                    onClick={e=>{e.stopPropagation();onItemClick&&onItemClick(c);}}
                    style={{backgroundColor:isL?BC[c.bank].d:isP?BC[c.bank].pl:BC[c.bank].p,color:isL||isP?isP?'#333':'#fff':'#fff',border:isP?'1px dashed #888':'none',opacity:isL?.45:1}}>
                    {c.ct==="pay"?"▸":"◂"} {c.supplier.split(' ')[0]} {fmtNum(c.amount)}
                  </div>
                );
              })}
              {dI.length>3&&<div className="text-[6px] text-stone-400">+{dI.length-3}</div>}
            </div>
          );
        })}
      </div>
    );
  };

  return (
    <div className="space-y-5 p-4">
      {/* Dashboard */}
      {(upDeb.length>0||planToProc.length>0)&&(
        <Card className="p-4 border-sky-200 bg-sky-50/30">
          <h4 className="font-semibold text-sky-800 text-[13px] mb-3 flex items-center gap-2"><Bell size={14}/>Próximas Acções</h4>
          <div className="grid grid-cols-2 gap-3">
            {upDeb.length>0&&<div className="space-y-1"><p className="text-[10px] font-semibold text-stone-600 uppercase">Débitos próx. 14d</p>{upDeb.slice(0,4).map(p=>(
              <div key={p.id} className="flex items-center justify-between bg-white rounded-lg px-2 py-1.5 text-xs cursor-pointer hover:bg-stone-50" onClick={()=>setShowDetail(p)}>
                <span className="font-medium">{p.supplier}</span><span><span className="px-1 py-0.5 rounded text-[9px] text-white font-bold" style={{backgroundColor:BC[p.bank].p}}>{BC[p.bank].l}</span> {fmt(rem(p))} · {fmtDate(p.debitDate)}</span>
              </div>))}</div>}
            {planToProc.length>0&&<div className="space-y-1"><p className="text-[10px] font-semibold text-stone-600 uppercase">Planificados → processar</p>{planToProc.slice(0,4).map(p=>(
              <div key={p.id} className="flex items-center justify-between bg-white rounded-lg px-2 py-1.5 text-xs">
                <span>{p.supplier} {fmt(p.amount)}</span>
                <Button size="xs" variant="ghost" onClick={()=>promote(p.id)}><ArrowUpRight size={11} className="text-blue-600"/>Proc</Button>
              </div>))}</div>}
          </div>
        </Card>
      )}

      {/* Plafond */}
      <div className="grid grid-cols-2 gap-4">
        {["abanca","bpi"].map(bk=>{const p=pl[bk];return(
          <Card key={bk} className="p-4">
            <div className="flex items-center justify-between mb-2">
              <div><p className="font-semibold text-stone-900">{BC[bk].l}</p><p className="text-[11px] text-stone-400">Plafond: {fmt(p.limit)}</p></div>
              <Badge variant={p.free<2000?"danger":"default"}>{fmt(p.free)} livre</Badge>
            </div>
            <div className="w-full bg-stone-100 rounded-full h-3 mb-2">
              <div style={{width:`${Math.min(100,(p.occ/p.limit)*100)}%`,backgroundColor:BC[bk].p}} className="h-3 rounded-full"/>
            </div>
            <p className="text-[11px] text-stone-500">Ocupado: {fmt(p.occ)}</p>
          </Card>
        );})}
      </div>

      {/* Calendar */}
      <Card className="p-5">
        <div className="flex items-center justify-between mb-3">
          {renderNav(cv,setCv)}
          <div className="flex gap-4 text-xs">
            {["abanca","bpi"].map(bk=>{const md=mPv(bk,cv.y,cv.m);return(<div key={bk}><span style={{color:BC[bk].p}} className="font-semibold">{BC[bk].l}:</span> P:{fmt(md.proc)} L:{fmt(md.liq)}</div>);})}
          </div>
        </div>
        {renderCal(cv,calIt(cv.y,cv.m),clickDay,setShowDetail)}
      </Card>

      {/* Projection */}
      <Card className="p-4">
        <h4 className="font-semibold text-stone-900 text-[13px] mb-3">Projeção 18 Meses</h4>
        <ResponsiveContainer width="100%" height={180}>
          <BarChart data={mProj} onClick={d=>{if(d&&d.activeLabel){const pts=d.activeLabel.split(' ');const mi=MN.indexOf(pts[0]);const yr=2000+parseInt(pts[1]);if(mi>=0)setCv({y:yr,m:mi});}}}>
            <CartesianGrid strokeDasharray="3 3" stroke="#e7e5e4"/>
            <XAxis dataKey="month" tick={{fontSize:9}}/>
            <YAxis tick={{fontSize:10}} tickFormatter={v=>`${(v/1000).toFixed(0)}k`}/>
            <Tooltip formatter={v=>fmt(v)}/>
            <Legend/>
            <Bar dataKey="aP" name="Ab proc." stackId="a" fill="#2563eb"/>
            <Bar dataKey="aPl" name="Ab plan." stackId="a" fill="#93c5fd" radius={[4,4,0,0]}/>
            <Bar dataKey="bP" name="BPI proc." stackId="b" fill="#ea580c"/>
            <Bar dataKey="bPl" name="BPI plan." stackId="b" fill="#fdba74" radius={[4,4,0,0]}/>
          </BarChart>
        </ResponsiveContainer>
      </Card>

      {/* Actions */}
      <div className="flex items-center justify-between flex-wrap gap-2">
        <h4 className="font-semibold text-stone-900">Pagamentos Confirming</h4>
        <div className="flex gap-2 items-center">
          <select className="px-2 py-1 rounded border border-stone-200 text-[11px]" value={emailLang} onChange={e=>setEmailLang(e.target.value)}>
            <option value="pt">PT</option><option value="en">EN</option><option value="es">ES</option>
          </select>
          {uSup.length>0&&<select className="px-2 py-1 rounded border border-stone-200 text-xs" onChange={e=>{if(e.target.value)gmailPlan(e.target.value);e.target.value="";}}>
            <option value="">Exportar plano...</option>
            {uSup.map(s=><option key={s} value={s}>{s}</option>)}
          </select>}
          <Button onClick={()=>{setShowForm({});setNf({supplier:"",doc:"",amount:"",payDate:TODAY,debitDate:"",bank:"abanca",notes:"",linkedFrom:""});setMiniV(null);}}>
            <Plus size={14}/>Agendar
          </Button>
        </div>
      </div>

      {/* Table */}
      <Card className="overflow-hidden">
        <table className="w-full text-sm">
          <thead><tr className="bg-stone-50 border-b border-stone-200">
            <th className="text-left py-2 px-2 text-[11px] text-stone-500">Fornecedor</th>
            <th className="text-right py-2 px-2 text-[11px] text-stone-500">Valor</th>
            <th className="text-center py-2 px-2 text-[11px] text-stone-500">Pag.</th>
            <th className="text-center py-2 px-2 text-[11px] text-stone-500">Débito</th>
            <th className="text-center py-2 px-2 text-[11px] text-stone-500">Banco</th>
            <th className="text-center py-2 px-2 text-[11px] text-stone-500">Estado</th>
            <th className="text-right py-2 px-2 text-[11px] text-stone-500">Restante</th>
            <th className="w-16"></th>
          </tr></thead>
          <tbody>
            {pays.sort((a,b)=>new Date(a.debitDate)-new Date(b.debitDate)).map(p=>{
              const isL=p.status==="liquidado";const isP=p.status==="planificado";const r=rem(p);const dt=debT(p);
              return (
                <tr key={p.id} className={`border-b border-stone-100 ${isL?'opacity-40 bg-stone-50':'hover:bg-stone-50'}`}>
                  <td className="py-2 px-2"><span className="font-medium text-[13px]">{p.supplier}</span><br/><span className="font-mono text-[9px] text-stone-400">{p.doc}</span></td>
                  <td className="py-2 px-2 text-right font-semibold text-[13px] text-red-600">{fmt(p.amount)}</td>
                  <td className="py-2 px-2 text-center text-[11px]">{fmtDate(p.payDate)}</td>
                  <td className="py-2 px-2 text-center text-[11px]">{fmtDate(p.debitDate)}</td>
                  <td className="py-2 px-2 text-center"><span className="px-1.5 py-0.5 rounded text-[9px] font-bold text-white" style={{backgroundColor:BC[p.bank].p}}>{BC[p.bank].l}</span></td>
                  <td className="py-2 px-2 text-center"><span className="px-1.5 py-0.5 rounded text-[9px] font-semibold" style={{backgroundColor:isL?'#d1d5db':isP?BC[p.bank].pl:BC[p.bank].p,color:isL?'#6b7280':isP?'#333':'#fff',border:isP?'1px dashed #888':'none'}}>{isL?"Liq":isP?"Plan":"Proc"}</span></td>
                  <td className="py-2 px-2 text-right text-[11px]">{dt>0&&<span className="text-emerald-600">{fmt(dt)}</span>}{r>0.01&&<span className="text-red-500 ml-1">/{fmt(r)}</span>}</td>
                  <td className="py-2 px-2">
                    {!isL&&<div className="flex items-center justify-center gap-0.5">
                      {isP&&<Button size="xs" variant="ghost" onClick={()=>promote(p.id)}><ArrowUpRight size={11} className="text-blue-600"/></Button>}
                      {!isP&&<Button size="xs" variant="ghost" onClick={()=>{setShowDebit(p);setDa({date:TODAY,amount:String(r),bankId:""});}}><Banknote size={11} className="text-emerald-600"/></Button>}
                      <Button size="xs" variant="ghost" onClick={()=>setShowNotes(p.id)}><Edit3 size={11} className="text-stone-400"/></Button>
                    </div>}
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </Card>

      {/* Schedule Form — FIX: buttons always visible (sticky footer) */}
      <Modal open={!!showForm} onClose={()=>{setShowForm(null);setMiniV(null);}} title="Agendar Pagamento Confirming" wide noPad>
        <div className="flex flex-col" style={{height:'80vh'}}>
          <div className="flex-1 overflow-auto px-6 py-4 space-y-4">
            <div className="grid grid-cols-3 gap-3">
              <div>
                <label className="block text-[11px] font-medium text-stone-500 mb-1 uppercase tracking-wider">Fornecedor</label>
                <input className="w-full px-3 py-2 rounded-lg border border-stone-200 text-sm" value={nf.supplier} onChange={e=>setNf({...nf,supplier:e.target.value})} list="cfs" placeholder="Escreva..."/>
                <datalist id="cfs">{allSup.map(s=><option key={s} value={s}/>)}</datalist>
              </div>
              <Input label="Documento" value={nf.doc} onChange={e=>setNf({...nf,doc:e.target.value})}/>
              <Input label="Valor €" type="number" value={nf.amount} onChange={e=>setNf({...nf,amount:e.target.value})}/>
              <Select label="Banco" value={nf.bank} onChange={e=>setNf({...nf,bank:e.target.value})}><option value="abanca">Abanca</option><option value="bpi">BPI</option></Select>
              <Input label="Data pagamento fornecedor" type="date" value={nf.payDate} onChange={e=>setNf({...nf,payDate:e.target.value})}/>
              <Input label="Data débito bancário" type="date" value={nf.debitDate} onChange={e=>setNf({...nf,debitDate:e.target.value})} max={maxDD(nf.payDate)}/>
            </div>

            {/* Linked invoices from CC */}
            {nf.supplier&&(()=>{
              const {entity,invoices}=getSupplierInvoices(nf.supplier);
              if (!entity&&!nf.supplier) return null;
              return(
                <div className="border border-stone-200 rounded-xl p-3 bg-stone-50/50">
                  <p className="text-[11px] font-semibold text-stone-600 uppercase mb-2">
                    {entity?`Faturas pendentes — ${entity.name} (${invoices.length})`:`"${nf.supplier}" — sem CC (será criada automaticamente)`}
                  </p>
                  {invoices.length>0?(
                    <div className="space-y-1">
                      {invoices.map(inv=>{
                        const bal=getInvBalance(inv);
                        const sel=selInvoices.find(si=>si.invId===inv.id);
                        return(
                          <div key={inv.id} className={`flex items-center gap-2 p-2 rounded-lg border text-xs ${sel?'border-sky-300 bg-sky-50':'border-stone-200 bg-white'}`}>
                            <input type="checkbox" checked={!!sel} onChange={e=>{
                              if (e.target.checked){
                                setSelInvoices(prev=>[...prev,{invId:inv.id,entityId:entity.id,doc:inv.doc,amount:bal,partial:false}]);
                                const newTotal=[...selInvoices,{amount:bal}].reduce((s,x)=>s+x.amount,0);
                                setNf(prev=>({...prev,amount:String(newTotal),doc:prev.doc||inv.doc}));
                              } else {
                                const updated=selInvoices.filter(si=>si.invId!==inv.id);
                                setSelInvoices(updated);
                                setNf(prev=>({...prev,amount:updated.reduce((s,x)=>s+x.amount,0)>0?String(updated.reduce((s,x)=>s+x.amount,0)):""}));
                              }
                            }} className="rounded"/>
                            <span className="font-mono text-[10px] text-stone-500">{inv.doc}</span>
                            <span className="text-stone-700">Saldo: <strong className="text-red-600">{fmt(bal)}</strong></span>
                            <span className="text-stone-400">Venc: {fmtDate(inv.dueDate)}</span>
                          </div>
                        );
                      })}
                    </div>
                  ):(entity?<p className="text-[10px] text-emerald-600">Todas liquidadas.</p>:null)}
                </div>
              );
            })()}

            {/* Mini calendar for debit date selection */}
            {nf.payDate&&(()=>{
              const mxDt=maxDD(nf.payDate);
              const mv=miniV||{y:nf.debitDate?new Date(nf.debitDate).getFullYear():new Date(nf.payDate).getFullYear(),m:nf.debitDate?new Date(nf.debitDate).getMonth():new Date(nf.payDate).getMonth()};
              const cDays=getDays(mv.y,mv.m);
              const cIt=calIt(mv.y,mv.m);
              return(
                <div className="border border-stone-200 rounded-xl p-3 bg-stone-50/50">
                  <div className="flex items-center justify-between mb-2">
                    {renderNav(mv,setMiniV)}
                    <p className="text-[10px] text-stone-400">Clica num dia para selecionar data de débito</p>
                  </div>
                  <div className="grid grid-cols-7 gap-0.5 text-center">
                    {["S","T","Q","Q","S","S","D"].map((d,di)=><div key={di} className="text-[8px] font-bold text-stone-400">{d}</div>)}
                    {cDays.map((day,di)=>{
                      if (!day) return <div key={"me"+di} className="h-11"/>;
                      const ds=dsFmt(mv.y,mv.m,day);
                      const dis=ds>mxDt||ds<nf.payDate;
                      const sel=ds===nf.debitDate;
                      const cl=isCl(mv.y,mv.m,day);
                      const dI=cIt.filter(c=>c.calDate===ds);
                      return(
                        <div key={di} className={`h-11 rounded border p-0.5 overflow-hidden text-[7px] transition-all ${sel?'ring-2 ring-stone-800 bg-stone-100':dis?'opacity-20':'cursor-pointer hover:ring-1 hover:ring-stone-400'} ${cl&&!dis?'bg-amber-50/50 border-amber-200':'border-stone-200'}`}
                          onClick={()=>!dis&&setNf(prev=>({...prev,debitDate:ds}))}>
                          <span className={`text-[8px] font-medium ${sel?'text-stone-900':cl?'text-amber-500':'text-stone-400'}`}>{day}</span>
                          {dI.slice(0,2).map((c,ci)=>(<div key={ci} className="truncate rounded" style={{backgroundColor:c.status==="liquidado"?'#d1d5db':c.status==="planificado"?BC[c.bank].pl:BC[c.bank].p,color:'#fff',fontSize:'5.5px',lineHeight:'8px',padding:'0 1px'}}>{c.ct==="pay"?"▸":"◂"}{c.supplier.split(' ')[0]}</div>))}
                        </div>
                      );
                    })}
                  </div>
                </div>
              );
            })()}

            <Select label={`Reutilização plafond — ${BC[nf.bank].l}`} value={nf.linkedFrom} onChange={e=>setNf({...nf,linkedFrom:e.target.value})}>
              <option value="">Novo (ocupa plafond)</option>
              {reut.filter(p=>p.bank===nf.bank).map(p=><option key={p.id} value={p.id}>[{BC[p.bank].l}] Déb {fmtDate(p.debitDate)}: {p.supplier} {fmt(p.amount)}</option>)}
            </Select>
            {nf.linkedFrom&&<p className="text-xs text-sky-600 bg-sky-50 p-2 rounded">Será "planificado" até processar no banco.</p>}
            <div>
              <label className="block text-[11px] font-medium text-stone-500 mb-1 uppercase tracking-wider">Notas</label>
              <textarea className="w-full px-3 py-2 rounded-lg border border-stone-200 text-sm" rows={2} value={nf.notes} onChange={e=>setNf({...nf,notes:e.target.value})}/>
            </div>
          </div>
          {/* FIX: Buttons always visible in sticky footer */}
          <div className="flex-shrink-0 border-t border-stone-200 bg-white px-6 py-4 flex justify-end gap-3">
            <Button variant="outline" onClick={()=>{setShowForm(null);setMiniV(null);}}>Cancelar</Button>
            <Button onClick={save} disabled={!nf.supplier||!nf.amount||!nf.debitDate}>Agendar Pagamento</Button>
          </div>
        </div>
      </Modal>

      {/* Debit Modal — FIX: Bank account selector with all accounts */}
      <Modal open={!!showDebit} onClose={()=>setShowDebit(null)} title="Registar Débito Bancário">
        {showDebit&&(
          <div className="space-y-4">
            <div className="p-3 bg-stone-50 rounded-lg">
              <p className="font-medium">{showDebit.supplier} — {fmt(showDebit.amount)}</p>
              <p className="text-sm text-stone-500">Debitado: {fmt(debT(showDebit))} · Restante: <strong className="text-red-600">{fmt(rem(showDebit))}</strong></p>
              {showDebit.debits.length>0&&<div className="mt-2 space-y-0.5">{showDebit.debits.map((d,i)=><div key={i} className="text-xs flex justify-between text-stone-400"><span>{fmtDate(d.date)}</span><span className="text-emerald-600">{fmt(d.amount)}</span></div>)}</div>}
            </div>
            <div className="grid grid-cols-2 gap-3">
              <Input label="Data" type="date" value={da.date} onChange={e=>setDa({...da,date:e.target.value})}/>
              <Input label="Valor €" type="number" value={da.amount} onChange={e=>setDa({...da,amount:e.target.value})}/>
            </div>
            {/* FIX: All bank accounts available */}
            <Select label="Conta Bancária debitada" value={da.bankId} onChange={e=>setDa({...da,bankId:e.target.value})}>
              <option value="">— Selecionar conta —</option>
              {bankAccounts.filter(b=>!b.archived).map(b=><option key={b.id} value={b.id}>{b.name} (saldo: {fmt(b.balance)})</option>)}
            </Select>
            <p className="text-xs text-stone-400">O saldo da conta selecionada será reduzido pelo valor do débito.</p>
            <div className="flex justify-end gap-2">
              <Button variant="outline" onClick={()=>setShowDebit(null)}>Cancelar</Button>
              <Button variant="success" onClick={()=>addDeb(showDebit.id)} disabled={!da.bankId}>
                <Check size={14}/>Registar Débito
              </Button>
            </div>
          </div>
        )}
      </Modal>

      {/* Detail Modal */}
      <Modal open={!!showDetail} onClose={()=>setShowDetail(null)} title="Detalhe">
        {showDetail&&(()=>{
          const f=pays.find(p=>p.id===showDetail.id)||showDetail;
          const lk=f.linkedFrom?pays.find(p=>p.id===f.linkedFrom):null;
          const lff=f.linkedTo?pays.find(p=>p.id===f.linkedTo):null;
          return(
            <div className="space-y-3">
              <div className="grid grid-cols-2 gap-3 text-sm">
                <div><span className="text-[11px] text-stone-500">Fornecedor</span><p className="font-semibold">{f.supplier}</p></div>
                <div><span className="text-[11px] text-stone-500">Valor</span><p className="font-semibold text-red-600">{fmt(f.amount)}</p></div>
                <div><span className="text-[11px] text-stone-500">Pagamento</span><p>{fmtDate(f.payDate)}</p></div>
                <div><span className="text-[11px] text-stone-500">Débito</span><p>{fmtDate(f.debitDate)}</p></div>
                <div><span className="text-[11px] text-stone-500">Banco</span><p>{BC[f.bank].l}</p></div>
                <div><span className="text-[11px] text-stone-500">Estado</span><p>{f.status}</p></div>
              </div>
              {f.debits.length>0&&<div className="p-2 bg-stone-50 rounded-lg text-xs">{f.debits.map((d,i)=><div key={i} className="flex justify-between"><span>{fmtDate(d.date)}</span><span className="text-emerald-600">{fmt(d.amount)}</span></div>)}<p className="font-semibold mt-1">Restante: {fmt(rem(f))}</p></div>}
              {f.notes&&<div className="p-2 bg-stone-50 rounded-lg text-xs">{f.notes}</div>}
              {lk&&<div className="p-2 bg-sky-50 rounded-lg border border-sky-200 cursor-pointer text-xs" onClick={()=>{setShowDetail(null);setTimeout(()=>navTo(lk.id),100);}}>← {lk.supplier} {fmt(lk.amount)}</div>}
              {lff&&<div className="p-2 bg-violet-50 rounded-lg border border-violet-200 cursor-pointer text-xs" onClick={()=>{setShowDetail(null);setTimeout(()=>navTo(lff.id),100);}}>→ {lff.supplier} {fmt(lff.amount)}</div>}
              <div className="flex gap-2">
                {f.status==="planificado"&&<Button size="sm" onClick={()=>{promote(f.id);setShowDetail(null);}}>Processar</Button>}
                {f.status==="processado"&&<Button size="sm" variant="success" onClick={()=>{setShowDetail(null);setShowDebit(f);setDa({date:TODAY,amount:String(rem(f)),bankId:""});}}><Banknote size={13}/>Débito</Button>}
                <Button size="sm" variant="outline" onClick={()=>setShowDetail(null)}>Fechar</Button>
              </div>
            </div>
          );
        })()}
      </Modal>

      <Modal open={!!showNotes} onClose={()=>setShowNotes(null)} title="Notas">
        {showNotes&&(()=>{
          const p=pays.find(x=>x.id===showNotes);
          if (!p) return null;
          return(<div className="space-y-3"><p className="text-sm"><strong>{p.supplier}</strong></p><textarea className="w-full px-3 py-2 rounded-lg border border-stone-200 text-sm" rows={3} value={p.notes||""} onChange={e=>setPays(prev=>prev.map(x=>x.id===p.id?{...x,notes:e.target.value}:x))}/><Button onClick={()=>setShowNotes(null)}>Guardar</Button></div>);
        })()}
      </Modal>
    </div>
  );
};

// ==================== CONTAS CORRENTE MODULE ====================
const ContasCorrenteModule = ({ ccSuppliers, setCcSuppliers, ccClients, setCcClients, payables, setPayables }) => {
  const [tab, setTab] = useState("fornecedores");
  const [search, setSearch] = useState("");
  const [selected, setSelected] = useState(null);
  const [showAddInv, setShowAddInv] = useState(false);
  const [showCopied, setShowCopied] = useState(false);
  const [showRegPayment, setShowRegPayment] = useState(null);
  const [regPayData, setRegPayData] = useState({ date:TODAY, amount:"" });
  const [newInv, setNewInv] = useState({ doc:"", amount:"", dueDate:"", plannedDate:"", plannedAmount:"" });
  const [editPlan, setEditPlan] = useState(null);
  const [planData, setPlanData] = useState({ plannedDate:"", plannedAmount:"" });

  const list = tab === "fornecedores" ? ccSuppliers : ccClients;
  const setList = tab === "fornecedores" ? setCcSuppliers : setCcClients;
  const filtered = list.filter(c => c.name.toLowerCase().includes(search.toLowerCase()));

  // FIX: getInvBalance allows negative (means we're owed money back / a nosso favor)
  const getInvBalance = (inv) => inv.amount - inv.partials.reduce((s,p) => s+p.amount, 0);
  // totalOwed: sum of all balances (positive = we owe, negative = they owe us)
  const totalOwed = list.reduce((s,c) => s+c.invoices.reduce((si,inv) => si+getInvBalance(inv),0),0);
  const totalOverdue = list.reduce((s,c) => s+c.invoices.filter(inv=>isOverdue(inv.dueDate)&&getInvBalance(inv)>0).reduce((si,inv)=>si+getInvBalance(inv),0),0);

  const generateText = (entity) => {
    const isClient = entity.type==="cliente";
    let text = isClient
      ? `Exmo(a) Sr(a),\n\nA vossa conta corrente junto da Yupik Outdoor apresenta os seguintes valores pendentes:\n\n`
      : `Exmo(a) Sr(a),\n\nPlano de pagamentos previsto para a vossa conta corrente:\n\n`;
    entity.invoices.forEach(inv => {
      const bal=getInvBalance(inv);
      text+=`Documento: ${inv.doc}\n  Original: ${fmt(inv.amount)}\n`;
      if (inv.partials.length>0) { text+=`  Pagamentos:\n`; inv.partials.forEach(p=>{ text+=`    ${fmtDateFull(p.date)} — ${fmt(p.amount)}${p.confirmingRef?` (${p.confirmingRef}${p.pendingDebit?' - CF pend.deb.':''})':''}\n`; }); }
      text+=`  Saldo: ${bal>0.01?fmt(bal):'LIQUIDADO'}\n`;
      if (bal>0.01&&inv.plannedDate&&inv.plannedAmount>0) text+=`  Previsão: ${fmtDateFull(inv.plannedDate)} — ${fmt(inv.plannedAmount)}\n`;
      text+=`\n`;
    });
    const total=entity.invoices.reduce((s,i)=>s+Math.max(0,getInvBalance(i)),0);
    text+=`Total pendente: ${fmt(total)}\n\nCom os melhores cumprimentos,\nYupik Outdoor, Lda.`;
    return text;
  };

  const openGmail = (entity) => {
    const text=generateText(entity);
    const isClient=entity.type==="cliente";
    window.open(`https://mail.google.com/mail/?view=cm&fs=1&su=${encodeURIComponent(`Yupik Outdoor — ${isClient?'Conta corrente':'Plano de pagamentos'}`)}&body=${encodeURIComponent(text)}`,'_blank');
  };

  const copyPlan = (entity) => {
    try { navigator.clipboard.writeText(generateText(entity)).then(()=>{setShowCopied(true);setTimeout(()=>setShowCopied(false),2000);}); } catch(e) {}
  };

  const savePlannedPayment = (entityId,invId) => {
    setList(prev=>prev.map(e=>e.id===entityId?{...e,invoices:e.invoices.map(inv=>inv.id===invId?{...inv,plannedDate:planData.plannedDate,plannedAmount:parseFloat(planData.plannedAmount)||0}:inv)}:e));
    setEditPlan(null);
  };

  const addInvoice = () => {
    if (!selected||!newInv.doc||!newInv.amount) return;
    setList(prev=>prev.map(e=>e.id===selected.id?{...e,invoices:[...e.invoices,{id:genId(),doc:newInv.doc,amount:parseFloat(newInv.amount),dueDate:newInv.dueDate||TODAY,partials:[],plannedDate:newInv.plannedDate,plannedAmount:parseFloat(newInv.plannedAmount)||0}]}:e));
    setShowAddInv(false);
    setNewInv({doc:"",amount:"",dueDate:"",plannedDate:"",plannedAmount:""});
  };

  const registerCCPayment = () => {
    if (!showRegPayment) return;
    const amt=parseFloat(regPayData.amount);
    if (!amt||amt<=0) return;
    const {entityId,invId}=showRegPayment;
    setList(prev=>prev.map(e=>e.id===entityId?{...e,invoices:e.invoices.map(inv=>inv.id===invId?{...inv,partials:[...inv.partials,{date:regPayData.date,amount:amt}]}:inv)}:e));
    setShowRegPayment(null);
    setRegPayData({date:TODAY,amount:""});
  };

  // When selected entity changes (tab change), update reference
  const selEntity = selected ? list.find(e => e.id === selected.id) : null;

  return (
    <div className="space-y-5">
      <div className="flex gap-4 border-b border-stone-200 pb-3">
        <button onClick={()=>{setTab("fornecedores");setSelected(null);}} className={`text-sm font-medium pb-1 border-b-2 transition-all ${tab==="fornecedores"?'border-stone-800 text-stone-900':'border-transparent text-stone-400'}`}>
          Fornecedores <Badge className="ml-1">{ccSuppliers.length}</Badge>
        </button>
        <button onClick={()=>{setTab("clientes");setSelected(null);}} className={`text-sm font-medium pb-1 border-b-2 transition-all ${tab==="clientes"?'border-stone-800 text-stone-900':'border-transparent text-stone-400'}`}>
          Clientes <Badge className="ml-1">{ccClients.length}</Badge>
        </button>
      </div>

      <div className="grid grid-cols-3 gap-4">
        <Card className="p-4"><p className="text-[11px] text-stone-400 uppercase font-medium">{tab==="fornecedores"?"Em dívida":"A receber"}</p><p className="text-xl font-bold text-stone-900 mt-1">{fmt(totalOwed)}</p></Card>
        <Card className="p-4"><p className="text-[11px] text-stone-400 uppercase font-medium">Vencido</p><p className="text-xl font-bold text-red-600 mt-1">{fmt(totalOverdue)}</p></Card>
        <Card className="p-4"><p className="text-[11px] text-stone-400 uppercase font-medium">Entidades</p><p className="text-xl font-bold text-stone-900 mt-1">{list.length}</p></Card>
      </div>

      <div className="grid grid-cols-3 gap-5">
        <Card className="col-span-1 p-4 max-h-[600px] overflow-auto">
          <div className="relative mb-3"><Search size={14} className="absolute left-2.5 top-2 text-stone-400"/><input className="w-full pl-8 pr-3 py-1.5 rounded-lg border border-stone-200 text-sm" placeholder="Pesquisar..." value={search} onChange={e=>setSearch(e.target.value)}/></div>
          <div className="space-y-0.5">
            {filtered.map(entity=>{
              const bal=entity.invoices.reduce((s,i)=>s+getInvBalance(i),0);
              const hasOverdue=entity.invoices.some(i=>isOverdue(i.dueDate)&&getInvBalance(i)>0);
              return(
                <button key={entity.id} onClick={()=>setSelected(entity)} className={`w-full text-left px-3 py-2.5 rounded-lg text-sm transition-all ${selected?.id===entity.id?'bg-stone-800 text-white':'hover:bg-stone-50'}`}>
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-1.5">
                      {hasOverdue&&<AlertCircle size={11} className={selected?.id===entity.id?"text-red-300":"text-red-500"}/>}
                      <span className="font-medium">{entity.name}</span>
                    </div>
                    <span className={`text-[11px] font-semibold ${selected?.id===entity.id?'text-stone-300':bal<0?'text-emerald-600':'text-red-600'}`}>
                      {bal<0?`A nosso favor: ${fmt(Math.abs(bal))}`:fmt(bal)}
                    </span>
                  </div>
                </button>
              );
            })}
          </div>
        </Card>

        <Card className="col-span-2 p-5 max-h-[600px] overflow-auto">
          {selEntity?(
            <div>
              <div className="flex items-center justify-between mb-4">
                <h4 className="font-semibold text-stone-900 text-lg">{selEntity.name}</h4>
                <div className="flex gap-2">
                  <Button variant="outline" size="sm" onClick={()=>copyPlan(selEntity)}>{showCopied?<><Check size={13}/>Copiado</>:<><Copy size={13}/>Copiar</>}</Button>
                  <Button variant="outline" size="sm" onClick={()=>openGmail(selEntity)}><Mail size={13}/>Gmail</Button>
                  <Button size="sm" onClick={()=>setShowAddInv(true)}><Plus size={13}/>Fatura</Button>
                </div>
              </div>
              <table className="w-full text-sm">
                <thead><tr className="border-b border-stone-200">
                  <th className="text-left py-2 px-2 text-[11px] text-stone-500 font-medium">Doc</th>
                  <th className="text-right py-2 px-2 text-[11px] text-stone-500 font-medium">Valor</th>
                  <th className="text-center py-2 px-2 text-[11px] text-stone-500 font-medium">Vencimento</th>
                  <th className="text-right py-2 px-2 text-[11px] text-stone-500 font-medium">Pago</th>
                  <th className="text-right py-2 px-2 text-[11px] text-stone-500 font-medium">Saldo</th>
                  {tab==="fornecedores"&&<th className="text-center py-2 px-2 text-[11px] text-stone-500 font-medium">Pag. previsto</th>}
                  <th className="text-center py-2 px-2 text-[11px] text-stone-500 font-medium">Estado</th>
                  <th className="w-10"></th>
                </tr></thead>
                <tbody>
                  {selEntity.invoices.map(inv=>{
                    const bal=getInvBalance(inv);
                    const paid=inv.amount-bal;
                    const overdue=isOverdue(inv.dueDate)&&bal>0;
                    const hasPendingCF=inv.partials.some(p=>p.pendingDebit);
                    return(
                      <tr key={inv.id} className={`border-b border-stone-100 ${overdue?'bg-red-50/30':''}`}>
                        <td className="py-2 px-2 font-mono text-xs">{inv.doc}</td>
                        <td className="py-2 px-2 text-right">{fmt(inv.amount)}</td>
                        <td className="py-2 px-2 text-center">{fmtDate(inv.dueDate)}</td>
                        <td className="py-2 px-2 text-right text-emerald-600">
                          {paid>0?fmt(paid):"—"}
                          {/* FIX: Show CF pending debit status clearly */}
                          {hasPendingCF&&<div className="text-[9px] text-amber-600 font-semibold">CF pend.déb.</div>}
                        </td>
                        <td className="py-2 px-2 text-right font-medium">
                          {Math.abs(bal)<0.01
                            ? <span className="text-emerald-600">Liquidado</span>
                            : bal<0
                            ? <span className="text-emerald-700 font-bold">A nosso favor: {fmt(Math.abs(bal))}</span>
                            : <span className="text-red-600">{fmt(bal)}</span>}
                        </td>
                        {tab==="fornecedores"&&<td className="py-2 px-2 text-center">
                          {editPlan===inv.id?(
                            <div className="flex gap-1 items-center">
                              <input type="date" className="px-1 py-0.5 border rounded text-xs w-24" value={planData.plannedDate} onChange={e=>setPlanData({...planData,plannedDate:e.target.value})}/>
                              <input type="number" className="px-1 py-0.5 border rounded text-xs w-16" value={planData.plannedAmount} onChange={e=>setPlanData({...planData,plannedAmount:e.target.value})}/>
                              <button onClick={()=>savePlannedPayment(selEntity.id,inv.id)} className="text-emerald-600"><Check size={13}/></button>
                              <button onClick={()=>setEditPlan(null)} className="text-stone-400"><X size={13}/></button>
                            </div>
                          ):inv.plannedDate&&inv.plannedAmount>0?(
                            <button onClick={()=>{setEditPlan(inv.id);setPlanData({plannedDate:inv.plannedDate,plannedAmount:String(inv.plannedAmount)});}} className="text-xs text-sky-600 hover:underline">{fmtDate(inv.plannedDate)} — {fmt(inv.plannedAmount)}</button>
                          ):bal>0?(
                            <button onClick={()=>{setEditPlan(inv.id);setPlanData({plannedDate:"",plannedAmount:String(bal)});}} className="text-xs text-stone-400 hover:text-stone-600">+ Planear</button>
                          ):"—"}
                        </td>}
                        <td className="py-2 px-2 text-center"><Badge variant={Math.abs(bal)<=0.01?"success":bal<0?"success":overdue?"danger":"warning"}>{Math.abs(bal)<=0.01?"Liquidado":bal<0?"A nosso favor":overdue?"Vencido":"Pendente"}</Badge></td>
                        <td className="py-2 px-1">
                          {bal>0.01&&<Button size="xs" variant="ghost" onClick={()=>{setShowRegPayment({entityId:selEntity.id,invId:inv.id,bal,doc:inv.doc});setRegPayData({date:TODAY,amount:String(bal)});}} title="Registar pagamento"><Banknote size={12} className="text-emerald-600"/></Button>}
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
                <tfoot><tr className="border-t-2 border-stone-300 font-semibold">
                  <td className="py-2 px-2">Total</td>
                  <td className="py-2 px-2 text-right">{fmt(selEntity.invoices.reduce((s,i)=>s+i.amount,0))}</td>
                  <td></td>
                  <td className="py-2 px-2 text-right text-emerald-600">{fmt(selEntity.invoices.reduce((s,i)=>s+i.amount-getInvBalance(i),0))}</td>
                  <td className="py-2 px-2 text-right">
                    {(() => { const t=selEntity.invoices.reduce((s,i)=>s+getInvBalance(i),0); return t<0?<span className="text-emerald-600 font-bold">A nosso favor: {fmt(Math.abs(t))}</span>:<span className="text-red-600">{fmt(t)}</span>; })()}
                  </td>
                  {tab==="fornecedores"&&<td></td>}
                  <td></td><td></td>
                </tr></tfoot>
              </table>
            </div>
          ):(
            <div className="flex flex-col items-center justify-center h-full text-center">
              <FileText size={36} className="mb-3 text-stone-300"/><p className="text-sm text-stone-400">Selecione uma entidade</p>
            </div>
          )}
        </Card>
      </div>

      <Modal open={!!showRegPayment} onClose={()=>setShowRegPayment(null)} title="Registar Pagamento">
        {showRegPayment&&(
          <div className="space-y-4">
            <div className="p-3 bg-stone-50 rounded-lg">
              <p className="font-medium text-stone-800">{selEntity?.name}</p>
              <p className="text-sm text-stone-500">Doc: {showRegPayment.doc} · Saldo: <span className="font-semibold text-red-600">{fmt(showRegPayment.bal)}</span></p>
            </div>
            <div className="grid grid-cols-2 gap-3">
              <Input label="Data" type="date" value={regPayData.date} onChange={e=>setRegPayData({...regPayData,date:e.target.value})}/>
              <Input label="Valor €" type="number" value={regPayData.amount} onChange={e=>setRegPayData({...regPayData,amount:e.target.value})}/>
            </div>
            <div className="flex justify-end gap-2">
              <Button variant="outline" onClick={()=>setShowRegPayment(null)}>Cancelar</Button>
              <Button variant="success" onClick={registerCCPayment}><Check size={14}/>Registar</Button>
            </div>
          </div>
        )}
      </Modal>

      <Modal open={showAddInv} onClose={()=>setShowAddInv(false)} title={`Nova Fatura — ${selEntity?.name||""}`}>
        <div className="space-y-4">
          <div className="grid grid-cols-2 gap-3">
            <Input label="Nº Documento" value={newInv.doc} onChange={e=>setNewInv({...newInv,doc:e.target.value})}/>
            <Input label="Valor €" type="number" value={newInv.amount} onChange={e=>setNewInv({...newInv,amount:e.target.value})}/>
            <Input label="Vencimento" type="date" value={newInv.dueDate} onChange={e=>setNewInv({...newInv,dueDate:e.target.value})}/>
            {tab==="fornecedores"&&<Input label="Data prevista pagamento" type="date" value={newInv.plannedDate} onChange={e=>setNewInv({...newInv,plannedDate:e.target.value})}/>}
          </div>
          <div className="flex justify-end gap-2">
            <Button variant="outline" onClick={()=>setShowAddInv(false)}>Cancelar</Button>
            <Button onClick={addInvoice}>Adicionar</Button>
          </div>
        </div>
      </Modal>
    </div>
  );
};

// ==================== TASKS MODULE ====================
const TasksModule = ({
  tasks, setTasks, payables, setPayables,
  ccSuppliers, setCcSuppliers,
  bankAccounts, setBankAccounts,
  completedPayments, setCompletedPayments,
  categories
}) => {
  const [showNew, setShowNew] = useState(false);
  const [editingTask, setEditingTask] = useState(null);
  const [filter, setFilter] = useState("all");
  const [showComplete, setShowComplete] = useState(null);
  const emptyTask = { title:"", amount:"", assignee:"Kátia Mendes", priority:"média", dueDate:TODAY, method:"Transferência bancária", bank:"", notes:"", invoiceDoc:"", category:"" };
  const [newTask, setNewTask] = useState({...emptyTask});

  const activeBanks = bankAccounts.filter(b=>!b.archived);
  const allMethods = [...new Set(bankAccounts.flatMap(b=>b.paymentMethods)), "Transferência bancária"];

  const addTask = () => {
    if (!newTask.title) return;
    setTasks(prev=>[...prev,{...newTask,id:genId(),amount:parseFloat(newTask.amount)||0,status:"pendente"}]);
    setShowNew(false);
    setNewTask({...emptyTask});
  };

  const saveEditTask = () => {
    if (!editingTask||!editingTask.title) return;
    setTasks(prev=>prev.map(t=>t.id===editingTask.id?{...editingTask,amount:parseFloat(editingTask.amount)||0}:t));
    setEditingTask(null);
  };

  const updateStatus = (id,status) => {
    if (status==="concluido") {
      const task=tasks.find(t=>t.id===id);
      if (task&&task.amount>0) { setShowComplete({...task}); return; }
    }
    setTasks(prev=>prev.map(t=>t.id===id?{...t,status}:t));
  };

  // FIX: confirmComplete — properly update payables and bank balance
  const confirmComplete = (task) => {
    const completionDate=task.dueDate||TODAY;
    setTasks(prev=>prev.map(t=>t.id===task.id?{...t,status:"concluido",completedDate:completionDate}:t));

    // FIX: Update payables if linked
    if (task.amount>0&&task.payableId&&setPayables) {
      setPayables(prev=>prev.map(p=>p.id===task.payableId?{...p,partials:[...p.partials,{date:completionDate,amount:task.amount}]}:p));
    }

    // FIX: Update bank balance
    if (task.bank&&task.amount>0&&setBankAccounts) {
      setBankAccounts(prev=>prev.map(b=>b.id===task.bank?{...b,balance:b.balance-task.amount}:b));
    }

    // FIX: Add to completed payments so it shows in history
    if (task.amount>0&&setCompletedPayments) {
      setCompletedPayments(prev=>[...prev,{
        id:genId(), date:completionDate,
        supplier:task.title,
        doc:task.invoiceDoc||"",
        amount:task.amount,
        category:task.category||"fornecedor",
        method:task.method||"",
        bank:task.bank||""
      }]);
    }

    setShowComplete(null);
  };

  const filtered = useMemo(()=>{
    let f=tasks;
    if (filter==="pendente") f=f.filter(t=>t.status==="pendente");
    if (filter==="em_processamento") f=f.filter(t=>t.status==="em_processamento");
    if (filter==="concluido") f=f.filter(t=>t.status==="concluido");
    if (filter==="katia") f=f.filter(t=>t.assignee==="Kátia Mendes");
    if (filter==="marcio") f=f.filter(t=>t.assignee==="Márcio Monteiro");
    return f.sort((a,b)=>{const p={alta:0,média:1,baixa:2};if(a.status!==b.status){if(a.status==="concluido")return 1;if(b.status==="concluido")return -1;}return(p[a.priority]||1)-(p[b.priority]||1);});
  },[tasks,filter]);

  const statusLabel={pendente:"Pendente",em_processamento:"Em processamento",concluido:"Concluído"};
  const statusColor={pendente:"warning",em_processamento:"info",concluido:"success"};

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between">
        <div className="flex gap-2">
          {["all","pendente","em_processamento","concluido","katia","marcio"].map(f=>(
            <button key={f} onClick={()=>setFilter(f)} className={`px-3 py-1.5 rounded-lg text-xs font-medium transition-all ${filter===f?'bg-stone-800 text-white':'bg-stone-100 text-stone-600 hover:bg-stone-200'}`}>
              {f==="all"?"Todas":f==="katia"?"Kátia":f==="marcio"?"Márcio":statusLabel[f]||f}
            </button>
          ))}
        </div>
        <Button onClick={()=>setShowNew(true)}><Plus size={15}/>Nova Tarefa</Button>
      </div>

      <div className="space-y-2">
        {filtered.map(task=>(
          <Card key={task.id} className={`p-4 ${task.status==="concluido"?'opacity-50':''}`}>
            <div className="flex items-start gap-3">
              <div className="flex flex-col gap-1 mt-0.5">
                {task.status!=="concluido"&&(
                  <select value={task.status} onChange={e=>updateStatus(task.id,e.target.value)} className="text-[10px] px-1 py-0.5 rounded border border-stone-200 bg-white">
                    <option value="pendente">Pendente</option>
                    <option value="em_processamento">Em proc.</option>
                    <option value="concluido">Concluído</option>
                  </select>
                )}
                {task.status==="concluido"&&<CheckCircle size={18} className="text-emerald-500"/>}
              </div>
              <div className="flex-1 min-w-0">
                <div className="flex items-center justify-between gap-2">
                  <span className={`font-medium text-[13px] ${task.status==="concluido"?'line-through text-stone-400':'text-stone-900'}`}>{task.title}</span>
                  <div className="flex items-center gap-1.5 flex-shrink-0">
                    {task.amount>0&&<span className="text-sm font-semibold text-stone-700">{fmt(task.amount)}</span>}
                    <Badge variant={task.priority==="alta"?"danger":task.priority==="média"?"warning":"default"}>{task.priority}</Badge>
                    <Badge variant={statusColor[task.status]}>{statusLabel[task.status]}</Badge>
                    <Badge variant="info">{task.assignee?.split(" ")[0]}</Badge>
                  </div>
                </div>
                <div className="flex items-center gap-3 mt-1 text-[11px] text-stone-400">
                  {task.method&&<span>{task.method}</span>}
                  {task.bank&&<span>· {activeBanks.find(b=>b.id===task.bank)?.name||task.bank}</span>}
                  {task.dueDate&&<span>· {fmtDate(task.dueDate)}</span>}
                </div>
                {task.notes&&<p className="text-xs text-stone-500 mt-1.5 bg-stone-50 rounded px-2 py-1">{task.notes}</p>}
              </div>
              <div className="flex flex-col gap-1">
                {task.status!=="concluido"&&<button onClick={()=>setEditingTask({...task})} className="p-1 text-stone-300 hover:text-sky-500"><Edit3 size={14}/></button>}
                <button onClick={()=>setTasks(prev=>prev.filter(t=>t.id!==task.id))} className="p-1 text-stone-300 hover:text-red-500"><Trash2 size={14}/></button>
              </div>
            </div>
          </Card>
        ))}
        {filtered.length===0&&<div className="text-center py-12 text-stone-400 text-sm">Sem tarefas nesta categoria</div>}
      </div>

      <Modal open={showNew} onClose={()=>setShowNew(false)} title="Nova Tarefa">
        <div className="space-y-4">
          <Input label="Título" value={newTask.title} onChange={e=>setNewTask({...newTask,title:e.target.value})}/>
          <div className="grid grid-cols-3 gap-3">
            <Input label="Valor €" type="number" value={newTask.amount} onChange={e=>setNewTask({...newTask,amount:e.target.value})}/>
            <Select label="Atribuir a" value={newTask.assignee} onChange={e=>setNewTask({...newTask,assignee:e.target.value})}>
              <option>Kátia Mendes</option><option>Márcio Monteiro</option>
            </Select>
            <Select label="Prioridade" value={newTask.priority} onChange={e=>setNewTask({...newTask,priority:e.target.value})}>
              <option value="alta">Alta</option><option value="média">Média</option><option value="baixa">Baixa</option>
            </Select>
          </div>
          <div className="grid grid-cols-3 gap-3">
            <Input label="Prazo" type="date" value={newTask.dueDate} onChange={e=>setNewTask({...newTask,dueDate:e.target.value})}/>
            <Select label="Método" value={newTask.method} onChange={e=>setNewTask({...newTask,method:e.target.value})}>
              <option value="">N/A</option>
              {allMethods.map(m=><option key={m}>{m}</option>)}
            </Select>
            <Select label="Conta" value={newTask.bank} onChange={e=>setNewTask({...newTask,bank:e.target.value})}>
              <option value="">—</option>
              {activeBanks.map(b=><option key={b.id} value={b.id}>{b.name}</option>)}
            </Select>
          </div>
          <Select label="Categoria" value={newTask.category} onChange={e=>setNewTask({...newTask,category:e.target.value})}>
            <option value="">— Selecionar —</option>
            {Object.entries(categories||{}).map(([k,v])=><option key={k} value={k}>{v.label}</option>)}
          </Select>
          <Input label="Nº Fatura" value={newTask.invoiceDoc||""} onChange={e=>setNewTask({...newTask,invoiceDoc:e.target.value})}/>
          <div><label className="block text-[11px] font-medium text-stone-500 mb-1 uppercase tracking-wider">Observações</label><textarea className="w-full px-3 py-2 rounded-lg border border-stone-200 text-sm" rows={2} value={newTask.notes} onChange={e=>setNewTask({...newTask,notes:e.target.value})}/></div>
          <div className="flex justify-end gap-2"><Button variant="outline" onClick={()=>setShowNew(false)}>Cancelar</Button><Button onClick={addTask}>Criar</Button></div>
        </div>
      </Modal>

      <Modal open={!!editingTask} onClose={()=>setEditingTask(null)} title="Editar Tarefa">
        {editingTask&&(
          <div className="space-y-4">
            <Input label="Título" value={editingTask.title} onChange={e=>setEditingTask({...editingTask,title:e.target.value})}/>
            <div className="grid grid-cols-3 gap-3">
              <Input label="Valor €" type="number" value={editingTask.amount} onChange={e=>setEditingTask({...editingTask,amount:e.target.value})}/>
              <Select label="Atribuir a" value={editingTask.assignee} onChange={e=>setEditingTask({...editingTask,assignee:e.target.value})}>
                <option>Kátia Mendes</option><option>Márcio Monteiro</option>
              </Select>
              <Select label="Prioridade" value={editingTask.priority} onChange={e=>setEditingTask({...editingTask,priority:e.target.value})}>
                <option value="alta">Alta</option><option value="média">Média</option><option value="baixa">Baixa</option>
              </Select>
            </div>
            <div className="grid grid-cols-2 gap-3">
              <Select label="Método" value={editingTask.method||""} onChange={e=>setEditingTask({...editingTask,method:e.target.value})}>
                <option value="">N/A</option>
                {allMethods.map(m=><option key={m}>{m}</option>)}
              </Select>
              <Select label="Conta" value={editingTask.bank||""} onChange={e=>setEditingTask({...editingTask,bank:e.target.value})}>
                <option value="">—</option>
                {activeBanks.map(b=><option key={b.id} value={b.id}>{b.name}</option>)}
              </Select>
            </div>
            <div className="flex justify-end gap-2"><Button variant="outline" onClick={()=>setEditingTask(null)}>Cancelar</Button><Button onClick={saveEditTask}>Guardar</Button></div>
          </div>
        )}
      </Modal>

      <Modal open={!!showComplete} onClose={()=>setShowComplete(null)} title="Concluir Tarefa">
        {showComplete&&(
          <div className="space-y-4">
            <div className="p-3 bg-stone-50 rounded-lg">
              <p className="font-medium text-stone-800">{showComplete.title}</p>
              <p className="text-sm text-stone-500">{fmt(showComplete.amount)}</p>
            </div>
            <div className="grid grid-cols-2 gap-3">
              <Input label="Data" type="date" value={showComplete.dueDate} onChange={e=>setShowComplete({...showComplete,dueDate:e.target.value})}/>
              <Input label="Valor €" type="number" value={showComplete.amount} onChange={e=>setShowComplete({...showComplete,amount:parseFloat(e.target.value)||0})}/>
            </div>
            <Select label="Método de pagamento" value={showComplete.method||""} onChange={e=>setShowComplete({...showComplete,method:e.target.value})}>
              <option value="">N/A</option>
              {allMethods.map(m=><option key={m}>{m}</option>)}
            </Select>
            <Select label="Conta bancária debitada" value={showComplete.bank||""} onChange={e=>setShowComplete({...showComplete,bank:e.target.value})}>
              <option value="">— Não debitar —</option>
              {activeBanks.map(b=><option key={b.id} value={b.id}>{b.name} ({fmt(b.balance)})</option>)}
            </Select>
            <div className="flex justify-end gap-2">
              <Button variant="outline" onClick={()=>setShowComplete(null)}>Cancelar</Button>
              <Button variant="success" onClick={()=>confirmComplete(showComplete)}><Check size={14}/>Concluído</Button>
            </div>
          </div>
        )}
      </Modal>
    </div>
  );
};

// ==================== VENDAS MODULE ====================
const ANNUAL_SALES = [
  {year:2022,months:[30803.7,29443.6,30736.2,42222.9,56391.08,46730.7,58278.95,51195.4,46904.1,58577.42,45502.4,59943.37],total:556729.82},
  {year:2023,months:[90801.43,60317.41,63632.4,53053.27,49217.46,56792.53,77766.99,71165.89,76961.38,65658.5,67734.09,80635.98],total:813737.33},
  {year:2024,months:[60724.08,47914.42,64308.12,75516.91,76992.11,63800.08,88300.47,66731.31,56461.58,64932.52,50931.17,63975.17],total:780587.94},
  {year:2025,months:[63586.32,60093.32,59284.94,59904.43,63662.74,63164.32,77624.67,55333.24,59365.38,63810.71,59333.59,68160.98],total:753324.64},
  {year:2026,months:[65238.3,43729.55,0,0,0,0,0,0,0,0,0,0],total:108967.85},
];
const MONTH_NAMES = ["Jan","Fev","Mar","Abr","Mai","Jun","Jul","Ago","Set","Out","Nov","Dez"];
const MONTH_NAMES_FULL = ["Janeiro","Fevereiro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"];

const VendasModule = ({ dailySales, setDailySales, bankAccounts, setBankAccounts, completedPayments, setCompletedPayments, payables, setPayables, categories, setCategories }) => {
  const [subTab, setSubTab] = useState("resumo");
  const [showCardAlloc, setShowCardAlloc] = useState(null); // {date, totalCards}
  const [cardAllocData, setCardAllocData] = useState([]); // [{bankId, gross, net, commission}]
  const [showPaymentMethodManager, setShowPaymentMethodManager] = useState(false);

  const activeBanks = bankAccounts.filter(b=>!b.archived);
  const allPayMethods = [...new Set(bankAccounts.flatMap(b=>b.paymentMethods))];

  const monthTotal = dailySales.reduce((s,d)=>s+d.loja+d.dist+d.site,0);
  const monthLoja = dailySales.reduce((s,d)=>s+d.loja,0);
  const monthDist = dailySales.reduce((s,d)=>s+d.dist,0);
  const monthSite = dailySales.reduce((s,d)=>s+d.site,0);

  // FIX: Process non-card payments — routes each method to its linked bank account
  const processDayClose = (day) => {
    const d = dailySales.find(x => x.date === day);
    if (!d) return;
    
    // Map method name → field in dailySales record
    const methodFields = {
      "Dinheiro": d.dinheiro || 0,
      "Ref MB": d.refMB || 0,
      "MB Way": d.mbway || 0,
      "PayPal": d.paypal || 0,
      "Visa Onl.": d.visaOnline || 0,
      "TB": d.tb || 0,
    };
    
    setBankAccounts(prev => {
      let updated = [...prev];
      Object.entries(methodFields).forEach(([method, amt]) => {
        if (!amt || amt <= 0) return;
        // Find the bank account that has this payment method
        const bankIdx = updated.findIndex(b => !b.archived && b.paymentMethods.includes(method));
        if (bankIdx >= 0) {
          updated = updated.map((b, i) => i === bankIdx ? {...b, balance: b.balance + amt} : b);
        }
      });
      return updated;
    });
    
    // Cards are handled separately via the card allocation modal
  };

  // FIX: Handle card allocation with TPA commission — updates bank balances AND creates TPA commission payable
  const processCardAllocation = () => {
    if (!showCardAlloc || cardAllocData.length === 0) return;
    
    let totalComm = 0;
    
    setBankAccounts(prev => {
      let updated = [...prev];
      cardAllocData.forEach(alloc => {
        if (!alloc.bankId || alloc.gross <= 0) return;
        const bank = updated.find(b => b.id === alloc.bankId);
        if (!bank) return;
        const commission = alloc.gross * (bank.tpaRate || 0) / 100;
        const net = alloc.gross - commission;
        totalComm += commission;
        updated = updated.map(b => b.id === alloc.bankId ? {...b, balance: b.balance + net} : b);
      });
      return updated;
    });
    
    // FIX: Add TPA commissions as payable entry
    if (totalComm > 0.01 && setPayables) {
      setPayables(prev => [...prev, {
        id: genId(),
        supplier: "Comissões TPA",
        doc: `TPA ${showCardAlloc.date || TODAY}`,
        amount: totalComm,
        dueDate: TODAY,
        category: "comissoesTPA",
        bank: "",
        method: "Transferência bancária",
        pinned: false,
        partials: [{date: TODAY, amount: totalComm}], // Auto-mark as paid (already deducted)
        ccLink: false
      }]);
    }
    
    setShowCardAlloc(null);
    setCardAllocData([]);
  };

  const initCardAlloc = (totalCards, date) => {
    const banksWithTPA = activeBanks.filter(b => b.tpaRate > 0);
    setCardAllocData(banksWithTPA.map(b => ({ bankId: b.id, name: b.name, gross: 0, tpaRate: b.tpaRate })));
    setShowCardAlloc({ totalCards, date });
  };

  return (
    <div className="space-y-5">
      <div className="flex gap-2 border-b border-stone-200 pb-3">
        {[{id:"resumo",label:"Resumo"},{id:"diario",label:"Fecho Diário"},{id:"tabela",label:"Comparativa"}].map(t=>(
          <button key={t.id} onClick={()=>setSubTab(t.id)} className={`text-sm font-medium pb-1 border-b-2 transition-all ${subTab===t.id?'border-stone-800 text-stone-900':'border-transparent text-stone-400'}`}>{t.label}</button>
        ))}
      </div>

      {subTab==="resumo"&&(
        <div className="space-y-5">
          <div className="grid grid-cols-4 gap-4">
            <Card className="p-4"><p className="text-[11px] text-stone-400 uppercase font-medium">Total Março</p><p className="text-xl font-bold text-stone-900 mt-1">{fmt(monthTotal)}</p></Card>
            <Card className="p-4"><p className="text-[11px] text-stone-400 uppercase font-medium">Loja</p><p className="text-xl font-bold text-blue-600 mt-1">{fmt(monthLoja)}</p></Card>
            <Card className="p-4"><p className="text-[11px] text-stone-400 uppercase font-medium">Site</p><p className="text-xl font-bold text-emerald-600 mt-1">{fmt(monthSite)}</p></Card>
            <Card className="p-4"><p className="text-[11px] text-stone-400 uppercase font-medium">Distribuição</p><p className="text-xl font-bold text-orange-600 mt-1">{fmt(monthDist)}</p></Card>
          </div>
          <Card className="p-5">
            <div className="flex items-center justify-between mb-4">
              <h4 className="font-semibold text-stone-900">Distribuição por Canal</h4>
              <Button size="sm" variant="outline" onClick={()=>{
                // FIX: Monthly report email — Relatório mensal - sócios
                // Columns are aligned using fixed-width formatting (monospace)
                const col = (v, w=12) => String(v).padStart(w);
                const colL = (v, w=18) => String(v).padEnd(w);
                const months = ["Jan","Fev","Mar","Abr","Mai","Jun","Jul","Ago","Set","Out","Nov","Dez"];
                
                // Build comparativo table with aligned columns (monospaced)
                let table = `${colL('Ano',6)}`;
                months.forEach(m => table += col(m));
                table += col('Total',14) + '\n';
                table += '-'.repeat(6 + months.length*12 + 14) + '\n';
                
                ANNUAL_SALES.slice(-5).forEach(yr => {
                  table += colL(String(yr.year), 6);
                  yr.months.forEach(v => table += col(v>0?Math.round(v).toLocaleString('pt-PT'):'—'));
                  table += col(Math.round(yr.total).toLocaleString('pt-PT'), 14);
                  table += '\n';
                });
                
                const txt = `Bom dia,\n\nSegue o relatório de vendas de Março 2026:\n\n` +
                  `RESUMO MARÇO 2026\n${'─'.repeat(40)}\n` +
                  `Total geral:    ${fmt(monthTotal)}\n` +
                  `Loja:           ${fmt(monthLoja)}\n` +
                  `Site:           ${fmt(monthSite)}\n` +
                  `Distribuição:   ${fmt(monthDist)}\n\n` +
                  `Vendas Site registadas como adiantamento: ${fmt(monthSite)}\n\n` +
                  `COMPARATIVO MENSAL — 2026 vs últimos 4 anos\n${'─'.repeat(40)}\n` +
                  `(valores em €, arredondados)\n\n` +
                  `\`\`\`\n${table}\`\`\`\n\n` +
                  `Com os melhores cumprimentos,\nMárcio Monteiro\nYupik Outdoor, Lda.`;
                  
                window.open(`https://mail.google.com/mail/?view=cm&fs=1&su=${encodeURIComponent('Yupik Outdoor — Relatório Mensal Março 2026')}&body=${encodeURIComponent(txt)}`,'_blank');
              }}>
                <Mail size={13}/>Relatório mensal — sócios
              </Button>
            </div>
            <ResponsiveContainer width="100%" height={200}>
              <BarChart data={[{name:'Loja',value:monthLoja},{name:'Site',value:monthSite},{name:'Distribuição',value:monthDist}]}>
                <CartesianGrid strokeDasharray="3 3" stroke="#e7e5e4"/>
                <XAxis dataKey="name" tick={{fontSize:11}}/><YAxis tick={{fontSize:10}}/>
                <Bar dataKey="value" fill="#2563eb" radius={[6,6,0,0]}>
                  {[monthLoja,monthSite,monthDist].map((v,i)=><Cell key={i} fill={['#2563eb','#059669','#d97706'][i]}/>)}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </Card>
          
          {/* Daily sales email */}
          <Card className="p-4 border border-stone-100">
            <div className="flex items-center justify-between mb-3">
              <h4 className="font-semibold text-stone-800 text-[13px]">Vendas do dia — equipa</h4>
              <Button size="sm" variant="outline" onClick={()=>{
                const lastDay = dailySales[dailySales.length-1];
                if (!lastDay) return;
                const total = lastDay.loja + lastDay.site + lastDay.dist;
                const txt = `Bom dia equipa,\n\nVendas de ${fmtDateFull(lastDay.date)}:\n\n` +
                  `Total: ${fmt(total)}\n` +
                  `Loja: ${fmt(lastDay.loja)}\n` +
                  `Site: ${fmt(lastDay.site)}\n` +
                  `Distribuição: ${fmt(lastDay.dist)}\n\n` +
                  `— Cartões: ${fmt(lastDay.cartoes)}\n` +
                  `— Dinheiro: ${fmt(lastDay.dinheiro)}\n` +
                  `— Ref MB: ${fmt(lastDay.refMB)}\n` +
                  `— MB Way: ${fmt(lastDay.mbway||0)}\n` +
                  `— PayPal: ${fmt(lastDay.paypal)}\n` +
                  `— Visa Onl.: ${fmt(lastDay.visaOnline)}\n\n` +
                  `Vendas Site registadas como adiantamento: ${fmt(lastDay.site)}\n\n` +
                  `Bom trabalho!\nYupik Outdoor`;
                window.open(`https://mail.google.com/mail/?view=cm&fs=1&su=${encodeURIComponent(`Vendas do dia ${fmtDateFull(lastDay.date)}`)}&body=${encodeURIComponent(txt)}`,'_blank');
              }}>
                <Mail size={13}/>Vendas do dia — equipa
              </Button>
            </div>
            <div className="grid grid-cols-2 gap-4 text-sm">
              <div className="space-y-1">
                <p className="text-[11px] text-stone-400 font-medium uppercase">Por canal</p>
                <div className="flex justify-between"><span className="text-stone-600">Loja:</span><span className="font-semibold">{fmt(monthLoja)}</span></div>
                <div className="flex justify-between"><span className="text-stone-600">Site:</span><span className="font-semibold text-emerald-600">{fmt(monthSite)}</span></div>
                <div className="flex justify-between"><span className="text-stone-400">Distribuição:</span><span className="text-stone-400">{fmt(monthDist)}</span></div>
              </div>
              <div className="space-y-1">
                <p className="text-[11px] text-stone-400 font-medium uppercase">Nota</p>
                <p className="text-xs text-stone-500">Distribuição NÃO incluída no cálculo de comissões.</p>
                <p className="text-xs text-stone-500">Vendas Site registadas como adiantamento até liquidação.</p>
              </div>
            </div>
          </Card>
        </div>
      )}

      {subTab==="diario"&&(
        <div className="space-y-5">
          <div className="flex items-center justify-between">
            <h4 className="font-semibold text-stone-900">Vendas Diárias — Março 2026</h4>
            <div className="flex gap-2">
              <Button size="sm" variant="outline" onClick={()=>setShowPaymentMethodManager(true)}><Settings size={13}/>Métodos</Button>
            </div>
          </div>
          <Card className="overflow-x-auto">
            <table className="w-full text-sm whitespace-nowrap">
              <thead><tr className="bg-stone-50 border-b border-stone-200">
                <th className="text-left py-2 px-3 text-[11px] text-stone-500 font-medium">Data</th>
                <th className="text-right py-2 px-2 text-[11px] text-stone-500 font-medium">Loja</th>
                <th className="text-right py-2 px-2 text-[11px] text-stone-500 font-medium">Site</th>
                <th className="text-right py-2 px-2 text-[11px] text-stone-500 font-medium">Distrib.</th>
                <th className="text-right py-2 px-2 text-[11px] text-stone-500 font-medium">Total</th>
                <th className="text-right py-2 px-2 text-[11px] text-stone-500 font-medium">Cartões</th>
                <th className="text-right py-2 px-2 text-[11px] text-stone-500 font-medium">Dinheiro</th>
                <th className="text-right py-2 px-2 text-[11px] text-stone-500 font-medium">Ref MB</th>
                <th className="text-right py-2 px-2 text-[11px] text-stone-500 font-medium">PayPal</th>
                <th className="text-right py-2 px-2 text-[11px] text-stone-500 font-medium">Visa Onl.</th>
                <th className="text-right py-2 px-2 text-[11px] text-stone-500 font-medium">TB</th>
                <th className="text-right py-2 px-2 text-[11px] text-stone-500 font-medium">MB Way</th>
                <th className="text-right py-2 px-2 text-[11px] text-stone-500 font-medium">Vales Reg.</th>
                <th className="text-center py-2 px-2 text-[11px] text-stone-500 font-medium">Fecho</th>
              </tr></thead>
              <tbody>
                {dailySales.map(d=>(
                  <tr key={d.date} className="border-b border-stone-100 hover:bg-stone-50">
                    <td className="py-2 px-3 font-medium">{fmtDate(d.date)}</td>
                    <td className="py-2 px-2 text-right">{fmt(d.loja)}</td>
                    <td className="py-2 px-2 text-right text-emerald-600">{d.site>0?fmt(d.site):"—"}</td>
                    <td className="py-2 px-2 text-right text-stone-400">{d.dist>0?fmt(d.dist):"—"}</td>
                    <td className="py-2 px-2 text-right font-semibold">{fmt(d.loja+d.site+d.dist)}</td>
                    <td className="py-2 px-2 text-right text-xs">
                      <span className="cursor-pointer hover:text-blue-600 underline" onClick={() => initCardAlloc(d.cartoes, d.date)} title="Distribuir por conta bancária">{fmt(d.cartoes)}</span>
                    </td>
                    <td className="py-2 px-2 text-right text-xs">{d.dinheiro>0?fmt(d.dinheiro):"—"}</td>
                    <td className="py-2 px-2 text-right text-xs">{d.refMB>0?fmt(d.refMB):"—"}</td>
                    <td className="py-2 px-2 text-right text-xs">{d.paypal>0?fmt(d.paypal):"—"}</td>
                    <td className="py-2 px-2 text-right text-xs">{d.visaOnline>0?fmt(d.visaOnline):"—"}</td>
                    <td className="py-2 px-2 text-right text-xs">{d.tb>0?fmt(d.tb):"—"}</td>
                    <td className="py-2 px-2 text-right text-xs">{d.mbway>0?fmt(d.mbway):"—"}</td>
                    <td className="py-2 px-2 text-right text-xs">{d.valesReg>0?fmt(d.valesReg):"—"}</td>
                    <td className="py-2 px-1 text-center">
                      <Button size="xs" variant="ghost" onClick={() => processDayClose(d.date)} title="Processar fecho — soma saldos bancários">
                        <Check size={11} className="text-emerald-600"/>
                      </Button>
                    </td>
                  </tr>
                ))}
              </tbody>
              <tfoot><tr className="bg-stone-50 border-t-2 border-stone-200 font-semibold">
                <td className="py-2 px-3">Acumulado</td>
                <td className="py-2 px-2 text-right">{fmt(monthLoja)}</td>
                <td className="py-2 px-2 text-right text-emerald-600">{fmt(monthSite)}</td>
                <td className="py-2 px-2 text-right">{fmt(monthDist)}</td>
                <td className="py-2 px-2 text-right">{fmt(monthTotal)}</td>
                <td className="py-2 px-2 text-right text-xs">{fmt(dailySales.reduce((s,d)=>s+d.cartoes,0))}</td>
                <td className="py-2 px-2 text-right text-xs">{fmt(dailySales.reduce((s,d)=>s+d.dinheiro,0))}</td>
                <td className="py-2 px-2 text-right text-xs">{fmt(dailySales.reduce((s,d)=>s+d.refMB,0))}</td>
                <td className="py-2 px-2 text-right text-xs">{fmt(dailySales.reduce((s,d)=>s+d.paypal,0))}</td>
                <td className="py-2 px-2 text-right text-xs">{fmt(dailySales.reduce((s,d)=>s+d.visaOnline,0))}</td>
                <td className="py-2 px-2 text-right text-xs">{fmt(dailySales.reduce((s,d)=>s+(d.tb||0),0))}</td>
                <td className="py-2 px-2 text-right text-xs">{fmt(dailySales.reduce((s,d)=>s+(d.mbway||0),0))}</td>
                <td className="py-2 px-2 text-right text-xs">{fmt(dailySales.reduce((s,d)=>s+(d.valesReg||0),0))}</td>
                <td></td>
              </tr></tfoot>
            </table>
          </Card>
          <Card className="p-4 bg-blue-50/30 border-blue-100">
            <p className="text-xs text-blue-800 font-medium">💡 Instruções do fecho diário:</p>
            <ul className="text-xs text-blue-700 mt-1 space-y-0.5 list-disc pl-4">
              <li>Clique no valor de <strong>Cartões</strong> para distribuir por conta bancária (Abanca/BPI) com cálculo automático de comissão TPA</li>
              <li>Clique no ✓ na coluna <strong>Fecho</strong> para processar os restantes métodos de pagamento — somam automaticamente às contas configuradas</li>
              <li>Métodos configurados: Dinheiro→Numerário, Ref MB/Visa Onl./MB Way→HiPay, PayPal→PayPal</li>
            </ul>
          </Card>
        </div>
      )}

      {subTab==="tabela"&&(
        <Card className="p-5">
          <h4 className="font-semibold text-stone-900 mb-4">Comparativo Anual</h4>
          <div className="overflow-x-auto">
            <table className="text-xs w-full">
              <thead><tr className="border-b border-stone-200">
                <th className="text-left py-2 px-2 font-medium text-stone-500">Ano</th>
                {MONTH_NAMES.map(m=><th key={m} className="text-right py-2 px-2 font-medium text-stone-500">{m}</th>)}
                <th className="text-right py-2 px-2 font-medium text-stone-500">Total</th>
              </tr></thead>
              <tbody>
                {ANNUAL_SALES.map(yr=>(
                  <tr key={yr.year} className={`border-b border-stone-100 ${yr.year===2026?'bg-blue-50/30 font-semibold':''}`}>
                    <td className="py-1.5 px-2 font-semibold">{yr.year}</td>
                    {yr.months.map((v,i)=><td key={i} className="py-1.5 px-2 text-right">{v>0?fmt(v):"—"}</td>)}
                    <td className="py-1.5 px-2 text-right font-bold">{fmt(yr.total)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </Card>
      )}

      {/* Card Allocation Modal */}
      <Modal open={!!showCardAlloc} onClose={()=>setShowCardAlloc(null)} title="Distribuição de Cartões por Conta">
        {showCardAlloc&&(
          <div className="space-y-4">
            <div className="p-3 bg-stone-50 rounded-lg">
              <p className="text-sm font-medium">Total Cartões: <span className="text-blue-600 font-bold">{fmt(showCardAlloc.totalCards)}</span></p>
              <p className="text-xs text-stone-500 mt-1">Distribua o valor pelos terminais bancários. A comissão TPA é calculada automaticamente.</p>
            </div>
            <div className="space-y-3">
              {activeBanks.filter(b=>b.tpaRate>0).map(bank=>{
                const alloc = cardAllocData.find(a=>a.bankId===bank.id)||{gross:0};
                const commission = (alloc.gross*(bank.tpaRate||0)/100);
                const net = alloc.gross - commission;
                return(
                  <div key={bank.id} className="p-3 border border-stone-200 rounded-lg">
                    <div className="flex items-center justify-between mb-2">
                      <p className="font-medium text-sm">{bank.name} <span className="text-[11px] text-stone-400">(TPA: {bank.tpaRate}%)</span></p>
                    </div>
                    <div className="grid grid-cols-3 gap-2 text-xs">
                      <div>
                        <label className="block text-stone-500 mb-1">Valor bruto (TPA)</label>
                        <input type="number" className="w-full px-2 py-1.5 rounded border border-stone-200 text-sm"
                          value={alloc.gross||""}
                          onChange={e=>{
                            const gross=parseFloat(e.target.value)||0;
                            setCardAllocData(prev=>{
                              const exists=prev.find(a=>a.bankId===bank.id);
                              if (exists) return prev.map(a=>a.bankId===bank.id?{...a,gross}:a);
                              return [...prev,{bankId:bank.id,name:bank.name,gross,tpaRate:bank.tpaRate}];
                            });
                          }}/>
                      </div>
                      <div><label className="block text-stone-500 mb-1">Comissão TPA</label><div className="px-2 py-1.5 bg-red-50 rounded border border-red-100 text-red-600 font-semibold">{fmt(commission)}</div></div>
                      <div><label className="block text-stone-500 mb-1">Líquido (entra na conta)</label><div className="px-2 py-1.5 bg-emerald-50 rounded border border-emerald-100 text-emerald-600 font-semibold">{fmt(net)}</div></div>
                    </div>
                  </div>
                );
              })}
            </div>
            <div className="p-3 bg-amber-50 rounded-lg border border-amber-100 text-xs">
              <p className="font-medium text-amber-800">Comissões TPA</p>
              <p className="text-amber-700 mt-0.5">As diferenças entre valor bruto e líquido serão registadas como "Comissões TPA" nos pagamentos.</p>
              <p className="font-semibold mt-1">Total comissões: {fmt(cardAllocData.reduce((s,a)=>{const b=activeBanks.find(x=>x.id===a.bankId);return s+(a.gross*(b?.tpaRate||0)/100);},0))}</p>
            </div>
            <div className="flex justify-end gap-2">
              <Button variant="outline" onClick={()=>setShowCardAlloc(null)}>Cancelar</Button>
              <Button onClick={processCardAllocation}>Processar e Atualizar Saldos</Button>
            </div>
          </div>
        )}
      </Modal>
    </div>
  );
};

// ==================== COMISSÕES MODULE ====================
const ComissoesModule = ({ dailySales, commissionRules, setCommissionRules }) => {
  const [showEdit, setShowEdit] = useState(false);
  const [editRules, setEditRules] = useState(null);

  const TIERS = (commissionRules?.tiers||[]).map((t,i,arr)=>({
    name:t.label, rate:t.rate,
    min: i===0?0:(arr[i-1].threshold+0.01),
    max: t.threshold===Infinity?Infinity:t.threshold
  }));

  const employees = (commissionRules?.employees||[]).map(e=>({
    name:e.fullName, salary:e.baseSalary,
    alimentacao:(e.alimentDays||0)*(e.alimentRate||0),
    abono:e.abono||0, tsu:e.tsu||0.11, irs:e.irs||0.0378
  }));

  const monthLoja = dailySales.reduce((s,d)=>s+d.loja,0);
  const monthSite = dailySales.reduce((s,d)=>s+d.site,0);
  const baseValue = (monthLoja+monthSite)/1.23;

  const getTier = (val) => TIERS.find(t=>val>=t.min&&(t.max===Infinity||val<=t.max))||TIERS[0];
  const tier = getTier(baseValue);

  return (
    <div className="space-y-5">
      <Card className="p-5 bg-gradient-to-r from-violet-50 to-violet-100/50 border-violet-200">
        <div className="flex items-center justify-between mb-4">
          <div>
            <h3 className="font-semibold text-violet-900 text-lg">Comissões — Março 2026</h3>
            <p className="text-xs text-violet-700 mt-0.5">Período: 26 Fevereiro → 25 Março 2026</p>
          </div>
          <Button variant="outline" size="sm" onClick={()=>{setEditRules(JSON.parse(JSON.stringify(commissionRules)));setShowEdit(true);}}>
            <Settings size={13}/>Editar Regras
          </Button>
        </div>

        {/* Tiers */}
        <div className="bg-white rounded-lg p-4 border border-violet-100 mb-4">
          <p className="text-xs font-semibold text-stone-600 uppercase mb-3">Estrutura de Comissões</p>
          <div className="grid grid-cols-3 gap-3">
            {TIERS.map(t=>(
              <div key={t.name} className={`p-3 rounded-lg border-2 ${tier&&t.name===tier.name?'border-violet-400 bg-violet-50':'border-stone-200 bg-stone-50'}`}>
                <p className="font-medium text-stone-800 text-xs">{t.name}</p>
                <p className="text-2xl font-bold text-violet-700 mt-1">{(t.rate*100).toFixed(1)}%</p>
                {tier&&t.name===tier.name&&<p className="text-[10px] text-violet-600 mt-1 font-semibold">← Nível atual</p>}
              </div>
            ))}
          </div>
        </div>

        {/* Sales base */}
        <div className="bg-white rounded-lg p-4 border border-violet-100 mb-4">
          <p className="text-xs font-semibold text-stone-600 uppercase mb-3">Base de Cálculo (s/IVA)</p>
          <div className="space-y-1.5 text-sm">
            <div className="flex justify-between"><span className="text-stone-600">Loja:</span><span className="font-semibold">{fmt(monthLoja)}</span></div>
            <div className="flex justify-between"><span className="text-stone-600">Site:</span><span className="font-semibold text-emerald-600">{fmt(monthSite)}</span></div>
            <div className="flex justify-between border-t pt-1.5 mt-1.5"><span className="font-semibold">Total s/IVA:</span><span className="font-bold text-violet-700">{fmt(baseValue)}</span></div>
            <div className="flex justify-between"><span className="text-stone-500 text-xs">Tier aplicável:</span><span className="text-xs font-semibold text-violet-600">{tier?.name} ({((tier?.rate||0)*100).toFixed(1)}%)</span></div>
          </div>
        </div>

        {/* Per employee */}
        <div className="bg-white rounded-lg p-4 border border-violet-100 mb-4">
          <p className="text-xs font-semibold text-stone-600 uppercase mb-3">Cálculo por Colaborador</p>
          <div className="overflow-x-auto">
            <table className="w-full text-xs">
              <thead><tr className="border-b border-stone-200">
                <th className="text-left py-1.5 px-2 font-medium text-stone-500">Colaborador</th>
                <th className="text-right py-1.5 px-2 font-medium text-stone-500">Comissão</th>
                <th className="text-right py-1.5 px-2 font-medium text-stone-500">Alimentação</th>
                <th className="text-right py-1.5 px-2 font-medium text-stone-500">Abono</th>
                <th className="text-right py-1.5 px-2 font-medium text-stone-500">Bruto</th>
                <th className="text-right py-1.5 px-2 font-medium text-stone-500">TSU</th>
                <th className="text-right py-1.5 px-2 font-medium text-stone-500">IRS</th>
                <th className="text-right py-1.5 px-2 font-medium text-stone-500">Líquido</th>
              </tr></thead>
              <tbody>
                {employees.map(emp=>{
                  const comm = baseValue * (tier?.rate||0);
                  const bruto = comm + emp.alimentacao + emp.abono;
                  const tsuDed = bruto * emp.tsu;
                  const irsDed = bruto * emp.irs;
                  const liquido = bruto - tsuDed - irsDed;
                  return(
                    <tr key={emp.name} className="border-b border-stone-100">
                      <td className="py-1.5 px-2 font-medium">{emp.name}</td>
                      <td className="py-1.5 px-2 text-right">{fmt(comm)}</td>
                      <td className="py-1.5 px-2 text-right">{fmt(emp.alimentacao)}</td>
                      <td className="py-1.5 px-2 text-right">{fmt(emp.abono)}</td>
                      <td className="py-1.5 px-2 text-right font-semibold">{fmt(bruto)}</td>
                      <td className="py-1.5 px-2 text-right text-red-600">-{fmt(tsuDed)}</td>
                      <td className="py-1.5 px-2 text-right text-red-600">-{fmt(irsDed)}</td>
                      <td className="py-1.5 px-2 text-right font-bold text-emerald-700">{fmt(liquido)}</td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </div>

        {/* Print table */}
        <div className="bg-white rounded-lg p-4 border-2 border-dashed border-violet-200">
          <div className="flex items-center justify-between mb-3">
            <p className="text-xs font-semibold text-stone-600 uppercase">Quadro para Afixar</p>
            <Button size="xs" variant="outline" onClick={()=>window.print()}>🖨️ Imprimir</Button>
          </div>
          <div className="space-y-2 text-xs">
            <p className="font-bold text-center text-stone-800 text-sm">COMISSÕES — Março 2026</p>
            <p className="text-center text-stone-500">Base: {fmt(baseValue)} s/IVA · Tier: {tier?.name} ({((tier?.rate||0)*100).toFixed(1)}%)</p>
            <table className="w-full border border-stone-200 mt-2">
              <thead><tr className="bg-stone-100"><th className="text-left p-2 border">Colaborador</th><th className="text-right p-2 border">Comissão Bruta</th><th className="text-right p-2 border">Dedução (TSU+IRS)</th><th className="text-right p-2 border">Líquido</th></tr></thead>
              <tbody>{employees.map(emp=>{
                const comm=baseValue*(tier?.rate||0);
                const bruto=comm+emp.alimentacao+emp.abono;
                const ded=bruto*(emp.tsu+emp.irs);
                const liq=bruto-ded;
                return(<tr key={emp.name} className="border-b"><td className="p-2 border">{emp.name}</td><td className="p-2 text-right border">{fmt(bruto)}</td><td className="p-2 text-right border text-red-600">-{fmt(ded)}</td><td className="p-2 text-right border font-bold text-emerald-700">{fmt(liq)}</td></tr>);
              })}</tbody>
            </table>
            <p className="text-[10px] text-stone-400 mt-2">{commissionRules?.notes}</p>
          </div>
        </div>
      </Card>

      {/* Edit Rules Modal */}
      <Modal open={showEdit} onClose={()=>setShowEdit(false)} title="Editar Regras de Comissão" wide>
        {editRules&&(
          <div className="space-y-4">
            <div>
              <p className="text-[11px] font-medium text-stone-500 uppercase mb-2">Tiers de Comissão</p>
              {editRules.tiers.map((t,i)=>(
                <div key={i} className="grid grid-cols-3 gap-2 mb-2">
                  <Input label="Descrição" value={t.label} onChange={e=>{const tr=[...editRules.tiers];tr[i]={...tr[i],label:e.target.value};setEditRules({...editRules,tiers:tr});}}/>
                  <Input label="Limite superior €" type="number" value={t.threshold===Infinity?"":t.threshold} onChange={e=>{const tr=[...editRules.tiers];tr[i]={...tr[i],threshold:e.target.value?parseFloat(e.target.value):Infinity};setEditRules({...editRules,tiers:tr});}}/>
                  <Input label="Taxa %" type="number" value={(t.rate*100).toFixed(1)} onChange={e=>{const tr=[...editRules.tiers];tr[i]={...tr[i],rate:parseFloat(e.target.value)/100||0};setEditRules({...editRules,tiers:tr});}}/>
                </div>
              ))}
            </div>
            <div>
              <p className="text-[11px] font-medium text-stone-500 uppercase mb-2">Notas / Regras</p>
              <textarea className="w-full px-3 py-2 rounded-lg border border-stone-200 text-sm" rows={3} value={editRules.notes||""} onChange={e=>setEditRules({...editRules,notes:e.target.value})}/>
            </div>
            <div className="flex justify-end gap-2">
              <Button variant="outline" onClick={()=>setShowEdit(false)}>Cancelar</Button>
              <Button onClick={()=>{setCommissionRules(editRules);setShowEdit(false);}}>Guardar Regras</Button>
            </div>
          </div>
        )}
      </Modal>
    </div>
  );
};

// ==================== COFRE MODULE ====================
const CofreModule = ({ cofre, setCofre, bankAccounts, setBankAccounts, dailySales }) => {
  const [showNewEntry, setShowNewEntry] = useState(false);
  const [entryType, setEntryType] = useState("entrada");
  const [newEntry, setNewEntry] = useState({ date:TODAY, amount:"", category:"vendas", description:"" });
  const [showDeposit, setShowDeposit] = useState(false);
  const [depositBank, setDepositBank] = useState("");
  const [depositAmount, setDepositAmount] = useState("");

  const FIXED_FUND = cofre?.fundoCaixa || 290;
  const entries = cofre?.movimentos || [];

  const totalEntradas = entries.filter(e=>e.type==="entrada").reduce((s,e)=>s+e.amount,0);
  const totalSaidas = entries.filter(e=>e.type==="saida").reduce((s,e)=>s+e.amount,0);
  const saldoAnterior = cofre?.saldoAnterior || 0;
  const saldoAtual = FIXED_FUND + saldoAnterior + totalEntradas - totalSaidas;
  const disponivelParaDeposito = Math.max(0, saldoAtual - FIXED_FUND);

  const addEntry = () => {
    const amt = parseFloat(newEntry.amount);
    if (!amt||amt<=0) return;
    setCofre(prev=>({
      ...prev,
      movimentos:[...(prev.movimentos||[]),{id:genId(),date:newEntry.date,type:entryType,amount:amt,category:newEntry.category,description:newEntry.description}]
    }));
    setShowNewEntry(false);
    setNewEntry({date:TODAY,amount:"",category:"vendas",description:""});
  };

  const processDeposit = () => {
    const amt = parseFloat(depositAmount);
    if (!amt||amt<=0||!depositBank) return;
    setCofre(prev=>({
      ...prev,
      movimentos:[...(prev.movimentos||[]),{id:genId(),date:TODAY,type:"saida",amount:amt,category:"deposito",description:`Depósito → ${bankAccounts.find(b=>b.id===depositBank)?.name||depositBank}`}]
    }));
    setBankAccounts(prev=>prev.map(b=>b.id===depositBank?{...b,balance:b.balance+amt}:b));
    setShowDeposit(false);
    setDepositBank("");
    setDepositAmount("");
  };

  const activeBanks = bankAccounts.filter(b=>!b.archived);

  return (
    <div className="space-y-5">
      <div className="grid grid-cols-4 gap-4">
        <Card className="p-4 bg-stone-50">
          <p className="text-[11px] text-stone-400 uppercase font-medium">Fundo Fixo Caixa</p>
          <p className="text-xl font-bold text-stone-900 mt-1">{fmt(FIXED_FUND)}</p>
          <p className="text-[10px] text-stone-400 mt-0.5">Permanente (120+120+50€)</p>
        </Card>
        <Card className="p-4 bg-stone-50">
          <p className="text-[11px] text-stone-400 uppercase font-medium">Saldo Anterior</p>
          <p className="text-xl font-bold text-stone-900 mt-1">{fmt(saldoAnterior)}</p>
        </Card>
        <Card className="p-4 bg-emerald-50">
          <p className="text-[11px] text-emerald-600 uppercase font-medium">Saldo Atual Cofre</p>
          <p className="text-xl font-bold text-emerald-700 mt-1">{fmt(saldoAtual)}</p>
          <p className="text-[10px] text-emerald-600 mt-0.5">Entradas: {fmt(totalEntradas)} · Saídas: {fmt(totalSaidas)}</p>
        </Card>
        <Card className="p-4 bg-blue-50">
          <p className="text-[11px] text-blue-600 uppercase font-medium">Disponível Depósito</p>
          <p className="text-xl font-bold text-blue-700 mt-1">{fmt(disponivelParaDeposito)}</p>
          <p className="text-[10px] text-blue-500 mt-0.5">Acima do fundo fixo</p>
        </Card>
      </div>

      <Card className="p-5">
        <div className="flex items-center justify-between mb-4">
          <h4 className="font-semibold text-stone-900">Movimentos Numerário</h4>
          <div className="flex gap-2">
            <Button size="sm" variant="outline" onClick={()=>setShowDeposit(true)}><ArrowDownRight size={13}/>Depositar</Button>
            <Button size="sm" onClick={()=>setShowNewEntry(true)}><Plus size={13}/>Movimento</Button>
          </div>
        </div>

        {entries.length===0?(
          <div className="text-center py-8 text-stone-400"><Banknote size={32} className="mx-auto mb-2 opacity-30"/><p className="text-sm">Sem movimentos registados</p></div>
        ):(
          <div className="overflow-auto max-h-[400px]">
            <table className="w-full text-xs">
              <thead><tr className="border-b border-stone-200 sticky top-0 bg-white">
                <th className="text-left py-2 px-2">Data</th>
                <th className="text-center py-2 px-2">Tipo</th>
                <th className="text-left py-2 px-2">Categoria</th>
                <th className="text-right py-2 px-2">Valor</th>
                <th className="text-right py-2 px-2">Saldo</th>
                <th className="text-left py-2 px-2">Descrição</th>
                <th className="w-8"></th>
              </tr></thead>
              <tbody>
                {(() => {
                  let running = FIXED_FUND + saldoAnterior;
                  return entries.slice().sort((a,b)=>new Date(a.date)-new Date(b.date)).map(e=>{
                    running += e.type==="entrada" ? e.amount : -e.amount;
                    return(
                      <tr key={e.id} className="border-b border-stone-100 hover:bg-stone-50">
                        <td className="py-1.5 px-2">{fmtDate(e.date)}</td>
                        <td className="py-1.5 px-2 text-center"><Badge variant={e.type==="entrada"?"success":"warning"}>{e.type==="entrada"?"Entrada":"Saída"}</Badge></td>
                        <td className="py-1.5 px-2 text-stone-600">{e.category}</td>
                        <td className="py-1.5 px-2 text-right font-semibold">{e.type==="entrada"?"+":"-"}{fmt(e.amount)}</td>
                        <td className="py-1.5 px-2 text-right text-stone-500">{fmt(running)}</td>
                        <td className="py-1.5 px-2 text-stone-500">{e.description}</td>
                        <td className="py-1.5 px-2"><button onClick={()=>setCofre(prev=>({...prev,movimentos:prev.movimentos.filter(x=>x.id!==e.id)}))} className="text-stone-300 hover:text-red-500"><X size={11}/></button></td>
                      </tr>
                    );
                  });
                })()}
              </tbody>
            </table>
          </div>
        )}
      </Card>

      <Modal open={showNewEntry} onClose={()=>setShowNewEntry(false)} title="Novo Movimento Numerário">
        <div className="space-y-4">
          <Select label="Tipo" value={entryType} onChange={e=>setEntryType(e.target.value)}>
            <option value="entrada">Entrada</option>
            <option value="saida">Saída</option>
          </Select>
          <div className="grid grid-cols-2 gap-3">
            <Input label="Data" type="date" value={newEntry.date} onChange={e=>setNewEntry({...newEntry,date:e.target.value})}/>
            <Input label="Valor €" type="number" value={newEntry.amount} onChange={e=>setNewEntry({...newEntry,amount:e.target.value})}/>
          </div>
          <Select label="Categoria" value={newEntry.category} onChange={e=>setNewEntry({...newEntry,category:e.target.value})}>
            <option value="vendas">Vendas</option>
            <option value="deposito">Depósito</option>
            <option value="refeicao">Refeição colaboradores</option>
            <option value="compra">Compra</option>
            <option value="troco">Troco</option>
            <option value="outro">Outro</option>
          </Select>
          <Input label="Descrição" value={newEntry.description} onChange={e=>setNewEntry({...newEntry,description:e.target.value})} placeholder="Descrição do movimento"/>
          <div className="flex justify-end gap-2">
            <Button variant="outline" onClick={()=>setShowNewEntry(false)}>Cancelar</Button>
            <Button onClick={addEntry}>Registar</Button>
          </div>
        </div>
      </Modal>

      <Modal open={showDeposit} onClose={()=>setShowDeposit(false)} title="Depositar em Conta Bancária">
        <div className="space-y-4">
          <div className="p-3 bg-blue-50 rounded-lg">
            <p className="text-sm text-blue-800">Disponível para depositar: <span className="font-bold">{fmt(disponivelParaDeposito)}</span></p>
          </div>
          <Select label="Conta bancária de destino" value={depositBank} onChange={e=>setDepositBank(e.target.value)}>
            <option value="">— Selecionar conta —</option>
            {activeBanks.map(b=><option key={b.id} value={b.id}>{b.name} (saldo atual: {fmt(b.balance)})</option>)}
          </Select>
          <Input label="Valor a depositar €" type="number" value={depositAmount} onChange={e=>setDepositAmount(e.target.value)} max={disponivelParaDeposito}/>
          <div className="flex justify-end gap-2">
            <Button variant="outline" onClick={()=>setShowDeposit(false)}>Cancelar</Button>
            <Button onClick={processDeposit} disabled={!depositBank||!depositAmount}><ArrowDownRight size={14}/>Depositar</Button>
          </div>
        </div>
      </Modal>
    </div>
  );
};

// ==================== LOGIN ====================
const LoginScreen = ({ onLogin }) => {
  const [email, setEmail] = useState("marcio.monteiro@yupik.com.pt");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");

  const handleLogin = () => {
    const users = {
      "marcio.monteiro@yupik.com.pt": { name:"Márcio Monteiro", role:"ADMIN" },
      "k.mendes@yupik.com.pt": { name:"Kátia Mendes", role:"ASSISTANT" },
      "c.subtil@yupik.com.pt": { name:"Carlos Subtil", role:"PARTNER" },
    };
    if (!email||!password) { setError("Preencha email e password"); return; }
    const user = users[email.toLowerCase()];
    if (!user) { setError("Email não reconhecido"); return; }
    onLogin({...user,email});
  };

  return (
    <div className="min-h-screen flex items-center justify-center" style={{background:'linear-gradient(160deg, #fafaf9 0%, #f5f5f4 40%, #ece9e4 100%)', fontFamily:"'Outfit', system-ui, sans-serif", minHeight:'100vh', display:'flex', alignItems:'center', justifyContent:'center'}}>
      <style>{`@import url('https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap');`}</style>
      <div className="bg-white rounded-2xl shadow-xl border border-stone-200 p-8 w-full max-w-sm">
        <div className="text-center mb-6">
          <div className="w-12 h-12 rounded-xl bg-stone-900 flex items-center justify-center mx-auto mb-3"><Wallet size={20} className="text-white"/></div>
          <h1 className="text-lg font-bold text-stone-900">Yupik Outdoor</h1>
          <p className="text-xs text-stone-400 uppercase tracking-[0.15em] font-medium">Sistema de Gestão</p>
        </div>
        <div className="space-y-3">
          <Input label="Email" type="email" value={email} onChange={e=>setEmail(e.target.value)}/>
          <Input label="Palavra-passe" type="password" value={password} onChange={e=>setPassword(e.target.value)}/>
          {error&&<p className="text-xs text-red-600">{error}</p>}
          <button onClick={handleLogin} className="w-full py-2.5 bg-stone-800 text-white rounded-lg text-sm font-medium hover:bg-stone-700 transition-colors">Entrar</button>
        </div>
        <p className="text-[10px] text-stone-400 text-center mt-4">Demo — qualquer password funciona</p>
      </div>
    </div>
  );
};

// ==================== MAIN APP ====================
function MainApp({ user, onLogout }) {
  const [tab, setTab] = useState("pagamentos");
  const [payables, setPayables] = useState(INIT_PAYABLES);
  const [ccSuppliers, setCcSuppliers] = useState(INIT_CC_SUPPLIERS);
  const [ccClients, setCcClients] = useState(INIT_CC_CLIENTS);
  const [tasks, setTasks] = useState([
    {id:1,title:"Processar pagamento Unit Legal",amount:851.78,assignee:"Kátia Mendes",priority:"alta",status:"pendente",dueDate:"2026-03-10",method:"Transferência bancária",bank:"bpi",notes:"FT 2026A1/40 — vencido desde 10.02",payableId:21,category:"servicos"},
    {id:2,title:"Processar pagamento AR Telecom",amount:190.80,assignee:"Kátia Mendes",priority:"alta",status:"em_processamento",dueDate:"2026-03-08",method:"Transferência bancária",bank:"abanca",notes:"F26_001853 — vencido desde 03.03",payableId:8,category:"telecom"},
    {id:3,title:"Enviar plano pagamentos Redicom",amount:0,assignee:"Kátia Mendes",priority:"média",status:"pendente",dueDate:"2026-03-12",method:"",bank:"",notes:"Copiar plano de CC e enviar por email",payableId:null,category:""},
    {id:4,title:"Verificar recebimento Escala25",amount:162.28,assignee:"Kátia Mendes",priority:"baixa",status:"pendente",dueDate:"2026-03-15",method:"",bank:"",notes:"FT 2026A1/58 — verificar se cliente pagou",payableId:null,category:""},
  ]);
  const [bankAccounts, setBankAccounts] = useState(INIT_BANK_ACCOUNTS);
  const [confirmingPays, setConfirmingPays] = useState([
    {id:1,supplier:"Scarpa",doc:"2023FE02027",amount:2733.44,payDate:"2026-02-13",debitDate:"2026-06-13",bank:"abanca",status:"processado",notes:"",linkedTo:null,linkedFrom:null,debits:[]},
    {id:2,supplier:"Equip UK",doc:"SI2512-07363",amount:2636.94,payDate:"2026-02-16",debitDate:"2026-06-16",bank:"abanca",status:"processado",notes:"",linkedTo:null,linkedFrom:null,debits:[]},
    {id:3,supplier:"Boreal",doc:"001-53925",amount:1591.85,payDate:"2026-02-23",debitDate:"2026-06-23",bank:"abanca",status:"processado",notes:"",linkedTo:null,linkedFrom:null,debits:[]},
    {id:4,supplier:"YY Vertical",doc:"CO",amount:700,payDate:"2026-02-25",debitDate:"2026-06-25",bank:"abanca",status:"processado",notes:"",linkedTo:null,linkedFrom:null,debits:[]},
    {id:5,supplier:"Dicaltex",doc:"BG/2485",amount:439.82,payDate:"2026-01-13",debitDate:"2026-03-10",bank:"bpi",status:"processado",notes:"",linkedTo:null,linkedFrom:null,debits:[]},
  ]);
  const [completedPayments, setCompletedPayments] = useState([]);
  const [dailySales, setDailySales] = useState([
    {date:"2026-03-02",loja:1280.50,dist:0,site:0,cartoes:980.50,dinheiro:290,mbway:0,paypal:0,visaOnline:10,refMB:0,tb:0,bitcoin:0,valesReg:0},
    {date:"2026-03-03",loja:890.20,dist:215,site:45.90,cartoes:650.20,dinheiro:69.70,mbway:0,paypal:0,visaOnline:0,refMB:385.30,tb:0,bitcoin:0,valesReg:0},
    {date:"2026-03-04",loja:1450.80,dist:0,site:128.50,cartoes:1100.80,dinheiro:60,mbway:0,paypal:0,visaOnline:290,refMB:0,tb:0,bitcoin:0,valesReg:0},
    {date:"2026-03-05",loja:780.00,dist:0,site:0,cartoes:690,dinheiro:90,mbway:0,paypal:0,visaOnline:0,refMB:0,tb:0,bitcoin:0,valesReg:0},
    {date:"2026-03-06",loja:950.30,dist:0,site:65.00,cartoes:860.30,dinheiro:90,mbway:0,paypal:0,visaOnline:0,refMB:0,tb:0,bitcoin:0,valesReg:0},
    {date:"2026-03-07",loja:1512.50,dist:0,site:189.95,cartoes:1600.95,dinheiro:0.60,mbway:0,paypal:65,visaOnline:89.95,refMB:355,tb:0,bitcoin:0,valesReg:0},
  ]);
  const [commissionRules, setCommissionRules] = useState(INIT_COMMISSION_RULES);
  const [cofre, setCofre] = useState(INIT_COFRE);
  const [categories, setCategories] = useState(DEFAULT_CATEGORIES);

  const tabs = [
    {id:"pagamentos",label:"Pagamentos",icon:CreditCard},
    {id:"confirming",label:"Confirming",icon:Building2},
    {id:"cc",label:"Contas Corrente",icon:FileText},
    {id:"vendas",label:"Vendas",icon:BarChart3},
    {id:"comissoes",label:"Comissões",icon:Users},
    {id:"cofre",label:"Cofre",icon:Banknote},
    {id:"tarefas",label:"Tarefas",icon:Send},
  ];

  const totalBal = bankAccounts.filter(a=>!a.archived).reduce((s,a)=>s+(a.balance||0),0);
  const getBalance = (p) => p.amount - p.partials.reduce((s,pp)=>s+pp.amount,0);
  const totalPayables = payables.reduce((s,p)=>s+getBalance(p),0);
  const pendingTasks = tasks.filter(t=>t.status!=="concluido").length;

  return (
    <div className="min-h-screen" style={{background:'linear-gradient(160deg, #fafaf9 0%, #f5f5f4 40%, #ece9e4 100%)', fontFamily:"'Outfit', system-ui, sans-serif", minHeight:'100vh'}}>
      <style>{`@import url('https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap');`}</style>

      <header className="bg-white/70 border-b border-stone-200/80 sticky top-0 z-40" style={{backdropFilter:'blur(16px)'}}>
        <div className="max-w-[1400px] mx-auto px-6">
          <div className="flex items-center justify-between h-14">
            <div className="flex items-center gap-3">
              <div className="w-8 h-8 rounded-lg bg-stone-900 flex items-center justify-center"><Wallet size={15} className="text-white"/></div>
              <div>
                <h1 className="text-sm font-bold text-stone-900 leading-tight">Yupik Outdoor</h1>
                <p className="text-[10px] text-stone-400 uppercase tracking-[0.15em] font-medium">Gestão de Tesouraria</p>
              </div>
            </div>
            <div className="flex items-center gap-4">
              <div className="flex items-center gap-6 text-xs text-stone-500">
                <span>Saldo total: <strong className="text-stone-800">{fmt(totalBal)}</strong></span>
                <span>Pendente: <strong className="text-red-600">{fmt(totalPayables)}</strong></span>
                <span>Tarefas: <strong className="text-sky-600">{pendingTasks}</strong></span>
              </div>
              <button onClick={onLogout} className="text-xs text-stone-500 hover:text-stone-700">{user.name} · Sair</button>
            </div>
          </div>
          <div className="flex gap-0.5 -mb-px overflow-x-auto">
            {tabs.map(t=>(
              <button key={t.id} onClick={()=>setTab(t.id)} className={`flex items-center gap-1.5 px-4 py-2.5 text-[13px] font-medium border-b-2 transition-all whitespace-nowrap ${tab===t.id?'border-stone-800 text-stone-900':'border-transparent text-stone-400 hover:text-stone-600'}`}>
                <t.icon size={15}/>{t.label}
              </button>
            ))}
          </div>
        </div>
      </header>

      <main className="max-w-[1400px] mx-auto px-6 py-6">
        {tab==="pagamentos"&&<PaymentsModule payables={payables} setPayables={setPayables} tasks={tasks} setTasks={setTasks} ccSuppliers={ccSuppliers} setCcSuppliers={setCcSuppliers} bankAccounts={bankAccounts} setBankAccounts={setBankAccounts} completedPayments={completedPayments} setCompletedPayments={setCompletedPayments} categories={categories} setCategories={setCategories}/>}
        {tab==="confirming"&&<ConfirmingModule pays={confirmingPays} setPays={setConfirmingPays} payables={payables} setPayables={setPayables} ccSuppliers={ccSuppliers} setCcSuppliers={setCcSuppliers} ccClients={ccClients} bankAccounts={bankAccounts} setBankAccounts={setBankAccounts} completedPayments={completedPayments} setCompletedPayments={setCompletedPayments} categories={categories}/>}
        {tab==="cc"&&<ContasCorrenteModule ccSuppliers={ccSuppliers} setCcSuppliers={setCcSuppliers} ccClients={ccClients} setCcClients={setCcClients} payables={payables} setPayables={setPayables}/>}
        {tab==="vendas"&&<VendasModule dailySales={dailySales} setDailySales={setDailySales} bankAccounts={bankAccounts} setBankAccounts={setBankAccounts} completedPayments={completedPayments} setCompletedPayments={setCompletedPayments} payables={payables} setPayables={setPayables} categories={categories} setCategories={setCategories}/>}
        {tab==="comissoes"&&<ComissoesModule dailySales={dailySales} commissionRules={commissionRules} setCommissionRules={setCommissionRules}/>}
        {tab==="cofre"&&<CofreModule cofre={cofre} setCofre={setCofre} bankAccounts={bankAccounts} setBankAccounts={setBankAccounts} dailySales={dailySales}/>}
        {tab==="tarefas"&&<TasksModule tasks={tasks} setTasks={setTasks} payables={payables} setPayables={setPayables} ccSuppliers={ccSuppliers} setCcSuppliers={setCcSuppliers} bankAccounts={bankAccounts} setBankAccounts={setBankAccounts} completedPayments={completedPayments} setCompletedPayments={setCompletedPayments} categories={categories}/>}
      </main>

      <footer className="text-center py-4">
        <p className="text-[10px] text-stone-400">Yupik Outdoor, Lda. · Sistema de Gestão v2.1 · {new Date().toLocaleDateString('pt-PT')}</p>
      </footer>
    </div>
  );
}

export default function YupikApp() {
  const [user, setUser] = useState(null);
  if (!user) return <LoginScreen onLogin={setUser}/>;
  return <MainApp user={user} onLogout={()=>setUser(null)}/>;
}

```
