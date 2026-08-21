import type { CSSProperties } from "react";
import type { Translation } from "../i18n";

/* ════════════════════════════════════════════════════════════════════
   DESIGN TOKENS
   ════════════════════════════════════════════════════════════════════ */
export const G = {
  bg: "rgba(255,255,255,0.06)",
  bgHov: "rgba(255,255,255,0.10)",
  border: "rgba(255,255,255,0.20)",
  borderHov: "rgba(255,255,255,0.40)",
  shadow:
    "0 10px 40px rgba(0,0,0,0.50), inset 0 1px 0 rgba(255,255,255,0.15), inset 0 -1px 0 rgba(0,0,0,0.20)",
  shadowHov:
    "0 20px 60px rgba(0,0,0,0.60), inset 0 1px 0 rgba(255,255,255,0.25), inset 0 -1px 0 rgba(0,0,0,0.20)",
  radius: 20,
  textPrimary: "rgba(255,255,255,0.92)",
  textSecondary: "rgba(255,255,255,0.60)",
  textMuted: "rgba(255,255,255,0.30)",
  overlay: "rgba(0,0,0,0.50)",
};

export function glassBase(blur = 24): CSSProperties {
  return {
    background: G.bg,
    backdropFilter: `blur(${blur}px)`,
    WebkitBackdropFilter: `blur(${blur}px)`,
    border: `1px solid ${G.border}`,
    boxShadow: G.shadow,
    borderRadius: G.radius,
  };
}

/* ════════════════════════════════════════════════════════════════════
   THEMES (12 total)
   ════════════════════════════════════════════════════════════════════ */
export type ThemeId =
  | "sunset"
  | "ice"
  | "mono"
  | "cyber"
  | "aurora"
  | "rose"
  | "cosmos"
  | "forest"
  | "obsidian"
  | "graphite"
  | "midnight"
  | "espresso";

export type Theme = {
  id: ThemeId;
  nameKey: keyof Translation;
  emoji: string;
  bg: string;
  orbs: { color: string; size: number; top: string; left: string }[];
  accents: string[];
};

export const THEMES: Theme[] = [
  {
    id: "sunset",
    nameKey: "themeSunset",
    emoji: "🌅",
    bg: "linear-gradient(145deg,#130500 0%,#2E0C00 28%,#4A1400 52%,#6B1E00 75%,#8A2800 100%)",
    orbs: [
      { color: "rgba(255,110,20,0.22)", size: 680, top: "-18%", left: "-10%" },
      { color: "rgba(200,50,0,0.16)", size: 520, top: "38%", left: "58%" },
      { color: "rgba(255,160,30,0.10)", size: 400, top: "72%", left: "5%" },
      { color: "rgba(180,40,0,0.09)", size: 280, top: "12%", left: "72%" },
    ],
    accents: [
      "rgba(255,150,50,0.09)",
      "rgba(255,90,30,0.08)",
      "rgba(240,190,60,0.07)",
      "rgba(210,70,10,0.08)",
    ],
  },
  {
    id: "ice",
    nameKey: "themeIce",
    emoji: "🧊",
    bg: "linear-gradient(145deg,#00080F 0%,#001525 30%,#002440 58%,#003658 80%,#004870 100%)",
    orbs: [
      { color: "rgba(0,180,230,0.18)", size: 620, top: "-12%", left: "-8%" },
      { color: "rgba(0,120,190,0.14)", size: 500, top: "40%", left: "62%" },
      { color: "rgba(60,210,220,0.09)", size: 380, top: "68%", left: "4%" },
      { color: "rgba(100,180,255,0.08)", size: 260, top: "15%", left: "70%" },
    ],
    accents: [
      "rgba(40,200,255,0.08)",
      "rgba(0,180,200,0.08)",
      "rgba(80,170,255,0.07)",
      "rgba(0,150,210,0.08)",
    ],
  },
  {
    id: "mono",
    nameKey: "themeMono",
    emoji: "🪨",
    bg: "linear-gradient(150deg,#0E0E10 0%,#141416 35%,#1A1A1C 65%,#111113 100%)",
    orbs: [
      { color: "rgba(200,200,220,0.07)", size: 700, top: "-15%", left: "-8%" },
      { color: "rgba(160,160,190,0.05)", size: 520, top: "42%", left: "60%" },
      { color: "rgba(100,110,180,0.04)", size: 360, top: "70%", left: "5%" },
    ],
    accents: [
      "rgba(220,220,240,0.07)",
      "rgba(150,160,255,0.06)",
      "rgba(255,150,200,0.05)",
      "rgba(190,190,210,0.06)",
    ],
  },
  {
    id: "cyber",
    nameKey: "themeCyber",
    emoji: "🌺",
    bg: "linear-gradient(140deg,#001212 0%,#002828 30%,#004040 55%,#003535 70%,#380A20 100%)",
    orbs: [
      { color: "rgba(0,220,200,0.20)", size: 600, top: "-12%", left: "-7%" },
      { color: "rgba(200,30,90,0.18)", size: 540, top: "38%", left: "58%" },
      { color: "rgba(0,180,170,0.10)", size: 380, top: "72%", left: "5%" },
      { color: "rgba(160,20,80,0.09)", size: 280, top: "10%", left: "70%" },
    ],
    accents: [
      "rgba(0,230,210,0.08)",
      "rgba(210,40,110,0.08)",
      "rgba(0,200,190,0.07)",
      "rgba(180,30,100,0.07)",
    ],
  },
  {
    id: "aurora",
    nameKey: "themeAurora",
    emoji: "🌌",
    bg: "linear-gradient(155deg,#010806 0%,#031A0E 28%,#051828 55%,#090B22 80%,#06041A 100%)",
    orbs: [
      { color: "rgba(0,240,120,0.18)", size: 660, top: "-16%", left: "-9%" },
      { color: "rgba(60,30,230,0.20)", size: 560, top: "36%", left: "56%" },
      { color: "rgba(0,190,170,0.11)", size: 400, top: "70%", left: "3%" },
      { color: "rgba(120,0,255,0.09)", size: 320, top: "8%", left: "68%" },
      { color: "rgba(0,255,160,0.07)", size: 240, top: "55%", left: "20%" },
    ],
    accents: [
      "rgba(0,255,130,0.07)",
      "rgba(80,50,255,0.07)",
      "rgba(0,210,180,0.07)",
      "rgba(100,255,190,0.06)",
    ],
  },
  {
    id: "rose",
    nameKey: "themeRose",
    emoji: "🥀",
    bg: "linear-gradient(145deg,#0A0005 0%,#180008 32%,#260010 60%,#180018 82%,#0E000C 100%)",
    orbs: [
      { color: "rgba(230,0,80,0.22)", size: 620, top: "-14%", left: "-8%" },
      { color: "rgba(150,0,200,0.17)", size: 520, top: "38%", left: "60%" },
      { color: "rgba(255,60,120,0.10)", size: 380, top: "68%", left: "4%" },
      { color: "rgba(120,0,180,0.08)", size: 300, top: "15%", left: "70%" },
    ],
    accents: [
      "rgba(255,50,110,0.08)",
      "rgba(210,0,150,0.08)",
      "rgba(190,0,255,0.07)",
      "rgba(255,100,170,0.07)",
    ],
  },
  {
    id: "cosmos",
    nameKey: "themeCosmos",
    emoji: "🔭",
    bg: "linear-gradient(148deg,#020008 0%,#08001E 32%,#110030 60%,#08001A 82%,#030010 100%)",
    orbs: [
      { color: "rgba(110,0,255,0.20)", size: 640, top: "-15%", left: "-8%" },
      { color: "rgba(60,0,210,0.16)", size: 520, top: "40%", left: "58%" },
      { color: "rgba(180,60,255,0.09)", size: 380, top: "72%", left: "6%" },
      { color: "rgba(255,120,255,0.06)", size: 280, top: "18%", left: "72%" },
      { color: "rgba(80,0,200,0.06)", size: 220, top: "50%", left: "28%" },
    ],
    accents: [
      "rgba(130,50,255,0.08)",
      "rgba(190,70,255,0.07)",
      "rgba(255,130,255,0.06)",
      "rgba(90,0,210,0.08)",
    ],
  },
  {
    id: "forest",
    nameKey: "themeForest",
    emoji: "🌲",
    bg: "linear-gradient(145deg,#010602 0%,#030E05 30%,#061808 58%,#081E0A 80%,#040C06 100%)",
    orbs: [
      { color: "rgba(0,190,55,0.17)", size: 620, top: "-13%", left: "-7%" },
      { color: "rgba(0,130,35,0.13)", size: 500, top: "40%", left: "62%" },
      { color: "rgba(40,210,70,0.08)", size: 380, top: "70%", left: "5%" },
      { color: "rgba(160,255,80,0.06)", size: 260, top: "14%", left: "68%" },
    ],
    accents: [
      "rgba(0,210,75,0.07)",
      "rgba(50,190,60,0.07)",
      "rgba(130,255,70,0.06)",
      "rgba(0,150,55,0.07)",
    ],
  },
  {
    id: "obsidian",
    nameKey: "themeObsidian",
    emoji: "🪬",
    bg: "linear-gradient(158deg,#08080C 0%,#0C0C12 35%,#090B10 65%,#07070A 100%)",
    orbs: [
      { color: "rgba(40,60,140,0.22)", size: 800, top: "-25%", left: "-15%" },
      { color: "rgba(20,40,100,0.16)", size: 620, top: "45%", left: "50%" },
      { color: "rgba(60,80,160,0.10)", size: 420, top: "75%", left: "-5%" },
      { color: "rgba(0,30,80,0.12)", size: 300, top: "5%", left: "65%" },
    ],
    accents: [
      "rgba(60,80,200,0.06)",
      "rgba(40,60,180,0.06)",
      "rgba(80,100,220,0.05)",
      "rgba(30,50,160,0.06)",
    ],
  },
  {
    id: "graphite",
    nameKey: "themeGraphite",
    emoji: "🩶",
    bg: "linear-gradient(152deg,#111113 0%,#161618 38%,#191919 62%,#111112 100%)",
    orbs: [
      { color: "rgba(180,185,210,0.10)", size: 750, top: "-20%", left: "-12%" },
      { color: "rgba(140,145,175,0.07)", size: 560, top: "42%", left: "52%" },
      { color: "rgba(100,105,150,0.05)", size: 380, top: "70%", left: "-4%" },
      { color: "rgba(200,195,220,0.04)", size: 280, top: "10%", left: "68%" },
    ],
    accents: [
      "rgba(210,215,235,0.06)",
      "rgba(160,165,200,0.06)",
      "rgba(130,135,185,0.05)",
      "rgba(185,190,215,0.05)",
    ],
  },
  {
    id: "midnight",
    nameKey: "themeMidnight",
    emoji: "🌑",
    bg: "linear-gradient(148deg,#040610 0%,#080C1C 32%,#0C1028 60%,#070A1A 82%,#040610 100%)",
    orbs: [
      { color: "rgba(30,50,160,0.25)", size: 720, top: "-20%", left: "-12%" },
      { color: "rgba(20,35,120,0.18)", size: 560, top: "42%", left: "54%" },
      { color: "rgba(50,70,190,0.10)", size: 400, top: "72%", left: "4%" },
      { color: "rgba(15,25,100,0.12)", size: 300, top: "8%", left: "66%" },
    ],
    accents: [
      "rgba(80,110,255,0.07)",
      "rgba(60,90,230,0.07)",
      "rgba(50,80,210,0.06)",
      "rgba(100,130,255,0.06)",
    ],
  },
  {
    id: "espresso",
    nameKey: "themeEspresso",
    emoji: "☕",
    bg: "linear-gradient(150deg,#0E0804 0%,#160C05 32%,#1C1008 60%,#140B06 82%,#0D0703 100%)",
    orbs: [
      { color: "rgba(160,80,10,0.22)", size: 700, top: "-18%", left: "-10%" },
      { color: "rgba(120,55,5,0.16)", size: 540, top: "42%", left: "54%" },
      { color: "rgba(200,120,20,0.08)", size: 380, top: "70%", left: "4%" },
      { color: "rgba(100,45,0,0.10)", size: 280, top: "10%", left: "68%" },
    ],
    accents: [
      "rgba(210,150,60,0.07)",
      "rgba(190,115,35,0.07)",
      "rgba(230,170,80,0.06)",
      "rgba(170,95,25,0.06)",
    ],
  },
];

/* ════════════════════════════════════════════════════════════════════
   GLOBAL CSS
   ════════════════════════════════════════════════════════════════════ */
export function buildCSS(): string {
  return `
  *,*::before,*::after{box-sizing:border-box;}

  .card{
    border-radius:${G.radius}px;
    transform-origin:center center;
    backface-visibility:hidden;-webkit-backface-visibility:hidden;
    will-change:transform;cursor:pointer;
    transition:transform 0.32s cubic-bezier(0.34,1.56,0.64,1),box-shadow 0.28s ease;
  }
  .card:hover{transform:translateY(-6px) scale(1.02);}
  .card:focus-visible{outline:2px solid rgba(255,255,255,0.55);outline-offset:3px;}

  .card-glass{
    border-radius:${G.radius}px;overflow:hidden;position:relative;
    background:${G.bg};backdrop-filter:blur(24px);-webkit-backdrop-filter:blur(24px);
    border:1px solid ${G.border};box-shadow:${G.shadow};
    transition:box-shadow 0.28s ease,border-color 0.28s ease,background 0.28s ease;
  }
  .card:hover .card-glass{background:${G.bgHov};border-color:${G.borderHov};box-shadow:${G.shadowHov};}

  .glass-ring{
    position:absolute;inset:0;border-radius:inherit;pointer-events:none;z-index:10;padding:1px;
    background:linear-gradient(160deg,rgba(255,255,255,0.35) 0%,rgba(255,255,255,0.08) 40%,rgba(255,255,255,0.02) 100%);
    -webkit-mask:linear-gradient(#fff 0 0) content-box,linear-gradient(#fff 0 0);
    -webkit-mask-composite:xor;mask-composite:exclude;transition:background 0.28s;
  }
  .card:hover .glass-ring{background:linear-gradient(160deg,rgba(255,255,255,0.60) 0%,rgba(255,255,255,0.14) 45%,rgba(255,255,255,0.02) 100%);}
  .glass-sheen{
    position:absolute;inset:0;border-radius:inherit;pointer-events:none;z-index:9;
    background:linear-gradient(45deg,rgba(255,255,255,0.06) 0%,transparent 50%,rgba(255,255,255,0.03) 100%);
    opacity:0.6;transition:opacity 0.28s;
  }
  .card:hover .glass-sheen{opacity:1;}
  .card-accent{position:absolute;inset:0;border-radius:inherit;pointer-events:none;z-index:8;transition:filter 0.28s;}
  .card:hover .card-accent{filter:brightness(1.6);}

  .card-actions{opacity:0;transition:opacity 0.20s;}
  .card:hover .card-actions{opacity:1;}
  .actions-always{opacity:1!important;}

  /* Pin button: ALWAYS visible (fixes mobile pin issue) */
  .card-pin{opacity:1;transform:scale(1);transition:opacity 0.20s,transform 0.20s,background 0.20s;}
  .card-pin:hover{background:rgba(255,255,255,0.10);border-radius:6px;}
  .card-pin.pinned{color:rgba(255,255,255,0.90);}

  input[type="datetime-local"]{color-scheme:dark;}
  input[type="datetime-local"]:focus{border-color:rgba(255,200,60,0.55)!important;outline:none;}

  @keyframes slideUp{from{transform:translateY(100%);}to{transform:translateY(0);}}
  .sheet-in{animation:slideUp 0.28s cubic-bezier(0.32,0.72,0,1) both;}

  @keyframes bellRing{
    0%,100%{transform:rotate(0);}
    15%{transform:rotate(14deg);}
    30%{transform:rotate(-10deg);}
    45%{transform:rotate(8deg);}
    60%{transform:rotate(-5deg);}
    75%{transform:rotate(3deg);}
  }
  .bell-active{animation:bellRing 0.7s ease both;}

  .masonry{columns:var(--cols,3);column-gap:16px;}
  .masonry .card{break-inside:avoid;margin-bottom:16px;display:block;}
  .masonry .card:hover{transform:translateY(-4px) scale(1.01);}

  .scroll-host{scrollbar-width:thin;scrollbar-color:rgba(255,255,255,0.10) transparent;}
  .scroll-host::-webkit-scrollbar{width:4px;}
  .scroll-host::-webkit-scrollbar-thumb{background:rgba(255,255,255,0.10);border-radius:4px;}

  .search-bar:focus-within{
    border-color:rgba(255,255,255,0.40)!important;
    box-shadow:0 12px 40px rgba(0,0,0,0.55),inset 0 1px 0 rgba(255,255,255,0.22)!important;
  }

  @keyframes modalIn{from{opacity:0;transform:translateY(22px) scale(0.97);}to{opacity:1;transform:none;}}
  .modal-in{animation:modalIn 0.30s cubic-bezier(0.34,1.46,0.64,1) both;}

  @supports (height: 100dvh) { .modal-mobile-safe { height: 92dvh; } }
  @media (max-width: 767px) {
    .modal-overlay {
      padding-bottom: env(safe-area-inset-bottom, 12px);
      padding-top: env(safe-area-inset-top, 12px);
    }
  }

  .modal-in.modal-mobile-safe,
  div.modal-in.modal-mobile-safe{
    border-radius: 24px !important;
    overflow: hidden !important;
    border: 1px solid rgba(255, 255, 255, 0.2) !important;
    -webkit-border-radius: 24px !important;
  }
  .modal-in.modal-mobile-safe > div,
  .modal-in.modal-mobile-safe > *{
    border-radius: inherit !important;
    overflow: hidden !important;
  }
  @media (max-width: 767px) {
    .modal-in.modal-mobile-safe,
    div.modal-in.modal-mobile-safe{
      border-radius: 20px !important;-webkit-border-radius: 20px !important;
      border-top-left-radius: 20px !important;border-top-right-radius: 20px !important;
      border-bottom-left-radius: 20px !important;border-bottom-right-radius: 20px !important;
    }
    .modal-in.modal-mobile-safe[style*="border-radius"],
    .modal-in.modal-mobile-safe[style*="radius"]{border-radius: 20px !important;}
  }
  @media (max-width: 767px) {
    .modal-in[class*="mobile"],.modal-in[class*="safe"]{border-radius: 20px !important;overflow: hidden !important;}
  }

  .settings-page-root{width:100%;max-width:100%;box-sizing:border-box;}
  .settings-section-container{width:100%;max-width:666px;box-sizing:border-box;margin-left:auto;margin-right:auto;}
  .settings-section-container > *{max-width:100%;box-sizing:border-box;overflow-wrap:break-word;word-break:break-word;}
  .settings-section-container input,.settings-section-container select,.settings-section-container button{max-width:100%;box-sizing:border-box;}

  @media (max-width:768px){
    .settings-theme-grid{display:grid!important;grid-template-columns:repeat(4,minmax(0,1fr));gap:8px!important;}
    .settings-theme-grid > button{width:100%!important;min-width:0!important;}
  }
  @media (min-width: 992px) {
    .settings-theme-grid{display:grid!important;grid-template-columns:repeat(6,1fr)!important;gap:10px;justify-content:center;}
  }

  .section-label{
    font-size:0.68rem;font-weight:600;letter-spacing:0.09em;text-transform:uppercase;
    color:rgba(255,255,255,0.30);margin:0 0 12px 4px;
    max-width:100%;box-sizing:border-box;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;
  }

  .fmt-btn{
    width:34px;height:30px;border-radius:8px;border:none;cursor:pointer;
    font-family:'Inter',monospace;font-size:0.76rem;font-weight:700;
    background:transparent;color:rgba(255,255,255,0.30);
    transition:background 0.15s,color 0.15s;
    display:flex;align-items:center;justify-content:center;
    user-select:none;-webkit-user-select:none;
  }
  .fmt-btn:hover{background:rgba(255,255,255,0.09);color:rgba(255,255,255,0.90);}
  .fmt-btn:active{background:rgba(255,255,255,0.14);}

  .icon-btn{
    width:36px;height:36px;border-radius:50%;border:none;cursor:pointer;
    background:transparent;display:flex;align-items:center;justify-content:center;
    transition:background 0.18s;flex-shrink:0;
  }
  .icon-btn:hover{background:rgba(255,255,255,0.08);}

  /* Floating Action Button — real glassmorphism, matching NoteCard layering */
  .fab-btn{
    transform:translateY(0);
    transition:transform 0.32s cubic-bezier(0.34,1.56,0.64,1),filter 0.28s ease;
    will-change:transform;
    backface-visibility:hidden;-webkit-backface-visibility:hidden;
  }
  .fab-btn:hover{transform:translateY(-3px) scale(1.04);filter:brightness(1.08);}
  .fab-btn:active{transform:translateY(-1px) scale(0.97);transition:transform 0.12s ease;}
  .fab-btn:focus-visible{outline:2px solid rgba(255,255,255,0.55);outline-offset:4px;border-radius:18px;}
  .fab-btn > .card-glass{transition:box-shadow 0.28s ease,border-color 0.28s ease,background 0.28s ease;}
  .fab-btn:hover > .card-glass{
    background:rgba(255,255,255,0.14);
    border-color:rgba(255,255,255,0.40);
    box-shadow:
      0 22px 60px rgba(0,0,0,0.60),
      inset 0 1px 0 rgba(255,255,255,0.25),
      inset 0 -1px 0 rgba(0,0,0,0.20),
      0 0 24px rgba(255,255,255,0.10);
  }
  .fab-btn:hover > .card-glass > .glass-ring{
    background:linear-gradient(160deg,rgba(255,255,255,0.60) 0%,rgba(255,255,255,0.14) 45%,rgba(255,255,255,0.02) 100%);
  }
  .fab-btn:hover > .card-glass > .glass-sheen{opacity:1;}
  .fab-btn > .card-glass > .glass-sheen{opacity:0.7;}

  /* Respect users who prefer reduced motion (accessibility). */
  @media (prefers-reduced-motion: reduce){
    *,*::before,*::after{
      animation-duration:0.001ms!important;
      animation-iteration-count:1!important;
      transition-duration:0.001ms!important;
      scroll-behavior:auto!important;
    }
  }
`;
}
